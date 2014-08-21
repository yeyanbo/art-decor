(:     This is the main controller for the web application. It is called from the
    XQueryURLRewrite filter configured in web.xml. :)
xquery version "3.0";

(:~ -------------------------------------------------------
    Main controller: handles all requests not matched by
    sub-controllers.
    ------------------------------------------------------- :)

declare namespace c="http://exist-db.org/xquery/controller";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $query := request:get-parameter("q", ())
return


(:
    ClaML Webservices

:)
if (matches($exist:path, "ViewClass")) then (
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="modules/claml-get-class.xquery"/>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{$exist:root}/claml/resources/stylesheets/class2html.xsl"/>
                <set-attribute name="xslt.root" value="{$exist:prefix}"/>
                <set-attribute name="xslt.output.media-type" value="text/html"/>
            </forward>
        </view>
    </dispatch>
)
else if (matches($exist:path, "RetrieveClass")) then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<forward url="/claml/modules/claml-get-class.xquery">
		</forward>
	</dispatch>
	 else if (matches($exist:path, "RetrieveSubClasses")) then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<forward url="/claml/modules/get-subclasses.xquery">
		</forward>
	</dispatch>
else if (matches($exist:path, "SearchDescription")) then
	<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<forward url="/claml/modules/search-description.xquery">
		</forward>
	</dispatch>
else (
  <ignore xmlns="http://exist.sourceforge.net/NS/exist">
      <cache-control cache="yes"/>
  </ignore>
)