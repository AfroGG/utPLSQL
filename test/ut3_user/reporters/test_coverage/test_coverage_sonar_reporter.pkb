create or replace package body test_coverage_sonar_reporter is

  procedure report_on_file is
    l_expected  clob;
    l_actual    clob;
    l_block_cov clob;
  begin
    --Arrange
    if test_coverage.gc_block_coverage_enabled then
      l_block_cov := '<lineToCover lineNumber="7" covered="true" branchesToCover="1" coveredBranches="1"/>';
    else
      l_block_cov := '<lineToCover lineNumber="7" covered="true"/>';
    end if;
    l_expected := '<?xml version="1.0"?>
<coverage version="1">
<file path="test/ut3_develop.dummy_coverage.pkb">
<lineToCover lineNumber="4" covered="true"/>
<lineToCover lineNumber="5" covered="false"/>
'||l_block_cov||'
</file>
</coverage>';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_sonar_reporter( ),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.dummy_coverage.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_equal(l_expected);
  end;

  procedure check_encoding_included is
  begin
    reporters.check_xml_encoding_included(ut3_develop.ut_coverage_sonar_reporter(), 'UTF-8');
  end;

end;
/
