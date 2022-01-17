﻿--===============================================================
-- 개발자를 위한 PL/SQL 프로그래밍
-- 소스 : https://github.com/Jpub/PLSQLProgramming
--===============================================================

--===============================================================
-- /* Example 1-6 저장 함수 */
--===============================================================
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION get_dept_employee_count(
		  a_deptno NUMBER -- 사원 수를 계산할 부서 번호
		) RETURN NUMBER   -- 부서의 사원수를 반환
IS
  -- 변수
  v_cnt NUMBER;  -- 건수
BEGIN
  SELECT COUNT(*)
    INTO v_cnt
	FROM emp
   WHERE deptno = a_deptno;

  RETURN v_cnt;

EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('응용프로그램 오류 발생' || CHR(10) || SQLERRM);
  RETURN -1;
END;


--===============================================================
-- /* Example 1-7 SELECT 문을 사용한 저장 함수의 실행 */
--===============================================================
SELECT deptno
	 , dname
	 , loc
	 , get_dept_employee_count(deptno) 사원수
  FROM dept;


--===============================================================
-- /* Example 1-8 익명 PL/SQL문을 사용한 저장 함수 실행 */
--===============================================================
SET SERVEROUTPUT ON;
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  v_cnt := get_dept_employee_count(10);
  DBMS_OUTPUT.PUT_LINE('사원수: '|| v_cnt);
END;


--===============================================================
-- /* Example 1-9 저장 프로시저 */
--===============================================================
CREATE OR REPLACE PROCEDURE register_employee(
		  a_empno			NUMBER,		-- 등록할 사번 매개변수
		  a_ename			VARCHAR2,	-- 등록할 이름 매개변수
		  a_job				VARCHAR2,	-- 등록할 업무 매개변수
		  a_rslt_out OUT	BOOLEAN,	-- 처리 성공 여부
		  a_msg_out	 OUT	VARCHAR2	-- 처리 결과를 반환하는 변수
)
IS
	c_default_deptno CONSTANT NUMBER := 20;	-- DEFAULT 부서 코드

	v_cnt		NUMBER;		-- 건수
BEGIN
	-- 주어진 사번의 존재 여부 확인
	SELECT COUNT(*)
	  INTO v_cnt
	  FROM emp
	 WHERE empno = a_empno;

	IF v_cnt > 0 THEN
	  UPDATE emp
		 SET ename = a_ename,
			 job   = a_job
	   WHERE ename = a_ename;

	  a_msg_out := '사원 "'  || a_ename || '"이(가) 등록되었습니다.' ;
	ELSE
	  INSERT INTO emp(empno, ename, job, deptno)
	  VALUES (a_empno, a_ename, a_job, c_default_deptno);

	  a_msg_out := '신입사원 "'  || a_ename || '"이(가) 등록되었습니다.' ;
	END IF;
	a_rslt_out := TRUE;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  a_msg_out  := '응용프로그램 오류 발생' || CHR(10) || SQLERRM;
  a_rslt_out := FALSE;
END;


--===============================================================
-- /* Example 1-10 저장 프로시저의 실행 */
--===============================================================
SET SERVEROUTPUT ON;
DECLARE
  a_rslt_out BOOLEAN;
  a_msg_out  VARCHAR2(1000);
BEGIN
  register_employee(7788, 'SCOTT', 'ANALYST', a_rslt_out, a_msg_out);
  DBMS_OUTPUT.PUT_LINE(a_msg_out);
  IF a_rslt_out = TRUE THEN
    DBMS_OUTPUT.PUT_LINE('등록 성공!');
	COMMIT;
  ELSE
    DBMS_OUTPUT.PUT_LINE('등록 실패!');
	ROLLBACK;
  END IF;
END;


--===============================================================
-- /* Example 2-1 익명 PL/SQL 예제 1-4를 MERGE문으로 재작성 */
--===============================================================
MERGE INTO emp a
USING (SELECT 7788		AS empno,
			  'SCOTT' 	AS ename,
			  'ANALYST' AS job,
			  20    	AS default_deptno
         FROM dual) b
ON(a.empno = b.empno)
WHEN MATCHED THEN
  UPDATE SET a.ename = b.ename,
			 a.job	 = b.job
WHEN NOT MATCHED THEN
  INSERT (a.empno, a.ename, a.job, a.deptno)
  VALUES (b.empno, b.ename, b.job, b.default_deptno);


--===============================================================
-- /* Example 4-1 기본적인 구성요소를 모두 갖춘 예제 */
--===============================================================

DECLARE
  V_STR VARCHAR2(100);
BEGIB
  V_STR := 'Hellowm world!';
  DBMS_OUTPUT.PUT_LINE(V_STR);
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
 END

--===============================================================
-- /* Example 5-4 식별자명 출동 시의 유효 범위 */
--===============================================================

SET SERVEROUTPUT ON;
DECLARE
  V_NUM NUMBER := 0;
BEGIN
  DECLARE
    V_NUM NUMBER;
  BEGIN
    V_NUM := 4; -- 5번 줄에 선언된 V_NUM을 참조
  END;
  V_NUM := V_NUM + 1; -- 2번 줄에 선언된 V_NUM을 참조
  DBMS_OUTPUT.PUT_LINE('V_NUM = '|| V_NUM);  -- 결과 : V_NUM = 1
END;


--===============================================================
-- /* Example 5-5 레이블을 사용한 식별자 참조 */
--===============================================================

SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레이블을 사용하여 바깥 블럭의 변수를 참조
<<OUTER_BLOCK>>  -- 레이블(Label)
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  DECLARE
    v_num NUMBER ;
  BEGIN
    v_num := 1 ;             -- 6번 줄에 선언된 변수 v_num을 변경시킨다.
    OUTER_BLOCK.v_num := 2 ; -- 3번 줄에 선언된 변수 v_num을 변경시킨다.
  END ;
  DBMS_OUTPUT.PUT_LINE('v_num = '||v_num) ; -- 3번 줄에 선언된 변수 v_num의 값을 출력한다.
END ;


--===============================================================
-- /* Example 5-6 서브프로그램에서의 식별자 유효범위.SQL */
--===============================================================

SET ECHO ON;
SET TAB OFF;
SET SERVEROUTPUT ON;

-- 서브프로그램 내부에 선언된 식별자의 유효범위는
-- 레이블이 없어도 "서브프로그램명.식별자"로 참조 가능하다.
CREATE OR REPLACE PROCEDURE check_salary(a_empno NUMBER)
IS
  v_name VARCHAR2(10) ;
  v_num  NUMBER ;

  FUNCTION check_bonus(a_empno NUMBER) RETURN BOOLEAN
  IS
    v_num NUMBER ;
  BEGIN
    SELECT comm
      INTO v_num
      FROM emp
     WHERE empno = a_empno ;

    DBMS_OUTPUT.PUT_LINE(v_name||'의 커미션: '||v_num) ;

    -- 커미션은 급여 금액을 초과하지 못한다.
    IF check_salary.v_num < v_num THEN
      RETURN FALSE ;
    ELSE
      RETURN TRUE ;
    END IF ;
  END ;

BEGIN
  SELECT ename, sal
    INTO v_name, v_num
    FROM emp
   WHERE empno = a_empno ;

  IF NOT check_bonus(a_empno) THEN
    DBMS_OUTPUT.PUT_LINE('사원 '||v_name||'의 커미션이 과도합니다') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('사원 '||v_name||'의 급여 데이터가 정상입니다') ;
  END IF ;
END ;

-- 프로시저 실행
BEGIN
  CHECK_SALARY(7499);
END;


--===============================================================
-- /* Example 6-2 데이터베이스 문자 집합과 문자열 크기 */
--===============================================================

SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 문자형 데이터 타입 선언 시 "(길이 CHAR)" 형식 사용
REM 바이트 단위가 아닌 글자 수 단위의 길이로 선언되므로
REM 데이터베이스 문자집합에 따라서 최대 길이가 달라진다.
DECLARE
  v_charset  VARCHAR2(16    ) ;
  v_name1    VARCHAR2(8 CHAR) ;
  v_name2    VARCHAR2(8     ) ;
BEGIN
  -- Fixed View에서 데이터베이스 문자 집합을 조회하여 출력한다.
  SELECT VALUE INTO v_charset FROM v$nls_parameters WHERE parameter = 'NLS_CHARACTERSET' ;
  DBMS_OUTPUT.PUT_LINE('데이터베이스 문자 집합 : ' || v_charset) ;

  -- DBMS_OUTPUT.PUT_LINE('') ; -- 탭 문자(빈 줄 출력용)
  DBMS_OUTPUT.PUT_LINE(CHR(9)) ; -- 탭 문자(빈 줄 출력용)

  -- 문자 단위
  DBMS_OUTPUT.PUT_LINE('v_name1 VARCHAR2(8 CHAR)') ;
  DBMS_OUTPUT.PUT_LINE('========================') ;
  v_name1 := 'Miller' ;   -- 알파벳 문자열
  DBMS_OUTPUT.PUT_LINE(RPAD(v_name1,9) ||' : ' || lengthb(v_name1) || '바이트') ;
  v_name1 := '을지문덕하이하이' ; -- 한글 문자열
  DBMS_OUTPUT.PUT_LINE(RPAD(v_name1,9) ||' : ' || lengthb(v_name1) || '바이트') ;

  DBMS_OUTPUT.PUT_LINE(CHR(9)) ; -- 탭 문자(빈 줄 출력용)

  -- 바이트 단위
  DBMS_OUTPUT.PUT_LINE('v_name2 VARCHAR2(8)') ;
  DBMS_OUTPUT.PUT_LINE('====================') ;
  v_name2 := 'Miller' ;   -- 알파벳 문자열
  DBMS_OUTPUT.PUT_LINE(RPAD(v_name2,9) ||' : ' || lengthb(v_name2) || '바이트') ;
  v_name2 := '을지문덕' ; -- 한글 문자열
  DBMS_OUTPUT.PUT_LINE(RPAD(v_name2,9) ||' : ' || lengthb(v_name2) || '바이트') ;
END;

--===============================================================
-- /* Example 7-1 변수명은 대소문자를 구별하지 않는다. */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 식별자는 대소문자를 구별하지 않으므로
REM 소문자 변수명 v_num과 대문자 변수명 V_NUM은 동일한 변수임.
REM 변수 중복 선언으로 인한 컴파일 오류 발생.
DECLARE
  v_num NUMBER ;
  V_NUM NUMBER ; -- 대소문자를 구별하지 않으므로, 위의 v_num과 중복되는 선언이다.
BEGIN
  v_num := 10 ;
  V_NUM := 20 ;
  DBMS_OUTPUT.PUT_LINE(v_num) ;
END ;

