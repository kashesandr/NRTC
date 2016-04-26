require('coffee-script/register')

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
multipipe = require 'multipipe'
uglify = require 'gulp-uglify'
license = require 'gulp-license'
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
    runSequence(
        'server-side:configs'
        'server-side:scripts'
    )

gulp.task 'server-side:scripts', ->
    gulp.src([
        "#{backendSrc}/**/*.coffee"
        "!#{backendSrc}/**/*test.coffee"
    ])
    .pipe(coffee())
    .pipe(uglify(
        mangling: true
    ))
    .pipe(gulp.dest(backendDest))

gulp.task 'server-side:configs', ->
    replaceConfigs = multipipe(
        replace(/"PARSE": \{(.*)\}/, "\"PARSE\": #{JSON.stringify GLOBAL_CONFIGS.PARSE}"),
        replace(/"DATABASE": \{(.*)\}/, "\"DATABASE\": #{JSON.stringify GLOBAL_CONFIGS.DATABASE}")
    )
    gulp.src([
        "#{backendSrc}/**/settings.json"
    ])
    .pipe(replaceConfigs)
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
        "!#{frontendSrc}/**/*test.coffee"
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
    gulp.watch( ["#{rootSrcPath}/**/*.jade"], ['default'] )
    gulp.watch( ["#{rootSrcPath}/**/*.styl"], ['default'] )
    gulp.watch( ["#{rootSrcPath}/**/*.coffee"], ['default'] )

gulp.task 'default', () ->
    runSequence(
        'clean:build',
        ['gulpNgConfig', 'templateCache', 'server-side'],
        ['copy:js', 'copy:html', 'copy:css'],
        'inject',
        'clean:extra'
        'license'
        #'watch'
    )

gulp.task 'test:backend', ->
    # test backend
    gulp.src "#{backendSrc}/**/*test.coffee"
    .pipe mocha
        clearRequireCache: true
        ignoreLeaks: true
        reporter: 'list'
        timeout: 4000

gulp.task 'test:frontend', ->
    # not yet

gulp.task 'license:frontend', ->
    gulp.src("#{frontendDest}/**/*.js")
    .pipe(license('Apache', {tyny: false, organization: 'http://kashesandr.com'}))
    .pipe(gulp.dest(frontendDest))

gulp.task 'license:backend', ->
    gulp.src("#{backendDest}/**/*.js")
    .pipe(license('Apache', {tyny: false, organization: 'http://kashesandr.com'}))
    .pipe(gulp.dest(backendDest))

gulp.task 'license', ->
    runSequence [
        'license:backend'
        'license:frontend'
    ]

gulp.task 'test', ->
    runSequence [
        'test:backend'
        'test:frontend'
    ]