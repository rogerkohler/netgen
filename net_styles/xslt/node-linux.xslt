<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:param name="target"/>
	<xsl:param name="targetdir" />

<!--
    FIXME: make netmask arith its own template, and make a full table
-->

    <xsl:variable name="masks">
<mask bits="1" dotted="127.0.0.0"/>
<mask bits="24" dotted="255.255.255.0"/>
    </xsl:variable>

	<xsl:template match="/">
      <report>
        <xsl:variable name="doc" select="/"/>
        <xsl:for-each select="//node[@OS='Linux']">
            <xsl:copy-of select="."/>
            <targetdir><xsl:value-of select="$targetdir"/></targetdir>
            <xsl:variable name="hostpath" select="string-join(('file:',translate($targetdir,'\','/'),@name),'/')"/>
            <hostpath><xsl:value-of select="$hostpath"/></hostpath>
            <xsl:variable name="interfaces" select="string-join(($hostpath,'etc','default','interfaces'),'/')"/>
            <interfaces><xsl:value-of select="$interfaces"/></interfaces>
            <xsl:result-document href="{$interfaces}" method="text">#interfaces file generated by Archi
                <xsl:call-template name="loopback"/>
                <xsl:apply-templates select="iface"/>
                <xsl:text>
                </xsl:text> 
            </xsl:result-document>
        </xsl:for-each>
      </report>
	</xsl:template>

    <xsl:template name="loopback">
auto lo
iface lo inet loopback
</xsl:template>

    <xsl:template match="iface">
    <xsl:variable name="network" select="(//network[@id=current()/@targetid]|//node[@id=current()/@targetid]/network)[1]"/>
<xsl:text>
</xsl:text>
auto <xsl:value-of select="@nodeif"/>
iface <xsl:value-of select="@nodeif"/> inet static
      address <xsl:value-of select="@IP"/>
#<xsl:value-of select="$network/@name"/>
      netmask <xsl:value-of select="$masks/mask[@bits=$network/@maskbits]/@dotted"/>
<xsl:if test="string-length($network/@gw) > 0">
      gateway <xsl:value-of select="$network/@gw"/>
</xsl:if>

</xsl:template>

</xsl:stylesheet>


