-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    uuid uuid NOT NULL DEFAULT gen_random_uuid(),
    username VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    role_id int2
);

CREATE TYPE USER_ROLE AS ENUM ('USER', 'ADMIN');

CREATE TABLE IF NOT EXISTS user_role (
    id int2 PRIMARY KEY,
    user_role USER_ROLE NOT NULL
);

ALTER TABLE IF EXISTS users
    ADD FOREIGN KEY (role_id) REFERENCES user_role(id);

CREATE TYPE COMPANY_ROLE AS ENUM ('COMPANY_ROLE_1', 'COMPANY_ROLE_2');

CREATE TABLE IF NOT EXISTS company_role (
    id int2 PRIMARY KEY,
    company_role COMPANY_ROLE NOT NULL
);

CREATE TABLE IF NOT EXISTS company (
    id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    company_role_id int2 REFERENCES company_role(id)
);

CREATE TABLE IF NOT EXISTS api_credentials (
    id BIGSERIAL PRIMARY KEY,
    api_credentials VARCHAR(255) NOT NULL
);

ALTER TABLE IF EXISTS api_credentials_to_company
    ADD COLUMN IF NOT EXISTS api_credentials_id BIGSERIAL,
    ADD FOREIGN KEY (api_credentials_id) REFERENCES api_credentials(id),
    ADD COLUMN IF NOT EXISTS company_id BIGSERIAL,
    ADD FOREIGN KEY (company_id) REFERENCES company(id);

CREATE TABLE IF NOT EXISTS store (
    id BIGSERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS app (
    id BIGSERIAL PRIMARY KEY,
    app_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS app_version (
    id BIGSERIAL PRIMARY KEY,
    api_version VARCHAR(255) NOT NULL
);

ALTER TABLE IF EXISTS app_version
    ADD COLUMN IF NOT EXISTS app_id BIGSERIAL,
    ADD FOREIGN KEY (app_id) REFERENCES app(id);

CREATE TABLE IF NOT EXISTS review (
    id BIGSERIAL PRIMARY KEY,
    review_text TEXT NOT NULL,
    store_id bigserial REFERENCES store(id),
    app_version_id bigserial REFERENCES app_version(id)
);

-- create table review_country
-- create table review_reply
-- create table review_device_meta

CREATE TABLE IF NOT EXISTS review_category (
    id SERIAL PRIMARY KEY,
    review_category_name VARCHAR(255) NOT NULL
--     company_id bigserial REFERENCES company(id)
);

CREATE TABLE IF NOT EXISTS review_to_category(
    id SERIAL PRIMARY KEY
);

ALTER TABLE IF EXISTS review_to_category
    ADD COLUMN IF NOT EXISTS review_id BIGSERIAL,
    ADD FOREIGN KEY (review_id) REFERENCES review(id),
    ADD COLUMN IF NOT EXISTS category_id SERIAL,
    ADD FOREIGN KEY (category_id) REFERENCES review_category(id);

CREATE TABLE IF NOT EXISTS review_label (
    id SERIAL PRIMARY KEY,
    review_label_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS review_to_label(
    id SERIAL PRIMARY KEY
);

ALTER TABLE IF EXISTS review_to_label
    ADD COLUMN IF NOT EXISTS review_id BIGSERIAL,
    ADD FOREIGN KEY (review_id) REFERENCES review(id),
    ADD COLUMN IF NOT EXISTS label_id SERIAL,
    ADD FOREIGN KEY (label_id) REFERENCES review_label(id);

-- +goose StatementEnd


