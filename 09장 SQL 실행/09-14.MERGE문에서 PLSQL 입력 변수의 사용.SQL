SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno%TYPE := 9000;
BEGIN
	MERGE INTO emp a
	USING DUAL
		 ON (a.empno = v_empno)
	 WHEN MATCHED THEN		-- 사번이 9000인 로우 존재 시 커미션을 10% 증가
		 UPDATE
				SET a.comm = a.comm * 1.1
	 WHEN NOT MATCHED THEN
		 INSERT
		 (
				empno
			, ename
			, job
			, hiredate
			, sal
			, deptno
		 )
		 VALUES
		 (
				v_empno
			, '홍길동'
			, 'CLERK'
			, SYSDATE
			, 3000
			, 10
		 );
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;
