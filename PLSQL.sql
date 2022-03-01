--===============================================================
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
		- 초기화하지 않고 사용 가능하며 생성자가 존재하지도 않는다.
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
		- 순서가 고정되어 있지 않고, 크기도 고정되지 않은 데이터의 집합을 저장하는데 적합한 컬렉션이다
		- 개수가 확정되지 않거나, 인덱스가 연속적이지 않거나, 컬렉션의 일부 항목을 삭제 또는 변경할 필요가 있는 경우에 유용함
		- VARRAY 인덱스는 1부터 시작하는 자연수 값이며, 초기화되지 않은 변수는 NULL 이다
		- Set

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
-- 위와 동일한 구문
CREATE OR REPLACE TYPE cities AS TABLE OF VARCHAR2(64)

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
  FOR i IN v_arr.FIRST..v_arr.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE('ename' || i || '= '||v_arr(i));
  END LOOP;
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
/*
많이 쓰이는 CHR 함수의미  정리

CHR(9)      탭문자
CHR(10)     라인피드        <- 줄바꾸기
CHR(13)     캐리지리턴     <- 행의 처음으로
CHR(38)     &
CHR(39)     '                   <- 싱글따옴표
CHR(44)     ,                   <- 쉼표
*/
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
	v_city := city('서울','부산','대전','광주','인천');

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

--===============================================================
-- /* Example 11-11 DELETE 메소드를 사용하여 삭제한 Nested Table 항목은 참조할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM DELETE 메소드를 사용하여 삭제한 Nested Table 항목은 참조할 수 없다.
DECLARE
  -- 정수를 인덱스로 하는 Associative Array
  TYPE city IS TABLE OF VARCHAR2(64) ;

  -- 컬렉션 변수 선언과 동시에 컬렉션 생성자를 사용하여 값을 초기화
  v_city      city := city('서울', '부산', '대전', '광주', '인천') ;
BEGIN
  -- 3번 인덱스를 삭제한다. 삭제된 인덱스의 항목은 더 이상 접근이 불가능하다.
  v_city.DELETE(3) ;
  -- 다음 문장은 존재하지 않는 3번 항목을 참조하므로 오류를 일으킨다.
  DBMS_OUTPUT.PUT_LINE('v_city(' || TO_CHAR(3) || ') : ' ||v_city(3)) ;
END ;

--===============================================================
-- /* Example 11-12 BULK COLLECT는 여러 건의 SELECT 결과를 Nested Table 변수에 넣는다.SQL */
--===============================================================
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

--===============================================================
-- /* Example 11-13 컬렉션 생성자.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 컬렉션 생성자
DECLARE
  TYPE string_array IS TABLE OF VARCHAR2(100) ;
  v_arr1 string_array := string_array() ; -- 변수 선언 시 빈 컬렉션으로 초기화
  v_arr2 string_array ;
BEGIN
  -- 실행 시 네 개의 항목을 가지는 컬렉션으로 초기화
  v_arr2 := string_array('사과', '수박', '망고', '배') ;
  DBMS_OUTPUT.PUT_LINE('v_arr1.COUNT = '||v_arr1.COUNT) ;
  DBMS_OUTPUT.PUT_LINE('v_arr2.COUNT = '||v_arr2.COUNT) ;
END ;

--===============================================================
-- /* Example 11-14 동일 타입의 컬렉션 변수 간에는 할당 연산자를 사용하여 데이터 복사가 가능하다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 동일 타입의 컬렉션 변수 간에는 할당 연산자를 사용하여 데이터 복사가 가능하다
DECLARE
  TYPE string_array IS TABLE OF VARCHAR2(100) ;
  v_arr1 string_array ;
  v_arr2 string_array ;

  PROCEDURE p_print_collection_count(a_title VARCHAR2, a_coll string_array)
  IS
  BEGIN
    IF a_coll IS NULL THEN
      DBMS_OUTPUT.PUT_LINE(a_title || ': ' || '컬렉션이 NULL입니다.') ;
    ELSE
      DBMS_OUTPUT.PUT_LINE(a_title || ': ' || '컬렉션 항목이 ' || a_coll.COUNT || '건입니다.') ;
    END IF ;
  END ;
BEGIN
  v_arr1 := string_array('사과', '수박', '망고', '배') ;
  v_arr2 := v_arr1 ;  -- 컬렉션 변수 간의 할당 연산을 통한 복사
  p_print_collection_count('1. v_arr1', v_arr1) ;
  p_print_collection_count('2. v_arr2', v_arr2) ;

  -- NULL 할당
  v_arr2 := null ;
  p_print_collection_count('3. v_arr2', v_arr2) ;
END ;

--===============================================================
-- /* Example 11-15 구조가 동일하더라도 타입명이 다르면 할당 연산이 불가능하다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 구조가 동일하더라도 타입명이 다르면 할당 연산이 불가능하다.
DECLARE
  TYPE string_array1 IS TABLE OF VARCHAR2(100) ;
  TYPE string_array2 IS TABLE OF VARCHAR2(100) ;
  v_arr1 string_array1 := string_array1('사과', '수박', '망고') ;
  v_arr2 string_array2 ;
BEGIN
  v_arr2 := v_arr1 ;  -- 동일 구조이지만 타입명이 다르므로 할당 연산이 불가능하다
END ;

--===============================================================
-- /* Example 11-16 컬렉션과 NULL의 비교.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 컬렉션과 NULL의 비교
-- VARRAY, Nested Table은 IS NULL 연산을 지원한다.
DECLARE
  TYPE string_array IS TABLE OF VARCHAR2(100) ;
  v_arr1 string_array := string_array('사과', '수박', '망고', '배') ;
  v_arr2 string_array ;
BEGIN
  IF v_arr1 IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_arr1 IS NULL') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_arr1 IS NOT NULL') ;
  END IF ;
  IF v_arr2 IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_arr2 IS NOT NULL') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_arr2 IS NULL') ;
  END IF ;
END ;

--===============================================================
-- /* Example 11-17 컬렉션 간의 동치 혹은 부등 비교.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 컬렉션 간의 동치 혹은 부등 비교
DECLARE
  TYPE string_array IS TABLE OF VARCHAR2(100) ;
  v_arr1 string_array := string_array('사과', '수박', '망고', '배') ;
  v_arr2 string_array := string_array('사과', '수박', '망고', '배') ;
  v_arr3 string_array := string_array('사과', '수박' ) ;
BEGIN
  IF v_arr1 = v_arr2 THEN
    DBMS_OUTPUT.PUT_LINE('v_arr1 =  v_arr2') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_arr1 <> v_arr2') ;
  END IF ;
  IF v_arr1 = v_arr3 THEN
    DBMS_OUTPUT.PUT_LINE('v_arr1 =  v_arr3') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_arr1 <> v_arr3') ;
  END IF ;
  IF v_arr1 <> v_arr3 THEN
    DBMS_OUTPUT.PUT_LINE('v_arr1 <> v_arr3') ;
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_arr1 =  v_arr3') ;
  END IF ;
END ;

--===============================================================
-- /* Example 11-18 다차원 컬렉션.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 다차원 컬렉션을 지원하지는 않지만 유사하게 사용할 수는 있다.
DECLARE
  TYPE arr_1d_type IS TABLE OF VARCHAR2(100);  -- Nested Table
  v_arr1_1 arr_1d_type := arr_1d_type('사과', '배');             -- 초기화
  v_arr1_2 arr_1d_type := arr_1d_type('오렌지', '자몽', '망고'); -- 초기화
  v_arr1_3 arr_1d_type := arr_1d_type('포도', '앵두');           -- 초기화

  TYPE arr_2d_type IS TABLE OF arr_1d_type;    -- 2차원 Nested Table 타입 선언
  v_arr2 arr_2d_type := arr_2d_type(v_arr1_1, v_arr1_2); -- 2차원 컬렉션 초기화(1차원 컬렉션 사용)

BEGIN
  v_arr2.EXTEND;
  v_arr2(3) := v_arr1_3;
  DBMS_OUTPUT.PUT_LINE('v_arr2(2)(3) = '||v_arr2(2)(3)); -- 다차원 배열의 항목 참조
END;

--===============================================================
-- /* Example 11-19 LIMIT 키워드 없이 전체 건 조회 또는 ROWNUM을 사용하여 SELECT 건수 제한.SQL */
--===============================================================
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

