define [
  'cs!xslt'
  '/base/test/karma/testUtil.js'
  'text!/base/test/data/hello.xml'
  'text!/base/test/data/hello.xsl'
  'text!/base/test/data/hello.html'
], (
  xslt
  util
  helloXml
  helloXsl
  helloOutput
) ->

  describe 'xslt', ->

    it 'should exist', () ->
      expect(xslt).toBeDefined()
      expect(typeof xslt).toBe('function')

    it 'can do a simple transform', ->
      str = xslt(helloXml, helloXsl, true)
      util.xmlDiff(helloOutput, str, true)
