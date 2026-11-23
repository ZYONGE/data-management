/* ████████████████████████████████████████████████████████████
   SET OPERATION — 집합 연산자
   ------------------------------------------------------------
   JOIN 이 테이블을 "옆으로" 붙인다면, 집합 연산자는 두 SELECT 의
   결과를 "위아래로" 합치거나 비교한다.

   ▣ 종류
     UNION      : 합집합. 중복 행은 하나만 남긴다. (중복 제거를 위해 정렬 작업이 생겨 느림)
     UNION ALL  : 합집합. 중복도 그대로 다 남긴다. (단순히 이어 붙여서 빠름)
     INTERSECT  : 교집합. 양쪽 결과에 모두 있는 행만.
     MINUS      : 차집합. 위 결과에서 아래 결과에 있는 행을 뺀다.
                  (Oracle 전용 이름. 표준 SQL 의 EXCEPT 에 해당)

   ▣ 규칙 (시험에 자주 나옴)
     - 각 SELECT 의 컬럼 "개수"가 같아야 하고, 같은 위치끼리 데이터 타입이 맞아야 한다.
       (컬럼 이름은 달라도 된다. 위치 순서로 대응된다)
     - 결과의 컬럼 제목은 "첫 번째 SELECT" 의 컬럼명/별칭을 따른다.
     - ORDER BY 는 맨 마지막 SELECT 뒤에 딱 한 번만 쓴다.
     - "같은 행" 판단은 모든 컬럼 값이 같을 때다. (NULL 끼리도 같은 것으로 본다)

   ▣ 사용 스키마 : EMP / DEPT → emp_dept_salgrade.sql
   ▣ UNION ALL 은 JOIN.sql [7] 에서 고정값 행을 쌓을 때도 쓰였다.
   ████████████████████████████████████████████████████████████ */


/* ============================================================
   [1] [p.18] FULL OUTER JOIN = LEFT OUTER JOIN UNION RIGHT OUTER JOIN
   ------------------------------------------------------------
   - 위 쿼리(FULL OUTER JOIN)와 아래 쿼리(LEFT ∪ RIGHT)는 결과가 같다. 둘 다 15건.
   - 왜 같은가?
       LEFT  결과 : 14건 (사원 전원, 짝이 있는 행만)
       RIGHT 결과 : 15건 (위 14건 + 사원 없는 40 OPERATIONS)
       → 두 결과에 똑같이 들어 있는 14건을 UNION 이 한 번만 남기고,
         RIGHT 에만 있는 OPERATIONS 1건이 더해져 15건 = FULL OUTER 결과.
   - ★ UNION ALL 로 바꾸면? 중복을 안 지우므로 14 + 15 = 29건이 된다.
     "FULL = LEFT ∪ RIGHT" 가 성립하려면 반드시 UNION 이어야 한다.
   - 참고 : UNION 은 "원래부터 똑같은 행" 도 지운다. EMP 는 사원 이름이
     모두 달라서 문제없지만, 이름·부서가 완전히 같은 사원이 둘 있으면
     UNION 쪽 결과가 FULL OUTER JOIN 보다 적어질 수 있다.
   ============================================================ */
-- FULL OUTER JOIN 으로 한 번에
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E FULL OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;

-- LEFT OUTER JOIN 결과 ∪ RIGHT OUTER JOIN 결과
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E LEFT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
UNION
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E RIGHT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;
