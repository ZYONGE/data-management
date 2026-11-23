/* ████████████████████████████████████████████████████████████
   DDL — 데이터 정의어 (Data Definition Language)
   ------------------------------------------------------------
   테이블 같은 "객체(object)" 자체를 만들고, 바꾸고, 지우는 명령.
   CREATE / ALTER / DROP / TRUNCATE 가 여기에 속한다.

   DDL은 실행하는 순간 자동으로 커밋(auto-commit)된다.
   → ROLLBACK 으로 되돌릴 수 없으므로 실행 전에 한 번 더 확인할 것.

   ※ 실습 스키마(STADIUM / TEAM / SCHEDULE / PLAYER)를 만드는
     DDL은 model.sql 에 따로 들어 있다. 이 파일은 수업 중 직접
     작성한 DDL만 모아 둔다.

   목차
     [1] DESC            [2] DROP TABLE        [3] CTAS (구조만 복사)
     [4]~[7] CREATE TABLE + 제약조건 (PK / NOT NULL / UNIQUE / CHECK / FK / DEFAULT)
     [8]~[9] ALTER TABLE 로 컬럼 추가·변경·이름변경·삭제, RENAME
     [10]~[11] 제약조건 추가·삭제 (ADD / DROP CONSTRAINT, ON DELETE CASCADE)

   ※ 실행 순서 주의 : [9], [10] 은 "복사할 원본 데이터"가 있어야 결과가 보인다.
     [4]~[8] 실행 → DML.sql [9]~[10] 으로 데이터 넣기 → [9]~[11] 실행
     → DML.sql [11] (CASCADE 확인) 순서로 돌리면 수업 때와 같은 결과가 나온다.
   ████████████████████████████████████████████████████████████ */


/* ============================================================
   [1] 테이블 구조 확인 : DESCRIBE / DESC
   ------------------------------------------------------------
   문법 : DESCRIBE 테이블명;   (축약형 DESC 테이블명;)
   - 테이블의 컬럼명, NULL 허용 여부(NOT NULL), 데이터 타입을 보여준다.
   - 데이터를 조회하는 것이 아니라 "구조(스키마)"를 확인하는 명령이다.
   - 엄밀히 말하면 SQL 표준 문장이 아니라 Oracle(SQL*Plus /
     SQL Developer)이 제공하는 도구 명령이라서 DBMS마다 지원이 다르다.
     그래서 끝에 세미콜론이 없어도 동작한다.
   - 테이블명은 대소문자를 구분하지 않는다. (TEAM = team)
   ============================================================ */
describe TEAM;      -- 정식 표기
desc TEAM;          -- 축약 표기 (결과는 위와 동일)
desc stadium;       -- 경기장 테이블 구조
desc schedule;      -- 경기 일정 테이블 구조
desc player;        -- 선수 테이블 구조


/* ============================================================
   [2] 테이블 삭제 : DROP TABLE ... PURGE
   ------------------------------------------------------------
   문법 : DROP TABLE [IF EXISTS] 테이블명 [PURGE];
   - 테이블의 데이터와 구조를 통째로 제거한다.
   - IF EXISTS : 테이블이 없어도 오류 없이 그냥 넘어간다.
     (Oracle 23ai 이상에서 지원. 그 이전 버전에서는 문법 오류가 난다.)
   - PURGE : 휴지통(recyclebin)을 거치지 않고 즉시 완전 삭제한다.
     PURGE를 빼면 BIN$... 이름으로 휴지통에 남아 용량을 계속 차지한다.
   - 스크립트를 여러 번 돌려도 깨지지 않게 하려고 CREATE 앞에 둔다.
   ============================================================ */
DROP TABLE IF EXISTS PLAYER_PRACTICE PURGE;


/* ============================================================
   [3] 조회 결과로 테이블 만들기 : CREATE TABLE ... AS SELECT (CTAS)
   ------------------------------------------------------------
   문법 : CREATE TABLE 새테이블명 AS SELECT ... FROM 원본테이블 ...;
   - SELECT 결과의 "컬럼 구조 + 데이터"를 그대로 가진 새 테이블을 만든다.
   - 컬럼명과 데이터 타입을 일일이 적지 않아도 되는 것이 장점.
   - WHERE 1 = 0 : 항상 거짓인 조건이라 단 한 행도 복사되지 않는다.
     → 데이터는 빼고 "구조만" 똑같이 복제하는 관용적인 수법.
   - 주의 : 복사되는 것은 컬럼과 데이터뿐이고,
     기본키·외래키·인덱스 같은 제약조건은 따라오지 않는다.
     (NOT NULL 만 예외적으로 따라온다.)
   ============================================================ */
