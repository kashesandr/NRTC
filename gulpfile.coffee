gulp = require "gulp"
runSequence = require 'run-sequence'
templateCache = require 'gulp-angular-templatecache'
gulpif = require 'gulp-if'
clean = require 'gulp-clean'
jade = require 'gulp-jade'
inject = require 'gulp-inject'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
styl = require 'gulp-styl'
batch = require 'gulp-batch'
wrap = require 'gulp-wrap'
gulpNgConfig = require "gulp-ng-config"
fs = require "fs"
replace = require "gulp-replace"
CONFIGS = JSON.parse fs.readFileSync './settings.json', 'utf8'

frontendSrc = "frontend/src"
frontendDest = "frontend/build"
bowerPath = "bower_components"

gulp.task "server-side", ->
    gulp.src([
        "./backend/settings.json"
    ])
    .pipe(replace(/"parse": \{(.*)\}/, "\"parse\": #{JSON.stringify CONFIGS.GLOBAL_CONFIGS.parse}"))
    .pipe(replace(/"database": \{(.*)\}/, "\"database\": #{JSON.stringify CONFIGS.GLOBAL_CONFIGS.database}"))
    .pipe(gulp.dest("./backend"))

gulp.task 'clean:build', ->
    gulp.src(frontendDest, {read: false})
    .pipe(clean())

gulp.task 'clean:extra', ->
    gulp.src([
        "#{frontendSrc}/**/*.js"
        "#{frontendSrc}/**/*.html"
        "#{frontendSrc}/**/*.css"
    ], {read: false})
    .pipe(clean())

gulp.task 'gulpNgConfig', ->
    gulp.src("./settings.json")
    .pipe(gulpNgConfig('GlobalConfigs', {
            createModule: true
            wrap: true
        }))
    .pipe(gulp.dest("#{frontendSrc}/scripts/services"))

gulp.task 'templateCache', ->
    gulp.src("#{frontendSrc}/**/*template.jade")
    .pipe(jade())
    .pipe(templateCache('templates.js', {
            templateHeader:
                """
                    (function() {
                        'use strict';
                        angular.module('NRTC').run(function($templateCache) {
                """
            templateFooter:
                """
                    })}).call(this);
                """
        }))
    .pipe(gulp.dest("#{frontendSrc}"))

gulp.task 'copy:js', ->
    gulp.src([
        "#{bowerPath}/jquery/dist/jquery.js"
        "#{bowerPath}/bootstrap/dist/js/bootstrap.min.js"
        "#{bowerPath}/angular/angular.min.js"
        "#{bowerPath}/moment/min/moment.min.js"
        "#{bowerPath}/angular-moment/angular-moment.min.js"
        "#{bowerPath}/parse/parse.min.js"
        "#{bowerPath}/parse-angular-patch/dist/parse-angular.js"
        "#{bowerPath}/angular-bootstrap/ui-bootstrap.min.js"
        "#{bowerPath}/angular-bootstrap/ui-bootstrap-tpls.min.js"
        "#{frontendSrc}/**/*.coffee"
        "#{frontendSrc}/scripts/services/settings.js"
        "#{frontendSrc}/templates.js"
    ])
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulpif(/ui-bootstrap.min.js/,wrap('(function(){\n"use strict";\n<%= contents %>\n})();')))
    .pipe(gulpif(/ui-bootstrap-tpls.min.js/,wrap('(function(){\n"use strict";\n<%= contents %>\n})();')))
    .pipe(concat('all.js'))
    #.pipe(uglify())
    .pipe(gulp.dest("#{frontendDest}/js"))

gulp.task 'copy:html', ->
    gulp.src("#{frontendSrc}/index.jade")
    .pipe(jade())
    .pipe(gulp.dest(frontendDest))

gulp.task 'copy:css', ->
    gulp.src([
        "#{bowerPath}/bootstrap/dist/css/bootstrap.min.css"
        "#{frontendSrc}/styles/**/*.styl"
    ])
    .pipe(gulpif(/[.]styl$/, styl()))
    .pipe(concat('all.css'))
    .pipe(gulp.dest("#{frontendDest}/css"))

gulp.task 'inject', ->
    sources = gulp.src(
        [
            "#{frontendDest}/css/**/*.css"
            "#{frontendDest}/js/**/*.js"
        ],
        { read: false }
    )
    gulp.src("#{frontendDest}/index.html")
    .pipe(inject(sources, {relative: true}))
    .pipe(gulp.dest(frontendDest))

gulp.task 'watch', ->
    gulp.watch(
        [
            "#{frontendSrc}/**/*.jade"
            "#{frontendSrc}/**/*.styl"
            "#{frontendSrc}/**/*.coffee"
        ], () ->
        runSequence(
            'templateCache',
            'copy',
            'inject',
        )
    )

gulp.task 'default', () ->
    gulp.start 'server-side'
    runSequence(
        'clean:build',
        ['gulpNgConfig', 'templateCache'],
        ['copy:js', 'copy:html', 'copy:css'],
        'inject',
        'clean:extra'
        #'watch'
    )

