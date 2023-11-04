-- +goose Up
-- +goose StatementBegin
CREATE TYPE USER_ROLE AS ENUM ('USER', 'ADMIN'); -- todo: подумать, как сделать идемпотентно

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY, -- todo: знать капасити SERIAL и BIGSERIAL
    uuid uuid NOT NULL DEFAULT gen_random_uuid(), -- todo: использовать "create extension", поискать по uuid column
    username VARCHAR(255) NOT NULL, -- todo: найти доп инфу про различия
    user_role USER_ROLE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(), -- todo: разобраться с таймзонами. как храниться? Чем отличается timestamp от timestampTZ?
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(), -- todo: добавить скрипт с триггером по апдейту даты
    role_id int2
);

DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
CREATE TRIGGER update_users_updated_at_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();

CREATE INDEX IF NOT EXISTS "INDX_USERNAME" ON users USING gin (username);
-- todo: data type character varying has no default operator class for access method "gin"
-- todo: You must specify an operator class for the index or define a default operator class for the data type.

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS INDX_USERNAME;
DROP TABLE IF EXISTS users;
DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
DROP TYPE USER_ROLE;
-- +goose StatementEnd