--===============================================================
-- /* Example 11-20 LIMIT 키워드 없이 SAMPLE 사용하여 SELECT 건수 제한.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM LIMIT 키워드를 사용하지 않는 경우
REM SAMPLE 또는 FETCH FIRST를 사용
REM FETCH FIRST는 버전 12c 이상에서만 지원되며, 11.2까지는 지원되지 않는다.
DECLARE
  TYPE emp_tab_type IS TABLE OF emp%ROWTYPE ;
  v_emp emp_tab_type ;
BEGIN
  -- SAMPLE절을 사용하여 건수 제한
  -- SAMPLE 뒤의 숫자 10은 건수가 아니라 퍼센트(%)를 지정하는 숫자다.
  -- 정확히 10%를 조회하는 것이 아니라 10%에 해당되는 건수를 추정하는 방법을 사용하므로
  -- 실제로 조회되는 결과 건수는 매 실행시 마다 달라질 수 있다.
  SELECT *
    BULK COLLECT INTO v_emp
    FROM emp SAMPLE (10) ;  -- 10%를 샘플링하여 조회한다.
  DBMS_OUTPUT.PUT_LINE('SAMPLE 건수: '||v_emp.COUNT) ;
END ;

--===============================================================
-- /* Example 11-21 LIMIT 절을 사용하여 SELECT 건수 제한.SQL */
--===============================================================
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

