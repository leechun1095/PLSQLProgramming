SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_ename emp.ename%TYPE NOT NULL := ' ';
  v_mgr   emp.mgr%TYPE NOT NULL := -1;
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
BEGIN
  -- KING은 상급자가 NULL이므로 SELECT 시 v_mgr(NOT NULL 변수)에 NULL이 할당된다.
  SELECT ename, mgr
    INTO v_ename, v_mgr
    FROM emp
   WHERE ename = 'KING';

  -- 예외처리
  EXCEPTION
    WHEN NO_DATA_FOUND THEN -- SELECT 되는 건이 없음
      DBMS_OUTPUT.PUT_LINE('사원이 존재하지 않습니다.');
    WHEN TOO_MANY_ROWS THEN -- SELECT 되는 건이 한건보다 많음
      DBMS_OUTPUT.PUT_LINE('조회되는 건수가 한 건보다 많습니다.');
    WHEN OTHERS THEN
      v_code := SQLCODE;
      v_errm := SUBSTR(SQLERRM, 1, 64);
      DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다.');
      DBMS_OUTPUT.PUT_LINE('오류 코드 '|| v_code || ': '|| v_errm);
--      DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다.');
--      DBMS_OUTPUT.PUT_LINE('오류 코드 '|| SQLCODE || ': '|| SUBSTR(SQLERRM, 1, 64));
END;
