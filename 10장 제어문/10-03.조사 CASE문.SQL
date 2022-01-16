SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 예제 8-12 조사 CASE 표현식 → 조사 CASE문으로 변경함
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Searched CASE Statement
  CASE WHEN v_BOOL = TRUE THEN
         v_STR := 'v_BOOL is TRUE' ;
       WHEN v_BOOL = FALSE THEN
         v_STR := 'v_BOOL is FALSE' ;
       ELSE
         v_STR := 'v_BOOL is NULL' ;
  END CASE ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;
