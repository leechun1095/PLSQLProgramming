SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- 예외명은 표준이 정해져있다. 아무 예외명을 쓰면 오류남
-- Java에서 Exception 처리하듯이 모두 싸잡아서 예외처리하는 예외명은 'OTHERS'

REM 예외 미처리 시의 실행 결과
DECLARE
  v_value  number := 10 ;
  v_zero   number := 0 ;
  v_result number ;
BEGIN
  -- 0으로 나누기 하는 예외 발생
  v_result := v_value / v_zero ;

  -- 0으로 나눔에 대한 오류를 처리
  EXCEPTION WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('0으로 나눔 예외 발생');
END ;
