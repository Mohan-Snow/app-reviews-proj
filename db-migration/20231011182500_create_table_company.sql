-- +goose Up
-- +goose StatementBegin
CREATE TABLE company (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    api_credentials_id bigserial REFERENCES api_credentials(id),
    company_role_id bigserial REFERENCES company_role(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS company;
-- +goose StatementEnd

