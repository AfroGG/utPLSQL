create or replace package body test_html_extended_reporter is

  procedure report_on_file is
    l_expected  varchar2(32767);
    l_actual    clob;
    l_charset   varchar2(100) := 'ISO-8859-1';
  begin
    --Arrange
    l_expected := '%<meta %charset='||l_charset||'" />%<h3>UT3_DEVELOP.DUMMY_COVERAGE_PACKAGE_WITH_AN_AMAZINGLY_' ||
    'LONG_NAME_THAT_YOU_WOULD_NOT_THINK_OF_IN_REAL_LIFE_PROJECT_BECAUSE_ITS_SIMPLY_TOO_LONG</h3>' ||
    '%<b>1</b> relevant lines. <span class="green"><b>1</b> lines covered</span> ' ||
    '(including <span class="yellow"><b>1</b> lines partially covered</span> ) and <span class="red"><b>0</b> lines missed%';

    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_block_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_html_reporter(),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.dummy_coverage_package_with_an_amazingly_long_name_that_you_would_not_think_of_in_real_life_project_because_its_simply_too_long.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( ),
              a_client_character_set => ']'||l_charset||q'['
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

end test_html_extended_reporter;
/
