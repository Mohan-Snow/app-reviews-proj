-- +goose Up
-- +goose StatementBegin
DROP FUNCTION IF EXISTS update_updated_at_field;
CREATE FUNCTION update_updated_at_field()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP FUNCTION IF EXISTS update_updated_at_field;
-- +goose StatementEnd