--===============================================================
-- /* Example 7-2 변수명에 큰따옴표를 사용하면 대소문자가 구별된다. */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON
REM 식별자를 큰따옴표로 감싸면 대소문자를 구별한다.
DECLARE
  "v_num" NUMBER ;
  "V_NUM" NUMBER ; -- 대소문자를 구별하므로, 위의 "v_num"과는 다른 선언이다.
BEGIN
  "v_num" := 10 ;
  "V_NUM" := 20 ;
  DBMS_OUTPUT.PUT_LINE("v_num") ;
END ;

--===============================================================
-- /* Example 7-3 변수 선언 시 초기값 지정 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 변수 선언 시에 제약조건과 초기 값을 지정할 수 있다.
DECLARE
  v_name VARCHAR2(10) NOT NULL := 'SMITH' ;
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_name) ;
END ;

--===============================================================
-- /* Example 7-4 NOT NULL 변수에 초기값을 지정하지 않으면 오류 발생 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM NOT NULL 제약조건을 가지는 변수에 초기값 미지정 시 오류 발생
DECLARE
  v_name VARCHAR2(10) NOT NULL ;
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_name) ;
END ;

--===============================================================
-- /* Example 7-5 변수의 최대 크기를 초과하는 값을 할당 시 오류  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 문자열 변수에 선언된 크기를 초과하는 문자열을 할당하면 오류 발생
DECLARE
  v_vc VARCHAR2(2) ; -- 최대 2바이트
BEGIN
  v_vc := 'ABC' ; -- 최대 크기가 2바이트인 변수에 크기가 3바이트인 문자열을 할당
END ;

--===============================================================
-- /* Example 7-6 상수는 값을 변경할 수 없다  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 상수는 변경할 수 없는 값이다.
REM 상수를 변경하면 오류가 발생한다.
DECLARE
  c_pi CONSTANT NUMBER := 3.14 ; -- 상수 선언
BEGIN
  c_pi := 3.1415927 ;            -- 상수를 변경하면 오류 발생
END ;

--===============================================================
-- /* Example 7-7 리터럴의 사용 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 리터럴을 사용하는 프로그램 예제.
REM 리터럴 없는 프로그래밍은 거의 불가능하다.
DECLARE
  v_sum NUMBER := 0 ;
BEGIN
  FOR i IN 1..10
  LOOP
    v_sum := v_sum + i ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('Σ(1~10) = '||v_sum) ;
END ;

--===============================================================
-- /* Example 7-8 서로 다른 타입의 NULL은 호환되지 않는다.  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM NULL 리터럴도 데이터 타입을 가진다.
REM 데이터 타입이 다른 NULL 간의 연산은 컴파일 오류를 발생시킨다.
DECLARE
  v_num  NUMBER  := NULL ; -- 수치형 리터럴 NULL
  v_bool BOOLEAN := NULL ; -- BOOLEAN형 리터럴 NULL
BEGIN
  -- NUMBER형 리터럴 NULL과 BOOLEAN형 리터럴 NULL은 서로 호환되지 않는다.
  -- 따라서 다음 IF 문은 컴파일 오류를 일으킨다.
  IF v_num = v_bool THEN
    DBMS_OUTPUT.PUT_LINE('NULL NUMBER = NULL BOOLEAN') ;
  END IF ;
END ;

--===============================================================
-- /* Example 7-9 큰 따옴표와 작은 따옴표의 차이.SQL  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 문자형 리터럴은 작은 따옴표를 사용한다.
REM 큰 따옴표를 사용하면 문자형 리터럴이 아니라 식별자이다.
DECLARE
  c_name CONSTANT STRING(10) := 'Mr. Smith' ;
  "Mr. Scott" STRING(10) ;
BEGIN
  "Mr. Scott" := c_name ;
  DBMS_OUTPUT.PUT_LINE('이름='||"Mr. Scott") ;
END ;

--===============================================================
-- /* Example 7-10 줄 바꿈을 포함하는 문자형 리터럴.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 작은 따옴표를 사용한 문자형 리터럴 선언 예제.
REM 리터럴은 줄바꿈을 포함할 수도 있다.
DECLARE
  v_str VARCHAR2(1000) ;
BEGIN
  -- 줄바꿈을 포함하는 문자형 리터럴
  v_str := '옛날에 옛날에 어느 깊은 산 속에
            할아버지와 할머니가 살고 있었어요' ;
  DBMS_OUTPUT.PUT_LINE(v_str) ;
END ;

--===============================================================
-- /* Example 7-11 프리픽스 Q를 사용하지 않는 문자형 리터럴.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 프리픽스 Q를 사용하지 않을 경우 문자열 중간의 작은따옴표는
REM 모두 겹따옴표로 변경해야 하므로 어려움이 있다.
DECLARE
  v_SQL VARCHAR2(1000) ;
BEGIN
  v_SQL := 'SELECT EMPNO, ENAME
              FROM EMP
             WHERE ENAME IN (''SMITH'', ''ALLEN'', ''WARD'', ''JONES'', ''MARTIN'')' ;
  DBMS_OUTPUT.PUT_LINE(v_SQL) ;
END ;

--===============================================================
-- /* Example 7-12 프리픽스 Q를 사용한 문자형 리터럴.SQL */
--===============================================================
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

--===============================================================
-- /* Example 7-13 프리픽스 Q를 사용한 문자형 리터럴의 구분자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 프리픽스 Q를 사용한 다음 문자열 리터럴의 예는
REM 모두 올바른 사용이며 모두 동일한 값이다.
/*
BEGIN
  DBMS_OUTPUT.PUT_LINE(Q'[Scott's cat]');
  DBMS_OUTPUT.PUT_LINE(Q'{Scott's cat}');
  DBMS_OUTPUT.PUT_LINE(Q'<Scott's cat>');
  DBMS_OUTPUT.PUT_LINE(Q'(Scott's cat)');
  DBMS_OUTPUT.PUT_LINE(Q'!Scott's cat!');
  DBMS_OUTPUT.PUT_LINE(Q'#Scott's cat#');
  DBMS_OUTPUT.PUT_LINE(Q'aScott's cata');
  DBMS_OUTPUT.PUT_LINE(Q'SScott's catS');
  DBMS_OUTPUT.PUT_LINE(Q'가Scott's cat가');
END ;
*/

