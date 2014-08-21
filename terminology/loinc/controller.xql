xquery version "1.0";

declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
		else if (matches($exist:path, "/searchLOINC")) then
			<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
				<forward url="/loinc/modules/search-loinc-concept.xquery">
					<add-parameter name="string" value="{$exist:resource}"/>
				</forward>
			</dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>