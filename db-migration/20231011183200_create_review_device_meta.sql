-- +goose Up
-- +goose StatementBegin
CREATE TABLE review_device_meta (
    id BIGSERIAL PRIMARY KEY,
    review_device_meta VARCHAR(255) NOT NULL,
    review_id bigserial REFERENCES review(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_device_meta;
-- +goose StatementEnd

