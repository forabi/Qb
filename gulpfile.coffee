gulp    = require 'gulp'
_       = require 'lodash'
plugins = (require 'gulp-load-plugins')()
gutil   = plugins.util

config = _.defaults gutil.env,
    env: if gutil.env.production then 'production' else 'development'
    src:
        coffee: ['*.coffee']

if config.env isnt 'production'
    config = _.defaults config,
        lint: yes
        sourceMaps: yes

config = "dist/#{config.env}"


try fs.mkdirSync cofig.dest

gulp.task 'build', ->
    gulp.src config.src.coffee, cwd: 'src'
    .pipe (if config.lint then plugins.coffeelint() else gutil.noop())
    .pipe (if config.lint then plugins.coffeelint.reporter() else gutil.noop())
    .pipe plugins.coffee bare: yes, sourceMap: (yes if config.env isnt 'production')
    .pipe (if config.env is 'production' then plugins.uglify() else gutil.noop())
    .pipe gulp.dest "#{config.dest}"

gulp.task 'test', ->
    gulp.src ['*.coffee'], cwd: 'tests'
    .pipe plugins.karma action: 'run', configFile: 'karma.conf.coffee'
    .on 'error', (err) ->
        # console.log err
        throw err