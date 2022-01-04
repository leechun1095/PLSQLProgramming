SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_emprec	emp%ROWTYPE;
BEGIN
	v_emprec.empno := 9000;

	SELECT *
		INTO v_emprec
		FROM emp
	 WHERE empno = v_emprec.empno;

	v_emprec.ename	:= '홍길동';
	v_emprec.deptno := 40;

	UPDATE emp
		 SET ROW = v_emprec		-- 레코드 변수를 사용한 UPDATE, SET ROW 다음에만 레코드 변수 사용 가능
	 WHERE empno = v_emprec.empno;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;
