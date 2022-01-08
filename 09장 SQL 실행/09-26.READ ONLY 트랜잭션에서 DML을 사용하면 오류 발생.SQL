SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM READ ONLY 트랜잭션에서 DML을 사용하면 오류 발생
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ;
  SET TRANSACTION READ ONLY ; -- DML을 금지시킨다.
  -- DML을 다시 가능하게 하려면 아래와 같이 사용한다.
  -- SET TRANSACTION READ WRITE ;
  -- 다음 INSERT문은 DML이므로 오류를 발생시킨다.
  INSERT INTO emp(empno, ename, hiredate, sal) VALUES (9000, '홍길동', SYSDATE, 9000) ;
END ;
