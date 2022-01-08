SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	c_hiredate DATE := DATE'2016-01-02';
	v_empno		 emp.empno%TYPE;
	v_ename		 emp.ename%TYPE;
	v_hiredate emp.hiredate%TYPE;
BEGIN
	DELETE FROM emp
	 WHERE empno = 9000;

	-- INSERT 후 삽입된 값을 반환
	INSERT INTO emp
  (
		empno
	, ename
	, hiredate
	, deptno
	)
	VALUES
	(
		9000
	, '홍길동'
	, c_hiredate
	, 40
	)
	RETURNING empno, ename, hiredate          -- 컬럼을
			 INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원추가=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');

	-- UPDATE 후 변경된 값을 반환
	UPDATE emp
		 SET HIREDATE = c_hiredate
	 WHERE empno = v_empno
	 RETURNING empno, ename, hiredate          -- 컬럼을
				INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원변경=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');

	-- DELETE 후 삭제된 사원의 사번, 이름, 입사일 반환
	DELETE FROM emp
	 WHERE empno = v_empno
	 RETURNING empno, ename, hiredate          -- 컬럼을
				INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원삭제=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');
	COMMIT;
END;
