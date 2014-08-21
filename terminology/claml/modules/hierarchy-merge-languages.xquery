let $primaryFileName := 'icd102010en-hierarchy.xml'
let $secondaryFileName := 'ICD-10-v2006-def-nl-hierarchy.xml'

let $primary :=doc(concat('/db/apps/terminology/claml/hierarchy/',$primaryFileName))
let $secondary :=doc(concat('/db/apps/terminology/claml/hierarchy/',$secondaryFileName))

let $primaryNotInSecondary :=
    for $class in $primary//Class
    return
        if (not($secondary//Class[@code=$class/@code])) then
            $class
        else()
        
        let $secondaryNotInPrimary :=
    for $class in $secondary//Class
    return
        if (not($primary//Class[@code=$class/@code])) then
            $class
        else()

return
$secondaryNotInPrimary
