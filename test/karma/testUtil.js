/*jslint vars:true*/
/*global define, expect*/

define(['jquery', 'prettydiff'], function ($, prettydiff) {
    'use strict';

    var util = {};

    util.xmlDiff = function (orig, diff, html) {
        expect(typeof orig).toEqual('string');
        expect(typeof diff).toEqual('string');
        var source = prettydiff({
            source: orig,
            lang: 'markup',
            mode: 'minify'
        });
        var changedDoc = prettydiff({
            source: diff,
            lang: 'markup',
            mode: 'minify'
        });

        expect(source[0]).not.toMatch(/^Error:/);
        expect(changedDoc[0]).not.toMatch(/^Error:/);

        var pretty = prettydiff({
            source: source[0],
            diff: changedDoc[0],
            lang: 'markup',
            force_indent: html,
            context: 1
        });
        var results = $(pretty[0]);
        var diffInfo = results.eq(11).find('p:nth-child(4)');
        var diffCount = parseInt(diffInfo.contents().eq(2).text());
        var diffLines = parseInt(diffInfo.contents().eq(4).text());
        expect(diffCount).toBe(0);
        expect(diffLines).toBe(0);
        if (diffCount > 0) {
            console.log(diffInfo.text());
            var left = results.eq(13).find('div.diff-left > ol.data').find('li.empty, li.replace, li.delete, li.insert');
            var right = results.eq(13).find('div.diff-right > ol.data').find('li.empty, li.replace, li.delete, li.insert');
            expect(left.length).toEqual(right.length);
            left.each(function (i) {
                var l = $(this);
                var r = right.eq(i);
                expect(r.text().trim()).toEqual(l.text().trim());
            });
        }
    };

    return util;
});
