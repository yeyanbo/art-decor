<!-- 
    DISCLAIMER
    Deze stylesheet en de resulterende html weergave van xml berichten zijn uitsluitend bedoeld voor testdoeleinden.
    Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.
    
    Auteur: Gerrit Boers
    Copyright: Nictiz
    
    
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:hl7="urn:hl7-org:v3" xmlns:UML="omg.org/UML1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0"><xsl:output method="html" exclude-result-prefixes="#all" encoding="UTF-8"/><xsl:variable name="headingList"><item>Revision History</item><item>Concept</item><item>Purpose</item><item>Evidence Base</item><item>Instruction</item><item>Interpretation</item><item>Care Process</item><item>Example of the Instrument</item><item>Constraints</item><item>References</item><item>Traceability to other standards</item><item>Disclaimer</item><item>Terms of Use</item><item>Copyright</item></xsl:variable><xsl:template match="/XMI/XMI.content"><xsl:apply-templates select="//UML:Class[UML:ModelElement.stereotype/UML:Stereotype/@name='rootconcept']"/></xsl:template><xsl:template match="XMI.header">
      <!-- ignore header info --></xsl:template><xsl:template match="UML:Class"><xsl:variable name="xmiId" select="@xmi.id"/><xsl:variable name="name" select="@name"/><xsl:variable name="item" select="//UML:Generalization[@subtype=$xmiId]"/><xsl:variable name="taggedValues" select="UML:ModelElement.taggedValue/UML:TaggedValue"/><concept multiplicity="{//UML:AssociationEnd[@type=$xmiId]/@multiplicity}" id="{$xmiId}" effectiveDate="{$taggedValues[@tag='date_created']/@value}" type="{if ($item) then 'item' else('group')}" statusCode="draft"><xsl:if test="//UML:TaggedValue[@tag='DCM::DefinitionCode'][@modelElement=$xmiId]"><xsl:for-each select="//UML:TaggedValue[@tag='DCM::DefinitionCode'][@modelElement=$xmiId]"><xsl:variable name="rawCode" select="normalize-space(@value)"/><xsl:choose><xsl:when test="starts-with($rawCode,'SNOMEDCT:')"><xsl:variable name="code" select="tokenize($rawCode,'\s')[2]"/><xsl:variable name="displayName" select="normalize-space(substring-after($rawCode,$code))"/><association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/></xsl:when><xsl:when test="starts-with($rawCode,'PSI:')"><xsl:variable name="code" select="tokenize($rawCode,'\s')[2]"/><association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName="{$name}"/></xsl:when></xsl:choose></xsl:for-each></xsl:if><name language="nl-NL"><xsl:value-of select="@name"/></name><desc language="nl-NL"><xsl:value-of select="$taggedValues[@tag='documentation']/@value"/></desc><xsl:if test="UML:ModelElement.stereotype/UML:Stereotype/@name='rootconcept'"><xsl:variable name="rootPackage" select="//UML:Package[not(ancestor::UML:package)]"/><rationale language="nl-NL"><xsl:apply-templates select="$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Purpose']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value"/></rationale><operationalization language="nl-NL"><xsl:apply-templates select="$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Instruction']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value"/><xsl:apply-templates select="$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Interpretation']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value"/><xsl:apply-templates select="$rootPackage/UML:Namespace.ownedElement/UML:Package[@name='Care Process']/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='documentation']/@value"/></operationalization><root/></xsl:if><xsl:for-each select="//UML:Association/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_targetName'][@value=$name]"><xsl:variable name="source" select="../UML:TaggedValue[@tag='ea_sourceName']/@value"/><xsl:apply-templates select="//UML:Class[@name=$source]"/></xsl:for-each><xsl:apply-templates select="$item"/></concept></xsl:template><xsl:template match="UML:Generalization"><xsl:variable name="valueType" select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_targetName']/@value"/><xsl:choose><xsl:when test="$valueType='BL'"><valueDomain type="boolean"/></xsl:when><xsl:when test="$valueType='CD'"><valueDomain type="code"><xsl:apply-templates select="UML:Classifier.feature"/></valueDomain></xsl:when><xsl:when test="$valueType='CO'"><valueDomain type="ordinal"/></xsl:when><xsl:when test="$valueType='ED'"><valueDomain type="text"/></xsl:when><xsl:when test="$valueType='II'"><valueDomain type="identifier"/></xsl:when><xsl:when test="$valueType='INT'"><valueDomain type="count"/></xsl:when><xsl:when test="$valueType='PQ'"><valueDomain type="quantity"/></xsl:when><xsl:when test="$valueType='ST'"><valueDomain type="string"/></xsl:when><xsl:when test="$valueType='TS'"><valueDomain type="datetime"/></xsl:when></xsl:choose></xsl:template><xsl:template match="UML:Classifier.feature"><conceptList id=""><xsl:for-each select="UML:Classifier.feature/UML:Attribute"><concept id=""><name language="nl-NL"><xsl:value-of select="@name"/></name><xsl:if test="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='DCM::DefinitionCode']"><xsl:variable name="rawCode" select="normalize-space(UML:ModelElement.taggedValue/UML:TaggedValue[@tag='DCM::DefinitionCode']/@value)"/><xsl:choose><xsl:when test="starts-with($rawCode,'SNOMEDCT:')"><xsl:variable name="code" select="tokenize($rawCode,'\s')[2]"/><xsl:variable name="displayName" select="tokenize($rawCode,'\s')[(3-last())]"/><association codeSystem="2.16.840.1.113883.6.96" codeSystemName="Snomed-CT" code="{$code}" displayName="{$displayName}"/></xsl:when><xsl:when test="starts-with($rawCode,'PSI:')"><xsl:variable name="code" select="tokenize($rawCode,'\s')[2]"/><association codeSystem="2222.3333.4444" codeSystemName="Parelsnoer" code="{$code}" displayName=""/></xsl:when></xsl:choose></xsl:if></concept></xsl:for-each></conceptList></xsl:template><xsl:template match="@value">
      <!--      <xsl:for-each select="tokenize(.,'
')">
         <xsl:value-of select="."/>
         <br/>
      </xsl:for-each>--><xsl:value-of select="."/></xsl:template></xsl:stylesheet>