--===============================================================
-- /* Example 7-14 수치형 리터럴.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 수치형 리터럴 예제
REM 부동 소수점형은 NUMBER 형에 비해 속도는 빠르나
REM 유효 숫자의 수가 작아 정확도가 낮다.
BEGIN
  DBMS_OUTPUT.PUT_LINE('*:'||3.1415926535897932384626433832795028842) ;
  DBMS_OUTPUT.PUT_LINE('F:'||3.1415926535897932384626433832795028842F) ;
  DBMS_OUTPUT.PUT_LINE('D:'||3.1415926535897932384626433832795028842D) ;
END ;

--===============================================================
-- /* Example 7-15 부동 소수점형 리터럴의 계산 결과는 정확하지 않을 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 부동 소수점형 리터럴은 값이 정확하지 않을 수 있다.
REM 동일한 상수 9.95이지만 부동소숫점형을 사용하면
REM 정확한 값을 가지지 못한다.
REM 따라서 부동소수점형은 금융 계산에 사용할 수 없으며,
REM 금융 계산에는 NUMBER 형을 사용해야 한다.
DECLARE
  v_num NUMBER ;
BEGIN
  DBMS_OUTPUT.PUT_LINE('NUMBER                : '||9.95) ;
  DBMS_OUTPUT.PUT_LINE('부동 소수점           : '||9.95F) ;
  DBMS_OUTPUT.PUT_LINE('TO_CHAR(9.95 ,''99.0'') :'||TO_CHAR(9.95 ,'99.0')) ;
  DBMS_OUTPUT.PUT_LINE('TO_CHAR(9.95F,''99.0'') :'||TO_CHAR(9.95F,'99.0')) ;
  DBMS_OUTPUT.PUT_LINE('ROUND(9.95 ,1)        : '||ROUND(9.95 ,1)) ; --ROUND(숫자, 1) -> 소수점 2번째 자리에서 반올림(=소수점 첫번째 자리까지 표현하겠다는 의미)
  DBMS_OUTPUT.PUT_LINE('ROUND(9.95F,1)        : '||ROUND(9.95F,1)) ;

  v_num := 9.95F ; -- 부동 소수점형 리터럴을 NUMBER형 변수에 바로 할당해도 값이 정확하지 않다.
  DBMS_OUTPUT.PUT_LINE('부동 소수점 변수      : '||v_num) ;
END ;

--===============================================================
-- /* Example 7-16 날짜형 리터럴.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 다양한 날짜형 리터럴 예제
DECLARE
  v_dt          DATE ;
  v_ts          TIMESTAMP ;
  v_tstz        TIMESTAMP WITH TIME ZONE ;
  v_intervalY2M INTERVAL YEAR    TO MONTH ; -- 기본은 YEAR(2)
  v_intervalY3M INTERVAL YEAR(3) TO MONTH ;
  v_intervalDS  INTERVAL DAY TO SECOND(9) ;
BEGIN
  -- 날짜형 리터럴
  v_dt := TO_DATE('2013-01-01', 'YYYY-MM-DD') ;
	DBMS_OUTPUT.PUT_LINE(v_dt);
  v_dt := DATE'2013-01-01' ;

  -- 일시형 리터럴
  v_dt := TO_DATE('2013-01-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS') ;
  v_dt := TIMESTAMP'2013-01-01 12:00:00' ;

  -- TIMESTAMP형 리터럴
  v_ts := TO_TIMESTAMP('2013-01-01 12:00:00.123', 'YYYY-MM-DD HH24:MI:SS.FF') ;
  v_ts := TIMESTAMP'2013-01-01 12:00:00.123' ;
  v_ts := TO_TIMESTAMP_TZ('2013-01-01 12:00:00 +02:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM') ;

  -- TIMESTAMP WITH TIME ZONE형 리터럴
  v_ts := TIMESTAMP'2013-01-01 12:00:00 +02:00' ;

  -- INTERVAL YEAR TO MONTH형 리터럴
  v_intervalY3M := INTERVAL '123-4' YEAR TO MONTH ; -- 123년 4개월
  v_intervalY3M := INTERVAL '123' YEAR ;            -- 123년
  v_intervalY3M := INTERVAL '50' MONTH ;            -- 50개월(4년 2개월)
  -- v_intervalY2M := INTERVAL '123' YEAR ; -- ORA-01873: 간격의 선행 정밀도가 너무 작습니다

  -- INTERVAL DAY TO SECOND형 리터럴
  v_intervalDS := INTERVAL '4 5:12:10.222' DAY TO SECOND ;
END ;

--===============================================================
-- /* Example 8-1 BOOLEAN 값을 출력하는 함수 print_boolean.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE print_boolean(v_msg VARCHAR2, v_bool BOOLEAN) IS
BEGIN
  IF v_bool IS NULL THEN
    dbms_output.put_line(v_msg || ' : NULL') ;
  ELSIF v_bool = TRUE THEN
    dbms_output.put_line(v_msg || ' : TRUE') ;
  ELSE
    dbms_output.put_line(v_msg || ' : FALSE') ;
  END IF ;
END;

--===============================================================
-- /* Example 8-2 print_boolean을 사용하여 BOOLEAN식의 결과 출력.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 표 8 4의 회색 부분의 결과 확인
DECLARE
	v_TRUE	BOOLEAN := TRUE;
	v_FALSE BOOLEAN := FALSE;
	v_NULL	BOOLEAN := NULL;
BEGIN
	print_boolean('TRUE	 AND NULL', v_TRUE AND v_NULL);
	print_boolean('TRUE	 OR	 NULL', v_TRUE AND v_NULL);
	print_boolean('FALSE AND NULL', v_TRUE AND v_NULL);
	print_boolean('FALSE OR  NULL ', v_FALSE OR  v_NULL);
	print_boolean('NULL  AND TRUE ', v_NULL  AND v_TRUE);
	print_boolean('NULL  OR  TRUE ', v_NULL  OR  v_TRUE);
	print_boolean('NULL  AND FALSE', v_NULL  AND v_FALSE);
	print_boolean('NULL  OR  FALSE', v_NULL  OR  v_FALSE);
END;

--===============================================================
-- /* Example 8-3 Short-Circuit Evaluation과 부작용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM Short-Circuit Evaluation의 부작용으로
REM 올바르지 못한 연산을 사전에 발견하지 못할 수 있다.
DECLARE
  x NUMBER := 1 ;
  y NUMBER := 2 ;
  z NUMBER := 0 ;
BEGIN
  -- "TRUE or ?"이므로 "y / z = 0"이 평가되지 않아서 오류가 발생하지 않음
  IF x = 1 OR y / z = 0 THEN
    DBMS_OUTPUT.PUT_LINE('x = 0 OR y / z = 0') ;
  END IF ;

  -- 이번에는 "FALSE or ?"이므로 "y / z = 0"이 평가되어 "ORA-01476: 제수가 0 입니다"가 발생
  x := 2 ;
  IF x = 1 OR y / z = 0 THEN  --> 여기에서 ORA-01476 오류 발생
    DBMS_OUTPUT.PUT_LINE('x = 0 OR y / z = 0') ;
  END IF ;
END ;

--===============================================================
-- /* Example 8-4 연결연산자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello, ' || 'World!') ;
  DBMS_OUTPUT.PUT_LINE('Hello, ' || NULL || 'World!') ; --> NULL에 대한 연결 연산은 무시됨
  DBMS_OUTPUT.PUT_LINE(24 || ' 시간') ;       --> 숫자 24를 문자로 묵시적 변환 후 연결
  DBMS_OUTPUT.PUT_LINE(CONCAT(24, ' 시간')) ; --> 숫자 24를 문자로 묵시적 변환 후 연결
END ;

--===============================================================
-- /* Example 8-5 NULL 여부 확인 연산자 IS NULL.SQL  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM NULL 여부 확인에는 IS NULL 연산을 사용해야 한다.
DECLARE
  x VARCHAR2(10) ;
  y NUMBER ;
BEGIN
  x := NULL ; print_boolean('NULL IS NULL    '  , x IS NULL) ;
  x := NULL ; print_boolean('NULL IS NOT NULL'  , x IS NOT NULL) ;
  x := '' ;   print_boolean(''''' IS NULL      ', x IS NULL) ;
  x := ' ' ;  print_boolean(''' '' IS NULL     ', x IS NULL) ;
  x := NULL ; print_boolean('NULL = NULL     '  , x = NULL) ;
  x := NULL ; print_boolean('NULL <> NULL    '  , x <> NULL) ;
  y := 0 ;    print_boolean('0 IS NULL       '  , y IS NULL) ;
END ;

--===============================================================
-- /* Example 8-6 IS NULL 대신에 = NULL 을 잘못 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM "IS NULL" 대신에 "= NULL" 을 사용하면 의도한 결과를 얻을 수 없다.
DECLARE
  x varchar2(10) ;
BEGIN
  x := NULL ;
  IF x = NULL THEN  -- 실수로 x IS NULL 대신에 x = NULL을 사용함
    DBMS_OUTPUT.PUT_LINE('위치 1. 테스트 : x = NULL ') ;
  END IF ;
  IF x <> NULL THEN -- 실수로 x IS NOT NULL 대신에 x <> NULL을 사용함
    DBMS_OUTPUT.PUT_LINE('위치 2, 테스트 : x <> NULL ') ;
  END IF ;
  print_boolean('위치 3. x =  NULL', x = NULL) ;
  print_boolean('위치 4. x <> NULL', x <> NULL) ;
  print_boolean('위치 5. x IS NULL', x IS NULL) ;
END ;

--===============================================================
-- /* Example 8-7 LIKE 연산자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  x varchar2(10) ;
BEGIN
  x := 'SMITH' ; print_boolean(Q'['SMITH' LIKE 'S%'    ]', x LIKE 'S%') ;
  x := 'SMITH' ; print_boolean(Q'['SMITH' LIKE 'S____' ]', x LIKE 'S____') ;
  x := 'SMITH' ; print_boolean(Q'['SMITH' LIKE 'SMITH' ]', x LIKE 'SMITH') ;
  x := 'SMITH' ; print_boolean(Q'['SMITH' LIKE 's%'    ]', x LIKE 's%') ;
  x := 'SMITH' ; print_boolean(Q'['SMITH' NOT LIKE 's%']', x NOT LIKE 's%') ;
  x := NULL    ; print_boolean(Q'[NULL LIKE 'A'        ]', x LIKE 'A') ;
  x := NULL    ; print_boolean(Q'[NULL NOT LIKE 'A'    ]', x NOT LIKE 'A') ;
  x := '한글'  ; print_boolean(Q'['한글' LIKE '__'     ]', '한글' LIKE '__') ;
END ;

--===============================================================
-- /* Example 8-8 BETWEEN 연산자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  x NUMBER := 10 ;
BEGIN
  print_boolean('x(10)     BETWEEN    5 AND 15  ', x     BETWEEN    5 AND 15) ;
  print_boolean('x(10) NOT BETWEEN    5 AND 15  ', x NOT BETWEEN    5 AND 15) ;
  print_boolean('x(10)     BETWEEN   15 AND  5  ', x     BETWEEN   15 AND  5) ;
  print_boolean('x(10)     BETWEEN NULL AND 10  ', x     BETWEEN NULL AND 10) ;
  print_boolean('x(10) NOT BETWEEN NULL AND 10  ', x NOT BETWEEN NULL AND 10) ;
  print_boolean('x(10)     BETWEEN    5 AND NULL', x     BETWEEN    5 AND NULL) ;
  print_boolean('x(10) NOT BETWEEN    5 AND NULL', x NOT BETWEEN    5 AND NULL) ;
  print_boolean('NULL      BETWEEN    5 AND 10  ', NULL  BETWEEN    5 AND 10) ;
END ;

--===============================================================
-- /* Example 8-9 IN 연산자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  x NUMBER := 10 ;
BEGIN
  print_boolean('x        IN (6, 8, 10)      ', x        IN (6, 8, 10)) ;
  print_boolean('x    NOT IN (6, 8, 10)      ', x    NOT IN (6, 8, 10)) ;
  print_boolean('x        IN (6, 8, 10, NULL)', x        IN (6, 8, 10, NULL)) ;
  print_boolean('NULL     IN (6, 8, 10, NULL)', NULL     IN (6, 8, 10, NULL)) ;
  print_boolean('NULL NOT IN (6, 8, 10, NULL)', NULL NOT IN (6, 8, 10, NULL)) ;
END ;

--===============================================================
-- /* Example 8-10 BOOLEAN 표현식.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_bool BOOLEAN ;
BEGIN
  v_bool := FALSE ;

  -- IF문의 분기 조건 판단에 사용
  IF v_bool = TRUE THEN
    DBMS_OUTPUT.PUT_LINE('v_bool이 참입니다.') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_bool이 거짓입니다.') ;
  END IF ;

  v_bool := FALSE ;
  -- WHILE문의 순환 조건 판단에 사용
  WHILE v_bool = FALSE
  LOOP
    v_bool := TRUE ;
  END LOOP ;

  v_bool := FALSE;
  -- BOOLEAN 표현식에 NOT 사용
  WHILE NOT v_bool = FALSE
  LOOP
    v_bool := TRUE ;
  END LOOP ;
END ;

--===============================================================
-- /* Example 8-11 단순 CASE 표현식.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM Simple CASE expression
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- ´Ü¼ø CASE Ç¥Çö½Ä(Simple CASE expression)
  v_STR := CASE v_BOOL WHEN TRUE  THEN 'v_BOOL is TRUE'
                       WHEN FALSE THEN 'v_BOOL is FALSE'
                       ELSE            'v_BOOL is NULL'
           END ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 8-12 조사 CASE 표현식.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 조사 CASE 표현식으로 변경
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- 조사 CASE 표현식(Searched CASE expression)
  v_STR := CASE WHEN v_BOOL = TRUE  THEN 'v_BOOL is TRUE'
                WHEN v_BOOL = FALSE THEN 'v_BOOL is FALSE'
                ELSE                     'v_BOOL is NULL'
           END ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 8-13 두 개 이상의 조건이 만족되는 경우에는 순서가 먼저인 절이 적용된다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 2개 이상의 조건이 만족되는 경우에는
REM 순서적으로 먼저 나타나는 WHEN이 적용된다.
DECLARE
  v_BOOL  BOOLEAN := TRUE ;
  v_TRUE  BOOLEAN := TRUE ;
  v_FALSE BOOLEAN := FALSE ;
  v_STR  STRING(100) ;
BEGIN
  v_STR := CASE v_BOOL WHEN TRUE    THEN 'v_BOOL = TRUE'    -- TRUE
                       WHEN v_TRUE  THEN 'v_BOOL = v_TRUE'  -- TRUE
                       WHEN FALSE   THEN 'v_BOOL = FALSE'   -- FALSE
                       WHEN v_FALSE THEN 'v_BOOL = v_FALSE' -- FALSE
                       ELSE              'v_BOOL IS NULL'
           END ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 8-14 내장 SQL 함수 DECODE는 PLSQL에서 지원되지 않는다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 내장 SQL 함수 DECODE는 PL/SQL에서 지원되지 않음
DECLARE
  v_NUM NUMBER := 1 ;
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_NUM || '은 ' || DECODE(MOD(v_NUM,2), 0, '짝수', '홀수') || '입니다.') ;
END ;

--===============================================================
-- /* Example 8-15 CASE 표현식으로 바꾸어 오류 해결.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 다음과 같이 CASE 문으로 바꾸어 사용해야 함
DECLARE
  v_NUM NUMBER := 1 ;
BEGIN
  DBMS_OUTPUT.PUT_LINE(v_NUM || '은 ' || CASE MOD(v_NUM,2) WHEN 0 THEN '짝수'
                                              ELSE '홀수' END || '입니다.') ;
END ;

--===============================================================
-- /* Example 8-16 DECODE 함수를 사용하려면 SQL문을 사용해야 한다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM DECODE를 사용하려면 다음과 같이 SQL문을 사용해야 함.
DECLARE
  v_NUM NUMBER := 1 ;
  v_TYPE STRING(10) ;
BEGIN
  SELECT DECODE(MOD(v_NUM,2), 0, '짝수', '홀수')
    INTO v_TYPE
  FROM DUAL ;
  DBMS_OUTPUT.PUT_LINE(v_NUM || '은 ' || v_TYPE || '입니다.') ;
END ;

--===============================================================
-- /* Example 9-1 SELECT문 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_cnt NUMBER;
BEGIN
	SELECT count(*)
	  INTO v_cnt
	  FROM emp;
	DBMS_OUTPUT.PUT_LINE('COUNT(*) =' || v_cnt);
END;

--===============================================================
-- /* Example 9-2 여러 개의 칼럼을 가지는 SELECT 문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno  %TYPE;
	v_ename		emp.ENAME	 %TYPE;
	v_deptno	emp.deptno %TYPE;
	v_job			emp.job 	 %TYPE;
BEGIN
	SELECT empno
		   , ename
			 , deptno
			 , job
	  INTO v_empno
		   , v_ename
			 , v_deptno
			 , v_job
	  FROM emp
	 WHERE empno = 7788;
	DBMS_OUTPUT.PUT_LINE('v_empno = ' || v_empno);
	DBMS_OUTPUT.PUT_LINE('v_ename  = ' || v_ename);
	DBMS_OUTPUT.PUT_LINE('v_deptno = ' || v_deptno);
	DBMS_OUTPUT.PUT_LINE('v_job = ' || v_job);
END;

--===============================================================
-- /* Example 9-3.SELECT 문에서 PLSQL 입력 변수의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM SELECT 문에서 PL/SQL 입력 변수의 사용
DECLARE
  v_empno  emp.empno%TYPE ;
  v_ename  emp.ename%TYPE ;
  v_rate   number := 1.1 ;
  v_sal    number ;
BEGIN
  v_empno := 7788 ;
  SELECT ename
       , (sal+comm)*v_rate  -- SELECT 칼럼에 입력 변수 v_rate를 사용
    INTO v_ename, v_sal     -- 출력 변수
    FROM emp
   WHERE empno = v_empno ;  -- 리터럴을 입력 변수 v_empno로 대체
END ;

--===============================================================
-- /* Example 9-4 SELECT 문에서 ROWTYPE의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_emprec		emp%ROWTYPE;	-- 레코드 변수 선언
BEGIN
	v_emprec.empno := 7788;
	SELECT *
    INTO v_emprec	-- 레코드 변수 사용
    FROM emp
   WHERE empno = v_emprec.empno;
  DBMS_OUTPUT.PUT_LINE('이름 = ' || v_emprec.ename);
	DBMS_OUTPUT.PUT_LINE('부서번호 = ' || v_emprec.deptno);
  DBMS_OUTPUT.PUT_LINE('job = ' || v_emprec.job);
END;

--===============================================================
-- /* Example 9-5 SELECT 절에 변수를 사용하면 결과를 변수에 저장하는 게 아니라 변수의 값을 반환한다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_name		emp.ename%TYPE;
	v_ename 	emp.ename%TYPE;
BEGIN
	v_name := 'TIGER';
	SELECT v_name
	  INTO v_ename
    FROM emp
   WHERE empno = 7788;
  DBMS_OUTPUT.PUT_LINE('이름 = ' || v_ename);
END;

--===============================================================
-- /* Example 9-6 INSERT문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	INSERT INTO emp
	(
		  empno
		, ename
		, hiredate
		, deptno
	)
	VALUES
	(
			9000
		, '홍길동'
		, sysdate
		, 30
	);
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: ' || SQL%ROWCOUNT);	-- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-7 INSERT 문에서 PLSQL 입력 변수의 사용.SQL */
--===============================================================
REM 앞에서 삽입한 로우 삭제
DELETE FROM emp
	    WHERE empno = 9000;

