gulp = require "gulp"
fs = require "fs"
replace = require "gulp-replace"
CONFIGS = JSON.parse fs.readFileSync './settings.json', 'utf8'

gulp.task "default", ->
    # client side
    require("./frontend/gulpfile.coffee")('frontend')

    # server side
    gulp.src([
        "./backend/settings.json"
    ])
    .pipe(replace(/"parse": \{(.*)\}/, "\"parse\": #{JSON.stringify CONFIGS.GLOBAL_CONFIGS.parse}"))
    .pipe(replace(/"database": \{(.*)\}/, "\"database\": #{JSON.stringify CONFIGS.GLOBAL_CONFIGS.database}"))
    .pipe(gulp.dest("./backend"))

