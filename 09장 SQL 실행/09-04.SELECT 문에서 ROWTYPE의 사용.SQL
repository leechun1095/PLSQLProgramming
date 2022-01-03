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
