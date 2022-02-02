SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_total_pay NUMBER := 0;  -- 급여 합계 계산
	-- 앞의 예제에서 FOR문에 포함되었던 SELECT문을 커서 문으로 선언하여 사용
	CURSOR emp_cursor IS
	-- CURSOR FOR LOOP 에 사용된 컬럼에 계산식이 있는 경우 꼭 Alias를 사용해야함.
	SELECT ename, hiredate, deptno, NVL(sal,0)+NVL(comm,0) total_pay
		FROM emp
	 WHERE deptno = 10;
BEGIN
	-- "(SELECT문)" 대신 위에서 선언한 커서명 emp_cursor를 사용
	FOR t IN emp_cursor
	LOOP
		DBMS_OUTPUT.PUT_LINE(
			RPAD(t.ename, 6, ' ') || ', 입사일자=' || TO_CHAR(t.hiredate, 'YYYY-MM-DD') || ', 급여=' || t.total_pay
		);
		v_total_pay := v_total_pay + NVL(t.total_pay, 0);
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('-------------------------------------');
	DBMS_OUTPUT.PUT_LINE('급여 합계 = $' || v_total_pay);
END;
