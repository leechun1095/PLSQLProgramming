SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- 예제 10-15를 WHILE LOOP로 변경
DECLARE
  v_num NUMBER := 1 ;
BEGIN
  WHILE v_num <= 3
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프내부 : ' || v_num) ;
    v_num := v_num + 1 ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프종료 : ' || v_num) ;
END ;
