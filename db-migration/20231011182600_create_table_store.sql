-- +goose Up
-- +goose StatementBegin
CREATE TABLE store (
    id BIGSERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    api_credentials_id bigserial REFERENCES api_credentials(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS store;
-- +goose StatementEnd

