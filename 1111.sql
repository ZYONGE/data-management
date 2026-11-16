-- ============================================================
-- Chapter 6. SQL - Join & Set Operation : 슬라이드 Q 풀이
-- 1 ~ 7번  : EMP / DEPT / SALGRADE  → emp_dept_salgrade.sql 먼저 실행
-- 8 ~ 10번 : K리그 스키마           → model.sql
-- ============================================================


-- ------------------------------------------------------------
-- 1. [p.8] Non-EQUI JOIN : 사원명, 급여, 급여등급
--    SAL 이 LOSAL ~ HISAL 구간에 들어가는 등급과 연결 (= 이 아닌 BETWEEN)
-- ------------------------------------------------------------
SELECT E.ENAME 사원명, E.SAL 급여, S.GRADE 급여등급
FROM   EMP E, SALGRADE S
WHERE  E.SAL BETWEEN S.LOSAL AND S.HISAL;

-- 명시적 조인으로 쓰면
SELECT E.ENAME 사원명, E.SAL 급여, S.GRADE 급여등급
FROM   EMP E JOIN SALGRADE S
ON     E.SAL BETWEEN S.LOSAL AND S.HISAL;


-- ------------------------------------------------------------
-- 2. [p.11] ON 조건절 : 이름에 'S' 를 포함하는 사원의 사원이름, 부서코드, 부서명
--    조인 조건은 ON, 일반 조건은 WHERE
--    결과 5건 : SMITH, JONES, SCOTT, ADAMS, JAMES
-- ------------------------------------------------------------
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
WHERE  E.ENAME LIKE '%S%';


-- ------------------------------------------------------------
-- 3. [p.16] INNER JOIN vs RIGHT OUTER JOIN 결과 비교
--    INNER JOIN       : 14건 (사원이 있는 부서 10/20/30 만)
--    RIGHT OUTER JOIN : 15건 (사원이 없는 40 OPERATIONS 가 추가됨)
--                       → 그 행의 ENAME, E.DEPTNO 는 NULL
--                         (E.DEPTNO 를 출력했기 때문. D.DEPTNO 를 출력하면 40 이 보임)
-- ------------------------------------------------------------
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E INNER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;

SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E RIGHT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;


-- ------------------------------------------------------------
-- 4. [p.20] CROSS JOIN 결과 행의 수
--    EMP 14건 × DEPT 4건 = 56건
-- ------------------------------------------------------------
SELECT E.ENAME, E.DEPTNO, D.DEPTNO, D.DNAME
FROM   EMP E CROSS JOIN DEPT D;

SELECT COUNT(*) FROM EMP CROSS JOIN DEPT;   -- 56


-- ------------------------------------------------------------
-- 5. [p.21] 5가지 JOIN 의 레코드 수
--    STUDENT : KIM(B), LEE(C), CHOI(D), PARK(B)
--    DEPT    : A(MIS), B(CS), C(BIO)
--
--    INNER JOIN       : 3건  (KIM-B, LEE-C, PARK-B)
--    CROSS JOIN       : 12건 (4 × 3)
--    LEFT OUTER JOIN  : 4건  (INNER 3 + 짝 없는 CHOI(D))
--    RIGHT OUTER JOIN : 4건  (INNER 3 + 짝 없는 A)
--    FULL OUTER JOIN  : 5건  (INNER 3 + CHOI(D) + A)
--
--    EMP 스키마의 DEPT 와 이름이 겹치므로 테이블을 만들지 않고 WITH 절로 확인
-- ------------------------------------------------------------
WITH STUDENT AS (
    SELECT 'KIM'  S_NAME, 111 S_ID, 'B' DEPT FROM DUAL UNION ALL
    SELECT 'LEE',         222,      'C'      FROM DUAL UNION ALL
    SELECT 'CHOI',        333,      'D'      FROM DUAL UNION ALL
    SELECT 'PARK',        444,      'B'      FROM DUAL
), S_DEPT AS (
    SELECT 'A' D_ID, 'MIS' D_NAME FROM DUAL UNION ALL
    SELECT 'B',      'CS'         FROM DUAL UNION ALL
    SELECT 'C',      'BIO'        FROM DUAL
)
SELECT 'INNER' 조인, COUNT(*) 건수 FROM STUDENT S INNER JOIN      S_DEPT D ON (S.DEPT = D.D_ID) UNION ALL
SELECT 'CROSS',      COUNT(*)      FROM STUDENT S CROSS JOIN      S_DEPT D                      UNION ALL
SELECT 'LEFT',       COUNT(*)      FROM STUDENT S LEFT OUTER JOIN  S_DEPT D ON (S.DEPT = D.D_ID) UNION ALL
SELECT 'RIGHT',      COUNT(*)      FROM STUDENT S RIGHT OUTER JOIN S_DEPT D ON (S.DEPT = D.D_ID) UNION ALL
SELECT 'FULL',       COUNT(*)      FROM STUDENT S FULL OUTER JOIN  S_DEPT D ON (S.DEPT = D.D_ID);


