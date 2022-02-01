SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE empno_arr IS TABLE OF NUMBER;
	TYPE ename_arr IS TABLE OF emp.ename%TYPE;

	v_empno empno_arr;
	v_ename ename_arr;

	-- 명시적 커서
	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp;
BEGIN
	-- 커서 OPEN
	OPEN ename_cursor;

	FETCH ename_cursor BULK COLLECT INTO v_empno, v_ename;
	DBMS_OUTPUT.PUT_LINE('사원 수 = '|| v_ename.COUNT);

	FOR i IN v_empno.FIRST..v_empno.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_empno(i) ||', ename = ' || v_ename(i));
	END LOOP;
	CLOSE ename_cursor;
END;
