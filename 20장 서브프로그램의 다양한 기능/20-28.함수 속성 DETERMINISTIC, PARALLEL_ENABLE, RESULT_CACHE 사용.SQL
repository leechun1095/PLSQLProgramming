SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 지시자의 위치는 저장 함수의 RETURN 절과 IS(AS) 사이다.
CREATE OR REPLACE FUNCTION factorial(a_num PLS_INTEGER)
RETURN NUMBER
  DETERMINISTIC PARALLEL_ENABLE RESULT_CACHE
IS
BEGIN
  IF a_num <= 1 THEN
    RETURN 1 ;
  ELSE
    RETURN a_num * factorial(a_num-1) ;
  END IF ;
END ;
