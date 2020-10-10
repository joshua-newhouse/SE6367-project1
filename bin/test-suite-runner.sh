#!/bin/bash

#Test suite runner
# arg1: test suite file path
# arg2: path to program under test

NO_COLOR='\033[0m'

function Log() {
    local lineID="${1}"
    local msg="${2}"
    local type="${3}"
    local color="${4}"

    echo -e "${color}$(date +%F\ %T) [${type}] ${lineID}" "${msg}" "${NO_COLOR}"
}

function LogErr() {
    Log "${1}" "${*:2}" "ERROR" '\033[1;31m'
}
export -f LogErr
ErrMessage='eval LogErr "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'

function LogWarn() {
    Log "${1}" "${*:2}" "WARNING" '\033[1;33m'
}
export -f LogWarn
WarnMessage='eval LogWarn "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'

function LogInfo() {
    Log "${1}" "${*:2}" "INFO" '\033[1;34m'
}
export -f LogInfo
InfoMessage='eval LogInfo "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'

function LogTesting() {
    Log "${1}" "${*:2}" "TESTING" '\033[1;36m'
}
export -f LogTesting
TestingMessage='eval LogTesting "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'

function LogSuccess() {
    Log "${1}" "${*:2}" "SUCCESS" '\033[1;32m'
}
export -f LogSuccess
SuccessMessage='eval LogSuccess "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'

function LogFailure() {
    Log "${1}" "${*:2}" "FAILURE" '\033[1;91m'
}
export -f LogFailure
FailureMessage='eval LogFailure "$(echo -e "$(basename $0)/${FUNCNAME[0]}/$LINENO")"'


LOG_DIR="../logs"
LOG_FILE="${LOG_DIR}/newhouse-test.output"
ERR_FILE="${LOG_DIR}/newhouse-test.error"
LOG="tee -a ${LOG_FILE}"
LOG_ERR="tee -a ${LOG_FILE} ${ERR_FILE}"

mkdir -p "${LOG_DIR}" && rm -f "${LOG_FILE}" "${ERR_FILE}"

declare -A TEST_CASES
declare -a FAILED_TEST_CASES

# Verify command line args
[[ $# -ne 2 ]] &&
    $ErrMessage "Invalid number of command line arguments" && 
    echo -e "${NC}usage: $(basename $0) <test-suite-to-run> <path to test program>\n" \
        "  ex: $(basename $0) spell-test-suite.sh /usr/bin/spell" &&
    exit 1

# Source the test suite
[[ ! -f "${1}" ]] && $ErrMessage "No valid test suite specified" && exit 1
TEST_SUITE="${1}" && shift
source "${TEST_SUITE}"

function Main() {
    local returnCode=0

    IFS=$'\n'
    local sortedTestCases=( $(sort <<< "${!TEST_CASES[*]}") )
    unset IFS

    for testCase in ${sortedTestCases[@]}; do
        local test="${TEST_CASES[${testCase}]}"
        $TestingMessage "Running ${testCase}::${test}" | ${LOG}

        "${test}"
        local rc=$?

        # Test case result actions
        [[ ${rc} -ne 0 ]] &&
            $FailureMessage "${testCase}::${test} failed with return code: ${rc}" | ${LOG_ERR} &&
            FAILED_TEST_CASES+=("${testCase}::${test}") &&
            returnCode=1 ||
            $SuccessMessage "${testCase}::${test} passed" | ${LOG}
    done

    # Final test suite report
    [[ ${returnCode} -ne 0 ]] &&
        $ErrMessage "There were failed tests:" | ${LOG_ERR} &&
        printf '%s\n' "${FAILED_TEST_CASES[@]}" | ${LOG_ERR} ||
        $SuccessMessage "All test cases passed" | ${LOG}

    $InfoMessage "Test runner complete"
    exit ${returnCode}
}

Main "$@"

