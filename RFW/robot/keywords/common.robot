*** Settings ***
Library           RequestsLibrary

*** Keywords ***
Send Get Request
    [Arguments]    ${hostname}    ${port}    ${uri}    ${expectedResult}
    ${header}=    Create Dictionary    Content-type=application/json
    Create Session    test    http://${hostname}:${port}
    ${resp}=    Get Request    test    ${uri}    headers=${header}
    #| | Log to console | ${resp} | DEBUG
    Should Be Equal As Strings    ${resp.status_code}    ${expectedResult}
    [Return]    ${resp.status_code}

Send Post Request
    [Arguments]    ${hostname}    ${port}    ${uri}    ${reqbody}    ${expectedResult}
    ${header}=    Create Dictionary    Content-type=application/json
    Create Session    test    http://${hostname}:${port}
    ${resp}=    Post Request    test    ${uri}    data=${reqbody}    headers=${header}
    #| Log to console ${resp} DEBUG
    Should Be Equal As Strings    ${resp.status_code}    ${expectedResult}
    [Return]    ${resp.status_code}
