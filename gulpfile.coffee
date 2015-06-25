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
mocha = require 'gulp-mocha'
CONFIGS = JSON.parse fs.readFileSync './settings.json', 'utf8'
GLOBAL_CONFIGS = CONFIGS.GLOBAL_CONFIGS

bowerPath = "bower_components"

rootSrcPath = "src"
rootBuildPath = "build"
frontendPath = "frontend"
backendPath = "backend"

frontendSrc =   "#{rootSrcPath}/#{frontendPath}"
frontendDest =  "#{rootBuildPath}/#{frontendPath}"
backendSrc =    "#{rootSrcPath}/#{backendPath}"
backendDest =   "#{rootBuildPath}/#{backendPath}"
appName = "NRTC"

gulp.task "server-side", ->
    gulp.src([
        "#{backendSrc}/**/*"
        "!#{backendSrc}/**/test.coffee"
    ])
    .pipe(
      gulpif("settings.json",
        replace(/"PARSE": \{(.*)\}/, "\"PARSE\": #{JSON.stringify GLOBAL_CONFIGS.parse}"),
        replace(/"DATABASE": \{(.*)\}/, "\"DATABASE\": #{JSON.stringify GLOBAL_CONFIGS.database}")
        )
    )
    .pipe(gulpif("*.coffee",coffee()))
    .pipe(gulp.dest(backendDest))

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
                        angular.module('#{appName}').run(function($templateCache) {
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

gulp.task 'test:backend', ->
    # test backend
    gulp.src "#{backendSrc}/**/test.coffee"
    .pipe mocha
        clearRequireCache: true
        ignoreLeaks: true
        reporter: 'list'

gulp.task 'test:frontend', ->
    # not yet

gulp.task 'test', ->
    runSequence(
      [
        'test:backend'
        'test:frontend'
      ]
    )