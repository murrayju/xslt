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

    ns = (id, extra='') -> "xmlns:ns#{id}=\"urn:test:ns#{id}#{extra}\""

    it 'can move namespaces up to root', ->
      str = xslt.cleanup(
        """
        <?xml version="1.0" encoding="UTF-8" ?>
        <root xmlns="urn:test:root" #{ns(1)}>
          <ns1:thing #{ns(2)} ns2:id="a">
            <ns2:inner #{ns(3)} ns3:id="b"/>
            <ns2:inner #{ns(2, 'alt')} ns2:id="c"/>
            <ns2:inner #{ns(3)} ns3:id="d"/>
          </ns1:thing>
          <rootThing #{ns(4)} #{ns(1, 'alt')}>
            <ns4:inner #{ns(5)} id="e"/>
            <ns1:inner id="f"/>
          </rootThing>
        </root>
        """
        {
          moveNamespacesToRoot: true
          excludedNamespaceUris: [
            'urn:test:ns5'
          ]
        }
      )
      util.xmlDiff(
        """
        <?xml version="1.0" encoding="UTF-8" ?>
        <root xmlns="urn:test:root" #{ns(1)} #{ns(2)} #{ns(3)} #{ns(4)}>
          <ns1:thing ns2:id="a">
            <ns2:inner ns3:id="b"/>
            <ns2:inner #{ns(2, 'alt')} ns2:id="c"/>
            <ns2:inner ns3:id="d"/>
          </ns1:thing>
          <rootThing #{ns(1, 'alt')}>
            <ns4:inner id="e"/>
            <ns1:inner id="f"/>
          </rootThing>
        </root>
        """
        str
      )
