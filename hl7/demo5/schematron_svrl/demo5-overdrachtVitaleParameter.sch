<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title> Schematron file for POCD_MT000040 - Transfer vital signs data </title>
   <ns uri="urn:hl7-org:v3" prefix="hl7"/>
   <ns uri="urn:hl7-org:v3" prefix="cda"/>
   <ns uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
   <!-- Add extra namespaces -->
   <ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
   <ns uri="http://www.w3.org/XML/1998/namespace" prefix="xml"/>
   <!-- Include realm specific schematron -->
   <!-- Include datatype abstract schematrons -->
   <pattern>
      <include href="include/DTr1_ANY.sch"/>
      <include href="include/DTr1_AD.sch"/>
      <include href="include/DTr1_AD.NL.sch"/>
      <include href="include/DTr1_AD.DE.sch"/>
      <include href="include/DTr1_AD.EPSOS.sch"/>
      <include href="include/DTr1_BIN.sch"/>
      <include href="include/DTr1_ED.sch"/>
      <include href="include/DTr1_ST.sch"/>
      <include href="include/DTr1_SC.sch"/>
      <include href="include/DTr1_ENXP.sch"/>
      <include href="include/DTr1_ADXP.sch"/>
      <include href="include/DTr1_thumbnail.sch"/>
      <include href="include/DTr1_BL.sch"/>
      <include href="include/DTr1_BN.sch"/>
      <include href="include/DTr1_CD.sch"/>
      <include href="include/DTr1_CE.sch"/>
      <include href="include/DTr1_CV.sch"/>
      <include href="include/DTr1_CO.sch"/>
      <include href="include/DTr1_CO.EPSOS.sch"/>
      <include href="include/DTr1_PQR.sch"/>
      <include href="include/DTr1_CV.EPSOS.sch"/>
      <include href="include/DTr1_EIVL.event.sch"/>
      <include href="include/DTr1_CE.EPSOS.sch"/>
      <include href="include/DTr1_CD.EPSOS.sch"/>
      <include href="include/DTr1_CR.sch"/>
      <include href="include/DTr1_CS.sch"/>
      <include href="include/DTr1_CS.LANG.sch"/>
      <include href="include/DTr1_EN.sch"/>
      <include href="include/DTr1_ON.sch"/>
      <include href="include/DTr1_PN.sch"/>
      <include href="include/DTr1_TN.sch"/>
      <include href="include/DTr1_II.sch"/>
      <include href="include/DTr1_II.NL.BSN.sch"/>
      <include href="include/DTr1_II.NL.URA.sch"/>
      <include href="include/DTr1_II.NL.UZI.sch"/>
      <include href="include/DTr1_II.NL.AGB.sch"/>
      <include href="include/DTr1_II.AT.DVR.sch"/>
      <include href="include/DTr1_II.AT.ATU.sch"/>
      <include href="include/DTr1_II.AT.BLZ.sch"/>
      <include href="include/DTr1_II.AT.KTONR.sch"/>
      <include href="include/DTr1_II.EPSOS.sch"/>
      <include href="include/DTr1_QTY.sch"/>
      <include href="include/DTr1_INT.sch"/>
      <include href="include/DTr1_IVXB_INT.sch"/>
      <include href="include/DTr1_SXCM_INT.sch"/>
      <include href="include/DTr1_IVL_INT.sch"/>
      <include href="include/DTr1_INT.NONNEG.sch"/>
      <include href="include/DTr1_INT.POS.sch"/>
      <include href="include/DTr1_MO.sch"/>
      <include href="include/DTr1_IVXB_MO.sch"/>
      <include href="include/DTr1_SXCM_MO.sch"/>
      <include href="include/DTr1_IVL_MO.sch"/>
      <include href="include/DTr1_PQ.sch"/>
      <include href="include/DTr1_IVXB_PQ.sch"/>
      <include href="include/DTr1_SXCM_PQ.sch"/>
      <include href="include/DTr1_IVL_PQ.sch"/>
      <include href="include/DTr1_REAL.sch"/>
      <include href="include/DTr1_IVXB_REAL.sch"/>
      <include href="include/DTr1_SXCM_REAL.sch"/>
      <include href="include/DTr1_IVL_REAL.sch"/>
      <include href="include/DTr1_REAL.NONNEG.sch"/>
      <include href="include/DTr1_REAL.POS.sch"/>
      <include href="include/DTr1_TS.sch"/>
      <include href="include/DTr1_IVXB_TS.sch"/>
      <include href="include/DTr1_SXCM_TS.sch"/>
      <include href="include/DTr1_IVL_TS.sch"/>
      <include href="include/DTr1_IVL_TS.EPSOS.TZ.sch"/>
      <include href="include/DTr1_IVL_TS.EPSOS.TZ.OPT.sch"/>
      <include href="include/DTr1_PIVL_TS.sch"/>
      <include href="include/DTr1_EIVL_TS.sch"/>
      <include href="include/DTr1_SXPR_TS.sch"/>
      <include href="include/DTr1_TS.DATE.sch"/>
      <include href="include/DTr1_TS.DATE.FULL.sch"/>
      <include href="include/DTr1_TS.DATE.MIN.sch"/>
      <include href="include/DTr1_TS.DATETIME.MIN.sch"/>
      <include href="include/DTr1_TS.EPSOS.TZ.sch"/>
      <include href="include/DTr1_TS.EPSOS.TZ.OPT.sch"/>
      <include href="include/DTr1_RTO_PQ_PQ.sch"/>
      <include href="include/DTr1_RTO_QTY_QTY.sch"/>
      <include href="include/DTr1_RTO.sch"/>
      <include href="include/DTr1_SD.TEXT.sch"/>
      <include href="include/DTr1_URL.sch"/>
      <include href="include/DTr1_TEL.sch"/>
      <include href="include/DTr1_TEL.AT.sch"/>
      <include href="include/DTr1_TEL.EPSOS.sch"/>
      <include href="include/DTr1_URL.NL.EXTENDED.sch"/>
   </pattern>

   <!-- Include the project schematrons related to scenario overdrachtVitaleParameter -->

   <!-- VitalSignsCDAdocument -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.1-2014-07-08T000000.sch"/>

   <!-- Include schematrons from templates with explicit * or ** context (but no representing templates), only those used in scenario template -->



   <!-- includes -->
   <!-- VitalSignObservation -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.115-2013-12-19T000000.sch"/>
   <!-- RespiratoryRate -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.116-2013-12-19T000000.sch"/>
   <!-- BodyWeight -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.117-2013-12-19T000000.sch"/>
   <!-- HeartRate -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.118-2013-12-19T000000.sch"/>
   <!-- BodyHeight -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.119-2013-12-19T000000.sch"/>
   <!-- HeartRatePeripheral -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.125-2013-12-19T000000.sch"/>
   <!-- BodyTemperature -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.126-2013-12-19T000000.sch"/>
   <!-- OxygenSaturation -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.127-2013-12-19T000000.sch"/>
   <!-- BloodPressure -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.128-2013-12-30T000000.sch"/>
   <!-- SystolicBloodPressure -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.129-2013-12-30T000000.sch"/>
   <!-- DiastolicBloodPressure -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.130-2013-12-30T000000.sch"/>
   <!-- MeanBloodPressure -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.131-2013-12-30T000000.sch"/>
   <!-- VitalSignsSection -->
   <include href="include/2.16.840.1.113883.3.1937.99.60.5.10.3001-2014-07-08T000000.sch"/>

</schema>
