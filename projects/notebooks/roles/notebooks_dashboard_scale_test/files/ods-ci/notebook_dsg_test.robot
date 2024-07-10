*** Settings ***
Resource            tests/Resources/ODS.robot
Resource            tests/Resources/Common.robot
Resource            tests/Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/Workbenches.resource
Resource            tests/Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/Projects.resource
Resource            tests/Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/DataConnections.resource
Resource            tests/Resources/Page/ODH/ODHDashboard/ODHDataScienceProject/Pipelines.resource
Resource            tests/Resources/Page/ODH/JupyterHub/Elyra.resource

Library             DateTime
Library             JupyterLibrary
Library             libs/Helpers.py
Library             SeleniumLibrary
#Library             DebugLibrary  # then use the 'Debug' keyword to set a breakpoint

Resource  notebook_scale_test_common.resource

Suite Teardown  Tear Down

*** Variables ***

${DASHBOARD_PRODUCT_NAME}      "%{DASHBOARD_PRODUCT_NAME}"

${PROJECT_NAME}                ${TEST_USER.USERNAME}
${WORKBENCH_NAME}              ${TEST_USER.USERNAME}

# ${NOTEBOOK_SIZE_NAME}          %{NOTEBOOK_SIZE_NAME}

${ACCESS_KEY}                  %{S3_ACCESS_KEY}
${SECRET_KEY}                  %{S3_SECRET_KEY}
${HOST_BASE}                   %{S3_HOSTNAME}
${HOST_BUCKET}                 %{S3_BUCKET_NAME}

${DC_NAME}                     elyra-s3
${IMAGE}                       Standard Data Science
${PV_NAME}                     ods-ci-pv-elyra
${PV_DESCRIPTION}              ods-ci-pv-elyra is a PV created to test Elyra in workbenches
${PV_SIZE}                     2

