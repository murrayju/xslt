/*jslint browser: true, nomen: true, vars:true */
(function (requirejs) {
    'use strict';

    var args = window.__karma__.config.args;
    var debug = args.length && (args[0] === '--testDebug');
    var allTestFiles = [];
    var pathToModule = function (path) {
        var base = path.replace(/^\/base\//, '../');
        if (/\.coffee$/.test(base)) {
            return (debug ? 'cs!' : 'coffee!') + base.replace(/\.coffee$/, '');
        }
        return base.replace(/\.js$/, '');
    };

    Object.keys(window.__karma__.files).forEach(function (file) {
        if (/^\/base\/test\/karma\/.*(spec|test)\.(js|coffee)$/i.test(file) || /^\/base\/test\/karma\/helpers\/.*\.(js|coffee)$/i.test(file)) {
            // Normalize paths to RequireJS module names.
            allTestFiles.push(pathToModule(file));
        }
    });

    requirejs.config({
        // Karma serves files under /base, which is the basePath from your config file
        baseUrl: '/base/src',
        waitSeconds: 0,

        paths: {
            // test only
            'cs': debug ? '../bower_components/require-cs/cs' : '../test/karma/cs-passthrough',
            'coffee': '../bower_components/require-cs/cs',
            text: '../bower_components/text/text',
            prettydiff: '../bower_components/prettydiff/prettydiff',
            jquery: '../bower_components/jquery/dist/jquery',
            'coffee-script': '../bower_components/coffee-script/docs/v1/browser-compiler/coffee-script'
        },

        // dynamically load all test files
        deps: allTestFiles,

        // we have to kickoff jasmine, as it is asynchronous
        callback: window.__karma__.start
    });
}(window.requirejs));
