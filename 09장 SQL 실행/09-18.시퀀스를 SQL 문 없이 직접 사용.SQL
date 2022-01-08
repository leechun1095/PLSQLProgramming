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
