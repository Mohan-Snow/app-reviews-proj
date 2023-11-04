-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS api_credentials (
    id BIGSERIAL PRIMARY KEY,
    api_credentials VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS api_credentials_to_company (
    api_credentials_id BIGSERIAL REFERENCES api_credentials(id),
    company_id BIGSERIAL REFERENCES company(id)
);

DROP TRIGGER IF EXISTS update_api_credentials_updated_at_trigger ON api_credentials;
CREATE TRIGGER update_api_credentials_updated_at_trigger
    BEFORE UPDATE ON api_credentials
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_field();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TRIGGER IF EXISTS update_api_credentials_updated_at_trigger ON api_credentials;
DROP TABLE IF EXISTS api_credentials_to_company;
DROP TABLE IF EXISTS api_credentials;
-- +goose StatementEnd

