-- +goose Up
-- +goose StatementBegin
CREATE TABLE review_country (
    id BIGSERIAL PRIMARY KEY,
    review_country_name VARCHAR(255) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_country;
-- +goose StatementEnd

