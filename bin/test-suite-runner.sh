#!/bin/bash

#Test suite runner
# Pass test suite file as first command line argument

#Logging
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ErrMessage='eval echo -e "${RED}$(date +"%Y-%m-%d %T") [ERROR] - ${FUNCNAME[0]},${LINENO[0]}: "'
WarnMessage='eval echo -e "${YELLOW}$(date +"%Y-%m-%d %T") [WARN] - ${FUNCNAME[0]},${LINENO[0]}: "'
InfoMessage='eval echo -e "${NC}$(date +"%Y-%m-%d %T") [INFO] - ${FUNCNAME[0]},${LINENO[0]}: "'

#Additional logging for tests
T_GREEN='\033[1;32m'
T_RED='\033[1;31m'

SuccessMessage='eval echo -e "${T_GREEN}$(date +"%Y-%m-%d %T") [SUCCESS] - ${FUNCNAME[0]},${LINENO[0]}: "'
FailureMessage='eval echo -e "${T_RED}$(date +"%Y-%m-%d %T") [FAILURE] - ${FUNCNAME[0]},${LINENO[0]}: "'

declare -a TEST_CASES
declare -a FAILED_TEST_CASES

# Source the test suite
[[ ! -f "${1}" ]] && $ErrMessage "No valid test suite specified" && exit 1
source "${1}" && shift

function Main() {
    local returnCode=0

    for test in ${TEST_CASES[@]}; do
        $InfoMessage "Running ${test}"

        "${test}"
        local rc=$?

        # Test case result actions
        [[ ${rc} -ne 0 ]] &&
            $FailureMessage "${test} failed with return code: ${rc}" &&
            FAILED_TEST_CASES+=("${test}") &&
            returnCode=1 ||
            $SuccessMessage "${test} passed"
    done

    # Final test suite report
    [[ ${returnCode} -ne 0 ]] &&
        $ErrMessage "There were failed tests:" &&
        printf '%s\n' "${FAILED_TEST_CASES[@]}" ||
        $InfoMessage "All test cases passed"


    $InfoMessage "Test runner complete"
    exit ${returnCode}
}

Main "$@"

