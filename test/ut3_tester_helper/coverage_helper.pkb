create or replace package body coverage_helper is

  g_job_no          integer := 0;

  function block_coverage_available return boolean is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return true;
    $else
      return false;
    $end
  end;

  function covered_package_name return varchar2 is
  begin
    $if dbms_db_version.version = 12 and dbms_db_version.release >= 2 or dbms_db_version.version > 12 $then
      return 'dummy_coverage_package_with_an_amazingly_long_name_that_you_would_not_think_of_in_real_life_project_because_its_simply_too_long';
    $else
      return 'dummy_coverage';
    $end
  end;

  function substitute_covered_package( a_text varchar2, a_substitution varchar2 ) return varchar2 is
  begin
    return replace( replace( a_text, a_substitution, covered_package_name() ), upper(a_substitution), upper(covered_package_name()) );
  end;

  procedure set_develop_mode is
  begin
    ut3_develop.ut_coverage.set_develop_mode(true);
  end;


  procedure create_dummy_coverage is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.]'||covered_package_name||q'[ is
      procedure do_stuff(i_input in number);
    end;]';

    execute immediate q'[create or replace package body ut3_develop.]'||covered_package_name||q'[ is
      procedure do_stuff(i_input in number) is
      begin
        if i_input = 2 then dbms_output.put_line('should not get here'); elsif i_input = 1 then dbms_output.put_line('should get here');
        else
          dbms_output.put_line('should not get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_dummy_coverage is
      --%suite(dummy coverage test)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;

      --%test
      procedure zero_coverage;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_dummy_coverage is
      procedure test_do_stuff is
      begin
        ]'||covered_package_name||q'[.do_stuff(1);
        ut.expect(1).to_equal(1);
      end;
      procedure zero_coverage is
      begin
        null;
      end;
    end;]';

  end;

  procedure drop_dummy_coverage is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.test_dummy_coverage]';    exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.]'||covered_package_name; exception when others then null; end;
  end;
 

  procedure create_dummy_coverage_1 is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package ut3_develop.dummy_coverage_1 is
      procedure do_stuff;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.dummy_coverage_1 is
      procedure do_stuff is
      begin
        if 1 = 2 then
          dbms_output.put_line('should not get here');
        else
          dbms_output.put_line('should get here');
        end if;
      end;
    end;]';

    execute immediate q'[create or replace package ut3_develop.test_dummy_coverage_1 is
      --%suite(dummy coverage test 1)
      --%suitepath(coverage_testing)

      --%test
      procedure test_do_stuff;
    end;]';

    execute immediate q'[create or replace package body ut3_develop.test_dummy_coverage_1 is
      procedure test_do_stuff is
      begin
        dummy_coverage_1.do_stuff;
      end;
      
    end;]';
  end;

  procedure drop_dummy_coverage_1 is
    pragma autonomous_transaction;
  begin
    begin execute immediate q'[drop package ut3_develop.dummy_coverage_1]'; exception when others then null; end;
    begin execute immediate q'[drop package ut3_develop.test_dummy_coverage_1]'; exception when others then null; end;
  end;

  procedure run_standalone_coverage(a_coverage_run_id raw, a_input integer) is
  begin
    ut3_develop.ut_runner.coverage_start(a_coverage_run_id);
    execute immediate 'begin ut3_develop.'||covered_package_name||'.do_stuff(:a_input); end;' using in a_input;
    ut3_develop.ut_runner.coverage_stop();
  end;

  function get_job_status(a_job_name varchar2, a_job_started_after timestamp with time zone) return varchar2 is
    l_status varchar2(1000);
  begin
    begin
      select status into l_status
        from user_scheduler_job_run_details
       where job_name = upper(a_job_name)
         and req_start_date >= a_job_started_after;
    exception
      when no_data_found then
      null;
    end;
    return l_status;
  end;

  procedure sleep(a_time number) is
  begin
    $if dbms_db_version.version >= 18 $then
      dbms_session.sleep(a_time);
    $else
      dbms_lock.sleep(a_time );
    $end
  end;

  procedure run_job_and_wait_for_finish(a_job_action varchar2) is
    l_status          varchar2(1000);
    l_job_name        varchar2(30);
    l_timestamp       timestamp with time zone := current_timestamp;
    i integer := 0;
    pragma autonomous_transaction;
  begin
    g_job_no := g_job_no + 1;
    l_job_name := 'utPLSQL_selftest_job_'||g_job_no;
    sleep(0.01);
    dbms_scheduler.create_job(
      job_name      =>  l_job_name,
      job_type      =>  'PLSQL_BLOCK',
      job_action    =>  a_job_action,
      start_date    =>  l_timestamp,
      enabled       =>  TRUE,
      auto_drop     =>  TRUE,
      comments      =>  'one-time-job'
      );
    while (l_status is null or l_status not in ('SUCCEEDED','FAILED')) and i < 30 loop
      l_status := get_job_status( l_job_name, l_timestamp );
      sleep(0.1);
      i := i + 1;
    end loop;
    commit;
    if l_status = 'FAILED' then
      raise_application_error(-20000, 'Running a scheduler job failed');
    end if;
  end;

  procedure run_coverage_job(a_coverage_run_id raw, a_input integer) is
  begin
    run_job_and_wait_for_finish(
      'begin coverage_helper.run_standalone_coverage('''||a_coverage_run_id||''', '||a_input||'); end;'
      );
  end;

  procedure create_test_results_table is
    pragma autonomous_transaction;
    e_exists exception;
    pragma exception_init ( e_exists, -955 );
  begin
    execute immediate 'create table test_results (text varchar2(4000))';
  exception
    when e_exists then
      null;
  end;

  procedure drop_test_results_table is
    pragma autonomous_transaction;
    e_not_exists exception;
    pragma exception_init ( e_not_exists, -942 );
  begin
    execute immediate 'drop table test_results';
  exception
    when e_not_exists then
      null;
  end;

  function run_code_as_job( a_plsql_block varchar2 ) return clob is
    l_result_clob clob;
    pragma autonomous_transaction;
  begin
    run_job_and_wait_for_finish( a_plsql_block );

    execute immediate q'[
      declare
        l_results ut3_develop.ut_varchar2_list;
      begin
        select *
          bulk collect into l_results
          from test_results;
        delete from test_results;
        commit;
        :clob_results := ut3_tester_helper.main_helper.table_to_clob(l_results);
      end;
      ]'
    using out l_result_clob;

    return l_result_clob;
  end;

  function run_tests_as_job( a_run_command varchar2 ) return clob is
    l_plsql_block varchar2(32767);
    l_result_clob clob;
    pragma autonomous_transaction;
  begin
    l_plsql_block := 'begin insert into test_results select * from table( {a_run_command} ); commit; end;';
    l_plsql_block := replace(l_plsql_block,'{a_run_command}',a_run_command);
    return run_code_as_job( l_plsql_block );
  end;

end;
/
