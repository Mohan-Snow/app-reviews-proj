## ПОЧИТАТЬ!!!!
1. with clause - cte - common table expression (?)
2. select for update (?)
3. vaccum, rebuild index (прочитать в контексте postgres)
4. репликация баз данных
5. знать капасити SERIAL и BIGSERIAL
6. username VARCHAR(255) NOT NULL, // найти доп инфу про различия
7. created_at TIMESTAMP NOT NULL DEFAULT NOW(), // разобраться с таймзонами. как храниться? Чем отличается timestamp от timestampTZ?

---

## Some Post Mortem:
**ERROR:**
data type character varying has no default operator class for access method "gin"
You must specify an operator class for the index or define a default operator class for the data type.

**SOLUTION:**
For full text search use:
```postgresql
CREATE INDEX test_gin_idx ON test USING gin (to_tsvector('english', the_text));
```

For trigram search you can use pg_trgm extension
```postgresql
CREATE EXTENSION pg_trgm;
CREATE INDEX test_the_text_gin_idx ON test USING GIN (the_text gin_trgm_ops);
```

```postgresql
EXPLAIN ANALYSE SELECT * FROM review
WHERE to_tsvector('russian', review_text) @@ to_tsquery('russian', 'test');
```

Indexing LIKE searches with Trigrams and gin_trgm_ops
Sometimes Full Text Search isn't the right fit, but you find yourself needing to index a LIKE search on a particular column:

```postgresql
CREATE TABLE test_trgm (t text);
SELECT * FROM test_trgm WHERE t LIKE '%foo%bar';
```

Due to the nature of the LIKE operation, which supports arbitrary wildcard expressions, this is fundamentally hard to index. 
However, the pg_trgm extension can help. When you create an index like this:

```postgresql
CREATE INDEX trgm_idx ON test_trgm USING gin (t gin_trgm_ops);
```
Postgres will split the row values into trigrams, allowing indexed searches:

```postgresql
EXPLAIN SELECT * FROM test_trgm WHERE t LIKE '%foo%bar';
```

--- 

## About gen_random_uuid()
PostgreSQL includes one function to generate a UUID:
```postgresql
uuid uuid NOT NULL DEFAULT gen_random_uuid()
```
gen_random_uuid () → uuid
This function returns a version 4 (random) UUID. This is the most commonly used type of UUID and is appropriate for most applications.

---
## CREATE EXTENSION

**uuid-ossp** is a contrib module, so it isn't loaded into the server by default. 
You must load it into your database to use it.

For modern PostgreSQL versions (9.1 and newer) that's easy:
```postgresql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

--- 

## Pg-Bouncer

pgbouncer — пул соединений Postgres Pro

В системах Linux:
```
pgbouncer [-d] [-R] [-v] [-u пользователь] pgbouncer.ini
pgbouncer -V | -h
```
В Windows:
```
pgbouncer [-v] [-u пользователь] pgbouncer.ini
pgbouncer -V | -h
```
**pgbouncer** — это программа, управляющая пулом соединений Postgres Pro. Любое конечное приложение может подключиться к pgbouncer, как если бы это был непосредственно сервер Postgres Pro, и pgbouncer создаст подключение к реальному серверу, либо задействует одно из ранее установленных подключений.

**Предназначение pgbouncer** — минимизировать издержки, связанные с установлением новых подключений к Postgres Pro.

Чтобы не нарушать семантику транзакций при переключении подключений, pgbouncer поддерживает несколько видов пулов:
**Пул сеансов**
Наиболее корректный метод. Когда клиент подключается, ему назначается одно серверное подключение на всё время, пока клиент остаётся подключённым. Когда клиент отключается, это подключение к серверу возвращается в пул. Этот метод работает по умолчанию.

**Пул транзакций**
Подключение к серверу назначается клиенту только на время транзакции. Когда pgbouncer замечает, что транзакция завершена, это подключение возвращается в пул.

**Пул операторов**
Наиболее агрессивный метод. Подключение к серверу будет возвращаться в пул сразу после завершения каждого запроса. Транзакции с несколькими операторами в этом режиме запрещаются, так как они не будут работать.


