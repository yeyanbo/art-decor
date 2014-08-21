xquery version "1.0";

import module namespace ada = "http://art-decor.org/ns/ada-xml" at "../modules/ada-xml.xqm";
declare namespace validation = "http://exist-db.org/xquery/validation";

let $xml    := collection($ada:strAdaProjects)//*[@id='cf495ca8-a36e-4eca-b281-8b574ba21640']
let $schema := doc(concat($ada:strAdaProjects,'/demoapp/schemas/measurement_message.xsd'))
let $result := validation:jaxv-report($xml, $schema)
return $result