${PIPELINE_IMPORT_BUTTON}      xpath=//button[@id='import-pipeline-button']
${PIPELINES_SERVER_BTN_XP}     xpath=//*[@data-testid="create-pipeline-button"]
${SVG_CANVAS}                  //*[name()="svg" and @class="svg-area"]
${SVG_INTERACTABLE}            /*[name()="g" and @class="d3-canvas-group"]
${SVG_PIPELINE_NODES}          /*[name()="g" and @class="d3-nodes-links-group"]
${SVG_SINGLE_NODE}             /*[name()="g" and contains(@class, "d3-draggable")]
${EXPECTED_COLOR}              rgb(0, 102, 204)

${ODH_DASHBOARD_DO_NOT_WAIT_FOR_SPINNER_PAGE}  ${true}

*** Test Cases ***

Open the Browser
  [Tags]  Setup

  Setup

Login to RHODS Dashboard
  [Tags]  Authenticate

  Go To  ${ODH_DASHBOARD_URL}
  Login To RHODS Dashboard  ${TEST_USER.USERNAME}  ${TEST_USER.PASSWORD}  ${TEST_USER.AUTH_TYPE}


Go to RHODS Dashboard
  [Tags]  Dashboard

  Wait For Condition  return document.title == ${DASHBOARD_PRODUCT_NAME}  timeout=3 minutes
  Wait Until Page Contains  Launch application  timeout=3 minutes
  Capture Page Screenshot


Go to the Project page
  [Tags]  Dashboard

  Open Data Science Projects Home Page
  Wait Until Page Contains No Spinner

  Capture Page Screenshot

  ${has_errors}  ${error}=  Run Keyword And Ignore Error  Project Should Be Listed  ${PROJECT_NAME}
  IF  '${has_errors}' != 'PASS'
    Create Data Science Project  ${PROJECT_NAME}  ${TEST_USER.USERNAME}'s project
  ELSE
    Open Data Science Project Details Page  ${PROJECT_NAME}
  END
  Wait Until Page Contains No Spinner
  Capture Page Screenshot
  
Create S3 Data Connection Creation  
  [Tags]  Dashboard

  ${data_connection_exists}  ${error}=  Run Keyword and Ignore Error  Data Connection Should Not Be Listed  ${DC_NAME}
  IF  '${data_connection_exists}' != 'PASS'
    Create S3 Data Connection   project_title=${PROJECT_NAME}   dc_name=${DC_NAME}    aws_access_key=${ACCESS_KEY}    aws_secret_access=${SECRET_KEY}   aws_bucket_name=${HOST_BUCKET}  aws_s3_endpoint=${HOST_BASE}
  ELSE
    Recreate S3 Data Connection   project_title=${PROJECT_NAME}   dc_name=${DC_NAME}    aws_access_key=${ACCESS_KEY}    aws_secret_access=${SECRET_KEY}   aws_bucket_name=${HOST_BUCKET}  aws_s3_endpoint=${HOST_BASE}
  END
  Capture Page Screenshot


Create Pipeline Server To s3
  [Tags]  Dashboard
  Create Pipeline Server    dc_name=${DC_NAME}    project_title=${PROJECT_NAME}
  Wait Until Page Contains No Spinner    
  Element Should Be Enabled     ${PIPELINE_IMPORT_BUTTON}
  Sleep  1 minutes

  Capture Page Screenshot


Create and Launch Workbench 
  [Tags]  Dashboard

  ${workbench_exists}  ${error}=  Run Keyword And Ignore Error  Workbench Is Listed  elyra_${IMAGE}
  IF  '${workbench_exists}' == 'FAIL'  
    Create Workbench    workbench_title=elyra_${IMAGE}    workbench_description=Elyra test    prj_title=${PROJECT_NAME}   image_name=${IMAGE}   deployment_size=Tiny    storage=Persistent    pv_existent=${FALSE}    pv_name=${PV_NAME}_${IMAGE}   pv_description=${PV_DESCRIPTION}    pv_size=${PV_SIZE}    
  END
  Start Workbench     workbench_title=elyra_${IMAGE}    timeout=300s
  Launch And Access Workbench Elyra Pipelines    workbench_title=elyra_${IMAGE}
  Capture Page Screenshot
  Clone Git Repository And Open    https://github.com/redhat-rhods-qe/ods-ci-notebooks-main
  ...    ods-ci-notebooks-main/notebooks/500__jupyterhub/pipelines/v2/elyra/run-pipelines-on-data-science-pipelines/hello-generic-world.pipeline  # robocop: disable
  Verify Hello World Pipeline Elements
  Set Runtime Image In All Nodes    runtime_image=Datascience with Python 3.9 (UBI9)
  Run Pipeline    pipeline_name=${IMAGE} Pipeline
  Wait Until Page Contains Element    xpath=//a[.="Run Details."]    timeout=30s

Check of Pipeline Runs
  [Tags]  Dashboard

  ${pipeline_run_name} =    Get Pipeline Run Name
  Switch To Pipeline Execution Page
  Is Data Science Project Details Page Open   ${PROJECT_NAME}
  Verify Elyra Pipeline Run    ${pipeline_run_name}    timeout=5m


*** Keywords ***


Just Launch Workbench
    [Arguments]     ${workbench_title}

    Click Link      ${WORKBENCH_SECTION_XP}//tr[td[@data-label="Name"]/*[div[text()="${workbench_title}"]]]/td//a[text()="Open"]
    Switch Window   NEW

Wait Until Page Contains No Spinner
    [Arguments]     ${timeout}=30 seconds
    Wait Until Page Does Not Contain Element   //*[contains(@class, 'pf-c-spinner')]  timeout=${timeout}

Wait Until Workbench Is Starting
    [Documentation]    Waits until workbench status is "Starting..." in the DS Project details page
    [Arguments]     ${workbench_title}      ${timeout}=30s    ${status}=${WORKBENCH_STATUS_STARTING}

    Wait Until Page Contains Element
    ...        ${WORKBENCH_SECTION_XP}//tr[td[@data-label="Name"]/*[div[starts-with(text(), "${workbench_title}")]]]/td[@data-label="Status"]//p[text()="${status}"]    timeout=${timeout}

Stop Starting Workbench
    [Documentation]    Stops a starting workbench from DS Project details page
    [Arguments]     ${workbench_title}    ${press_cancel}=${FALSE}
    ${is_stopped}=      Run Keyword And Return Status   Workbench Status Should Be
    ...    workbench_title=${workbench_title}   status=${WORKBENCH_STATUS_STOPPED}
    IF    ${is_stopped} == ${False}
        Click Element       ${WORKBENCH_SECTION_XP}//tr[td[@data-label="Name"]/*[div[starts-with(text(), "${workbench_title}")]]]/td[@data-label="Status"]//span[@class="pf-v5-c-switch__toggle"]
        Wait Until Generic Modal Appears
        Page Should Contain    Are you sure you want to stop the workbench? Any changes without saving will be erased.
        Click Button    ${WORKBENCH_STOP_BTN_XP}
    ELSE
        Fail   msg=Cannot stop workbench ${workbench_title} because it is always stopped..
    END

Workbench is Listed
    [Documentation]    Checks a workbench is listed in the DS Project details page
    [Arguments]     ${workbench_title}
    Run keyword And Continue On Failure
    ...    Page Should Contain Element
    ...        ${WORKBENCH_SECTION_XP}//td[@data-label="Name"]/*[div[starts-with(text(), "${workbench_title}")]]

Wait Until Pipeline Server Deployed 
    [Documentation]    waits untill the pipeline server deployed and have the button import pipeline button 
    Wait Until Page Does Not Contain Element   //*[contains(@class, 'pf-c-spinner')]  timeout=3 minutes
        

Verify Hello World Pipeline Elements
    [Documentation]    Verifies that the example pipeline is displayed correctly by Elyra
    Wait Until Page Contains Element    xpath=${SVG_CANVAS}     timeout=10s
    Maybe Migrate Pipeline
    Page Should Contain Element    xpath=${SVG_CANVAS}${SVG_INTERACTABLE}${SVG_PIPELINE_NODES}${SVG_SINGLE_NODE}//span[.="Load weather data"]  # robocop: disable
    Page Should Contain Element    xpath=${SVG_CANVAS}${SVG_INTERACTABLE}${SVG_PIPELINE_NODES}${SVG_SINGLE_NODE}//span[.="Part 1 - Data Cleaning.ipynb"]  # robocop: disable
    Page Should Contain Element    xpath=${SVG_CANVAS}${SVG_INTERACTABLE}${SVG_PIPELINE_NODES}${SVG_SINGLE_NODE}//span[.="Part 2 - Data Analysis.ipynb"]  # robocop: disable
    Page Should Contain Element    xpath=${SVG_CANVAS}${SVG_INTERACTABLE}${SVG_PIPELINE_NODES}${SVG_SINGLE_NODE}//span[.="Part 3 - Time Series Forecasting.ipynb"]  # robocop: disable

Launch And Access Workbench Elyra Pipelines 
    [Documentation]    Launches a workbench from DS Project details page
    [Arguments]     ${workbench_title}    ${username}=${TEST_USER.USERNAME}
    ...    ${password}=${TEST_USER.PASSWORD}  ${auth_type}=${TEST_USER.AUTH_TYPE}
    ${is_started}=      Run Keyword And Return Status   Workbench Status Should Be
    ...    workbench_title=${workbench_title}   status=${WORKBENCH_STATUS_RUNNING}
    IF    ${is_started} == ${TRUE}
        Open Workbench    workbench_title=${workbench_title}
        Access To Workbench    username=${username}    password=${password}
        ...    auth_type=${auth_type}
    ELSE
        Fail   msg=Cannot Launch And Access Workbench ${workbench_title} because it is not running...
    END

Verify Elyra Pipeline Run 
    [Documentation]    Verifys Elyra Pipeline runs are sucessfull
    [Arguments]    ${pipeline_run_name}    ${timeout}=10m
    Open Pipeline Elyra Pipeline Run    ${pipeline_run_name}
    Wait Until Page Contains Element    //span[@class='pf-v5-c-label__text' and text()='Succeeded']    timeout=${timeout}
    Capture Page Screenshot  


Open Pipeline Elyra Pipeline Run
    [Documentation]    Open the Pipeline Run detail.
    [Arguments]    ${pipeline_run_name}
    Navigate To Page    Data Science Pipelines    Runs
    ODHDashboard.Maybe Wait For Dashboard Loading Spinner Page
    Wait Until Page Contains Element    xpath=//*[@data-testid="active-runs-tab"]      timeout=30s
    Click Element    xpath=//*[@data-testid="active-runs-tab"]
    Wait Until Page Contains Element    xpath=//span[text()='${pipeline_run_name}']
    Click Element    xpath=//span[text()='${pipeline_run_name}']
    Wait Until Element Is Visible    //span[@class='pf-v5-c-label__text' and text()='Succeeded']    5m
    Element Should Contain    //span[@class='pf-v5-c-label__text' and text()='Succeeded']    Succeeded