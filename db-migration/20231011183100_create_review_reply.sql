-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS review_reply (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    reply_text VARCHAR(255) NOT NULL,
    review_id bigserial REFERENCES review(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_review_reply_updated_at_trigger ON review_reply;
CREATE TRIGGER update_review_reply_updated_at_trigger
    BEFORE UPDATE ON review_reply
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_review_reply_updated_at_trigger ON review_reply;
DROP TABLE IF EXISTS review_reply;
-- +goose StatementEnd

