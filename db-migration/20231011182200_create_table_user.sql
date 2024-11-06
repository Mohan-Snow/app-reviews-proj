-- +goose Up
-- +goose StatementBegin
CREATE TYPE USER_ROLE AS ENUM ('USER', 'ADMIN');

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT uuid_generate_v4(),
    username VARCHAR(255) NOT NULL,
    user_role USER_ROLE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    role_id int2
);

DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
CREATE TRIGGER update_users_updated_at_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();

CREATE INDEX IF NOT EXISTS INDX_USERNAME ON users USING gin (to_tsvector('english', username));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS INDX_USERNAME;
DROP TABLE IF EXISTS users;
DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
DROP TYPE USER_ROLE;
-- +goose StatementEnd