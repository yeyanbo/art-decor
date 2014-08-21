<?xml version="1.0" encoding="UTF-8"?>
<pattern id="transmission-wrapper-sch" xmlns="http://purl.oclc.org/dsdl/schematron">
    <title>Transmission Wrapper Algemeen</title>
    <!-- 
        Message id equals every id that is adjacent to hl7:creationTime. 
        This way it works for batches and every message contained, even SOAP wrapped.
    -->
    <rule context="hl7:id-not-used[../hl7:creationTime]">
        <assert test="@root and @extension">Id element mist root of extension</assert>
        <report test="not(substring(@root,1,26)='2.16.840.1.113883.2.4.6.6.' or substring(@root,1,20)='2.16.528.1.1007.3.3.' or substring(@root,1,29)='2.16.840.1.113883.2.4.3.11.7.')">root OID van id is niet gebaseerd op URA, Landelijke applicatie id of Klantenloket id</report>
    </rule>
    <!-- creationTime -->
    <rule context="hl7:creationTime">
        <assert role="error" test="not(@xsi:type) or @xsi:type='TS' or ends-with(@xsi:type,':TS')"
            >creationTime heeft ongeldig datatype '<value-of select="@xsi:type"/>'. Dit moet 'TS' zijn.</assert>
        <assert role="error" test="string-length(@value)&gt;13"
            >creationTime moet minimaal op de seconde nauwkeurig zijn.</assert>
    </rule>
    <!-- versionCode -->
    <rule context="hl7:versionCode">
        <assert test="@code='NICTIZEd2005-Okt'">versionCode '<value-of select="@code"/>' is niet gelijk aan 'NICTIZEd2005-Okt'</assert>
    </rule>
    <!-- interactionId -->
    <rule context="hl7:interactionId">
        <assert test="@root='2.16.840.1.113883.1.6'">Root van de interactionId is onjuist</assert>
        <!-- ends-with zou beter zijn, maar blijkbaar wordt geen xslt 2.0 ondersteund -->
        <assert test="contains(name(..),@extension)             ">Extension van de interactionId komt niet overeen met het root element van het bericht.</assert>
        <assert test="not(contains(@extension,':'))">Extension van de interactionId mag geen namespace prefix bevatten.</assert>
    </rule>
    <!-- profileId - voor peri even buiten kracht -->
    <rule context="hl7:profileId-notused">
        <assert test="@root='2.16.840.1.113883.2.4.3.11.1' and (@extension='705' or @extension='805' or @extension='810')">ProfileId '<value-of select="@extension"/>' is niet gelijk aan 705, 805 of 810. </assert>
    </rule>
    
    <!-- acknowledgement algemeen, adjacent to hl7:creationTime -->
    <rule context="hl7:acknowledgement[not(ends-with(name(..),'MCCI_IN000002')) and ../hl7:creationTime]">
        <assert test="@typeCode='AA' or @typeCode='AE' or @typeCode='AR'">Er is een acknowledgement, maar de acknowledgement/@typeCode is niet AA, AE of AR.</assert>
    </rule>
    <!-- acknowledgement MCCI_IN000002 -->
    <rule context="hl7:acknowledgement[ends-with(name(..),'MCCI_IN000002') and ../hl7:creationTime]">
        <assert test="@typeCode='CA' or @typeCode='CE' or @typeCode='CR'">Het root element is MCCI_IN000002, maar de acknowledgement/@typeCode is niet CA, CE of CR.</assert>
    </rule>
    <!-- acknowledgementDetail/@typeCode -->
    <rule context="hl7:acknowledgement[../hl7:creationTime]/hl7:acknowledgementDetail">
        <assert test="@typeCode='E' or @typeCode='W' or @typeCode='I'">Er is een acknowledgementDetail, maar de typeCode is niet E (Error), W (Warning) of I (Information).</assert>
    </rule>
    
    <!-- receiver or sender device id -->
    <rule context="hl7:receiver/hl7:device/hl7:id | hl7:sender/hl7:device/hl7:id">
        <!-- 
        <assert test="@root and @extension"
            >Id element mist root of extension</assert>
        
            <report test="@root!='2.16.840.1.113883.2.4.6.6'">Root OID van device/id moet 2.16.840.1.113883.2.4.6.6 zijn</report>
        -->
    </rule>

    <!-- receiver or sender device -->
    <rule context="hl7:receiver/hl7:device/hl7:desc | hl7:sender/hl7:device/hl7:desc">
        <assert test="not(.)">Element device/descr mag niet gebruikt worden.</assert>
    </rule>
    <rule context="hl7:receiver/hl7:device/hl7:existenceTime | hl7:sender/hl7:device/hl7:existenceTime">
        <assert test="not(.)">Element device/existenceTime mag niet gebruikt worden.</assert>
    </rule>
    <rule context="hl7:receiver/hl7:device/hl7:manufacturerModelName | hl7:sender/hl7:device/hl7:manufacturerModelName">
        <assert test="not(.)">Element device/manufacturerModelName mag niet gebruikt worden.</assert>
    </rule>
    <rule context="hl7:receiver/hl7:device/hl7:loation | hl7:sender/hl7:device/hl7:location">
        <assert test="not(.)">Element device/location mag niet gebruikt worden.</assert>
    </rule>
    <title>Transmission Wrapper, geen batch MCCI_IN200101</title>
    <rule context="hl7:processingCode">
        <assert test="@code='P' or @code='T' or @code='D'">Element processingCode is niet gelijk aan D (debugging), P (productie) of T (training)</assert>
    </rule>
    <rule context="hl7:processingModeCode">
        <assert test="@code='A' or @code='I' or @code='R' or @code='T'">Element processingModeCode is niet gelijk aan A (Archive), I (Initial load), R (Restore from archive) of T (Current processing)</assert>
    </rule>
    <rule context="hl7:acceptAckCode">
        <assert test="@code='NE' or @code='AL'">Element acceptAckCode is niet gelijk aan NE (never) of AL (always)</assert>
        
        <!-- Controle moeilijk generiek te maken, hier alleen de huidig bekende. 
            Later lijst externaliseren of controle verplaatsen naar respectievelijke sch bestanden -->
        <assert test="if (ends-with(name(..),'MFMT_IN002101') or ends-with(name(..),'MFMT_IN002102') or             ends-with(name(..),'MFMT_IN002103') or ends-with(name(..),'REPC_IN990003NL') or              ends-with(name(..),'COMT_IN113113NL') or ends-with(name(..),'PORX_IN932000NL') or              ends-with(name(..),'COMT_IN800100') or ends-with(name(..),'COMT_IN800110') or              ends-with(name(..),'COMT_IN800120') or ends-with(name(..),'COMT_IN800200') or              ends-with(name(..),'COMT_IN800400') or ends-with(name(..),'PORX_IN924000NL')             ) then (@code='AL') else (1=1)">Element acceptAckCode moet AL (always) zijn in initiërende berichten, behalve HL7 Ping 
            (COMT_IN118118), vraagberichten met responsePriorityCode='I' en orderberichten met synchroon antwoord</assert>
        
        <!-- IH Generieke berichten §3.3.1: De HL7 Ping bevat de waarde NE in het attribuut Message.acceptAckCode -->
        <assert test="if (ends-with(name(..),'COMT_IN118118')) then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor HL7 Ping berichten</assert>
        
        <!-- IH Wrappers §4.1: NE (never) in Accept Acknowledgement interacties -->
        <assert test="if (ends-with(name(..),'MCCI_IN000002')) then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor Accept Acknowledgement berichten</assert>
        
        <!-- IH Wrappers §4.1: NE (never) in antwoordberichten die horen bij een vraagbericht dat voorzien was van een I (Immediate) responsePriorityCode. Zie paragraaf 5.2.1 voor een beschrijving van QueryByParameter.responsePriorityCode -->
        <!-- Controle moeilijk generiek te maken, hier alleen WDH/EMD/VWI -->
        <assert test="if (ends-with(name(..),'QUPC_IN990002NL') or ends-with(name(..),'QURX_IN990003NL') or              ends-with(name(..),'QURX_IN990013NL') or ends-with(name(..),'QURX_IN990113NL') or              ends-with(name(..),'QUMT_IN020020') or ends-with(name(..),'QUMT_IN020021NL') or             ends-with(name(..),'MCCI_IN200101')) then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor antwoordberichten bij vraagberichten met responsePriorityCode='I'</assert>
        
        <!-- IH Wrappers §4.1: NE in vraagberichten met een I (Immediate) responsePriorityCode -->
        <assert test="if (../hl7:ControlActProcess/hl7:queryByParameter and              (not(../hl7:ControlActProcess/hl7:queryByParameter/hl7:responsePriorityCode) or              ../hl7:ControlActProcess/hl7:queryByParameter/hl7:responsePriorityCode/@code='I')) then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor vraagberichten met responsePriorityCode='I'</assert>
        
        <!-- IH Wrappers §4.1: NE (never) in berichten die een antwoord vormen op een bericht (van een type anders dan een vraagbericht) waarop een synchroon (Immediate) antwoord wordt verwacht. -->
        <!-- Controle moeilijk generiek te maken, hier alleen HL7 Pong -->
        <assert test="if (ends-with(name(..),'COMT_IN229229'))  then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor antwoordberichten bij berichten waarop een synchroon antwoord werd verwacht</assert>
        
        <!-- IH Wrappers §4.1: NE in order berichten die (zoals vastgelegd in de documentatie en de WSDL), worden beantwoord met een inhoudelijk bevestiging/afwijzings bericht (d.w.z. een bericht ongelijk aan de Accept Acknowledgement, MCCI_IN000002). -->
        <!-- Controle moeilijk generiek te maken, hier alleen beheeroverdracht -->
        <assert test="if (ends-with(name(..),'COMT_IN229229') or ends-with(name(..),'COMT_IN800300'))  then (@code='NE') else (1=1)">Element acceptAckCode moet NE (never) zijn voor antwoordberichten bij berichten waarop een synchroon antwoord werd verwacht</assert>
    </rule>
    <rule context="hl7:acknowledgement[../hl7:creationTime]">
        <assert test="(../hl7:targetMessage/hl7:id/@root and ../hl7:targetMessage/hl7:id/@extension) or              (hl7:targetTransmission/hl7:id/@root and hl7:targetTransmission/hl7:id/@extension)">Er is een acknowledgement element maar de identificatie van het bericht waarop dit een bevestiging is ontbreekt.</assert>
    </rule>
    <rule context="hl7:attentionLine[../hl7:creationTime]">
        <assert test="string-length(hl7:keyWordText/@code)&gt;0 and hl7:keyWordText/@codeSystem='2.16.840.1.113883.2.4.15.1'">Attribuut keyWordText/code moet gevuld zijn en het codeSystem moet 2.16.840.1.113883.2.4.15.1 zijn.</assert>
    </rule>
</pattern>