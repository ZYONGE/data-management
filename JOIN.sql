/* ████████████████████████████████████████████████████████████
   JOIN — 여러 테이블을 연결해서 조회하기
   ------------------------------------------------------------
   테이블 하나에는 필요한 정보가 다 들어 있지 않다.
   (PLAYER 에는 TEAM_ID 만 있고 팀 "이름"은 TEAM 에 있다)
   → 두 테이블에서 "같은 값을 가진 컬럼"(보통 PK = FK)을 기준으로
     행을 짝지어 하나의 결과로 붙이는 것이 JOIN 이다.

   ▣ 두 가지 표기법 (결과는 같다)
     Oracle 방식 : FROM A, B        WHERE A.키 = B.키
     ANSI  방식  : FROM A JOIN B    ON    A.키 = B.키
     → ANSI 방식은 "조인 조건(ON)"과 "일반 조건(WHERE)"이 분리돼서
       읽기 쉽고 실수가 적다. 시험·실무 모두 ANSI 방식을 권장.

   ▣ 테이블 별칭 (FROM EMP E)
     - E.ENAME 처럼 "어느 테이블의 컬럼인지" 짧게 표시한다.
     - 두 테이블에 같은 이름의 컬럼(DEPTNO)이 있으면 반드시 별칭을 붙여야 한다.
       안 붙이면 ORA-00918 (column ambiguously defined).
     - 별칭을 정하면 그 쿼리 안에서는 원래 이름(EMP.ENAME)을 쓸 수 없다.

   ▣ 꼭 외울 것
     - 조인 조건을 빠뜨리면 모든 행 × 모든 행 = CROSS JOIN(카티션 곱)이 된다.
     - 테이블 N개를 조인하려면 조인 조건이 최소 N-1개 필요하다.

   ▣ JOIN 종류 한눈에 보기
     INNER JOIN       : 양쪽 모두 짝이 있는 행만
     LEFT  OUTER JOIN : 왼쪽 테이블은 전부 + 오른쪽은 짝이 있을 때만 (없으면 NULL)
     RIGHT OUTER JOIN : 오른쪽 테이블은 전부 + 왼쪽은 짝이 있을 때만
     FULL  OUTER JOIN : 양쪽 전부 (짝 없는 쪽은 NULL)
     CROSS JOIN       : 조건 없이 모든 조합 (행 수 = A 행 수 × B 행 수)
     SELF JOIN        : 같은 테이블을 별칭 두 개로 나눠 자기 자신과 조인
     Non-EQUI JOIN    : = 가 아닌 조건(BETWEEN, >, < 등)으로 조인

   ▣ 사용하는 스키마
     [1] ~ [9]  : EMP / DEPT / SALGRADE → emp_dept_salgrade.sql 먼저 실행
     [10] ~     : K리그 (PLAYER / TEAM / STADIUM / SCHEDULE) → model.sql
     [p.xx] 는 강의 슬라이드(Chapter 6. Join & Set Operation) 페이지 번호.
   ████████████████████████████████████████████████████████████ */


/* ████ EMP / DEPT / SALGRADE 스키마 ███████████████████████████ */

/* ============================================================
   [1] 조인 전에 데이터부터 확인
   ------------------------------------------------------------
   - 조인 결과의 행 수를 예측하려면 원본 테이블에 무엇이 있는지 먼저 본다.
     EMP 14건 / DEPT 4건 (10, 20, 30, 40) / SALGRADE 5건
   - 포인트 : 사원은 10, 20, 30 부서에만 있고 40(OPERATIONS)에는 아무도 없다.
     → 이 "짝 없는 40번 부서"가 INNER 와 OUTER 의 결과 차이를 만든다. ([5] 참고)
   ============================================================ */
select * from emp;
select * from dept;
select * from salgrade;


