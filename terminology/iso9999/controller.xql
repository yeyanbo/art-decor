xquery version "1.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
	else if (matches($exist:path, "/SearchISO9999")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/iso9999/modules/search-iso9999.xquery">
					<add-parameter name="string" value="{$exist:resource}"/>
				</forward>
			</dispatch>
		else if ($exist:resource ="RetrieveISO9999") then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/iso9999/modules/retrieve-iso9999.xquery"/>
			</dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
