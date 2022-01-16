SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

DECLARE
	v_cnt		NUMBER;
	v_type	STRING(10);
BEGIN
	-- 테이블 emp가 생성되어 있는지 확인한다.
	-- 딕셔너리 뷰 user_tables에는 계정에 생성된 모든 테이블 목록이 들어 있다.
	SELECT COUNT(*)
		INTO v_cnt
		FROM USER_TABLES
	 WHERE TABLE_NAME = 'EMP';

	IF v_cnt > 0
	THEN
		DBMS_OUTPUT.PUT_LINE('테이블 EMP가 존재합니다.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('테이블 EMP가 존재하지 않습니다.');
	END IF;
END;
