-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS review (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    review_text TEXT NOT NULL,
    store_id bigserial REFERENCES store(id),
    app_version_id bigserial REFERENCES app_version(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_review_updated_at_trigger ON review;
CREATE TRIGGER update_review_updated_at_trigger
    BEFORE UPDATE ON review
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();

CREATE INDEX IF NOT EXISTS INDX_CREATED_AT ON review(created_at DESC);
CREATE INDEX IF NOT EXISTS INDX_STORE_ID_AND_APP_VERSION_ID ON review (store_id, app_version_id) ;
CREATE INDEX IF NOT EXISTS INDX_REVIEW_TEXT ON review USING gin(to_tsvector('russian', review_text));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_review_updated_at_trigger ON review;
DROP INDEX IF EXISTS INDX_CREATED_AT;
DROP INDEX IF EXISTS INDX_STORE_ID_AND_APP_VERSION_ID;
DROP INDEX IF EXISTS INDX_REVIEW_TEXT;
DROP TABLE IF EXISTS review;
-- +goose StatementEnd

