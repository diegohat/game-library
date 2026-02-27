module.exports = {
    '*.{ts,js}': ['eslint --fix', 'prettier --write'],
    '*.html': ['prettier --write'],
    '*.{scss,css}': ['prettier --write'],
    '*.{json,yml,yaml,md}': ['prettier --write'],
};
