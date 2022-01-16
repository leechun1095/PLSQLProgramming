SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

/*
1. 레이블명으로 사용 가능한 문자열의 기준은 변수명의 기준과 동일하며, 한글도 사용 가능함
2. 변수명과 마찬가지로 큰따옴표로 레이블명을 둘러싸는 경우에는 어떤 문자라도 사용 가능함
*/
REM 레이블의 사용
DECLARE
  v_num NUMBER := 0 ;
BEGIN
  IF v_num = 0 THEN
    GOTO block_label ; -- 뒤따르는 블록 레이블로 이동
  END IF ;

  <<block_label>>  -- BLOCK에 대한 레이블
  BEGIN
    IF v_num = 0 THEN
      GOTO statement_label ; -- 뒤따르는 문장 레이블로 이동
    END IF ;

    <<statement_label>>  -- 문장(실행문)에 대한 레이블
    v_num := v_num + 1 ;
		DBMS_OUTPUT.PUT_LINE('1111') ;

    IF v_num = 0 THEN
			DBMS_OUTPUT.PUT_LINE('2222') ;
      GOTO statement_label ; -- 앞에 위치한 문장 레이블로 이동
    END IF ;
  END ;

  IF v_num = 0  THEN
		DBMS_OUTPUT.PUT_LINE('3333') ;
    GOTO block_label ; -- 앞에 위치한 블록 레이블로 이동
  END IF ;
END ;
