SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE emp_rec IS TABLE OF emp%ROWTYPE;
	v_emp_arr 		emp_rec;
	c_size_limit	CONSTANT PLS_INTEGER := 10;
	v_fetched			PLS_INTEGER;
	CURSOR c IS
		SELECT *
			FROM emp;
BEGIN
	v_fetched := 0;
	OPEN c; -- 커서 열기
	LOOP
		FETCH c BULK COLLECT INTO v_emp_arr
		LIMIT c_size_limit;

		DBMS_OUTPUT.PUT_LINE(v_emp_arr.COUNT ||'건');

		IF 0 < v_emp_arr.COUNT THEN
			FOR i IN v_emp_arr.FIRST..v_emp_arr.LAST
			LOOP
				DBMS_OUTPUT.PUT_LINE(CHR(9)||'순서 = ' || TO_CHAR(v_fetched+i, '99') ||
													   '	사번 = ' ||v_emp_arr(i).empno || ', 이름 = ' ||
	 													 v_emp_arr(i).ename);
			END LOOP;
			v_fetched := c%ROWCOUNT; -- 처리된 건수
		END IF;

		EXIT WHEN c%NOTFOUND; -- 더 이상의 데이터가 없으면 종료한다. 모든 처리가 끝난 후에 호출해야 한다.
	END LOOP;
	CLOSE c;
END;

/* 처리 결과
10건
	순서 =   1	사번 = 9000, 이름 = 홍길동
	순서 =   2	사번 = 7369, 이름 = SMITH
	순서 =   3	사번 = 7499, 이름 = ALLEN
	순서 =   4	사번 = 7521, 이름 = WARD
	순서 =   5	사번 = 7566, 이름 = JONES
	순서 =   6	사번 = 7654, 이름 = MARTIN
	순서 =   7	사번 = 7698, 이름 = BLAKE
	순서 =   8	사번 = 7782, 이름 = CLARK
	순서 =   9	사번 = 7788, 이름 = SCOTT
	순서 =  10	사번 = 7839, 이름 = KING
5건
	순서 =  11	사번 = 7844, 이름 = TURNER
	순서 =  12	사번 = 7876, 이름 = ADAMS
	순서 =  13	사번 = 7900, 이름 = JAMES
	순서 =  14	사번 = 7902, 이름 = FORD
	순서 =  15	사번 = 7934, 이름 = MILLER
*/
