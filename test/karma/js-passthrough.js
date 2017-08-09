/*global define*/

// This acts as a dummy plugin for requirejs.
// This is already a js file, just pass it through with a .js extension
define(['passthrough'], function (passthrough) {
    'use strict';
    return passthrough('.js');
});
