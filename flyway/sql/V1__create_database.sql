CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users(
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR (250) UNIQUE NOT NULL ,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE stores(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    name VARCHAR (250) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE user_store(
    user_id UUID NOT NULL REFERENCES users(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY(user_id, store_id)
);

CREATE TABLE items(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    title TEXT NOT NULL,
    description TEXT,
    img TEXT,
    price INT NOT NULL DEFAULT 0,
    store_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    FOREIGN KEY(store_id) REFERENCES stores(id)
);

CREATE TABLE cart_items(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    user_id UUID NOT NULL REFERENCES users(id),
    item_id UUID NOT NULL REFERENCES items(id),
    quantity INT NOT NULL DEFAULT 1
);

CREATE TABLE orders(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    total INT NOT NULL DEFAULT 0,
    charge TEXT,
    paid BOOLEAN DEFAULT FALSE,
    user_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE order_items(
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    title TEXT NOT NULL,
    description TEXT,
    img TEXT,
    price INT NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 1,
    store_id UUID NOT NULL,
    user_id UUID NOT NULL,
    order_id UUID NOT NULL,
    status TEXT default 'created',
    FOREIGN KEY(store_id) REFERENCES stores(id),
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(order_id) REFERENCES orders(id)
);

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS trigger AS
$$
    BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
    END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER order_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

