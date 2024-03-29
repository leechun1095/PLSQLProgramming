SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

CREATE OR REPLACE FUNCTION get_emp_rec(a_empno NUMBER)
  RETURN emp%ROWTYPE
IS
  v_emp_rec emp%ROWTYPE ;
BEGIN
  SELECT *
    INTO v_emp_rec
    FROM emp
   WHERE empno = a_empno;
  RETURN v_emp_rec ;
END ;
