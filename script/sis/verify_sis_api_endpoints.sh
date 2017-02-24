#!/bin/bash

default_uid=1079058
default_cs_id=25129630

UID_CROSSWALK=${UID_CROSSWALK:-$default_uid}
SID=${SID:-$default_cs_id}
CAMPUS_SOLUTIONS_ID=${CAMPUS_SOLUTIONS_ID:-$default_cs_id}

echo_usage() {
  echo; echo "USAGE"; echo "    ${0} [Path to YAML file]"
  echo; echo "[OPTIONAL] Environment variables"
  echo
  echo "  By default, this script uses UID ${default_uid} (CS ID ${default_cs_id}) when testing API calls."
  echo "  You can override those defaults with:"
  echo
  echo "    export UID_CROSSWALK=123"
  echo "    export SID=456"
  echo "    export CAMPUS_SOLUTIONS_ID=789"
  echo
}

[[ $# -gt 0 ]] || { echo_usage; exit 1; }

LOG_RELATIVE_PATH="log/sis_api_test_$(date +"%Y-%m-%d_%H%M%S")"
LOG_DIRECTORY="${PWD}/${LOG_RELATIVE_PATH}"
CURL_STDOUT_LOG_FILE="${LOG_DIRECTORY}/curl_stdout.log"
API_ERROR_INDICATORS="error\|unable to find\|not authorized\|no service\|not available"

parse_yaml() {
  # --------------------------------------------
  # Read YAML file from Bash script and other utilities.
  # See sample usage at https://gist.github.com/pkuczynski/8665367
  # --------------------------------------------
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
       vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
       printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}

report_success() {
  local api_path="${1}"
  local response_metadata="${2}"
  echo "  [INFO] ${api_path} --> ${response_metadata}"
}

report_error() {
  local api_path="${1}"
  local http_code="${2}"
  local url="${3}"
  local path_to_file="${4}"
  echo
  echo "  [ERROR]"
  echo "    API Endpoint: ${api_path}"
  echo "    HTTP status: ${http_code}"
  echo "    Log: log${path_to_file#*/log}"
  echo "    URL: ${url}"
  echo
}

validate_api_response() {
  # Report error per HTTP Response code
  local api_path="${1}"
  local response_metadata="${2}"
  local http_code=$(cut -f1 -d" " <<< ${response_metadata})
  local url="${3}"
  local path_to_file="${4}"

  if [[ ("${http_code}" -lt "200") || ("${http_code}" -ge "400") ]] ; then
    report_error "$@"
  elif [[ ! -f "${path_to_file}" ]] ; then
    report_error "$@"
  else
    error_count=$(grep -i "${API_ERROR_INDICATORS}" ${path_to_file} | wc -l)
    if [ "${error_count}" -ne "0" ]; then
      report_error "$@"
      echo "    NOTE: Response contains at least one of ${API_ERROR_INDICATORS}"; echo
    else
      report_success "${api_path}" "${response_metadata}"
    fi
  fi
}

verify_sis_endpoints() {
  echo "----------------------------------------------------------------------------------------------------"
  local sis_system="${1}"
  local endpoint_array=$2[@]
  local endpoints=("${!endpoint_array}")
  local feature_flag_name="${3:-always_enabled}"
  local feature_flag_value="${4:-true}"
  echo; echo "${sis_system} > ${feature_flag_name}: ${feature_flag_value}"
  echo
  if [ "${feature_flag_value}" == "true" ] ; then
    curl_write_out='\n\t%{http_code} HTTP status\n\tTotal time (seconds): %{time_total}\n\tURL: %{url_effective}\n'
    for path in ${endpoints[@]}; do
      case "${sis_system}" in
        Campus\ Solutions)
          mkdir -p "${LOG_DIRECTORY}/campus_solutions"
          log_file="${LOG_DIRECTORY}/campus_solutions/${path//\//_}.log"
          url="${CS_BASE_URL}${path}"
          response_metadata=$(curl -k -w "${curl_write_out}" -so "${log_file}" -u "${CS_CREDENTIALS}" "${url}" 2>&1 | tee -a ${CURL_STDOUT_LOG_FILE})
          ;;
        Crosswalk)
          mkdir -p "${LOG_DIRECTORY}/calnet_crosswalk"
          log_file="${LOG_DIRECTORY}/calnet_crosswalk/${path//\//_}.log"
          url="${CROSSWALK_BASE_URL}${path}"
          response_metadata=$(curl -k -w "${curl_write_out}" -so "${log_file}" --digest -u "${CROSSWALK_CREDENTIALS}" "${url}" 2>&1 | tee -a ${CURL_STDOUT_LOG_FILE})
          ;;
        Hub*)
          mkdir -p "${LOG_DIRECTORY}/hub_edos"
          log_file="${LOG_DIRECTORY}/hub_edos/${path//\//_}.log"
          [[ "${path}" = \http* ]] && url="${path}" || url="${HUB_BASE_URL}${path}"
          response_metadata=$(curl -k -w "${curl_write_out}" -so "${log_file}" -H "Accept:application/json" -u "${HUB_CREDENTIALS}" --header "app_id: ${HUB_APP_ID}" --header "app_key: ${HUB_APP_KEY}" "${url}" 2>&1 | tee -a ${CURL_STDOUT_LOG_FILE})
          ;;
        (*)
          echo; echo "[ERROR] Unknown SIS system: ${sis_system}"; echo
          continue
          ;;
      esac
      validate_api_response "${path}" "${response_metadata}" "${url}" "${log_file}"
      echo "  Response body: ${log_file}" | tee -a "${CURL_STDOUT_LOG_FILE}"; echo
    done
  fi
  echo
}

