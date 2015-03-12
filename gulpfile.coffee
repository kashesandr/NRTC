gulp = require "gulp"
chug = require "gulp-chug"

gulp.task "sub-gulpfiles", ->


gulp.task "default", ->
    gulp.src("./*/gulpfile.js")
    .pipe(chug({tasks: ["default"]}))