--===============================================================
-- /* Example 11-22 11-22.DML 문에서의 배열 처리.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DROP TABLE t ;

REM 예제를 위한 테이블 생성
CREATE TABLE t (
  id   INTEGER PRIMARY KEY,
  name VARCHAR(100)
) ;

PAUSE

REM DML에서 배열 처리에 FOR ALL의 사용
DECLARE
  TYPE id_arr_type   IS TABLE OF PLS_INTEGER ;
  TYPE name_arr_type IS TABLE OF t.name%TYPE ;
  v_id_arr    id_arr_type   := id_arr_type(1,2,3,4,5) ;
  v_name_arr  name_arr_type := name_arr_type('이순신', '강감찬', '을지문덕', '계백', '김유신') ;
  v_name_arr2 name_arr_type := name_arr_type('강희안', '김홍도', '신윤복', '정선', '장승업') ;
BEGIN
  DELETE FROM t ;

  -- INSERT문에서의 배열 처리. ".."을 사용하여 범위 지정
	FORALL i IN v_id_arr.FIRST .. v_id_arr.LAST
		INSERT INTO t(id, name) VALUES(v_id_arr(i), v_name_arr(i));
	DBMS_OUTPUT.PUT_LINE('INSERT COUNT = ' || SQL%ROWCOUNT);

  -- UPDATE문에서의 배열 처리. INDICES OF를 사용하여 범위 지정
	FORALL i IN INDICES OF v_id_arr
		UPDATE t
			 SET name = v_arr_name(i)
		 WHERE ID = v_id_arr(i);
	DBMS_OUTPUT.PUT_LINE('UPDATE COUNT = ' || SQL%ROWCOUNT);

	-- MERGE문에서의 배열 처리. ".."을 사용하여 범위 지정
   FORALL i IN v_id_arr.FIRST .. v_id_arr.LAST  -- ".."을 이용한 범위 지정
     MERGE INTO t
     USING (
       SELECT id
       FROM t
       WHERE id = v_id_arr(i)) u
     ON (t.id = u.id)
     WHEN MATCHED THEN
       UPDATE SET t.name = v_name_arr2(i)
     WHEN NOT MATCHED THEN
       INSERT (id, name)
       VALUES (v_id_arr(i), v_name_arr2(i));
   DBMS_OUTPUT.PUT_LINE('MERGE  COUNT = '||SQL%ROWCOUNT) ;

   -- DELETE문에서의 배열 처리. VALUES OF를 사용하여 범위 지정
   FORALL i IN VALUES OF v_id_arr  -- VALUES OF 를 이용한 범위 지정
     DELETE FROM t WHERE id = v_id_arr(i) ;
   DBMS_OUTPUT.PUT_LINE('DELETE COUNT = '||SQL%ROWCOUNT) ;
 END ;

--===============================================================
-- /* Example 11-23 FORALL 문에 EXCEPTION 미포함 시는 오류를 만나면 전체가 ROLLBACK 된다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON
REM EXCEPTION 미포함시는 오류를 만나면 전체가 ROLLBACK된다.
REM 예제에서는 PK 칼럼 id에 3이 2건이 중복되어 오류가 발생하고 전체가 ROLLBACK된다.

DECLARE
	TYPE ID_ARR_TYPE IS TABLE OF PLS_INTEGER ;
	v_id_arr ID_ARR_TYPE := ID_ARR_TYPE(1,2,3,3,5) ; -- 중복 키 값(3이 두 개) 포함
BEGIN
	DELETE FROM t ;
	COMMIT ;
	-- INSERT 문의 배열 처리
	FORALL i IN v_id_arr.FIRST .. v_id_arr.LAST
	INSERT INTO T VALUES( v_id_arr(i), v_id_arr(i)) ;
END ;
/
PAUSE
SELECT COUNT(*) FROM t ;

--===============================================================
-- /* Example 11-24 FORALL 문에 EXCEPTION 포함시는 오류를 만나기 전까지는 정상으로 처리한다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXCEPTION 포함시는 오류를 만나기 전까지는 정상으로 처리한다.
REM 예제에서는 (1,2,3,3,5) 중에서 처음 세 건은 정상 INSERT 된다.
DECLARE
 TYPE ID_ARR_TYPE IS TABLE OF PLS_INTEGER ;
 v_id_arr ID_ARR_TYPE := ID_ARR_TYPE(1,2,3,3,5) ;
BEGIN
 -- INSERT문의 배열 처리
 FORALL i IN v_id_arr.FIRST .. v_id_arr.LAST
   INSERT INTO T VALUES( v_id_arr(i), v_id_arr(i)) ;
 EXCEPTION WHEN OTHERS THEN

END ;
/

PAUSE

SELECT COUNT(*) FROM t ;

--===============================================================
-- /* Example 12-1 레코드의 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 기본 예제
DECLARE
  TYPE emp_type IS RECORD ( -- 세 개의 필드를 가지는 레코드 선언
    empno  NUMBER(4) NOT NULL := 0, -- NOT NULL 필드는 반드시 초깃값을 지정해야 함
    ename  emp.ename%TYPE,          -- 칼럼 앵커를 사용한 필드 선언
    job    VARCHAR2(9)              -- 필드의 데이터 타입을 직접 지정
  ) ;
  v_emp emp_type ;                 -- 타입을 사용하여 변수(인스턴스) 선언
BEGIN
  -- 레코드의 필드에 값을 할당
  v_emp.empno := 9000 ;
  v_emp.ename := '홍길동' ;
  v_emp.job   := '의적' ;

  DBMS_OUTPUT.PUT_LINE('EMPNO = ' || v_emp.empno) ;
  DBMS_OUTPUT.PUT_LINE('ENAME = ' || v_emp.ename) ;
  DBMS_OUTPUT.PUT_LINE('JOB   = ' || v_emp.job  ) ;
END ;

--===============================================================
-- /* Example 12-2 로우 앵커를 사용한 레코드 변수 선언.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 로우 앵커를 사용하여 재작성
DECLARE
  v_emp emp%ROWTYPE ; -- 로우 앵커를 사용한 레코드 변수 선언
BEGIN
  -- 레코드의 필드에 값을 할당
  v_emp.empno := 9000 ;
  v_emp.ename := '홍길동' ;
  v_emp.job   := '의적' ;

  DBMS_OUTPUT.PUT_LINE('EMPNO = ' || v_emp.empno) ;
  DBMS_OUTPUT.PUT_LINE('ENAME = ' || v_emp.ename) ;
  DBMS_OUTPUT.PUT_LINE('JOB   = ' || v_emp.job  ) ;
END ;

--===============================================================
-- /* Example 12-3 SELECT 문에 레코드 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 기본 예제
DECLARE
  TYPE emp_type IS RECORD (
    empno  NUMBER(4) NOT NULL := 0, -- NOT NULL 필드는 반드시 초깃값을 지정해야 함
    ename  emp.ename%TYPE,          -- 칼럼 앵커를 사용한 필드 선언
    job    VARCHAR2(9)              -- 필드의 데이터 타입을 직접 지정
  ) ;
  v_emp emp_type ;
BEGIN
  -- INTO절에 세 개의 필드를 지정하는 대신 레코드 변수를 지정할 수 있다.
  SELECT empno, ename, job
    INTO v_emp
    --INTO v_emp.empno, v_emp.ename, v_emp.job  -- 세 개의 변수를 윗줄의 레코드 하나로 대체
    FROM emp
   WHERE empno = 7788 ;

  DBMS_OUTPUT.PUT_LINE('EMPNO = ' || v_emp.empno) ;
  DBMS_OUTPUT.PUT_LINE('ENAME = ' || v_emp.ename) ;
  DBMS_OUTPUT.PUT_LINE('JOB   = ' || v_emp.job  ) ;
END ;

--===============================================================
-- /* Example 12-4 레코드의 필드명과 SELECT 되는 테이블의 칼럼명과는 일치하지 않아도 된다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레코드의 필드명과 SELECT 되는 테이블의 칼럼명과는 일치하지 않아도 된다.
DECLARE
  TYPE emp_type IS RECORD (
    emp_no    NUMBER(4),      -- empno 대신 emp_no 사용
    emp_name  emp.ename%TYPE, -- ename 대신 emp_name 사용
    job       VARCHAR2(10)    -- 데이터 타입과 길이는 호환성만 있으면 된다.
  ) ;
  v_emp emp_type ;
BEGIN
  -- SELECT되는 칼럼명과 이 값을 할당할 레코드 필드명이 같지 않아도 전혀 문제가 없다.
  SELECT empno, ename, job
    INTO v_emp
    FROM emp
   WHERE empno = 7788 ;

  DBMS_OUTPUT.PUT_LINE('EMPNO = ' || v_emp.emp_no) ;
  DBMS_OUTPUT.PUT_LINE('ENAME = ' || v_emp.emp_name) ;
  DBMS_OUTPUT.PUT_LINE('JOB   = ' || v_emp.job) ;
END ;

--===============================================================
-- /* Example 12-5 레코드 변수는 하나만 사용 가능하며, 다른 변수와 같이 사용할 수 없다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레코드 변수는 하나만 사용 가능하며, 다른 변수와 같이 사용할 수 없다.
DECLARE
  -- 테이블 emp의 일부 칼럼을 레코드로 선언
  TYPE emp_basic_info_type IS RECORD (
    empno    emp.empno   %TYPE,
    ename    emp.ename   %TYPE,
    job      emp.job     %TYPE,
    mgr      emp.mgr     %TYPE,
    hiredate emp.hiredate%TYPE,
    deptno   emp.deptno  %TYPE
  ) ;
  -- 테이블 emp의 나머지 칼럼을 레코드로 선언
  TYPE emp_salary_info_type IS RECORD (
    sal      emp.sal     %TYPE,
    comm     emp.comm    %TYPE
  ) ;

  -- 레코드 변수
  v_emp_basic  emp_basic_info_type ;
  v_emp_salary emp_salary_info_type ;

  -- 개별 스칼라 변수
  v_sal    emp.sal     %TYPE ;
  v_comm   emp.comm    %TYPE ;
BEGIN
  -- 두 개의 레코드 변수를 INTO절에 사용할 수는 없다.
  -- 파싱 단계에서 다음의 오류가 발생한다.
  -- PLS-00494: coercion into multiple record targets not supported
  SELECT empno, ename, job, mgr, hiredate, deptno, sal, comm
    INTO v_emp_basic, v_emp_salary
    FROM emp
   WHERE empno = 7788 ;

  -- 레코드 변수와 스칼라 변수를 혼합하여 INTO절에 사용할 수도 없다.
  -- 파싱 단계에서 다음의 오류가 발생한다.
  -- PLS-00494: coercion into multiple record targets not supported
  SELECT empno, ename, job, mgr, hiredate, deptno, sal, comm
    INTO v_emp_basic, v_sal, v_comm
    FROM emp
   WHERE empno = 7788 ;
END ;

--===============================================================
-- /* Example 12-6 레코드 변수의 각 필드에 값을 할당하는 방법.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 기본 예제
REM 레코드 변수의 필드는 필드별로 값을 할당해야 한다.
DECLARE
  TYPE emp_rec IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );

  v_emp1 emp_rec;
  v_emp2 emp_rec;
  v_emp3 emp_rec;
BEGIN
  v_emp1.empno := 9000 ; v_emp1.ename := '홍길동'; -- 1. 필드별로 값을 할당
  v_emp2 := v_emp1;                                -- 2. 다른 레코드를 복사
  SELECT empno, ename INTO v_emp3                  -- 3. 쿼리 결과를 레코드에 저장
    FROM emp
   WHERE empno = 7788;
END;

--===============================================================
-- /* Example 12-07.필드가 동일하더라도 타입명이 다른 레코드 간에는 할당 연산이 불가능하다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 필드가 동일하더라도 타입명이 다른 레코드 간에는 할당 연산이 불가능하다.
REM 다음 예제에서 emp_rec1과 emp_rec2는 다른 타입이므로
REM 할당 연산을 사용할 수 없다.
DECLARE
  TYPE emp_rec1 IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );
  TYPE emp_rec2 IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );

  v_emp1 emp_rec1;
  v_emp2 emp_rec2;
BEGIN
  v_emp1 := v_emp2 ; -- 필드의 데이터 타입이 동일해도 레코드 타입이 다르므로 오류
END;

--===============================================================
-- /* Example 12-08.레코드의 모든 필드를 한 번에 초기화하기 위해 사용자 정의 함수를 사용할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레코드의 모든 필드를 한 번에 초기화 하는 기능은 기본으로 제공되지 않는다.
REM 필요하면 유사한 기능을 가지는 함수를 만들어 사용해야 한다.
DECLARE
  TYPE emp_rec IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );

  v_emp emp_rec;

  -- 생성자 역할을 하는 함수를 만든다.
  FUNCTION make_emp_rec(a_empno emp.empno%TYPE,
                        a_ename emp.ename%TYPE) RETURN emp_rec
  IS
    v_rec emp_rec ;
  BEGIN
    v_rec.empno := a_empno ;
    v_rec.ename := a_ename ;
    RETURN v_rec ;
  END ;

BEGIN
  v_emp := make_emp_rec('9000', '홍길동') ; -- 생성자 역할의 함수를 사용한다.
END;

--===============================================================
-- /* Example 12-09.레코드와 컬렉션의 동시 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 레코드와 컬렉션을 혼합하여 동시에 사용하는 예제
DECLARE
  TYPE city_tab_type IS TABLE OF VARCHAR2(64) INDEX BY PLS_INTEGER ; -- 컬렉션
  TYPE name_rec IS RECORD (                                      -- 레코드
    first_name  VARCHAR2(30),
    last_name   VARCHAR2(30)
  ) ;
  TYPE emp_rec IS RECORD (                                       -- 컬렉션과 레코드의 혼합
    empno emp.empno%TYPE DEFAULT 1000,
    ename name_rec,      -- 레코드가 레코드의 필드가 될 수 있다.
    city  city_tab_type  -- 컬렉션이 레코드의 필드가 될 수 있다.
  );
  TYPE people_type IS VARRAY(10) OF name_rec ; -- 레코드의 컬렉션이 가능하다.
  TYPE emp_type    IS VARRAY(10) OF emp_rec  ; -- 레코드의 컬렉션
BEGIN
  NULL ;
END;

--===============================================================
-- /* Example 13-01.묵시적 커서.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_name emp.ename%TYPE ;
BEGIN
  -- 묵시적 커서­
  SELECT ename
    INTO v_name
    FROM emp
   WHERE empno = 7788 ;

  DBMS_OUTPUT.PUT_LINE('ENAME = '||v_name) ;
END ;

--===============================================================
-- /* Example 13-02.명시적 커서.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_name emp.ename%TYPE ;

	-- 명시적 커서를 선언
	CURSOR ename_cursor IS
		SELECT ENAME
			FROM EMP
		 WHERE EMPNO = 7788;
BEGIN
	-- 커서를 OPEN 한다.
  OPEN ename_cursor;

	-- SELECT 결과를 FETCH한다.
	FETCH ename_cursor
	 INTO v_name;
  DBMS_OUTPUT.PUT_LINE('ENAME = '||v_name) ;

	-- 커서를 CLOSE한다.
	CLOSE ename_cursor;
END ;

--===============================================================
-- /* Example 13-03.루프 문을 사용하여 여러 건을 FETCH.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_empno NUMBER;
	v_ename emp.ename%TYPE;

	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp
		 ORDER BY empno;
BEGIN
	OPEN ename_cursor;

	LOOP
		FETCH ename_cursor INTO v_empno, v_ename;
		EXIT WHEN ename_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_empno ||', ename = ' || v_ename);
	END LOOP;

	CLOSE ename_cursor;
END;

--===============================================================
-- /* Example 13-04.BULK COLLECT를 사용하여 여러 건을 한 번에 FETCH.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	TYPE empno_arr IS TABLE OF NUMBER;
	TYPE ename_arr IS TABLE OF emp.ename%TYPE;

	v_empno empno_arr;
	v_ename ename_arr;

	-- 명시적 커서
	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp;
BEGIN
	-- 커서 OPEN
	OPEN ename_cursor;

	FETCH ename_cursor BULK COLLECT INTO v_empno, v_ename;
	DBMS_OUTPUT.PUT_LINE('사원 수 = '|| v_ename.COUNT);

	FOR i IN v_empno.FIRST..v_empno.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_empno(i) ||', ename = ' || v_ename(i));
	END LOOP;
	CLOSE ename_cursor;
END;

--===============================================================
-- /* Example 13-05.커서에 대한 ROWTYPE 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	CURSOR ename_cursor IS
		SELECT empno, ename
			FROM emp;
	v_emprec ename_cursor%ROWTYPE;
BEGIN
	OPEN ename_cursor;

	LOOP
		FETCH ename_cursor INTO v_emprec;
		EXIT WHEN ename_cursor%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('empno = '|| v_emprec.empno ||', ename = ' || v_emprec.ename);
	END LOOP;

	CLOSE ename_cursor;
END;

--===============================================================
-- /* Example 13-06.커서 FOR LOOP를 사용한 테이블 데이터 복제.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM emp와 동일한 구조의 테이블 emp2 생성
DROP TABLE emp2 ;
CREATE TABLE emp2 AS SELECT * FROM EMP WHERE ROWNUM = 0 ;

PAUSE

REM emp2는 현재 빈 테이블이다.
SELECT COUNT(*) FROM emp2;

PAUSE

REM 커서 FOR LOOP를 사용한 테이블 데이터 복제
BEGIN
  FOR c IN (SELECT * FROM emp)  -- 커서 FOR LOOP를 사용하여 테이블 복사
  LOOP
    INSERT INTO emp2 VALUES c ;
  END LOOP ;
END ;
/

PAUSE

REM 테이블 emp의 모든 로우를 emp2로 복사해서 14건이 되었다.
SELECT COUNT(*) FROM emp2;

--===============================================================
-- /* Example 13-07.묵시적 커서 FOR LOOP.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_total_pay NUMBER := 0;  -- 급여 합계 계산
BEGIN
	-- 묵시적 커서 FOR LOOP 사용
	FOR t IN (
		SELECT ename, hiredate, deptno, NVL(sal,0)+NVL(comm,0) total_pay
			FROM emp
		 WHERE deptno = 10
	)
	LOOP
		DBMS_OUTPUT.PUT_LINE(
			RPAD(t.ename, 6, ' ') || ', 입사일자=' || TO_CHAR(t.hiredate, 'YYYY-MM-DD') || ', 급여=' || t.total_pay
		);
		v_total_pay := v_total_pay + NVL(t.total_pay, 0);
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('-------------------------------------');
	DBMS_OUTPUT.PUT_LINE('급여 합계 = $' || v_total_pay);
END;

--===============================================================
-- /* Example 13-08.커서 FOR LOOP 미사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM SELECT 문의 결과 저장을 위한 일반적인 변수 선언 방법
REM 변수를 선언하고 사용해야 하는 불편함이 있고,
REM 프로그램의 길이가 길어진다.
DECLARE
  v_ename     emp.ename   %TYPE ;
  v_hiredate  emp.hiredate%TYPE ;
  v_deptno    emp.ename   %TYPE ;
  v_sal       emp.sal     %TYPE ;
BEGIN
  BEGIN
    SELECT ename,
           hiredate,
           deptno,
           sal
      INTO v_ename,
           v_hiredate,
           v_deptno,
           v_sal
      FROM emp
     WHERE empno = 7788 ;
    DBMS_OUTPUT.PUT_LINE(v_ename   ||', '||
                         v_hiredate||', '||
                         v_deptno  ||', '||
                         v_sal) ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL ;
  END ;
END ;

--===============================================================
-- /* Example 13-09.커서 FOR LOOP 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 명백히 한 건만을 조회하는 경우라도
REM 프로그램을 간단히 하기 위해 FOR LOOP 사용
BEGIN
  FOR t IN (SELECT ename,
                   hiredate,
                   deptno,
                   sal
              FROM emp
             WHERE empno = 7788)
  LOOP
    DBMS_OUTPUT.PUT_LINE(t.ename   ||', '||
                         t.hiredate||', '||
                         t.deptno  ||', '||
                         t.sal) ;
  END LOOP ;
END ;

--===============================================================
-- /* Example 13-10.명시적 커서 FOR LOOP.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_total_pay NUMBER := 0;  -- 급여 합계 계산
	-- 앞의 예제에서 FOR문에 포함되었던 SELECT문을 커서 문으로 선언하여 사용
	CURSOR emp_cursor IS
	-- CURSOR FOR LOOP 에 사용된 컬럼에 계산식이 있는 경우 꼭 Alias를 사용해야함.
	SELECT ename, hiredate, deptno, NVL(sal,0)+NVL(comm,0) total_pay
		FROM emp
	 WHERE deptno = 10;
BEGIN
	-- "(SELECT문)" 대신 위에서 선언한 커서명 emp_cursor를 사용
	FOR t IN emp_cursor
	LOOP
		DBMS_OUTPUT.PUT_LINE(
			RPAD(t.ename, 6, ' ') || ', 입사일자=' || TO_CHAR(t.hiredate, 'YYYY-MM-DD') || ', 급여=' || t.total_pay
		);
		v_total_pay := v_total_pay + NVL(t.total_pay, 0);
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('-------------------------------------');
	DBMS_OUTPUT.PUT_LINE('급여 합계 = $' || v_total_pay);
END;

--===============================================================
-- /* Example 13-11.명시적 커서 속성.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 명시적 커서 속성
DECLARE
  CURSOR emp_cursor IS
    SELECT ename, hiredate
      FROM emp
     WHERE deptno = 10
     ORDER BY hiredate desc;
BEGIN
  FOR t IN emp_cursor
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(t.ename, 6,' ')||
      ', 입사 일자='|| TO_CHAR(t.hiredate, 'YYYY-MM-DD')) ;
    IF emp_cursor%ROWCOUNT >= 3 THEN -- 명시적 커서 속성 커서명%ROWCOUNT
      EXIT ; -- 3건 이상인 경우 루프 종료하라는 의미
    END IF ;
  END LOOP ;
END ;

--===============================================================
-- /* Example 13-12.묵시적 커서 속성.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 묵시적 커서 속성
DECLARE
  v_rows PLS_INTEGER ;
BEGIN
  DELETE FROM emp WHERE empno = 7788 ;
  v_rows := SQL%ROWCOUNT ; -- 묵시적 커서 속성 SQL%ROWCOUNT
  DBMS_OUTPUT.PUT_LINE('삭제된 건수='||v_rows) ;
  ROLLBACK ;
END ;

--===============================================================
-- /* Example 13-13.커서 칼럼의 앨리어스 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 커서의 칼럼이 표현식인데 앵커로 참조된다면
REM 표현식 칼럼은 반드시 앨리어스를 사용해야 한다.
DECLARE
  -- 명시적 커서
  CURSOR emp_cursor IS
   SELECT empno           사번
        , ename           이름
        , sal+NVL(comm,0) 총급여 -- 앵커로 참조되는 칼럼이 표현식이라면 앨리어스가 필요
     FROM emp ;
  v_emp_rec emp_cursor%ROWTYPE ;
BEGIN
  OPEN emp_cursor ;

  DBMS_OUTPUT.PUT_LINE('사번 이름       총급여') ;
  DBMS_OUTPUT.PUT_LINE('==== ========== ======') ;
  LOOP
    FETCH emp_cursor INTO v_emp_rec ;
    EXIT WHEN emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(' ' ||TO_CHAR(v_emp_rec.사번, '9999') || ' ' ||
                         RPAD(v_emp_rec.이름, 10) || ' ' ||
                         TO_CHAR(v_emp_rec.총급여, '99999')) ;
  END LOOP;

  -- 커서를 CLOSE한다.
  CLOSE emp_cursor ;
END ;

--===============================================================
-- /* Example 13-14.커서를 매개변수로 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_name	emp.ename%TYPE;
	v_empno NUMBER := 7788;

	-- 매개변수 a_empno를 가지는 명시적 커서
	CURSOR ename_cursor(a_empno NUMBER) IS
		SELECT ename
			FROM emp
		 WHERE empno = a_empno;
BEGIN
	-- 매개변수를 사용하여 커서를 OPEN한다.
	OPEN ename_cursor(v_empno);

	-- SELECT 결과를 FETCH 한다.
	FETCH ename_cursor
	 INTO v_name;
	DBMS_OUTPUT.PUT_LINE('이름 = ' || v_name);

	CLOSE ename_cursor;
END;

--===============================================================
-- /* Example 13-15.커서 매개변수를 사용하지 않고 글로벌 변수를 사용한 경우.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 커서 매개변수를 사용하지 않고 글로벌 변수를 사용한 경우
REM 모듈화의 두 가지 원칙인 높은 응집도와 낮은 결합도를
REM 정면으로 위배하는 나쁜 코딩 방법의 사례다.
DECLARE
  v_name  emp.ename%TYPE ;
  v_empno NUMBER ;

  -- 매개변수를 가지지 않는 커서
  CURSOR ename_cursor IS
   SELECT ename
     FROM emp
    WHERE empno = v_empno ; -- 매개변수로 상위 블록에 선언된 변수를 사용한다.
BEGIN
  v_empno := 7788 ;

  -- 커서를 OPEN한다. 위에서 설정한 변수 v_empno의 값 7788이 커서 OPEN시에 사용된다.
  OPEN ename_cursor ;

  -- SELECT 결과를 FETCH한다.
  FETCH ename_cursor
   INTO v_name ;
  DBMS_OUTPUT.PUT_LINE('이름 = '||v_name) ;

  -- 커서를 CLOSE한다.
  CLOSE ename_cursor ;
END ;

--===============================================================
-- /* Example 13-16.커서 변수 선언.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 커서 변수 선언
DECLARE
  TYPE empcursor_type     IS REF CURSOR RETURN emp%ROWTYPE;     -- 강한 타입(테이블%ROWTYPE)
  TYPE genericcursor_type IS REF CURSOR;                        -- 약한 타입

  v_c1 empcursor_type;
  v_c2 genericcursor_type;
  v_c3 SYS_REFCURSOR;  -- 타입 선언 없이 사용 가능

  TYPE empcursor_type2 IS REF CURSOR RETURN v_c1%ROWTYPE;       -- 강한 타입(변수%ROWTYPE)
  v_c4 empcursor_type2;

  CURSOR emp_cursor IS
    SELECT empno, ename
      FROM emp ;
  TYPE empcursor_type3 IS REF CURSOR RETURN emp_cursor%ROWTYPE; -- 강한 타입(커서%ROWTYPE)
  v_c5 empcursor_type3;

  TYPE emp_rec IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );
  TYPE empcursor_type4 IS REF CURSOR RETURN emp_rec;            -- 강한 타입(레코드 타입)
  v_c6 empcursor_type4;
BEGIN
  NULL;
END;

--===============================================================
-- /* Example 13-17.강한 타입의 커서 변수는 반환형만 일치하면 어떤 SELECT 문도 OPEN할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 강한 타입의 커서 변수는 반환되는 칼럼의 개수와 타입만 일치하면
REM 어떤 SELECT 문에 대해서도 OPEN 가능하다.
DECLARE
  TYPE emp_rec IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE,
    sal   emp.sal  %TYPE
  );
  v_emprec emp_rec ; -- FETCH 결과를 저장할 레코드 변수
  TYPE     emp_cursor_type IS REF CURSOR RETURN emp_rec; -- 커서 타입
  v_empcur emp_cursor_type;                              -- 커서 변수
BEGIN
  -- 첫 번째 SQL문에 대해 커서 변수를 OPEN
  OPEN v_empcur FOR SELECT empno, ename, sal FROM EMP WHERE deptno = 10 ;
  LOOP
    FETCH v_empcur INTO v_emprec ;
    EXIT WHEN v_empcur%NOTFOUND ;
    DBMS_OUTPUT.PUT_LINE('EMPNO='||v_emprec.empno||', ENAME='||v_emprec.ename||
                         ', SAL='||v_emprec.sal) ;
  END LOOP ;
  CLOSE v_empcur ;

  DBMS_OUTPUT.PUT_LINE(' ') ;

  -- 두 번째 SQL문에 대해 커서 변수를 OPEN
  OPEN v_empcur FOR SELECT empno, ename, sal+NVL(comm,0) FROM EMP WHERE deptno = 20 ;
  LOOP
    FETCH v_empcur INTO v_emprec ;
    EXIT WHEN v_empcur%NOTFOUND ;
    DBMS_OUTPUT.PUT_LINE('EMPNO='||v_emprec.empno||', ENAME='||v_emprec.ename||
                         ', SAL='||v_emprec.sal) ;
  END LOOP ;
  CLOSE v_empcur ;
END;

--===============================================================
-- /* Example 13-18.커서 변수는 서브프로그램의 매개 변수로 사용할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 커서 변수는 서브 프로그램의 매개 변수로 사용할 수 있다.
DECLARE
  TYPE emp_rec IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );
  TYPE     emp_cursor_type IS REF CURSOR RETURN emp_rec; -- 레코드 타입의 커서 변수
  v_empcur emp_cursor_type;                              -- 커서 변수

  PROCEDURE print_emp(a_empcur emp_cursor_type) IS    -- 커서 변수를 프로시저의 매개변수로 사용
    v_emprec emp_rec ;
  BEGIN
    LOOP
      FETCH a_empcur INTO v_emprec ;
      EXIT WHEN a_empcur%NOTFOUND ;
      DBMS_OUTPUT.PUT_LINE('EMPNO=' ||v_emprec.empno||', ENAME=' || v_emprec.ename) ;
    END LOOP ;
  END ;
BEGIN
  OPEN v_empcur FOR SELECT empno, ename FROM EMP ;
  print_emp(v_empcur) ; -- 커서를 매개변수로 전달
  CLOSE v_empcur ;
END;

--===============================================================
-- /* Example 13-19.약한 타입의 커서 변수는 반환형이 서로 다른 쿼리에 대해서도 사용할 수 있다.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_cursor		SYS_REFCURSOR;		-- 약한 타입의 커서 변수
	v_selector	CHAR;
	v_deptno		NUMBER;

	-- a_selector 값에 따라서 서로 다른 개수와 타입을 반환하는 SELECT문을 사용하여 커서를 OPEN
	PROCEDURE open_cursor(a_cursor IN OUT SYS_REFCURSOR, a_selector CHAR, a_deptno NUMBER) IS
	BEGIN
		IF a_selector = 'E' THEN
			OPEN a_cursor FOR SELECT * FROM emp WHERE deptno = a_deptno;
		ELSE
			OPEN a_cursor FOR SELECT * from dept WHERE deptno = a_deptno;
		END IF;
	END;

	-- a_selector 값에 따라서 서로 다른 개수와 타입을 반환하는
	-- 커서 변수에서 서로 다른 칼럼을 추출하여 화면에 출력
	PROCEDURE print_cursor(a_cursor IN OUT SYS_REFCURSOR, a_selector CHAR) IS
		v_emprec		emp%ROWTYPE;
		v_deptrec		dept%ROWTYPE;
	BEGIN
		IF a_selector = 'E' THEN
			LOOP
				FETCH a_cursor INTO v_emprec;
				EXIT WHEN a_cursor%NOTFOUND;
				-- emp 테이블의 네 칼럼을 출력
        DBMS_OUTPUT.PUT_LINE('EMPNO='||v_emprec.empno||', ENAME='||v_emprec.ename||
                             ', JOB='||v_emprec.job  ||', SAL='  ||v_emprec.sal) ;
			END LOOP;
		ELSE
			LOOP
				FETCH a_cursor INTO v_deptrec;
				EXIT WHEN a_cursor%NOTFOUND;
				-- dept 테이블의 세 칼럼을 출력
			 	DBMS_OUTPUT.PUT_LINE('DEPTNO='||v_deptrec.deptno||', DNAME='||v_deptrec.dname||
														 ', LOC=' ||v_deptrec.loc) ;
			END LOOP;
		END IF;
	END;
BEGIN
	-- dept 테이블을 출력하도록 커서를 연다.
	v_selector := 'D';
	v_deptno := 10;

	open_cursor(v_cursor, v_selector, v_deptno);	-- 커서 오픈
	print_cursor(v_cursor, v_selector); -- 커서 출력
	CLOSE v_cursor;

	DBMS_OUTPUT.PUT_LINE('----') ;

	-- emp 테이블을 출력하도록 커서를 다시 연다.
	v_selector := 'E';
	v_deptno := 10;

	open_cursor(v_cursor, v_selector, v_deptno);	-- 커서 오픈
	print_cursor(v_cursor, v_selector); -- 커서 출력
	CLOSE v_cursor;
END;

--===============================================================
-- /* Example 13-20.SELECT FOR UPDATE.SQL */
--===============================================================
/*
SELECT FOR UPDATE :
 - SELECT문과 UPDATE 문의 사이에 시차가 존재하므로 동시에 여러 SQL문이 실행되는 경우
	 한 트랜젝션의 SELECT문과 UPDATE문의 사이에 다른 트랜젝션이 실행될 수 있어서 데이터의 무결성이 깨지는 문제 발생할 수 있음
 - SELECT문과 UPDATE문을 하나로 만들어 줄 수 있다면 무결성을 보장할 수 있다.
 - 이 것이 SELECT FOR UPDATE문이다.
 - 조회 대상 로우에 대해 SELECT와 동시에 락을 거는 방식으로 동작하여 SELECT문과 UPDATE문 사이에
   다른 데이터 변경 거래가 끼어들 수 없도록 원천적으로 차단한다.
 - 단점으로는 SELECT만 하고 UPDATE를 하지 않는 로우에 대해서도 락이 걸려서, 커밋이나 롤백이 수행되기 전까지는
   락이 해제되지 않는다는 것이다. 이 때문에 프로그램의 동시성을 떨어뜨리는 부작용을 가지고 있다.
*/
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	CURSOR emp_cursor IS
		SELECT empno, ename, job, sal
			FROM emp
		 WHERE sal < 1500
			 FOR UPDATE; -- 조회와 동시에 락을 건다.
