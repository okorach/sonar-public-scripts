<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/">
    <coverage version="1">
      <xsl:for-each select="coverage/packages/package/classes/class">
        <file>
          <xsl:attribute name="path">
            <xsl:value-of select="@filename"/>
          </xsl:attribute>
          <xsl:for-each select="lines/line">
            <lineToCover>
              <xsl:attribute name="lineNumber">
                <xsl:value-of select="@number"/>
              </xsl:attribute>
              <xsl:attribute name="covered">
              <xsl:choose>
                <xsl:when test="@hits &gt; 0">true</xsl:when>
					      <xsl:otherwise>false</xsl:otherwise>
              </xsl:choose>
              <!-- No support for branch since Cobertura does not seem to provide branch info -->
              </xsl:attribute>
            </lineToCover>
          </xsl:for-each>
        </file>
      </xsl:for-each>
    </coverage>
  </xsl:template>
</xsl:stylesheet>
