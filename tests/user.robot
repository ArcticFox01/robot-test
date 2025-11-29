*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Test Teardown    Delete All Sessions

Suite Setup    Run Keywords    Disable SSL Warnings

*** Variables ***
${BASE_URL}    https://fakestoreapi.com
${PRODUCT_DATA}    ${CURDIR}/../data/api/product/

*** Keywords ***
Disable SSL Warnings
    ${disable_warnings}=    Evaluate    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)    modules=urllib3, urllib3.exceptions

GET Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}
    &{headers}=    Create Dictionary    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    GET On Session    ${BASE_URL}    ${PATH_URL}    expected_status=any
    RETURN    ${response}

POST Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    POST On Session    ${BASE_URL}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}

PUT Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    PUT On Session    ${BASE_URL}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}
    
DELETE Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    DELETE On Session    ${BASE_URL}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}

*** Test Cases ***
Get Product List
    ${response}=    Get Resp API    PATH_URL=/products/1
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_id_1.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')    json
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}
    Log Many    ${response.json()}[rating]

Post Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    Post Resp API    PATH_URL=/products    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    201
    Should Be Equal As Strings    ${response.reason}         Created
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Log Many    ${response.json()}
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}    ignore_keys=['id']

Put Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    PUT Resp API    PATH_URL=/products/1    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Log Many    ${response.json()}
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}    ignore_keys=['id']

Delete Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    DELETE Resp API    PATH_URL=/products/1    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Log Many    ${response.json()}
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}    ignore_keys=['id']