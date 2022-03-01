SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
  -- 예외 처리를 하지 않았으므로 프로그램이 오류로 중단된다.
  INSERT INTO dept(deptno, dname, loc)
  VALUES (40, 'CONSULTING', 'MANHATTAN');
END
;
