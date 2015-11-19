define [
  'cs!xslt'
  '/base/test/karma/testUtil.js'
  'text!/base/test/data/namespaces.xsl'
  'text!/base/test/data/namespaces-in.xml'
  'text!/base/test/data/namespaces-out.xml'
  'text!/base/test/data/namespaces-redundant.xml'
  'text!/base/test/data/namespaces-white-black.xml'
], (
  xslt
  util
  xsl
  xmlIn
  xmlOut
  xmlRedundant
  xmlWhiteBlack
) ->

  describe 'namespaces', ->

    it 'should be applied to attributes', ->
      str = xslt(xmlIn, xsl)
      util.xmlDiff(xmlOut, str)

    it 'removes redundant namespaces', ->
      str = xslt.cleanup(xmlRedundant)
      util.xmlDiff(xmlIn, str)

    it 'can include/exclude namespaces', ->
      str = xslt.cleanup xmlWhiteBlack,
        includeNamespaces:
          ns3: 'urn:test:ns3'
        excludedNamespaceUris: ['urn:test:ns4']
      util.xmlDiff(xmlIn, str)
