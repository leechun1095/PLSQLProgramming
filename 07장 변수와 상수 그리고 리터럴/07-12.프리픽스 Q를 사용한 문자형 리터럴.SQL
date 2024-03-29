SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 프리픽스 Q를 사용하면 경우 문자열 중간의 작은따옴표를
REM 겹따옴표로 변경할 필요가 없다.
DECLARE
  v_SQL VARCHAR2(1000) ;
BEGIN
  v_SQL := Q'[SELECT EMPNO, ENAME
                FROM EMP
               WHERE ENAME IN ('SMITH', 'ALLEN', 'WARD', 'JONES', 'MARTIN')]' ;
  DBMS_OUTPUT.PUT_LINE(v_SQL) ;
END ;
