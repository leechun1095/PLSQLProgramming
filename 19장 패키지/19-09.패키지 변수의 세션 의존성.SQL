SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM =====================================
REM 세션 1
SELECT pkg_seq.get_nextval FROM dual ;

SELECT pkg_seq.get_nextval FROM dual ;

REM =====================================
REM 세션 2
SELECT pkg_seq.get_nextval FROM dual ;

REM =====================================
REM 세션 1
SELECT pkg_seq.get_nextval FROM dual ;
