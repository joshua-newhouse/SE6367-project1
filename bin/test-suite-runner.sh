#!/bin/bash

#Test suite runner
# Pass test suite file as first command line argument

#Logging
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ErrMessage='eval echo -e "${RED}$(date +%F\ %T) [ERROR] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
WarnMessage='eval echo -e "${YELLOW}$(date +%F\ %T") [WARN] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
InfoMessage='eval echo -e "${NC}$(date +%F\ %T) [INFO] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'

#Additional logging for tests
T_GREEN='\033[1;32m'
T_RED='\033[1;31m'

SuccessMessage='eval echo -e "${T_GREEN}$(date +%F\ %T) [SUCCESS] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'
FailureMessage='eval echo -e "${T_RED}$(date +%F\ %T) [FAILURE] - $(basename $0)/${FUNCNAME[0]},${LINENO[0]}: "'

declare -A TEST_CASES
declare -a FAILED_TEST_CASES

# Verify command line args
[[ $# -ne 2 ]] &&
    $ErrMessage "Invalid number of command line arguments" && 
    echo -e "${NC}usage: $(basename $0) \<test-suite-to-run\> \<path to test program\>\n" \
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
        $InfoMessage "Running ${testCase}::${test}"

        "${test}"
        local rc=$?

        # Test case result actions
        [[ ${rc} -ne 0 ]] &&
            $FailureMessage "${testCase}::${test} failed with return code: ${rc}" &&
            FAILED_TEST_CASES+=("${testCase}::${test}") &&
            returnCode=1 ||
            $SuccessMessage "${testCase}::${test} passed"
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

