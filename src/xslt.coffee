((root, factory) ->
  if (typeof define == 'function' && define.amd?)
    # AMD
    define([], factory)
  else if (typeof module?.exports == 'object')
    # CommonJS
    module.exports = factory()
  else
    # global
    root?.xslt = factory()
) this, ->

  isXml = (str) -> /^\s*</.test(str)
  hasXmlHeader = (str) -> /^\s*<\?/.test(str)
  needsHeader = (str) -> isXml(str) && !hasXmlHeader(str)
  xmlHeader = '<?xml version="1.0" ?>'
  prependHeader = (str) -> xmlHeader + str
  activeXSupported = ActiveXObject? || 'ActiveXObject' of window

  tryCreateActiveX = (objIds...) ->
    return null unless activeXSupported
    for id in objIds
      try
        return new ActiveXObject(id)
    return null

  createDomDoc = ->
    d = tryCreateActiveX([
      "Msxml2.FreeThreadedDOMDocument.6.0"
      "Msxml2.FreeThreadedDOMDocument.3.0"
      "Msxml2.FreeThreadedDOMDocument"
      "Microsoft.XMLDOM"
      "Msxml2.DOMDocument.6.0"
      "Msxml2.DOMDocument.5.0"
      "Msxml2.DOMDocument.4.0"
      "Msxml2.DOMDocument.3.0"
      "MSXML2.DOMDocument"
      "MSXML.DOMDocument"
    ]...)
    if d?
      d.async = false
      null while d.readyState != 4
    return d

  createXSLTemplate = -> tryCreateActiveX([
    'Msxml2.XSLTemplate.6.0'
    'Msxml2.XSLTemplate'
  ]...)

  manualCreateElement = ->
    xml = document.createElement('xml')
    xml.src = xmlHeader
    document.body.appendChild(xml)
    res = xml.XMLDocument
    document.body.removeChild(xml)
    return res

  newDocument = ->
    d = null
    d ?= createDomDoc()
    return d if DOMParser?
    d ?= manualCreateElement()
    d ?= document.implementation?.createDocument?("", 'test', null)
    return d


  strToDoc = (str) ->
    return null if (typeof str != 'string') or !isXml(str)
    str = prependHeader(str) if needsHeader(str)

    d = newDocument()
    if d? and 'loadXML' of d
      d.loadXML(str)
      if !d.documentElement? || d.parseError?.errorCode != 0
        throw new Error("loadXML error: #{d.parseError}")
    else if d? and 'load' of d
      d.load(str)
    else if DOMParser?
      d = (new DOMParser?())?.parseFromString?(str, 'text/xml')
      if d?.getElementsByTagName?('parsererror')?.length > 0 || d?.documentElement?.nodeName == 'parsererror'
        throw new Error("Failed to load document from string:\r\n#{d.documentElement.textContent}")
    return d

  docToStr = (doc) ->
    return null unless doc?
    xml = doc?.xml || new XMLSerializer?()?.serializeToString?(doc)
    if xml?.indexOf?("<transformiix::result") >= 0
      xml = xml.substring(xml.indexOf(">") + 1, xml.lastIndexOf("<"))
    return xml

  return (xmlStr, xsltStr, asFullDocument) ->
    xmlDoc = strToDoc(xmlStr)
    xsltDoc = strToDoc(xsltStr)
    return false unless xmlDoc? and xsltDoc?

    if XSLTProcessor? and document?.implementation?.createDocument?
      processor = new XSLTProcessor()
      processor.importStylesheet(xsltDoc)
      trans = if asFullDocument
        processor.transformToDocument(xmlDoc)
      else
        processor.transformToFragment(xmlDoc, document)
    else if 'transformNode' of xmlDoc
      return xmlDoc.transformNode(xsltDoc)
    else if activeXSupported
      xslt = createXSLTemplate()
      xslt.stylesheet = xsltDoc
      xslProc = xslt.createProcessor()
      xslProc.input = xmlDoc
      xslProc.transform()
      trans = xslProc.output

    return docToStr(trans)

