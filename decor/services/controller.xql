(:  This is the main controller for the web application. It is called from the
    XQueryURLRewrite filter configured in web.xml. :)
xquery version "3.0";

(:~ -------------------------------------------------------
    Main controller: handles all requests not matched by
    sub-controllers.
    ------------------------------------------------------- :)

declare namespace c             = "http://exist-db.org/xquery/controller";
import module namespace request = "http://exist-db.org/xquery/request";
declare variable $exist:path external;
declare variable $exist:resource external;

let $query    := request:get-parameter("q", ())
return
    (: redirect webapp root to index.xml :)
    if ($exist:path eq '/') then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="index.xml"/>
        </dispatch>
        
    (: ignore Cocoon :)
(:    else if (matches($exist:path, "/cocoon")) then
        <ignore xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="yes"/>
        </ignore>:)
        
(:    else if ($exist:resource eq 'applications.xml') then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <!-- query results are passed to XSLT servlet via request attribute -->
            <set-attribute name="xquery.attribute" value="model"/>
            <view>
                <forward servlet="XSLTServlet">
                    <set-attribute name="xslt.input" value="model"/>
                    <set-attribute name="xslt.stylesheet" value="apps/applications.xsl"/>
                </forward>
                <forward servlet="XSLTServlet">
                    <set-attribute name="xslt.input" value=""/>
                    <set-attribute name="xslt.stylesheet" value="stylesheets/db2html.xsl"/>
                </forward>
            </view>
        </dispatch>:)

(:
    DECOR REST Services
    RetrieveDataset, RetrieveValueset, RetrieveCode,
    RetrieveOID, DatasetIndex, ValuesetIndex, CodeSystemIndex, OIDIndex, GetImage
:)
    else if ($exist:resource = 'RetrieveDataSet') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveTransaction.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveConceptDiagram') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveConceptDiagram.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveCodeSystem') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveCodeSystem.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveValueSet') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveValueSet.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveCode') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveCode.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveOID') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveOID.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveXpathsForTransaction') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveXpathsForTransaction.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveTransaction') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveTransaction.xquery"/>
            </dispatch>
    else if ($exist:resource = 'ProjectIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/ProjectIndex.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveProject') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveProject.xquery"/>
            </dispatch>
    else if ($exist:resource = 'TerminologyReport') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/TerminologyReport.xquery"/>
            </dispatch>
    else if ($exist:resource = 'DataSetIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/ProjectIndex.xquery">
                    <add-parameter name="view" value="d"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'TemplateIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/ProjectIndex.xquery">
                    <add-parameter name="view" value="r"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'TransactionIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/ProjectIndex.xquery">
                    <add-parameter name="view" value="t"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'ValueSetIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/ProjectIndex.xquery">
                    <add-parameter name="view" value="v"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'CodeSystemIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/CodeSystemIndex.xquery"/>
            </dispatch>            
    else if ($exist:resource = 'OIDIndex') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/OIDIndex.xquery"/>
            </dispatch>
    else if ($exist:resource = 'GetImage') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/GetImage.xquery"/>
            </dispatch>
   else if ($exist:resource = 'RetrieveMessageForInstance') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/retrieve-message-for-instance.xquery"/>
            </dispatch>
    else if ($exist:resource = 'Template2XSL') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/Template2XSL.xquery"/>
            </dispatch>
   (:else if ($exist:resource = 'RetrieveTemplatePrototypeList') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/retrieve-template-prototype-list.xquery"/>
            </dispatch>:)
   (:else if ($exist:resource = 'RetrieveTemplatePrototype') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/retrieve-template-prototype.xquery"/>
            </dispatch>:)
   (:else if ($exist:resource = 'RetrieveTemplatePrototypeForEditor') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/retrieve-template-prototype-for-editor.xquery"/>
            </dispatch>:)
    else if ($exist:resource = 'RetrieveTemplateDiagram') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveTemplateDiagram.xquery"/>
            </dispatch>
    else if ($exist:resource = 'RetrieveTemplate') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RetrieveTemplate.xquery"/>
            </dispatch>
    else if ($exist:resource = 'SearchCodeSystem') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/SearchValueSet.xquery">
                    <add-parameter name="type" value="codesystem"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'SearchValueSet') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/SearchValueSet.xquery">
                    <add-parameter name="type" value="valueset"/>
                </forward>
            </dispatch>
    else if ($exist:resource = 'RenderCDA') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/RenderCDA.xquery"/>
            </dispatch>
    (:else if ($exist:resource = 'TestService') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="modules/TestService.xquery"/>
            </dispatch>:)
    else
            <ignore xmlns="http://exist.sourceforge.net/NS/exist">
                <cache-control cache="yes"/>
            </ignore>