DECLARE
	v_empno		emp.empno%TYPE;
	v_ename		emp.ename%TYPE;
	v_deptno	emp.deptno%TYPE;
BEGIN
	v_empno  := 9000;
	v_ename  := '홍길동';
	v_deptno := 30;

	INSERT INTO emp
  (
			empno
		, ename
		, hiredate
		, deptno
	)
  VALUES
 	(
			v_empno		-- PL/SQL 변수 사용
		, v_ename		-- PL/SQL 변수 사용
		, sysdate
		, v_deptno		-- PL/SQL 변수 사용
	);
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: ' || SQL%ROWCOUNT);	-- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-8 INSERT 문에서 ROWTYPE의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 앞에서 삽입한 로우를 삭제
DELETE FROM emp WHERE empno = 9000 ;

DECLARE
	v_emprec	emp%ROWTYPE;		-- 레코드 변수
BEGIN
	v_emprec.empno		:= 9000;
	v_emprec.ename		:= '홍길동';
	v_emprec.deptno 	:= 30;
	v_emprec.hiredate	:= SYSDATE;

	INSERT INTO emp
			 VALUES	v_emprec;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: ' || SQL%ROWCOUNT);	-- 변경된 건수 출력
END;

--===============================================================
-- /* Example 9-9 INSERT 문에서 테이블 명과 INTO 절의 칼럼 목록에는 변수를 사용할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM INSERT 문에서 테이블 명과 INTO 절의 칼럼 목록에는 변수를 사용할 수 없다.
REM 다음 프로그램은 오류를 발생시킨다.
DECLARE
  v_colname VARCHAR2(30) := 'ename';
BEGIN
  INSERT INTO emp
	(
			empno /* 변수 */
		, v_colname
		, hiredate
		, deptno
	)
  VALUES
	(
			9000
		, '홍길동'
		, SYSDATE
		, 30
	);
  DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
  COMMIT;
END;

--===============================================================
-- /* Example 9-10 UPDATE */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	UPDATE emp
		 SET deptno = 40
	 WHERE empno = 9000;
  DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
END;

--===============================================================
-- /* Example 9-11 UPDATE 문에서 PLSQL 입력 변수의 사용.SQL*/
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno%TYPE := 9000;
	v_deptno	emp.deptno%TYPE := 40;
BEGIN
	UPDATE emp
		 SET deptno = v_deptno
	 WHERE empno = v_empno;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
END;

--===============================================================
-- /* Example 9-12 UPDATE 문에서 ROWTYPE의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_emprec	emp%ROWTYPE;
BEGIN
	v_emprec.empno := 9000;

	SELECT *
		INTO v_emprec
		FROM emp
	 WHERE empno = v_emprec.empno;

	v_emprec.ename	:= '홍길동';
	v_emprec.deptno := 40;

	UPDATE emp
		 SET ROW = v_emprec		-- 레코드 변수를 사용한 UPDATE, SET ROW 다음에만 레코드 변수 사용 가능
	 WHERE empno = v_emprec.empno;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-13 MERGE문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	MERGE INTO emp a
	USING DUAL
		 ON (a.empno = 9000)
	 WHEN MATCHED THEN			-- 사번이 9000인 로우 존재 시
		 UPDATE
				SET a.comm = a.comm * 1.1
	 WHEN NOT MATCHED THEN	-- 사번이 9000인 로우 미존재 시
		 INSERT
		 (
				empno
			, ename
			, job
			, hiredate
			, sal
			, deptno
		 )
		 VALUES
		 (
				9000
			, '홍길동'
			, 'CLERK'
			, SYSDATE
			, 3000
			, 10
		 );
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-14 MERGE문에서 PLSQL 입력 변수의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno		emp.empno%TYPE := 9000;
BEGIN
	MERGE INTO emp a
	USING DUAL
		 ON (a.empno = v_empno)
	 WHEN MATCHED THEN		-- 사번이 9000인 로우 존재 시 커미션을 10% 증가
		 UPDATE
				SET a.comm = a.comm * 1.1
	 WHEN NOT MATCHED THEN
		 INSERT
		 (
				empno
			, ename
			, job
			, hiredate
			, sal
			, deptno
		 )
		 VALUES
		 (
				v_empno
			, '홍길동'
			, 'CLERK'
			, SYSDATE
			, 3000
			, 10
		 );
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-15 MERGE 문의 INSERT 절에서 레코드 변수 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_emprec	emp%ROWTYPE;
BEGIN
	SELECT *
		INTO v_emprec
		FROM emp
	 WHERE empno = 7788;

	v_emprec.empno := 9000;
	v_emprec.ename := '홍길동';

	MERGE INTO emp a
	USING DUAL
		 ON (a.empno = v_emprec.empno)
	 WHEN MATCHED THEN
		 UPDATE							-- MERGE 문의 UPDATE절에서는 레코드 변수를 사용할 수 없다.
				SET a.comm = a.comm * 1.1
	 WHEN NOT MATCHED THEN
		 INSERT
		 VALUES v_emprec;		-- MERGE 문의 INSERT절에서는 레코드 변수를 사용할 수 있다.
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-16 .DELETE문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	DELETE FROM emp
	 WHERE empno = 9000;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
 	COMMIT;
END;

--===============================================================
-- /* Example 9-17 DELETE문에서 PLSQL 입력 변수의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno	emp.empno%TYPE := 9000;
BEGIN
	DELETE FROM emp
	 WHERE empno = v_empno;
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: '||SQL%ROWCOUNT) ; -- 변경된 건수 출력
	COMMIT;
END;

--===============================================================
-- /* Example 9-18 시퀀스를 SQL문 없이 직접 사용 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 시퀀스 emp_seq 생성
--CREATE SEQUENCE emp_seq;

DECLARE
	v_seq_value NUMBER;
BEGIN
	-- SQL 없이 시퀀스를 직접 사용하는 방법
	v_seq_value := emp_seq.NEXTVAL;

	DBMS_OUTPUT.PUT_LINE('시퀀스 값: ' || TO_CHAR(v_seq_value));
END;


-- 모든 생성된 sequences 조회
-- select * from user_sequences

-- 현재 시퀀스 조회
-- select emp_seq.currval from dual

-- 다음 시권스 조회
-- select emp_seq.nextval from dual

--===============================================================
-- /* Example 9-19 시퀀스를 SQL문에 포함하여 사용 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_seq_value NUMBER;
BEGIN
	-- SQL을 사용하여 시퀀스를 얻어 옴
  -- "v_seq_value := emp_seq.NEXTVAL"에 비해 비효율적임
	SELECT emp_seq.NEXTVAL
		INTO v_seq_value
		FROM DUAL;

	DBMS_OUTPUT.PUT_LINE('시퀀스 값: ' || TO_CHAR(v_seq_value));
END;


-- 모든 생성된 sequences 조회
-- select * from user_sequences

-- 현재 시퀀스 조회
-- select emp_seq.currval from dual

-- 다음 시권스 조회
-- select emp_seq.nextval from dual

--===============================================================
-- /* Example 9-20 RETURNING절을 사용하여 DML문의 결과값을 PL/SQL로 반환 */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	c_hiredate DATE := DATE'2016-01-02';
	v_empno		 emp.empno%TYPE;
	v_ename		 emp.ename%TYPE;
	v_hiredate emp.hiredate%TYPE;
