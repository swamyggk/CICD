/****************************** Environment variables ******************************/ 
def JobName									// variable to get jobname 
def Sonar_project_name							// varibale passed as SonarQube parameter while building the application
def robot_result_folder = ""				// variable used to store Robot Framework test results
def server = Artifactory.server 'server1'	// Artifactory server instance declaration. 'server1' is the Server ID given to Artifactory server in Jenkins
def buildInfo								// variable to store build info which is used by Artifactory
def rtMaven = Artifactory.newMavenBuild()	// creating an Artifactory Maven Build instance
def Reason = "JOB FAILED"					// variable to display the build failure reason
def lock_resource_name = ""							// variable for storing lock resource name

// Reading jar file name from pom.xml //
def getMavenBuildArtifactName() {
 pom = readMavenPom file: 'pom.xml'
 return "${pom.artifactId}-${pom.version}.${pom.packaging}"
}

// Email Notifications template when Build succeeds //
def notifySuccessful(){
emailext (
	attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
	<h1><FONT COLOR=Green>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1><h2 style=\'color:#e46c0a\'>GitHub Details</h2>
	<B>${BUILD_LOG_REGEX, regex="Started by ", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<br>
	${BUILD_LOG_REGEX, regex="Checking out Revision", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</B>
	<p><!-- ${SCRIPT, template="unit_test_results.groovy"} --></p>
	<p><br><br>${SCRIPT, template="sonarqube_template.groovy"}<br></p>
	<p><br><br><br><br><br><br><br><h2 style=\'color:#e46c0a; font-family: Candara;\'>Artifactory Details</h2>
	<b style=\'font-family: Candara;\'>${BUILD_LOG_REGEX, regex="http://padlcicdggk4.sw.fortna.net:8088/artifactory/webapp/*", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<b></p>
	<p><br><br>${SCRIPT, template="robotframework_template.groovy"}</p>
	<p><br><br><br><br><br><br><br><h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br><h3>Please find below, the build logs and other files.</h3></p>
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'sunil.boga@ggktech.com'
	)
}

// Email Notifications template when Build fails //
def notifyFailure(def Reason){
println "Failed Reason: ${Reason}"
emailext (
	attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
	<h1><FONT COLOR=red>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1>
  	<h1>${BUILD_LOG_REGEX, regex="Failed Reason:", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</h1>
	<p><h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br><h3>Please find below, the build logs and other files.</h3></p>
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'sunil.boga@ggktech.com, sneha.kailasa@ggktech.com'
	)
}

/****************************** Jenkinsfile execution starts here ******************************/
node {
	def content = readFile './.env'				// variable to store .env file contents
	Properties properties = new Properties()	// creating an object for Properties class
	InputStream contents = new ByteArrayInputStream(content.getBytes());	// storing the contents
	properties.load(contents)	
	contents = null
	try {
/****************************** Git Checkout Stage ******************************/
		stage ('Checkout') {
			Reason = "GIT Checkout Failed"
			checkout scm				
		}
	/*************** Building the application ***************/
	stage ('Maven Build') {
	
		//Downloading dependencies
		//rtMaven.resolver server: server, releaseRepo: 'fortna_release', snapshotRepo: 'fortna_snapshot'
		
		//Deploying artifacts to this repo
		rtMaven.deployer server: server, snapshotRepo: 'fortna_snapshot', releaseRepo: 'fortna_release'
		
		//Disabling artifacts deployment to Artifactory
		rtMaven.deployer.deployArtifacts = false	//this will not publish artifacts soon after build succeeds
		
		//Defining maven tool 
		rtMaven.tool = 'maven'
		
		/*************** Build Step ***************/
	//	withSonarQubeEnv {
			def mvn_version = tool 'maven'
			echo "${mvn_version}"
			withEnv( ["PATH+MAVEN=${mvn_version}/bin"] ) {
				buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true'// $SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.projectKey="$JOB_NAME" -Dsonar.projectName="$JOB_NAME"'
			}
		//}
	}
	
	/*************** Robot Frame work results ***************/
	stage ('Docker Deploy and RFW') {
	/*******Locking Resource ********/
		lock('Compose-resource-lock') {
		/*************** Docker Compose ***************/
		sh ''' username=${BRANCH_NAME} /usr/local/bin/docker-compose up -d
			./clean_up.sh'''
			robot_result_folder = properties.robot_result_folder
			step([$class: 'RobotPublisher',
				outputPath: "/home/robot/${robot_result_folder}",
				passThreshold: 0,
				unstableThreshold: 0,
				otherFiles: ""])
		}
	}
	
	/*************** Pushing the artifacts***************
	stage ('Artifacts Deployment'){		
		/*************** Publishing buildInfo to Artifactory ***************
		rtMaven.deployer.deployArtifacts buildInfo	//this should be disabled when depoyArtifacts is set to false. Otherwise, this will publish the Artifacts.
		server.publishBuildInfo buildInfo
	}
	
	/*************** Build Promotion Section ***************
    stage ('Build Promotions') {
		def promotionConfig = [
			// Mandatory parameters
			'buildName'          : buildInfo.name,
			'buildNumber'        : buildInfo.number,
			'targetRepo'         : 'fortna_release',
 
			// Optional parameters
			'comment'            : 'PROMOTION SUCCESSFULLY COMPLETED',
			'sourceRepo'         : 'fortna_snapshot',
			'status'             : 'Released',
			'includeDependencies': false,
			'copy'               : false,
			'failFast'           : true
		]
 
		// Promote build
		Artifactory.addInteractivePromotion server: server, promotionConfig: promotionConfig, displayName: "Promotions Time" //this need human interaction to promote
	}
	
	stage ('Reports creation') {
		sh '''sleep 15s
		curl "http://10.240.17.12:9000/sonar/api/resources?resource=$JOB_NAME&metrics=bugs,vulnerabilities,code_smells,duplicated_blocks" > output.json
		sleep 10s'''
	} */
	
	stage ('Email Notifications') {
		notifySuccessful() 
	}
}
	catch(Exception e)
	{
		currentBuild.result = "FAILURE"
		notifyFailure(Reason)
		sh 'exit 1'
	}
}
