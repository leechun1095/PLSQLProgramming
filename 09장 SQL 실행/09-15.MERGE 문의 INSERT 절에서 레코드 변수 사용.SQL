SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_emprec	emp%ROWTYPE;
BEGIN
	SELECT *
		INTO v_emprec
		FROM emp
	 WHERE empno = 7788;

	v_emprec.empno := 9000;
	v_emprec.ename := '홍길동';

	MERGE INTO emp a
	USING DUAL
		 ON (a.empno = v_emprec.empno)
	 WHEN MATCHED THEN
		 UPDATE							-- MERGE 문의 UPDATE절에서는 레코드 변수를 사용할 수 없다.
				SET a.comm = a.comm * 1.1
	 WHEN NOT MATCHED THEN
		 INSERT
		 VALUES v_emprec;		-- MERGE 문의 INSERT절에서는 레코드 변수를 사용할 수 있다.
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;
