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
            prettydiff: '../test/karma/prettydiff-hacked',
            'prettydiff-global': '../test/karma/prettydiff-global',
            'prettydiff-global-shell': '../test/karma/prettydiff-global-shell',
            'prettydiff-language': '../bower_components/prettydiff/lib/language',
            'prettydiff-options': '../bower_components/prettydiff/lib/options',
            'prettydiff-finalFile': '../bower_components/prettydiff/lib/finalFile',
            'prettydiff-safeSort': '../bower_components/prettydiff/lib/safeSort',
            'prettydiff-ace': '../bower_components/prettydiff/ace/ace',
            'prettydiff-dom': '../bower_components/prettydiff/api/dom',
            'prettydiff-csspretty': '../bower_components/prettydiff/lib/csspretty',
            'prettydiff-csvpretty': '../bower_components/prettydiff/lib/csvpretty',
            'prettydiff-diffview': '../bower_components/prettydiff/lib/diffview',
            'prettydiff-jspretty': '../bower_components/prettydiff/lib/jspretty',
            'prettydiff-markuppretty': '../bower_components/prettydiff/lib/markuppretty',
            jquery: '../bower_components/jquery/dist/jquery',
            'coffee-script': '../bower_components/coffee-script/docs/v1/browser-compiler/coffee-script'
        },

        shim: {
            prettydiff: {
                deps: [ 'prettydiff-global' ],
                exports: 'global.prettydiff'
            },
            'prettydiff-language': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-options': {
                deps: [
                    'prettydiff-global-shell',
                    'prettydiff-language'
                ],
            },
            'prettydiff-finalFile': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-safeSort': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-ace': {
                deps: [
                    'prettydiff-global-shell',
                    'prettydiff-markuppretty'
                ],
            },
            'prettydiff-dom': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-csspretty': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-csvpretty': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-diffview': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-jspretty': {
                deps: ['prettydiff-global-shell'],
            },
            'prettydiff-markuppretty': {
                deps: [
                    'prettydiff-global-shell',
                    'prettydiff-safeSort',
                    'prettydiff-csspretty',
                    'prettydiff-jspretty'
                ],
            }

        },

        // dynamically load all test files
        deps: allTestFiles,

        // we have to kickoff jasmine, as it is asynchronous
        callback: window.__karma__.start
    });
}(window.requirejs));
