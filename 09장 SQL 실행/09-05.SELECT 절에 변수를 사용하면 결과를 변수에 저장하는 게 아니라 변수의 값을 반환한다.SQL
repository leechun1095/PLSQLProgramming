SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_name		emp.ename%TYPE;
	v_ename 	emp.ename%TYPE;
BEGIN
	v_name := 'TIGER';
	SELECT v_name
	  INTO v_ename
    FROM emp
   WHERE empno = 7788;
  DBMS_OUTPUT.PUT_LINE('이름 = ' || v_ename);
END;
