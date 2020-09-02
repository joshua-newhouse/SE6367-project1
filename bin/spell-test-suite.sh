#Spell test suite

# Resource files
RESOURCE_DIR="../resources"
AMERICAN_TXT="${RESOURCE_DIR}/american-words.txt"
BRITISH_TXT="${RESOURCE_DIR}/british-words.txt"
MADEUP_DIC="${RESOURCE_DIR}/madeup-dictionary.txt"
MADEUP_TXT="${RESOURCE_DIR}/madeup-words.txt"
LINENUM_TXT="${RESOURCE_DIR}/line-number.test"
FILENAME_TXT="${RESOURCE_DIR}/file-name.test"

# Verify spell program is present
SPELL_EXE="${1}"
[[ ! -x "${SPELL_EXE}" ]] &&
    $ErrMessage "Cannot find executable 'spell' at specified path: ${SPELL_EXE}.  Verify the path and make sure it is executable." &&
    exit 1

# Test cases

# T001
function testPrintISpellVersion() {
    local returnCode=0

    local ispellVersion="$("${SPELL_EXE}" -I)"
    local ispellVersionLong="$("${SPELL_EXE}" --ispell-version)"

    if [[ -z "${ispellVersion}" ]] ||
        [[ -z "${ispellVersionLong}" ]] || 
        [[ "${ispellVersion}" != "${ispellVersionLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES["T001"]="testPrintISpellVersion"

# T002
function testPrintSpellVersion() {
    local returnCode=0

    local spellVersion="$("${SPELL_EXE}" -V 2>&1)"
    local spellVersionLong="$("${SPELL_EXE}" --version 2>&1)"

    if [[ -z "${spellVersion}" ]] ||
        [[ -z "${spellVersionLong}" ]] || 
        [[ "${spellVersion}" != "${spellVersionLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES["T002"]="testPrintSpellVersion"

# T003
function testPrintHelp() {
    local returnCode=0

    local help="$("${SPELL_EXE}" -h 2>&1)"
    local helpLong="$("${SPELL_EXE}" --help 2>&1)"

    if [[ -z "${help}" ]] ||
        [[ -z "${helpLong}" ]] || 
        [[ "${help}" != "${helpLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES["T003"]="testPrintHelp"

# T004
function testAmericanWordsWithAmericanDictionary() {
    local returnCode=0

    local expectedMisspelledWords=0
    local misspelledWords="$("${SPELL_EXE}" ${AMERICAN_TXT} | xargs)"
    local actualMisspelledWords="$(echo ${misspelledWords} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T004"]="testAmericanWordsWithAmericanDictionary"

# T005
function testAmericanWordsWithBritishDictionary() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -b ${AMERICAN_TXT} | xargs)"
    local misspelledWordsLong="$("${SPELL_EXE}" --british ${AMERICAN_TXT} | xargs)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=14
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T005"]="testAmericanWordsWithBritishDictionary"

# T006
function testBritishWordsWithAmericanDictionary() {
    local returnCode=0

    local expectedMisspelledWords=14
    local misspelledWords="$("${SPELL_EXE}" ${BRITISH_TXT} | xargs)"
    local actualMisspelledWords="$(echo ${misspelledWords} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T006"]="testBritishWordsWithAmericanDictionary"

# T007
function testBritishWordsWithBritishDictionary() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -b ${BRITISH_TXT} | xargs)"
    local misspelledWordsLong="$("${SPELL_EXE}" --british ${BRITISH_TXT} | xargs)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=0
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T007"]="testBritishWordsWithBritishDictionary"

# T008
function testMadeUpWordsInSpecifiedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -d ${MADEUP_DIC} ${MADEUP_TXT} | xargs)"
    local misspelledWordsLong="$("${SPELL_EXE}" --dictionary=${MADEUP_DIC} ${MADEUP_TXT} | xargs)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=1
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T008"]="testMadeUpWordsInSpecifiedDictionary"

# T009
function testCorrectWordsInSpecifiedNamedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -D british ${BRITISH_TXT} | xargs)"
    local misspelledWordsLong="$("${SPELL_EXE}" --ispell-dictionary=british ${BRITISH_TXT} | xargs)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=0
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T009"]="testCorrectWordsInSpecifiedNamedDictionary"

# T010
function testIncorrectWordsInSpecifiedNamedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -D british ${AMERICAN_TXT} | xargs)"
    local misspelledWordsLong="$("${SPELL_EXE}" --ispell-dictionary=british ${AMERICAN_TXT} | xargs)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=14
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES["T010"]="testIncorrectWordsInSpecifiedNamedDictionary"


# T011
function testUseDifferentProgram() {
    local returnCode=0

    local misspelledWordsShort="$("${SPELL_EXE}" -i echo echo_pgm_test)"
    local misspelledWordsLong="$("${SPELL_EXE}" --ispell=echo echo_pgm_test)"

    [[ "${misspelledWordsShort}" != "${misspelledWordsLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${misspelledWordsShort}, long: ${misspelledWordsLong}"
        
    local expectedMisspelledWords=14
    local actualMisspelledWords="$(echo ${misspelledWordsShort} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
#TEST_CASES["T011"]="testUseDifferentProgram"

# T012
function testVerifyLineNumbers() {
    local returnCode=0

    local expected="$(cat ${LINENUM_TXT} | xargs)"
    local actualShort="$("${SPELL_EXE}" -n ${MADEUP_TXT} | xargs)"
    local actualLong="$("${SPELL_EXE}" --number ${MADEUP_TXT} | xargs)"

    [[ "${actualShort}" != "${actualLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${actualShort}, long: ${actualLong}"

    if [[ "${actualShort}" != "${expected}" ]]; then
        returnCode=1 &&
            $ErrMessage "Expected: ${expected}, actual: ${actualShort}: ${actualShort}"
    fi

    return ${returnCode}
}
TEST_CASES["T012"]="testVerifyLineNumbers"

# T013
function testVerifyFileNames() {
    local returnCode=0

    local expected="$(cat ${FILENAME_TXT} | xargs)"
    local actualShort="$("${SPELL_EXE}" -o ${RESOURCE_DIR}/madeup-*.txt | xargs)"
    local actualLong="$("${SPELL_EXE}" --print-file-name ${RESOURCE_DIR}/madeup-*.txt | xargs)"

    [[ "${actualShort}" != "${actualLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${actualShort}, long: ${actualLong}"

    if [[ "${actualShort}" != "${expected}" ]]; then
        returnCode=1 &&
            $ErrMessage "Expected: ${expected}, actual: ${actualShort}: ${actualShort}"
    fi

    return ${returnCode}
}
TEST_CASES["T013"]="testVerifyFileNames"