CREATE TABLE PLAYER_PRACTICE AS
SELECT *
FROM PLAYER
WHERE 1 = 0;


/* ████ CREATE TABLE — 제약조건을 붙여 테이블 만들기 ████████████

   제약조건(constraint) : 테이블에 "잘못된 데이터가 들어오지 못하게" 거는 규칙.
     PRIMARY KEY : 행을 하나로 식별하는 키. NOT NULL + UNIQUE 가 자동으로 함께 걸린다.
                   테이블당 하나만 만들 수 있다. (컬럼 여러 개를 묶은 복합키는 가능)
     NOT NULL    : 값을 반드시 넣어야 한다.
     UNIQUE      : 같은 값이 두 번 들어갈 수 없다. 단, NULL 은 여러 개 허용.
     CHECK       : 조건식이 참인 값만 들어갈 수 있다.
     FOREIGN KEY : 다른 테이블(부모)의 PK/UNIQUE 컬럼에 실제로 있는 값만 허용.

   위반하면 나오는 오류 번호 (메시지를 읽을 줄 알아야 한다)
     ORA-00001 : PK / UNIQUE 중복
     ORA-01400 : NOT NULL 컬럼에 NULL 삽입
     ORA-02290 : CHECK 조건 위반
     ORA-02291 : FK - 부모에 없는 값을 자식에 넣음
     ORA-02292 : FK - 자식이 참조 중인 부모 행을 지우려 함
   ████████████████████████████████████████████████████████████ */

/* ============================================================
   [4] 학생 테이블 : 컬럼 옆에 제약조건 쓰기 (PK / NOT NULL / UNIQUE)
   ------------------------------------------------------------
   문법 : CREATE TABLE 테이블명 (
              컬럼명 데이터타입 [제약조건 ...],
              ...
          );
   - student_id INT PRIMARY KEY : INT 는 Oracle 에서 NUMBER(38) 로 바뀌어 저장된다.
     (다른 DBMS 와 호환되도록 받아 주는 이름일 뿐)
   - email ... NOT NULL UNIQUE : 제약조건은 여러 개를 나란히 붙일 수 있다.
     → "반드시 있어야 하고, 다른 학생과 겹치면 안 되는" 값.
   - 제약조건에 이름을 안 붙이면 Oracle 이 SYS_C0012345 같은 이름을 자동으로 붙인다.
     (이름을 직접 붙이는 방법은 [5] 참고)
   - 맨 앞 DROP : STUDENT 가 아직 없으면 ORA-00942 (table or view does not exist)
     가 나지만, 처음 한 번은 정상이다. 다시 실행해도 되게 하려고 넣은 것.
   - 데이터 넣기 → DML.sql [9]
   ============================================================ */
DROP TABLE STUDENT PURGE;

CREATE TABLE STUDENT (
    student_id    INT           PRIMARY KEY,
    name          VARCHAR2(50)  NOT NULL,
    email         VARCHAR2(100) NOT NULL UNIQUE,
    date_of_birth DATE,
    major         VARCHAR2(50)
);


/* ============================================================
   [5] 상품 테이블 : 제약조건에 이름 붙이기 + CHECK
   ------------------------------------------------------------
   문법 : 컬럼명 타입 CONSTRAINT 제약조건이름 제약조건종류
   - CONSTRAINT PRODUCT_PK PRIMARY KEY : 제약조건에 이름을 직접 붙인 형태.
     장점 ① 오류가 나면 "ORA-00001: unique constraint (PRODUCT_PK) violated" 처럼
             어떤 규칙을 어겼는지 이름으로 바로 알 수 있다.
          ② 나중에 ALTER TABLE ... DROP CONSTRAINT 이름 으로 지울 수 있다. ([11] 참고)
     이름 짓기 관례 : 테이블명_PK, 테이블명_컬럼_CK, 테이블명_FK
   - CHECK (PRICE > 0) : 가격은 0 보다 커야 한다. 0 이나 음수를 넣으면 ORA-02290.
   - 데이터 타입
       NUMBER(5)     : 소수점 없는 최대 5자리 정수
       NUMBER(10)    : 최대 10자리 정수 (소수점 이하 자리가 0 이라 소수는 반올림되어 저장)
       VARCHAR2(50)  : 최대 50바이트 가변 길이 문자열 (한글은 보통 한 글자 3바이트)
   - CATEGORY, STOCK 처럼 제약조건이 없는 컬럼은 NULL 도 허용된다.
   ============================================================ */
