/************************ Environment Variables **************************/
//Artifactory server instance declaration	
def server = Artifactory.server 'art1' //art1 is the Server ID given to Artifactory server in Jenkins

//buildInfo variable
def buildInfo = 'null'



/******************** Notifying SUCCESSFUL buildInfo **********************/
def notifySuccessful(){
emailext (
	attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<!-- BUILD SUCCESS-->
	<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
	<h1><FONT COLOR=Green>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1>
	<h2 style=\'color:#e46c0a\'>GitHub Details</h2>
	<B>${BUILD_LOG_REGEX, regex="Started by ", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<br>
	${BUILD_LOG_REGEX, regex="Checking out Revision", linesBefore=0, linesAfter=1, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</B>
	<p>
		<!-- Unit Test Details -->
		${SCRIPT, template="unit_test_results.groovy"}
	</p>
	<p>
		<br><br><br><br><br><br><br><br><br><br><br><br><br>
		<!-- Sonarqube Analysis Details -->
		${SCRIPT, template="sonarqube_template.groovy"}
		<br>
	</p>
	<p>
		<br><br><br><br><br><br><br> <!-- Artifactory Details -->
		<h2 style=\'color:#e46c0a; font-family: Candara;\'>Artifactory Details</h2>
		<b style=\'font-family: Candara;\'>${BUILD_LOG_REGEX, regex="http://padlcicdggk4.sw.fortna.net:8088/artifactory/webapp/*", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}<b>
		<br>
	</p>
	<p>
		<br><br><!-- Robot Framework Details> -->
		<b>${SCRIPT, template="robotframework_template.groovy"}
	</p>
	<p>
		<h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br>
		<h3>Please find below, the build logs and other files.</h3>
	</p>
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'yerriswamy.konanki@ggktech.com, sunil.boga@ggktech.com'
)
}

node {

	/*************** Git Checkout ***************/
	stage ('Checkout') {
	checkout scm	
	}

	/*************** Building the application and Deploying/Downloading Artifacts to/from Artifactory ***************/
	stage ('Build and Deploy Artifacts') {
		
		//Creating an Artifactory Maven Build instance
		def rtMaven = Artifactory.newMavenBuild()
		
		//Downloading dependencies
		//rtMaven.resolver server: server, releaseRepo: 'fortna_release', snapshotRepo: 'fortna_snapshot'
		
		//Deploying artifacts to this repo
		rtMaven.deployer server: server, releaseRepo: 'fortna_release', snapshotRepo: 'fortna_snapshot'
		
		//Includes and excludes option
		//rtMaven.deployer.artifactDeploymentPatterns.addInclude("frog*").addExclude("*.zip")
		
		//Disabling artifacts deployment to Artifactory
		//rtMaven.deployer.deployArtifacts = false
		
		//Defining maven tool 
		rtMaven.tool = 'maven'
		
		/*************** Build Step ***************/
		withSonarQubeEnv {
			def mvn_version = tool 'maven'
			echo "${mvn_version}"
			withEnv( ["PATH+MAVEN=${mvn_version}/bin"] ) {
				buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean package -Dmaven.test.skip=true $SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.projectKey="$JOB_NAME" -Dsonar.projectName="$JOB_NAME"'
				
			}
		}
		/*******Locking Resource ********/
		lock('my-resource-name') {
		/*************** Docker Compose ***************/
		sh '''docker-compose up -d
			./clean_up.sh'''
		}
		/*************** Publishing buildInfo to Artifactory ***************/
		rtMaven.deployer.deployArtifacts buildInfo	//this should be disabled when depoyArtifacts is set to false. Otherwise, this will publish the Artifacts.
		server.publishBuildInfo buildInfo
		
	}
	
	/*************** Build Promotion Section ***************/
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
			// 'failFast' is true by default.
			// Set it to false, if you don't want the promotion to abort upon receiving the first error.
			'failFast'           : true
		]
 
		// Promote build
		//server.promote promotionConfig //this promotes the build automatically to the target specified in promotionConfig 
		Artifactory.addInteractivePromotion server: server, promotionConfig: promotionConfig, displayName: "Promotions Time" //this need human interaction to promote
	}
	
	stage ('Reports creation') {
		sh '''sleep 15s
		curl "http://13.230.131.198:8080/sonar/api/resources?resource=$JOB_NAME&metrics=bugs,vulnerabilities,code_smells,duplicated_blocks" > output.json
		sleep 10s'''
	}
	
	stage ('Robot FrameWork Results') {
		step([$class: 'RobotPublisher',
		outputPath: '/home/robot/results',
		passThreshold: 50,
		unstableThreshold: 50,
		otherFiles: ""])
	}
	
	stage ('Email Notifications') {
		notifySuccessful()
	}
}
