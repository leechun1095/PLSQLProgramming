# PL/SQL CURSOR 를 사용하는 이유
## 커서에서 별도의 데이터 가공 로직이 필요한 경우만 사용한다.

#### 예시 : 평상시 아무 생각없이 동일 패턴으로 코드를 짠 경우
```sql
CREATE OR REPLACE PROCEDURE SP_1234
(
      O_ERR_CODE    OUT VARCHAR2    /* Error code */
    , O_ERR_MSG     OUT NVARCHAR2   /* Error message */
)
AS
    TYPE TBL_DATA_LIST  IS TABLE OF TABLE_E%ROWTYPE;
    TBL_DS              TBL_DATA_LIST;
    CUR_RS              SYS_REFCURSOR;
 
    V_CNT               NUMBER := 0;
        
BEGIN

    DELETE 
      FROM TABLE_E		
     WHERE HHHHH = TO_CHAR(SYSDATE - 1, 'YYYYMMDD');
     
    COMMIT;
	
    OPEN CUR_RS FOR 

        WITH WITH_A
        AS (
            SELECT A.BBBBB
                 , B.AAAAA
                 , A.CCCCC
                 , A.DDDDD
                 , NVL(BB.TOWARD_RETURN, A.EEEEE) AS EEEEE
                 , C.DPD FFFFF
                 , A.HHHHH
              FROM (
                    SELECT BBBBB
                         , CCCCC
                         , DDDDD
                         , EEEEE
                         , HHHHH
                      FROM TABLE_A
                     WHERE TRUNC(HHHHH) = TRUNC(SYSDATE - 1)
                    ) A
                LEFT JOIN TABLE_B B 
                  ON A.BBBBB = B.BBBBB
                LEFT JOIN TABLE_C C 
                  ON A.BBBBB = C.BBBBB
                 AND TRUNC(A.CCCCC) - 1 <= C.CTIME 
                 AND TRUNC(A.CCCCC) > C.CTIME
                LEFT JOIN TABLE_D BB
                  ON A.EEEEE = BB.TOWARD
            )
        , WITH_B
        AS (
            SELECT A.*
                 , D.DPD GGGGG
              FROM WITH_A A
              LEFT JOIN TABLE_C D 
                ON A.BBBBB = D.BBBBB
               AND TRUNC(A.CCCCC) <= D.CTIME 
               AND TRUNC(A.CCCCC) + 1 > D.CTIME 
        )

        SELECT T.AAAAA
             , T.BBBBB
             , TO_CHAR(T.CCCCC, 'YYYYMMDD') AS CCCCC
             , T.DDDDD
             , T.EEEEE
             , NVL(T.FFFFF, 0) AS FFFFF
             , NVL(T.GGGGG, 0) AS GGGGG
             , TO_CHAR(T.HHHHH, 'YYYYMMDD') AS HHHHH
          FROM WITH_B T;

    LOOP
    
        FETCH CUR_RS BULK COLLECT INTO TBL_DS LIMIT 100000;
        
        FORALL I IN TBL_DS.FIRST..TBL_DS.LAST

        INSERT INTO TABLE_E
        (
              AAAAA
            , BBBBB
            , CCCCC
            , DDDDD
            , EEEEE
            , FFFFF
            , GGGGG
            , HHHHH
        )
        VALUES 
        (
              TBL_DS(I).AAAAA
            , TBL_DS(I).BBBBB
            , TBL_DS(I).CCCCC
            , TBL_DS(I).DDDDD
            , TBL_DS(I).EEEEE
            , TBL_DS(I).FFFFF
            , TBL_DS(I).GGGGG   
            , TBL_DS(I).HHHHH
        );

        COMMIT;
       
        EXIT WHEN CUR_RS%NOTFOUND;

    END LOOP;
    
    CLOSE CUR_RS;
```

</br>

#### INSERT INTO TABLE SELECT 절로 변경하는 것이 속도/성능 측면에서 훨씬 유리함.
* 위에 프로시저는 별도의 로직이 없기 때문임.
```sql
INSERT INTO TABLE_E
	WITH WITH_A
	AS (
		SELECT A.BBBBB
		   , B.AAAAA
		   , A.CCCCC
		   , A.DDDDD
		   , NVL(BB.TOWARD_RETURN, A.EEEEE) AS EEEEE
		   , C.DPD FFFFF
		   , A.HHHHH
		  FROM (
			SELECT BBBBB
			   , CCCCC
			   , DDDDD
			   , EEEEE
			   , HHHHH
			  FROM TABLE_A
			 WHERE TRUNC(HHHHH) = TRUNC(SYSDATE - 1)
			) A
		  LEFT JOIN TABLE_B B 
			ON A.BBBBB = B.BBBBB
		  LEFT JOIN TABLE_C C 
			ON A.BBBBB = C.BBBBB
		   AND TRUNC(A.CCCCC) - 1 <= C.CTIME 
		   AND TRUNC(A.CCCCC) > C.CTIME
		  LEFT JOIN TABLE_D BB
			ON A.EEEEE = BB.TOWARD
	)
	, WITH_B
	AS (
		SELECT A.*
		   , D.DPD GGGGG
		  FROM WITH_A A
		  LEFT JOIN TABLE_C D 
		  ON A.BBBBB = D.BBBBB
		   AND TRUNC(A.CCCCC) <= D.CTIME 
		   AND TRUNC(A.CCCCC) + 1 > D.CTIME 
	)
SELECT T.AAAAA
	 , T.BBBBB
	 , TO_CHAR(T.CCCCC, 'YYYYMMDD') AS CCCCC
	 , T.DDDDD
	 , T.EEEEE
	 , NVL(T.FFFFF, 0) AS FFFFF
	 , NVL(T.GGGGG, 0) AS GGGGG
	 , TO_CHAR(T.HHHHH, 'YYYYMMDD') AS HHHHH
  FROM WITH_B T;
```
