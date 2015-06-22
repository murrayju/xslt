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
  activeXSupported = ActiveXObject? || 'ActiveXObject' in window

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
    d ?= new DOMParser?()
    d ?= createDomDoc()
    d ?= manualCreateElement()
    d ?= document.implementation?.createDocument?("", 'test', null);
    return d


  strToDoc = (str) ->
    return null if (typeof str != 'string') or !isXml(str)
    str = prependHeader(str) if needsHeader(str)

    d = newDocument()
    if d?.loadXML?
      d.loadXML(str)
      if !d.documentElement? || d.parseError?.errorCode != 0
        throw "loadXML error: #{d.parseError}"
    else if d?.load?
      d.load(str)
    else if d?.parseFromString?
      d = d.parseFromString(str, 'text/xml')
      if d?.getElementsByTagName?('parsererror')?.length > 0 || d?.documentElement?.tagName == 'parsererror'
        throw "Failed to load document from string:\r\n#{d.documentElement.textContent}"
    return d


  return (xmlStr, xsltStr) ->

    if XSLTProcessor? and document?.implementation?.createDocument?
      processor = new XSLTProcessor()