/* ============================================================
   [2] 기본 ANSI JOIN : JOIN ... ON
   ------------------------------------------------------------
   문법 : SELECT ... FROM A JOIN B ON A.컬럼 = B.컬럼 [WHERE 조건];
   - 그냥 JOIN 이라고만 쓰면 INNER JOIN 이다. (INNER 생략 가능)
   - ON 에는 "두 테이블을 잇는 조건", WHERE 에는 "결과를 거르는 조건".
   - 동작 순서로 생각하면 : 먼저 EMP 와 DEPT 를 DEPTNO 로 붙이고(ON),
     그 결과에서 이름이 SMITH 인 행만 남긴다(WHERE).
   - 결과 : SMITH / RESEARCH (SMITH 의 DEPTNO 20 → DEPT 의 20 = RESEARCH)
   ============================================================ */
SELECT E.ENAME, D.DNAME
FROM   EMP E JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
WHERE  E.ENAME = 'SMITH';


/* ============================================================
   [3] [p.11] ON 조건절 + WHERE : 이름에 'S' 가 들어간 사원의 부서명
   ------------------------------------------------------------
   - 조인 조건은 ON, 일반 조건(LIKE)은 WHERE 로 나눠 쓴 예.
   - LIKE '%S%' : 위치 상관없이 S 가 들어간 이름. (DQL.sql [8] 참고)
   - 결과 5건 : SMITH, JONES, SCOTT, ADAMS, JAMES
   ============================================================ */
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO
WHERE  E.ENAME LIKE '%S%';


/* ============================================================
   [4] [p.8] Non-EQUI JOIN : 사원명, 급여, 급여등급
   ------------------------------------------------------------
   - EMP 와 SALGRADE 에는 "같은 값을 가진 컬럼"이 없다.
     대신 SAL 이 LOSAL ~ HISAL 구간 "안에 들어가는지"로 짝을 짓는다.
   - 이처럼 = 가 아닌 조건(BETWEEN, >=, < 등)으로 하는 조인을 Non-EQUI JOIN 이라 한다.
     (= 로 하는 일반 조인은 EQUI JOIN)
   - 예) SMITH 의 SAL 800 → 700 ~ 1200 구간 → 1등급
   - 아래 두 쿼리는 같은 결과. 위는 Oracle 방식, 아래는 ANSI 방식.
   ============================================================ */
-- Oracle 방식 : 조인 조건을 WHERE 에
SELECT E.ENAME 사원명, E.SAL 급여, S.GRADE 급여등급
FROM   EMP E, SALGRADE S
WHERE  E.SAL BETWEEN S.LOSAL AND S.HISAL;

-- ANSI 방식 : 조인 조건을 ON 에
SELECT E.ENAME 사원명, E.SAL 급여, S.GRADE 급여등급
FROM   EMP E JOIN SALGRADE S
ON     E.SAL BETWEEN S.LOSAL AND S.HISAL;


/* ============================================================
   [5] [p.16] INNER JOIN vs RIGHT OUTER JOIN 결과 비교
   ------------------------------------------------------------
   - INNER JOIN       : 14건. 양쪽에 짝이 있는 행만 → 사원이 있는 10/20/30 부서만.
   - RIGHT OUTER JOIN : 15건. 오른쪽(DEPT)은 짝이 없어도 전부 나온다.
                        → 사원이 없는 40 OPERATIONS 가 1행 추가된다.
   - ★ 그 추가된 행의 ENAME, E.DEPTNO 는 NULL 로 보인다.
     왼쪽(EMP)에 짝이 없으니 EMP 쪽 컬럼은 전부 NULL 이기 때문.
     → D.DEPTNO 를 출력했다면 40 이 보였을 것. "어느 테이블의 컬럼을
       출력하느냐"에 따라 NULL 이 보이는지가 달라진다는 점이 시험 포인트.
   - LEFT / RIGHT 는 "FROM 에 적은 순서" 기준이다.
     EMP E RIGHT JOIN DEPT D  =  DEPT D LEFT JOIN EMP E
   - OUTER 는 생략 가능 (RIGHT JOIN = RIGHT OUTER JOIN).
   ============================================================ */
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E INNER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;

SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E RIGHT OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;


/* ============================================================
   [6] [p.20] CROSS JOIN : 모든 조합
   ------------------------------------------------------------
   - ON 조건이 없다. 왼쪽의 모든 행이 오른쪽의 모든 행과 한 번씩 짝지어진다.
   - 행 수 = EMP 14건 × DEPT 4건 = 56건
   - 의도하지 않은 CROSS JOIN 은 보통 "조인 조건을 빠뜨린" 실수에서 나온다.
     (Oracle 방식에서 FROM EMP, DEPT 라고만 쓰고 WHERE 를 안 쓰면 똑같이 56건)
   ============================================================ */
SELECT E.ENAME, E.DEPTNO, D.DEPTNO, D.DNAME
FROM   EMP E CROSS JOIN DEPT D;

SELECT COUNT(*) FROM EMP CROSS JOIN DEPT;   -- 56


/* ============================================================
   [7] [p.21] 5가지 JOIN 의 결과 행 수 비교
   ------------------------------------------------------------
   예제 데이터
     STUDENT : KIM(B), LEE(C), CHOI(D), PARK(B)
     DEPT    : A(MIS), B(CS), C(BIO)

   - INNER JOIN       : 3건  (KIM-B, LEE-C, PARK-B)
   - CROSS JOIN       : 12건 (4 × 3)
   - LEFT OUTER JOIN  : 4건  (INNER 3 + 왼쪽에서 짝 없는 CHOI(D))
   - RIGHT OUTER JOIN : 4건  (INNER 3 + 오른쪽에서 짝 없는 A)
   - FULL OUTER JOIN  : 5건  (INNER 3 + CHOI(D) + A)
     → 공식처럼 외우기 : OUTER = INNER + 짝 없는 행

   문법 포인트
   - WITH 이름 AS (SELECT ...) : 이 쿼리 안에서만 쓰는 "임시 테이블"을 만든다.
     (CTE, Common Table Expression) 실제 테이블을 만들지 않으므로
     EMP 스키마의 DEPT 와 이름이 겹치지도 않고 지울 필요도 없다.
   - SELECT ... FROM DUAL UNION ALL SELECT ... : 고정값 행을 여러 개 쌓는 방법.
     DUAL 은 1행짜리 더미 테이블. (UNION ALL 은 SET_OPERATION.sql 참고)
   - 맨 아래 SELECT 5개를 UNION ALL 로 이어서 조인별 건수를 한 표로 보여 준다.
   ============================================================ */
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


/* ============================================================
   [8] [p.23] SELF JOIN : 사원의 사번·이름 + 그 사원의 매니저 사번·이름
   ------------------------------------------------------------
   - EMP.MGR 에는 "매니저의 EMPNO" 가 들어 있다. 즉 EMP 가 EMP 자신을 가리킨다.
   - 같은 테이블을 별칭 두 개로 불러서 "두 개의 테이블인 것처럼" 조인한다.
       E = 사원 역할,  M = 매니저 역할
       조인 조건 : 사원의 MGR = 매니저의 EMPNO
   - ★ 왜 LEFT OUTER JOIN 인가?
     KING 은 사장이라 MGR 이 NULL → 짝이 되는 매니저가 없다.
     INNER JOIN 이면 KING 이 빠져 13건, LEFT OUTER JOIN 이면 KING 도 나와 14건.
     (KING 행의 MGRNO, MNAME 은 NULL)
   ============================================================ */
SELECT E.EMPNO, E.ENAME, M.EMPNO MGRNO, M.ENAME MNAME
FROM   EMP E LEFT OUTER JOIN EMP M
ON     E.MGR = M.EMPNO;