CREATE TABLE PRODUCT (
    PRODUCT_ID   NUMBER(5)    CONSTRAINT PRODUCT_PK PRIMARY KEY,
    PRODUCT_NAME VARCHAR2(50) NOT NULL,
    PRICE        NUMBER(10)   CONSTRAINT PRODUCT_PRICE_CK CHECK (PRICE > 0),
    CATEGORY     VARCHAR2(30),
    STOCK        NUMBER(5)
);


/* ============================================================
   [6] 주문 테이블 : 외래키(FK) + DEFAULT + 테이블 레벨 제약조건
   ------------------------------------------------------------
   문법 : CONSTRAINT 이름 FOREIGN KEY (자식컬럼) REFERENCES 부모테이블(부모컬럼)
   - 컬럼 옆에 쓰면 "컬럼 레벨", 컬럼 정의가 다 끝난 뒤 따로 쓰면 "테이블 레벨" 제약조건.
     여기서 FK 는 테이블 레벨로 썼다.
     (여러 컬럼에 걸친 제약은 테이블 레벨로만, NOT NULL 은 컬럼 레벨로만 쓸 수 있다)
   - FK 의 의미 : ORDERS.PRODUCT_ID 는 PRODUCT 에 실제로 있는 상품번호이거나 NULL 이어야 한다.
       PRODUCT = 부모 테이블 (참조 "당하는" 쪽)
       ORDERS  = 자식 테이블 (참조 "하는" 쪽)
     - 없는 상품번호로 주문을 넣으면 ORA-02291
     - 주문이 남아 있는 상품을 지우려 하면 ORA-02292
     - 그래서 테이블은 부모 → 자식 순으로 만들고, 지울 때는 자식 → 부모 순으로 지운다.
   - CHECK (QUANTITY >= 1) : 수량은 1개 이상.
   - DEFAULT SYSDATE : INSERT 때 이 컬럼을 "생략하면" 현재 날짜·시간이 자동으로 들어간다.
     (VALUES 에 직접 NULL 이라고 쓰면 DEFAULT 가 아니라 NULL 이 들어간다)
   - FK 이름을 ORDERS_FK 로 정해 둔 이유 : [11] 에서 이 이름으로 지우고 다시 만들기 위해.
   ============================================================ */
CREATE TABLE ORDERS (
    ORDER_ID   NUMBER(5) CONSTRAINT ORDERS_PK PRIMARY KEY,
    PRODUCT_ID NUMBER(5),
    QUANTITY   NUMBER(5) CONSTRAINT ORDERS_QTY_CK CHECK (QUANTITY >= 1),
    ORDER_DATE DATE      DEFAULT SYSDATE,
    CONSTRAINT ORDERS_FK FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(PRODUCT_ID)
);


/* ============================================================
   [7] 리뷰 테이블 : ON DELETE CASCADE (상품이 지워지면 리뷰도 함께 삭제)
   ------------------------------------------------------------
   - FK 를 만들 때 "부모 행이 지워지면 자식 행을 어떻게 할지" 정할 수 있다.
       (옵션 없음)         : 자식이 있으면 부모를 지울 수 없다 → ORA-02292
       ON DELETE CASCADE   : 부모를 지우면 그 부모를 참조하는 자식도 자동으로 삭제
       ON DELETE SET NULL  : 부모를 지우면 자식은 남기고 FK 컬럼만 NULL 로 바꿈
   - 리뷰는 상품이 없어지면 의미가 없으므로 CASCADE 가 자연스럽다.
   - 동작 확인 실습 → DML.sql [11] (ORDERS 에 CASCADE 를 걸고 확인)
   ============================================================ */
CREATE TABLE PRODUCT_REVIEW (
    REVIEW_ID   NUMBER(5)     CONSTRAINT PRODUCT_REVIEW_PK PRIMARY KEY,
    PRODUCT_ID  NUMBER(5),
    REVIEW_TEXT VARCHAR2(200),
    CONSTRAINT PRODUCT_REVIEW_FK FOREIGN KEY (PRODUCT_ID)
        REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE
);


/* ████ ALTER TABLE — 이미 있는 테이블의 구조 바꾸기 ██████████████ */

