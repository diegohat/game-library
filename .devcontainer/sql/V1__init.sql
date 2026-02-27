-- V1__init.sql — Migration Flyway inicial
-- Cria as tabelas base e insere dados de seed para desenvolvimento

CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS games (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(150) NOT NULL,
    platform        VARCHAR(50)  NOT NULL,
    genre           VARCHAR(50),
    status          VARCHAR(20)  NOT NULL DEFAULT 'BACKLOG',
    personal_rating NUMERIC(3,1) CHECK (personal_rating BETWEEN 0 AND 10),
    cover_url       VARCHAR(255),
    user_id         BIGINT REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Seed inicial de jogos para o usuário dev
INSERT INTO users (username, email, password) VALUES
    ('dev', 'dev@gamelibrary.local', '$2a$10$placeholder_bcrypt_hash');

INSERT INTO games (title, platform, genre, status, personal_rating, user_id) VALUES
    ('The Last of Us Part II', 'PS5', 'Action',        'COMPLETED', 9.5, 1),
    ('Hollow Knight',          'PC',  'Metroidvania',  'PLAYING',   9.0, 1),
    ('Cyberpunk 2077',         'PC',  'RPG',           'BACKLOG',   0.0, 1),
    ('Hades',                  'PC',  'Roguelike',     'COMPLETED', 10.0, 1),
    ('Elden Ring',             'PC',  'Souls-like',    'ABANDONED', 7.0, 1);
