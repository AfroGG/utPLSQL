create or replace package body test_cov_cobertura_reporter is

  procedure report_on_file is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected := 
    q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="2" lines-valid="3" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>test/ut3_develop.dummy_coverage.pkb</source>
</sources>
<packages>
<package name="DUMMY_COVERAGE" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="DUMMY_COVERAGE" filename="test/ut3_develop.dummy_coverage.pkb" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
<line number="4" hits="1" branch="false"/>
<line number="5" hits="0" branch="false"/>
<line number="7" hits="1" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter => ut3_develop.ut_coverage_cobertura_reporter( ),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.dummy_coverage.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure report_zero_coverage is
    l_expected  clob;
    l_actual    clob;
  begin
    --Arrange
    l_expected :=
    q'[<?xml version="1.0"?>
<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
<coverage line-rate="0" branch-rate="0.0" lines-covered="0" lines-valid="10" branches-covered="0" branches-valid="0" complexity="0" version="1" timestamp="%">
<sources>
<source>ut3_develop.dummy_coverage</source>
</sources>
<packages>
<package name="DUMMY_COVERAGE" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<class name="DUMMY_COVERAGE" filename="ut3_develop.dummy_coverage" line-rate="0.0" branch-rate="0.0" complexity="0.0">
<lines>
<line number="1" hits="0" branch="false"/>
<line number="2" hits="0" branch="false"/>
<line number="3" hits="0" branch="false"/>
<line number="4" hits="0" branch="false"/>
<line number="5" hits="0" branch="false"/>
<line number="6" hits="0" branch="false"/>
<line number="7" hits="0" branch="false"/>
<line number="8" hits="0" branch="false"/>
<line number="9" hits="0" branch="false"/>
<line number="10" hits="0" branch="false"/>
</lines>
</class>
</package>
</packages>
</coverage>]';

    ut3_tester_helper.coverage_helper.drop_long_name_package();
    --Act
    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              'ut3_develop.test_dummy_coverage.zero_coverage',
              ut3_develop.ut_coverage_cobertura_reporter(),
              a_include_objects => ut3_develop.ut_varchar2_list('UT3_DEVELOP.DUMMY_COVERAGE')
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
    --Cleanup
    ut3_tester_helper.coverage_helper.create_dummy_coverage;
  end;

end;
/
