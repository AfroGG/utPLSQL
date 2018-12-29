create or replace package test_realtime_reporter as

  --%suite(ut_realtime_reporter)
  --%suitepath(utplsql.core.reporters)

  --%beforeall
  procedure create_test_suites_and_run;
  
  --%test(Provide a report structure with pre-run information and event based messages per suite and per test)
  procedure xml_report_structure;
  
  --%test(Provide the total number of tests as part of the pre-run information structure)
  procedure total_number_of_tests;
  
  --%test(Escape special characters in data such as the test suite description)
  procedure escaped_characters;
  
  --%test(Provide a startTestEvent node before starting a test with testNumber and totalNumberOfTests)
  procedure number_of_starttestevent_nodes;
  
  --%test(Provide a endTestEvent node after completion of a test with test results)
  procedure endtestevent_nodes;

  --%test(Provide expectation message for a failed test)
  procedure single_failed_message;

  --%test(Provide expectation messages for each failed assertion of a failed test)
  procedure multiple_failed_messages;
  
  --%test(Provide dbms_output produced in a test)
  procedure serveroutput_of_test;

  --%test(Provide dbms_output produced in a testsuite)
  procedure serveroutput_of_testsuite;
  
  --%test(Provide the error stack of a test)
  procedure error_stack_of_test;

  --%test(Provide the error stack of a testsuite)
  procedure error_stack_of_testsuite;
  
  --%test(Provide a description of the reporter explaining the use for SQL Developer)
  procedure get_description;

  --%afterall
  procedure remove_test_suites;

end test_realtime_reporter;
/
