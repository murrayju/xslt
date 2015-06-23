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

  arrayContains = (arr, val) ->
    for v in arr
      return true if v == val
    return false

  # If a ns is defined in the root node, it should not be redefined later
  stripRedundantNamespaces = (xml) ->
    # start with the first node
    matches = xml.match(/^<([a-zA-Z0-9:\-]+)\s(?:\/(?!>)|[^>\/])*(\/?)>/)
    if matches?.length
      rootNode = matches[0]
      rootNamespaces = rootNode.match(/xmlns(:[a-zA-Z0-9:\-]+)?="[^"]*"/g)

      return rootNode + xml.substr(rootNode.length).replace /xmlns(:[a-zA-Z0-9:\-]+)?="[^"]*"/g, (ns) ->
        return '' if arrayContains(rootNamespaces, ns)
        return ns
    return xml

  stripDuplicateAttributes = (node, nodeName, closeTag) ->
    attrRegex = /([a-zA-Z0-9:\-]+)\s*=\s*("[^"]*")/g
    collection = {}
    parts = attrRegex.exec(node)
    while parts
      collection[parts[1]] = parts[0]
      parts = attrRegex.exec(node)
    newStr = '<' + nodeName
    newStr += (' ' + val) for val of collection
    newStr += (closeTag || '') + '>'
    return newStr

  stripNullNamespaces = (node) -> node.replace(/xmlns\s*=\s*""/gi, '')

  stripAllNamespaces = (node) -> node.replace(/xmlns\s*=\s*"[^"]*"/gi, '')

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
    return xml.replace /<([a-zA-Z0-9:\-]+)\s*(?:\/(?!>)|[^>\/])*(\/?)>/g, (node, nodeName, closeTag) ->
      node = stripNamespacedNamespace(node) if opt.removeNamespacedNamespace
      node = stripNullNamespaces(node) if opt.removeNullNamespace
      node = stripAllNamespaces(node) if opt.removeAllNamespaces
      node = stripDuplicateAttributes(node, nodeName, closeTag) if opt.removeDupAttrs
      return node

  defaults =
    fullDocument: false
    cleanup: true
    removeDupNamespace: true
    removeDupAttrs: true
    removeNullNamespace: true
    removeAllNamespaces: false
    removeNamespacedNamespace: true

  return (xmlStr, xsltStr, options) ->
    opt = {}
    opt[p] = defaults[p] for p of defaults
    opt[p] = options[p] for p of options if options?

    xmlDoc = strToDoc(xmlStr)
    xsltDoc = strToDoc(xsltStr)
    return false unless xmlDoc? and xsltDoc?

    if XSLTProcessor? and document?.implementation?.createDocument?
      processor = new XSLTProcessor()
      processor.importStylesheet(xsltDoc)
      trans = if opt.fullDocument
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

    outStr = docToStr(trans)
    if opt.cleanup
      outStr = cleanupXmlNodes(outStr, opt)
      outStr = stripRedundantNamespaces(outStr) if opt.removeDupNamespace
    return outStr

