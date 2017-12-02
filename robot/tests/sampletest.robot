*** Settings ***
Suite Setup
Resource          ../keywords/common.robot
Library           DatabaseLibrary

*** Variables ***
${hostname}       192.168.13.14
${port}           8082
${uri}            /api/lms/listWorker
${dbConnectionStr}    'cicd_sample/cicd_sample@192.168.13.14:1521/FORTNAWCS'

*** Test Cases ***
Connect To Database And Execute Query
    Connect To Database Using Custom Params    cx_Oracle    ${dbConnectionStr}
    ${toRet}=    Query    SELECT * FROM CONFIGURATION
    Disconnect From Database

Send API Get Request
    Send Get Request    ${hostname}    ${port}    ${uri}    200

Send API Post Request
    Send Post Request    ${hostname}    ${port}    ${uri}    \{\"id\"\:\"1\"\}    200
