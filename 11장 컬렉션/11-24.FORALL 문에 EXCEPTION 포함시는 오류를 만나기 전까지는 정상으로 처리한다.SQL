SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM EXCEPTION 포함시는 오류를 만나기 전까지는 정상으로 처리한다.
REM 예제에서는 (1,2,3,3,5) 중에서 처음 세 건은 정상 INSERT 된다.
DECLARE
 TYPE ID_ARR_TYPE IS TABLE OF PLS_INTEGER ;
 v_id_arr ID_ARR_TYPE := ID_ARR_TYPE(1,2,3,3,5) ;
BEGIN
 -- INSERT문의 배열 처리
 FORALL i IN v_id_arr.FIRST .. v_id_arr.LAST
   INSERT INTO T VALUES( v_id_arr(i), v_id_arr(i)) ;
 EXCEPTION WHEN OTHERS THEN

END ;
/

PAUSE

SELECT COUNT(*) FROM t ;