BEGIN
	FOR e IN emp_cursor
	LOOP
		IF e.job = 'SALESMAN' THEN
			UPDATE emp
				 SET comm = comm * 1.1
			 WHERE CURRENT OF emp_cursor; 	-- 현재 커서가 위치한 로우만을 UPDATE 한다.
		END IF;
	END LOOP;
END;

--===============================================================
-- /* Example 14-01.EXECUTE IMMEDIATE를 사용한 DDL, DML, TCL 실행.SQL */
--===============================================================
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

--===============================================================
-- /* Example 14-02.EXECUTE IMMEDIATE 문에서 쿼리 결과를 변수에 저장.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_query CONSTANT VARCHAR2(200) := 'SELECT empno, ename
                                       FROM EMP
                                      WHERE empno = 7788';
  TYPE emp_type IS RECORD (
    empno emp.empno%TYPE,
    ename emp.ename%TYPE
  );
  v_rec     emp_type;       -- 레코드 변수
  v_empno   emp.empno%TYPE; -- 스칼라 변수
  v_ename   emp.ename%TYPE; -- 스칼라 변수

  TYPE emp_arr IS TABLE OF emp_type;
  v_emps emp_arr;           -- 레코드 컬렉션 변수
BEGIN
  -- INTO 스칼라 변수
  EXECUTE IMMEDIATE v_query INTO v_empno, v_ename;
  DBMS_OUTPUT.PUT_LINE(v_empno ||', '|| v_ename);

  -- INTO 레코드 변수
  EXECUTE IMMEDIATE v_query INTO v_rec;
  DBMS_OUTPUT.PUT_LINE(v_rec.empno ||', '|| v_rec.ename);

  -- INTO 레코드 컬렉션 변수
  EXECUTE IMMEDIATE 'SELECT empno, ename FROM emp' BULK COLLECT INTO v_emps;
  DBMS_OUTPUT.PUT_LINE('사원수: '||v_emps.COUNT);
END ;

--===============================================================
-- /* Example 14-03.EXECUTE IMMEDIATE 문에서 바인드 변수 사용.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 바인드 변수 사용
REM 바인드 변수는 USING 절에 나열한다.
REM 변수 모드로 IN과 OUT을 사용할 수 있으며, 생략시에는 IN이 사용된다.
DECLARE
  v_query CONSTANT VARCHAR2(200) := 'SELECT COUNT(*)
                                       FROM emp
                                      WHERE deptno = :deptno
                                        AND job    = :job' ;
  v_deptno emp.deptno%TYPE ;
  v_cnt    PLS_INTEGER ;
BEGIN
  v_deptno := 20 ;
  -- 바인드 값은 변수, 상수, 리터럴을 모두 사용할 수 있다.
  EXECUTE IMMEDIATE v_query
               INTO v_cnt
              USING IN v_deptno, 'CLERK';
  DBMS_OUTPUT.PUT_LINE('COUNT = '||v_cnt) ;
END ;

--===============================================================
-- /* Example 14-04.바인드 변수 플레이스 홀더의 이름과 순서(익명 PLSQL 문이나 CALL 문이 아닐 경우).SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 바인드 변수 플레이스 홀더의 이름과 순서
REM 가. 익명 PL/SQL문도 아니고 CALL 문도 아닐 경우
REM     바인드 변수의 사용 횟수만큼 USING 절에 값 제공
DECLARE
  v_ename_in  VARCHAR2(10) := 'Scott';
  v_ename     VARCHAR2(10);
  v_job       VARCHAR2(10) := 'ANALYST';
BEGIN
  EXECUTE IMMEDIATE 'SELECT ename
                       FROM EMP
                      WHERE ename IN (:ename, UPPER(:ename), LOWER(:ename), INITCAP(:ename))
                        AND job = :job'
          INTO v_ename
          USING v_ename_in, v_ename_in, v_ename_in, v_ename_in, v_job;
  DBMS_OUTPUT.PUT_LINE('이름=' || v_ename || ', 업무=' || v_job) ;
END ;

--===============================================================
-- /* Example 14-05.바인드 변수 플레이스 홀더의 이름과 순서(익명 PLSQL 문이거나 CALL 문일 경우).SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  c_stmt CONSTANT VARCHAR2(1000) :=
    Q'<BEGIN
        :a := :a + :b;
        DBMS_OUTPUT.PUT_LINE('a='||:a||', b='||:b);
       END;>';
  v_a NUMBER := 2;
  v_b NUMBER := 3;
BEGIN
  EXECUTE IMMEDIATE c_stmt USING IN OUT v_a, v_b;
END ;

--===============================================================
-- /* Example 14-06.커서 변수를 사용하는 동적 SQL.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  TYPE empcur_type IS REF CURSOR;
  v_emp_cur       empcur_type; --커서 변수
  emp_rec         emp%ROWTYPE;
  v_stmt          VARCHAR2(200);
  v_empno         NUMBER;
BEGIN
  -- 실행할 동적 SQL문
  v_stmt := 'SELECT * FROM emp WHERE empno = :empno';
  v_empno := 7788;  -- 바인드 변수의 값으로 사용할 사번

  -- 쿼리문 v_stmt에 대한 v_emp_cur 커서를 OPEN
  OPEN v_emp_cur FOR v_stmt USING v_empno;

  -- 결과 로우를 한 건씩 FETCH
  LOOP
    FETCH v_emp_cur INTO emp_rec;
    EXIT WHEN v_emp_cur%NOTFOUND;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('이름=' || emp_rec.ename || ', 사번=' || emp_rec.empno) ;
  -- 사용 완료된 커서를 CLOSE
  CLOSE v_emp_cur;
END;

--===============================================================
-- /* Example 14-07.DBMS_SQL을 사용한 SELECT 문 처리.SQL (나중에 다시 보자..) */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM DBMS_SQL을 사용한 SELECT 문 처리
DECLARE
  v_cursor_id NUMBER;
  v_sql_stmt  VARCHAR2(4000) := Q'<SELECT *
                                     FROM emp
                                    WHERE deptno   = :deptno
                                      AND hiredate >= TO_DATE(:hiredate, 'YYYY-MM-DD')>' ;

  TYPE vc_array IS TABLE OF VARCHAR2(100);
  v_bind_var    vc_array ;
  v_bind_val    vc_array ;
  v_ret         NUMBER;

  v_desc_tab    DBMS_SQL.DESC_TAB;
  v_col_cnt     PLS_INTEGER ;
  v_str_var     VARCHAR2(100);
  v_num_var     NUMBER;
  v_date_var    DATE;
  v_row_cnt     PLS_INTEGER ;
