module.exports = (config) ->
  config.set
    reporters: ['spec']
    frameworks: ['jasmine', 'browserify']
    browsers: ['Chrome']
    autoWatch: yes

    plugins: [
        'karma-spec-reporter'
        'karma-browserify'
        # 'karma-coffee-preprocessor'
        'karma-chrome-launcher'
        'karma-firefox-launcher'
        # 'karma-phantomjs-launcher'
        'karma-jasmine'
    ]

    preprocessors:
      'tests/*.coffee': ['browserify']

    coffeePreprocessor:
      # options passed to the coffee compiler
      options:
        bare: true,
        sourceMap: false

      # transforming the filenames
      transformPath: (path) -> path.replace /\.coffee$/, '.js'

    browserify:
        extensions: ['.coffee']
        transform: ['coffeeify']
        watch: yes   # Watches dependencies only (Karma watches the tests)
        debug: yes   # Adds source maps to bundle