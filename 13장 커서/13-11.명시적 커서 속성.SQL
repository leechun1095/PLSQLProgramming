SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 명시적 커서 속성
DECLARE
  CURSOR emp_cursor IS
    SELECT ename, hiredate
      FROM emp
     WHERE deptno = 10
     ORDER BY hiredate desc;
BEGIN
  FOR t IN emp_cursor
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(t.ename, 6,' ')||
      ', 입사 일자='|| TO_CHAR(t.hiredate, 'YYYY-MM-DD')) ;
    IF emp_cursor%ROWCOUNT >= 3 THEN -- 명시적 커서 속성 커서명%ROWCOUNT
      EXIT ; -- 3건 이상인 경우 루프 종료하라는 의미
    END IF ;
  END LOOP ;
END ;
