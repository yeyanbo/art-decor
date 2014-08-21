xquery version "1.0";
(:
    Copyright (C) 2011-2014 ART-DECOR expert group art-decor.org
    
    Author: Gerrit Boers

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "art-decor-settings.xqm";
declare namespace svg="http://www.w3.org/2000/svg";
(:declare option exist:serialize "method=svg media-type=application/svg+xml omit-xml-declaration=no indent=yes";:)

let $scenarioId := request:get-parameter('id','2.16.840.1.113883.2.4.6.99.1.77.3.1')
(:let $scenarioId := '2.16.840.1.113883.2.4.6.99.1.77.3.1':)
let $collection := $get:strDecorData
let $scenario := collection($collection)//scenario[@id=$scenarioId]
let $scenarioName :=$scenario/name/text()
let $clientName :=$scenario/actors/actor[1]/name/text()
let $serverName :=$scenario/actors/actor[2]/name/text()
let $transactionCount := count($scenario/transaction)
let $maxTransactionName := max($scenario/transaction/name/string-length())
let $maxActorName := max($scenario/actors/actor/name/string-length())
let $minActorboxWidth := 80
let $sequencebarWidth :=10
let $minArrowLength := 350
let $actorboxWidth := 
									if (10 + $maxActorName*6 > $minActorboxWidth) then
									20 + $maxActorName*6
									else ($minActorboxWidth)
let $arrowLength :=
									if (100 + $maxTransactionName*6 > $minArrowLength) then
									100 + $maxTransactionName*6
									else($minArrowLength)
let $width := 150 + $arrowLength
let $widthPinkRect:= 10 + $maxTransactionName*6
let $heightPinkRect := 16
let $offsetPinkRectY := 10


let $transactionLabels :=  
						for $transactionGroup  at $position in $scenario/transaction
						let $transactionName :=$transactionGroup/name/text()
			    	return
						<g xmlns="http://www.w3.org/2000/svg">
							<rect y="{$offsetPinkRectY + ($position * 100)}" x="{($width div 2) - ($widthPinkRect div 2) }" height="{$heightPinkRect}" width="{$widthPinkRect}"
										style="fill:#ffaaaa;fill-opacity:1">
							</rect>
							<text y="{$offsetPinkRectY  + ($position * 100) + ($heightPinkRect div 2) + 3}" x="{($width div 2) }"
										style="font-size:10px;text-align:center;text-anchor:middle;line-height:125%;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
								{$transactionName}
							</text>
						</g>

let $transactionInteractions :=  
						for $transactionGroup  at $position in $scenario/transaction
						let $messageIn :=$transactionGroup/transaction[1]/name/text()
						let $messageOut :=$transactionGroup/transaction[2]/name/text()
			    	return
			    	<g id="interactionLabels" xmlns="http://www.w3.org/2000/svg">
							<text style="font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana"
										x="{($width div 2)}" y="{45 + ($position * 100)}" id="inMessage">
								{$messageIn}
							</text>
							<text  xmlns="http://www.w3.org/2000/svg"
										style="font-size:10px;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:center;line-height:125%;writing-mode:lr-tb;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana"
										x="{($width div 2)}" y="{80 + ($position * 100)}" id="outMessage">
								{$messageOut}
              </text>
             </g>
                            
let $transactionArrows :=  
						for $transactionGroup  at $position in $scenario/transaction
			    	return
			    	<g id="arrows" xmlns="http://www.w3.org/2000/svg">
							<g id="gArrowClientToServer">
								<path id="ArrowClientToServer" d="{concat('m ',($width div 2)- ($arrowLength div 2), ',', 50 + ($position*100), ' h ', $arrowLength)}"
											style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;marker-end:none">
									<desc>This is the initiating arrow</desc>
								</path>
								<!-- arrow head client to server -->
								<path d="{concat('m ', ($width div 2) + ($arrowLength div 2) - 10, ',', 45 + ($position*100), ' 0.2428,9.99706 c 3.8451,-1.75975 7.6902,-3.51949 11.5354,-5.27924 0,-0.002 0,-0.002 0,-0.002 0,0 0,0 -0,-0.002 -3.926,-1.57108 -7.852,-3.14216 -11.7781,-4.71324 z')}"
											style="fill:#000000;fill-rule:evenodd;stroke:none">
								</path>
							</g>
							<g id="gArrowServerToClient">
								<path id="ArrowServerToClient" d="{concat('m ',($width div 2)- ($arrowLength div 2), ', ' , 85 + ($position*100), ' h ', $arrowLength)}"
											style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none;marker-end:none">
									<desc> This is the responding arrow</desc>
								</path>
								<!-- The arrow head server to client -->
								<path d="{concat('m ',($width div 2)- ($arrowLength div 2) + 10,',', 90 + ($position*100), ' 0.4062,-9.99174 c -3.3774,1.28641 -6.7547,2.57283 -10.132,3.85925 0,0 0,0 0,0 -0.4815,0.18338 -0.9629,0.36676 -1.4444,0.55014 0,0 0,0 0,0 -0.076,0.0291 -0.153,0.0583 -0.2295,0.0874 0,0 0,0 0,0 0,0 0,0 0,0 -0.015,0.0176 -0.029,0.0231 -0.043,0.0246 0,0 0,0 0,0 -0.01,5.5e-4 -0.01,5.8e-4 -0.015,4.1e-4 -0,-6e-5 -0,-6e-5 -0,-6e-5 0,0 0,0 0,9e-5 0.01,2.6e-4 0.01,6.3e-4 0.015,0.002 0,0 0,0 0,0 0.014,0.003 0.028,0.009 0.041,0.028 0,0 0,0 0,0 0,0 0,0 0,0 0.074,0.0353 0.1478,0.0705 0.2216,0.10576 0.465,0.22185 0.93,0.44371 1.395,0.66556 3.2617,1.55631 6.5235,3.11262 9.7853,4.66892 z')}"
											style="fill:#000000;fill-rule:evenodd;stroke:none">
								</path>
							</g>
			    	</g>
						
return
<svg xmlns="http://www.w3.org/2000/svg" id="svg2" version="1.1" height="{140 + ($transactionCount * 100)}" width="{$width}">
	<rect style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:0"
				id="backgroundObject" width="{$width}" height="{140 + ($transactionCount * 100)}" x="0" y="0">
		<desc>Background rectangle in white to avoid transparency.</desc>
	</rect>
	<!-- Service name -->
	<text style="font-size:12px;font-weight:bold;text-align:start;line-height:125%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana"
				x="{($width div 2)}" y="50" id="textService">

		<desc>Title of scenario</desc>    
	</text>
	<!-- Client side objects -->
	<g id="client_objects">
		<!-- Client box (header) -->
			<g id="client_box">
				<rect y="20" x="{($width div 2) - ($arrowLength div 2) - ($sequencebarWidth div 2) - ($actorboxWidth div 2)}" height="50" width="{$actorboxWidth}" id="clientBox"
							style="fill:#c4e1ff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none">
					<desc id="desc2842">Header box for client</desc>
				</rect>
				<text y="50" x="{($width div 2) - ($arrowLength div 2) - ($sequencebarWidth div 2)}"
							style="font-size:10px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
					{$clientName}
				</text>
      </g>
		<!-- Client box to bar connect -->
		<path style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
					d="m {($width div 2) - ($arrowLength div 2) - ($sequencebarWidth div 2)}, 70 v 30" id="path3646">
			<desc id="desc3635">Client box to bar connector</desc>
		</path>
		<!-- Client bar -->
		<rect y="100" x="{($width div 2) - ($arrowLength div 2) - $sequencebarWidth}" height="{20 + $transactionCount*100}" width="{$sequencebarWidth}" id="rectClientBar"
					style="fill:#c4e1ff;fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none">
			<desc id="desc2880">Client bar</desc>
		</rect>
	</g>
	<!-- Server side objects -->
	<g id="server_objects">
		<!-- Server box -->
		<g id="server_box">
			<rect style="fill:#c4e1ff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"
						y="20" x="{($width div 2) + ($arrowLength div 2) + ($sequencebarWidth div 2) - ($actorboxWidth div 2)}" height="50" width="{$actorboxWidth}" id="rect2844">
			</rect>
			<text y="50" x="{($width div 2) + ($arrowLength div 2) + ($sequencebarWidth div 2)}" style="font-size:10px;font-weight:bold;text-align:middle;line-height:100%;text-anchor:middle;fill:#000000;fill-opacity:1;stroke:none;font-family:Verdana">
				<desc id="desc4316">Could add application role here</desc>
				{$serverName}
			</text>
		</g>
		<!-- Server bar -->
		<rect y="100" x="{($width div 2) + ($arrowLength div 2)}" height="{20 + $transactionCount*100}" width="{$sequencebarWidth}" id="rectServerBar"
					style="fill:#c4e1ff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0.37758133;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none">
			<desc id="desc2864">Server bar</desc>
		</rect>
		<!-- Server box to bar line -->
		<path style="fill:none;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
					d="{concat('m ', (($width div 2) + ($arrowLength div 2) + ($sequencebarWidth div 2)) , ', 70 v 30')}" id="path2872">
		</path>
	</g>
	{
		$transactionLabels,
		$transactionInteractions,
		$transactionArrows
	}
</svg>