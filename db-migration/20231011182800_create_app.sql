-- +goose Up
-- +goose StatementBegin
CREATE TABLE app (
    id BIGSERIAL PRIMARY KEY,
    app_name VARCHAR(255) NOT NULL,
    app_version_id bigserial REFERENCES app_version(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS app;
-- +goose StatementEnd

