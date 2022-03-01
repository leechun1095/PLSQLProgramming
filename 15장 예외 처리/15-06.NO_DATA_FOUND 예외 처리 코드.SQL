SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_empno emp.empno%TYPE := 1000;
  v_ename emp.ename%TYPE;
BEGIN
  SELECT ename
    INTO v_ename
    FROM emp
   WHERE empno = v_empno;
   DBMS_OUTPUT.PUT_LINE('사번 '||v_empno||'의 이름은 '||v_ename||'입니다.');

   -- 예외처리
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('사번 '||v_empno||'인 사원은 존재하지 않습니다.');
END;
