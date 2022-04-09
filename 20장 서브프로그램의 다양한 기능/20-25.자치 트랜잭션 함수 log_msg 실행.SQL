SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 초기 건수
SELECT (SELECT COUNT(*) FROM EMP)	AS "emp 건수"
		 , (SELECT COUNT(*) FROM log_table) AS "로그 건수"
	FROM DUAL;

REM 자치 트랜잭션 함수 log_msg 실행
BEGIN
	INSERT INTO emp(empno, ename, sal)
	VALUES (9100, '이순신', 9100);
  log_msg('이순신을 추가했습니다.');
	ROLLBACK;
END;

REM 로깅 + 롤백 후 건수
SELECT (SELECT COUNT(*) FROM emp)       "emp 건수"
     , (SELECT COUNT(*) FROM log_table) "로그 건수"
  FROM DUAL ;
