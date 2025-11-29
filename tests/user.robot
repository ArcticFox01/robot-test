*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    json
Suite Teardown    Delete All Sessions

# 2. Use a Suite Setup to create the bypassing session once
Suite Setup    Run Keywords    Disable SSL Warnings    AND    Create Bypassing Session Setup

*** Variables ***
# 3. Revert to the original URL
${BASE_URL}    https://jsonplaceholder.typicode.com
${PRODUCT_DATA}    ${CURDIR}/../data/api/product/
# 4. Fixed session alias used by the custom keyword and all API keywords
${SESSION_ALIAS}    myapi_cf_bypass

*** Keywords ***
Disable SSL Warnings
    ${disable_warnings}=    Evaluate    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)    modules=urllib3, urllib3.exceptions

# 5. New Setup Keyword using the custom Python library
Create Bypassing Session Setup
    &{headers}=    Create Dictionary
    ...    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
    ...    Accept=application/json
    ...    Accept-Encoding=gzip, deflate
    ...    Connection=keep-alive
    
    # Calls the Python keyword to solve the challenge and store the session
    Create Session    ${SESSION_ALIAS}    ${BASE_URL}    headers=${headers}

# 6. API Keywords are simplified: They only make the request using the existing session
GET Resp API
    [Arguments]    ${PATH_URL}=/
    ${response}=    GET On Session    ${SESSION_ALIAS}    ${PATH_URL}    expected_status=any
    RETURN    ${response}

POST Resp API
    [Arguments]    ${PATH_URL}=/    ${payload}=${EMPTY}
    ${response}=    POST On Session    ${SESSION_ALIAS}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}

PUT Resp API
    [Arguments]    ${PATH_URL}=/    ${payload}=${EMPTY}
    ${response}=    PUT On Session    ${SESSION_ALIAS}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}
    
DELETE Resp API
    [Arguments]    ${PATH_URL}=/    ${payload}=${EMPTY}
    ${response}=    DELETE On Session    ${SESSION_ALIAS}    ${PATH_URL}    expected_status=any
    RETURN    ${response}

*** Test Cases ***
Get Product List
    ${response}=    Get Resp API    PATH_URL=/todos/1
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    ${expected_json}=    Get File    ${PRODUCT_DATA}/testdata1.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')    json
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}
    Log Many    ${response.json()}

Post Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/testdata2.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    Post Resp API    PATH_URL=posts    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    201
    Should Be Equal As Strings    ${response.reason}         Created
    Log Many    ${response.json()}
    # Check if response has rating field, if not add it for comparison
    ${response_dict}=    Set Variable    ${response.json()}
    ${expected_json}=    Get File    ${PRODUCT_DATA}/testdata2_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Dictionaries Should Be Equal    ${response_dict}    ${expected_dict}

Put Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/testdata3.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    PUT Resp API    PATH_URL=/posts/1    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    Log Many    ${response.json()}
    # Check if response has rating field, if not add it for comparison
    ${response_dict}=    Set Variable    ${response.json()}
    ${expected_json}=    Get File    ${PRODUCT_DATA}/testdata3_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Dictionaries Should Be Equal    ${response_dict}    ${expected_dict}

Delete Product List
    ${response}=    DELETE Resp API    PATH_URL=/posts/1
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    Log Many    ${response.json()}
    Should Be Equal As Strings    ${response.json()}    {}