## ПОЧИТАТЬ!!!!
1. with clause - cte - common table expression (?)
2. репликация баз данных
3. знать капасити SERIAL и BIGSERIAL
4. username VARCHAR(255) NOT NULL, // найти доп инфу про различия
5. created_at TIMESTAMP NOT NULL DEFAULT NOW(), // разобраться с таймзонами. как храниться? Чем отличается timestamp от timestampTZ?

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

---
## SELECT FOR UPDATE

Пока у вас транзакции следуют строго одна за другой - у вас всё хорошо и нет проблем. Кроме производительности. А чтобы улучшить производительность - необходимо разрешить транзакции выполнять параллельно. И вот тут начинается богатый и поразительный мир concurrently control. При том, не только в базах данных, а везде где хоть что-то выполняется параллельно.

На деньгах люди обычно лучше понимают, так что будем говорить про деньги. Допустим есть пользователь, у него есть 100 денег на счету. Пользователь может их тратить, вы проверяете баланс select balance ..., затем обновляете баланс при покупке update ... set balance = ? where .... И вот в счастливый день как-то так вышло, что приходят сразу два запроса на покупки для этого пользователя. Одна на 50 денег, вторая на 70. Одна из них должна быть отклонена, т.к. денег недостаточно. Но в результате получается что обе покупки прошли и у вас проблема, вы продали то что не надо было. И это даже не видно по балансу пользователя. Как же?

Это типичный race condition, обе транзакции сначала данные читают, потом локально что-то делают, потом что-то пишут.

читать им никто не мешает, потому обе транзакции прочитали что у пользователя 100 денег
обе транзакции закономерно решили что денег достаточно
обе транзакции обновили баланс пользователя
На конкурентном доступе к ресурсу подрались только на последнем шаге, транзакция которая начала обновлять данные позже сначала подождала завершение первой транзакции. А затем банально перезаписала баланс на тот который считала правильным сама. Так называемая lost update аномалия.

То есть, в существующем виде эти две транзакции были неверно сериализованы. Для корректного выполнения логики вторая пришедшая транзакция должна была подождать результат первой транзакции до чтения баланса пользователя. Но базу данных об этом не предупредили, и вполне закономерно этот первый select был расценен как не мешающий другим.

Вот как раз для того чтобы предупредить СУБД о том, что мы планируем с данными что-то делать, а потому нам надо сериализовать транзакции иначе, и существует FOR SHARE, FOR UPDATE дополнения. Потому они кстати и задокументированы в разделе Explicit Locking

Если ничего не указано в select - то из-за сущности MVCC реализации postgresql транзакции смогут читать данные чуть менее чем всегда. Даже если прямо сейчас другая транзакция эту строку уже обновляет - мы получим последнее известное зафиксированное значение этой строк.
если запросить явно FOR SHARE - то читать мы сможем в много потоков с этой FOR SHARE блокировкой не блокируя друг друга. Но вот если кто-то захочет обновить эту строку - то он встанет в очередь ожидания пока не завершатся все транзакции удерживающие читающую блокировку и вместе с тем задержит все последующие FOR SHARE транзакции.
если запросить FOR UPDATE - то мы можем быть уверены, что ни одна другая транзакция не сможет обновить эту строку до конца нашей транзакции.
То есть нужны в тех местах, где без этого конкурентныая транзакция может сериализоваться логично с точки зрения СУБД, но некорректно для бизнес логики приложения.

Нужен ли здесь FOR UPDATE - просто процитирую документацию с советами по уменьшению проседания производительности от Serializable уровня изоляции:

**Eliminate explicit locks, SELECT FOR UPDATE, and SELECT FOR SHARE where no longer needed due to the protections automatically provided by Serializable transactions.**

---

## **VACUUM**, **ANALYZE**, and **REINDEX**. PostgreSQL.

**Purpose**
If the application is running on a PostgreSQL database, there are Postgres tasks that can be run to improve and optimize database performance.
Three of these will be introduced in this article: **VACUUM**, **ANALYZE**, and **REINDEX**.

**To avoid conflicting database updates or corrupted data, it is recommended to run these commands during a maintenance window and with the application stopped.**

In the default PostgreSQL configuration, the AUTOVACUUM daemon is enabled and all required configuration parameters are set as needed.
The daemon will run VACUUM and ANALYZE at regular intervals. If the daemon is enabled, these commands can be run to supplement the daemon's work.

To confirm whether the autovacuum daemon is running on LINUX, use the command below:

```
$ ps aux|grep autovacuum|grep -v grep
postgres           334   0.0  0.0  2654128   1232   ??  Ss   16Mar17   0:05.63 postgres: autovacuum launcher process  
```

Alternatively, the SQL query below can be used to check the status of the autovacuum in the pg_settings:
```
SELECT name, setting FROM pg_settings WHERE name ILIKE '%autovacuum%';
```

## VACUUM
The VACUUM command will reclaim storage space occupied by dead tuples.
In normal PostgreSQL operation, tuples that are deleted or obsoleted by an update are not physically removed from their table

