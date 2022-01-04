SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno%TYPE := 9000;
	v_deptno	emp.deptno%TYPE := 40;
BEGIN
	UPDATE emp
		 SET deptno = v_deptno
	 WHERE empno = v_empno;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
END;
