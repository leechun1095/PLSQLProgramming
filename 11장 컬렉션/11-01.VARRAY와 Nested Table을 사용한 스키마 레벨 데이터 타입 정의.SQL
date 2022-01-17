/*

1. 스칼라 데이터 타입 : 단일 값 데이터 타입
2. 컴포지트 데이터 타입 : 복합 데이터 타입
 1) 컬렉션(Collection) : 배열과 유사한 구조로 동일한 데이터 타입이 반복되는 데이터를 저장하는 자료 구조이다.
	(1) Associative Array(연관배열) :
		- 컬렉션 항목의 개수를 사전에 지정하지 않는다.
		- 키(인덱스)는 정수와 문자열 둘 중 하나를 사용할 수 있다.(음수도 가능)
		- 컬렉션 항목의 개수에는 제한이 없음
		- Associative Array 변수는 초기화를 필요로 하지 않는다.
		- 변수는 NULL이 될 수 없으며, NULL을 할당하려고 하면 오류가 발생한다.
		- 키(인덱스)-값 쌍으로 이루어진 무한 배열이라고 볼 수 있다
		- Associative Array는 서브프로그램 내에서 사용될 소규모의 참조 테이블에서 사용하거나 컬렉션을 서버로 전달 또는 서버로부터 전달받을 때 유용함
		- Hash Table, Hash Map

	(2) VARRAY(가변 크기 배열) :
		- VARRAY 변수의 선언 시 배열의 크기를 지정해야 한다
		- VARRAY 인덱스는 1부터 시작하는 자연수 값이며, 저장된 값은 순서가 바뀌지 않는 것이 보장된다
		- 초기화되지 않은 VARRAY 변수는 NULL 이며, 사용 전에 반드시초기화해 주어야 오류가 발생하지 않는다.
		- 컬렉션 생성자 또는 EXTEND 메소드로 초기화 가능함
		- VARRAY는 배열의 최대 개수를 사전에 알고 있는 경우 또는 배열의 항목을 항상 동일한 순서로 접근하는 경우 유용함
		- Array, Vector

	(3) Nested Table(중첩 테이블) : Set, Bag(중복 허용 집합)

 2) 레코드(Record) : 서로 다른 데이터 타입의 데이터를 모아 놓은 자료 구조이다.

- ADT(Abstract Data Type) : TYPE문을 사용하여 스키마 레벨에서 정의되는 사용자 정의 객체 타입을 말한다.

*/

--PROCEDURE 생성 시
--CREATE OR REPLACE PROCEDURE SCOTT.check_salary(a_empno NUMBER)

SET ECHO ON
SET TAB OFF
SET SERVEROUTPUT ON

REM VARRAY를 사용한 스키마 레벨 데이터 타입 정의
CREATE OR REPLACE TYPE languages IS VARRAY(10) OF VARCHAR2(64)

PAUSE

REM Nested Table을 사용한 스키마 레벨 데이터 타입 정의
CREATE OR REPLACE TYPE cities IS TABLE OF VARCHAR2(64)
