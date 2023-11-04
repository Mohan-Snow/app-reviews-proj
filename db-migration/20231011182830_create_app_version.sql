-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS app_version (
    id BIGSERIAL PRIMARY KEY,
    api_version VARCHAR(255) NOT NULL,
    app_id BIGSERIAL REFERENCES app(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS app_version;
-- +goose StatementEnd

