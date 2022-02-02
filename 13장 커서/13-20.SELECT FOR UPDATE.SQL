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
