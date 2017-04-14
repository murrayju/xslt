/*jslint vars:true*/
/*global define, expect*/

define(['jquery', 'prettydiff'], function ($, prettydiff) {
    'use strict';

    var util = {};

    util.xmlDiff = function (orig, diff, noMinify) {
        expect(typeof orig).toEqual('string');
        expect(typeof diff).toEqual('string');

        var prettySource, prettyDiff;
        if (noMinify) {
            prettySource = orig;
            prettyDiff = diff;
        } else {
            var source = prettydiff.prettydiff({
                source: orig,
                lang: 'markup',
                mode: 'minify'
            });
            var changedDoc = prettydiff.prettydiff({
                source: diff,
                lang: 'markup',
                mode: 'minify'
            });

            expect(source[0]).not.toMatch(/^Error:/);
            expect(changedDoc[0]).not.toMatch(/^Error:/);

            prettySource = source[0];
            prettyDiff = changedDoc[0];
        }

        var pretty = prettydiff.prettydiff({
            source: prettySource,
            diff: prettyDiff,
            lang: 'markup',
            force_indent: true,
            html: false,
            tagmerge: false,
            context: 1
        });
        var results = $(pretty);
        var diffInfo = results.eq(0);
        var diffCount = parseInt(diffInfo.contents().eq(2).text());
        var diffLines = parseInt(diffInfo.contents().eq(4).text());
        expect(diffCount).toBe(0);
        expect(diffLines).toBe(0);
        if (diffCount > 0) {
            console.log(diffInfo.text());
            var isInteresting = function ($el) {
                return $el.is('li.empty, li.replace, li.delete, li.insert');
            };
            var diffDetail = results.eq(1);
            var left = diffDetail.find('div.diff-left > ol.data').find('li');
            var right = diffDetail.find('div.diff-right > ol.data').find('li');
            expect(left.length).toEqual(right.length);
            left.each(function (i) {
                var l = $(this);
                var r = right.eq(i);
                if (isInteresting(l) || isInteresting(r)) {
                    expect(r.text().trim()).toEqual(l.text().trim());
                }
            });
        }
    };

    return util;
});
