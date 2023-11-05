-- +goose Up
-- +goose StatementBegin
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE store
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
ALTER TABLE users
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
ALTER TABLE company
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
ALTER TABLE app
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
ALTER TABLE review
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
ALTER TABLE review_reply
    ALTER COLUMN uuid SET DATA TYPE UUID USING (uuid_generate_v4());
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP EXTENSION IF EXISTS "uuid-ossp";
-- +goose StatementEnd