/* ============================================================
   [9] [p.18] FULL OUTER JOIN
   ------------------------------------------------------------
   - 양쪽 테이블의 행을 모두 남긴다. 짝이 없는 쪽 컬럼은 NULL.
   - EMP 는 전원 부서가 있으므로 왼쪽에서 짝 없는 행은 0개,
     DEPT 의 40 은 사원이 없으므로 1개 → 14 + 1 = 15건.
   - "FULL OUTER = LEFT OUTER ∪ RIGHT OUTER" 를 UNION 으로 확인하는
     쿼리는 SET_OPERATION.sql [1] 에 있다.
   ============================================================ */
SELECT E.ENAME, E.DEPTNO, D.DNAME
FROM   EMP E FULL OUTER JOIN DEPT D
ON     E.DEPTNO = D.DEPTNO;


/* ████ K리그 스키마 (model.sql) ███████████████████████████████
   테이블 관계 : STADIUM ─┬─< TEAM ─< PLAYER
                          └─< SCHEDULE
     PLAYER.TEAM_ID       → TEAM.TEAM_ID
     TEAM.STADIUM_ID      → STADIUM.STADIUM_ID
     SCHEDULE.STADIUM_ID  → STADIUM.STADIUM_ID
     SCHEDULE.HOMETEAM_ID / AWAYTEAM_ID → TEAM.TEAM_ID (FK 는 없지만 의미상 연결)
   ████████████████████████████████████████████████████████████ */

/* ============================================================
   [10] Oracle 방식 3개 테이블 조인 : 선수명, 포지션, 팀이름, 경기장명
   ------------------------------------------------------------
   - FROM 에 테이블을 쉼표로 나열하고, WHERE 에 조인 조건을 AND 로 잇는다.
   - 테이블 3개 → 조인 조건 2개 (N-1 개 규칙)
       PLAYER → TEAM   : P.TEAM_ID    = T.TEAM_ID
       TEAM   → STADIUM: T.STADIUM_ID = S.STADIUM_ID
   - PLAYER 와 STADIUM 사이에는 직접 연결 컬럼이 없어서
     TEAM 을 "다리"처럼 거쳐야 한다.
   ============================================================ */
SELECT P.PLAYER_NAME  AS 선수명,
       P.POSITION     AS 포지션,
       T.TEAM_NAME    AS 팀이름,
       S.STADIUM_NAME AS 경기장명
FROM   PLAYER P, TEAM T, STADIUM S
WHERE  P.TEAM_ID    = T.TEAM_ID
  AND  T.STADIUM_ID = S.STADIUM_ID;


/* ============================================================
   [11] ANSI 방식 3개 테이블 조인 + 조건 : 선수명, 팀명, 경기장명
   ------------------------------------------------------------
   - [10] 과 같은 조인을 JOIN ... ON 두 번으로 쓴 형태.
     PLAYER JOIN TEAM 의 결과에 다시 JOIN STADIUM 을 붙이는 식으로 차례로 이어진다.
   - (A) 슬라이드 원문 : 연봉(SALARY) 10000 이상인 선수.
     ★ model.sql 의 PLAYER 에는 SALARY 컬럼이 없다.
       그대로 실행하면 ORA-00904 (invalid identifier : 없는 컬럼 이름).
       SALARY 가 있는 수업용 데이터에서만 실행할 것.
   - (B) 같은 구조를 실제 있는 컬럼(HEIGHT)으로 바꿔 실행 가능하게 만든 버전 : 키 180 이상.
   ============================================================ */
-- (A) 연봉 10000 이상 (SALARY 컬럼이 있을 때만 동작)
SELECT P.PLAYER_NAME 선수명, T.TEAM_NAME 팀명, S.STADIUM_NAME 경기장명
FROM   PLAYER P
       JOIN TEAM T    ON P.TEAM_ID    = T.TEAM_ID
       JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID
WHERE  P.SALARY >= 10000;

-- (B) 키 180 이상 (model.sql 에서 바로 실행 가능)
SELECT P.PLAYER_NAME  AS 선수명,
       T.TEAM_NAME    AS 팀명,
       S.STADIUM_NAME AS 경기장명
