/*global define*/

// This acts as a dummy coffeescript plugin for requirejs.
// The code coverage preprocessor already compiled the .coffee file to .js,
// so we just pass through to the normal require call
define(['passthrough'], function (passthrough) {
    'use strict';
    return passthrough('.coffee');
});