-- ------------------------------------------------------------
-- 6. [p.23] SELF JOIN : 사원의 사번·이름 + 매니저의 사번·이름
--    매니저가 없는 KING 도 나와야 하므로 LEFT OUTER JOIN → 14건
--    (INNER JOIN 이면 KING 이 빠져서 13건)
--    E = 사원 역할, M = 매니저 역할 (같은 EMP 를 개념적으로 두 테이블로 사용)
-- ------------------------------------------------------------
SELECT E.EMPNO, E.ENAME, M.EMPNO MGRNO, M.ENAME MNAME
FROM   EMP E LEFT OUTER JOIN EMP M
ON     E.MGR = M.EMPNO;


-- ------------------------------------------------------------
-- 7. [p.18] FULL OUTER JOIN = LEFT OUTER JOIN UNION RIGHT OUTER JOIN
--    두 질의 모두 15건
-- ------------------------------------------------------------
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E FULL OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;

SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E LEFT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
UNION
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E RIGHT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;


-- ============================================================
-- [p.24] K리그 스키마 연습문제 (model.sql)
-- ============================================================

-- ------------------------------------------------------------
-- 8. 각 선수의 이름, 소속 팀명, 경기장명 (연봉 SALARY 10000 이상만)
--    PLAYER → TEAM → STADIUM 순서로 두 번 조인
--    주의 : model.sql 의 PLAYER 에는 SALARY 컬럼이 없어서 그대로 실행하면
--           ORA-00904 (invalid identifier) 오류. 수업용 데이터에 SALARY 가 있을 때 실행
-- ------------------------------------------------------------
SELECT P.PLAYER_NAME 선수명, T.TEAM_NAME 팀명, S.STADIUM_NAME 경기장명
FROM   PLAYER P
       JOIN TEAM T    ON P.TEAM_ID    = T.TEAM_ID
       JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID
WHERE  P.SALARY >= 10000;


-- ------------------------------------------------------------
-- 9. 경기도(DDD = '031') 경기장에서 홈경기를 한 팀의 이름, 경기일자, 홈팀 점수
--    홈팀이 승리한 경기만 (HOME_SCORE > AWAY_SCORE)
--    SCHEDULE.STADIUM_ID → STADIUM (지역번호), SCHEDULE.HOMETEAM_ID → TEAM (팀명)
--    경기 전이라 점수가 NULL 인 행은 > 비교에서 자동으로 빠짐
--    031 경기장 : 성남·인천·수원·일산·안양 → 결과 18건 (일화천마, 삼성블루윙즈, 유나이티드)
-- ------------------------------------------------------------
SELECT T.TEAM_NAME 팀명, SC.SCHE_DATE 경기일자, SC.HOME_SCORE 홈팀점수
FROM   SCHEDULE SC
       JOIN STADIUM S ON SC.STADIUM_ID  = S.STADIUM_ID
       JOIN TEAM T    ON SC.HOMETEAM_ID = T.TEAM_ID
WHERE  S.DDD = '031'
  AND  SC.HOME_SCORE > SC.AWAY_SCORE
ORDER BY SC.SCHE_DATE;


-- ------------------------------------------------------------
-- 10. 모든 경기장 이름 + 그 경기장에서 홈경기를 한 팀의 이름
--     한 번도 홈경기를 하지 않은 경기장도 포함 → STADIUM 기준 LEFT OUTER JOIN
--     경기마다 행이 생기므로 DISTINCT 로 경기장-팀 조합당 한 번만 출력
--     홈경기가 없는 경기장은 팀명이 NULL → 결과 20건 (그중 홈경기 없는 경기장 9곳)
-- ------------------------------------------------------------
SELECT DISTINCT S.STADIUM_NAME 경기장명, T.TEAM_NAME 홈팀명
FROM   STADIUM S
       LEFT OUTER JOIN SCHEDULE SC ON S.STADIUM_ID     = SC.STADIUM_ID
       LEFT OUTER JOIN TEAM T      ON SC.HOMETEAM_ID   = T.TEAM_ID
ORDER BY S.STADIUM_NAME;

select * from emp;
select * from dept;
select * from salgrade;


SELECT E.ENAME, D.DNAME
FROM   EMP E JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
WHERE  E.ENAME = 'SMITH';



SELECT P.PLAYER_NAME  AS 선수명,
       P.POSITION     AS 포지션,
       T.TEAM_NAME    AS 팀이름,
       S.STADIUM_NAME AS 경기장명
FROM   PLAYER P, TEAM T, STADIUM S
WHERE  P.TEAM_ID    = T.TEAM_ID
  AND  T.STADIUM_ID = S.STADIUM_ID;