FROM PLAYER P
     JOIN TEAM T    ON P.TEAM_ID = T.TEAM_ID
     JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID
WHERE P.HEIGHT >= 180;


/* ============================================================
   [12] 팀별 선수 명단 : JOIN + 다중 정렬
   ------------------------------------------------------------
   - PLAYER 의 TEAM_ID 를 TEAM 과 이어서 ID 대신 팀 "이름"을 보여 준다.
   - ORDER BY 팀명, 선수명 : 팀 이름순으로 먼저 정렬하고,
     같은 팀 안에서는 선수 이름순으로 정렬한다. (DQL.sql [13-1] 참고)
   - 팀별로 "몇 명인지" 세는 문제는 GROUP_BY.sql [3] 에 있다.
   ============================================================ */
SELECT   T.TEAM_NAME   AS 팀명,
         P.PLAYER_NAME AS 선수명
FROM     PLAYER P
         JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
ORDER BY T.TEAM_NAME, P.PLAYER_NAME;


/* ============================================================
   [13] 경기장별 경기 일정 : SCHEDULE + STADIUM
   ------------------------------------------------------------
   - SCHEDULE 에는 경기장 ID 만 있으므로 STADIUM 과 조인해 경기장 이름을 가져온다.
   - SC.STADIUM_ID 와 S.STADIUM_ID 는 조인 조건 때문에 항상 같은 값이라
     SELECT 에서 어느 쪽을 써도 결과가 같다. (INNER JOIN 이기 때문)
   - 정렬 : 경기장 ID 순 → 같은 경기장 안에서는 날짜순.
     SCHE_DATE 는 'YYYYMMDD' 형식 문자열이라 문자 정렬이 곧 날짜 정렬이 된다.
   - 경기장별 "경기 수"를 세는 문제는 GROUP_BY.sql [4] 에 있다.
   ============================================================ */
SELECT   SC.STADIUM_ID   AS 경기장ID,
         S.STADIUM_NAME  AS 경기장이름,
         SC.SCHE_DATE    AS 경기일정,
         SC.HOMETEAM_ID  AS 홈팀ID,
         SC.AWAYTEAM_ID  AS 상대팀ID
FROM     SCHEDULE SC
         JOIN STADIUM S ON SC.STADIUM_ID = S.STADIUM_ID
ORDER BY SC.STADIUM_ID, SC.SCHE_DATE;


/* ============================================================
   [14] JOIN + CASE 표현식 : 홈팀명, 점수, 경기 결과(Win/Lose/Draw)
   ------------------------------------------------------------
   문법 : CASE
              WHEN 조건1 THEN 값1
              WHEN 조건2 THEN 값2
              [ELSE 기본값]
          END [AS 별칭]
   - 위에서부터 차례로 검사해서 "처음으로 참인 WHEN" 의 값을 돌려준다.
     프로그래밍의 if ~ else if ~ else 와 같다.
   - ELSE 를 생략했는데 어떤 WHEN 도 참이 아니면 결과는 NULL.
   - 점수가 NULL(아직 안 한 경기)이면 모든 비교가 UNKNOWN 이라 결과가 NULL 이 된다.
     → 그래서 WHERE 에서 IS NOT NULL 로 미경기 행을 미리 뺐다.
     → 이렇게 NULL 을 빼 두면 마지막 WHEN (=) 대신 ELSE 'Draw' 로 써도 결과가 같다.
   - 조인 : Oracle 방식. SCHEDULE.HOMETEAM_ID = TEAM.TEAM_ID 로 "홈팀" 이름만 붙였다.
   - ★ 여기서 S 는 SCHEDULE 의 별칭이다. (다른 문제에서는 S 가 STADIUM)
     별칭은 쿼리마다 새로 정하는 것이므로 FROM 절을 보고 판단할 것.
   ============================================================ */
