<div align="center">

# DataManagement

Source code for the **Data Management** course

</div>

### Programming Languages
<div>
  <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logoColor=white" alt="SQL" />
</div>

### Database
<div>
  <img src="https://img.shields.io/badge/Oracle%20Database-F80000?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU%2BT3JhY2xlPC90aXRsZT48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTE2LjQxMiA0LjQxMmgtOC44MmE3LjU4OCA3LjU4OCAwIDAgMC0uMDA4IDE1LjE3Nmg4LjgyOGE3LjU4OCA3LjU4OCAwIDAgMCAwLTE1LjE3NnptLS4xOTMgMTIuNTAySDcuNzg2YTQuOTE1IDQuOTE1IDAgMCAxIDAtOS44MjhoOC40MzNhNC45MTQgNC45MTQgMCAxIDEgMCA5LjgyOHoiLz48L3N2Zz4%3D" alt="Oracle Database" />
</div>

### Version Control
<div>
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" alt="Git" />
  <img src="https://img.shields.io/badge/GitHub-586069?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
</div>

### IDE
<div>
  <img src="https://img.shields.io/badge/Visual%20Studio%20Code-007ACC?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU%2BVmlzdWFsIFN0dWRpbyBDb2RlPC90aXRsZT48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTIzLjE1IDIuNTg3TDE4LjIxLjIxYTEuNDk0IDEuNDk0IDAgMCAwLTEuNzA1LjI5bC05LjQ2IDguNjMtNC4xMi0zLjEyOGEuOTk5Ljk5OSAwIDAgMC0xLjI3Ni4wNTdMLjMyNyA3LjI2MUExIDEgMCAwIDAgLjMyNiA4Ljc0TDMuODk5IDEyIC4zMjYgMTUuMjZhMSAxIDAgMCAwIC4wMDEgMS40NzlMMS42NSAxNy45NGEuOTk5Ljk5OSAwIDAgMCAxLjI3Ni4wNTdsNC4xMi0zLjEyOCA5LjQ2IDguNjNhMS40OTIgMS40OTIgMCAwIDAgMS43MDQuMjlsNC45NDItMi4zNzdBMS41IDEuNSAwIDAgMCAyNCAyMC4wNlYzLjkzOWExLjUgMS41IDAgMCAwLS44NS0xLjM1MnptLTUuMTQ2IDE0Ljg2MUwxMC44MjYgMTJsNy4xNzgtNS40NDh2MTAuODk2eiIvPjwvc3ZnPg%3D%3D" alt="Visual Studio Code" />
  <img src="https://img.shields.io/badge/Oracle%20SQL%20Developer-C74634?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU%2BT3JhY2xlPC90aXRsZT48cGF0aCBmaWxsPSJ3aGl0ZSIgZD0iTTE2LjQxMiA0LjQxMmgtOC44MmE3LjU4OCA3LjU4OCAwIDAgMC0uMDA4IDE1LjE3Nmg4LjgyOGE3LjU4OCA3LjU4OCAwIDAgMCAwLTE1LjE3NnptLS4xOTMgMTIuNTAySDcuNzg2YTQuOTE1IDQuOTE1IDAgMCAxIDAtOS44MjhoOC40MzNhNC45MTQgNC45MTQgMCAxIDEgMCA5LjgyOHoiLz48L3N2Zz4%3D" alt="Oracle SQL Developer" />
</div>

### AI Agents
<div>
  <img src="https://img.shields.io/badge/Claude%20Code-D97757?style=for-the-badge&logo=claude&logoColor=white" alt="Claude Code" />
</div>

---
## Project Overview
**Course:** Data Management  
**University:** Tech University of Korea (TUK)

This repository contains Oracle SQL practice code written while studying Data Management.
Most exercises run against a K League soccer sample schema (`STADIUM`, `TEAM`, `SCHEDULE`, `PLAYER`) created by [model.sql](model.sql).
The join, grouping and set-operation exercises also use the classic `EMP` / `DEPT` / `SALGRADE` schema created by [emp_dept_salgrade.sql](emp_dept_salgrade.sql).

The purpose of this project is to:

- build a practice schema with DDL and load sample data with DML
- practice core SQL querying (`SELECT`, `WHERE`, `ORDER BY`) on Oracle
- practice joins, `GROUP BY` / `HAVING`, and set operators
- keep lecture exercises organised by topic (DDL / DML / DQL / JOIN / GROUP BY / SET OPERATION)

---
## Project Structure

```
DataManagement/
├── model.sql              # K League schema: DROP/CREATE tables + sample data INSERTs
├── emp_dept_salgrade.sql  # EMP / DEPT / SALGRADE schema for join & grouping exercises
├── DDL.sql                # Data Definition: DESC, DROP, CTAS, CREATE with constraints, ALTER, RENAME
├── DML.sql                # Data Manipulation: INSERT, INSERT ALL, UPDATE, DELETE, ON DELETE CASCADE, COMMIT
├── DQL.sql                # Data Query: SELECT, operators, LIKE, BETWEEN, IN, NOT
├── JOIN.sql               # Joins: INNER, OUTER, CROSS, SELF, Non-EQUI, multi-table, CASE
├── GROUP_BY.sql           # Aggregate functions, GROUP BY, HAVING (with joins)
├── SET_OPERATION.sql      # UNION / UNION ALL / INTERSECT / MINUS
├── LICENSE                # MIT License
├── .gitignore
└── README.md
```

