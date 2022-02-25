SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  c_stmt CONSTANT VARCHAR2(1000) :=
    Q'<BEGIN
        :a := :a + :b;
        DBMS_OUTPUT.PUT_LINE('a='||:a||', b='||:b);
       END;>';
  v_a NUMBER := 2;
  v_b NUMBER := 3;
BEGIN
  EXECUTE IMMEDIATE c_stmt USING IN OUT v_a, v_b;
END ;
