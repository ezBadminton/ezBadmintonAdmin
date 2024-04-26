<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="exeName" select="'ezBadminton.exe'"/>

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>


  <!-- Rename the client executable to ezBadminton.exe and make that name the Id of the File element to be able to create a shortcut for it -->
  <xsl:template match="node()[local-name()='File'][@*[local-name()='Source'] = 'SourceDir\ez_badminton_admin_app.exe']/@*[local-name()='Id']">
    <xsl:attribute name="{name()}" namespace="{namespace-uri()}">
      <xsl:value-of select="$exeName"/>
    </xsl:attribute>
    <xsl:attribute name="Name" namespace="{namespace-uri()}">
      <xsl:value-of select="$exeName"/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>