-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS app (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    app_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_app_updated_at_trigger ON app;
CREATE TRIGGER update_app_updated_at_trigger
    BEFORE UPDATE ON app
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_app_updated_at_trigger ON app;
DROP TABLE IF EXISTS app;
-- +goose StatementEnd

