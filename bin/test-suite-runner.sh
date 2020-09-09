#!/bin/bash

#Test suite runner
# arg1: test suite file path
# arg2: path to program under test

#Logging
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ErrMessage='eval echo -e "${RED}$(date +%F\ %T) [ERROR] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
WarnMessage='eval echo -e "${YELLOW}$(date +%F\ %T") [WARN] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
InfoMessage='eval echo -e "${NC}$(date +%F\ %T) [INFO] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'

#Additional logging for tests
T_BLUE='\033[1;34m'
T_GREEN='\033[1;32m'
T_RED='\033[1;31m'

TestingMessage='eval echo -e "${T_BLUE}$(date +%F\ %T) [TESTING] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
SuccessMessage='eval echo -e "${T_GREEN}$(date +%F\ %T) [SUCCESS] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
FailureMessage='eval echo -e "${T_RED}$(date +%F\ %T) [FAILURE] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'

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

    for testCase in ${!TEST_CASES[@]}; do
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
        $InfoMessage "All test cases passed" | ${LOG}

    $InfoMessage "Test runner complete"
    exit ${returnCode}
}

Main "$@"

