-- +goose Up
-- +goose StatementBegin
CREATE TABLE api_credentials (
    id BIGSERIAL PRIMARY KEY,
    api_credentials VARCHAR(255) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS api_credentials;
-- +goose StatementEnd