BEGIN
	DELETE FROM emp
	 WHERE empno = 9000;

	-- INSERT 후 삽입된 값을 반환
	INSERT INTO emp
  (
		empno
	, ename
	, hiredate
	, deptno
	)
	VALUES
	(
		9000
	, '홍길동'
	, c_hiredate
	, 40
	)
	RETURNING empno, ename, hiredate          -- 컬럼을
			 INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원추가=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');

	-- UPDATE 후 변경된 값을 반환
	UPDATE emp
		 SET HIREDATE = c_hiredate
	 WHERE empno = v_empno
	 RETURNING empno, ename, hiredate          -- 컬럼을
				INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원변경=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');

	-- DELETE 후 삭제된 사원의 사번, 이름, 입사일 반환
	DELETE FROM emp
	 WHERE empno = v_empno
	 RETURNING empno, ename, hiredate          -- 컬럼을
				INTO v_empno, v_ename, v_hiredate;   -- PL/SQL 변수로 리턴
	DBMS_OUTPUT.PUT_LINE('사원삭제=(' || v_empno || ', ' || v_ename || ', ' || TO_CHAR(v_hiredate, 'YYYYMMDD') || ')');
	COMMIT;
END;

--===============================================================
-- /* Example 9-21 COMMIT의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM COMMIT의 사용
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ;
  INSERT INTO emp(empno, ename, hiredate, sal) VALUES (9000, '홍길동', SYSDATE, 9000) ;
  UPDATE EMP SET sal = sal + 100 WHERE empno = 9000 ;
  COMMIT ;
END ;

--===============================================================
-- /* Example 9-22 DDL에 의한 묵시적 COM.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 이전에 생성된 테이블 t가 있으면 DROP
DROP TABLE t ;

PAUSE

REM DDL에 의한 묵시적 COMMIT
REM EXECUTE IMMEDIATE 'CREATE TABLE' 문은 트랜잭션을 묵시적으로 COMMIT 한다.
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ;
  INSERT INTO emp(empno, ename, hiredate, sal) VALUES (9000, '홍길동', SYSDATE, 9000) ;
  UPDATE EMP SET SAL = SAL + 100 WHERE EMPNO = 9000 ;
  EXECUTE IMMEDIATE 'CREATE TABLE t(C1 NUMBER)' ; -- DDL이 수행되면 자동으로 COMMIT이 수행된다.
  ROLLBACK ; -- 6번 줄에서 트랜잭션이 이미 묵시적으로 COMMIT되었으므로 무의미함.
  DECLARE
    v_sal NUMBER ;
  BEGIN
    SELECT sal INTO v_sal FROM emp WHERE empno = 9000 ;
    DBMS_OUTPUT.PUT_LINE('SAL = '||v_sal) ; -- 사번 9000에 대한 DML이 COMMIT됨.
  END ;
END ;

--===============================================================
-- /* Example 9-23 ROLLBACK의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM ROLLBACK의 사용
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ; -- emp 테이블의 데이터는 14건이 됨
  -- 다음 INSERT문에 의해 emp 테이블의 데이터는 15건이 됨
  INSERT INTO emp(empno, ename, hiredate, sal) VALUES (9000, '홍길동', SYSDATE, 9000) ;
  UPDATE EMP SET SAL = SAL + 100 WHERE EMPNO = 9000 ;
  ROLLBACK ; -- 4번 줄과 5번 줄의 변경을 취소. emp 테이블의 데이터는 다시 14건이 됨
  DECLARE
    v_cnt NUMBER ;
  BEGIN
    SELECT count(*) INTO v_cnt FROM emp WHERE empno = 9000 ;
    DBMS_OUTPUT.PUT_LINE('사번 9000 건수 = '||v_cnt) ;
  END ;
END ;

--===============================================================
-- /* Example 9-24 SAVEPOINT의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM SAVEPOINT의 사용
DECLARE
  v_org_sal NUMBER := 5000;
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ;
  INSERT INTO emp(empno, ename, hiredate, sal)
         VALUES (9000, '홍길동', SYSDATE, v_org_sal) ;
  SAVEPOINT p1 ;     -- 첫 번째 SAVEPOINT p1
  UPDATE emp SET sal = sal + 100 WHERE empno = 9000 ;
  SAVEPOINT p2 ;     -- 두 번째 SAVEPOINT p2
  BEGIN
    INSERT INTO emp(empno, ename, hiredate, sal)
           VALUES (9000, '임꺽정', SYSDATE, v_org_sal) ;
  EXCEPTION WHEN OTHERS THEN
    -- 12번 줄의 INSERT문이 실패하면 9번 줄의UPDATE와 12번 줄의 INSERT는 취소하고
    -- 6번 줄의 INSERT문은 변경에 반영하도록 한다.
    DBMS_OUTPUT.PUT_LINE('오류 발생 감지: '||SQLERRM) ; -- 오류 메시지 출력
    ROLLBACK TO p1 ; -- 트랜잭션을 p1 상태로 복귀
  END ;
  COMMIT ;
  DECLARE
    v_sal NUMBER ;
  BEGIN
    SELECT sal INTO v_sal FROM emp WHERE empno = 9000 ;
    DBMS_OUTPUT.PUT_LINE('SAL = '||v_sal) ; -- 6번 줄에서 INSERT된 급여가 출력된다.
    IF v_org_sal <> v_sal THEN
      DBMS_OUTPUT.PUT_LINE('원 급여가 변경되었습니다.') ;
    ELSE
      DBMS_OUTPUT.PUT_LINE('원 급여가 변경되지 않았습니다.') ;
    END IF ;
  END ;
END ;

--===============================================================
-- /* Example 9-25 동일한 이름의 SAVEPOINT를 여러 곳에서 사용.SQL  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 동일한 이름의 SAVEPOINT를 여러 곳에서 사용
DECLARE
  v_org_sal NUMBER := 5000;
BEGIN
  DELETE FROM emp WHERE empno = 9000 ; -- 이전 예제에서 생성된 데이터 삭제
  COMMIT ;
  INSERT INTO emp(empno, ename, hiredate, sal)
         VALUES (9000, '홍길동', SYSDATE, v_org_sal) ;
  SAVEPOINT p1 ; -- 처음 지정된 SAVEPOINT p1의 위치
  UPDATE emp SET sal = sal + 100 WHERE empno = 9000 ;
  SAVEPOINT p1 ;  -- 8번 줄과 SAVEPOINT 이름이 동일. p1을 이 지점으로 옮김
  BEGIN
    INSERT INTO emp(empno, ename, hiredate, sal)
           VALUES (9000, '임꺽정', SYSDATE, v_org_sal) ;
  EXCEPTION WHEN OTHERS THEN
    -- 12번 줄의 INSERT문이 실패하면 INSERT만 취소하고
    -- 6번 줄의 INSERT문과 9번 줄의 UPDATE문은 변경에 반영하도록 한다.
    DBMS_OUTPUT.PUT_LINE('오류 발생 감지: '||SQLERRM) ; -- 오류 메시지 출력
    ROLLBACK TO p1 ; -- 트랜잭션을 p1 상태로 복귀
  END ;
  COMMIT ;
  DECLARE
    v_sal NUMBER ;
  BEGIN
    SELECT sal INTO v_sal FROM emp WHERE empno = 9000 ;
    DBMS_OUTPUT.PUT_LINE('SAL = '||v_sal) ; -- 9번 줄에서 UPDATE된 급여 출력.
    IF v_org_sal <> v_sal THEN
      DBMS_OUTPUT.PUT_LINE('원 급여가 변경되었습니다.') ;
    ELSE
      DBMS_OUTPUT.PUT_LINE('원 급여가 변경되지 않았습니다.') ;
    END IF ;
  END ;
END ;

--===============================================================
-- /* Example 9-26 READ ONLY 트랜잭션에서 DML을 사용하면 오류 발생.SQL  */
--===============================================================
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

--===============================================================
-- /* Example 9-27 CLOB의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DROP TABLE t_clob ;

REM 예제용 테이블 생성
CREATE TABLE t_clob (
 line#  NUMBER,
 script CLOB
) ;

--PAUSE

REM CLOB의 사용
DECLARE
  v_rec t_clob%ROWTYPE ;
BEGIN
  DELETE FROM t_clob ;

  v_rec.line#  := 1 ;
  v_rec.script := '옛날에 옛날에 어느 깊은 산속 연못 가에 도토리 나무가 서 있었습니다.' ;
  INSERT INTO T_CLOB VALUES v_rec ;

  v_rec.line#  := 2 ;
  v_rec.script := '어느 해 날씨가 너무 좋아서 도토리 나무에 도토리가 정말 많이 열렸습니다.' ;
  INSERT INTO t_clob VALUES v_rec ;

  SELECT line#, script
    INTO v_rec
    FROM t_clob
   WHERE line# = 1 ;
  DBMS_OUTPUT.PUT_LINE(v_rec.line#||' : '||v_rec.script) ;
END ;

--===============================================================
-- /* Example 9-28 PLSQL에서는 CLOB 타입과 VARCHAR2 타입간의 구별이 거의 없이 사용 가능하다.SQL  */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM PL/SQL에서는 CLOB 타입과 VARCHAR2 타입간의 구별이 거의 없이 사용 가능하다.
DECLARE
  v_dname    VARCHAR2(32767) ;
  v_clob     CLOB ;
  v_varchar  VARCHAR2(4000) ;
  v_clob2    CLOB ;
  v_varchar2 VARCHAR2(4000) ;
