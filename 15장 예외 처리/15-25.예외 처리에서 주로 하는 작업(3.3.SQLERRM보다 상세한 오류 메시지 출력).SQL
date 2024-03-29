SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 예외 처리에서 주로 하는 작업
REM 3. 디버깅 정보 출력
REM 동일 프로그램에 대해 단순한 SQLERRM보다 상세한 오류 메시지 출력
DECLARE
  PROCEDURE p IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20001, '사용자 지정 예외') ;
  END ;
BEGIN
  p ;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM) ;
  DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE) ;
END ;