/* ============================================================
   [8] 컬럼 추가 → 크기 변경 → 이름 변경 → 삭제
   ------------------------------------------------------------
   문법
     ALTER TABLE 테이블 ADD    (컬럼 타입);              -- 컬럼 추가
     ALTER TABLE 테이블 MODIFY (컬럼 새타입);            -- 타입·크기 변경
     ALTER TABLE 테이블 RENAME COLUMN 옛이름 TO 새이름;  -- 컬럼 이름 변경
     ALTER TABLE 테이블 DROP COLUMN 컬럼;                -- 컬럼 삭제
   - ADD : 새 컬럼은 항상 "맨 뒤"에 붙는다. 기존 행의 값은 NULL.
           NUMBER(3,2) = 전체 3자리 중 소수점 아래 2자리 → -9.99 ~ 9.99 (할인율 0.15 같은 값)
   - MODIFY : VARCHAR2(50) → VARCHAR2(100) 처럼 크기를 "늘리는" 것은 언제나 된다.
              줄이거나 타입을 바꾸는 것은 기존 데이터가 새 규칙에 맞아야만 된다.
   - DROP COLUMN : 컬럼과 그 안의 데이터가 함께 사라진다. 되돌릴 수 없다. (DDL 이므로)
   - DESC 로 마지막 구조를 확인 → DISCOUNT 는 추가됐다가 지워졌으니 원래 구조 +
     PRODUCT_NAME 의 크기만 100 으로 바뀌어 있어야 한다.
   ============================================================ */
ALTER TABLE PRODUCT ADD (DISCOUNT_RATE NUMBER(3,2));
ALTER TABLE PRODUCT MODIFY (PRODUCT_NAME VARCHAR2(100));
ALTER TABLE PRODUCT RENAME COLUMN DISCOUNT_RATE TO DISCOUNT;
ALTER TABLE PRODUCT DROP COLUMN DISCOUNT;

DESC PRODUCT;


/* ============================================================
   [9] 테이블 복사 후 학번 컬럼을 새로 만들어 교체하기 (CTAS + ALTER + RENAME)
   ------------------------------------------------------------
   ※ 선행 : [4] 로 STUDENT 를 만들고 DML.sql [9] 로 데이터를 넣어 둘 것.
     STUDENT 가 비어 있으면 복사본도 비어서 결과가 0건이다.

   한 줄씩 무슨 일이 일어나는지
   ① CREATE TABLE ... AS SELECT * : STUDENT 의 컬럼과 데이터를 그대로 복사한
      STUDENT_TEMP 를 만든다. ★ PK·UNIQUE 는 복사되지 않는다. (NOT NULL 만 복사)
   ② ADD : 새 학번용 컬럼 std_tmp_id 추가. 모든 행에서 값은 NULL.
   ③ DROP COLUMN : 기존 학번 student_id 삭제. (데이터도 함께 사라진다)
   ④ RENAME COLUMN : std_tmp_id → std_new_id 로 이름 변경.
   ⑤ MODIFY : VARCHAR2(20) → NUMBER(10) 으로 타입 변경.
      ★ 데이터 타입을 바꾸려면 그 컬럼이 비어 있어야(전부 NULL) 한다.
        방금 추가해서 아직 NULL 뿐이므로 가능하다. 값이 있었다면 ORA-01439.
   ⑥ UPDATE ... SET = ROWNUM : ROWNUM 은 행을 읽은 순서대로 1, 2, 3 ... 을 매기는
      가상 컬럼(의사 컬럼). 이것으로 새 학번을 1부터 채운다.
      (이 문장만 DDL 이 아니라 DML 이다. 흐름상 여기 함께 둔 것)
   ⑦ ADD CONSTRAINT ... PRIMARY KEY : 값이 다 채워졌으니 이제 PK 를 건다.
      값이 비어 있거나 중복이면 PK 를 걸 수 없다. 그래서 ⑥ 다음에 와야 한다.
   ⑧ RENAME 옛이름 TO 새이름 : 테이블 이름을 바꾼다.
      (ALTER TABLE STUDENT_TEMP RENAME TO STUDENT_NEW; 로도 같은 일을 할 수 있다)

   - 다시 실행할 때 : STUDENT_NEW 가 이미 있으면 ⑧ 에서 ORA-00955
     (name is already used) 가 난다. DROP TABLE STUDENT_NEW PURGE; 를 먼저 실행할 것.
   ============================================================ */
