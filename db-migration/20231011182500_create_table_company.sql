-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS company (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    company_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    company_role_id int2 REFERENCES company_role(id)
);

DROP TRIGGER IF EXISTS update_company_updated_at_trigger ON company;
CREATE TRIGGER update_company_updated_at_trigger
    BEFORE UPDATE ON company
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_company_updated_at_trigger ON company;
DROP TABLE IF EXISTS company;
-- +goose StatementEnd