BEGIN
  -- 바인드 변수와 값 목록
  v_bind_var := vc_array('deptno', 'hiredate') ;   -- 바인드 변수
  v_bind_val := vc_array('10'    , '1981-07-01') ; -- 바인드 값

  -- SQL 커서를 열고 커서 번호를 반환받는다.
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;

  -- SQL을 파싱한다.
  DBMS_SQL.PARSE(v_cursor_id, v_sql_stmt, DBMS_SQL.NATIVE);

  -- 바인드 변수에 값을 바인드 한다.
  FOR i IN 1 .. v_bind_var.COUNT LOOP
    DBMS_SQL.BIND_VARIABLE(v_cursor_id, v_bind_var(i), v_bind_val(i));
  END LOOP;

  -- SELECT문의 칼럼 정보를 가져온다.
  DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_cnt, v_desc_tab);

  -- SELECT될 칼럼을 정의한다.
  FOR i IN 1 .. v_col_cnt LOOP
    IF    v_desc_tab(i).col_type = DBMS_SQL.NUMBER_TYPE THEN -- NUMBER형 칼럼
      DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_num_var);
    ELSIF v_desc_tab(i).col_type = DBMS_SQL.DATE_TYPE THEN   -- 일시간형 칼럼
      DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_date_var);
    ELSE                                                     -- 그 외는 모두 문자형으로 처리
      DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_str_var, 100);
    END IF;
  END LOOP;

  -- 커서를 실행한다.
  v_ret := DBMS_SQL.EXECUTE(v_cursor_id);

  -- 값을 출력
  v_row_cnt := 0 ;
  WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0
  LOOP
    v_row_cnt := v_row_cnt + 1 ;
    DBMS_OUTPUT.PUT_LINE(v_row_cnt||'번째 로우') ;
    FOR i IN 1 .. v_col_cnt LOOP
      IF (v_desc_tab(i).col_type = DBMS_SQL.NUMBER_TYPE) THEN  -- NUMBER형 칼럼 값
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_num_var);
        DBMS_OUTPUT.PUT_LINE(CHR(9)||rpad(v_desc_tab(i).col_name, 8, ' ') || ' : ' || v_num_var) ;
      ELSIF (v_desc_tab(i).col_type = DBMS_SQL.DATE_TYPE) THEN -- 일시간형 칼럼 값
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_date_var);
        DBMS_OUTPUT.PUT_LINE(CHR(9)||rpad(v_desc_tab(i).col_name, 8, ' ') || ' : ' ||
                             TO_CHAR(v_date_var,'YYYY-MM-DD')) ;
      ELSE                                                     -- 그 외는 모든 문자형 값
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_str_var);
        DBMS_OUTPUT.PUT_LINE(CHR(9)||rpad(v_desc_tab(i).col_name, 8, ' ') || ' : ' || v_str_var) ;
      END IF;
    END LOOP;
  END LOOP;

  -- 커서를 닫는다.
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id) ;
END;

