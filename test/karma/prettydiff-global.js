define([
    'prettydiff-language',
    'prettydiff-options',
    'prettydiff-finalFile',
    'prettydiff-safeSort',
    'prettydiff-ace',
    'prettydiff-dom',
    'prettydiff-csspretty',
    'prettydiff-csvpretty',
    'prettydiff-diffview',
    'prettydiff-jspretty',
    'prettydiff-markuppretty'
], function (
    language,
    options,
    finalFile,
    safeSort,
    ace,
    dom,
    csspretty,
    csvpretty,
    diffview,
    jspretty,
    markuppretty
) {
    return window.global = {
        prettydiff: {
            pd: {},
            language: language,
            options: options,
            finalFile: finalFile,
            safeSort: safeSort,
            csspretty: csspretty,
            csvpretty: csvpretty,
            diffview: diffview,
            jspretty: jspretty,
            markuppretty: markuppretty
        }
    }
});
