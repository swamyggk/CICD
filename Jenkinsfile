/***** Jenkinsfile with final template *****/

/************************ Environment Variables **************************/
def robot_result_folder = ""

def server = Artifactory.server 'server1'		//Artifactory server instance declaration. 'server1' is the Server ID given to Artifactory server in Jenkins

def buildInfo = 'null'						//buildInfo variable
	
def rtMaven = Artifactory.newMavenBuild()	//Creating an Artifactory Maven Build instance

def Reason = "JOB FAILED"

/******reading jar file name*********/
def getMavenBuildArtifactName() {
 pom = readMavenPom file: 'pom.xml'
 return "${pom.artifactId}-${pom.version}.${pom.packaging}"
}

/******************** Notifying buildInfo **********************/
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
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'sneha.kailasa@ggktech.com'
	)
}

def notifyFailure(def Reason){
println "Failed Reason:  ${Reason}"
emailext (
	attachLog: true, attachmentsPattern: '*.html, output.xml', body: '''<span style=\'line-height: 22px; font-family: Candara; padding: 10.5px; font-size: 15px; word-break: break-all; word-wrap: break-word; \'>
	<h1><FONT COLOR=red>$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS</FONT></h1>
 <!-- <h1>${BUILD_LOG_REGEX, regex="Failed Reason: ", linesBefore=0, linesAfter=0, maxMatches=1, showTruncatedLines=false, escapeHtml=true}</h1> -->
 	<h1> zsdfzdsf$BUILD_DESCRIPTION</h1>
	<p><h2><a href="$BUILD_URL">Click Here</a> to view build result</h2><br><h3>Please find below, the build logs and other files.</h3></p>
	</span>''', subject: '$DEFAULT_SUBJECT', to: 'sneha.kailasa@ggktech.com'
	)
}

node {
     
	/*************** Git Checkout ***************/
	try {
		stage ('Checkout') {
			//checkout scm	
			Reason = "GIT Checkout Failed"
			checkout([$class: 'GitSCM', branches: [[name: '*/TestBoga']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory']], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/boga5/CICD.git']]])
			
		}
	
	
    
    /************ getting jarfile name ************/
    def jar_name = getMavenBuildArtifactName()
	
    /*************** Building the application ***************
	
		stage ('Maven Build') {
			Reason = "Maven Build Failed"
		
			//rtMaven.resolver server: server, releaseRepo: 'fortna_release', snapshotRepo: 'fortna_snapshot'		//Downloading dependencies
			
			rtMaven.deployer server: server, snapshotRepo: 'fortna_snapshot', releaseRepo: 'fortna_release'			//Deploying artifacts to this repo
			
			rtMaven.deployer.deployArtifacts = false	//this will not publish artifacts soon after build succeeds	//Disabling artifacts deployment to Artifactory
			
			rtMaven.tool = 'maven'						//Defining maven tool 
			
			/*************** Build Step ***************
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
			Reason = "Docker Deployment or RFW Failed"
			def JobName = "${JOB_NAME}"
			def content = readFile './.env'
			Properties properties = new Properties()
			InputStream contents = new ByteArrayInputStream(content.getBytes());
			properties.load(contents)
			contents = null
			def branch_name1 = properties.branch_name
			println "${branch_name1}" 
			if(JobName.contains('PR-'))
			{
			 def index = JobName.indexOf("/");
			 SonarHostName = JobName.substring(0 , index)+"_"+"${branch_name1}"
			}
			else
			{
 				def index = JobName.indexOf("/");
				 SonarHostName = JobName.substring(0 , index)+"_"+"${BRANCH_NAME}"
			}
			sh 'exit 1 '
			lock(SonarHostName) {
					/*************** Docker Compose ***************
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
					passThreshold: 50,
					unstableThreshold: 50,
					otherFiles: ""])
			if("${currentBuild.result}" == "FAILURE")
			 {
				 sh "exit 1"
			 }*/
			}
		}
	
	
	
	/*************** Pushing the artifacts***************	
	
		stage ('Artifacts Deployment'){		
			/*************** Publishing buildInfo to Artifactory ***************
			Reason = "Artifacts Deployment Failed"
			rtMaven.deployer.deployArtifacts buildInfo	//this should be disabled when depoyArtifacts is set to false. Otherwise, this will publish the Artifacts.
			server.publishBuildInfo buildInfo
		}
	
	
	 
	/*************** Build Promotion Section ***************
	
		stage ('Build Promotions') {
			Reason = "Build Promotions Failed"
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
			Reason = "Reports creation Failed"
			sh '''sleep 15s
			curl "http://10.240.17.12:9000/sonar/api/resources?resource=$JOB_NAME&metrics=bugs,vulnerabilities,code_smells,duplicated_blocks" > output.json
			sleep 10s'''
		}
	*/
	stage ('Email Notifications') {
		notifySuccessful() 
	}
}
	catch(Exception e)
	{
		//def Reason = "Report Creation failed"
		currentBuild.result = "FAILURE"
		currentBuild.description="${Reason}"
		sh 'echo ${BUILD_STATUS}'
		notifyFailure(Reason)
		sh 'exit 1'
	}
}
	
