'use strict';

/**
  * Load Dependiencies
  */

var gulp       = require('gulp'),
  connect      = require('gulp-connect'),
  history      = require('connect-history-api-fallback'),
  coffeelint   = require('gulp-coffeelint'),
  stylish      = require('coffeelint-stylish'),
  uglify       = require('gulp-uglify'),
  sass         = require('gulp-sass'),
  minifyCSS    = require('gulp-minify-css'),
  clean        = require('gulp-clean'),
  livereload   = require('gulp-livereload'),
  coffee       = require('gulp-coffee'),
  jade         = require('gulp-jade'),
  gutil        = require('gulp-util'),
  wiredep      = require('wiredep').stream,
  karma        = require('karma').Server,
  protractor   = require('gulp-protractor').protractor;

/**
  * Gulp Configurations
  */

var config = {
  tmpDir: './.tmp',
  prodDir: './dist',
  prod: !!gutil.env.production,
  serve: !gutil.env.build,
  init: function(){
    this.buildDir = this.prod ? this.prodDir : this.tmpDir;
    return this;
  }
}.init();

/**
  * Build Tasks
  */

// lint files
gulp.task('lint', function() {
  gulp.src(['./app/**/*.coffee', '!./app/bower_components/**'])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(stylish))
});

// empty .tmp folder
gulp.task('clean', function() {
    gulp.src(config.tmpDir + '/*')
      .pipe(clean({force: true}));
    gulp.src(config.prodDir + '/*')
      .pipe(clean({force: true}));
});

// Render coffescript to js
gulp.task('coffee', function(){
  if (!gutil.env.webstorm) {
    gulp.src('./app/**/*.coffee')
        .pipe(coffee({bare: false}).on('error', gutil.log))
        .pipe(gulp.dest(config.buildDir));
  }
  // copy in config file
  gulp.src('./config/*')
    .pipe(gulp.dest(config.buildDir + '/js/config'));
  // Production Uglify
  if(config.prod){
    gulp.src([config.prodDir + '/**/*.js'])
      .pipe(uglify())
      .pipe(gulp.dest(config.prodDir));
  }
});

gulp.task('sass', function(){
  var dir = config.buildDir;
  var dev = {sourceComments: true};
  var prod = {outputStyle: 'compressed'};
  gulp.src('./app/sass/main.scss')
    .pipe(wiredep())
    .pipe(gulp.dest('./app/sass'));
  gulp.src(['./app/sass/**/*.scss'])
    .pipe(sass(config.prod? prod : dev).on('error', sass.logError))
    .pipe(gulp.dest(dir + '/css'));

});

gulp.task('jade', function(){
  var options = {pretty: config.prod? false : true}
  gulp.src(['./app/**/*.jade', '!./app/index.jade', '!./app/views/includes/**/*.jade'])
    .pipe(jade(options))
    .pipe(gulp.dest(config.buildDir));
  // Inject bower depenencies
  gulp.src('./app/index.jade')
    .pipe(jade(options))
    .pipe(wiredep({
      ignorePath:  /\.\.\//,
    }))
    .pipe(gulp.dest(config.buildDir));
});

// Pull in html files
gulp.task('copy-img', function () {
  gulp.src('./app/images/**/*')
    .pipe(gulp.dest(config.buildDir + '/images'));
});

gulp.task('copy-font', function () {
  gulp.src('./app/fonts/**/*')
    .pipe(gulp.dest(config.buildDir + '/fonts'));
});

// Setup bower dependencies
gulp.task('bower', function () {
  var dir = config.buildDir;
  // Copy bower components
  gulp.src('./bower_components/**')
    .pipe(gulp.dest(dir + '/bower_components'));
});


/**
  * Testing Tasks
  */

gulp.task('unit', function (done) {
  new karma({
    configFile: __dirname + '/tests/karma.conf.js',
    singleRun: true
  }, done).start();
});

gulp.task('e2e', function(done) {
  var args = ['--baseUrl', 'http://127.0.0.1:8888'];
  gulp.src(["./tests/e2e/*.js"])
    .pipe(protractor({
      configFile: "tests/protractor.conf.js",
      args: args
    }))
    .on('error', function(e) { throw e; });
});


/**
  * Serve Tasks
  */

gulp.task('serve', function () {
  if(config.serve){
    gutil.log("Running server from " + config.buildDir);
    connect.server({
      root: config.buildDir,
      port: config.prod ? 9999 : 8888,
      middleware: function(connect, opt) {
        return [ history() ];
      }
    });
  }
});

//Connect Livereload for easy Development
gulp.task('livereload', function() {
  livereload.reload();
})

gulp.task('watch', function() {
  if(config.serve){
    livereload.listen();
    gulp.watch(['app/**/*.jade', 'app/js/**/*.coffee', 'app/sass/**/*.scss'], ['livereload', 'lint', 'coffee', 'sass', 'jade', 'copy-img']);
  }
});


// default task
gulp.task('default',
  ['lint', 'coffee', 'sass', 'jade', 'copy-img', 'copy-font', 'bower', 'serve', 'watch']
);
