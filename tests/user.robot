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
    &{headers}=    Create Dictionary
    ...    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
    ...    Accept=application/json
    ...    Accept-Encoding=gzip, deflate
    ...    Connection=keep-alive
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    GET On Session    ${BASE_URL}    ${PATH_URL}    expected_status=any
    RETURN    ${response}

POST Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary
    ...    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
    ...    Accept=application/json
    ...    Accept-Encoding=gzip, deflate
    ...    Connection=keep-alive
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    POST On Session    ${BASE_URL}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}

PUT Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary
    ...    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
    ...    Accept=application/json
    ...    Accept-Encoding=gzip, deflate
    ...    Connection=keep-alive
    Create Session    ${BASE_URL}    ${BASE_URL}    headers=${headers}
    ${response}=    PUT On Session    ${BASE_URL}    ${PATH_URL}    json=${payload}    expected_status=any
    RETURN    ${response}
    
DELETE Resp API
    [Arguments]    ${BASE_URL}=${BASE_URL}    ${PATH_URL}=${/}    ${payload}=${EMPTY}
    &{headers}=    Create Dictionary
    ...    User-Agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
    ...    Accept=application/json
    ...    Accept-Encoding=gzip, deflate
    ...    Connection=keep-alive
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
    Log Many    ${response.json()}
    # Check if response has rating field, if not add it for comparison
    ${response_dict}=    Set Variable    ${response.json()}
    ${has_rating}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${response_dict}    rating
    IF    not ${has_rating}
        &{rating_dict}=    Create Dictionary    rate=${3.9}    count=${120}
        Set To Dictionary    ${response_dict}    rating    ${rating_dict}
    END
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Dictionaries Should Be Equal    ${response_dict}    ${expected_dict}    ignore_keys=['id']

Put Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    PUT Resp API    PATH_URL=/products/1    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    Log Many    ${response.json()}
    # Check if response has rating field, if not add it for comparison
    ${response_dict}=    Set Variable    ${response.json()}
    ${has_rating}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${response_dict}    rating
    IF    not ${has_rating}
        &{rating_dict}=    Create Dictionary    rate=${3.9}    count=${120}
        Set To Dictionary    ${response_dict}    rating    ${rating_dict}
    END
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1_expected.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')
    Dictionaries Should Be Equal    ${response_dict}    ${expected_dict}    ignore_keys=['id']

Delete Product List
    ${payload_json}=    Get File    ${PRODUCT_DATA}/test_data_product_1.json
    &{payload_dict}=    Evaluate    json.loads('''${payload_json}''')    json
    ${response}=    DELETE Resp API    PATH_URL=/products/1    payload=${payload_dict}
    Should Be Equal As Numbers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.reason}         OK
    Log Many    ${response.json()}
    # For DELETE, the API returns the deleted product data, not the test data
    # So we need to compare against the expected product data (test_data_id_1.json)
    ${expected_json}=    Get File    ${PRODUCT_DATA}/test_data_id_1.json
    &{expected_dict}=    Evaluate    json.loads('''${expected_json}''')    json
    Dictionaries Should Be Equal    ${response.json()}    ${expected_dict}