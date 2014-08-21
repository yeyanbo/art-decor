(:     This is the main controller for the web application. It is called from the
    XQueryURLRewrite filter configured in web.xml. :)
xquery version "3.0";
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
	else if (matches($exist:path, "/getConcept")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/get-snomed-concept.xquery">
					<add-parameter name="id" value="{$exist:resource}"/>
				</forward>
			</dispatch>
	else if (matches($exist:path, "/viewConcept")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/retrieve-concept.xquery">
					<add-parameter name="id" value="{$exist:resource}"/>
				</forward>
				<view>
					<forward servlet="XSLTServlet">
						<set-attribute name="xslt.stylesheet" value="{$exist:root}/snomed/resources/stylesheets/concept2html.xsl"/>
						<set-attribute name="xslt.output.media-type" value="text/html"/>
    					<set-attribute name="xslt.output.doctype-public" value="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
    					<set-attribute name="xslt.output.doctype-system" value="resources/xhtml1-transitional.dtd"/>
					</forward>
				</view>
			</dispatch>
	else if (matches($exist:path, "/getDescription")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/get-concept-description.xq">
					<add-parameter name="conceptId" value="{$exist:resource}"/>
				</forward>
			</dispatch>
	else if (matches($exist:path, "/searchDescription")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/search-snomed-description.xquery">
					<add-parameter name="string" value="{$exist:resource}"/>
				</forward>
			</dispatch>
	else if (matches($exist:path, "/retrieveRefsetASCII")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/retrieve-refset.xquery">
					<add-parameter name="string" value="{$exist:resource}"/>
				</forward>
			</dispatch>
	else if (matches($exist:path, "/retrieveRefsetXML")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/retrieve-refset-xml.xquery">
					<add-parameter name="string" value="{$exist:resource}"/>
				</forward>
			</dispatch>
	else if (matches($exist:path, "/viewRefset")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/view-refset.xquery">
					<add-parameter name="id" value="{$exist:resource}"/>
				</forward>
				<view>
					<forward servlet="XSLTServlet">
						<set-attribute name="xslt.stylesheet" value="{$exist:root}/snomed/resources/stylesheets/refset2html.xsl"/>
						<set-attribute name="xslt.output.media-type" value="text/html"/>
    					<set-attribute name="xslt.output.doctype-public" value="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
    					<set-attribute name="xslt.output.doctype-system" value="resources/xhtml1-transitional.dtd"/>
					</forward>
				</view>
			</dispatch>
	else if (matches($exist:path, "/isDescendant")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/is-descendant.xquery">
				</forward>
			</dispatch>
	else if (matches($exist:path, "/getRelease")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/snomed/modules/get-zipped-release.xquery">
					<add-parameter name="release" value="{$exist:resource}"/>
				</forward>
			</dispatch>	
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>