--===============================================================
-- /* Example 1-6 저장 함수 */
--===============================================================
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION get_dept_employee_count(
		  a_deptno NUMBER -- 사원 수를 계산할 부서 번호
		) RETURN NUMBER   -- 부서의 사원수를 반환
IS
  -- 변수
  v_cnt NUMBER;  -- 건수
BEGIN
  SELECT COUNT(*)
    INTO v_cnt
	FROM emp
   WHERE deptno = a_deptno;

  RETURN v_cnt;

EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('응용프로그램 오류 발생' || CHR(10) || SQLERRM);
  RETURN -1;
END;
