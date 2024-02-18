create or replace package body test_tfs_junit_reporter as

  procedure crate_a_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate q'[create or replace package check_junit_reporting is
      --%suite(A suite with <tag>)

      --%test(A test with <tag>)
      procedure test_do_stuff;

    end;]';
    execute immediate q'[create or replace package body check_junit_reporting is
      procedure test_do_stuff is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
        ut3_develop.ut.expect(1).to_equal(2);
      end;

    end;]';

    execute immediate q'[create or replace package check_junit_rep_suitepath is
      --%suitepath(core)
      --%suite(check_junit_rep_suitepath)
      --%displayname(Check JUNIT Get path for suitepath)

      --%test(check_junit_rep_suitepath)
      --%displayname(Check JUNIT Get path for suitepath)
      procedure check_junit_rep_suitepath;
    end;]';
    execute immediate q'[create or replace package body check_junit_rep_suitepath is
      procedure check_junit_rep_suitepath is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;
    end;]';

  execute immediate q'[create or replace package check_junit_flat_suitepath is
      --%suitepath(core.check_junit_rep_suitepath)
      --%suite(flatsuitepath)

      --%beforeall
      procedure donuffin;
    end;]';
    execute immediate q'[create or replace package body check_junit_flat_suitepath is
      procedure donuffin is
      begin
        null;
      end;
    end;]';

    execute immediate q'[create or replace package check_junit_in_context is
      --%suitepath(core.check_junit_rep_suitepath)
      --%suite(inctxsuite)
      --%displayname(JUNIT test are inside context)

      -- %context(incontext)
      -- %name(incontext)

      --%test(incontext)
      --%displayname(Check JUNIT Get path incontext)
      procedure check_junit_rep_incontext;

      -- %endcontext
    end;]';
    execute immediate q'[create or replace package body check_junit_in_context is
      procedure check_junit_rep_incontext is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;
    end;]';

    execute immediate q'[create or replace package check_junit_out_context is
      --%suitepath(core)
      --%suite(outctxsuite)
      --%displayname(JUNIT test are outside context)

      -- %context(outcontext)
      -- %name(outcontext)

      -- %endcontext


      --%test(outctx)
      --%displayname(outctx)
      procedure outctx;


    end;]';
    execute immediate q'[create or replace package body check_junit_out_context is
      procedure outctx is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;
    end;]';

    execute immediate q'[create or replace package check_junit_inout_context is
      --%suitepath(core)
      --%suite(inoutcontext)
      --%displayname(Test in and out of context)

      -- %context(incontext)
      -- %name(ProductincontextFeatures)

      --%test(inctx)
      --%displayname(inctx)
      procedure inctx;

      -- %endcontext


      --%test(outctx)
      --%displayname(outctx)
      procedure outctx;


    end;]';
    execute immediate q'[create or replace package body check_junit_inout_context is
      procedure inctx is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;

      procedure outctx is
      begin
        ut3_develop.ut.expect(1).to_equal(1);
      end;      
    end;]';

  end;

  procedure escapes_special_chars is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%<tag>%');
    ut.expect(l_actual).to_be_like('%&lt;tag&gt;%');
  end;

  procedure reports_only_failed_or_errored is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).not_to_be_like('%Actual: 1 (number) was expected to equal: 1 (number)%');
    ut.expect(l_actual).to_be_like('%Actual: 1 (number) was expected to equal: 2 (number)%');
  end;

  procedure check_classname_suite is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_reporting',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="check_junit_reporting"%');
  end;

 procedure check_flatten_nested_suites is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_flat_suitepath',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0"?>
<testsuites>
<testsuite tests="0" id="1" package="core.check_junit_rep_suitepath.check_junit_flat_suitepath"  errors="0" failures="0" name="flatsuitepath" time="%"  timestamp="%"  hostname="%" >
<properties/>
<system-out/>
<system-err/>
</testsuite>%');
  end;

  procedure check_nls_number_formatting is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;
    l_nls_numeric_characters varchar2(30);
  begin
    --Arrange
    select replace(nsp.value,'''','''''') into l_nls_numeric_characters
    from nls_session_parameters nsp
    where parameter = 'NLS_NUMERIC_CHARACTERS';
    execute immediate q'[alter session set NLS_NUMERIC_CHARACTERS=', ']';
    --Act
    select *
    bulk collect into l_results
    from table(ut3_develop.ut.run('check_junit_reporting', ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_match('time="[0-9]*\.[0-9]{3,6}"');
    --Cleanup
    execute immediate 'alter session set NLS_NUMERIC_CHARACTERS='''||l_nls_numeric_characters||'''';
  end;

  procedure check_failure_escaped is
  begin
    reporters.check_xml_failure_escaped(ut3_develop.ut_tfs_junit_reporter());
  end;

  procedure check_classname_suitepath is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_rep_suitepath',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('%testcase classname="core.check_junit_rep_suitepath"%');   
  end;
  procedure remove_test_package is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package check_junit_reporting';
    execute immediate 'drop package check_junit_rep_suitepath';
    execute immediate 'drop package check_junit_flat_suitepath';
  end;

  procedure check_encoding_included is
  begin
    reporters.check_xml_encoding_included(ut3_develop.ut_tfs_junit_reporter(), 'UTF-8');
  end;

  procedure reports_only_test_in_ctx is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_in_context',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0"?>
<testsuites>
<testsuite tests="1" id="1" package="core.check_junit_rep_suitepath.check_junit_in_context"  errors="0" failures="0" name="JUNIT test are inside context" time="%"  timestamp="%"  hostname="%" >
<properties/>
<testcase classname="core.check_junit_rep_suitepath.check_junit_in_context.incontext"  name="Check JUNIT Get path incontext" time="%">
</testcase>
<system-out/>
<system-err/>
</testsuite>
</testsuites>%');
  end;

  procedure reports_only_test_out_ctx is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_out_context',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0"?>
<testsuites>
<testsuite tests="1" id="1" package="core.check_junit_out_context"  errors="0" failures="0" name="JUNIT test are outside context" time="%"  timestamp="%"  hostname="%" >
<properties/>
<testcase classname="core.check_junit_out_context"  name="outctx" time="%">
</testcase>
<system-out/>
<system-err/>
</testsuite>
</testsuites>%');
  end;

  procedure reports_only_test_inout_ctx is
    l_results   ut3_develop.ut_varchar2_list;
    l_actual    clob;    
  begin
    --Act
    select *
      bulk collect into l_results
      from table(ut3_develop.ut.run('check_junit_inout_context',ut3_develop.ut_tfs_junit_reporter()));
    l_actual := ut3_tester_helper.main_helper.table_to_clob(l_results);
    --Assert
    ut.expect(l_actual).to_be_like('<?xml version="1.0"?>
<testsuites>
<testsuite tests="2" id="1" package="core.check_junit_inout_context"  errors="0" failures="0" name="Test in and out of context" time="%"  timestamp="%"  hostname="%" >
<properties/>
<testcase classname="core.check_junit_inout_context.ProductincontextFeatures"  name="inctx" time="%">
</testcase>
<testcase classname="core.check_junit_inout_context"  name="outctx" time="%">
</testcase>
<system-out/>
<system-err/>
</testsuite>
</testsuites>%');
  end;

end;
/