<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="exeName" select="'ezBadmintonServer.exe'"/>

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>


  <!-- Rename the server executable to ezBadmintonServer.exe -->
  <xsl:template match="node()[local-name()='File']/@*[local-name()='Id']">
    <xsl:attribute name="Name" namespace="{namespace-uri()}">
      <xsl:value-of select="$exeName"/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>