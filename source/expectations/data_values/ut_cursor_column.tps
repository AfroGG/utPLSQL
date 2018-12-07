create or replace type ut_cursor_column force authid current_user as object
(
   parent_name      varchar2(4000),
   access_path      varchar2(4000),
   has_nested_col   number(1,0),
   transformed_name varchar2(32),
   hierarchy_level  number,
   column_position  number,
   xml_valid_name   varchar2(128),
   column_name      varchar2(128),
   column_type      varchar2(128),
   column_type_name varchar2(128),
   column_schema    varchar2(128),
   column_len       integer,
   is_sql_diffable  number(1, 0),
   is_collection    number(1, 0),

   member procedure init(self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer,a_access_path in varchar2),
     
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer,a_access_path in varchar2) 
   return self as result,
   
  constructor function ut_cursor_column( self in out nocopy ut_cursor_column) return self as result
)
/
