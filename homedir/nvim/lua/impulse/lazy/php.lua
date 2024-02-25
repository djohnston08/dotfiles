return {
    -- PHP Refactoring Tools
    {
        'phpactor/phpactor',
        ft = 'php',
        run = 'composer install --no-dev --optimize-autoloader',
        config = function()
            vim.keymap.set('n', '<Leader>pm', ':PhpactorContextMenu<CR>')
            vim.keymap.set('n', '<Leader>pn', ':PhpactorClassNew<CR>')
        end,
    },

    -- Project Configuration.
    {
        'tpope/vim-projectionist',
        requires = 'tpope/vim-dispatch',
        config = function()
            vim.g.projectionist_heuristics = {
                artisan = {
                    ['*'] = {
                        console = 'sail artisan tinker',
                        logs = 'tail -n 200 -f storage/logs/laravel.log',
                    },
                    ['app/*.php'] = {
                        type = 'source',
                        alternate = {
                            'tests/Unit/{}Test.php',
                            'tests/Feature/{}Test.php',
                        },
                    },
                    ['app/Repositories/*.php'] = {
                        type = 'source',
                        alternate = {
                            'app/Interfaces/{}Interface.php',
                        },
                    },
                    ['app/Interfaces/*Interface.php'] = {
                        type = 'source',
                        alternate = {
                            'app/Repositories/{}.php',
                        },
                    },
                    ['tests/Feature/*Test.php'] = {
                        type = 'test',
                        alternate = 'app/{}.php',
                    },
                    ['tests/Unit/*Test.php'] = {
                        type = 'test',
                        alternate = 'app/{}.php',
                    },
                    ['app/Models/*.php'] = {
                        type = 'model',
                    },
                    ['app/Http/Controllers/*.php'] = {
                        type = 'controller',
                    },
                    ['routes/*.php'] = {
                        type = 'route',
                    },
                    ['database/migrations/*.php'] = {
                        type = 'migration',
                    },
                },
            }

            vim.keymap.set('n', '<C-a>', ':A<CR>')
        end,
    },
}
