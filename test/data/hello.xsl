<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" encoding="UTF-8" />
    <xsl:template match="/hello-world">
        <doc someattr="Don't lose this">
            <h1><xsl:value-of select="greeting"/></h1>
            <xsl:apply-templates select="greeter"/>
        </doc>
    </xsl:template>
    <xsl:template match="greeter">
        <div>from <i><xsl:value-of select="."/></i></div>
    </xsl:template>
</xsl:stylesheet>