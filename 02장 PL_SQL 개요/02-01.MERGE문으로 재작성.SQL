--===============================================================
-- /* Example 2-1 익명 PL/SQL 예제 1-4를 MERGE문으로 재작성 */
--===============================================================
MERGE INTO emp a
USING (SELECT 7788		AS empno,
			  'SCOTT' 	AS ename,
			  'ANALYST' AS job,
			  20    	AS default_deptno
         FROM dual) b
ON(a.empno = b.empno)
WHEN MATCHED THEN
  UPDATE SET a.ename = b.ename,
			 a.job	 = b.job
WHEN NOT MATCHED THEN
  INSERT (a.empno, a.ename, a.job, a.deptno)
  VALUES (b.empno, b.ename, b.job, b.default_deptno);
