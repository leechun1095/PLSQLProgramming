SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM LIMIT 키워드를 사용하지 않는 경우
REM 한 번의 실행으로 쿼리의 모든 결과 로우를 컬렉션 변수에 저장
DECLARE
	TYPE emp_rec IS TABLE OF emp%ROWTYPE;
	v_emp_arr	emp_rec;
BEGIN
  -- 한 번의 실행으로 emp 테이블의 모든 로우를 배열에 읽어 들인다.
	SELECT *
		BULK COLLECT INTO v_emp_arr
		FROM emp;
	DBMS_OUTPUT.PUT_LINE('건수1: ' || v_emp_arr.COUNT);

	-- LIMIT 키워드 없이도 ROWNUM을 사용하여 건수 제한이 가능하다.
  -- 한 번의 실행으로 EMP 테이블의 로우 10건을 배열에 읽어 들인다.
  -- 최대 10까지가 v_emp에 담길 수 있다.
	SELECT *
		BULK COLLECT INTO v_emp_arr
		FROM emp
	 WHERE ROWNUM <= 10;
	DBMS_OUTPUT.PUT_LINE('건수2: ' || v_emp_arr.COUNT);
END;


/*
-- emp 단건 데이터 새로운 TABLE(emp_tmp)로 INSERT 하기
DECLARE
  v_emp_rec emp%ROWTYPE;
BEGIN
  SELECT *
    INTO v_emp_rec
    FROM emp
   where empno = 7499;

  INSERT INTO emp_tmp
    VALUES v_emp_rec;
END;


-- emp 다건 데이터 새로운 TABLE(emp_tmp)로 INSERT 하기
DECLARE
  TYPE emp_rec IS TABLE OF emp%ROWTYPE;
  v_emp_rec emp_rec;
BEGIN
  SELECT *
    BULK COLLECT INTO v_emp_rec
    FROM emp
   where empno > 7800;

  FOR i IN v_emp_rec.FIRST..v_emp_rec.LAST
  LOOP
    INSERT INTO emp_tmp
    VALUES v_emp_rec(i);
  END LOOP;
END;
*/
