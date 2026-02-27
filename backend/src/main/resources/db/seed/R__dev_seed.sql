-- R__dev_seed.sql — Repeatable Flyway migration: seed de desenvolvimento
-- Este arquivo só é aplicado quando o profile dev adiciona classpath:db/seed
-- às localizações Flyway (application-dev.properties).
-- NÃO é executado em ambientes de produção.

INSERT INTO users (username, email, password)
VALUES ('dev', 'dev@gamelibrary.local', '$2a$10$placeholder_bcrypt_hash')
ON CONFLICT (username) DO NOTHING;

INSERT INTO games (title, platform, genre, status, personal_rating, user_id)
SELECT title, platform, genre, status, personal_rating, u.id
FROM (VALUES
    ('The Last of Us Part II', 'PS5', 'Action',       'COMPLETED', 9.5),
    ('Hollow Knight',          'PC',  'Metroidvania', 'PLAYING',   9.0),
    ('Cyberpunk 2077',         'PC',  'RPG',          'BACKLOG',   0.0),
    ('Hades',                  'PC',  'Roguelike',    'COMPLETED', 10.0),
    ('Elden Ring',             'PC',  'Souls-like',   'ABANDONED', 7.0)
) AS seed(title, platform, genre, status, personal_rating)
JOIN users u ON u.username = 'dev'
WHERE NOT EXISTS (
    SELECT 1 FROM games g WHERE g.title = seed.title AND g.user_id = u.id
);
