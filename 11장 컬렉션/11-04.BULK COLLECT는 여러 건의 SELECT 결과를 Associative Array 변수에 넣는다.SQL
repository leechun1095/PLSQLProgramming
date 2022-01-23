SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE string_array IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
	v_arr string_array;
BEGIN
	-- 테이블 emp의 모든 로우의 ename을 Associative Array 컬렉션에 한 번에 적재한다.
	SELECT ename
		BULK COLLECT INTO v_arr
		FROM emp;
	DBMS_OUTPUT.PUT_LINE('Associative Array 컬렉션 건수 = '||v_arr.COUNT) ;
  FOR i IN v_arr.FIRST..v_arr.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE('ename' || i || '= '||v_arr(i));
  END LOOP;
END;
