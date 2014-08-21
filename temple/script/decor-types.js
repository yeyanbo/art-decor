var DecorObjectType = [{ "text" : "'DS'", "displayText" : "Data set" }, { "text" : "'DE'", "displayText" : "Data Element" }, { "text" : "'SC'",
"displayText" : "Scenario" }, { "text" : "'TR'", "displayText" : "Transaction" }, { "text" : "'AC'", "displayText" : "Actors" }, { "text" : "'VS'",
"displayText" : "Value Set" }, { "text" : "'IS'", "displayText" : "Issue" }, { "text" : "'RL'", "displayText" : "Rule" }, { "text" : "'TM'", "displayText" :
"Template" }, { "text" : "'CL'", "displayText" : "Concept list Konzeptliste" }, { "text" : "'EL'", "displayText" : "Template Element" }, { "text" : "'SX'",
"displayText" : "Test Scenario" }, { "text" : "'TX'", "displayText" : "Test Data Element" }, { "text" : "'EX'", "displayText" : "Example transaction" }, {
"text" : "'QX'", "displayText" : "Test requirements" }, { "text" : "'CM'", "displayText" : "Community" }, { "text" : "'CS'", "displayText" : "Code system"
}]

var DataSetTimeStampPrecision = [{ "text" : "'Y'", "displayText" : "at least year (YYYY)" }, { "text" : "'Y!'", "displayText" : "year (YYYY)" }, {
"text" : "'YM'", "displayText" : "at least month (MM) and year (YYYY)" }, { "text" : "'YM!'", "displayText" : "month (MM) and year (YYYY)" }, { "text" :
"'YMD'", "displayText" : "at least day (DD), month (MM) and year (YYYY)" }, { "text" : "'YMD!'", "displayText" : "day (DD), month (MM) and year (YYYY)" }, {
"text" : "'YMDHM'", "displayText" : "at least day (DD), month (MM) and year (YYYY), hour (hh) and minute (mm)" }]

var DataSetValueType = [{ "text" :
"'count'", "displayText" : "Count" }, { "text" : "'code'", "displayText" : "Code" }, { "text" : "'ordinal'", "displayText" : "Ordinal" }, { "text" :
"'identifier'", "displayText" : "Identifier" }, { "text" : "'string'", "displayText" : "String" }, { "text" : "'text'", "displayText" : "Text" }, { "text" :
"'date'", "displayText" : "Date" }, { "text" : "'datetime'", "displayText" : "Date+time" }, { "text" : "'complex'", "displayText" : "Collection of data" },
{ "text" : "'quantity'", "displayText" : "Quantity" }, { "text" : "'duration'", "displayText" : "Duration" }, { "text" : "'boolean'", "displayText" :
"Boolean" }, { "text" : "'blob'", "displayText" : "Binary" }, { "text" : "'decimal'", "displayText" : "Decimal number" }]

var DataSetConceptType = [{
"text" : "'group'", "displayText" : "Group" }, { "text" : "'item'", "displayText" : "Item" }]

var ProcessCode = [{ "text" : "'strict'", "displayText" :
"Strict" }, { "text" : "'lax'", "displayText" : "Lax" }]

var ItemStatusCodeLifeCycle = [{ "text" : "'new'", "displayText" : "New" }, { "text" :
"'draft'", "displayText" : "Draft" }, { "text" : "'final'", "displayText" : "Final" }, { "text" : "'rejected'", "displayText" : "Rejected" }, { "text" :
"'cancelled'", "displayText" : "Cancelled" }, { "text" : "'deprecated'", "displayText" : "Deprecated" }]

var TemplateStatusCodeLifeCycle = [{ "text" :
"'draft'", "displayText" : "Draft" }, { "text" : "'active'", "displayText" : "Active" }, { "text" : "'retired'", "displayText" : "Retired" }, { "text" :
"'inactive'", "displayText" : "inactive" }, { "text" : "'rejected'", "displayText" : "Rejected" }, { "text" : "'cancelled'", "displayText" : "Cancelled" },
{ "text" : "'update'", "displayText" : "Under update" }, { "text" : "'pending'", "displayText" : "Under pre-publication review" }, { "text" : "'review'",
"displayText" : "In Review" }]

var TransactionType = [{ "text" : "'group'", "displayText" : "Group" }, { "text" : "'initial'", "displayText" : "Initial"
}, { "text" : "'back'", "displayText" : "Back" }, { "text" : "'stationary'", "displayText" : "Stationary" }]

var ScenarioActorType = [{ "text" :
"'person'", "displayText" : "Person" }, { "text" : "'organization'", "displayText" : "Organization" }, { "text" : "'device'", "displayText" : "Device" }]

var ActorType = [{ "text" : "'sender'", "displayText" : "Sender" }, { "text" : "'receiver'", "displayText" : "Receiver" }, { "text" : "'stationary'",
"displayText" : "Stationary" }]

