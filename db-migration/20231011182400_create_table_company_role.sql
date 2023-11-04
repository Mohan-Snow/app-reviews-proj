-- +goose Up
-- +goose StatementBegin
CREATE TYPE COMPANY_ROLE_TYPE AS ENUM ('COMPANY_ROLE_1', 'COMPANY_ROLE_2');

CREATE TABLE IF NOT EXISTS company_role (
    id int2 PRIMARY KEY,
    company_role COMPANY_ROLE_TYPE NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS company_role;
DROP TYPE IF EXISTS COMPANY_ROLE_TYPE;
-- +goose StatementEnd

