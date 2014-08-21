/*
*    Author: Marc de Graauw, derived from decor.xsd
*
*    This program is free software; you can redistribute it and/or modify it under the terms 
*    of the GNU General Public License as published by the Free Software Foundation; 
*    either version 3 of the License, or (at your option) any later version.
*    
*    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
*    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
*    See the GNU General Public License for more details.
*    
*    See http://www.gnu.org/licenses/gpl.html
*/
 var tags = {
    "!top": ["rules"],
    rules: {
        attrs: {},
        children: ["templateAssociation", "template"]
    },
    templateAssociation: {
        attrs: {
            templateId: baseIds,
            effectiveDate: effectiveDates
        },
        children: ["concept"]
    },
    concept: {
        attrs: {
            ref: projectConcepts,
            effectiveDate: effectiveDates,
            elementId: elementIds
        }
    },
    template: {
        attrs: {
            id: baseIds,
            name: null,
            displayName: null,
            effectiveDate: effectiveDates,
            statusCode: TemplateStatusCodeLifeCycle,
            isClosed: ["true", "false"]
        },
        children: ["desc", "classification", "relationship", "context", "item", "example", "publishingAuthority", "endorsingAuthority", "revisionHistory", "attribute", "choice", "element", "include"]
    },
    desc: {
        attrs: {
            language: languages
        }
    },
    classification: {
        attrs: {
            type: TemplateTypes
        },
        children: ["tag"]
    },
    relationship: {
        attrs: {
            type: RelationshipTypes,
            template: null,
            model: null,
            flexibility: null
        }
    },
    context: {
        attrs: {
            id: ["*", "**"],
            path: null
        }
    },
    let: {
        attrs: {
            name: null,
            value: null
        }
    },
    assert: {
        attrs: {
            role: ["fatal", "error", "warning", "hint"],
            test: null,
            see: null,
            flag: null
        }
    },
    report: {
        attrs: {
            role: ["fatal", "error", "warning", "hint"],
            test: null,
            see: null,
            flag: null
        }
    },
    defineVariable: {
        attrs: {
            name: null,
            path: null
        },
        children: ["code", "use"]
    },
    code: {
        attrs: {
            code: null,
            codeSystem: projectIds
        }
    },
    use: {
        attrs: {
            path: null,
            as: null
        }
    },
    element: {
        attrs: {
            name: null,
            cc: conformance_cardinality,
            id: elementIds,
            minimumMultiplicity: ["0", "1"],
            maximumMultiplicity: ["1", "*"],
            isMandatory: bool,
            conformance: ["R", "NP", "C"],
            datatype: ["AD", "ADXP", "ANY", "BIN", "BL", "BN", "BXIT_CD", "BXIT_IVL_PQ", "CD", "CE", "CO", "CR", "CS", "CV", "ED", "EIVL_PPD_TS", "EIVL_TS", "EN", "ENXP", "GLIST_PQ", "GLIST_TS", "HXIT_CE", "HXIT_PQ", "II", "INT", "IVL_INT", "IVL_MO", "IVL_PPD_PQ", "IVL_PPD_TS", "IVL_PQ", "IVL_REAL", "IVL_TS", "IVXB_INT", "IVXB_MO", "IVXB_PPD_PQ", "IVXB_PPD_TS", "IVXB_PQ", "IVXB_REAL", "IVXB_TS", "MO", "ON", "PIVL_PPD_TS", "PIVL_TS", "PN", "PPD_PQ", "PPD_TS", "PQ", "PQR", "QTY", "REAL", "RTO", "RTO_MO_PQ", "RTO_PQ_PQ", "RTO_QTY_QTY", "SC", "SLIST_PQ", "SLIST_TS", "ST", "SXCM_CD", "SXCM_INT", "SXCM_MO", "SXCM_PPD_PQ", "SXCM_PPD_TS", "SXCM_PQ", "SXCM_REAL", "SXCM_TS", "SXPR_TS", "TEL", "TN", "TS", "URL", "UVP_TS"],
            contains: projectTemplates
        },
        children: ["desc", "item", "example", "inherit", "vocabulary", "property", "text", "attribute", "let", "assert", "report", "defineVariable" ,"element", "choice", "include"]
    },
    attribute: {
        attrs: {
            as: attribute_shortcut,
            name: null,
            value: null,
            isOptional: bool,
            prohibited: bool,
            datatype: ["bin","bl","bn","int","oid","ruid","uuid","uid","real","set_cs","cs","st","ts"]
            /*classCode: null,
            moodCode: null,
            extension: null,
            root: null,
            typeCode: null,
            contextControlCode: null,
            operator: null,
            institutionSpecified: null,
            unit: null,
            determinerCode: null,
            contextConductionInd: bool,
            inversionInd: bool,
            independentInd: bool,
            negationInd: null,
            mediaType: null,
            representation: null,
            use: null,
            qualifier: null,
            nullFlavor: null,
            name: null,
            value: null,
            isOptional: bool,
            nullFlavor: ["NI", "UNK", "OTH"]*/
        },
        children: ["desc", "item", "vocabulary"]
    },
    property: {
        attrs: {
            unit: null,
            currency: null,
            minInclude: null,
            maxInclude: null,
            fractionDigits: null,
            minLength: null,
            maxLength: null,
            value: null
        }
    },
    vocabulary: {
        attrs: {
            code: null,
            codeSystem: projectIds,
            displayName: null,
            valueSet: projectValuesets,
            flexibility: null
        }
    },
    include: {
        attrs: { 
            ref: projectTemplates, 
            cc: conformance_cardinality,
            minimumMultiplicity: ["0", "1"],
            maximumMultiplicity: ["1", "*"],
            isMandatory: bool,
            conformance: ["R", "NP", "C"]
            },
        children: ["desc", "item","example","constraint"]
    },
    choice: {
        attrs: { 
            cc: cardinality,
            minimumMultiplicity: ["0", "1"],
            maximumMultiplicity: ["1", "*"]
        },
        children: ["desc", "item","element","include","choice"]
    }
};