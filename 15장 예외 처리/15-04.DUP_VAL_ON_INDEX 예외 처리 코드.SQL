SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
  -- 예외 처리를 하지 않았으므로 프로그램이 오류로 중단된다.
  INSERT INTO dept(deptno, dname, loc)
  VALUES (40, 'CONSULTING', 'MANHATTAN');

  -- 예외 처리
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN -- 키 중복 처리
      DBMS_OUTPUT.PUT_LINE('키 값이 중복됩니다. 데이터는 INSERT 되지 않습니다.');
END
;
