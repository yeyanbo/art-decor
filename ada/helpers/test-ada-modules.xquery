(:
    Copyright (C) 2013-2014  Marc de Graauw
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
:)
xquery version "3.0";

import module namespace ada     = "http://art-decor.org/ns/ada-common" at "../modules/ada-common.xqm";
import module namespace adaxml  = "http://art-decor.org/ns/ada-xml" at "../modules/ada-xml.xqm";
declare namespace util          = "http://exist-db.org/xquery/util";

declare function local:test-all() as element()* {
    let $results := 
        (
        local:test-ada-common(),
        local:test-schema-uri(),
        local:test-validate-schema(),
        local:test-add-remove-concept-id()
        )
    return $results
};
    
declare function local:test-ada-common() as element()* {
    let $uri := ada:getUri('demo1-', 'data')
    return 
        if ($uri = concat($ada:strAdaProjects,'/demo1/data/')) 
        then <success>{$uri}</success> 
        else <failed>{$uri}</failed>
};
    
declare function local:test-schema-uri() as element()* {
    let $doc    := doc(concat($ada:strAdaProjects,'/rivmsp/data/0c8dbaeb-ae33-4164-978e-ed21738c4f1a.xml'))
    let $schema := ada:getSchemaUri($doc)
    return 
        if ($schema = concat($ada:strAdaProjects,'/rivmsp/schemas/gestructureerde_gegevensvastlegging_coloscopie_bevolkingsonderzoek_darmkanker.xsd')) 
        then <success>{$schema}</success> 
        else <failed>{$schema}</failed>
};
    
declare function local:test-validate-schema() as element()* {
    let $doc    := concat($ada:strAdaProjects,'/demo1/data/9528f370-1a2e-4a35-bc23-e855483f8f37.xml')
    let $schema := concat($ada:strAdaProjects,'/demo1/schemas/meting_bericht.xsd')
    let $result := adaxml:validateSchema($doc, $schema)
    let $test1  := 
        if (data($result//report/status) = 'valid')
        then <success>{$result}</success> 
        else <failed>{$result}</failed>
    let $doc    := concat($ada:strAdaProjects,'/demo1/data/test-invalid-data.xml')
    let $result := adaxml:validateSchema($doc, $schema)
    let $test2  := 
        if (data($result//report/status) = 'invalid')
        then <success>{$result}</success> 
        else <failed>{$result}</failed>
    let $result := adaxml:validateSchema($doc, $doc)
    let $test3  := 
        if (data($result//@status-after) = 'error')
        then <success>{$result}</success> 
        else <failed>{$result}</failed>
    let $doc    := concat($ada:strAdaProjects,'/demo1/data/geen-doc.xml')
    let $test4  := 
        try {
            let $result := adaxml:validateSchema($doc, $schema)
            return <failed>DocNotAvailable not raised</failed>
            }
        catch DocNotAvailable {<success>DocNotAvailable</success>}
        catch * {<failed>Unexpected error</failed>}    
    return ($test1, $test2, $test3, $test4)
};

declare function local:test-add-remove-concept-id() as element()* {
    let $transactionId  := "2.16.840.1.113883.3.1937.99.62.3.4.2" 
    let $dataset        := doc(concat($ada:strAdaProjects,'/demo1/definitions/demo1-20131016T092058-nl-NL-ada-release.xml'))//transactionDatasets/dataset[@transactionId=$transactionId]
    let $elements       := <meting_bericht><meetwaarden/></meting_bericht>
    let $result         := adaxml:addConceptId($elements, $dataset)
    let $test1          := 
        if ($result//meetwaarden/@conceptId)
        then <success>{$result}</success> 
        else <failed>{$result}</failed>
    let $result         := adaxml:removeConceptId($result)
    let $test2          := 
        if (not($result//meetwaarden/@conceptId))
        then <success>{$result}</success> 
        else <failed>{$result}</failed>
    let $doc            := concat($ada:strAdaProjects,'/demo1/data/9528f370-1a2e-4a35-bc23-e855483f8f37.xml')
    let $result         := adaxml:addCode(doc($doc)/adaxml/data/*, $dataset)
    let $test3          := 
        if ($result//meting_door/@code)
        then <success>{$result//meting_door}</success> 
        else <failed>{$result//meting_door}</failed>
    return ($test1, $test2, $test3)
};

let $results    := local:test-all()
return <results>{$results}</results>

