SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

-- GOTO문은 현재 위치와 동일한 깊이에 선언도니 레이블이나 더 바깥에 선언된 레이블을 지정할 수 있음
-- 그러나 현재 레벨보다 더 깊은 곳에 위치한 레이블은 지정할 수 없음
REM 무조건 분기문: 더 깊은 레벨의 레이블을 참조하므로 오류
DECLARE
  v_bool BOOLEAN := TRUE;
BEGIN
  GOTO deeper_level ; -- 더 깊은 레벨의 레이블을 참조하므로 오류

  IF v_bool = TRUE THEN
  <<deeper_level>>
    NULL ;
  END IF;
END;