BEGIN
  -- VARCHAR2 타입의 칼럼을 CLOB 타입의 변수에 저장할 수 있다.
  SELECT dname INTO v_clob
    FROM dept
   WHERE deptno = 10 ;

  -- CLOB 타입의 칼럼을 VARCHAR2 타입의 변수에 저장할 수 있다.
  SELECT SCRIPT INTO v_varchar
    FROM t_clob
   WHERE line# = 1 ;

  -- CLOB <-> VARCHAR2 간의 변환은 문제 없이 지원된다(VARCHAR2의 길이가 충분한 경우에 한한다).
  v_clob2    := v_varchar ;
  v_varchar2 := v_clob ;

  -- VARCHAR2 타입에 사용 가능한 내장함수를 CLOB 타입에도 동일하게 사용할 수 있다
  v_clob2  := UPPER(v_clob) ;
  v_dname  := LOWER(SUBSTR(v_clob, 1, 10)) ;

  -- VARCHAR2 변수에서 CLOB으로의 변환도 자동으로 수행된다.
  v_clob2  := INITCAP(v_dname) ;

  -- CLOB의 DBMS_OUTPUT 출력도 동일하게 지원된다.
  DBMS_OUTPUT.PUT_LINE('CLOB 출력: '||v_clob) ;

  -- DML에서 CLOB 타입의 변수를 VARCHAR2 타입 칼럼에 사용할 수 있다.
  UPDATE dept
     SET dname = v_clob
   WHERE deptno = 10 ;

  -- DML에서 VARCHAR2 타입의 변수를 CLOB 타입 칼럼에 사용할 수 있다.
  UPDATE t_clob
     SET script = v_varchar
   WHERE line# = 1 ;
END ;

--===============================================================
-- /* Example 9-29 CLOB과 VARCHAR2가 완전히 호환되지는 않는다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CLOB과 VARCHAR2가 완전히 호환되지는 않는다.
REM 32767바이트 길이의 한계가 존재하고, 일부 호환되지 않는 함수가 있다.
DECLARE
  v_varchar2 VARCHAR2(32767) ;
  v_clob     CLOB ;
BEGIN
  -- 크기가 32768인 CLOB을 생성한다.
  v_clob := RPAD('A', 32767, 'A') || '$' ;
  -- 길이를 128K로 늘린다.
  v_clob := v_clob || v_clob || v_clob || v_clob ;

  -- 일부 내장 함수는 길이 32767바이트 이상의 CLOB에서 정상 동작한다.
  v_clob     := REPLACE(v_clob, 'A', 'B') ; -- 정상
  v_clob     := TRIM(v_clob) ;              -- 정상

  -- 32767바이트를 초과하는 CLOB을 VARCHAR2 타입에 복사할 수 없다.
  BEGIN
    v_varchar2 := v_clob ;                    -- 오류
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('오류 발생(1): '||SQLERRM) ; -- 오류 메시지 출력
  END ;

  -- 일부 내장 함수는 길이 32767바이트 이상의 CLOB에서 오류가 발생한다.
  BEGIN
    v_varchar2 := SUBSTR(v_clob, 1, 32768) ;  -- 오류
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('오류 발생(2): '||SQLERRM) ; -- 오류 메시지 출력
  END ;
  BEGIN
    v_clob     := INITCAP(v_clob) ;           -- 오류
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('오류 발생(3): '||SQLERRM) ; -- 오류 메시지 출력
  END ;
END ;

--===============================================================
-- /* Example 10-1 조건분기문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_cnt		NUMBER;
	v_type	STRING(10);
BEGIN
	-- 테이블 emp가 생성되어 있는지 확인한다.
	-- 딕셔너리 뷰 user_tables에는 계정에 생성된 모든 테이블 목록이 들어 있다.
	SELECT COUNT(*)
		INTO v_cnt
		FROM USER_TABLES
	 WHERE TABLE_NAME = 'EMP';

	IF v_cnt > 0
	THEN
		DBMS_OUTPUT.PUT_LINE('테이블 EMP가 존재합니다.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('테이블 EMP가 존재하지 않습니다.');
	END IF;
END;

--===============================================================
-- /* Example 10-2 단순 CASE문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 예제 8-11 단순 CASE 표현식 → 단순 CASE문으로 변경함
/*
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Simple CASE expression
  v_STR := CASE v_BOOL WHEN TRUE  THEN 'v_BOOL is TRUE'
                       WHEN FALSE THEN 'v_BOOL is FALSE'
                       ELSE            'v_BOOL is NULL'
           END ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;
*/
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Simple CASE Statement
  CASE v_BOOL WHEN TRUE THEN
                v_STR := 'v_BOOL is TRUE' ;
              WHEN FALSE THEN
                v_STR := 'v_BOOL is FALSE' ;
              ELSE
                v_STR := 'v_BOOL is NULL' ;
  END CASE ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 10-3 조사 CASE문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 예제 8-12 조사 CASE 표현식 → 조사 CASE문으로 변경함
DECLARE
  v_BOOL BOOLEAN := TRUE ;
  v_STR  STRING(100) ;
BEGIN
  -- Searched CASE Statement
  CASE WHEN v_BOOL = TRUE THEN
         v_STR := 'v_BOOL is TRUE' ;
       WHEN v_BOOL = FALSE THEN
         v_STR := 'v_BOOL is FALSE' ;
       ELSE
         v_STR := 'v_BOOL is NULL' ;
  END CASE ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 10-4 두 개 이상의 조건이 만족되는 경우에는 순서가 먼저인 것이 적용된다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 두 개 이상의 조건이 만족되는 경우에는 순서가 먼저인 것이 적용된다
DECLARE
  v_BOOL  BOOLEAN := TRUE ;
  v_TRUE  BOOLEAN := TRUE ;
  v_FALSE BOOLEAN := FALSE ;
  v_STR  STRING(100) ;
BEGIN
  CASE v_BOOL WHEN TRUE THEN
                v_STR := 'v_BOOL = TRUE'   ; -- TRUE
              WHEN v_TRUE  THEN
                v_STR := 'v_BOOL = v_TRUE' ; -- TRUE
              WHEN FALSE   THEN
                v_STR := 'v_BOOL = FALSE'  ; -- FALSE
              WHEN v_FALSE THEN
                v_STR := 'v_BOOL = v_FALSE'; -- FALSE
              ELSE
                v_STR := 'v_BOOL IS NULL' ;
  END CASE ;
  DBMS_OUTPUT.PUT_LINE(v_STR) ;
END ;

--===============================================================
-- /* Example 10-5 만족하는 조건이 발견되면 CASE문에서 예외가 발생하지 않는다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CASE문에 나열된 선택자나 조건식 중에서 만족하는 조건이 발견되면 예외가 발생하지 않는다.
DECLARE
  v_num PLS_INTEGER := 3 ;
  v_str  STRING(100) ;
BEGIN
  -- 만족하는 조건이 발견되면 예외가 발생하지 않는다.
  CASE v_num WHEN 1 THEN
               v_str := '숫자 1' ;
             WHEN 2 THEN
               v_str := '숫자 2' ;
             WHEN 3 THEN
               v_str := '숫자 3' ; -- 만족하는 조건이 존재
             WHEN 4 THEN
               v_str := '숫자 4' ;
  END CASE;
  DBMS_OUTPUT.PUT_LINE(v_str) ;
END ;

--===============================================================
-- /* Example 10-6 만족하는 조건이 발견되지 않으면 CASE문에서 예외가 발생한다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CASE문에 나열된 선택자나 조건식 중에서 만족하는 조건이 발견되지 않으면 예외가 발생한다.
DECLARE
  v_num PLS_INTEGER := 3 ;
  v_str  STRING(100) ;
BEGIN
  -- 선택값 3을 주석 처리하면 만족하는 조건이 발견되지 않아 예외가 발생한다.
  CASE v_num WHEN 1 THEN
               v_str := '숫자 1' ;
             WHEN 2 THEN
               v_str := '숫자 2' ;
          -- WHEN 3 THEN
          --   v_str := '숫자 3' ; -- 만족하는 조건이 주석 처리되어 없어졌음
             WHEN 4 THEN
               v_str := '숫자 4' ;
  END CASE;
  DBMS_OUTPUT.PUT_LINE(v_str) ;
END ;

--===============================================================
-- /* Example 10-7 ELSE를 추가하면 CASE문의 예외를 방지할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 마지막 조건으로 ELSE를 추가하면 CASE문의 예외를 방지할 수 있다
DECLARE
  v_num PLS_INTEGER := 3 ;
  v_str  STRING(100) ;
BEGIN
  -- 선택값 3을 주석 처리하면 만족하는 조건이 발견되지 않아 예외가 발생한다.
  CASE v_num WHEN 1 THEN
               v_str := '숫자 1' ;
             WHEN 2 THEN
               v_str := '숫자 2' ;
          -- WHEN 3 THEN
          --   v_str := '숫자 3' ; -- 만족하는 조건이 주석 처리되어 없어졌음
             WHEN 4 THEN
               v_str := '숫자 4' ;
             ELSE
               v_str := '알 수 없는 숫자 ' || v_num ; -- ELSE는 항상 만족되는 조건임
  END CASE;
  DBMS_OUTPUT.PUT_LINE(v_str) ;
END ;

--===============================================================
-- /* Example 10-8 GOTO 문을 사용한 4중 루프 탈출.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM GOTO 문을 사용한 4중 LOOP 탈출
BEGIN
  FOR I IN 1 .. 10 LOOP
    FOR J IN 1 .. 10 LOOP
      FOR K IN 1 .. 10 LOOP
        FOR L IN 1 .. 10 LOOP
          GOTO AFTER_LOOP ; -- 4중 LOOP 탈출
          DBMS_OUTPUT.PUT_LINE('L='||L) ;
        END LOOP ;
        DBMS_OUTPUT.PUT_LINE('K='||K) ;
      END LOOP ;
      DBMS_OUTPUT.PUT_LINE('J='||J) ;
    END LOOP ;
    DBMS_OUTPUT.PUT_LINE('I='||I) ;
  END LOOP ;
  <<AFTER_LOOP>> -- 레이블
  DBMS_OUTPUT.PUT_LINE('AFTER LOOP') ;
END ;

--===============================================================
-- /* Example 10-9 EXIT 문을 사용한 4중 루프 탈출.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXIT 문을 사용한 4중 LOOP 탈출
BEGIN
  <<OUTMOST_LOOP>> -- 레이블
  FOR I IN 1 .. 10 LOOP
    FOR J IN 1 .. 10 LOOP
      FOR K IN 1 .. 10 LOOP
        FOR L IN 1 .. 10 LOOP
          EXIT OUTMOST_LOOP ; -- 4중 LOOP 탈출
          DBMS_OUTPUT.PUT_LINE('L='||L) ;
        END LOOP ;
        DBMS_OUTPUT.PUT_LINE('K='||K) ;
      END LOOP ;
      DBMS_OUTPUT.PUT_LINE('J='||J) ;
    END LOOP ;
    DBMS_OUTPUT.PUT_LINE('I='||I) ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('AFTER LOOP') ;
END ;

--===============================================================
-- /* Example 10-10 더 깊은 레벨의 레이블을 참조하는 무조건 분기문 오류.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- GOTO문은 현재 위치와 동일한 깊이에 선언도니 레이블이나 더 바깥에 선언된 레이블을 지정할 수 있음
-- 그러나 현재 레벨보다 더 깊은 곳에 위치한 레이블은 지정할 수 없음
REM 무조건 분기문: 더 깊은 레벨의 레이블을 참조하므로 오류
DECLARE
  v_bool BOOLEAN := TRUE;
BEGIN
  GOTO deeper_level ; -- 더 깊은 레벨의 레이블을 참조하므로 오류

  IF v_bool = TRUE THEN
  <<deeper_level>>
    NULL ;
  END IF;
END;

--===============================================================
-- /* Example 10-11 다른 프로시저 내부의 레이블을 참조하는 무조건 분기문 오류.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- GOTO문이 다른 FUNCTION 또는 프로시저 내부에 선언된 레이블을 지정하는 것은 불가함
REM 무조건 분기문: 다른 프로시저의 레이블을 참조하므로 오류
DECLARE
 PROCEDURE p AS
 BEGIN
  <<subprogram_p>>
   NULL ;
 END ;
BEGIN
  GOTO subprogram_p ; -- 다른 프로시져 내부의 레이블을 참조하므로 오류
END;

--===============================================================
-- /* Example 10-12 레이블의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

/*
1. 레이블명으로 사용 가능한 문자열의 기준은 변수명의 기준과 동일하며, 한글도 사용 가능함
2. 변수명과 마찬가지로 큰따옴표로 레이블명을 둘러싸는 경우에는 어떤 문자라도 사용 가능함
*/
REM 레이블의 사용
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  IF v_num = 0 THEN
    GOTO block_label ; -- 뒤따르는 블록 레이블로 이동
  END IF ;

  <<block_label>>  -- BLOCK에 대한 레이블
  BEGIN
    IF v_num = 0 THEN
      GOTO statement_label ; -- 뒤따르는 문장 레이블로 이동
    END IF ;

    <<statement_label>>  -- 문장(실행문)에 대한 레이블
    v_num := v_num + 1 ;
		DBMS_OUTPUT.PUT_LINE('1111') ;

    IF v_num = 0 THEN
			DBMS_OUTPUT.PUT_LINE('2222') ;
      GOTO statement_label ; -- 앞에 위치한 문장 레이블로 이동
    END IF ;
  END ;

  IF v_num = 0  THEN
		DBMS_OUTPUT.PUT_LINE('3333') ;
    GOTO block_label ; -- 앞에 위치한 블록 레이블로 이동
  END IF ;
