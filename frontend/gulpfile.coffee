gulp = require 'gulp'
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

src = "src"
dest = "build"
bowerPath = "../bower_components"

gulp.task 'clean:build', ->
    gulp.src(dest, {read: false})
    .pipe(clean())

gulp.task 'clean:extra', ->
    gulp.src(
        [
            "#{src}/**/*.js",
            "#{src}/**/*.html",
            "#{src}/**/*.css"
        ],
        {read: false}
    )
    .pipe(clean())

gulp.task 'templateCache', ->
    gulp.src("#{src}/**/*template.jade")
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
    .pipe(gulp.dest("#{src}"))

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
        "#{src}/**/*.coffee"
        "#{src}/templates.js"
    ])
    .pipe(gulpif(/[.]coffee$/, coffee()))
    .pipe(gulpif(/ui-bootstrap.min.js/,wrap('(function(){\n"use strict";\n<%= contents %>\n})();')))
    .pipe(gulpif(/ui-bootstrap-tpls.min.js/,wrap('(function(){\n"use strict";\n<%= contents %>\n})();')))
    .pipe(concat('all.js'))
    #.pipe(uglify())
    .pipe(gulp.dest("#{dest}/js"))

gulp.task 'copy:html', ->
    gulp.src("#{src}/index.jade")
    .pipe(jade())
    .pipe(gulp.dest(dest))

gulp.task 'copy:css', ->
    gulp.src([
        "#{bowerPath}/bootstrap/dist/css/bootstrap.min.css"
        "#{src}/styles/**/*.styl"
    ])
    .pipe(gulpif(/[.]styl$/, styl()))
    .pipe(concat('all.css'))
    .pipe(gulp.dest("#{dest}/css"))

gulp.task 'inject', ->
    sources = gulp.src(
        [
            "#{dest}/css/**/*.css"
            "#{dest}/js/**/*.js"
        ],
        { read: false }
    )
    gulp.src("#{dest}/index.html")
    .pipe(inject(sources, {relative: true}))
    .pipe(gulp.dest(dest))    

gulp.task 'watch', ->
    gulp.watch(
        [
            "#{src}/**/*.jade"
            "#{src}/**/*.styl"
            "#{src}/**/*.coffee"
        ], () ->
            runSequence(
                'templateCache',
                'copy',
                'inject',
                'clean:extra'
            )
    )

gulp.task 'default', (callback) ->
    runSequence(
        'clean:build'
        'templateCache'
        'copy:js'
        'copy:html'
        'copy:css'
        'inject'
        #'clean:extra'
        #'watch'
    )
