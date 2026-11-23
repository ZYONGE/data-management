/* ████████████████████████████████████████████████████████████
   GROUP BY — 그룹 함수와 그룹별 집계
   ------------------------------------------------------------
   "포지션별 평균 키", "팀별 선수 수" 처럼 여러 행을 묶어서
   하나의 값으로 요약할 때 쓴다.

   ▣ 그룹(집계) 함수 : 여러 행 → 값 하나
     COUNT(*)     : 행의 개수 (NULL 이 있는 행도 센다)
     COUNT(컬럼)  : 그 컬럼이 NULL 이 "아닌" 행의 개수
     SUM / AVG / MAX / MIN (컬럼) : 합계 / 평균 / 최댓값 / 최솟값
     ★ COUNT(*) 를 뺀 그룹 함수는 NULL 을 "무시"한다.
       예) AVG(HEIGHT) 는 키가 NULL 인 선수를 빼고 평균을 낸다. (0 으로 치지 않음)

   ▣ GROUP BY 컬럼
     - 그 컬럼 값이 같은 행끼리 한 그룹으로 묶고, 그룹마다 결과 1행을 만든다.
     - GROUP BY A, B 처럼 여러 개를 쓰면 (A, B) 조합이 같은 행끼리 묶인다.
     - 값이 NULL 인 행들도 하나의 그룹으로 묶인다.

   ▣ ★ 가장 많이 틀리는 규칙
     SELECT 에 그룹 함수가 아닌 일반 컬럼을 쓰면, 그 컬럼은 반드시 GROUP BY 에도 있어야 한다.
     → 어기면 ORA-00979 (not a GROUP BY expression)
       GROUP BY 없이 일반 컬럼과 그룹 함수를 섞으면 ORA-00937
     이유 : 그룹 하나는 결과 1행인데, 그룹 안에 값이 여러 개인 컬럼을
            어떤 값으로 보여 줄지 정할 수 없기 때문.

   ▣ WHERE vs HAVING
     WHERE  : 그룹으로 묶기 "전"에 행을 거른다. 그룹 함수를 쓸 수 없다. (ORA-00934)
     HAVING : 그룹으로 묶은 "후"에 그룹을 거른다. 그룹 함수를 조건에 쓴다.

   ▣ 실행 순서 (DQL.sql 맨 위 설명과 같은 내용)
     FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

   ▣ 사용 스키마 : K리그 → model.sql,  EMP / DEPT → emp_dept_salgrade.sql
   ████████████████████████████████████████████████████████████ */


/* ████ 테이블 하나로 그룹화 ████████████████████████████████████ */

/* ============================================================
   [1] 포지션별 평균 키 (단, 그 포지션의 최장신이 190cm 이상인 그룹만)
   ------------------------------------------------------------
   - GROUP BY POSITION : FW, MF, DF, GK ... 포지션마다 1행.
   - ROUND(AVG(HEIGHT), 2) : 평균 키를 소수 둘째 자리까지 반올림.
     함수 안에 함수를 넣을 수 있다. 안쪽(AVG)부터 계산된다.
   - HAVING MAX(HEIGHT) >= 190 : "그룹 안에서 가장 큰 키"가 190 이상인 포지션만 남긴다.
     → 그룹 함수로 거르는 조건이라 WHERE 가 아니라 HAVING 에 써야 한다.
   - 비교 : WHERE HEIGHT >= 190 이라고 쓰면 의미가 완전히 달라진다.
     "190 이상인 선수들만으로" 평균을 내게 된다. (행을 먼저 거르기 때문)
   - 포지션이 NULL 인 선수가 있다면 그들도 하나의 그룹(POSITION 이 빈칸)으로 묶인다.
     (그 그룹도 HAVING 조건을 만족해야 결과에 나온다)
   ============================================================ */
SELECT   POSITION, ROUND(AVG(HEIGHT), 2) 평균키
FROM     PLAYER
GROUP BY POSITION
HAVING   MAX(HEIGHT) >= 190;


/* ████ JOIN + GROUP BY ████████████████████████████████████████
   조인으로 먼저 테이블을 붙이고(FROM ~ ON), 붙은 결과를 그룹화한다.
   순서 : FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
   ████████████████████████████████████████████████████████████ */

/* ============================================================
   [2] 부서·직무별 직원 수, 급여 합계, 평균 급여 (평균 급여 2000 초과만)
   ------------------------------------------------------------
   - EMP 와 DEPT 를 조인해 부서번호 대신 부서 이름으로 묶는다.
   - GROUP BY D.DNAME, E.JOB : (부서, 직무) 조합마다 1행.
     예) (RESEARCH, ANALYST), (RESEARCH, CLERK) 는 서로 다른 그룹.
   - SELECT 의 일반 컬럼 D.DNAME, E.JOB 은 둘 다 GROUP BY 에 있으므로 규칙 OK.
   - COUNT(*) / SUM(E.SAL) / AVG(E.SAL) : 한 SELECT 에 그룹 함수 여러 개를 함께 쓸 수 있다.
   - HAVING AVG(E.SAL) > 2000 : 평균 급여가 2000 초과인 "조합"만 남긴다.
   - ORDER BY D.DNAME ASC, E.JOB ASC : 부서명순, 같은 부서 안에서는 직무명순.
   ============================================================ */
SELECT   D.DNAME     AS 부서명,
         E.JOB       AS 직무,
         COUNT(*)    AS 직원수,
         SUM(E.SAL)  AS 급여합계,
         AVG(E.SAL)  AS 평균급여
