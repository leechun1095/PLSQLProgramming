SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 4개의 매개변수를 가지는 저장 함수
CREATE OR REPLACE FUNCTION f(a_empno NUMBER, a_ename VARCHAR2, a_hiredate DATE, a_deptno NUMBER)
RETURN VARCHAR2
AS
BEGIN
  NULL ;
END ;
