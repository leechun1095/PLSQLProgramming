SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno  %TYPE;
	v_ename		emp.ENAME	 %TYPE;
	v_deptno	emp.deptno %TYPE;
	v_job			emp.job 	 %TYPE;
BEGIN
	SELECT empno
		   , ename
			 , deptno
			 , job
	  INTO v_empno
		   , v_ename
			 , v_deptno
			 , v_job
	  FROM emp
	 WHERE empno = 7788;
	DBMS_OUTPUT.PUT_LINE('v_empno = ' || v_empno);
	DBMS_OUTPUT.PUT_LINE('v_ename  = ' || v_ename);
	DBMS_OUTPUT.PUT_LINE('v_deptno = ' || v_deptno);
	DBMS_OUTPUT.PUT_LINE('v_job = ' || v_job);
END;
