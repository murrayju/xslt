# xslt
![Bower version](https://img.shields.io/bower/v/xslt.svg)
[![npm version](https://img.shields.io/npm/v/xslt.svg)](https://www.npmjs.com/package/xslt)
[![Build Status](https://travis-ci.org/murrayju/xslt.svg?branch=master)](https://travis-ci.org/murrayju/xslt)
[![Coverage Status](https://coveralls.io/repos/murrayju/xslt/badge.svg)](https://coveralls.io/r/murrayju/xslt)
[![devDependency Status](https://david-dm.org/murrayju/xslt/dev-status.svg)](https://david-dm.org/murrayju/xslt#info=devDependencies)

[![Sauce Test Status](https://saucelabs.com/browser-matrix/murrayju_xslt.svg)](https://saucelabs.com/u/murrayju_xslt)

A simple wrapper around browser based xslt. Includes some cleanup options to help normalize the output across browsers.

## Quick start

Several options are available to get started:

- [Download the latest release](https://github.com/murrayju/xslt/releases).
- Clone the repo: `git clone https://github.com/murrayju/xslt.git`.
- Install with [Bower](http://bower.io): `bower install xslt`.
- Install with [npm](https://www.npmjs.com): `npm install xslt`.

## Example

```js
// Here are the options with their default values
options = {
  fullDocument: false, // Is the output a complete document, or a fragment?
  cleanup: true, // false will disable all of the below options
  xmlHeaderInOutput: true,
  normalizeHeader: true,
  encoding: 'UTF-8',
  preserveEncoding: false, // When false, always uses the above encoding. When true, keeps whatever the doc says
  removeDupNamespace: true,
  removeDupAttrs: true,
  removeNullNamespace: true,
  removeAllNamespaces: false,
  removeNamespacedNamespace: true,
  moveNamespacesToRoot: false,

  // These two are mutually exclusive. Attempting to use both is the same as using neither
  collapseEmptyElements: true, // Forces output of self-closing tags
  expandCollapsedElements: false, // Forces output of separate closing tags
};
outputXmlString = xslt(inputXmlString, xslString, options);
```

It is also possible to just run the cleanup function itself. This uses the same `options` as above.
```js
outputXmlString = xslt.cleanup(intermediateXmlString, options);
```
