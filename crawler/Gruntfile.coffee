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
          "<%= mochaTest.all.src %>"
        ]
        tasks: ["test"]

    mochaTest:
      all:
        options:
          reporter: 'spec'
          timeout: 3000
          ui: 'bdd'
          require: 'coffee-script/register'
          compilers: 'coffee:coffee-script/register'
        src: ['test/**/*.coffee']

  grunt.registerTask "default", ["watch"]
  grunt.registerTask "build", ["coffee:source"]
  grunt.registerTask "test", ["mochaTest"]