--===============================================================
-- /* Example 14-08.DBMS_SQL을 사용한 DML 문 처리.SQL (나중에 다시 보자..) */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM DBMS_SQL을 사용한 DML 문 처리
DECLARE
  v_cursor_id NUMBER;
  v_sql_stmt  VARCHAR2(4000) := Q'<INSERT INTO emp(empno, ename, job, mgr,
                                           hiredate, sal, comm, deptno)
                                     VALUES(:empno, :ename, :job, :mgr,
                                         SYSDATE, :sal, :comm, :deptno)
                                       RETURNING hiredate into :hiredate>';

  v_emp       emp%ROWTYPE;
  v_ret       NUMBER;

  v_desc_tab  DBMS_SQL.DESC_TAB;
  v_col_cnt   PLS_INTEGER ;
  v_str_var   VARCHAR2(100);
  v_num_var   NUMBER;
  v_date_var  DATE;
  v_row_cnt   PLS_INTEGER ;
BEGIN
  -- INSERT할 값
  v_emp.empno    := 7000 ;
  v_emp.ename    := '이순신' ;
  v_emp.job      := '군인' ;
  v_emp.mgr      := NULL ;
  v_emp.hiredate := NULL ;     -- hiredate는 SYSDATE를 반환받음
  v_emp.sal      := 9999 ;
  v_emp.comm     := NULL ;
  v_emp.deptno   := 40 ;

  -- 기존 테스트 데이터 삭제
  DELETE FROM emp WHERE empno = v_emp.empno ;

  -- SQL 커서를 열고 커서 번호를 반환받는다.
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;

  -- SQL을 파싱한다.
  DBMS_SQL.PARSE(v_cursor_id, v_sql_stmt, DBMS_SQL.NATIVE);

  -- 바인드 변수에 값을 바인드 한다.
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'empno'   , v_emp.empno   );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'ename'   , v_emp.ename   );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'job'     , v_emp.job     );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'mgr'     , v_emp.mgr     );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'hiredate', v_emp.hiredate);
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'sal'     , v_emp.sal     );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'comm'    , v_emp.comm    );
  DBMS_SQL.BIND_VARIABLE(v_cursor_id, 'deptno'  , v_emp.deptno  );

  -- 커서를 실행한다.
  v_ret := DBMS_SQL.EXECUTE(v_cursor_id);

  -- OUT 변수 값을 받음
  DBMS_SQL.VARIABLE_VALUE(v_cursor_id, 'hiredate', v_emp.hiredate); -- RETURNING절의 반환값
  DBMS_OUTPUT.PUT_LINE(v_emp.ename || '의 입사일 : '||TO_CHAR(v_emp.hiredate, 'YYYY-MM-DD')) ;

  -- 커서를 닫는다.
  DBMS_SQL.CLOSE_CURSOR(v_cursor_id) ;
