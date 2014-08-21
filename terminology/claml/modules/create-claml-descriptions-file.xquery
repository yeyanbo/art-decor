import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
(:let $clamlDataCollection := 'atc-data':)

(:let $clamlDataCollection := 'icf-data':)


(:let $clamlDataCollection := 'icd10-data':)

(:let $clamlDataCollection := 'loinc-claml':)


let $clamlDataCollection := 'hl7-data'

for $claml in collection(concat($get:strTerminologyData,'/',$clamlDataCollection))//ClaML
   let $descriptionsFileName := concat(substring-before(util:document-name($claml),'.xml'),'-descriptions.xml')
      let $descriptionsCollection := concat(substring-before(util:collection-name($claml),'/claml'),'/descriptions')


(:transform:transform($claml,xs:anyURI(concat('xmldb:exist://',$get:strTerminology,'/claml/resources/stylesheets/ClaML-2-descriptions.xsl')),<parameters/>)
:)return
xmldb:store($descriptionsCollection,$descriptionsFileName,transform:transform($claml,xs:anyURI(concat('xmldb:exist://',$get:strTerminology,'/claml/resources/stylesheets/ClaML-2-descriptions.xsl')),<parameters/>))


