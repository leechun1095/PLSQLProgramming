
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CONTINUE 문
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  LOOP
    v_num:= v_num + 1 ;
    EXIT WHEN v_num > 5 ;
    IF v_num > 3 THEN
      CONTINUE; -- 5번 줄부터 다시 시작
    END IF ;
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;
