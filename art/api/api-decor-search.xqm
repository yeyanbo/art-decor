xquery version "1.0";
(:~
:   Copyright (C) 2013-2014 ART-DECOR expert group art-decor.org
:   
:   Author: Alexander Henket, Marc de Graauw
:   
:   This program is free software; you can redistribute it and/or modify it under the terms of the
:   GNU Lesser General Public License as published by the Free Software Foundation; either version
:   2.1 of the License, or (at your option) any later version.
:   
:   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
:   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
:   See the GNU Lesser General Public License for more details.
:   
:   The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
:
:)
module namespace adsearch       = "http://art-decor.org/ns/decor/search";

import module namespace get     = "http://art-decor.org/ns/art-decor-settings" at "../modules/art-decor-settings.xqm";
import module namespace art     = "http://art-decor.org/ns/art" at "../modules/art-decor.xqm";
import module namespace vs      = "http://art-decor.org/ns/decor/valueset" at "api-decor-valueset.xqm";
import module namespace templ   = "http://art-decor.org/ns/decor/template" at "api-decor-template.xqm";

(:~
:   All functions support their own override, but this is the fallback for the maximum number of results returned on a search
:)
declare variable $adsearch:maxResults := xs:integer('50');

(:~
:   Returns lucene config xml for a sequence of strings. The search will find yield results that match all terms+trailing wildcard in the sequence
:   Example output:
:   <query>
:       <bool>
:           <wildcard occur="must">term1*</wildcard>
:           <wildcard occur="must">term2*</wildcard>
:       </bool>
:   </query>
:
:   @param $searchTerms required sequence of terms to look for
:   @return lucene config
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:getSimpleLuceneQuery($searchTerms as xs:string+) as element() {
    <query>
        <bool>{
            for $term in $searchTerms
            return
                <wildcard occur="must">{concat($term,'*')}</wildcard>
        }</bool>
    </query>
};

(:~
:   Returns lucene options xml that instruct filter-rewrite=yes
:)
declare function adsearch:getSimpleLuceneOptions() as element() {
    <options>
        <filter-rewrite>yes</filter-rewrite>
    </options>
};

(:~
:   Returns all code systems optionally filtered on project/id|ref/name. 
:   Code systems carry only attributes  and their normal name elements (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the value set is in
:   Example output:
:   <result current="3" total="3">
:       <codeSystem project="peri20-" name="EthnicGroup" displayName="EthnicGroup" effectiveDate="2009-10-01T00:00:00" id="2.16.840.1.113883.2.4.11.3" statusCode="final"/>
:       <codeSystem project="peri20-" id="2.16.840.1.113883.2.4.11.3" effectiveDate="2013-01-10T12:51:30" name="EthnicGroup" displayName="EthnicGroup" statusCode="final"/>
:       <codeSystem project="peri20-" id="2.16.840.1.113883.2.4.11.3" effectiveDate="2014-05-19T14:35:30" statusCode="draft" name="EthnicGroup" displayName="EthnicGroup"/>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchCodesystem($projectPrefix as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
    let $luceneOptions  := adsearch:getSimpleLuceneOptions()
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//codeSystem[ancestor::decor[@repository='true'][not(@private='true')]]) 
        else ($get:colDecorData//codeSystem[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        :=
        if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
            $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))] | $decorObjects[ends-with(@ref,concat('.',$searchTerms[1]))]
        else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
            $decorObjects[@id=$searchTerms[1]] | $decorObjects[@ref=$searchTerms[1]]
        else (
            $decorObjects[ft:query(@name,$luceneQuery) or ft:query(@displayName,$luceneQuery,$luceneOptions)]
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project)
        }
    }
    </result>
};