verify_crosswalk() {
  endpoints=($@)
  verify_sis_endpoints "Crosswalk" endpoints
}

verify_cs() {
  feature=${1}; flag_value=${2}
  shift 2
  endpoints=($@)
  verify_sis_endpoints "Campus Solutions" endpoints "${feature}" "${flag_value}"
}

verify_hub() {
  feature=${1}; flag_value=${2}
  shift 2
  endpoints=($@)
  verify_sis_endpoints "Hub" endpoints "${feature}" "${flag_value}"
}

# cd to 'calcentral' directory
cd $( dirname "${BASH_SOURCE[0]}" )/../..

# Find and load the default YAML settings.
default_settings_yaml="${PWD}/config/settings.yml"
if [[ ! -f "${default_settings_yaml}" ]] ; then
  default_settings_yaml="${HOME}/calcentral/config/settings.yml"
fi

if [[ ! -f "${default_settings_yaml}" ]] ; then
  echo; echo "[ERROR]"
  echo "    The default YAML file was not found: ${default_settings_yaml}"; echo
  exit 1
fi
eval $(parse_yaml ${default_settings_yaml} 'yml_')

# Next, load the environment-specific YAML. It has precedence so it loads after default YAML.
yaml_file="${1}"
if [[ ! -f "${yaml_file}" ]] ; then
  echo; echo "[ERROR]"
  echo "    YAML file not found: ${yaml_file}"; echo
  exit 1
fi

eval $(parse_yaml ${yaml_file} 'yml_')

if [[ "${yml_application_provided_services}" = *calcentral* ]]; then
  APP_MODE="calcentral"
else
  APP_MODE="junction"
fi

# --------------------
CROSSWALK_BASE_URL="${yml_calnet_crosswalk_proxy_base_url//\'}"
CROSSWALK_CREDENTIALS="${yml_calnet_crosswalk_proxy_username//\'}:${yml_calnet_crosswalk_proxy_password//\'}"

CS_BASE_URL="${yml_campus_solutions_proxy_base_url//\'}"
CS_CREDENTIALS="${yml_campus_solutions_proxy_username//\'}:${yml_campus_solutions_proxy_password//\'}"

HUB_BASE_URL="${yml_hub_edos_proxy_base_url//\'}"
HUB_CREDENTIALS="${yml_hub_edos_proxy_username//\'}:${yml_hub_edos_proxy_password//\'}"
HUB_APP_ID="${yml_hub_edos_proxy_app_id//\'}"
HUB_APP_KEY="${yml_hub_edos_proxy_app_key//\'}"

# --------------------
echo "DESCRIPTION"
echo "    Verify API endpoints: Crosswalk, Campus Solutions, Hub"; echo

echo "OUTPUT"
echo "    Directory: ${LOG_RELATIVE_PATH}"; echo

echo "----------------------------------------------------------------------------------------------------"
echo "SIS ENVIRONMENTS"; echo
echo "  Campus Solutions: ${CS_BASE_URL}"
echo "  Crosswalk: ${CROSSWALK_BASE_URL}"
echo "  Hub: ${HUB_BASE_URL}"
echo; echo

