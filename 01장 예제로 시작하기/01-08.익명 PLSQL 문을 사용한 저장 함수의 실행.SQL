--===============================================================
-- /* Example 1-8 익명 PL/SQL문을 사용한 저장 함수 실행 */
--===============================================================
SET SERVEROUTPUT ON;
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  v_cnt := get_dept_employee_count(10);
  DBMS_OUTPUT.PUT_LINE('사원수: '|| v_cnt);
END;
