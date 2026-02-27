-- V1__init.sql — Flyway migration: schema inicial

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
