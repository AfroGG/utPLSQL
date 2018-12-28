create or replace type ut_realtime_reporter force under ut_output_reporter_base(
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  /**
   * Total number of all tests in the run (incl. disabled tests).
   */
  total_number_of_tests integer, 
 
  /**
   * Currently executed test number.
   */
  current_test_number integer,

  /**
   * Current indentation in logical tabs.
   */
  current_indent integer,
  
  /**
   * The realtime reporter.
   * Provides test results in a XML format, for clients such as SQL Developer interested progressing details.
   */
  constructor function ut_realtime_reporter(
    self in out nocopy ut_realtime_reporter
  ) return self as result,

  /**
   * Provides meta data of complete run in advance.
   * Used to show total tests and initialize a progress bar.
   */
  overriding member procedure before_calling_run(
    self  in out nocopy ut_realtime_reporter, 
    a_run in            ut_run
  ),

  /**
   * Provides closing tag with runtime summary.
   */
  overriding member procedure after_calling_run(
    self  in out nocopy ut_realtime_reporter, 
    a_run in            ut_run
  ),

  /**
   * Indicates the start of a test suite execution.
   */
  overriding member procedure before_calling_suite(
    self    in out nocopy ut_realtime_reporter, 
    a_suite in ut_logical_suite
  ),

  /**
   * Provides meta data of completed test suite with runtime.
   */
  overriding member procedure after_calling_suite(
    self    in out nocopy ut_realtime_reporter, 
    a_suite in ut_logical_suite
  ),


  /**
   * Indicates the start of a test.
   */
  overriding member procedure before_calling_test(
    self   in out nocopy ut_realtime_reporter, 
    a_test in            ut_test
  ),

  /**
   * Provides meta data of a completed test with runtime and status. 
   */
  overriding member procedure after_calling_test(
    self   in out nocopy ut_realtime_reporter, 
    a_test in            ut_test
  ),

  /**
   * Provides the description of this reporter.
   */
  overriding member function get_description return varchar2,

  /**
   * Prints the start tag of an XML with an optional id attribute.
   */
  member procedure print_start_node(
     self      in out nocopy ut_realtime_reporter,
     a_name    in            varchar2,
     a_id      in            varchar2             default null
  ),
  
  /**
   * Prints the end tag of an XML node.
   */
  member procedure print_end_node(
    self   in out nocopy ut_realtime_reporter, 
    a_name in            varchar2
  ),

  /**
   * Prints a child node with content. Content will be XML encoded.
   */
  member procedure print_node(
     self      in out nocopy ut_realtime_reporter,
     a_name    in            varchar2,
     a_content in            clob
  ),
  
  /**
   * Prints a child node with content. Content is passed 1:1 incl. new lines, etc. using CDATA.
   */
  member procedure print_cdata_node(
     self      in out nocopy ut_realtime_reporter,
     a_name    in            varchar2,
     a_content in            clob
  ),

  /**
   * Prints a line of the resulting XML document using the current indentation.
   * a_indent_summand_before is added before printing a line.
   * a_indent_summand_after is added after printing a line.
   * All output is produced through this function.
   */
  member procedure print_xml_fragment(
    self                    in out nocopy ut_realtime_reporter, 
    a_fragment              in            clob, 
    a_indent_summand_before in            integer              default 0,
    a_indent_summand_after  in            integer              default 0
  )
)
not final
/
