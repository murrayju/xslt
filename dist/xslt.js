/*! xslt v0.4.0+0.master.ba4530b72c4a | (c) 2015 Justin Murray | built on 2015-07-21 */

(function() {
  var slice = [].slice;

  (function(root, factory) {
    if (typeof define === 'function' && (define.amd != null)) {
      return define([], factory);
    } else if (typeof (typeof module !== "undefined" && module !== null ? module.exports : void 0) === 'object') {
      return module.exports = factory();
    } else {
      return root != null ? root.xslt = factory() : void 0;
    }
  })(this, function() {
    var activeXSupported, arrayContains, cleanupXmlNodes, collapseEmptyElements, createDomDoc, createXSLTemplate, defaults, docToStr, getAttrVal, getHeader, getHeaderEncoding, getHeaderStandalone, hasXmlHeader, isXml, manualCreateElement, needsHeader, newDocument, prependHeader, strToDoc, stripAllNamespaces, stripDuplicateAttributes, stripHeader, stripNamespacedNamespace, stripNullNamespaces, stripRedundantNamespaces, tryCreateActiveX, xmlHeader;
    isXml = function(str) {
      return /^\s*</.test(str);
    };
    hasXmlHeader = function(str) {
      return /^\s*<\?/.test(str);
    };
    needsHeader = function(str) {
      return isXml(str) && !hasXmlHeader(str);
    };
    xmlHeader = function(encoding, standalone) {
      var str;
      str = '<?xml version="1.0" ';
      if (encoding != null) {
        str += "encoding=\"" + encoding + "\" ";
      }
      if (standalone != null) {
        str += "standalone=\"" + standalone + "\" ";
      }
      str += '?>';
      return str;
    };
    prependHeader = function(str, encoding, standalone) {
      return xmlHeader(encoding, standalone) + str;
    };
    stripHeader = function(str) {
      return str != null ? str.replace(/\s*<\?xml[^<]+/, '') : void 0;
    };
    getHeader = function(str) {
      var match, ref;
      match = str != null ? str.match(/^\s*<\?xml\b[^<]+/i) : void 0;
      return ((match != null ? match.length : void 0) && ((ref = match[0]) != null ? typeof ref.trim === "function" ? ref.trim() : void 0 : void 0)) || null;
    };
    getAttrVal = function(node, attrName) {
      var match;
      match = (new RegExp('\\b' + attrName + '\\s*=\\s*"([^"]*)"', 'g')).exec(node);
      return ((match != null ? match.length : void 0) > 1 && match[1]) || null;
    };
    getHeaderEncoding = function(str) {
      return getAttrVal(getHeader(str), 'encoding');
    };
    getHeaderStandalone = function(str) {
      return getAttrVal(getHeader(str), 'standalone');
    };
    activeXSupported = (typeof ActiveXObject !== "undefined" && ActiveXObject !== null) || 'ActiveXObject' in window;
    tryCreateActiveX = function() {
      var i, id, len, objIds;
      objIds = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (!activeXSupported) {
        return null;
      }
      for (i = 0, len = objIds.length; i < len; i++) {
        id = objIds[i];
        try {
          return new ActiveXObject(id);
        } catch (_error) {}
      }
      return null;
    };
    createDomDoc = function() {
      var d;
      d = tryCreateActiveX.apply(null, ["Msxml2.FreeThreadedDOMDocument.6.0", "Msxml2.FreeThreadedDOMDocument.3.0", "Msxml2.FreeThreadedDOMDocument", "Microsoft.XMLDOM", "Msxml2.DOMDocument.6.0", "Msxml2.DOMDocument.5.0", "Msxml2.DOMDocument.4.0", "Msxml2.DOMDocument.3.0", "MSXML2.DOMDocument", "MSXML.DOMDocument"]);
      if (d != null) {
        d.async = false;
        while (d.readyState !== 4) {
          null;
        }
      }
      return d;
    };
    createXSLTemplate = function() {
      return tryCreateActiveX.apply(null, ['Msxml2.XSLTemplate.6.0', 'Msxml2.XSLTemplate']);
    };
    manualCreateElement = function() {
      var res, xml;
      xml = document.createElement('xml');
      xml.src = xmlHeader();
      document.body.appendChild(xml);
      res = xml.XMLDocument;
      document.body.removeChild(xml);
      return res;
    };
    newDocument = function() {
      var d, ref;
      d = null;
      if (d == null) {
        d = createDomDoc();
      }
      if (typeof DOMParser !== "undefined" && DOMParser !== null) {
        return d;
      }
      if (d == null) {
        d = manualCreateElement();
      }
      if (d == null) {
        d = (ref = document.implementation) != null ? typeof ref.createDocument === "function" ? ref.createDocument("", 'test', null) : void 0 : void 0;
      }
      return d;
    };
    strToDoc = function(str) {
      var d, ref, ref1, ref2, ref3;
      if ((typeof str !== 'string') || !isXml(str)) {
        return null;
      }
      if (needsHeader(str)) {
        str = prependHeader(str);
      }
      d = newDocument();
      if ((d != null) && 'loadXML' in d) {
        d.loadXML(str);
        if ((d.documentElement == null) || ((ref = d.parseError) != null ? ref.errorCode : void 0) !== 0) {
          throw new Error("loadXML error: " + d.parseError);
        }
      } else if ((d != null) && 'load' in d) {
        d.load(str);
      } else if (typeof DOMParser !== "undefined" && DOMParser !== null) {
        d = (ref1 = new DOMParser()) != null ? typeof ref1.parseFromString === "function" ? ref1.parseFromString(str, 'text/xml') : void 0 : void 0;
        if ((d != null ? typeof d.getElementsByTagName === "function" ? (ref2 = d.getElementsByTagName('parsererror')) != null ? ref2.length : void 0 : void 0 : void 0) > 0 || (d != null ? (ref3 = d.documentElement) != null ? ref3.nodeName : void 0 : void 0) === 'parsererror') {
          throw new Error("Failed to load document from string:\r\n" + d.documentElement.textContent);
        }
      }
      return d;
    };
    docToStr = function(doc) {
      var ref, xml;
      if (doc == null) {
        return null;
      }
      xml = (typeof doc) === 'string' ? doc : (doc != null ? doc.xml : void 0) != null ? doc.xml : typeof XMLSerializer !== "undefined" && XMLSerializer !== null ? (ref = new XMLSerializer()) != null ? typeof ref.serializeToString === "function" ? ref.serializeToString(doc) : void 0 : void 0 : null;
      if ((xml != null ? typeof xml.indexOf === "function" ? xml.indexOf("<transformiix::result") : void 0 : void 0) >= 0) {
        xml = xml.substring(xml.indexOf(">") + 1, xml.lastIndexOf("<"));
      }
      return xml;
    };
    arrayContains = function(arr, val) {
      var i, len, v;
      for (i = 0, len = arr.length; i < len; i++) {
        v = arr[i];
        if (v === val) {
          return true;
        }
      }
      return false;
    };
    stripRedundantNamespaces = function(xml) {
      var matches, rootNamespaces, rootNode;
      matches = xml != null ? xml.match(/^<([a-zA-Z0-9:\-]+)\s(?:\/(?!>)|[^>\/])*(\/?)>/) : void 0;
      if (matches != null ? matches.length : void 0) {
        rootNode = matches[0];
        rootNamespaces = rootNode.match(/xmlns(:[a-zA-Z0-9:\-]+)?="[^"]*"/g);
        return rootNode + xml.substr(rootNode.length).replace(/xmlns(:[a-zA-Z0-9:\-]+)?="[^"]*"/g, function(ns) {
          if (arrayContains(rootNamespaces, ns)) {
            return '';
          }
          return ns;
        });
      }
      return xml;
    };
    stripDuplicateAttributes = function(node, nodeName, closeTag) {
      var attrRegex, collection, key, newStr, parts, val;
      attrRegex = /([a-zA-Z0-9:\-]+)\s*=\s*("[^"]*")/g;
      collection = {};
      parts = attrRegex.exec(node);
      while (parts) {
        collection[parts[1]] = parts[0];
        parts = attrRegex.exec(node);
      }
      newStr = '<' + nodeName;
      for (key in collection) {
        val = collection[key];
        newStr += ' ' + val;
      }
      newStr += (closeTag || '') + '>';
      return newStr;
    };
    stripNullNamespaces = function(node) {
      return node.replace(/xmlns\s*=\s*""/gi, '');
    };
    stripAllNamespaces = function(node) {
      return node.replace(/xmlns\s*=\s*"[^"]*"/gi, '');
    };
    stripNamespacedNamespace = function(node) {
      var i, len, num, nums;
      nums = [];
      node = node.replace(/xmlns:NS([0-9]+)=""/gi, function(match, num) {
        nums.push(num);
        return '';
      });
      for (i = 0, len = nums.length; i < len; i++) {
        num = nums[i];
        node = node.replace(new RegExp("NS" + num + ":xmlns:", "g"), "xmlns:");
      }
      return node;
    };
    cleanupXmlNodes = function(xml, opt) {
      return xml != null ? xml.replace(/<([a-z_][a-z_0-9:\.\-]*\b)\s*(?:\/(?!>)|[^>\/])*(\/?)>/gi, function(node, nodeName, closeTag) {
        if (opt.removeNamespacedNamespace) {
          node = stripNamespacedNamespace(node);
        }
        if (opt.removeNullNamespace) {
          node = stripNullNamespaces(node);
        }
        if (opt.removeAllNamespaces) {
          node = stripAllNamespaces(node);
        }
        if (opt.removeDupAttrs) {
          node = stripDuplicateAttributes(node, nodeName, closeTag);
        }
        return node;
      }) : void 0;
    };
    collapseEmptyElements = function(xml) {
      return xml != null ? xml.replace(/(<([a-z_][a-z_0-9:\.\-]*\b)\s*(?:\/(?!>)|[^>\/])*)><\/\2>/gi, function(all, element) {
        return element + "/>";
      }) : void 0;
    };
    defaults = {
      fullDocument: false,
      cleanup: true,
      xmlHeaderInOutput: true,
      normalizeHeader: true,
      encoding: 'UTF-8',
      preserveEncoding: false,
      collapseEmptyElements: true,
      removeDupNamespace: true,
      removeDupAttrs: true,
      removeNullNamespace: true,
      removeAllNamespaces: false,
      removeNamespacedNamespace: true
    };
    return function(xmlStr, xsltStr, options) {
      var encoding, opt, outStr, p, processor, ref, standalone, trans, xmlDoc, xslProc, xslt, xsltDoc;
      opt = {};
      for (p in defaults) {
        opt[p] = defaults[p];
      }
      if (options != null) {
        for (p in options) {
          opt[p] = options[p];
        }
      }
      xmlDoc = strToDoc(xmlStr);
      xsltDoc = strToDoc(xsltStr);
      if (!((xmlDoc != null) && (xsltDoc != null))) {
        return false;
      }
      if ((typeof XSLTProcessor !== "undefined" && XSLTProcessor !== null) && ((typeof document !== "undefined" && document !== null ? (ref = document.implementation) != null ? ref.createDocument : void 0 : void 0) != null)) {
        processor = new XSLTProcessor();
        processor.importStylesheet(xsltDoc);
        trans = opt.fullDocument ? processor.transformToDocument(xmlDoc) : processor.transformToFragment(xmlDoc, document);
      } else if ('transformNode' in xmlDoc) {
        trans = xmlDoc.transformNode(xsltDoc);
      } else if (activeXSupported) {
        xslt = createXSLTemplate();
        xslt.stylesheet = xsltDoc;
        xslProc = xslt.createProcessor();
        xslProc.input = xmlDoc;
        xslProc.transform();
        trans = xslProc.output;
      }
      outStr = docToStr(trans);
      if (opt.cleanup) {
        encoding = opt.preserveEncoding ? getHeaderEncoding(outStr) || getHeaderEncoding(xmlStr) : opt.encoding;
        standalone = getHeaderStandalone(outStr);
        if (opt.normalizeHeader || !opt.xmlHeaderInOutput) {
          outStr = stripHeader(outStr);
        }
        if (opt.xmlHeaderInOutput && needsHeader(outStr)) {
          outStr = prependHeader(outStr, encoding, standalone);
        }
        outStr = cleanupXmlNodes(outStr, opt);
        if (opt.removeDupNamespace) {
          outStr = stripRedundantNamespaces(outStr);
        }
        if (opt.collapseEmptyElements) {
          outStr = collapseEmptyElements(outStr);
        }
      }
      return outStr;
    };
  });

}).call(this);

//# sourceMappingURL=xslt.js.map
