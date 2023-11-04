-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS store (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    store_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_store_updated_at_trigger ON store;
CREATE TRIGGER update_store_updated_at_trigger
    BEFORE UPDATE ON store
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_store_updated_at_trigger ON store;
DROP TABLE IF EXISTS store;
-- +goose StatementEnd

