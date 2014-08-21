xquery version "1.0";

import module namespace get ="http://art-decor.org/ns/art-decor-settings" at "../../../art/modules/art-decor-settings.xqm";
(:let $clamlDataCollection := 'atc-data':)
(:let $clamlDataCollection := 'icf-data':)
(:let $clamlDataCollection := 'icd10-data':)
(:let $clamlDataCollection := 'loinc-claml':)

let $clamlDataCollection := 'hl7-data'

let $collections := 
    for $claml in collection(concat($get:strTerminologyData,'/',$clamlDataCollection))//ClaML
    let $denormalizedCollection := concat(substring-before(util:collection-name($claml),'/claml'),'/denormalized')
    return
        $denormalizedCollection
   
for $classification in collection($collections)//ClaML-denormalized
let $currentRootClass := update delete $classification/Class[@name='rootClass']
let $class            :=
    <Class code="rootClass">
    {
        for $subClass in $classification//Class[not(SuperClass)]
        return
        <SubClass subCount="{count($subClass/SubClass)}">
        {
            $subClass/@*,
            $subClass/Rubric[@kind='preferred']
        }
        </SubClass>
    }
        <Rubric kind="preferred">
            <Label xml:lang="nl">{$classification/Title/@name/string()}</Label>
        </Rubric>
        <Rubric kind="description">
            <Label xml:lang="nl">{$classification/Title/text()}</Label>
        </Rubric>
    </Class>
return
    update insert $class following $classification//Title
 
 
