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

  regex =
    xmlNode: -> /<([a-z_][a-z_0-9:\.\-]*\b)\s*(?:\/(?!>)|[^>\/])*(\/?)>/i
    xmlLike: -> /^\s*</
    xmlHeader: -> /^\s*<\?xml\b[^<]+/i
    namespaces: -> /\bxmlns(:[a-z0-9:\-]+)?\s*=\s*"[^"]*"/ig
  isXml = (str) -> regex.xmlLike().test(str)
  hasXmlHeader = (str) -> regex.xmlHeader().test(str)
  needsHeader = (str) -> isXml(str) && !hasXmlHeader(str)
  xmlHeader = (encoding, standalone) ->
    str = '<?xml version="1.0" '
    str += "encoding=\"#{encoding}\" " if encoding?
    str += "standalone=\"#{standalone}\" " if standalone?
    str += '?>'
    return str
  prependHeader = (str, encoding, standalone) -> xmlHeader(encoding, standalone) + str
  stripHeader = (str) -> str?.replace(regex.xmlHeader(), '')
  getHeader = (str) ->
    match = str?.match(regex.xmlHeader())
    return (match?.length && match[0]?.trim?()) || null
  getAttrVal = (node, attrName) ->
    match = (new RegExp('\\b' + attrName + '\\s*=\\s*"([^"]*)"', 'g')).exec(node)
    return (match?.length > 1 && match[1]) || null
  getHeaderEncoding = (str) -> getAttrVal(getHeader(str), 'encoding')
  getHeaderStandalone = (str) -> getAttrVal(getHeader(str), 'standalone')

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
    xml.src = xmlHeader()
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
      d = (new DOMParser())?.parseFromString?(str, 'text/xml')
      if d?.getElementsByTagName?('parsererror')?.length > 0 || d?.documentElement?.nodeName == 'parsererror'
        throw new Error("Failed to load document from string:\r\n#{d.documentElement.textContent}")
    return d

  docToStr = (doc) ->
    return null unless doc?
    xml = if (typeof doc) == 'string'
      doc
    else if doc?.xml?
      doc.xml
    else if XMLSerializer?
      (new XMLSerializer())?.serializeToString?(doc)
    else
      null
    if xml?.indexOf?("<transformiix::result") >= 0
      xml = xml.substring(xml.indexOf(">") + 1, xml.lastIndexOf("<"))
    return xml

  # If a ns is defined in the root node, it should not be redefined later
  stripRedundantNamespaces = (xml) ->
    # start with the first node
    matches = xml?.match(regex.xmlNode())
    return xml unless matches?.length

    rootNode = matches[0]
    rootNamespaces = rootNode.match(regex.namespaces())
    return xml unless rootNamespaces?.length

    offset = xml.indexOf(rootNode)
    start = xml.substring(0, offset + rootNode.length)
    remainder = xml.substring(offset + rootNode.length)
    return start + remainder.replace regex.namespaces(), (ns) ->
      return '' if ns in rootNamespaces
      return ns

  stripDuplicateAttributes = (node, nodeName, closeTag) ->
    attrRegex = /([a-zA-Z0-9:\-]+)\s*=\s*("[^"]*")/g
    collection = {}
    parts = attrRegex.exec(node)
    while parts
      collection[parts[1]] = parts[0]
      parts = attrRegex.exec(node)
    newStr = '<' + nodeName
    newStr += (' ' + val) for key, val of collection
    newStr += (closeTag || '') + '>'
    return newStr

  stripNullNamespaces = (node) -> node.replace(/xmlns\s*=\s*""/gi, '')

  stripAllNamespaces = (node) -> node.replace(regex.namespaces(), '')

  # This happens in IE 10
  stripNamespacedNamespace = (node) ->
    nums = []
    node = node.replace /xmlns:NS([0-9]+)=""/gi, (match, num) ->
      nums.push(num)
      return ''
    for num in nums
      node = node.replace(new RegExp("NS" + num + ":xmlns:", "g"), "xmlns:")
    return node

  # Combine rules that apply to a single node at a time
  cleanupXmlNodes = (xml, opt) ->
    return xml?.replace new RegExp(regex.xmlNode().source, 'gi'), (node, nodeName, closeTag) ->
      node = stripNamespacedNamespace(node) if opt.removeNamespacedNamespace
      node = stripNullNamespaces(node) if opt.removeNullNamespace
      node = stripAllNamespaces(node) if opt.removeAllNamespaces
      node = stripDuplicateAttributes(node, nodeName, closeTag) if opt.removeDupAttrs
      return node

  collapseEmptyElements = (xml) ->
    return xml?.replace /(<([a-z_][a-z_0-9:\.\-]*\b)\s*(?:\/(?!>)|[^>\/])*)><\/\2>/gi, (all, element) ->
      return "#{element}/>"

  defaults =
    fullDocument: false
    cleanup: true
    xmlHeaderInOutput: true
    normalizeHeader: true
    encoding: 'UTF-8'
    preserveEncoding: false
    collapseEmptyElements: true
    removeDupNamespace: true
    removeDupAttrs: true
    removeNullNamespace: true
    removeAllNamespaces: false
    removeNamespacedNamespace: true

  loadOptions = (options) ->
    opt = {}
    opt[p] = defaults[p] for p of defaults
    opt[p] = options[p] for p of options if options?
    return opt

  $xslt = (xmlStr, xsltStr, options) ->
    opt = loadOptions(options)

    xmlDoc = strToDoc(xmlStr)
    throw new Error('Failed to load the XML document') unless xmlDoc?
    xsltDoc = strToDoc(xsltStr)
    throw new Error('Failed to load the XSLT document') unless xsltDoc?

    if XSLTProcessor? and document?.implementation?.createDocument?
      processor = new XSLTProcessor()
      processor.importStylesheet(xsltDoc)
      trans = if opt.fullDocument
        processor.transformToDocument(xmlDoc)
      else
        processor.transformToFragment(xmlDoc, document)
    else if 'transformNode' of xmlDoc
      trans = xmlDoc.transformNode(xsltDoc)
    else if activeXSupported
      xslt = createXSLTemplate()
      xslt.stylesheet = xsltDoc
      xslProc = xslt.createProcessor()
      xslProc.input = xmlDoc
      xslProc.transform()
      trans = xslProc.output

    outStr = docToStr(trans)
    if opt.preserveEncoding
      opt.encoding = getHeaderEncoding(outStr) || getHeaderEncoding(xmlStr) || opt.encoding
    outStr = $xslt.cleanup(outStr, opt) if opt.cleanup
    return outStr

  $xslt.cleanup = (outStr, options) ->
    opt = loadOptions(options)
    return unless opt.cleanup

    if opt.preserveEncoding
      opt.encoding = getHeaderEncoding(outStr) || opt.encoding
    standalone = getHeaderStandalone(outStr)
    outStr = stripHeader(outStr) if opt.normalizeHeader or !opt.xmlHeaderInOutput
    outStr = prependHeader(outStr, opt.encoding, standalone) if opt.xmlHeaderInOutput and needsHeader(outStr)
    outStr = cleanupXmlNodes(outStr, opt)
    outStr = stripRedundantNamespaces(outStr) if opt.removeDupNamespace
    outStr = collapseEmptyElements(outStr) if opt.collapseEmptyElements
    return outStr

  return $xslt
