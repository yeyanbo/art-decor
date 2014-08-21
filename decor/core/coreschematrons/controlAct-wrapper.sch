<?xml version="1.0" encoding="UTF-8"?>
<pattern id="controlAct-wrapper-sch" xmlns="http://purl.oclc.org/dsdl/schematron">
    <!-- ControlAct Wrapper, queryByParameter -->
    <title>ControlAct Wrapper, queryByParameter</title>
    <rule context="hl7:ControlActProcess[hl7:queryByParameter]">
        <assert test="@moodCode='EVN'">ControlActProcess moodCode moet EVN zijn bij queries.</assert>
    </rule>
    <rule context="hl7:ControlActProcess/hl7:code">
        <assert test="@codeSystem='2.16.840.1.113883.1.18'">ControlActProcess code moet uit codeSystem '2.16.840.1.113883.1.18' komen</assert>
        <let name="codeValue" value="@code"/>
        <let name="interactionId" value="../../hl7:interactionId/@extension"/>
        <!-- 
            Sinds Oxygen 11.0 met Saxon EE kun je blijkbaar geen variabelen meer aanroepen binnen een let
            Bij gebruik van onderstaande $vocabFile blijkt de concat een sequence op te leveren in plaats 
            van een string (singleton). Als je echter de inhoud van de variabele in de asserts gebruikt, 
            dan gaat alles goed. Gemeld bij Oxygen support 
        -->
        <let name="vocabFile" value="concat('../vocab/',../../hl7:interactionId/@root,'.xml')"/>
        <assert test="document(concat('../vocab/',../../hl7:interactionId/@root,'.xml'))/*/hl7:code[@code=$interactionId]/hl7:reference[@extension=$codeValue]">ControlActProcess/code '<value-of select="$codeValue"/>' (Trigger Event) komt niet overeen met verwachte 
            code '<value-of select="document(concat('../vocab/',../../hl7:interactionId/@root,'.xml'))/*/hl7:code[@code=$interactionId]/hl7:reference/@extension"/>'</assert>
    </rule>
    <rule context="hl7:queryByParameter">
        <let name="interactionId" value="name(../..)"/>
        <assert test="hl7:responsePriorityCode or (             ends-with($interactionId,'PRPA_IN900111NL')   or ends-with($interactionId,'PRPA_IN900112NL'))">Element responsePriorityCode is verplicht vanaf AORTA 6.</assert>
        <assert test="hl7:responseModalityCode or (             ends-with($interactionId,'PRPA_IN900111NL')   or ends-with($interactionId,'PRPA_IN900112NL'))">Element responseModalityCode is verplicht vanaf AORTA 6.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:statusCode">
        <assert test="@code='executing'">De query status code moet 'executing' zijn.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:modifyCode">
        <assert test="@code='M' or @code='N'">De modifyCode moet 'M' (Modified) of 'N' (New) zijn.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:responseElementGroupId">
        <assert test="not(.)">responseElementGroupId mag niet gebruikt worden.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:responseModalityCode">
        <assert test="@code='R' or @code='B'">De responseModalityCode moet 'R' (Realtime) of 'B' (Batch) zijn.</assert>
        
        <!-- Queries van type indirect opvragen -->
        <let name="interactionId" value="name(../../..)"/>
        <assert test="@code='B' or ../../../hl7:sender/hl7:device/hl7:id/@extension='1' or (             ends-with($interactionId,'QUMT_IN020010')   or ends-with($interactionId,'QUMT_IN020011NL') or              ends-with($interactionId,'QUPA_IN101101')   or ends-with($interactionId,'QUPA_IN101103')   or              ends-with($interactionId,'COMT_IN999998NL') or ends-with($interactionId,'RCMR_IN010017NL') or             ends-with($interactionId,'PRPM_IN405010NL') or ends-with($interactionId,'PRPM_IN406010NL') or             ends-with($interactionId,'PRPM_IN906010NL') or ends-with($interactionId,'PRPM_IN907010NL') or             ends-with($interactionId,'PRPM_IN907020NL')  )">De responseModalityCode moet bij deze query 'B' (Batch) zijn en niet '<value-of select="@code"/>'.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:responsePriorityCode">
        <assert test="@code='I' or @code='D'">De responsePriorityCode moet 'I' (Immediate) of 'D' (Deferred) zijn.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:initialQuantity">
        <assert test="../hl7:initialQuantityCode">Als er een initialQuantity element is dan moet ook een initialQuantityCode element aanwezig zijn.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:initialQuantityCode">
        <assert test="../hl7:initialQuantity">Als er een initialQuantityCode element is dan moet ook een initialQuantity element aanwezig zijn.</assert>
        <assert test="@code='MC' and @codeSystem='2.16.840.1.113883.5.1112'">De initialQuantityCode moet 'MC' (Matching Classes) zijn met codeSystem='2.16.840.1.113883.5.1112'.</assert>
    </rule>
    <rule context="hl7:queryByParameter/hl7:sortControl">
        <assert test="not(.)">sortControl mag niet gebruikt worden.</assert>
    </rule>
    
    <!-- ControlAct Wrapper queryAck -->
    <title>ControlAct Wrapper, queryAck</title>
    <rule context="hl7:queryAck/hl7:id">
        <assert test="@root and @extension">queryId mist root en/of extension</assert>
    </rule>
    <rule context="hl7:queryAck/hl7:queryResponseCode">
        <assert test="@code='NF' or @code='AE' or @code='QE' or @code='OK'">De queryResponsecode/code moet NF (Nothing found), AE (Application Error), QE (Query error) of OK bevatten.</assert>
        <let name="acknowledgementTypeCode" value="../../../hl7:acknowledgement/@typeCode"/>
        <assert test="if ($acknowledgementTypeCode='AA') then (             @code='NF' or @code='OK' ) else (             @code='AE' or @code='QE'             )">acknowledgement/@typeCode='<value-of select="$acknowledgementTypeCode"/>'. Bij een positief antwoord moet queryResponseCode 'OK' of 'NF' zijn, anders moet deze 'AE' of 'QE' zijn.</assert>
        <let name="resultCurrentQuantity" value="../hl7:resultCurrentQuantity/@value"/>
        <assert test="not($acknowledgementTypeCode='AA') or $resultCurrentQuantity &gt; 0 or @code='NF'">De queryResponseCode moet 'NF' bevatten indien er op basis van de queryParameters geen resultaten gevonden konden 
            worden (resultCurrentQuantity/@value='<value-of select="$resultCurrentQuantity"/>') en de query valide
            is (acknowledgement/@typeCode='<value-of select="$acknowledgementTypeCode"/>').</assert>
    </rule>
    <rule context="hl7:queryAck">
        <assert test="hl7:resultTotalQuantity">resultTotalQuantity ontbreekt</assert>
        <assert test="hl7:resultCurrentQuantity">resultCurrentQuantity ontbreekt</assert>
    </rule>
    <rule context="hl7:queryAck/hl7:resultTotalQuantity">
        <assert test="@value &gt;= 0 or @nullFlavor">resultTotalQuantity moet 0 of groter zijn, of er moet een nullFlavor zijn.</assert>
        <assert test="if (@value and ../hl7:resultCurrentQuantity/@value) then (             @value &gt;= ../hl7:resultCurrentQuantity/@value) else (1=1)">resultTotalQuantity '<value-of select="@value"/>' mag niet kleiner zijn dan resultCurrentQuantity '<value-of select="../hl7:resultCurrentQuantity/@value"/>'</assert>
    </rule>
    <!-- (verplicht te vullen voor zenders van antwoordberichten met ingang van de onderhoudsrelease AORTA 2008; 
        verplicht te gebruiken voor zowel zenders als ontvangers met ingang van de onderhoudsrelease AORTA 2009) 
        Dit attribuut mag geen nullFlavor bevatten. -->
    <rule context="hl7:queryAck/hl7:resultCurrentQuantity">
        <assert test="@value">resultCurrentQuantity moet 0 of groter zijn</assert>
        <let name="resultCurrentQuantity" value="count(../../hl7:subject)"/>
        <assert test="@value=$resultCurrentQuantity">resultCurrentQuantity '<value-of select="@value"/>' is niet gelijk aan het aantal subject elementen '<value-of select="$resultCurrentQuantity"/>'</assert>
    </rule>
    <rule context="hl7:queryAck/hl7:resultRemainingQuantity">
        <assert test="@value &gt;= 0 or @nullFlavor">resultRemainingQuantity moet 0 of groter zijn, of er moet een nullFlavor zijn.</assert>
        <assert test="if (@value and ../hl7:resultTotalQuantity/@value) then (             @value &lt;= ../hl7:resultTotalQuantity/@value) else (1=1)">resultRemainingQuantity '<value-of select="@value"/>' moet kleiner zijn dan resultTotalQuantity '<value-of select="../hl7:resultTotalQuantity/@value"/>'</assert>
        <assert test="(not(@value) or not(../hl7:resultCurrentQuantity/@value) or not(../hl7:resultTotalQuantity/@value)) or             (../hl7:resultCurrentQuantity/@value = ../hl7:resultTotalQuantity/@value and @value = 0) or             (../hl7:resultCurrentQuantity/@value &lt; ../hl7:resultTotalQuantity/@value and @value &gt; 0)">resultRemainingQuantity moet kleiner dan resultTotalQuantity zijn of exact 0 indien resultCurrentQuantity gelijk is aan resultTotalQuantity</assert>
    </rule>
    <rule context="hl7:reasonOf/hl7:justifiedDetectedIssue/hl7:code">
        <assert test="not(hl7:translation)">code mag geen translation bevatten.</assert>
    </rule>
    <rule context="hl7:reasonOf/hl7:justifiedDetectedIssue/hl7:targetOf">
        <assert test="../hl7:code/@code and ../hl7:code/@codeSystem">Als IssueManagement aanwezig is dan is de justifiedDetectedIssue/code verplicht.</assert>
    </rule>
    
    <!-- ControlAct Wrapper -->
    <title>ControlAct Wrapper</title>
    <!-- informationRecipient not in NL -->
    <rule context="hl7:ControlActProcess/hl7:informationRecipient">
        <assert test="not(.)">informationRecipient mag (nog) niet gebruikt worden.</assert>
    </rule>
    <!-- dataEnterer not in NL -->
    <rule context="hl7:ControlActProcess/hl7:dataEnterer">
        <assert test="not(.)">dataEnterer mag (nog) niet gebruikt worden.</assert>
    </rule>
    
    <!-- authorOrPerformer -->
    <rule context="hl7:ControlActProcess/hl7:authorOrPerformer">
        <assert test="@typeCode='AUT' or not(../hl7:queryByParameter)">authorOrPerformer typeCode moet AUT zijn</assert>
    </rule>
    <rule context="hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant">
        <assert test="hl7:AssignedPerson/hl7:id or hl7:AssignedDevice/hl7:id">Er moet tenminste één AssignedPerson/id of AssignedDevice/id aanwezig zijn.</assert>
    </rule>
    
    <!-- authorOrPerformer/AssignedPerson -->
    <rule context="hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson">
        <!--<report test="not(hl7:id[@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3' or @root='2.16.840.1.113883.2.4.3.11.7.3'])"
            >Tenminste één id moet als root 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN) of 2.16.840.1.113883.2.4.3.11.7.3 (batch inzage auteur) hebben.</report>
        -->
        <report test="not(hl7:code/@code and hl7:code/@codeSystem)">De rolcode van de persoon ontbreekt. Dit is alleen toegestaan als de rolcode 00.000 is. (Pas voor medewerker niet op naam)</report>
        <assert test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or not(hl7:code) or hl7:code/@codeSystem='2.16.840.1.113883.2.4.15.111'">Als de persoon een zorgverlener is en niet rolcode 00.000 heeft dan moet de code uit RoleCodeNL - zorgverlenertype (natuurlijke personen) '2.16.840.1.113883.2.4.3.15.111' zijn</assert>
        <assert test="not(hl7:id[@root='2.16.840.1.113883.2.4.6.3']) or hl7:code/@codeSystem='2.16.840.1.113883.2.4.3.11.8' or hl7:code/@codeSystem='2.16.840.1.113883.2.4.3.11.6'">Als de persoon een BSN heeft dan moet de code uit RoleCodeWettelijkeVertegenwoordigerNL '2.16.840.1.113883.2.4.3.11.6' of VertegenwoordigingstypenWetEPD '2.16.840.1.113883.2.4.3.11.8' zijn</assert>
        
        <!-- 
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or
            hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension] or
            hl7:Organization/hl7:id[@root='2.16.840.1.113883.2.4.3.11' and @extension]"
            >Tenminste één Organization/id moet als root 2.16.528.1.1007.3.3 (URA) of 2.16.840.1.113883.2.4.3.11 (Klantenloket) hebben en de extensie moet aanwezig (en gevuld) zijn.</assert>
        -->
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or string-length(hl7:Organization/hl7:name)&gt;0">Organization/name mag niet leeg zijn.</assert>
    </rule>
    
    <!-- authorOrPerformer/AssignedDevice -->
    <rule context="hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice-not-used">
        <assert test="hl7:id[@root='2.16.528.1.1007.3.2' or @root='2.16.840.1.113883.2.4.6.6' or @root='2.16.528.1.1007.4']">Tenminste één id moet als root 2.16.528.1.1007.3.2 (UZI), 2.16.840.1.113883.2.4.6.6 (ZIM) of 2.16.528.1.1007.4 (SBV-Z) hebben.</assert>
        <assert test="hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension] or              hl7:id[@extension='1' and @root='2.16.840.1.113883.2.4.6.6'] or hl7:id[@root='2.16.528.1.1007.4']">Tenminste één Organization/id moet als root 2.16.528.1.1007.3.3 (URA), de ZIM zijn, of de SBV-Z hebben en de extensie moet aanwezig (en gevuld) zijn.</assert>
        <assert test="string-length(hl7:Organization/hl7:name)&gt;0 or hl7:id[@extension='1' and @root='2.16.840.1.113883.2.4.6.6'] or hl7:id[@root='2.16.528.1.1007.4']">Organization/name mag niet leeg zijn.</assert>
    </rule>
    
    <!-- 
        Controle op verplichte overseer
        Optioneel in antwoordberichten op een vraag (deze hebben een acknowledgement element en acceptAckCode='NE')
              NB: in principe kunnen vragen ook asynchroon worden gesteld, maar op de AORTA doen we dat nog niet
              NB: antwoordberichten op verzoekberichten hebben ook een acknowledgement element, echter deze worden
                  meestal asynchroon verzonden waardoor deze meestal acceptAckCode='AL' hebben.
                  De huidige controle laat dus nog wel wat door, maar het alternatief is deze controle verplaatsen 
                  naar de respectievelijke schematron bestanden per interactie
        Optioneel in berichten aan de SBV-Z
        Optioneel in verificatieberichten HL7 Ping, HL7 Pong en HL7 Tick
        Optioneel in berichten met vertrouwensniveau laag zoals vragen aan de ZAB en Applicatieregister
    -->
    <rule context="hl7:ControlActProcess">
        <assert test="(../hl7:acknowledgement and ../hl7:acceptAckCode/@code='NE') or              ends-with(name(..),'QUPA_IN101101') or             ends-with(name(..),'QUPA_IN101103') or             ends-with(name(..),'PRPA_IN900111NL') or             ends-with(name(..),'COMT_IN800400') or             ends-with(name(..),'COMT_IN113113NL') or             ends-with(name(..),'COMT_IN118118') or             ends-with(name(..),'COMT_IN229229') or             ends-with(name(..),'PRPM_IN405010NL') or             ends-with(name(..),'PRPM_IN406010NL') or             ends-with(name(..),'PRPM_IN906010NL') or             ends-with(name(..),'PRPM_IN907010NL') or             ends-with(name(..),'PRPM_IN907020NL') or             ends-with(name(..),'REPC_IN004211UV01') or             ends-with(name(..),'REPC_IN004110UV01') or             ends-with(name(..),'REPC_IN004410UV01') or             ends-with(name(..),'PRPA_IN101001') or             ends-with(name(..),'RCMR_IN010006NL') or             ends-with(name(..),'RCMR_IN010016NL') or             hl7:overseer">Overseer ontbreekt</assert>
    </rule>
    
    <!-- overseer -->
    <rule context="hl7:ControlActProcess/hl7:overseer">
        <assert test="@typeCode='RESP'">overseer typeCode moet RESP zijn</assert>
    </rule>
    
    <!-- overseer/AssignedPerson en overseer/AssignedEntity -->
    <rule context="hl7:ControlActProcess/hl7:overseer/hl7:participant/hl7:AssignedPerson | hl7:ControlActProcess/hl7:overseer/hl7:assignedEntity">
        <!-- 
        <assert test="hl7:id[@root='2.16.528.1.1007.3.1' or @root='2.16.840.1.113883.2.4.6.3' or @root='2.16.840.1.113883.2.4.3.11.7.3']"
            >Tenminste één id moet als root 2.16.528.1.1007.3.1 (UZI), 2.16.840.1.113883.2.4.6.3 (BSN) of 2.16.840.1.113883.2.4.3.11.7.3 (batch inzage auteur) hebben.</assert>
        -->
        <report test="not(hl7:code/@code and hl7:code/@codeSystem)">De rolcode van de persoon ontbreekt. Dit is alleen toegestaan als de rolcode 00.000 is. (Pas voor medewerker niet op naam)</report>
        <assert test="not(hl7:id[@root='2.16.528.1.1007.3.1']) or not(hl7:code) or hl7:code/@codeSystem='2.16.840.1.113883.2.4.15.111'">Als de persoon een zorgverlener is en niet rolcode 00.000 heeft dan moet de code uit RoleCodeNL - zorgverlenertype (natuurlijke personen) '2.16.840.1.113883.2.4.3.15.111' zijn</assert>
        <!--
        <assert test="not(hl7:id[@root='2.16.840.1.113883.2.4.6.3']) or hl7:code/@codeSystem='2.16.840.1.113883.2.4.3.11.8' or hl7:code/@codeSystem='2.16.840.1.113883.2.4.3.11.6'"
            >Als de persoon een BSN heeft dan moet de code uit RoleCodeWettelijkeVertegenwoordigerNL '2.16.840.1.113883.2.4.3.11.6' of VertegenwoordigingstypenWetEPD '2.16.840.1.113883.2.4.3.11.8' zijn</assert>
        -->
        <assert test="string-length(hl7:assignedPrincipalChoiceList/hl7:assignedPerson/hl7:name/hl7:family)&gt;0">assignedPerson/name mag niet leeg zijn.</assert>
        
        <!-- 
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or hl7:Organization/hl7:id[@root='2.16.528.1.1007.3.3' and @extension]"
            >Tenminste één Organization/id moet als root 2.16.528.1.1007.3.3 (URA) hebben en de extensie moet aanwezig (en gevuld) zijn.</assert>
        -->
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or string-length(hl7:Organization/hl7:name)&gt;0">Organization/name mag niet leeg zijn.</assert>
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or string-length(hl7:Organization/hl7:addr/hl7:city)&gt;0">Organization/addr/city mag niet leeg zijn.</assert>
        <!--
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or hl7:Organization/hl7:code[@codeSystem and @code]"
            >Organization/code moet een code en codeSystem OID hebben.</assert>
        -->
        
        <!-- NB deze controle gaat fout als de overseerorganisatie meer dan 1 id heeft -->
        <let name="overseerRoot" value="hl7:Organization/hl7:id/@root"/>
        <let name="overseerExt" value="hl7:Organization/hl7:id/@extension"/>
        <!-- 
        <assert test="hl7:id[@root='2.16.840.1.113883.2.4.6.3'] or
            ../../hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:Organization/hl7:id[@root=$overseerRoot and @extension=$overseerExt] or
            ../../hl7:authorOrPerformer/hl7:participant/hl7:AssignedDevice/hl7:Organization/hl7:id[@root=$overseerRoot and @extension=$overseerExt]"
            >Organisatie van de overseer is niet gelijk aan die van de authorOrPerformer.</assert>
        -->
    </rule>
    
    <!-- Dit wordt nu allemaal in datatypes.sch gedaan -->
    <!--rule context="hl7:code[@codeSystem='2.16.840.1.113883.2.4.15.111']">
        <!- CIBG rolcode vocabulair ->
        <let name="codeValue" value="@code"/>
        <let name="codeSystem" value="@codeSystem"/>
        <assert test="document(concat('../vocab/',$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]"
            >Code '<value-of select="$codeValue"/>' is geen geldige RoleCodeNL.</assert>
        <!- test op CIBG code 00.000 ->
        <report test="@code='00.000'"
            >Gebruik van CIBG rolcode 00.000 is niet toegestaan.</report>
    </rule-->
</pattern>