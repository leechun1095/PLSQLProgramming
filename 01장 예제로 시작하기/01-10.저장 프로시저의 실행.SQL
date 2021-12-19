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
