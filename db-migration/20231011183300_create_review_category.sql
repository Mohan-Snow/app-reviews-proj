-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS review_category (
    id SERIAL PRIMARY KEY,
    review_category_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS review_to_category(
    id SERIAL PRIMARY KEY,
    review_id BIGSERIAL REFERENCES review(id),
    category_id SERIAL REFERENCES review_category(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_to_label;
DROP TABLE IF EXISTS review_category;
-- +goose StatementEnd

