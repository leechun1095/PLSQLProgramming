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
