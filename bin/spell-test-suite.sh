#Spell test suite

# Resource files
RESOURCE_DIR="../resources"
AMERICAN_TXT="${RESOURCE_DIR}/american-words.txt"
BRITISH_TXT="${RESOURCE_DIR}/british-words.txt"
MADEUP_DIC="${RESOURCE_DIR}/madeup-dictionary.txt"
MADEUP_TXT="${RESOURCE_DIR}/madeup-words.txt"
LINENUM_TXT="${RESOURCE_DIR}/line-number.test"
FILENAME_TXT="${RESOURCE_DIR}/file-name.test"

# Test cases

# T001
function testPrintISpellVersion() {
    local returnCode=0

    local ispellVersion="$(spell -I)"
    local ispellVersionLong="$(spell --ispell-version)"

    if [[ -z "${ispellVersion}" ]] ||
        [[ -z "${ispellVersionLong}" ]] || 
        [[ "${ispellVersion}" != "${ispellVersionLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES+=("testPrintISpellVersion")

# T002
function testPrintSpellVersion() {
    local returnCode=0

    local spellVersion="$(spell -V 2>&1)"
    local spellVersionLong="$(spell --version 2>&1)"

    if [[ -z "${spellVersion}" ]] ||
        [[ -z "${spellVersionLong}" ]] || 
        [[ "${spellVersion}" != "${spellVersionLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES+=("testPrintSpellVersion")

# T003
function testPrintHelp() {
    local returnCode=0

    local help="$(spell -h 2>&1)"
    local helpLong="$(spell --help 2>&1)"

    if [[ -z "${help}" ]] ||
        [[ -z "${helpLong}" ]] || 
        [[ "${help}" != "${helpLong}" ]]; then

        returnCode=1
    fi

    return ${returnCode}
}
TEST_CASES+=("testPrintHelp")

# T004
function testAmericanWordsWithAmericanDictionary() {
    local returnCode=0

    local expectedMisspelledWords=0
    local misspelledWords="$(spell ${AMERICAN_TXT} | xargs)"
    local actualMisspelledWords="$(echo ${misspelledWords} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES+=("testAmericanWordsWithAmericanDictionary")

# T005
function testAmericanWordsWithBritishDictionary() {
    local returnCode=0

    local misspelledWordsShort="$(spell -b ${AMERICAN_TXT} | xargs)"
    local misspelledWordsLong="$(spell --british ${AMERICAN_TXT} | xargs)"

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
TEST_CASES+=("testAmericanWordsWithBritishDictionary")

# T006
function testBritishWordsWithAmericanDictionary() {
    local returnCode=0

    local expectedMisspelledWords=14
    local misspelledWords="$(spell ${BRITISH_TXT} | xargs)"
    local actualMisspelledWords="$(echo ${misspelledWords} | wc -w)"

    if [[ ${actualMisspelledWords} -ne ${expectedMisspelledWords} ]]; then
        returnCode=1 &&
            $ErrMessage "Expected ${expectedMisspelledWords} misspelled words, actual ${actualMisspelledWords}: ${misspelledWords}"
    fi

    return ${returnCode}
}
TEST_CASES+=("testBritishWordsWithAmericanDictionary")

# T007
function testBritishWordsWithBritishDictionary() {
    local returnCode=0

    local misspelledWordsShort="$(spell -b ${BRITISH_TXT} | xargs)"
    local misspelledWordsLong="$(spell --british ${BRITISH_TXT} | xargs)"

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
TEST_CASES+=("testBritishWordsWithBritishDictionary")

# T008
function testMadeUpWordsInSpecifiedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$(spell -d ${MADEUP_DIC} ${MADEUP_TXT} | xargs)"
    local misspelledWordsLong="$(spell --dictionary=${MADEUP_DIC} ${MADEUP_TXT} | xargs)"

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
TEST_CASES+=("testMadeUpWordsInSpecifiedDictionary")

# T009
function testCorrectWordsInSpecifiedNamedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$(spell -D british ${BRITISH_TXT} | xargs)"
    local misspelledWordsLong="$(spell --ispell-dictionary=british ${BRITISH_TXT} | xargs)"

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
TEST_CASES+=("testCorrectWordsInSpecifiedNamedDictionary")

# T010
function testIncorrectWordsInSpecifiedNamedDictionary() {
    local returnCode=0

    local misspelledWordsShort="$(spell -D british ${AMERICAN_TXT} | xargs)"
    local misspelledWordsLong="$(spell --ispell-dictionary=british ${AMERICAN_TXT} | xargs)"

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
TEST_CASES+=("testIncorrectWordsInSpecifiedNamedDictionary")


# T011
function testUseDifferentProgram() {
    local returnCode=0

    local misspelledWordsShort="$(spell -i echo echo_pgm_test)"
    local misspelledWordsLong="$(spell --ispell=echo echo_pgm_test)"

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
#TEST_CASES+=("testUseDifferentProgram")

# T012
function testVerifyLineNumbers() {
    local returnCode=0

    local expected="$(cat ${LINENUM_TXT} | xargs)"
    local actualShort="$(spell -n ${BRITISH_TXT} | xargs)"
    local actualLong="$(spell --number ${BRITISH_TXT} | xargs)"

    [[ "${actualShort}" != "${actualLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${actualShort}, long: ${actualLong}"

    if [[ "${actualShort}" != "${expected}" ]]; then
        returnCode=1 &&
            $ErrMessage "Expected: ${expected}, actual: ${actualShort}: ${actualShort}"
    fi

    return ${returnCode}
}
TEST_CASES+=("testVerifyLineNumbers")

# T013
function testVerifyFileNames() {
    local returnCode=0

    local expected="$(cat ${FILENAME_TXT} | xargs)"
    local actualShort="$(spell -o ${RESOURCE_DIR}/*.txt | xargs)"
    local actualLong="$(spell --print-file-name ${RESOURCE_DIR}/*.txt | xargs)"

    [[ "${actualShort}" != "${actualLong}" ]] &&
        returnCode=1 &&
        $ErrMessage "Short option output does not equal long option output, short: ${actualShort}, long: ${actualLong}"

    if [[ "${actualShort}" != "${expected}" ]]; then
        returnCode=1 &&
            $ErrMessage "Expected: ${expected}, actual: ${actualShort}: ${actualShort}"
    fi

    return ${returnCode}
}
TEST_CASES+=("testVerifyFileNames")

