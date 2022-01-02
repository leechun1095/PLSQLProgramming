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
