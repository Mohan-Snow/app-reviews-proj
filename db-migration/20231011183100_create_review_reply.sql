-- +goose Up
-- +goose StatementBegin
CREATE TABLE review_reply (
    id BIGSERIAL PRIMARY KEY,
    reply_text VARCHAR(255) NOT NULL,
    review_id bigserial REFERENCES review(id)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS review_reply;
-- +goose StatementEnd

