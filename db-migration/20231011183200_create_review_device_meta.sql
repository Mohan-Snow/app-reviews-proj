-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS review_device_meta (
   id BIGSERIAL PRIMARY KEY,
   review_device_meta VARCHAR(255) NOT NULL,
   review_id bigserial REFERENCES review(id),
   created_at TIMESTAMP NOT NULL DEFAULT NOW(),
   updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_review_device_meta_updated_at_trigger ON review_device_meta;
CREATE TRIGGER update_review_device_meta_updated_at_trigger
    BEFORE UPDATE ON review_device_meta
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_review_device_meta_updated_at_trigger ON review_device_meta;
DROP TABLE IF EXISTS review_device_meta;
-- +goose StatementEnd

