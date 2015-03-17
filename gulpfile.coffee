gulp = require "gulp"

gulp.task "default", ->
    require("./frontend/gulpfile.coffee")('frontend')
