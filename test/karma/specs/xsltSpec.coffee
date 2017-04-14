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
  'text!/base/test/data/closingTags-expanded.xml'
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
  closingExpanded
) ->

  describe 'xslt', ->

    it 'should exist', () ->
      expect(xslt).toBeDefined()
      expect(xslt.cleanup).toBeDefined()
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
      util.xmlDiff(closingCollapsed, str, true)

    it 'can expand collapsed tags', ->
      str = xslt(closingMix, passthrough, {collapseEmptyElements: false, expandCollapsedElements: true})
      util.xmlDiff(closingExpanded, str, true)

    it 'can do cleanup as a separate step', ->
      str = xslt(closingMix, passthrough, {cleanup: false})
      str = xslt.cleanup(str)
      expect(str).not.toMatch(/<\/rabbit>/)
      util.xmlDiff(closingCollapsed, str)

    it 'can preserve encoding', ->
      str = xslt(helloXmlAsc, passthrough, {preserveEncoding: true})
      util.xmlDiff(helloXmlAsc, str)

    it 'throws on invalid xml', ->
      try
        ret = xslt('something invalid', helloXsl)
        expect(ret).toBe('should not get here')
      catch err
        expect(err).toBeDefined()
        expect(err.message).toMatch(/XML/)

    it 'throws on invalid xslt', ->
      try
        ret = xslt(helloXml, 'something invalid')
        expect(ret).toBe('should not get here')
      catch err
        expect(err).toBeDefined()
        expect(err.message).toMatch(/XSLT/)