END ;

--===============================================================
-- /* Example 10-13 레이블 다음에는 최소한 1개의 실행문이 필요하다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레이블 다음에는 최소한 1개의 실행문이 필요하다
REM 적어도 하나의 NULL 문이라도 있어야 한다.
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  IF v_num = 0 THEN
    GOTO program_end ;
  END IF ;

<<program_end>>
  NULL ; -- 레이블 다음에 반드시 실행문이 있어야 하는 규칙 때문에 삽입한 문장
END ;

--===============================================================
-- /* Example 10-14 가장 단순한 기본 LOOP 문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 기본 LOOP문은 종료 조건이 반드시 필요하다.
REM 이 예제는 종료 조건이 없는 무한 FNVM로, 영원히 끝나지 않는다.
REM CTRL+C로 수행을 중단시켜야 한다
BEGIN
	LOOP	-- 이 LOOP문은 종료 조건이 없는 무한 루프다. CTRL+C로 수행을 중단시켜야 한다
		NULL;
	END LOOP;
END;

--===============================================================
-- /* Example 10-15 GOTO 탈출문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM GOTO 탈출문
DECLARE
  v_num NUMBER := 1 ;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
    v_num:= v_num + 1 ;
    IF v_num > 3 THEN
      GOTO end_loop ;
    END IF ;
  END LOOP ;
  << end_loop >>
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;

--===============================================================
-- /* Example 10-16 EXIT 탈출문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXIT 탈출문
DECLARE
  v_num NUMBER := 1 ;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
    v_num:= v_num + 1 ;
    IF v_num > 3 THEN
      EXIT ; -- LOOP를 즉시 탈출하여 END LOOP 다음의 실행문으로 실행 위치를 이동
    END IF ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;

--===============================================================
-- /* Example 10-17 EXIT WHEN 탈출문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXIT WHEN 탈출문
DECLARE
  v_num NUMBER := 1 ;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
    v_num:= v_num + 1 ;
    EXIT WHEN v_num > 3 ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;

--===============================================================
-- /* Example 10-18 WHILE LOOP문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- 예제 10-15를 WHILE LOOP로 변경
DECLARE
  v_num NUMBER := 1 ;
BEGIN
  WHILE v_num <= 3
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프내부 : ' || v_num) ;
    v_num := v_num + 1 ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프종료 : ' || v_num) ;
END ;

--===============================================================
-- /* Example 10-19 범위를 지정한 FOR LOOP 문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	FOR idx IN 1 .. 3
	LOOP
		  DBMS_OUTPUT.PUT_LINE('루프내부 : ' || idx);
	END LOOP;
END;

--===============================================================
-- /* Example 10-20 FOR문의 순환 범위는 반드시 하한값 .. 상한값으로 지정해야 한다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM REVERSE 옵션 사용과 관계 없이 순환 범위는
REM 반드시 하한값..상한값으로 지정해야 한다.
DECLARE
  v_cnt PLS_INTEGER ;
BEGIN
  v_cnt := 0 ;
  -- IN 하한값 .. 상한값 사용
  FOR idx IN REVERSE 1 .. 3
  LOOP
    v_cnt := v_cnt + 1 ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 실행 횟수(1..3) : ' || v_cnt || '회') ;

  v_cnt := 0 ;
  -- IN 상한값 .. 하한값 사용
  FOR idx IN REVERSE 3 .. 1 -- 오류 1 .. 3으로 해야함.
  LOOP
    v_cnt := v_cnt + 1 ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 실행 횟수(3..1) : ' || v_cnt || '회') ;
END ;

--===============================================================
-- /* Example 10-21 FOR 문의 인덱스 변수는 FOR 문을 벗어나면 사용할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM FOR 문의 인덱스 변수는 FOR 문을 벗어나면 사용할 수 없다.
REM 6번 줄에서는 변수 idx가 존재하지 않으므로 오류를 발생시킨다.
BEGIN
  FOR idx IN 1 .. 3
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, idx = ' || idx) ;
  END LOOP ;
  -- DBMS_OUTPUT.PUT_LINE('루프 종료, idx = ' || idx) ; -- LOOP INDEX 변수는 LOOP문 밖에서 사용하면 에러남
END ;

--===============================================================
-- /* Example 10-22 DECLARE 절의 변수 idx와 FOR 문의 인덱스 변수 idx는 서로 다른 변수이다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM DECLARE 절의 변수 idx와 FOR 문의 인덱스 변수 idx는 이름만 같지 서로 다른 변수이다.
DECLARE
  idx NUMBER := 0 ;
BEGIN
  FOR idx IN 1 .. 3
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, idx = ' || idx) ; -- 1, 2, 3 리턴
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, idx = ' || idx) ; -- 0 리턴
END ;

--===============================================================
-- /* Example 10-23 FOR 문의 인덱스 변수는 변경할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM FOR 문의 인덱스 변수는 변경할 수 없다.
REM 다음 예제는 인덱스 변수를 변경하므로 오류를 발생시킨다.
BEGIN
  FOR idx IN 1 .. 3
  LOOP
    idx := idx + 1 ;
  END LOOP ;
END ;

--===============================================================
-- /* Example 10-24 FOR 문의 상하한 값에 변수 또는 표현식을 사용할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM FOR 문의 상/하한 값에 변수 또는 표현식을 사용할 수 있다.
DECLARE
  v_lower_value NUMBER := 0 ;
BEGIN
  FOR idx IN v_lower_value .. (v_lower_value + 2) -- 하한값은 변수, 상한값은 표현식을 사용함
  LOOP
    DBMS_OUTPUT.PUT_LINE('루프 내부, idx = ' || idx) ;
  END LOOP ;
END ;

--===============================================================
-- /* Example 10-25 CONTINUE 문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CONTINUE 문
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  LOOP
    v_num:= v_num + 1 ;
    EXIT WHEN v_num > 5 ;
    IF v_num > 3 THEN
      CONTINUE; -- 5번 줄부터 다시 시작
    END IF ;
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;

--===============================================================
-- /* Example 10-26 CONTINUE WHEN 문.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM CONTINUE WHEN 문
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  LOOP
    v_num:= v_num + 1 ;
    EXIT WHEN v_num > 5 ;
    CONTINUE WHEN v_num > 3; -- 5번 줄부터 다시 시작
    DBMS_OUTPUT.PUT_LINE('루프 내부, v_num = '||v_num) ;
  END LOOP ;
  DBMS_OUTPUT.PUT_LINE('루프 종료, v_num = '||v_num) ;
END ;

--===============================================================
-- /* Example 11-1 VARRAY와 Nested Table을 사용한 스키마 레벨 데이터 타입 정의.SQL */
--===============================================================
/*

1. 스칼라 데이터 타입 : 단일 값 데이터 타입
2. 컴포지트 데이터 타입 : 복합 데이터 타입
 1) 컬렉션(Collection) : 배열과 유사한 구조로 동일한 데이터 타입이 반복되는 데이터를 저장하는 자료 구조이다.
	(1) Associative Array(연관배열) :
		- 컬렉션 항목의 개수를 사전에 지정하지 않는다.
		- 키(인덱스)는 정수와 문자열 둘 중 하나를 사용할 수 있다.(음수도 가능)
		- 컬렉션 항목의 개수에는 제한이 없음
		- Associative Array 변수는 초기화를 필요로 하지 않는다.
		- 변수는 NULL이 될 수 없으며, NULL을 할당하려고 하면 오류가 발생한다.
		- 키(인덱스)-값 쌍으로 이루어진 무한 배열이라고 볼 수 있다
		- Associative Array는 서브프로그램 내에서 사용될 소규모의 참조 테이블에서 사용하거나 컬렉션을 서버로 전달 또는 서버로부터 전달받을 때 유용함
		- Hash Table, Hash Map

	(2) VARRAY(가변 크기 배열) :
		- VARRAY 변수의 선언 시 배열의 크기를 지정해야 한다
		- VARRAY 인덱스는 1부터 시작하는 자연수 값이며, 저장된 값은 순서가 바뀌지 않는 것이 보장된다
		- 초기화되지 않은 VARRAY 변수는 NULL 이며, 사용 전에 반드시초기화해 주어야 오류가 발생하지 않는다.
		- 컬렉션 생성자 또는 EXTEND 메소드로 초기화 가능함
		- VARRAY는 배열의 최대 개수를 사전에 알고 있는 경우 또는 배열의 항목을 항상 동일한 순서로 접근하는 경우 유용함
		- Array, Vector

	(3) Nested Table(중첩 테이블) : Set, Bag(중복 허용 집합)

 2) 레코드(Record) : 서로 다른 데이터 타입의 데이터를 모아 놓은 자료 구조이다.

- ADT(Abstract Data Type) : TYPE문을 사용하여 스키마 레벨에서 정의되는 사용자 정의 객체 타입을 말한다.

*/

