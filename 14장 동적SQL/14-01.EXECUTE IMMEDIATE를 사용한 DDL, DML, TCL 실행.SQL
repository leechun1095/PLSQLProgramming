SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXECUTE IMMEDIATE를 사용한 DDL, DML, DCL의 실행
DECLARE
  v_insert_stmt CONSTANT VARCHAR2(100) := 'INSERT INTO t VALUES(1, ''서울'')' ;
BEGIN
  -- DDL 실행. 리터럴 사용
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE t' ;
  EXCEPTION WHEN OTHERS THEN
    NULL ; -- 테이블이 없을 때 발생하는 오류는 무시함
  END ;
  EXECUTE IMMEDIATE 'CREATE TABLE t(a NUMBER, b VARCHAR2(10))' ;

  -- DML 실행. 문자열 변수 사용
  EXECUTE IMMEDIATE v_insert_stmt ;

  -- TCL 실행. 리터럴 사용
  EXECUTE IMMEDIATE 'COMMIT' ;
END ;
