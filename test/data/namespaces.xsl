<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="urn:test:ns1" xmlns:ns2="urn:test:ns2">
	<xsl:output method="xml" indent="no" encoding="UTF-8"/>

	<!-- copy all nodes -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*[starts-with(local-name(), 'test-')]">
		<xsl:attribute name="ns2:{substring-after(local-name(), '-')}" namespace="urn:test:ns2">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
</xsl:stylesheet>
