xquery version "1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if ($exist:resource ="RetrieveICA-mapping") then
   <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   	<forward url="/ica/modules/RetrieveICA-mapping.xquery"/>
   </dispatch>
else if ($exist:resource ="RetrieveXML") then
   <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   	<forward url="/ica/modules/retrieve-ci-list-xml.xquery"/>
   </dispatch>
else if ($exist:resource ="RetrieveHTML") then
   <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
   	<forward url="/ica/modules/retrieve-ci-list-xml.xquery"/>
      <view>
			<forward servlet="XSLTServlet">
				<set-attribute name="xslt.stylesheet" value="{$exist:root}/ica/resources/stylesheets/ci-list-2-html.xsl"/>
				<set-attribute name="xslt.output.media-type" value="text/html"/>
    			<set-attribute name="xslt.output.doctype-public" value="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
    			<set-attribute name="xslt.output.doctype-system" value="resources/xhtml1-transitional.dtd"/>
			</forward>
		</view>
   </dispatch>
else if (matches($exist:path, "/getRelease")) then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<forward url="/ica/modules/get-zipped-release.xquery">
			<add-parameter name="release" value="{$exist:resource}"/>
		</forward>
	</dispatch>	
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>