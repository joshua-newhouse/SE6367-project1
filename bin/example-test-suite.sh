#Spell test suite

#Additional logging for tests
T_GREEN='\033[1;32m'
T_RED='\033[1;31m'

SuccessMessage='eval echo -e "${T_GREEN}$(date +"%Y-%m-%d %T") [SUCCESS] - ${FUNCNAME[0]},${LINENO[0]}: "'
FailureMessage='eval echo -e "${T_RED}$(date +"%Y-%m-%d %T") [FAILURE] - ${FUNCNAME[0]},${LINENO[0]}: "'

# Test cases

function Test1() {
    return 1
}
TEST_CASES["T001"]="Test1"

function Test2() {
    return 0
}
TEST_CASES["T002"]="Test2"

