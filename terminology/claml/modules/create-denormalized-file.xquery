import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";

(:let $clamlDataCollection := 'atc-data':)

(:let $clamlDataCollection := 'icf-data':)

(:let $clamlDataCollection := 'icd10-data':)

let $clamlDataCollection := 'hl7-data'

(:let $clamlDataCollection := 'loinc-claml':)

for $claml in collection(concat($get:strTerminologyData,'/',$clamlDataCollection))//ClaML
   let $denormalizedFileName := concat(substring-before(util:document-name($claml),'.xml'),'-denormalized.xml')
   let $denormalizedCollection := concat(substring-before(util:collection-name($claml),'/claml'),'/denormalized')
return
xmldb:store($denormalizedCollection,$denormalizedFileName,transform:transform($claml,xs:anyURI(concat('xmldb:exist://',$get:strTerminology,'/claml/resources/stylesheets/ClaML-2-denormalized.xsl')),<parameters/>))