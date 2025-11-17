-- db/schema.sql
CREATE TABLE IF NOT EXISTS pokemon (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    vida INTEGER,
    vida_maxima INTEGER
);

CREATE TABLE IF NOT EXISTS tipo (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS pokemon_tipo (
    pokemon_id INTEGER NOT NULL REFERENCES pokemon(id) ON DELETE CASCADE,
    tipo_id INTEGER NOT NULL REFERENCES tipo(id) ON DELETE CASCADE,
    PRIMARY KEY (pokemon_id, tipo_id)
);
