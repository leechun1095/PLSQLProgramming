SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp;
	v_emprec ename_cursor%ROWTYPE;
BEGIN
	OPEN ename_cursor;

	LOOP
		FETCH ename_cursor INTO v_emprec;
		EXIT WHEN ename_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_emprec.empno ||', ename = ' || v_emprec.ename);
	END LOOP;

	CLOSE ename_cursor;
END;
