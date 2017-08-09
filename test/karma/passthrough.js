/*global define*/

// Used to generate a passthrough plugin for whatever file extension is specified
define([], function () {
    'use strict';
    
    // This is a factory function
    return function (extension) {
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
                var path = req.toUrl(name + extension);
                fetchText(path, function (text) {
                    onload.fromText(name, text);
                });
            }
        };
    };
});
