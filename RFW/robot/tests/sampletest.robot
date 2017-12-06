*** Settings ***
Suite Setup
Resource          ../keywords/common.robot
Library           DatabaseLibrary

*** Variables ***
${hostname}       cpserver
${port}           6400
${uri}            /api/product/list
${dbConnectionStr}    'cicd_sample/cicd_sample@52.67.80.187:1521/GGKF'

*** Test Cases ***
Connect To Database And Execute Query
    Connect To Database Using Custom Params    cx_Oracle    ${dbConnectionStr}
    ${toRet}=    Query    SELECT * FROM CONFIGURATION
    Disconnect From Database

Send API Get Request
    Send Get Request    ${hostname}    ${port}    ${uri}    200

Send API Post Request
    Send Post Request    ${hostname}    ${port}    ${uri}    \{\"id\"\:\"1\"\}    200