verify_crosswalk \
  "/CAMPUS_SOLUTIONS_ID/${CAMPUS_SOLUTIONS_ID}" \
  "/LEGACY_SIS_STUDENT_ID/${SID}" \
  "/UID/${UID_CROSSWALK}"

if [ "${APP_MODE}" == "calcentral" ] ; then
  verify_cs 'always_enabled' true \
    "/UC_AA_ADVISING_RESOURCES.v1/UC_ADVISING_RESOURCES?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_CC_COMM_DB_URL.v1/dashboard/url/" \
    "/UC_SR_SLR_LINKS.v1/UC_SR_SLR_LINKS_GET" \
    "/UC_LINK_API.v1/get?PROPNAME=CALCENTRAL" \
    "/UC_AA_ADV_APPMT.v1/?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_AA_ADV_STDNT_REL.v1/?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_AA_ADV_ACTION_ITEM.v1/?EMPLID=${CAMPUS_SOLUTIONS_ID}&CALLER_TYPE=ADVISOR" \
    "/UC_SR_TRNSCPT_DATA.v1/Get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SR_TRANSFER_CREDIT.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SR_FACULTY_GRADING.v1/Get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_AA_ACAD_PLANNER_GET.v1/UC_AA_ACAD_PLANNER_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'advising_student_success' "${yml_features_advising_student_success}" \
    "/UC_AA_STDNT_GPA_TERMS.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SF_STDNT_OS_BAL.v1/Get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \

  verify_cs 'cs_profile' "${yml_features_cs_profile}" \
    "/UC_CC_ADDR_LBL.v1/get?COUNTRY=ESP" \
    "/UC_CC_ADDR_TYPE.v1/getAddressTypes/" \
    "/UC_CC_COMM_PEND_MSG.v1/get/pendmsg?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_CC_CURRENCY_CD.v1/Currency_Cd/Get" \
    "/UC_CC_LANGUAGES.v1/get/languages/" \
    "/UC_CC_NAME_TYPE.v1/getNameTypes/" \
    "/UC_CC_SERVC_IND.v1/Servc_ind/Get?/EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_CC_SS_ETH_SETUP.v1/GetEthnicitytype/" \
    "/UC_CC_STDNT_FERPA.v1/FERPA/GET?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_CM_XLAT_VALUES.v1/GetXlats?FIELDNAME=PHONE_TYPE" \
    "/UC_COUNTRY.v1/country/get" \
    "/UC_SIR_CONFIG.v1/get/sir/config/?INSTITUTION=UCB01" \
    "/UC_STATE_GET.v1/state/get/?COUNTRY=ESP"

  verify_cs 'cs_sir' "${yml_features_cs_sir}" \
    "/UC_CC_CHECKLIST.v1/get/checklist?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_DEPOSIT_AMT.v1/deposit/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&ADM_APPL_NBR=00000087" \
    "/UC_OB_HIGHER_ONE_URL_GET.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'cs_fin_aid' "${yml_features_cs_fin_aid}" \
    "/UC_FA_FINANCIAL_AID_DATA.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&INSTITUTION=UCB01&AID_YEAR=2016" \
    "/UC_FA_FUNDING_SOURCES.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&INSTITUTION=UCB01&AID_YEAR=2016" \
    "/UC_FA_FUNDING_SOURCES_TERM.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&INSTITUTION=UCB01&AID_YEAR=2016" \
    "/UC_FA_GET_T_C.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&INSTITUTION=UCB01"

  verify_cs 'cs_delegated_access' "${yml_features_cs_delegated_access}" \
    "/UC_CC_DELEGATED_ACCESS.v1/DelegatedAccess/get?SCC_DA_PRXY_OPRID=${UID_CROSSWALK}" \
    "/UC_CC_DELEGATED_ACCESS_URL.v1/get" \
    "/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=25000&MESSAGE_NBR=15" \
    "/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=28000&MESSAGE_NBR=52" \
    "/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=28001&MESSAGE_NBR=2005" \
    "/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=32500"

  verify_cs 'cs_enrollment_card' "${yml_features_cs_enrollment_card}"  \
    "/UC_SR_ACADEMIC_PLANNER.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&STRM=2168" \
    "/UC_SR_COLLEGE_SCHDLR_URL.v1/get/?EMPLID=${CAMPUS_SOLUTIONS_ID}&STRM=2168&ACAD_CAREER=UGRD&INSTITUTION=UCB01" \
    "/UC_SR_CURR_TERMS.v1/GetCurrentItems?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SR_STDNT_CLASS_ENROLL.v1/Get?EMPLID=${CAMPUS_SOLUTIONS_ID}&STRM=2168"

  verify_cs 'cs_fin_aid_award_compare' "${yml_features_cs_fin_aid_award_compare}" \
    "/UC_FA_AWARD_COMPARE_CURRNT.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&AID_YEAR=2016" \
    "/UC_FA_AWARD_COMPARE_PARMS.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&AID_YEAR=2016" \
    "/UC_FA_AWARD_COMPARE_PRIOR.v1/get?EMPLID=${CAMPUS_SOLUTIONS_ID}&AID_YEAR=2016"

  verify_cs 'cs_billing' "${yml_features_cs_billing}" \
    "/UC_SF_BILLING_DETAILS.v1/Get?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SF_FPP_LINKS_GET.v1/Get"

  verify_cs 'cs_advisor_student_lookup' "${yml_features_cs_advisor_student_lookup}" \
    "/UC_CC_USER_LOOKUP.v1/lookup?NAME1=Wavy&NAME2=Gravy&AFFILIATIONS=STUDENT,UNDERGRAD"

  verify_cs 'cs_profile_emergency_contacts' "${yml_features_cs_profile_emergency_contacts}" \
    "/UcApiEmergencyContactGet.v1/?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'cs_degree_progress_grad_advising' "${yml_features_cs_degree_progress_grad_advising}" \
    "/UC_AA_PROGRESS_GET.v1/UC_AA_PROGRESS_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'cs_degree_progress_grad_student' "${yml_features_cs_degree_progress_grad_student}" \
    "/UC_AA_PROGRESS_GET.v1/UC_AA_PROGRESS_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'cs_degree_progress_ugrd_advising' "${yml_features_cs_degree_progress_ugrd_advising}" \
    "/UC_AA_PROGRESS_UGRD_GET.v1/UC_AA_PROGRESS_UGRD_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}"

  verify_cs 'cs_committees' "${yml_features_cs_committees}" \
    "/UC_SR_STUDENT_COMMITTEE.v1/UC_SR_STUDENT_COMMITTEE_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}" \
    "/UC_SR_FACULTY_COMMITTEE.v1/UC_SR_FACULTY_COMMITTEE_GET?EMPLID=${CAMPUS_SOLUTIONS_ID}"
