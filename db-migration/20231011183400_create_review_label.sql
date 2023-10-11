-- +goose Up
-- +goose StatementBegin
CREATE TABLE review_label (
    id BIGSERIAL PRIMARY KEY,
    review_label_name VARCHAR(255) NOT NULL,
    review_category_id bigserial REFERENCES review_category(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_label;
-- +goose StatementEnd