--PROCEDURE 생성 시
--CREATE OR REPLACE PROCEDURE SCOTT.check_salary(a_empno NUMBER)

SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM VARRAY를 사용한 스키마 레벨 데이터 타입 정의
CREATE OR REPLACE TYPE languages IS VARRAY(10) OF VARCHAR2(64)

PAUSE

REM Nested Table을 사용한 스키마 레벨 데이터 타입 정의
CREATE OR REPLACE TYPE cities IS TABLE OF VARCHAR2(64)

--===============================================================
-- /* Example 11-2 Associative Array를 사용한 ADT 정의는 불가능하다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM Associative Array를 사용한 스키마 레벨 데이터 타입 정의는 불가능
CREATE OR REPLACE TYPE colors IS TABLE OF VARCHAR2(64) INDEX BY PLS_INTEGER
/
PAUSE

SHOW ERROR

--===============================================================
-- /* Example 11-3 Associative Array 컬렉션의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM Associative Array 컬렉션의 사용
DECLARE
  -- 정수를 인덱스로 하는 Associative Array 타입 선언
  TYPE city IS TABLE OF VARCHAR2(64) INDEX BY PLS_INTEGER ;

  -- 문자열을 인덱스로 하는 Associative Array 타입 선언
  TYPE population IS TABLE OF NUMBER INDEX BY VARCHAR2(64);

  v_city       city ;        -- 컬렉션 변수 선언
  v_Population Population ;  -- Population 타입의 컬렉션 변수
BEGIN

  -- 정수 인덱스를 사용하는 Associative Array의 값 할당
  -- 특정 인덱스에 값을 지정하면, 이후 이 인덱스로 값의 접근이 가능하다.
  v_city(-1) := '서울' ;
  v_city( 0) := '부산' ;
  v_city( 2) := '대전' ;

  -- 인덱스 -1, 0, 2를 제외한 인덱스의 항목은 값을 가지지 않는다.
  -- 다른 인덱스를 사용하여 v_city에 접근하면 ORA-01403 오류가 발생한다.

  -- 문자열 인덱스를 사용하는 Associative Array의 값 지정
  v_Population('서울') := 10373234 ; -- 서울 인구
  v_Population('부산') :=  3812392 ; -- 부산 인구
  v_Population('대전') :=  1390510 ; -- 대전 인구

  -- v_city에 들어 있는 각 도시의 인구 출력
  DBMS_OUTPUT.PUT_LINE('도시별 인구(2000년 기준)') ;
  DBMS_OUTPUT.PUT_LINE('========================') ;
  DBMS_OUTPUT.PUT_LINE(v_city(-1) || ' :' || TO_CHAR(v_Population(v_city(-1)), '99,999,999')) ;
  DBMS_OUTPUT.PUT_LINE(v_city( 0) || ' :' || TO_CHAR(v_Population(v_city( 0)), '99,999,999')) ;
  DBMS_OUTPUT.PUT_LINE(v_city( 2) || ' :' || TO_CHAR(v_Population(v_city( 2)), '99,999,999')) ;
END ;

--===============================================================
-- /* Example 11-4 BULK COLLECT는 여러 건의 SELECT 결과를 Associative Array 변수에 넣는다.SQL */
--===============================================================
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
END;

--===============================================================
-- /* Example 11-5 함수의 반환형으로 Associative Array 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE int_array IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER; -- Associative Array ADT
	v_fibonacci int_array; -- 피보나치 수열을 저장할 배열
	c_order CONSTANT PLS_INTEGER := 20;

	/*
	 * N 개의 피보나치 수열을 계산하여 배열을 반환하는 함수
 	 * 피보나치 수열은 처음 두 개의 항이 0과 1이고, 세 번째 항부터는
   * F(n) = F(n-1) + F(n-2)의 점화식으로 주어지는 수열이다.
	 */
	FUNCTION fibonacci_sequence(num IN PLS_INTEGER) RETURN int_array
	IS
		v_arr int_array; -- 반환할 피보나치 수열
	BEGIN
		v_arr(1) := 0; -- 첫번째 항
		v_arr(2) := 1; -- 두번째 항
		FOR i IN 3..num
		LOOP -- 세번째 항 이상
			v_arr(i) := v_arr(i-1) + v_arr(i-2);
		END LOOP;
		RETURN v_arr; -- Associative Array를 반환
	END;

BEGIN
	v_fibonacci := fibonacci_sequence(c_order); -- 함수가 반환한 Associative Array
	DBMS_OUTPUT.PUT_LINE('피보나치 수열의 '||c_order||'개 항') ;
	FOR i IN 1 .. c_order
	LOOP
		DBMS_OUTPUT.PUT(CASE WHEN 1 < i THEN ', ' END || v_fibonacci(i)) ;
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('') ;
END;

/*
SQL> 피보나치 수열의 20개 항
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181
*/

--===============================================================
-- /* Example 11-6 값이 할당되지 않은 Associative Array 항목은 참조할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 값이 할당되지 않은 Associative Array 항목은 참조할 수 없다.
DECLARE
  TYPE int_array IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  v_arr int_array ;
BEGIN
  v_arr(-1) := -1 ;
  v_arr( 1) :=  1 ;
  DBMS_OUTPUT.PUT_LINE('v_arr(-1) = '||v_arr(-1)) ; -- 정상
  DBMS_OUTPUT.PUT_LINE('v_arr( 1) = '||v_arr( 1)) ; -- 정상
  DBMS_OUTPUT.PUT_LINE('v_arr( 0) = '||v_arr( 0)) ; -- 오류 발생
END ;

--===============================================================
-- /* Example 11-7 VARRAY 컬렉션의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM VARRAY 컬렉션의 사용
DECLARE
  -- VARRAY 타입 선언 : 자연수를 인덱스로 하는, 최대 10개의 64바이트 문자열의 배열
	TYPE languages IS VARRAY(10) OF VARCHAR2(64);
	v_lang		languages;	-- VARRAY 변수 선언 v_lang = NULL임
	v_lang2		languages := languages('한국어', '중국어', '영어'); -- 변수 선언 시 생성자를 사용하여 초기화
BEGIN
	v_lang := languages();										-- 컬렉션 생성자를 사용하여 Empty(크기가 0)로 초기화.
	v_lang := languages('한국어');							-- 컬렉션 생성자를 사용하여 크기가 1인 VARRAY로 재초기화
	v_lang := languages('한국어', '중국어');		-- 컬렉션 생성자를 사용하여 크기가 2인 VARRAY로 재초기화

	v_lang.EXTEND(2);		-- 크기 두개 증가
	v_lang(3) := '일본어';
	v_lang(4) := '영어';

	-- v_lang에 들어 있는 언어 출력
  DBMS_OUTPUT.PUT_LINE('	') ;
  DBMS_OUTPUT.PUT_LINE('언어 목록') ;
  DBMS_OUTPUT.PUT_LINE('===========') ;
	FOR i IN v_lang.FIRST .. v_lang.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(i) || ' : ' ||v_lang(i));
	END LOOP;
END;

--===============================================================
-- /* Example 11-8 BULK COLLECT는 여러 건의 SELECT 결과를 VARRAY 변수에 넣는다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM BULK COLLECT를 사용하면 여러 건의 SELECT 결과를 VARRAY 변수에 넣을 수 있다.

DECLARE
	TYPE string_array IS VARRAY(20) OF VARCHAR2(100);
	v_arr string_array;
BEGIN
	-- 테이블 emp의 모든 로우의 ename을 VARRAY 컬렉션에 한 번에 적재한다.
	SELECT ename
		BULK COLLECT INTO v_arr
		FROM emp
	 WHERE ROWNUM <= 20;
  FOR i IN v_arr.FIRST .. v_arr.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(i ||'. '|| v_arr(i)) ;
  END LOOP;
	DBMS_OUTPUT.PUT_LINE('VARRAY 컬렉션 건수 = '||v_arr.COUNT) ;
END;

--===============================================================
-- /* Example 11-9 할당되지 않은 VARRAY 항목은 참조할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 할당되지 않은 VARRAY 항목은 참조할 수 없다.
DECLARE
	TYPE string_array IS VARRAY(5) OF VARCHAR2(100) ;
	v_arr string_array ;
BEGIN
	v_arr := string_array() ;
	v_arr.EXTEND(3) ;
	v_arr(1) := '사과' ; -- 정상 실행
	v_arr(2) := '배'   ; -- 정상 실행
	v_arr(3) := '망고' ; -- 정상 실행
	v_arr(4) := '수박' ; -- 할당되지 않은 항목을 참조하므로 오류 발생
END ;

--===============================================================
-- /* Example 11-10 Nested Table 컬렉션의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM Nested Table 컬렉션의 사용
DECLARE
  -- 정수를 인덱스로 하는 Nested Table
	TYPE city IS TABLE OF VARCHAR2(64);
	-- 빈 컬렉션 변수 선언
	v_city 		city;

	-- 컬렉션 변수 선언과 동시에 컬렉션 생성자를 사용하여 값을 초기화
	v_city2 	city := city('서울','부산','대전');
BEGIN
	-- 실행중에도 컬렉션 생성자를 사용하여 초기화 가능
	v_city('서울','부산','대전','광주','인천');

	v_city := city();		-- 크기 0(Empty 컬렉션)으로 초기화
	-- 크기를 증가시키고 값을 지정한다.
	v_city.EXTEND ; v_city(1) := '서울' ;
	v_city.EXTEND ; v_city(2) := '부산' ;
	v_city.EXTEND ; v_city(3) := '대구' ;
	v_city.EXTEND ; v_city(4) := '광주' ;
	DBMS_OUTPUT. PUT_LINE('도시 개수 : ' ||v_city.COUNT||'개') ;

	-- 유효한 컬렉션 값을 출력
  FOR i in v_city.FIRST .. v_city.LAST
  LOOP
    IF v_city.EXISTS(i) THEN
      DBMS_OUTPUT.PUT_LINE(CHR(9)||'v_city(' || TO_CHAR(i) || ') : ' ||v_city(i)) ;
    END IF ;
  END LOOP ;

  -- 3번 인덱스를 삭제한다. 삭제된 인덱스의 항목은 더 이상 접근이 불가능하다.
  v_city.DELETE(3) ;
  DBMS_OUTPUT. PUT_LINE('도시 개수 : ' ||v_city.COUNT||'개') ;

  -- 유효한 컬렉션 값을 출력
  FOR i in v_city.FIRST .. v_city.LAST
  LOOP
    IF v_city.EXISTS(i) THEN
      DBMS_OUTPUT.PUT_LINE(CHR(9)||'v_city(' || TO_CHAR(i) || ') : ' ||v_city(i)) ;
    END IF ;
  END LOOP ;
END ;
