/** @type {import('prettier').Config} */
module.exports = {
    singleQuote: true,
    printWidth: 120,
    tabWidth: 4,
    useTabs: false,
    semi: true,
    trailingComma: 'all',
    bracketSpacing: true,
    arrowParens: 'always',
    endOfLine: 'lf',
    overrides: [
        {
            files: '*.html',
            options: {
                parser: 'angular',
                printWidth: 120,
            },
        },
    ],
};
