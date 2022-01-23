SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE string_array IS TABLE OF VARCHAR2(100);
	v_arr string_array;
BEGIN
	SELECT ename
		BULK COLLECT INTO v_arr
		FROM emp;
	DBMS_OUTPUT.PUT_LINE('VARRAY 컬렉션 건수 = '||v_arr.COUNT) ;
	FOR i IN v_arr.FIRST..v_arr.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE(CHR(9) || 'ename(' || i || ') = ' || v_arr(i)) ;
	END LOOP;
END;
