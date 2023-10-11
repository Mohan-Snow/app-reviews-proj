-- +goose Up
-- +goose StatementBegin
CREATE TABLE review (
    id BIGSERIAL PRIMARY KEY,
    review_text VARCHAR(255) NOT NULL,
    store_id bigserial REFERENCES store(id),
    review_country_id bigserial REFERENCES review_country(id),
    app_version_id bigserial REFERENCES app_version(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review;
-- +goose StatementEnd