SELECT T.TEAM_NAME AS 홈팀명,
       S.HOME_SCORE AS 홈팀점수,
       S.AWAY_SCORE AS 원정팀점수,
       CASE
           WHEN S.HOME_SCORE > S.AWAY_SCORE THEN 'Win'
           WHEN S.HOME_SCORE < S.AWAY_SCORE THEN 'Lose'
           WHEN S.HOME_SCORE = S.AWAY_SCORE THEN 'Draw'
       END AS RESULT
FROM SCHEDULE S, TEAM T
WHERE S.HOMETEAM_ID = T.TEAM_ID
  AND S.HOME_SCORE IS NOT NULL
  AND S.AWAY_SCORE IS NOT NULL;


/* ============================================================
   [15] [p.24] 경기도(DDD = '031') 경기장에서 홈팀이 이긴 경기
   ------------------------------------------------------------
   출력 : 홈팀 이름, 경기일자, 홈팀 점수
   - SCHEDULE 을 중심으로 두 테이블을 각각 다른 컬럼으로 조인한다.
       SCHEDULE.STADIUM_ID  → STADIUM : 경기장의 지역번호(DDD)를 알기 위해
       SCHEDULE.HOMETEAM_ID → TEAM    : 홈팀 이름을 알기 위해
   - DDD 는 VARCHAR2 라서 '031' 처럼 따옴표가 필요하다.
     (숫자 031 로 쓰면 앞의 0 이 사라진 31 과 비교하게 된다)
   - HOME_SCORE > AWAY_SCORE : 점수가 NULL 인 미경기 행은 비교 결과가
     UNKNOWN 이라 IS NOT NULL 을 따로 안 써도 자동으로 빠진다.
   - 031 경기장 : 성남·인천·수원·일산·안양
     → 결과 18건 (일화천마, 삼성블루윙즈, 유나이티드)
   ============================================================ */
SELECT T.TEAM_NAME 팀명, SC.SCHE_DATE 경기일자, SC.HOME_SCORE 홈팀점수
FROM   SCHEDULE SC
       JOIN STADIUM S ON SC.STADIUM_ID  = S.STADIUM_ID
       JOIN TEAM T    ON SC.HOMETEAM_ID = T.TEAM_ID
WHERE  S.DDD = '031'
  AND  SC.HOME_SCORE > SC.AWAY_SCORE
ORDER BY SC.SCHE_DATE;


/* ============================================================
   [16] [p.24] 모든 경기장 + 그 경기장에서 홈경기를 한 팀 (LEFT OUTER JOIN 2번)
   ------------------------------------------------------------
   - "한 번도 홈경기를 하지 않은 경기장도 포함" → 경기장이 기준이므로
     STADIUM 을 왼쪽에 두고 LEFT OUTER JOIN.
   - ★ 두 번째 조인도 LEFT 여야 한다.
     첫 조인에서 경기가 없는 경기장은 SC.HOMETEAM_ID 가 NULL 인데,
     두 번째를 INNER JOIN 으로 하면 NULL = TEAM_ID 가 성립하지 않아
     그 경기장이 다시 사라진다. OUTER 의 효과를 끝까지 유지하려면 계속 LEFT.
   - DISTINCT : 경기마다 1행씩 생기므로 같은 "경기장-팀" 조합이 여러 번 나온다.
     DISTINCT 로 중복된 행을 한 번씩만 남긴다.
   - 홈경기가 없는 경기장은 홈팀명이 NULL → 결과 20건 (그중 홈경기 없는 경기장 9곳)
   ============================================================ */
SELECT DISTINCT S.STADIUM_NAME 경기장명, T.TEAM_NAME 홈팀명
FROM   STADIUM S
       LEFT OUTER JOIN SCHEDULE SC ON S.STADIUM_ID     = SC.STADIUM_ID
       LEFT OUTER JOIN TEAM T      ON SC.HOMETEAM_ID   = T.TEAM_ID
ORDER BY S.STADIUM_NAME;
