(:     This is the main controller for the web application. It is called from the
    XQueryURLRewrite filter configured in web.xml. :)
xquery version "3.0";

(:~ -------------------------------------------------------
    Main controller: handles all requests not matched by
    sub-controllers.
    ------------------------------------------------------- :)
import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../art/modules/art-decor-settings.xqm";

let $getWSDL        := 'wsdl' = request:get-parameter-names()
return

(:
    XIS Webservices
:)
    if ($exist:resource = 'RetrieveMessage') then (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
             <forward url="modules/RetrieveMessage.xquery"/>
        </dispatch>
    )
    else if ($exist:resource = 'RenderMessage') then (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
             <forward url="modules/message2html.xquery"/>
        </dispatch>
    )
    else if ($exist:resource = 'ViewTestresult') then (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="modules/retrieve-testresult.xquery"/>
            <view>
                <forward servlet="XSLTServlet">
                    <set-attribute name="xslt.stylesheet" value="{$exist:root}/resources/stylesheets/analyseMessage2html.xsl"/>
                    <set-attribute name="xslt.output.media-type" value="text/html"/>
                </forward>
            </view>
        </dispatch>
    ) 
    (: This is vulnerable. Any xquery that needs parameter wsdl is now bypassed. However:
        - currently no xquery does that
        - we have no alternative methode to find whether or not $exist:resource is a service
    :)
    else if ($getWSDL=true()) then (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/modules/WSDL-response.xquery">
                <add-parameter name="service" value="{$exist:resource}"/>
            </forward>
        </dispatch>
    )
    (: This is vulnerable. This assumes that any webservice requires a SOAPAction, and that the sender actually implemented it
       WS-i Basic Profile states that SOAPAction is not required. The sender may have made a mistake. However:
       - currently every soap webservice to date uses a SOAPAction header
       - we have no alternative method to detect whether or not we're dealing with soap. When you call request:get-data() here, 
         you cannot call it again in SOAP-response.xquery or anywhere else
    :)
    else if (request:get-header('SOAPAction')) then (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/modules/SOAP-response.xquery">
                <add-parameter name="service" value="{$exist:resource}"/>
            </forward>
        </dispatch>
    )
    else (
        <ignore xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="yes"/>
        </ignore>
    )