(:~
:   Returns matching concepts based on id/name and optionally type. Concepts that inherit do not have names so in order 
:   to find those we first match all concepts in repositories and (if supplied) within the project that the supplied 
:   dataset-id is in. With that result we recursively find all concepts that inherit from the resultset.
:   Concepts carry only attributes and their normal name elements (whatever was available in the db). However to pin 
:   point them back to where they belong in ART, they also carry these attributes: 
:   @uuid - UUID
:   @datasetId / @datasetName - Dataset-id and name (first found name) the concept is in
:   @project / @projectName - Project prefix and name (first found name) the concept is in
:   @repository / @private - Project attributes of the project the concept is in
:   Example output:
:   <result current="50" total="271">
:       <concept uuid="7b5d95b7-f821-471e-9758-acdeac358775" datasetId="1.2.3.4" datasetName="Dataset 4" project="pfx-" projectName="Project name" repository="false" private="false" id="1.2.4.4" effectiveDate="2012-08-06T00:00:00" statusCode="final" type="group">
:           <name language="en-US">English concept name</name>
:           <name language="nl-NL">Nederlandse conceptnaam</name>
:       </concept>
:   ...
:   </result>
:
:   @param $prefix optional DECOR project prefix
:   @param $datasetId optional DECOR full dataset id
:   @param $conceptType optional DECOR 
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @param $originalConceptsOnly required returns original concepts (that do not inherit) if true, otherwise returns every hit including concepts that inherit from matching concepts
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchConcept($prefix as xs:string?, $datasetId as xs:string?, $conceptType as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?, $originalConceptsOnly as xs:boolean) as element(result) {
    let $maxResults         := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $luceneQuery        := adsearch:getSimpleLuceneQuery($searchTerms)
    let $queryOnId          := 
        if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then concat('\.',$searchTerms[1],'$') else ()
    
    let $resultsOnId        := 
        if (not(empty($queryOnId))) then 
            ($get:colDecorData//concept[matches(@id,$queryOnId)][ancestor::decor[@repository='true'][not(@private='true')]][not(parent::conceptList)][not(ancestor::history)] |
             $get:colDecorData//concept[matches(@id,$queryOnId)][ancestor::datasets/dataset/@id=$datasetId][not(parent::conceptList)][not(ancestor::history)])
        else ()
    
    let $resultsOnName      :=
        if (empty($prefix)) then
            if (empty($conceptType)) then
                ($get:colDecorData//concept[ft:query((name|synonym),$luceneQuery)][ancestor::decor[@repository='true'][not(@private='true')]][ancestor::datasets][not(parent::conceptList)][not(ancestor::history)])
            else (
                ($get:colDecorData//concept[ft:query((name|synonym),$luceneQuery)][ancestor::decor[@repository='true'][not(@private='true')]][ancestor::datasets][not(parent::conceptList)][not(ancestor::history)][@type=$conceptType])
            )
        else (
            if (empty($conceptType)) then
                ($get:colDecorData//concept[ft:query((name|synonym),$luceneQuery)][ancestor::decor[@repository='true'][not(@private='true')] or ancestor::decor/project/@prefix=$prefix][ancestor::datasets][not(parent::conceptList)][not(ancestor::history)])
            else (
                ($get:colDecorData//concept[ft:query((name|synonym),$luceneQuery)][ancestor::decor[@repository='true'][not(@private='true')] or ancestor::decor/project/@prefix=$prefix][ancestor::datasets][not(parent::conceptList)][not(ancestor::history)][@type=$conceptType])
            )
        )
    
    let $allResults         := 
        if ($originalConceptsOnly) then (
            ($resultsOnName | $resultsOnId)[not(inherit)]
        )
        else (
            for $concept in ($resultsOnName | $resultsOnId) 
            return 
                local:getConceptsThatInheritFromConcept($concept,())
        )

    let $resultsFiltered    := 
        if ($datasetId) then $allResults[(ancestor::dataset/@id|@datasetId)=$datasetId] else $allResults

    let $count              := count($allResults)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $concepts in subsequence($resultsFiltered,1,$maxResults)
        group by $conceptId := concat($concepts/@id,$concepts/@effectiveDate)
        order by ($concepts/name)[1]
        return
            let $ancestorProject    := $concepts[1]/ancestor::decor
            return
            element {$concepts[1]/local-name()} {
                attribute uuid {util:uuid()},
                attribute conceptId {$concepts[1]/@id},
                if ($ancestorProject) then (
                    attribute datasetId     {$concepts[1]/ancestor::dataset/@id},  
                    attribute datasetName   {$concepts[1]/ancestor::dataset/name[1]}, 
                    attribute project       {$ancestorProject/project/@prefix},
                    attribute projectName   {$ancestorProject/project/name[1]},
                    attribute repository    {$ancestorProject/@repository='true'},
                    attribute private       {$ancestorProject/@private='true'}
                )
                else (
                    $concepts[1]/@datasetId,
                    $concepts[1]/@datasetName,
                    $concepts[1]/@project,
                    $concepts[1]/@projectName,
                    $concepts[1]/@repository,
                    $concepts[1]/@private
                ),
                $concepts[1]/(@* except (@uuid|@id|@conceptId|@datasetId|@datasetName|@project|@projectName|@repository|@private)),
                $concepts[1]/name,
                $concepts[1]/inherit
            }
    }
    </result>
};

(:~
:   Returns all datasets optionally filtered on project/id/name. 
:   Dataset carry only attributes and their normal name elements (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the dataset is in
:   Example output:
:   <result current="5" total="5">
:       <dataset project="peri20-" id="2.16.840.1.113883.2.4.3.11.60.90.77.1.1" effectiveDate="2009-10-01T00:00:00" statusCode="final">
:           <name language="nl-NL">Spirit dataset 1a</name>
:       </dataset>
:       <dataset project="peri20-" id="2.16.840.1.113883.2.4.3.11.60.90.77.1.2" effectiveDate="2011-01-28T00:00:00" statusCode="final">
:           <name language="nl-NL">Spirit dataset 1c</name>
:       </dataset>
:   ...
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchDataset($projectPrefix as xs:string?, $searchTerms as xs:string*, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//dataset[ancestor::decor[@repository='true'][not(@private='true')]]) 
        else ($get:colDecorData//dataset[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        := 
        if (count($searchTerms)=0) then 
            $decorObjects
        else (
            let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
            let $luceneOptions  := adsearch:getSimpleLuceneOptions()
            return
            if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
                $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))]
            else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
                $decorObjects[@id=$searchTerms[1]]
            else (
                $decorObjects[ft:query(name,$luceneQuery,$luceneOptions)]
            )
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project),
            $object/name
        }
    }
    </result>
};

(:~
:   Returns all issues optionally filtered on project/id/name. 
:   Issues carry only attributes (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the issue is in
:   Example output:
:   <result current="10" total="531">
:       <issue project="peri20-" id="2.16.840.1.113883.2.4.3.11.60.90.77.6.1" displayName="Care Provision ID" type="RFC"/>
:   ...
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms optional sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchIssue($projectPrefix as xs:string?, $searchTerms as xs:string*, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//issue[ancestor::decor[not(@private='true')]]) 
        else ($get:colDecorData//issue[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        := 
        if (count($searchTerms)=0) then 
            $decorObjects
        else (
            let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
            let $luceneOptions  := adsearch:getSimpleLuceneOptions()
            return
            if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
                $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))]
            else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
                $decorObjects[@id=$searchTerms[1]]
            else (
                $decorObjects[ft:query(@displayName,$luceneQuery,$luceneOptions) or ft:query(*/desc,$luceneQuery,$luceneOptions)]
            )
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project)
        }
    }
    </result>
};

(:~
:   Returns all templates optionally filtered on project/id/name. 
:   Templates carry only attributes (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the template is in
:   Example output:
:   <result current="1" total="1">
:       <template project="peri20-" id="2.16.840.1.113883.2.4.6.10.90.900853" name="Ethnicgroup" displayName="Ethnic group" effectiveDate="2012-06-26T00:00:00" statusCode="draft"/>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:   @see adsearch:searchTemplate($projectPrefix as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?, $version as xs:string?)
:)
declare function adsearch:searchTemplate($projectPrefix as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?) as element(result) {
    adsearch:searchTemplate($projectPrefix, $searchTerms, $maxResults, ())
};

(:~
:   Returns all templates optionally filtered on project/id/name. 
:   Templates carry only attributes (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the template is in
:   Example output:
:   <result current="1" total="1">
:       <template project="peri20-" id="2.16.840.1.113883.2.4.6.10.90.900853" name="Ethnicgroup" displayName="Ethnic group" effectiveDate="2012-06-26T00:00:00" statusCode="draft"/>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @param $version optional. Go to some archived release. Defaults to active data
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchTemplate($projectPrefix as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?, $version as xs:string?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $decorObjects   := 
        if (empty($projectPrefix)) then (
            if (empty($version)) then (
                $get:colDecorData//rules[ancestor::decor[@repository='true'][not(@private='true')]]
             ) else (
                collection($get:strDecorVersion)//rules[ancestor::decor[@versionDate=$version][@repository='true'][not(@private='true')]]
             )
        ) else (
            if (empty($version)) then (
                $get:colDecorData//rules[ancestor::decor/project/@prefix=$projectPrefix]
            ) else (
                collection($get:strDecorVersion)//rules[ancestor::decor[@versionDate=$version][project/@prefix=$projectPrefix]]
            )
        )
    
return
    adsearch:searchTemplatesInRuleSet($searchTerms, $decorObjects, $maxResults)
};

declare function adsearch:searchTemplatesInRuleSet($searchTerms as xs:string+, $ruleSet as element()*, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
    let $luceneOptions  := adsearch:getSimpleLuceneOptions()
            
    let $results        := 
        if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
            $ruleSet/template[ends-with(@id,concat('.',$searchTerms[1]))] | $ruleSet/template[ends-with(@ref,concat('.',$searchTerms[1]))]
        else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
            $ruleSet/template[@id=$searchTerms[1]] | $ruleSet/template[@ref=$searchTerms[1]]
        else (
            $ruleSet/template[ft:query(@name,$luceneQuery,$luceneOptions) or ft:query(@displayName,$luceneQuery,$luceneOptions)]
        )
    let $resultsById    := (
            $results[@id],
            for $template in $results[@ref]
            return 
            templ:getTemplateById($template/@ref,(),$template/ancestor::decor/project/@prefix)/*/template[@url]
        )
        
    let $count := count($resultsById)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($resultsById,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix | $object/@ident}, 
            $object/(@* except @project),
            attribute sortname {if (string-length($object/@displayName)>0) then $object/@displayName else $object/@name},
            $object/name,
            art:serializeDescriptionNodes($object/desc)/*,
            $object/classification
        }
    }
    </result>
};

(:~
:   Returns all scenarios optionally filtered on project/id/name. 
:   Scenarios carry only attributes  and their normal name elements (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the scenario is in
:   Example output:
:   <result current="1" total="1">
:       <scenario project="peri20-" id="2.16.840.1.113883.2.4.3.11.60.90.77.3.1" effectiveDate="2011-01-28T00:00:00" statusCode="final">
:           <name language="nl-NL">Start Zorg bericht</name>
:       </scenario>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchScenario($projectPrefix as xs:string?, $searchTerms as xs:string*, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//scenario[ancestor::decor[@repository='true'][not(@private='true')]]) 
        else ($get:colDecorData//scenario[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        := 
        if (count($searchTerms)=0) then 
            $decorObjects
        else (
            let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
            let $luceneOptions  := adsearch:getSimpleLuceneOptions()
            return
            if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
                $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))]
            else (
                $decorObjects[ft:query(name,$luceneQuery,$luceneOptions)]
            )
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project),
            $object/name
        }
    }
    </result>
};

(:~
:   Returns all transactions optionally filtered on project/id/name. 
:   Transactions carry only attributes  and their normal name elements (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the transaction is in
:   Example output:
:   <result current="1" total="1">
:       <transaction project="peri20-" type="group" id="2.16.840.1.113883.2.4.3.11.60.90.77.4.1" effectiveDate="2011-01-28T00:00:00" statusCode="final">
:           <name language="nl-NL">Berichten Start Zorg fase 1a naar registraties</name>
:       </transaction>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchTransaction($projectPrefix as xs:string?, $searchTerms as xs:string*, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//transaction[ancestor::decor[@repository='true'][not(@private='true')]]) 
        else ($get:colDecorData//transaction[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        := 
        if (count($searchTerms)=0) then 
            $decorObjects
        else (
            let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
            let $luceneOptions  := adsearch:getSimpleLuceneOptions()
            return
            if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
                $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))]
            else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
                $decorObjects[@id=$searchTerms[1]]
            else (
                $decorObjects[ft:query(name,$luceneQuery,$luceneOptions)]
            )
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project),
            $object/name
        }
    }
    </result>
};

(:~
:   Returns all value sets optionally filtered on project/id|ref/name. 
:   Value sets carry only attributes  and their normal name elements (whatever was available in the db). 
:   To pin point them back to where they belong in ART, they also carry these attributes: 
:   @project - Project prefix the value set is in
:   Example output:
:   <result current="3" total="3">
:       <valueSet project="peri20-" name="EthnicGroup" displayName="EthnicGroup" effectiveDate="2009-10-01T00:00:00" id="2.16.840.1.113883.2.4.11.3" statusCode="final"/>
:       <valueSet project="peri20-" id="2.16.840.1.113883.2.4.11.3" effectiveDate="2013-01-10T12:51:30" name="EthnicGroup" displayName="EthnicGroup" statusCode="final"/>
:       <valueSet project="peri20-" id="2.16.840.1.113883.2.4.11.3" effectiveDate="2014-05-19T14:35:30" statusCode="draft" name="EthnicGroup" displayName="EthnicGroup"/>
:   </result>
:
:   @param $projectPrefix optional DECOR project prefix to search in
:   @param $searchTerms required sequence of terms to look for
:   @param $maxResults optional maximum number of results to return, defaults to $adsearch:maxResults
:   @return resultset with max $maxResults results
:   @author Alexander Henket
:   @since 2014-06-06
:)
declare function adsearch:searchValueset($projectPrefix as xs:string?, $searchTerms as xs:string+, $maxResults as xs:integer?) as element(result) {
    let $maxResults     := if ($maxResults) then $maxResults else $adsearch:maxResults
    
    let $luceneQuery    := adsearch:getSimpleLuceneQuery($searchTerms)
    let $luceneOptions  := adsearch:getSimpleLuceneOptions()
    
    let $decorObjects   := 
        if (string-length($projectPrefix)=0) 
        then ($get:colDecorData//valueSet[ancestor::decor[@repository='true'][not(@private='true')]]) 
        else ($get:colDecorData//valueSet[ancestor::decor/project/@prefix=$projectPrefix])
    
    let $results        :=
        if (count($searchTerms)=1 and matches($searchTerms[1],'^\d+$')) then
            $decorObjects[ends-with(@id,concat('.',$searchTerms[1]))] | $decorObjects[ends-with(@ref,concat('.',$searchTerms[1]))]
        else if (count($searchTerms)=1 and matches($searchTerms[1],'^[0-2](\.(0|[1-9][0-9]*))*$')) then
            $decorObjects[@id=$searchTerms[1]] | $decorObjects[@ref=$searchTerms[1]]
        else (
            $decorObjects[ft:query(@name,$luceneQuery) or ft:query(@displayName,$luceneQuery,$luceneOptions)]
        )
    
    let $count := count($results)
    
return
    <result current="{if ($count<=$maxResults) then $count else $maxResults}" total="{$count}">
    {
        for $object in subsequence($results,1,$maxResults)
        return 
        element {$object/local-name()} {
            attribute project {$object/ancestor::decor/project/@prefix}, 
            $object/(@* except @project)
        }
    }
    </result>
};

(:~
:   Internal helper function that recursively finds concepts inheriting from the current concept
:)
declare function local:getConceptsThatInheritFromConcept($concept as element(concept), $results as element(concept)*) as item()* {
    let $currentResult :=
        for $currentResultConcept in $get:colDecorData//concept[inherit/@ref=$concept/@id][inherit/@effectiveDate=$concept/@effectiveDate][not(ancestor::history)]
        let $currentResultConceptWithName :=
            element {$currentResultConcept/name()} {
                attribute id            {$currentResultConcept/@id}, 
                attribute effectiveDate {$currentResultConcept/@effectiveDate},
                attribute statusCode    {$currentResultConcept/@statusCode},
                attribute type          {$concept/@type},
                attribute datasetId     {$currentResultConcept/ancestor::dataset/@id},
                attribute datasetName   {$currentResultConcept/ancestor::dataset/name[1]},
                attribute project       {$currentResultConcept/ancestor::decor/project/@prefix},
                attribute projectName   {$currentResultConcept/ancestor::decor/project/name[1]},
                attribute repository    {$currentResultConcept/ancestor::decor/@repository='true'},
                attribute private       {$currentResultConcept/ancestor::decor/@private='true'},
                $concept/name, 
                $currentResultConcept/inherit
            }
        return
            local:getConceptsThatInheritFromConcept($currentResultConceptWithName,$results)
    
    return $concept | $results | $currentResult
};