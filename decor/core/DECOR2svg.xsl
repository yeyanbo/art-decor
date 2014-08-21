<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    Copyright (C) 2009-2014 Alexander Henket, Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd svg" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Adapted for DECOR</xd:b> Jan 13, 2012</xd:p>
            <xd:p>
                <xd:ul>
                    <xd:li>Transaction group MUST have 0..* transactions</xd:li>
                    <xd:li>Transaction is of type 'initial', 'back', or 'stationary' <xd:ul>
                            <xd:li>Transaction MUST have 2..* actors for type 'initial'. At least 1 sending actor and 1 receiving actor.</xd:li>
                            <xd:li>Transaction MUST have 2..* actors for type 'back'. At least 1 sending actor and 1 receiving actor.</xd:li>
                            <xd:li>Transaction MUST have 1..1 actors for type 'stationary'</xd:li>
                        </xd:ul>
                    </xd:li>
                    <xd:li>Diagram will only be drawn, if there is 1..* transaction of type 'initial'.</xd:li>
                </xd:ul>
            </xd:p>
            <xd:p>Known issues (see FIXMEs): <xd:ul>
                    <xd:li>Transactions of type 'initial' with multiple sending actors will lead to drawing problems in functional SVG.</xd:li>
                    <xd:li>Transaction groups or transactions with multiple names will lead to drawing problems. Need to be smart in egtting the right language</xd:li>
                </xd:ul></xd:p>
        </xd:desc>
    </xd:doc>

    <!--xsl:template match="/">
        <xsl:variable name="theOutputDir" select="'/Users/ahenket/Documents/Nictiz/AORTA/trunk/Zorgtoepassing/JGZ/DECOR/jgz-html-develop/'"/>
        <xsl:variable name="allSvg">
            <xsl:for-each select="//scenarios/scenario//transaction[@type='group']">
                <transaction id="{@id}">
                    <xsl:apply-templates select="self::node()" mode="transactionGroupToSVG"/>
                </transaction>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each select="$allSvg/transaction">
            <xsl:if test="*">
                <xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theOutputDir}tg-{@id}_functional.svg">
                    <xsl:copy-of select="*[1]" copy-namespaces="no"/>
                </xsl:result-document>
            </xsl:if>
            <xsl:if test="*[2]">
                <xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theOutputDir}tg-{@id}_technical.svg">
                    <xsl:copy-of select="*[2]" copy-namespaces="no"/>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template-->

    <xsl:template match="transaction[@type='group']" mode="transactionGroupToSVG">
        <!--xsl:param name="theOutputDir" required="yes"/-->

        <xsl:variable name="transactionGroupName" select="name[@language=$defaultLanguage][1]/text()"/>
        <xsl:variable name="transactionGroupId" select="@id"/>
        <!-- denotes the number of actors that we need to draw boxes with lines for-->
        <xsl:variable name="countOfUniqueActors" select="count(distinct-values(transaction/actors/actor/@id))"/>
        <!-- denotes the number of initiated transactions -->
        <xsl:variable name="countOfInitialTransactions" select="count(distinct-values(transaction[@type='initial']))"/>

        <xsl:choose>
            <xsl:when test="$countOfInitialTransactions = 0">
                <!--xsl:value-of select="false()"/-->

                <xsl:message>
                    <xsl:text>+++ INFO: Not writing SVG diagram for transaction group '</xsl:text>
                    <xsl:value-of select="$transactionGroupName"/>
                    <xsl:text>' (id='</xsl:text>
                    <xsl:value-of select="$transactionGroupId"/>
                    <xsl:text>'), because there are no transactions of type='initial'</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:when test="$countOfUniqueActors = 0">
                <!--xsl:value-of select="false()"/-->

                <xsl:message>
                    <xsl:text>+++ INFO: Not writing SVG diagram for transaction group '</xsl:text>
                    <xsl:value-of select="$transactionGroupName"/>
                    <xsl:text>' (id='</xsl:text>
                    <xsl:value-of select="$transactionGroupId"/>
                    <xsl:text>'), because there are no actors</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:value-of select="true()"/-->

                <xsl:variable name="svgMargin" select="21"/>
                <xsl:variable name="svgTitleHeight" select="10"/>
                <xsl:variable name="actorBoxMarginLeftRight" select="20"/>
                <xsl:variable name="actorBoxMarginTopBottom" select="30"/>
                <xsl:variable name="actorBoxHeight" select="50"/>
                <xsl:variable name="actorBoxMinWidth" select="80"/>
                <xsl:variable name="actorBoxesMinDistance" select="30"/>
                <xsl:variable name="actorBoxXoffset" select="$svgMargin"/>
                <xsl:variable name="actorBoxYoffset" select="$svgMargin + $svgTitleHeight"/>
                <xsl:variable name="sequenceLineHeightBetweenActorBoxAndFirstBar" select="50"/>
                <xsl:variable name="sequenceLineHeightBetweenBars" select="30"/>
                <xsl:variable name="sequenceLineHeightAfterLastBar" select="10"/>
                <xsl:variable name="sequenceLineYoffset" select="$svgMargin + $svgTitleHeight + $actorBoxHeight"/>
                <xsl:variable name="sequenceBarWidth" select="10"/>
                <xsl:variable name="sequenceBarYoffset" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar"/>
                <xsl:variable name="sequenceBarMargin" select="20"/>
                <xsl:variable name="letterWidth" select="6"/>
                <xsl:variable name="pinkRectMargin" select="20"/>
                <xsl:variable name="pinkRectHeight" select="16"/>
                <xsl:variable name="pinkRectYoffset" select="$sequenceBarYoffset - $pinkRectHeight"/>
                <xsl:variable name="arrowMargin" select="30"/>
                <xsl:variable name="arrowLengthMin" select="350"/>
                <xsl:variable name="arrowYoffset" select="$sequenceBarYoffset + 20"/>
                <xsl:variable name="arrowHeadYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowTextYoffset" select="$arrowYoffset - 5"/>
                <xsl:variable name="arrowDistance" select="35"/>
                <xsl:variable name="arrowReturnYoffset" select="$arrowYoffset + $arrowDistance"/>
                <xsl:variable name="arrowReturnHeadYoffset" select="$arrowReturnYoffset + 5"/>
                <xsl:variable name="arrowReturnTextYoffset" select="$arrowReturnYoffset - 5"/>
                <xsl:variable name="transactionModelMax" select="max(transaction/@model/string-length())"/>

                <xsl:if test="1=1">
                    <!--xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theOutputDir}tg-{@id}_functional.svg"-->
                    <!-- arrow stuff first for width count -->
                    <xsl:variable name="transactionNameMax" select="max(transaction/name[@language=$defaultLanguage][1]/string-length()) + $transactionModelMax"/>
                    <xsl:variable name="arrowLength" select="if ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) > $arrowLengthMin) then ( ($arrowMargin*2) + ($transactionNameMax*$letterWidth) - 10 ) else ($arrowLengthMin - 10)"/>

                    <!-- need to know later on where a certain actor was drawn, so place in variable first for reuse -->
                    <xsl:variable name="actorsUnique">
                        <!-- Get all actors for this transaction group into a variable -->
                        <xsl:variable name="actorsUniqueTemp1">
                            <wrap>
                                <xsl:for-each select="transaction/actors/actor">
                                    <xsl:sort select="@id"/>
                                    <xsl:variable name="actorId" select="@id"/>
                                    <xsl:variable name="actorName" select="ancestor::scenarios/actors/actor[@id=$actorId]/name[@language=$defaultLanguage][1]/text()"/>
                                    <xsl:variable name="actorRole" select="if (ancestor::transaction[@type='group']/transaction[@type='initial']//actor[@id=$actorId and @role='sender']) then ('sender') else ('receiver')"/>
                                    <actor id="{$actorId}" role="{$actorRole}" name="{$actorName}"/>
                                </xsl:for-each>
                            </wrap>
                        </xsl:variable>
                        <!-- Make the list unique -->
                        <xsl:variable name="actorsUniqueTemp2">
                            <wrap>
                                <xsl:for-each select="$actorsUniqueTemp1/wrap/actor">
                                    <xsl:variable name="actorId" select="@id"/>
                                    <xsl:if test="not(preceding-sibling::actor[@id=$actorId])">
                                        <xsl:copy-of select="self::node()"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </wrap>
                        </xsl:variable>
                        <!-- Sort by descending role. Sender first, then receiver -->
                        <wrap>
                            <xsl:for-each select="$actorsUniqueTemp2/wrap/actor">
                                <xsl:sort select="@role" order="descending"/>
                                <xsl:copy-of select="self::node()"/>
                            </xsl:for-each>
                        </wrap>
                    </xsl:variable>
                    <!-- actor variables -->
                    <xsl:variable name="actorNameMax" select="max($actorsUnique/*/actor/@name/string-length())"/>
                    <xsl:variable name="actorBoxWidth" select="if ( ($actorBoxMarginLeftRight*2) + ($actorNameMax*$letterWidth) > $actorBoxMinWidth) then ( ($actorBoxMarginLeftRight*2) + ($actorNameMax*$letterWidth) ) else ($actorBoxMinWidth)"/>
                    <!-- Distance between top left corners of two actors -->
                    <xsl:variable name="actorBoxXdistance" select="$arrowLength + $sequenceBarWidth"/>


                    <xsl:variable name="actorBoxes">
                        <wrap>
                            <xsl:for-each select="$actorsUnique/wrap/actor">
                                <xsl:comment> Actor box (header) </xsl:comment>
                                <xsl:text>&#10;</xsl:text>
                                <g id="actor_{@id}" xmlns="http://www.w3.org/2000/svg">
                                    <rect x="{$actorBoxXoffset + ((position()-1) * $actorBoxXdistance)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>
                                    <text x="{$actorBoxXoffset + ($actorBoxWidth div 2) + ((position()-1) * $actorBoxXdistance)}" y="{$actorBoxYoffset + $actorBoxMarginTopBottom}" style="font-size:10px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                        <xsl:value-of select="@name"/>
                                    </text>
                                </g>
                            </xsl:for-each>
                        </wrap>
                    </xsl:variable>
                    <xsl:variable name="sequenceBars">
                        <wrap>
                            <g id="sequenceBars" xmlns="http://www.w3.org/2000/svg">
                                <!-- now loop through all transaction combinations -->
                                <xsl:for-each select="transaction">
                                    <xsl:variable name="transactionId" select="@id"/>
                                    <xsl:variable name="transactionModel" select="@model"/>
                                    <xsl:variable name="transactionName" select="name[@language=$defaultLanguage][1]/text()"/>
                                    <xsl:variable name="transactionPos" select="position()"/>
                                    <xsl:choose>
                                        <xsl:when test="@type='initial'">
                                            <xsl:for-each select="actors/actor[@role='sender']">
                                                <xsl:variable name="actorId" select="@id"/>
                                                <xsl:variable name="actorIdBack" select="ancestor::actors/actor[@role='receiver']/@id"/>
                                                <xsl:variable name="actorBoxSenderPos" select="count($actorBoxes/wrap/svg:g[@id=concat('actor_',$actorId)]/preceding-sibling::svg:g)+1"/>
                                                <xsl:variable name="actorBoxReceiverPos" select="count($actorBoxes/wrap/svg:g[@id=concat('actor_',$actorIdBack)]/preceding-sibling::svg:g)+1"/>
                                                <!-- FIXME: this goes sour once we have multiple senders for 1 transaction.... -->
                                                <xsl:variable name="senderPos" select="$transactionPos"/>
                                                <xsl:variable name="actorBoxSenderXoffset" select="$actorBoxes/wrap/svg:g[@id=concat('actor_',$actorId)]/svg:rect/@x"/>
                                                <xsl:variable name="actorBoxReceiverXoffset" select="$actorBoxes/wrap/svg:g[@id=concat('actor_',$actorIdBack)]/svg:rect/@x"/>
                                                <xsl:variable name="sequenceLineReceiverXoffset" select="$actorBoxReceiverXoffset + ($actorBoxWidth div 2)"/>
                                                <xsl:variable name="sequenceBarReceiverXoffset" select="$sequenceLineReceiverXoffset - ($sequenceBarWidth div 2)"/>
                                                <xsl:variable name="countBackTransactions" select="count(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back']
                                                        [actors/actor[@id=$actorId][@role='receiver']]
                                                        [actors/actor[@id=$actorIdBack][@role='sender']])"/>

                                                <xsl:variable name="sequenceBarHeight" select="($sequenceBarMargin*2) + ($countBackTransactions*$arrowDistance)"/>
                                                <xsl:variable name="sequenceLineX" select="$actorBoxSenderXoffset + ($actorBoxWidth div 2)"/>
                                                <xsl:variable name="sequenceBarX" select="$sequenceLineX - ($sequenceBarWidth div 2)"/>
                                                <xsl:variable name="sequenceBarY" select="$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (($senderPos - 1) * ($sequenceBarHeight + $sequenceLineHeightBetweenBars))"/>
                                                <xsl:variable name="sequenceLineY" select="$sequenceBarY + $sequenceBarHeight"/>
                                                <xsl:variable name="arrowLineX" select="if (($sequenceBarX + $sequenceBarWidth) &lt; $sequenceBarReceiverXoffset) then ($sequenceBarX + $sequenceBarWidth) else ($sequenceBarReceiverXoffset + $sequenceBarWidth)"/>
                                                <xsl:variable name="arrowLineY" select="$sequenceBarY + $sequenceBarMargin"/>
                                                <xsl:variable name="arrowLineTextX" select="$arrowLineX + ($arrowLength div 2) - 5"/>
                                                <xsl:variable name="arrowLineTextY" select="$arrowLineY - 10"/>

                                                <xsl:variable name="arrowLengthFull" select="if ($actorBoxSenderPos &lt; $actorBoxReceiverPos) then 
                                                        ($actorBoxReceiverXoffset - $actorBoxSenderXoffset - (2 * $sequenceBarWidth)) else
                                                        ($actorBoxSenderXoffset - $actorBoxReceiverXoffset - (2 * $sequenceBarWidth))"/>

                                                <xsl:comment> sequence bar client </xsl:comment>
                                                <xsl:text>&#10;</xsl:text>
                                                <rect x="{$sequenceBarX}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.37758133;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>

                                                <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                                    <xsl:comment> Arrow text client to server </xsl:comment>
                                                    <xsl:text>&#10;</xsl:text>
                                                    <text x="{$arrowLineTextX}" y="{$arrowLineTextY}" style="font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                                        <xsl:value-of select="$transactionName"/>
                                                        <xsl:if test="string-length($transactionModel)>0">
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:value-of select="$transactionModel"/>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                    </text>
                                                    <xsl:comment> Arrow line client to server </xsl:comment>
                                                    <xsl:text>&#10;</xsl:text>
                                                    <path d="{concat('m ',$arrowLineX, ',', $arrowLineY, ' h ', $arrowLengthFull)}" style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none"/>
                                                    <xsl:comment> Arrow head client to server </xsl:comment>
                                                    <xsl:text>&#10;</xsl:text>
                                                    <path d="{concat('m ', $arrowLineX + $arrowLengthFull, ',', $arrowLineY - 5, ' 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z')}" style="fill:#000000;fill-rule:evenodd;stroke:none"/>
                                                </g>

                                                <!-- Suppose there are no transaction leading back to our sender, we still want to draw a sequence bar. -->
                                                <xsl:if test="not(ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']])">
                                                    <xsl:comment> sequence bar server </xsl:comment>
                                                    <xsl:text>&#10;</xsl:text>
                                                    <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.37758133;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>
                                                </xsl:if>
                                                <xsl:for-each select="ancestor::transaction[@id=$transactionId]/following-sibling::transaction[@type='back'][actors/actor[@id=$actorId][@role='receiver']][actors/actor[@id=$actorIdBack][@role='sender']]">
                                                    <xsl:variable name="transactionIdBack" select="@id"/>
                                                    <xsl:variable name="transactionModelBack" select="@model"/>
                                                    <xsl:variable name="transactionNameBack" select="name[@language=$defaultLanguage][1]/text()"/>
                                                    <xsl:variable name="arrowLineXBack" select="$arrowLineX + 10"/>
                                                    <xsl:variable name="arrowLineYBack" select="$arrowLineY + (position() * $arrowDistance)"/>
                                                    <xsl:variable name="arrowLineTextXBack" select="$arrowLineXBack + ($arrowLength div 2) - 5"/>
                                                    <xsl:variable name="arrowLineTextYBack" select="$arrowLineYBack - 10"/>

                                                    <xsl:comment> sequence bar server </xsl:comment>
                                                    <xsl:text>&#10;</xsl:text>
                                                    <rect x="{$sequenceBarReceiverXoffset}" y="{$sequenceBarY}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.37758133;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>

                                                    <g id="{concat('respondingTransaction_',$actorId,'_',generate-id(.))}">
                                                        <xsl:comment> Arrow text server to client </xsl:comment>
                                                        <xsl:text>&#10;</xsl:text>
                                                        <text x="{$arrowLineTextXBack}" y="{$arrowLineTextYBack}" style="font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                                            <xsl:value-of select="$transactionNameBack"/>
                                                            <xsl:if test="string-length($transactionModelBack)>0">
                                                                <xsl:text> (</xsl:text>
                                                                <xsl:value-of select="$transactionModelBack"/>
                                                                <xsl:text>)</xsl:text>
                                                            </xsl:if>
                                                        </text>
                                                        <xsl:comment> Arrow line server to client </xsl:comment>
                                                        <xsl:text>&#10;</xsl:text>
                                                        <path d="{concat('m ',$arrowLineXBack, ',', $arrowLineYBack, ' h ', $arrowLengthFull)}" style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none"/>
                                                        <xsl:comment> Arrow head server to client </xsl:comment>
                                                        <xsl:text>&#10;</xsl:text>
                                                        <path
                                                            d="{concat('m ', $arrowLineXBack, ',', $arrowLineYBack + 5, ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}"
                                                            style="fill:#000000;fill-rule:evenodd;stroke:none"/>

                                                    </g>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </g>
                        </wrap>
                    </xsl:variable>

                    <xsl:variable name="sequenceLineYmax" select="max($sequenceBars/wrap/svg:g/svg:rect/@y)"/>
                    <xsl:variable name="sequenceLineHeight" select="$sequenceLineYmax + ($sequenceBars/wrap/svg:g/svg:rect[@y=$sequenceLineYmax])[last()]/@height + $sequenceLineHeightAfterLastBar - $sequenceLineYoffset"/>
                    <xsl:variable name="svgWidth" select="($svgMargin*2) + ( $actorBoxXdistance * ($countOfUniqueActors - 1)) + $actorBoxWidth"/>
                    <xsl:variable name="svgHeight" select="$svgMargin + $sequenceLineYoffset + $sequenceLineHeight"/>

                    <xsl:variable name="pinkRectWidth" select="($pinkRectMargin*2) + ($transactionNameMax*$letterWidth)"/>

                    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="{concat('svg_',$transactionGroupId)}" version="1.1" height="{$svgHeight}" width="{$svgWidth}" style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:0;">
                        <xsl:comment>Service Name</xsl:comment>
                        <xsl:text>&#10;</xsl:text>
                        <text x="{($svgWidth div 2)}" y="{$svgMargin}" style="font-size:12px;font-weight:bold;text-align:start;line-height:125%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                            <desc>Title of scenario</desc>
                            <xsl:value-of select="$transactionGroupName"/>
                        </text>
                        <g id="actor_objects">
                            <xsl:copy-of select="$actorBoxes/wrap/node()"/>
                        </g>
                        <g id="sequenceLines" xmlns="http://www.w3.org/2000/svg">
                            <xsl:for-each select="$actorBoxes/wrap/svg:g">
                                <xsl:variable name="sequenceLineX" select="(svg:rect)[1]/@x + ((svg:rect)[1]/@width div 2)"/>
                                <path style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" d="m {$sequenceLineX}, {$sequenceLineYoffset} v {$sequenceLineHeight}"/>

                            </xsl:for-each>
                        </g>
                        <xsl:copy-of select="$sequenceBars/wrap/svg:*"/>
                    </svg>
                    <!--/xsl:result-document-->
                </xsl:if>
                <xsl:if test="1=1">
                    <!--xsl:result-document method="xml" output-version="1.0" indent="yes" href="{$theOutputDir}tg-{@id}_technical.svg"-->
                    <xsl:variable name="clientName" select="'Client'"/>
                    <xsl:variable name="serverName" select="'Server'"/>
                    <xsl:variable name="sequenceBarHeight" select="75"/>
                    <xsl:variable name="sequenceBarPlusLineHeight" select="$sequenceBarHeight + $sequenceLineHeightBetweenBars"/>

                    <xsl:variable name="actorNameMax" select="string-length('Client')"/>
                    <xsl:variable name="pinkRectMax" select="string-length(concat('urn:hl7-org:v3/',(//project)[1]/@prefix,@id,'_'))+$transactionModelMax"/>
                    <xsl:variable name="transactionNameMax" select="max(transaction/name[@language=$defaultLanguage][1]/string-length()) + $transactionModelMax"/>

                    <xsl:variable name="actorBoxWidth" select="if ( ($actorBoxMarginLeftRight*2) + ($actorNameMax*$letterWidth) > $actorBoxMinWidth) then ( ($actorBoxMarginLeftRight*2) + ($actorNameMax*$letterWidth) ) else ($actorBoxMinWidth)"/>

                    <xsl:variable name="sequenceLineHeight" select="$sequenceLineHeightBetweenActorBoxAndFirstBar + ($sequenceBarHeight*$countOfInitialTransactions) + ($sequenceLineHeightBetweenBars*($countOfInitialTransactions - 1)) + $sequenceLineHeightAfterLastBar"/>

                    <xsl:variable name="pinkRectWidth" select="($pinkRectMargin*2) + ($pinkRectMax*$letterWidth)"/>

                    <xsl:variable name="arrowLength">
                        <xsl:variable name="theLength">
                            <xsl:choose>
                                <xsl:when test="($arrowMargin*2) + ($transactionNameMax*$letterWidth) > $arrowLengthMin">
                                    <xsl:value-of select="($arrowMargin*2) + ($transactionNameMax*$letterWidth)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$arrowLengthMin"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="if (($pinkRectWidth + 20) > $theLength) then ($pinkRectWidth + 20) else ($theLength)"/>
                    </xsl:variable>

                    <xsl:variable name="svgWidth" select="($svgMargin*2) + ($actorBoxWidth*2) + ( ($arrowLength - ($sequenceBarWidth div 2) - ($actorBoxWidth div 2))*(2 - 1))"/>
                    <xsl:variable name="svgHeight" select="($svgMargin*2) + $svgTitleHeight + $actorBoxHeight + $sequenceLineHeight"/>

                    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="{concat('svg_',$transactionGroupId)}" version="1.1" height="{$svgHeight}" width="{$svgWidth}" style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:0">
                        <xsl:comment>Service Name</xsl:comment>
                        <xsl:text>&#10;</xsl:text>
                        <text x="{($svgWidth div 2)}" y="{$svgMargin}" style="font-size:12px;font-weight:bold;text-align:start;line-height:125%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                            <desc>Title of scenario</desc>
                            <xsl:value-of select="$transactionGroupName"/>
                        </text>
                        <!-- Draw client and server actor boxes with sequence line -->
                        <g id="client_objects">
                            <xsl:comment> Client box (header) </xsl:comment>
                            <xsl:text>&#10;</xsl:text>
                            <g id="client_box">
                                <rect x="{($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2) - ($actorBoxWidth div 2)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>
                                <text x="{($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2)}" y="{$svgMargin + $svgTitleHeight + $actorBoxMarginTopBottom}" style="font-size:10px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                    <xsl:value-of select="$clientName"/>
                                </text>
                            </g>
                            <xsl:comment> Client Box Sequence Line </xsl:comment>
                            <xsl:text>&#10;</xsl:text>
                            <path style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" d="m {($svgWidth div 2) - ($arrowLength div 2) - ($sequenceBarWidth div 2)}, {$sequenceLineYoffset} v {$sequenceLineHeight}"/>
                        </g>
                        <g id="server_objects">
                            <xsl:comment> Server box (header) </xsl:comment>
                            <xsl:text>&#10;</xsl:text>
                            <g id="server_box">
                                <rect x="{($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2) - ($actorBoxWidth div 2)}" y="{$actorBoxYoffset}" height="{$actorBoxHeight}" width="{$actorBoxWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>
                                <text x="{($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2)}" y="{$svgMargin + $svgTitleHeight + $actorBoxMarginTopBottom}" style="font-size:10px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                    <xsl:value-of select="$serverName"/>
                                </text>
                            </g>
                            <xsl:comment> Server Box Sequence Line </xsl:comment>
                            <xsl:text>&#10;</xsl:text>
                            <path style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" d="m {($svgWidth div 2) + ($arrowLength div 2) + ($sequenceBarWidth div 2)} , {$sequenceLineYoffset} v {$sequenceLineHeight}"/>
                        </g>

                        <!-- Build bars, lines with arrows, and text per intial transaction -->
                        <xsl:for-each select="transaction[@type='initial']">
                            <xsl:variable name="currentTransactionId" select="@id"/>
                            <xsl:variable name="currentTransactionModel" select="@model"/>

                            <xsl:variable name="currentTransactionPos" select="count(../transaction[@id=$currentTransactionId]/preceding-sibling::transaction)+1"/>
                            <xsl:variable name="respondingTransactionPos" select="../transaction[@id=$currentTransactionId]/following-sibling::transaction[@type='back']/position() + 1"/>
                            <xsl:if test="not(preceding-sibling::transaction[@model=$currentTransactionModel])">
                                <g id="{generate-id(.)}">
                                    <xsl:comment> Client bar </xsl:comment>
                                    <xsl:text>&#10;</xsl:text>
                                    <rect x="{($svgWidth div 2) - ($arrowLength div 2) - $sequenceBarWidth}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>

                                    <xsl:comment> Server bar </xsl:comment>
                                    <xsl:text>&#10;</xsl:text>
                                    <rect x="{($svgWidth div 2) + ($arrowLength div 2)}" y="{$sequenceLineYoffset + $sequenceLineHeightBetweenActorBoxAndFirstBar + (position()-1)*($sequenceBarHeight + $sequenceLineHeightBetweenBars)}" height="{$sequenceBarHeight}" width="{$sequenceBarWidth}" style="fill:AliceBlue;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.37758133;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"/>

                                    <xsl:comment> SOAP Action in pink background-color </xsl:comment>
                                    <xsl:text>&#10;</xsl:text>
                                    <g xmlns="http://www.w3.org/2000/svg">
                                        <rect x="{($svgWidth div 2) - ($pinkRectWidth div 2)}" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" height="{$pinkRectHeight}" width="{$pinkRectWidth}" style="fill:#ffaaaa;fill-opacity:1"/>
                                        <text x="{($svgWidth div 2) }" y="{$pinkRectYoffset + ((position()-1) * $sequenceBarPlusLineHeight) + ($pinkRectHeight div 2) + 3}" style="font-size:10px;text-align:center;text-anchor:middle;line-height:125%;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                            <xsl:choose>
                                                <xsl:when test="@model">
                                                    <xsl:value-of select="concat('urn:hl7-org:v3/',(//project)[1]/@prefix,parent::transaction[@type='group']/@id,'_',@model)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat('urn:hl7-org:v3/',(//project)[1]/@prefix,parent::transaction[@type='group']/@id)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </text>
                                    </g>

                                    <xsl:comment> Arrow, with head, and label </xsl:comment>
                                    <xsl:text>&#10;</xsl:text>
                                    <g id="{concat('clientToServer_',generate-id(.))}" xmlns="http://www.w3.org/2000/svg">
                                        <g id="{concat('initiatingTransaction_',generate-id(.))}">
                                            <xsl:comment> Arrow text client to server </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <text x="{($svgWidth div 2)}" y="{$arrowTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}" style="font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
                                                <xsl:value-of select="name[@language=$defaultLanguage][1]/text()"/>
                                                <xsl:if test="string-length($currentTransactionModel)>0">
                                                    <xsl:text> (</xsl:text>
                                                    <xsl:value-of select="$currentTransactionModel"/>
                                                    <xsl:text>)</xsl:text>
                                                </xsl:if>
                                            </text>
                                            <xsl:comment> Arrow line client to server </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ',', $arrowYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none"/>
                                            <xsl:comment> Arrow head client to server </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <path d="{concat('m ', ($svgWidth div 2) + ($arrowLength div 2) - 10, ',', $arrowHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z')}" style="fill:#000000;fill-rule:evenodd;stroke:none"/>
                                        </g>

                                        <g id="{concat('respondingTransaction_',generate-id(.))}">
                                            <xsl:comment> Arrow text server to client </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <text x="{($svgWidth div 2)}" y="{$arrowReturnTextYoffset + ((position()-1) * $sequenceBarPlusLineHeight)}">

                                                <xsl:choose>
                                                    <xsl:when test="count($respondingTransactionPos)&gt;1">
                                                        <xsl:attribute name="style" select="'font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana'"/>
                                                        <xsl:value-of select="concat(@model,'Response')"/>
                                                    </xsl:when>
                                                    <xsl:when test="count($respondingTransactionPos)=1">
                                                        <xsl:attribute name="style" select="'font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana'"/>
                                                        <xsl:value-of select="../transaction[$respondingTransactionPos]/name[@language=$defaultLanguage][1]/text()"/>
                                                        <xsl:if test="@model">
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:value-of select="../transaction[$respondingTransactionPos]/@model"/>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:message>
                                                            <xsl:text>+++ WARNING: WSDL diagram for transaction group '</xsl:text>
                                                            <xsl:value-of select="$transactionGroupName"/>
                                                            <xsl:text>' (id='</xsl:text>
                                                            <xsl:value-of select="$transactionGroupId"/>
                                                            <xsl:text>'), is missing a transaction of type @type='back'. Webservice needs input and output document</xsl:text>
                                                        </xsl:message>
                                                        <xsl:attribute name="style" select="'font-style:italic;font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana'"/>
                                                        <xsl:text>undefined</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </text>
                                            <xsl:comment> Arrow line server to client </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <path d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2), ', ' , $arrowReturnYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' h ', $arrowLength)}" style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:9, 5;marker-end:none"/>
                                            <xsl:comment> Arrow head server to client </xsl:comment>
                                            <xsl:text>&#10;</xsl:text>
                                            <path
                                                d="{concat('m ',($svgWidth div 2) - ($arrowLength div 2) + 10,',', $arrowReturnHeadYoffset + ((position()-1) * $sequenceBarPlusLineHeight), ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}"
                                                style="fill:#000000;fill-rule:evenodd;stroke:none"/>

                                        </g>
                                    </g>
                                </g>
                            </xsl:if>
                        </xsl:for-each>
                    </svg>
                    <!--/xsl:result-document-->
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
