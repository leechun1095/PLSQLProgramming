SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 예제 8-11 단순 CASE 표현식 → 단순 CASE문으로 변경함
/*
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Simple CASE expression
  v_STR := CASE v_BOOL WHEN TRUE  THEN 'v_BOOL is TRUE'
                       WHEN FALSE THEN 'v_BOOL is FALSE'
                       ELSE            'v_BOOL is NULL'
           END ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;
*/
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Simple CASE Statement
  CASE v_BOOL WHEN TRUE THEN
                v_STR := 'v_BOOL is TRUE' ;
              WHEN FALSE THEN
                v_STR := 'v_BOOL is FALSE' ;
              ELSE
                v_STR := 'v_BOOL is NULL' ;
  END CASE ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;
