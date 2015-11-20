define [
  'cs!xslt'
  '/base/test/karma/testUtil.js'
  'text!/base/test/data/hello.xml'
  'text!/base/test/data/hello-dupAttr.xml'
  'text!/base/test/data/hello-quotes.xml'
], (
  xslt
  util
  helloXml
  helloDupAttrXml
  helloQuotesXml
) ->

  describe 'xslt', ->

    it 'strips duplicate attributes', () ->
      str = xslt.cleanup(helloDupAttrXml)
      util.xmlDiff(helloXml, str)

    it 'handles different quoting styles', () ->
      str = xslt.cleanup(helloQuotesXml)
      util.xmlDiff(helloQuotesXml, str)