END;
/

PAUSE
REM 테스트 데이터를 삭제한다.
DELETE FROM emp WHERE empno = 7000 ;
COMMIT ;

--===============================================================
-- /* Example 14-09.동적 PLSQL.SQL */
--===============================================================
SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
  v_stmt    VARCHAR2(1000);
  v_empno   emp.empno%TYPE;
  v_ename   emp.ename%TYPE;
  v_dname   dept.dname%TYPE;
BEGIN
  -- 실행할 동적 PL/SQL문
  -- 사번을 입력으로 하여 사원명과 소속 부서를 출력
  v_stmt := 'DECLARE
               vv_ename emp.ename%TYPE;
               vv_dname dept.dname%TYPE;
             BEGIN
               DBMS_OUTPUT.PUT_LINE(''조회할 사번 = '' ||:empno);
               SELECT ename, dname
                 INTO vv_ename, vv_dname
                 FROM emp e, dept d
                WHERE e.empno = :empno
                  AND e.deptno = d.deptno;
               :ename := vv_ename; -- 무슨 의미지?..
               :dname := vv_dname; -- 무슨 의미지?..
             END;';
  v_empno := 7788;
  -- 동적 PL/SQL 실행
  EXECUTE IMMEDIATE v_stmt
              USING IN  v_empno,  -- 입력 변수(IN 생략 가능)
                    OUT v_ename,  -- 출력 변수(OUT 필수)
                    OUT v_dname;  -- 출력 변수(OUT 필수)
  DBMS_OUTPUT.PUT_LINE(v_ename||'의 소속 부서 = '||v_dname);
END;
