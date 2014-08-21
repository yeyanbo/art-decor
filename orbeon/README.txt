Orbeon web archive for Art-Decor

Installation and configuration
1. Put art-decor.war in <TOMCAT_HOME>/webapps
2. Add the following Context to <TOMCAT_HOME>/conf/server.xml (below GlobalNamingResources)

<Context path="/art-decor" docBase="art-decor.war" reloadable="false" override="true" crossContext="true">
	<Parameter override="false" name="oxf.resources.priority.0" value="org.orbeon.oxf.resources.FilesystemResourceManagerFactory"/>
	<Parameter override="false" name="oxf.resources.priority.0.oxf.resources.filesystem.sandbox-directory" value="/resources"/>
</Context>

3. The database URLs are defined in two files:
   1. webapps/art-decor/WEB-INF/resources/config/properties-local.xml
   2. webapps/art-decor/WEB-INF/resources/page-flow.xml

   The default settings point to the default installation location/port of the eXist-db server.
   
   The relevant properties in properties-local.xml are:
   <property as="xs:anyURI" name="art.exist.url" value="http://localhost:8877/art"/>
   <property as="xs:anyURI" name="art.external.exist.url" value="http://localhost:8877/art"/>

   <property as="xs:anyURI" name="decor.exist.url" value="http://localhost:8877/decor"/>
   <property as="xs:anyURI" name="decor.external.exist.url" value="http://localhost:8877/decor"/>

   <property as="xs:anyURI" name="xis.exist.url" value="http://localhost:8877/xis"/>
   <property as="xs:anyURI" name="xis.external.exist.url" value="http://localhost:8877/xis"/>

   <property as="xs:anyURI" name="tools.exist.url" value="http://localhost:8877/tools"/>
   <property as="xs:anyURI" name="tools.external.exist.url" value="http://localhost:8877/tools"/>

   <property as="xs:anyURI" name="terminology.exist.url" value="http://localhost:8877/terminology"/>
   <property as="xs:anyURI" name="terminology.external.exist.url" value="http://localhost:8877/terminology"/>

   <property as="xs:anyURI" name="temple.exist.url" value="http://localhost:8877/temple"/>
   <property as="xs:anyURI" name="temple.external.exist.url" value="http://localhost:8877/temple"/>

   The URLs in properties local are used in xforms and the .external properties are also passed to the client. For the .external properties: to be accessible from another machine the URLs should be changed as localhost will not be reachable from other hosts.

   The relevant parts in page-flow.xml are:
   <page id="home" path-info="/home" view="http://localhost:8877/art/modules/get-form.xq?form=home"/>

   <page id="exist" path-info="/([^/]+)" matcher="oxf:perl5-matcher" 
      view="http://localhost:8877/art/modules/get-form.xq?form=${1}"  model="request.xpl"/>

   <page id="instance" path-info="/instance/([^/]*)" matcher="oxf:perl5-matcher"
      view="http://localhost:8877/art/modules/get-instance-xforms.xquery?id=${1}"/>
   
   <page id="transaction" path-info="/transaction/([^/]*)" matcher="oxf:perl5-matcher"
      view="http://localhost:8877/art/modules/get-transaction-xforms.xquery?id=${1}"/>
   
   <page id="scenario" path-info="/scenario/([^/]*)" matcher="oxf:perl5-matcher"
      view="http://localhost:8877/art/modules/get-scenario-xforms.xquery?id=${1}"/>
   
   <page id="test" path-info="/test/([^/]*)" matcher="oxf:perl5-matcher"
      view="http://localhost:8877/art/modules/get-instance-xforms.xquery?id=${1}&amp;type=test"/>
   
   <page id="template" path-info="/template/([^/]*)" matcher="oxf:perl5-matcher"
      view="http://localhost:8877/art/modules/get-template-xform.xquery?id=${1}"/>

   The URLs in the page-flow are only used by the Orbeon application, if the database is running on the same machine <localhost:port> can be used.