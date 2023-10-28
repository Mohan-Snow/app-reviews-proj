-- +goose Up
-- +goose StatementBegin

-- User
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    username VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    role_id int2
);

-- UserRole
CREATE TYPE USER_ROLE AS ENUM ('USER', 'ADMIN');

CREATE TABLE IF NOT EXISTS user_role (
    id int2 PRIMARY KEY,
    user_role USER_ROLE NOT NULL
);

ALTER TABLE IF EXISTS users
    ADD FOREIGN KEY (role_id) REFERENCES user_role(id);

CREATE INDEX IF NOT EXISTS "INDX_USERNAME" ON users USING gin (username);

-- CompanyRole
CREATE TYPE COMPANY_ROLE AS ENUM ('COMPANY_ROLE_1', 'COMPANY_ROLE_2');

CREATE TABLE IF NOT EXISTS company_role (
    id int2 PRIMARY KEY,
    company_role COMPANY_ROLE NOT NULL
);

-- Company
CREATE TABLE IF NOT EXISTS company (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    company_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    company_role_id int2 REFERENCES company_role(id)
);

-- ApiCredentials
CREATE TABLE IF NOT EXISTS api_credentials (
    id BIGSERIAL PRIMARY KEY,
    api_credentials VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE IF EXISTS api_credentials_to_company
    ADD COLUMN IF NOT EXISTS api_credentials_id BIGSERIAL REFERENCES api_credentials(id),
    ADD COLUMN IF NOT EXISTS company_id BIGSERIAL REFERENCES company(id);

-- Store
CREATE TABLE IF NOT EXISTS store (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    store_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- App
CREATE TABLE IF NOT EXISTS app (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    app_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- AppVersion
CREATE TABLE IF NOT EXISTS app_version (
    id BIGSERIAL PRIMARY KEY,
    api_version VARCHAR(255) NOT NULL
);

ALTER TABLE IF EXISTS app_version
    ADD COLUMN IF NOT EXISTS app_id BIGSERIAL REFERENCES app(id);

-- Review
CREATE TABLE IF NOT EXISTS review (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    review_text TEXT NOT NULL,
    store_id bigserial REFERENCES store(id),
    app_version_id bigserial REFERENCES app_version(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS "INDX_CREATED_AT" ON review(created_at);
CREATE INDEX IF NOT EXISTS "INDX_STORE_ID_AND_APP_VERSION_ID" ON review (store_id, app_version_id) ;
CREATE INDEX IF NOT EXISTS "INDX_REVIEW_TEXT" ON review USING gin(review_text);

-- ReviewReply
CREATE TABLE IF NOT EXISTS review_reply (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    reply_text VARCHAR(255) NOT NULL,
    review_id bigserial REFERENCES review(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ReviewDeviceMeta
CREATE TABLE IF NOT EXISTS review_device_meta (
  id BIGSERIAL PRIMARY KEY,
  review_device_meta VARCHAR(255) NOT NULL,
  review_id bigserial REFERENCES review(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ReviewCategory
CREATE TABLE IF NOT EXISTS review_category (
    id SERIAL PRIMARY KEY,
    review_category_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS review_to_category(
    id SERIAL PRIMARY KEY
);

ALTER TABLE IF EXISTS review_to_category
    ADD COLUMN IF NOT EXISTS review_id BIGSERIAL REFERENCES review(id),
    ADD COLUMN IF NOT EXISTS category_id SERIAL REFERENCES review_category(id);

-- ReviewLabel
CREATE TABLE IF NOT EXISTS review_label (
    id SERIAL PRIMARY KEY,
    review_label_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS review_to_label(
    id SERIAL PRIMARY KEY
);

ALTER TABLE IF EXISTS review_to_label
    ADD COLUMN IF NOT EXISTS review_id BIGSERIAL REFERENCES review(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS label_id SERIAL REFERENCES review_label(id) ON DELETE CASCADE;

-- ReviewCountry
CREATE TABLE IF NOT EXISTS review_country (
    id SERIAL PRIMARY KEY,
    review_country_name VARCHAR(255) NOT NULL
);

ALTER TABLE  IF EXISTS review_label
    ADD COLUMN IF NOT EXISTS country_id SERIAL REFERENCES review_country(id)

-- +goose StatementEnd


