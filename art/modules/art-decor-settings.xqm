xquery version "3.0";
(:
	Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:)

module namespace get    = "http://art-decor.org/ns/art-decor-settings";
declare namespace repo  = "http://exist-db.org/xquery/repo";
declare variable $get:root := repo:get-root();

(:~ String variable with everything under art :)
declare variable $get:strArt             := concat($get:root,'art');
(:~ String variable with location of art/resources :)
declare variable $get:strArtResources    := concat($get:root,'art/resources');
(:~ Collection variable with everything under art/resources :)
declare variable $get:colArtResources    := collection($get:strArtResources);

(:~ String variable with everything under art-data :)
declare variable $get:strArtData         := concat($get:root,'art-data');
(: Should not expose these user-info variables. Use the api-user-settings.xqm instead :)
(:~ String variable to the art user-info.xml contents :)
declare variable $get:strUserInfo        := concat($get:strArtData,'/user-info.xml');
(:~ Document variable with the art user-info.xml contents :)
declare variable $get:docUserInfo        := doc($get:strUserInfo);

(:~ String variable with the ART-DECOR server config:)
declare variable $get:strServerInfo      := concat($get:strArtData,'/server-info.xml');
(:~ String variable with the default ART-DECOR server language. May be user overridden :)
declare variable $get:strArtLanguage     := 
    if (doc-available($get:strServerInfo) and doc($get:strServerInfo)/server-info/defaultLanguage) then
        doc($get:strServerInfo)/server-info/defaultLanguage/string()
    else ('en-US');

(:~ String variable with the DECOR types :)
declare variable $get:strDecorTypes      := concat($get:strArtData,'/decor-xsd-types.xml');
(:~ String variable with the database location of decor/develop collection :)
declare variable $get:strDecorDevelop      := concat($get:root,'decor/develop');
(:~ String variable with the database location of decor/cache collection :)
declare variable $get:strDecorCache      := concat($get:root,'decor/cache');
(:~ String variable with the database location of decor/data collection :)
declare variable $get:strDecorData       := concat($get:root,'decor/data');
(:~ String variable with the database location of decor/core collection :)
declare variable $get:strDecorCore       := concat($get:root,'decor/core');
(:~ String variable with the database location of version collection :)
declare variable $get:strDecorVersion    := concat($get:root,'decor/releases');
(:~ Collection variable with the database location of version collection :)
declare variable $get:colDecorVersion    := collection($get:strDecorVersion);
(:~ Collection variable with everything under decor/cache :)
declare variable $get:colDecorCache      := collection($get:strDecorCache);
(:~ Collection variable with everything under decor/data :)
declare variable $get:colDecorData       := collection($get:strDecorData);
(:~ String variable with path to ISO Schematron transformations to XSL :)
declare variable $get:strUtilISOSCH2SVRL := concat($get:strArtResources,'/iso-schematron');
(:~ String variable with everything under ada/projects :)
declare variable $get:docDecorSchema     := doc(concat($get:strDecorCore,'/DECOR.xsd'));
(:~ Collection variable with everything under decor/core :)
declare variable $get:colDecorCore       := collection($get:strDecorCore);

(:~ Collection variable with everything under hl7 :)
declare variable $get:strHl7             := concat($get:root,'hl7');
(:~ String variable to CDA stylesheet :)
declare variable $get:strCdaXsl          := concat($get:strHl7,'/CDAr2/xsl/cda.xsl');

(:~ Collection variable with everything under terminology :)
declare variable $get:strTerminology     := concat($get:root,'terminology');
(:~ Collection variable with everything under terminology-data :)
declare variable $get:strTerminologyData := concat($get:root,'terminology-data');

(:~ String variable with everything under xis resources :)
declare variable $get:strXisResources    := concat($get:root,'xis/resources');
(:~ String variable with the database location of xis-data collection :)
declare variable $get:strXisData         := concat($get:root,'xis-data');
(:~ String variable with everything under xis accounts :)
declare variable $get:strXisAccounts     := concat($get:strXisData,'/accounts');
(:~ String variable with the database location of xis-data/data collection :)
declare variable $get:strXisHelperConfig := concat($get:strXisData,'/data');
(:~ String variable with the database location of test accounts :)
declare variable $get:strTestAccounts    := concat($get:strXisData,'/test-accounts.xml');
(:~ String variable with the database location of test suites :)
declare variable $get:strTestSuites      := concat($get:strXisData,'/test-suites.xml');
(:~ String variable with the database location of test suites :)
declare variable $get:strSoapServiceList := concat($get:strXisData,'/soap-service-list.xml');

(:~ String variable with the database location of OIDS data collection :)
declare variable $get:strOidsData        := concat($get:root,'tools/oids-data');
(:~ Collection variable with everything under oids/data :)
declare variable $get:colOidsData        := collection(concat($get:root,'tools/oids-data'));
(:~ String variable with the database location of OIDS core collection :)
declare variable $get:strOidsCore        := concat($get:root,'tools/oids/core');
(:~ String variable with the database location of OIDS resources collection :)
declare variable $get:strOidsResources   := concat($get:root,'tools/oids/resources');
