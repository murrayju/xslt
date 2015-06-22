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
            'cs': debug ? 'lib/require-cs/cs' : '../test/karma/cs-passthrough',
            'coffee': 'lib/require-cs/cs',
            text: 'lib/text/text',
            prettydiff: 'lib/prettydiff/prettydiff',
            jquery: 'lib/jquery/jquery',
            'coffee-script': 'lib/coffee-script/extras/coffee-script'
        },

        // dynamically load all test files
        deps: allTestFiles,

        // we have to kickoff jasmine, as it is asynchronous
        callback: window.__karma__.start
    });
}(window.requirejs));
