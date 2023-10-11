-- +goose Up
-- +goose StatementBegin
CREATE TABLE review_category (
    id BIGSERIAL PRIMARY KEY,
    review_category_name VARCHAR(255) NOT NULL,
    company_id bigserial REFERENCES company(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_category;
-- +goose StatementEnd

