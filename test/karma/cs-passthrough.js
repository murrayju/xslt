/*global define*/

// This acts as a dummy coffeescript plugin for requirejs.
// The code coverage preprocessor already compiled the .coffee file to .js,
// so we just pass through to the normal require call
define([], function () {
    'use strict';

    var fetchText = function (url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onreadystatechange = function (evt) {
            //Do not explicitly handle errors, those should be
            //visible via console output in the browser.
            if (xhr.readyState === 4) {
                callback(xhr.responseText);
            }
        };
        xhr.send(null);
    };
    return {
        load: function (name, req, onload, config) {
            var path = req.toUrl(name + '.coffee');
            fetchText(path, function (text) {
                onload.fromText(name, text);
            });
        }
    };
});