fi

verify_hub 'always_enabled' true \
  "/${CAMPUS_SOLUTIONS_ID}/affiliation" \
  "/${CAMPUS_SOLUTIONS_ID}/contacts"

if [ "${APP_MODE}" == "calcentral" ] ; then
verify_hub 'profile' true \
  "/${CAMPUS_SOLUTIONS_ID}/academic-status" \
  "/${CAMPUS_SOLUTIONS_ID}/all" \
  "/${CAMPUS_SOLUTIONS_ID}/demographic" \
  "/${CAMPUS_SOLUTIONS_ID}/registrations" \
  "/${CAMPUS_SOLUTIONS_ID}/work-experiences"
fi

# Custom credentials are needed for the Hub's Term API
export HUB_APP_ID="${yml_hub_term_proxy_app_id//\'}"
export HUB_APP_KEY="${yml_hub_term_proxy_app_key//\'}"

verify_hub 'hub_term_api' "${yml_features_hub_term_api}" \
  "${yml_hub_term_proxy_base_url//\'}?temporal-position=Next"

if [ "${APP_MODE}" == "calcentral" ] ; then
  # Custom credentials are needed for the Hub's Enrollment API
  export HUB_APP_ID="${yml_hub_enrollments_proxy_app_id//\'}"
  export HUB_APP_KEY="${yml_hub_enrollments_proxy_app_key//\'}"

  verify_hub 'hub_enrollments_api' true \
    "${yml_hub_enrollments_proxy_base_url//\'}/${CAMPUS_SOLUTIONS_ID}?page-size=1"
fi

echo; echo "----------------------------------------------------------------------------------------------------"; echo
echo "Results can be found in the directory:"
echo "  ${LOG_DIRECTORY}/${LOG_RELATIVE_PATH}"; echo;
echo "Output of all cURL commands:";
echo "  ${CURL_STDOUT_LOG_FILE}";
echo; echo "----------------------------------------------------------------------------------------------------"; echo
echo "[DONE]"; echo

exit 0
