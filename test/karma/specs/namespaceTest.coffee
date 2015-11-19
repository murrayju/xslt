define [
  'cs!xslt'
  '/base/test/karma/testUtil.js'
  'text!/base/test/data/namespaces.xsl'
  'text!/base/test/data/namespaces-in.xml'
  'text!/base/test/data/namespaces-out.xml'
  'text!/base/test/data/namespaces-redundant.xml'
], (
  xslt
  util
  xsl
  xmlIn
  xmlOut
  xmlRedundant
) ->

  describe 'namespaces', ->

    it 'should be applied to attributes', ->
      str = xslt(xmlIn, xsl)
      util.xmlDiff(xmlOut, str)

    it 'removes redundant namespaces', ->
      str = xslt.cleanup(xmlRedundant)
      util.xmlDiff(xmlIn, str)
