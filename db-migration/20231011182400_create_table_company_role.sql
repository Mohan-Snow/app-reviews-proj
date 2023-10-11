-- +goose Up
-- +goose StatementBegin
CREATE TABLE company_role (
    id BIGSERIAL PRIMARY KEY,
    company_role VARCHAR(255) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS company_role;
-- +goose StatementEnd

