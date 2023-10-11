-- +goose Up
-- +goose StatementBegin
CREATE TABLE app_version (
    id BIGSERIAL PRIMARY KEY,
    api_version VARCHAR(255) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS app_version;
-- +goose StatementEnd

