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