Files are organised by topic, not by lecture date.
Every statement carries a comment (in Korean) explaining what it does, written as exam-study notes.

Run order when starting from an empty schema:
`model.sql` → `emp_dept_salgrade.sql` → `DDL.sql` → `DML.sql` → `DQL.sql` → `JOIN.sql` → `GROUP_BY.sql` → `SET_OPERATION.sql`

Some `DDL.sql` blocks copy data from tables filled in `DML.sql`; the header of `DDL.sql` gives the exact interleaving order.

---
## Practice Schema (`model.sql`)

| Table | Description | Primary Key | Foreign Key | Rows |
|-------|-------------|-------------|-------------|-----:|
| `STADIUM`  | Stadium info (name, home team, seats, address) | `STADIUM_ID` | – | 20 |
| `TEAM`     | Team info (region, name, founding year, contact) | `TEAM_ID` | `STADIUM_ID` → `STADIUM` | 15 |
| `SCHEDULE` | Match schedule and scores | `STADIUM_ID`, `SCHE_DATE` | `STADIUM_ID` → `STADIUM` | 180 |
| `PLAYER`   | Player info (position, back number, height, weight) | `PLAYER_ID` | `TEAM_ID` → `TEAM` | 480 |

```
STADIUM ─┬─< TEAM ─< PLAYER
         └─< SCHEDULE
```

The script drops the tables in reverse dependency order (`PLAYER` → `SCHEDULE` → `TEAM` → `STADIUM`) before recreating them, so it can be re-run to reset the practice data.

---
## What I Learned

### DDL — Defining Tables
- `CREATE TABLE` with Oracle data types: `CHAR`, `VARCHAR2`, `NUMBER(p)`
- `NOT NULL` constraints
- `PRIMARY KEY` constraints, including a composite key (`SCHEDULE`)
- `FOREIGN KEY ... REFERENCES` to link tables
- `DROP TABLE` order when foreign keys exist (child tables first)

### DML / TCL — Loading Data
- Inserting sample rows with `INSERT INTO ... VALUES`
- Making changes permanent with `COMMIT`

### Checking the Environment and Table Structure
- `SELECT * FROM HELP` to confirm the Oracle connection works
- `DESCRIBE` / `DESC` to see column names, nullability, and types
- `DESC` is a SQL\*Plus / SQL Developer command, not standard SQL

### SELECT Basics
- Selecting all columns with `*` vs. listing only needed columns
- Column aliases with `AS` (optional keyword, double quotes for spaces/case)
- Sorting with `ORDER BY ... ASC | DESC`
  - `ASC` is the default
  - In Oracle, `NULL` sorts last in `ASC` and first in `DESC`
  - Character columns sort lexicographically (`'9'` > `'10'`)
  - A column can be used in `ORDER BY` without being in the `SELECT` list
- Filtering rows with `WHERE`
  - String literals use single quotes, and values are case-sensitive (`'mf'` ≠ `'MF'`)
  - Written order: `SELECT → FROM → WHERE → ORDER BY`
  - Execution order: `FROM → WHERE → SELECT → ORDER BY`

### Constraints and ALTER TABLE
- Named constraints (`CONSTRAINT name ...`): `PRIMARY KEY`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `DEFAULT`
- Column-level vs table-level constraint syntax
- `ON DELETE CASCADE` and what happens without it (`ORA-02292`)
- `ALTER TABLE ... ADD / MODIFY / RENAME COLUMN / DROP COLUMN`, `RENAME` for tables
- `CREATE TABLE ... AS SELECT` copies only `NOT NULL` constraints

### Joins
- Oracle (`FROM A, B WHERE`) vs ANSI (`JOIN ... ON`) syntax
- `INNER`, `LEFT` / `RIGHT` / `FULL OUTER`, `CROSS`, `SELF`, and Non-EQUI joins
- Joining three tables and chaining `LEFT OUTER JOIN`s
- `CASE` expressions in the `SELECT` list

### Grouping
- Aggregate functions and how they treat `NULL` (`COUNT(*)` vs `COUNT(col)`)
- `GROUP BY` on one or more columns, filtering groups with `HAVING`
- Every non-aggregated `SELECT` column must appear in `GROUP BY`

### Set Operations
- `UNION` vs `UNION ALL`, `INTERSECT`, `MINUS`
- `FULL OUTER JOIN` = `LEFT OUTER JOIN` `UNION` `RIGHT OUTER JOIN`

---
## How to Run

1. Connect to an Oracle Database in Oracle SQL Developer (or SQL\*Plus).
2. Run [model.sql](model.sql) as a script to create the tables and load the sample data.
   - On the very first run the `DROP TABLE` lines fail because the tables don't exist yet; that is expected.
3. Run [emp_dept_salgrade.sql](emp_dept_salgrade.sql) for the join / grouping / set-operation exercises.
4. Open a topic file (e.g. [JOIN.sql](JOIN.sql)) and run each statement.

---

## License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.


## Author
Name: Jiyong Kim (ZYONGE)  
Profile: https://github.com/ZYONGE  

## Motivation
For A+ !!!
