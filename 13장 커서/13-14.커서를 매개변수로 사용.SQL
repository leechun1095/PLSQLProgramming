SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_name	emp.ename%TYPE;
	v_empno NUMBER := 7788;

	-- 매개변수 a_empno를 가지는 명시적 커서
	CURSOR ename_cursor(a_empno NUMBER) IS
		SELECT ename
			FROM emp
		 WHERE empno = a_empno;
BEGIN
	-- 매개변수를 사용하여 커서를 OPEN한다.
	OPEN ename_cursor(v_empno);

	-- SELECT 결과를 FETCH 한다.
	FETCH ename_cursor
	 INTO v_name;
	DBMS_OUTPUT.PUT_LINE('이름 = ' || v_name);

	CLOSE ename_cursor;
END;
