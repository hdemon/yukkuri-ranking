"use strict"
module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    coffee:
      source:
        expand: true,
        cwd: 'lib/',
        src: ['**/*.coffee'],
        dest: 'dist/',
        ext: '.js'

    watch:
      test:
        files: [
          "lib/**/*.coffee"
          "<%= simplemocha.all.src %>"
        ]
        tasks: ["test"]

    simplemocha:
      all:
        src: ['test/**/*.coffee']
        options:
          timeout: 3000
          ignoreLeaks: false
          ui: 'bdd'
          compilers: 'coffee:coffee-script'

  grunt.registerTask "default", ["watch"]
  grunt.registerTask "build", ["coffee:source"]
  grunt.registerTask "test", ["simplemocha"]
