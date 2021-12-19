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
























