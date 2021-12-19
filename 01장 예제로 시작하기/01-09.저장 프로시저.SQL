--===============================================================
-- /* Example 1-9 저장 프로시저 */
--===============================================================
CREATE OR REPLACE PROCEDURE register_employee(
		  a_empno			NUMBER,		-- 등록할 사번 매개변수
		  a_ename			VARCHAR2,	-- 등록할 이름 매개변수
		  a_job				VARCHAR2,	-- 등록할 업무 매개변수
		  a_rslt_out OUT	BOOLEAN,	-- 처리 성공 여부
		  a_msg_out	 OUT	VARCHAR2	-- 처리 결과를 반환하는 변수
)
IS
	c_default_deptno CONSTANT NUMBER := 20;	-- DEFAULT 부서 코드

	v_cnt		NUMBER;		-- 건수
BEGIN
	-- 주어진 사번의 존재 여부 확인
	SELECT COUNT(*)
	  INTO v_cnt
	  FROM emp
	 WHERE empno = a_empno;

	IF v_cnt > 0 THEN
	  UPDATE emp
		 SET ename = a_ename,
			 job   = a_job
	   WHERE ename = a_ename;

	  a_msg_out := '사원 "'  || a_ename || '"이(가) 등록되었습니다.' ;
	ELSE
	  INSERT INTO emp(empno, ename, job, deptno)
	  VALUES (a_empno, a_ename, a_job, c_default_deptno);

	  a_msg_out := '신입사원 "'  || a_ename || '"이(가) 등록되었습니다.' ;
	END IF;
	a_rslt_out := TRUE;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  a_msg_out  := '응용프로그램 오류 발생' || CHR(10) || SQLERRM;
  a_rslt_out := FALSE;
END;
