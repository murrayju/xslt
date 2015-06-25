define [
  'cs!xslt'
  '/base/test/karma/testUtil.js'
  'text!/base/test/data/hello.xml'
  'text!/base/test/data/helloAscii.xml'
  'text!/base/test/data/hello.xsl'
  'text!/base/test/data/hello.html'

  'text!/base/test/data/passthrough.xsl'
  'text!/base/test/data/closingTags-mixture.xml'
  'text!/base/test/data/closingTags-collapsed.xml'
], (
  xslt
  util
  helloXml
  helloXmlAsc
  helloXsl
  helloOutput

  passthrough
  closingMix
  closingCollapsed
) ->

  describe 'xslt', ->

    it 'should exist', () ->
      expect(xslt).toBeDefined()
      expect(typeof xslt).toBe('function')

    it 'can do a simple transform', ->
      str = xslt(helloXml, helloXsl, {removeAllNamespaces: true})
      util.xmlDiff(helloOutput, str)

    it 'can strip xml header', ->
      str = xslt(helloXml, helloXsl, {
        removeAllNamespaces: true
        xmlHeaderInOutput: false
      })
      util.xmlDiff(helloOutput.replace(/\s*<\?xml[^<]+/, ''), str)

    it 'can collapse empty tags', ->
      str = xslt(closingMix, passthrough)
      util.xmlDiff(closingCollapsed, str)

    it 'can preserve encoding', ->
      str = xslt(helloXmlAsc, passthrough, {preserveEncoding: true})
      util.xmlDiff(helloXmlAsc, str)
