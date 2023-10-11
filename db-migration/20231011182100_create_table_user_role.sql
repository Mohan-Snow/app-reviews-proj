-- +goose Up
-- +goose StatementBegin
CREATE TABLE user_role (
    id BIGSERIAL PRIMARY KEY,
    user_role VARCHAR(255) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS user_role;
-- +goose StatementEnd

