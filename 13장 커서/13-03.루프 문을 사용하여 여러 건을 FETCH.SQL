SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno NUMBER;
	v_ename emp.ename%TYPE;

	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp
		 ORDER BY empno;
BEGIN
	OPEN ename_cursor;

	LOOP
		FETCH ename_cursor INTO v_empno, v_ename;
		EXIT WHEN ename_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_empno ||', ename = ' || v_ename);
	END LOOP;

	CLOSE ename_cursor;
END;
