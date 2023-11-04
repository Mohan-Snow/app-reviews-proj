-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS review_label (
    id SERIAL PRIMARY KEY,
    review_label_name VARCHAR(255) NOT NULL,
    country_id SERIAL REFERENCES review_country(id)
);

CREATE TABLE IF NOT EXISTS review_to_label(
    id SERIAL PRIMARY KEY,
    review_id BIGSERIAL REFERENCES review(id) ON DELETE CASCADE,
    label_id SERIAL REFERENCES review_label(id) ON DELETE CASCADE
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_to_label;
DROP TABLE IF EXISTS review_label;
-- +goose StatementEnd

