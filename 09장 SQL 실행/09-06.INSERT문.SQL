SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

BEGIN
	INSERT INTO emp( empno
                 , ename
                 , hiredate
                 , deptno
                 )
          VALUES ( 9000
                 , '홍길동'
                 , sysdate
                 , 30
                 );
	DBMS_OUTPUT.PUT_LINE('INSERT 건수: ' || SQL%ROWCOUNT);	-- 변경된 건수 출력
  COMMIT;
END;

select * from emp;
