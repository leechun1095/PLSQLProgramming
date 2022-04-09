SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM 재귀호출을 사용한 팩토리얼 계산 함수
CREATE OR REPLACE FUNCTION factorial(a_num PLS_INTEGER)
RETURN NUMBER
IS
BEGIN
	IF a_num <= 1 THEN
		RETURN 1;
	ELSE
		RETURN a_num * factorial(a_num-1); -- 재귀호출
	END IF;
END;

PAUSE

REM SELECT문에서 factorial 함수 호출
SELECT LEVEL 숫자
		 , factorial(LEVEL)
	FROM DUAL
	CONNECT BY LEVEL <= 10;