VACUUM can be run on its own, or with ANALYZE.


Atlassian Support
Documentation
Atlassian Knowledge Base

Postgres Troubleshooting and How-To Guides
Optimize and Improve PostgreSQL Performance with VACUUM, ANALYZE, and REINDEX
Still need help?
The Atlassian Community is here for you.

Ask the community

Platform notice: Server and Data Center only.  This article only applies to Atlassian products on the server and data center platforms.

Purpose
If the application is running on a PostgreSQL database, there are Postgres tasks that can be run to improve and optimize database performance.
Three of these will be introduced in this article: VACUUM, ANALYZE, and REINDEX.

To avoid conflicting database updates or corrupted data, it is recommended to run these commands during a maintenance window and with the application stopped.

In the default PostgreSQL configuration, the AUTOVACUUM daemon is enabled and all required configuration parameters are set as needed.
The daemon will run VACUUM and ANALYZE at regular intervals. If the daemon is enabled, these commands can be run to supplement the daemon's work.

To confirm whether the autovacuum daemon is running on LINUX, use the command below:
```
$ ps aux|grep autovacuum|grep -v grep
postgres           334   0.0  0.0  2654128   1232   ??  Ss   16Mar17   0:05.63 postgres: autovacuum launcher process
```
Alternatively, the SQL query below can be used to check the status of the autovacuum in the pg_settings:
```postgresql
SELECT name, setting FROM pg_settings WHERE name ILIKE '%autovacuum%';
```

Vacuum
The VACUUM command will reclaim storage space occupied by dead tuples.
In normal PostgreSQL operation, tuples that are deleted or obsoleted by an update are not physically removed from their table

VACUUM can be run on its own, or with ANALYZE.

When the option list is surrounded by parentheses, the options can be written in any order. Without parentheses, options must be specified in exactly the order shown below. The parenthesized syntax was added in PostgreSQL 9.0; after which the unparenthesized syntax is deprecated.

**Examples**
In the examples below, **[tablename]** is optional. Without a table specified, VACUUM will be run on ALL available tables in the current schema that the user has access to.

Plain VACUUM: Frees up space for re-use
```postgresql
VACUUM [tablename]
```
Full VACUUM: Locks the database table, and reclaims more space than a plain VACUUM
```postgresql
-- Before Postgres 9.0: 
VACUUM FULL
-- Postgres 9.0+:
VACUUM(FULL) [tablename]
```

Full VACUUM and ANALYZE: Performs a Full VACUUM and gathers new statistics on query executions paths using ANALYZE
```postgresql
-- Before Postgres 9.0:
VACUUM FULL ANALYZE [tablename]
-- Postgres 9.0+:
VACUUM(FULL, ANALYZE) [tablename]
```

Verbose Full VACUUM and ANALYZE: Same as #3, but with verbose progress output
```postgresql
-- Before Postgres 9.0:
VACUUM FULL VERBOSE ANALYZE [tablename]
-- Postgres 9.0+:
VACUUM(FULL, ANALYZE, VERBOSE) [tablename]
```

## ANALYZE
ANALYZE gathers statistics for the query planner to create the most efficient query execution paths. Per PostgreSQL documentation, accurate statistics will help the planner to choose the most appropriate query plan, and thereby improve the speed of query processing.

**Example**
In the example below, [tablename] is optional. Without a table specified, ANALYZE will be run on available tables in the current schema that the user has access to.

```postgresql
ANALYZE VERBOSE [tablename]
```

## REINDEX
The REINDEX command rebuilds one or more indices, replacing the previous version of the index. REINDEX can be used in many scenarios, including the following (from Postgres documentation):

* An index has become corrupted, and no longer contains valid data. Although in theory, this should never happen, in practice indexes can become corrupted due to software bugs or hardware failures. REINDEX provides a recovery method.
* An index has become "bloated", that is it contains many empty or nearly-empty pages. This can occur with B-tree indexes in PostgreSQL under certain uncommon access patterns. REINDEX provides a way to reduce the space consumption of the index by writing a new version of the index without the dead pages.
* A storage parameter (such as fillfactor) has been changed for an index, and needs ensure that the change has taken full effect.
* An index build with the CONCURRENTLY option failed, leaving an "invalid" index. Such indexes are useless but it can be convenient to use REINDEX to rebuild them. Note that REINDEX will not perform a concurrent build. To build the index without interfering with production it is necessary to drop the index and reissue the CREATE INDEX CONCURRENTLY command.

**Examples**
Any of these can be forced by adding the keyword FORCE after the command

Recreate a single index, myindex:
```postgresql
REINDEX INDEX myindex
```
Recreate all indices in a table, mytable:
```postgresql
REINDEX TABLE mytable
```
Recreate all indices in schema public:
```postgresql
REINDEX SCHEMA public
```
Recreate all indices in database postgres:
```postgresql
REINDEX DATABASE postgres
```
Recreate all indices on system catalogs in database postgres:
```postgresql
REINDEX SYSTEM postgres
```

