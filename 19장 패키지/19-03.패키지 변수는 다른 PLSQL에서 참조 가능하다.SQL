SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_var		NUMBER;
BEGIN
	v_var := pkg_emp.get_wage(7788);
	DBMS_OUTPUT.PUT_LINE('last wage = ' || pkg_emp.v_last_wage);	-- 패키지 변수 참조
END;