CREATE TABLE STUDENT_TEMP AS SELECT * FROM STUDENT;                        -- ①
ALTER TABLE STUDENT_TEMP ADD (std_tmp_id VARCHAR2(20));                    -- ②
ALTER TABLE STUDENT_TEMP DROP COLUMN student_id;                           -- ③
ALTER TABLE STUDENT_TEMP RENAME COLUMN std_tmp_id TO std_new_id;           -- ④
ALTER TABLE STUDENT_TEMP MODIFY (std_new_id NUMBER(10));                   -- ⑤
UPDATE STUDENT_TEMP SET std_new_id = ROWNUM;                               -- ⑥
ALTER TABLE STUDENT_TEMP ADD CONSTRAINT student_temp_pk PRIMARY KEY (std_new_id);  -- ⑦
RENAME STUDENT_TEMP TO STUDENT_NEW;                                        -- ⑧

SELECT * FROM STUDENT_NEW ORDER BY std_new_id;


/* ████ 제약조건 추가 · 삭제 ████████████████████████████████████ */

/* ============================================================
   [10] 조건에 맞는 행만 복사한 테이블에 제약조건 다시 걸기
   ------------------------------------------------------------
   ※ 선행 : DML.sql [10] 으로 PRODUCT 에 데이터를 넣은 뒤 실행해야 행이 복사된다.
     (수업 순서대로면 Laptop, Desk 2건이 복사됨)

   - CTAS + WHERE : 가격 100000 이상인 상품만 골라서 새 테이블로 만든다.
     복사 "시점"의 데이터가 들어간다. 나중에 PRODUCT 가 바뀌어도 이 테이블은 그대로.
   - CTAS 로 만든 테이블에는 PK, CHECK 가 없다. → ALTER TABLE 로 직접 추가.
       ADD CONSTRAINT ... PRIMARY KEY (컬럼) : 기존 데이터에 중복·NULL 이 있으면 실패.
       ADD CONSTRAINT ... CHECK (조건)       : 기존 데이터가 조건을 어기면 ORA-02293.
   - NOT NULL 은 ADD CONSTRAINT 가 아니라 MODIFY (컬럼 NOT NULL) 로 건다.
     (NOT NULL 은 "컬럼의 속성"처럼 다루기 때문)
   - ★ 시험 포인트 : 원본 PRODUCT 의 PRODUCT_NAME 은 이미 NOT NULL 이었다.
     CTAS 는 NOT NULL 만큼은 복사해 오므로 EXPENSIVE_PRODUCT.PRODUCT_NAME 도
     이미 NOT NULL 이다. 그래서 마지막 MODIFY 는
     ORA-01442 (column to be modified to NOT NULL is already NOT NULL) 가 날 수 있다.
     → DESC 결과에서 PRODUCT_NAME 이 "NOT NULL" 로 나오는지 확인해 볼 것.
   ============================================================ */
CREATE TABLE EXPENSIVE_PRODUCT AS
SELECT PRODUCT_ID, PRODUCT_NAME, PRICE
FROM PRODUCT
WHERE PRICE >= 100000;

SELECT * FROM EXPENSIVE_PRODUCT;

ALTER TABLE EXPENSIVE_PRODUCT ADD CONSTRAINT EXPENSIVE_PRODUCT_PK PRIMARY KEY (PRODUCT_ID);
ALTER TABLE EXPENSIVE_PRODUCT ADD CONSTRAINT EXPENSIVE_PRODUCT_PRICE_CK CHECK (PRICE >= 100000);
ALTER TABLE EXPENSIVE_PRODUCT MODIFY (PRODUCT_NAME NOT NULL);

DESC EXPENSIVE_PRODUCT;


/* ============================================================
   [11] FK 를 지우고 ON DELETE CASCADE 로 다시 만들기
   ------------------------------------------------------------
   문법 : ALTER TABLE 테이블 DROP CONSTRAINT 제약조건이름;
          ALTER TABLE 테이블 ADD CONSTRAINT 이름 FOREIGN KEY (컬럼)
                REFERENCES 부모(컬럼) [ON DELETE CASCADE];
   - 이미 만든 FK 의 ON DELETE 규칙은 "고칠" 수 없다. 지우고 새로 만들어야 한다.
   - 지울 때 제약조건 "이름"이 필요하다 → [6] 에서 ORDERS_FK 라고 이름을 붙여 둔 이유.
     (이름을 모르면 USER_CONSTRAINTS 딕셔너리 뷰에서 찾아야 한다)
   - 이후 주문 넣기 → 상품 삭제 → 주문도 같이 지워지는지 확인 : DML.sql [11]
   ============================================================ */
ALTER TABLE ORDERS DROP CONSTRAINT ORDERS_FK;
ALTER TABLE ORDERS ADD CONSTRAINT ORDERS_FK FOREIGN KEY (PRODUCT_ID)
    REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE;
