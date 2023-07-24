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