var NotifierOnOff = [{ "text" : "'on'", "displayText" : "Notifier on" }, { "text" : "'off'", "displayText" : "Notifier off" }]

var IssueType = [{ "text" : "'INC'", "displayText" : "Incident" }, { "text" : "'RFC'", "displayText" : "Change Request" }, { "text" : "'FUT'",
"displayText" : "For future consideration" }, { "text" : "'CLF'", "displayText" : "Request for Information/Education" }]

var IssuePriority = [{ "text" :
"'HH'", "displayText" : "Highest" }, { "text" : "'H'", "displayText" : "High" }, { "text" : "'N'", "displayText" : "Normal" }, { "text" : "'L'",
"displayText" : "Low" }, { "text" : "'LL'", "displayText" : "Lowest" }]

var IssueObjectType = [{ "text" : "'VS'", "displayText" : "Value Set" }, { "text"
: "'DE'", "displayText" : "Data Element" }, { "text" : "'TM'", "displayText" : "Template" }, { "text" : "'EL'", "displayText" : "Template Element" }, {
"text" : "'TR'", "displayText" : "Transaction" }, { "text" : "'DS'", "displayText" : "Data Set" }, { "text" : "'SC'", "displayText" : "Scenario" }, { "text"
: "'IS'", "displayText" : "Issue" }]

var IssueStatusCodeLifeCycle = [{ "text" : "'new'", "displayText" : "New" }, { "text" : "'open'", "displayText" :
"Open" }, { "text" : "'inprogress'", "displayText" : "In Progress" }, { "text" : "'feedback'", "displayText" : "Feedback needed" }, { "text" : "'closed'",
"displayText" : "Closed" }, { "text" : "'rejected'", "displayText" : "Rejected" }, { "text" : "'deferred'", "displayText" : "Deferred" }, { "text" :
"'cancelled'", "displayText" : "Cancelled" }]

var NullFlavorPattern = { "text" : "'nullFlavor'", "displayText" : null }

var VocabType = [{ "text" :
"'L'", "displayText" : null }, { "text" : "'A'", "displayText" : null }, { "text" : "'S'", "displayText" : null }, { "text" : "'D'", "displayText" : null
}]

var ConformanceType = [{ "text" : "'R'", "displayText" : "Required" }, { "text" : "'C'", "displayText" : "Conditional" }, { "text" : "'NP'",
"displayText" : "Not present" }]

var DesignationType = [{ "text" : "'preferred'", "displayText" : "preferred" }, { "text" : "'synonym'", "displayText" :
"synonym" }, { "text" : "'abbreviation'", "displayText" : "abbreviation" }]

var TemplateTypes = [{ "text" : "'cdadocumentlevel'", "displayText" : "CDA document level template" }, { "text" : "'cdaheaderlevel'", "displayText" : "CDA header level template" }, { "text" : "'cdasectionlevel'", "displayText" :
"CDA section level template" }, { "text" : "'cdaentrylevel'", "displayText" : "CDA entry level template" }, { "text" : "'messagelevel'", "displayText" :
"HL7 V3 message level template" }, { "text" : "'clinicalstatementlevel'", "displayText" : "HL7 V3 clinical statement level template" }, { "text" :
"'datatypelevel'", "displayText" : "HL7 V3 data type level template" }, { "text" : "'notype'", "displayText" : "Template type not specified" }]

var RelationshipTypes = [{ "text" : "'REPL'", "displayText" : "Replacement" }, { "text" : "'SPEC'", "displayText" : "Specialization" }, { "text" :
"'GEN'", "displayText" : "Generalization" }, { "text" : "'COPY'", "displayText" : "Copy" }, { "text" : "'ADAPT'", "displayText" : "Adaptation" }, { "text" :
"'EQUIV'", "displayText" : "Equivalent" }, { "text" : "'VERSION'", "displayText" : "Versie" }, { "text" : "'BACKWD'", "displayText" : "Backward Compatible"
}, { "text" : "'DRIV'", "displayText" : "Derived" }]

var TemplateFormats = { "text" : "'hl7v3xml1'", "displayText" : "Template format HL7 V3 XML ITS 1"}

var ExampleType = [{ "text" : "'error'", "displayText" : "error" }, { "text" : "'valid'", "displayText" : "valid" }, { "text" : "'neutral'",
"displayText" : "neutral" }]

var AssertRole = [{ "text" : "'fatal'", "displayText" : null }, { "text" : "'error'", "displayText" : null }, { "text" :
"'warning'", "displayText" : null }, { "text" : "'hint'", "displayText" : null }]

var SelfReferenceTemplateId = [{ "text" : "'*'", "displayText" : null}, { "text" : "'**'", "displayText" : null }]

var DynamicFlexibility = { "text" : "'dynamic'", "displayText" : null }