FROM     EMP E
         JOIN DEPT D ON E.DEPTNO = D.DEPTNO
GROUP BY D.DNAME, E.JOB
HAVING   AVG(E.SAL) > 2000
ORDER BY D.DNAME ASC, E.JOB ASC;


/* ============================================================
   [3] 팀별 선수 수
   ------------------------------------------------------------
   - JOIN.sql [12] 의 "팀별 선수 명단"을 GROUP BY 로 묶어 개수만 센 것.
     명단(여러 행) → 팀마다 1행 + COUNT(*).
   - COUNT(*) : 그룹(팀) 안의 행 수 = 그 팀 선수 수.
   - 팁 : 팀 이름이 같은 팀이 둘 있으면 한 그룹으로 합쳐져 버린다.
     더 안전하게 쓰려면 [4] 처럼 GROUP BY T.TEAM_ID, T.TEAM_NAME 으로
     고유한 ID 를 함께 묶는다.
   ============================================================ */
SELECT   T.TEAM_NAME AS 팀명,
         COUNT(*)    AS 선수수
FROM     PLAYER P
         JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
GROUP BY T.TEAM_NAME
ORDER BY T.TEAM_NAME;


/* ============================================================
   [4] 경기장별 경기 수 (경기가 5번 이상인 경기장만)
   ------------------------------------------------------------
   - JOIN.sql [13] 의 경기 일정을 경기장마다 묶어 개수를 센 것.
   - ★ GROUP BY S.STADIUM_ID, S.STADIUM_NAME
     SELECT 에 STADIUM_NAME 도 출력하므로 GROUP BY 에도 넣어야 한다.
     (ID 만 묶고 NAME 을 빼면 ORA-00979)
     ID 하나에 이름이 하나뿐이라 그룹 수는 ID 로만 묶을 때와 같다.
   - HAVING COUNT(*) >= 5 : 그룹 함수 조건이므로 HAVING.
   - COUNT(*) 는 점수가 NULL 인 "아직 안 한 경기"도 센다. (행 자체를 세기 때문)
     실제로 치른 경기만 세려면 COUNT(SC.HOME_SCORE) 처럼 컬럼을 지정하면 된다.
   ============================================================ */
SELECT   S.STADIUM_ID   AS 경기장ID,
         S.STADIUM_NAME AS 경기장이름,
         COUNT(*)       AS 경기수
FROM     SCHEDULE SC
         JOIN STADIUM S ON SC.STADIUM_ID = S.STADIUM_ID
GROUP BY S.STADIUM_ID, S.STADIUM_NAME
HAVING   COUNT(*) >= 5
ORDER BY S.STADIUM_ID;


/* ============================================================
   [5] 경기장·홈팀별 경기 횟수와 홈팀 득점 합계 (테이블 3개 + 그룹 2개 컬럼)
   ------------------------------------------------------------
   - SCHEDULE 을 중심으로 STADIUM(경기장 이름), TEAM(홈팀 이름)을 조인.
   - GROUP BY 경기장이름, 홈팀명 : (경기장, 홈팀) 조합마다 1행.
     한 경기장을 여러 팀이 홈으로 썼다면 그 경기장은 여러 행으로 나온다.
   - COUNT(*) 와 SUM(HOME_SCORE) 의 차이 (★ NULL 처리)
       COUNT(*)           : 미경기(점수 NULL) 행도 1경기로 센다.
       SUM(SC.HOME_SCORE) : NULL 점수는 무시하고 실제 점수만 더한다.
       그룹의 점수가 전부 NULL 이면 SUM 결과도 0 이 아니라 NULL.
   ============================================================ */
SELECT   S.STADIUM_NAME     AS 경기장이름,
         T.TEAM_NAME        AS 홈팀명,
         COUNT(*)           AS 경기횟수,
         SUM(SC.HOME_SCORE) AS 점수합계
FROM     SCHEDULE SC
         JOIN STADIUM S ON SC.STADIUM_ID  = S.STADIUM_ID
         JOIN TEAM T    ON SC.HOMETEAM_ID = T.TEAM_ID
GROUP BY S.STADIUM_NAME, T.TEAM_NAME
ORDER BY S.STADIUM_NAME, T.TEAM_NAME;


/* ============================================================
   [6] 경기장·팀별 선수 수와 평균 키
   ------------------------------------------------------------
   - PLAYER → TEAM → STADIUM 순서로 조인 (JOIN.sql [10] 과 같은 연결 경로).
     여기서 경기장은 "팀의 홈 경기장"(TEAM.STADIUM_ID)이다.
   - GROUP BY 경기장이름, 팀명 : (경기장, 팀) 조합마다 1행.
   - COUNT(*) : 그 팀 선수 수.
   - ROUND(AVG(P.HEIGHT), 2) : 키가 NULL 인 선수는 평균 계산에서 빠진다.
     그래서 "선수수"로 나눈 값과 다를 수 있다. (분모가 키가 있는 선수 수)
   ============================================================ */
SELECT   S.STADIUM_NAME         AS 경기장이름,
         T.TEAM_NAME            AS 팀명,
         COUNT(*)               AS 선수수,
         ROUND(AVG(P.HEIGHT), 2) AS 평균키
FROM     PLAYER P
         JOIN TEAM T    ON P.TEAM_ID    = T.TEAM_ID
         JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID
GROUP BY S.STADIUM_NAME, T.TEAM_NAME
ORDER BY S.STADIUM_NAME, T.TEAM_NAME;
