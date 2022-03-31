SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

SELECT pkg_emp.v_last_wage	-- 패키지 변수는 외부 SQL문에서 참조할 수 없다.
	FROM DUAL;
