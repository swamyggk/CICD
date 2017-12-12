/***** Jenkinsfile with final template *****/
/************************ Environment Variables **************************/
def robot_result_folder = ""

//Artifactory server instance declaration	
def server = Artifactory.server 'art1' //server1 is the Server ID given to Artifactory server in Jenkins

//buildInfo variable
def buildInfo = 'null'
	
//Creating an Artifactory Maven Build instance
def rtMaven = Artifactory.newMavenBuild()

/******reading jar file name*********/
def getMavenBuildArtifactName() {
 pom = readMavenPom file: 'pom.xml'
 return "${pom.artifactId}-${pom.version}.${pom.packaging}"
}


/******************** Notifying SUCCESSFUL buildInfo **********************/
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
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'yerriswamy.konanki@ggktech.com, sunil.boga@ggktech.com, thonguyen@fortna.com'
	)
}

node {
     
	/*************** Git Checkout ***************/
	stage ('Checkout') {
		checkout scm	
		//checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/yerriswamykonanki/CICD.git']]])
	}
    
    /************ getting jarfile name ************/
    def jar_name = getMavenBuildArtifactName()
	
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
		withSonarQubeEnv {
			def mvn_version = tool 'maven'
			echo "${mvn_version}"
			withEnv( ["PATH+MAVEN=${mvn_version}/bin"] ) {
				buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true $SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.projectKey="$JOB_NAME" -Dsonar.projectName="$JOB_NAME"'
			}
		}
	}
	
	/*************** Robot Frame work results ***************/
	stage ('Docker Deploy and RFW') {
   	/*******Locking Resource ********/
		lock('Compose-resource-lock') {
        		/*************** Docker Compose ***************/
		sh """jarfile_name=${jar_name} /usr/local/bin/docker-compose up -d
			./clean_up.sh"""
			def content = readFile './.env'
  			Properties properties = new Properties()
  			InputStream contents = new ByteArrayInputStream(content.getBytes());
  			properties.load(contents)
  			contents = null
			robot_result_folder = properties.robot_result_folder
			step([$class: 'RobotPublisher',
				outputPath: "/home/robot/${robot_result_folder}",
				passThreshold: 0,
				unstableThreshold: 0,
				otherFiles: ""])
		}
	}
	
	/*************** Pushing the artifacts***************/	
	stage ('Artifacts Deployment'){		
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
			'failFast'           : true
		]
 
		// Promote build
		//server.promote promotionConfig //this promotes the build automatically to the target specified in promotionConfig 
		Artifactory.addInteractivePromotion server: server, promotionConfig: promotionConfig, displayName: "Promotions Time" //this need human interaction to promote
	}
	
	stage ('Reports creation') {
		sh '''sleep 15s
		curl "http://10.240.17.12:9000/sonar/api/resources?resource=$JOB_NAME&metrics=bugs,vulnerabilities,code_smells,duplicated_blocks" > output.json
		sleep 10s'''
	}
	
	stage ('Email Notifications') {
		notifySuccessful() 
	}
}
