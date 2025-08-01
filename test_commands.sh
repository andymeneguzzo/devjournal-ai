#!/bin/bash

# DevJournal AI Backend API Testing Script
# Tests authentication and CRUD operations with extensive logging

# Colors for enhanced output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# API Configuration
API_URL="http://localhost:5001"
TEST_EMAIL="test@example.com"
TEST_PASSWORD="testpassword123"
TEST_EMAIL2="test2@example.com"

# Test Statistics
TOTAL_TESTS=18
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

echo -e "${WHITE}========================================${NC}"
echo -e "${BLUE}🚀 DevJournal AI Backend API Test Suite${NC}"
echo -e "${WHITE}========================================${NC}"
echo -e "${GRAY}Started at: $(date)${NC}"
echo -e "${GRAY}Target API: $API_URL${NC}"
echo -e "${GRAY}Total Tests: $TOTAL_TESTS${NC}"
echo -e "${WHITE}========================================${NC}"
echo

# Enhanced cleanup function with verification
cleanup_test_data() {
    echo -e "${YELLOW}🧹 Pre-Test Cleanup & Environment Setup${NC}"
    echo -e "${GRAY}----------------------------------------${NC}"
    
    # Check if data directory exists
    if [ ! -d "server/data" ]; then
        echo -e "${RED}❌ Error: server/data directory not found!${NC}"
        echo -e "${RED}💡 Hint: Run this script from the project root directory${NC}"
        exit 1
    fi
    
    # Reset users.json to empty array
    echo "[]" > server/data/users.json
    echo "[]" > server/data/entries.json
    
    # Verify cleanup
    local users_content=$(cat server/data/users.json)
    local entries_content=$(cat server/data/entries.json)
    
    if [[ "$users_content" == "[]" ]] && [[ "$entries_content" == "[]" ]]; then
        echo -e "${GREEN}✅ Test data successfully reset${NC}"
        echo -e "${GRAY}   - users.json: empty array${NC}"
        echo -e "${GRAY}   - entries.json: empty array${NC}"
    else
        echo -e "${RED}❌ Failed to reset test data${NC}"
        echo -e "${RED}💡 Check file permissions in server/data/ directory${NC}"
        exit 1
    fi
    echo
}

# Enhanced function to print test results with statistics
print_result() {
    local status=$1
    local test_name="$2"
    local test_num="$3"
    local duration="$4"
    
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC} [${test_num}/${TOTAL_TESTS}] ${test_name}"
        if [ ! -z "$duration" ]; then
            echo -e "${GRAY}   ⏱️  Duration: ${duration}ms${NC}"
        fi
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ FAIL${NC} [${test_num}/${TOTAL_TESTS}] ${test_name}"
        if [ ! -z "$duration" ]; then
            echo -e "${GRAY}   ⏱️  Duration: ${duration}ms${NC}"
        fi
        ((FAILED_TESTS++))
    fi
    echo
}

# Cross-platform milliseconds function
get_milliseconds() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    elif command -v node >/dev/null 2>&1; then
        node -e "console.log(Date.now())"
    else
        # Fallback to seconds * 1000
        echo $(($(date +%s) * 1000))
    fi
}

# Enhanced API call function with comprehensive logging
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="$4"
    local test_name="$5"
    local start_time=$(get_milliseconds)
    
    # Enhanced request logging
    echo -e "${CYAN}📤 REQUEST DETAILS${NC}" >&2
    echo -e "${GRAY}   Method: ${WHITE}$method${NC}" >&2
    echo -e "${GRAY}   Endpoint: ${WHITE}$endpoint${NC}" >&2
    echo -e "${GRAY}   Full URL: ${WHITE}$API_URL$endpoint${NC}" >&2
    
    if [ ! -z "$data" ]; then
        echo -e "${GRAY}   Payload: ${WHITE}$data${NC}" >&2
    else
        echo -e "${GRAY}   Payload: ${GRAY}(none)${NC}" >&2
    fi
    
    if [ ! -z "$auth_header" ]; then
        echo -e "${GRAY}   Auth: ${WHITE}Bearer ${auth_header:0:20}...${NC}" >&2
    else
        echo -e "${GRAY}   Auth: ${GRAY}(none)${NC}" >&2
    fi
    
    # Build and execute curl command
    local curl_cmd="curl -s -w \"HTTP_STATUS:%{http_code}|TIME:%{time_total}|SIZE:%{size_download}\" -X $method \"$API_URL$endpoint\""
    
    if [ ! -z "$data" ]; then
        curl_cmd="$curl_cmd -H \"Content-Type: application/json\" -d '$data'"
    fi
    
    if [ ! -z "$auth_header" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $auth_header\""
    fi
    
    echo -e "${PURPLE}🔧 Executing: ${GRAY}$curl_cmd${NC}" >&2
    
    # Execute request and capture response
    local response=$(eval $curl_cmd 2>/dev/null)
    local end_time=$(get_milliseconds)
    local duration=$((end_time - start_time))
    
    # Parse response metadata
    local http_info=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*|TIME:[0-9.]*|SIZE:[0-9]*" | tail -1)
    local http_status=""
    local time_total=""
    local size_download=""
    
    if [ ! -z "$http_info" ]; then
        http_status=$(echo "$http_info" | grep -o "HTTP_STATUS:[0-9]*" | cut -d':' -f2)
        time_total=$(echo "$http_info" | grep -o "TIME:[0-9.]*" | cut -d':' -f2)
        size_download=$(echo "$http_info" | grep -o "SIZE:[0-9]*" | cut -d':' -f2)
    fi
    
    # Clean response body
    local clean_response=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*|TIME:[0-9.]*|SIZE:[0-9]*$//')
    
    # Enhanced response logging
    echo -e "${CYAN}📥 RESPONSE DETAILS${NC}" >&2
    echo -e "${GRAY}   Status Code: ${WHITE}${http_status:-"unknown"}${NC}" >&2
    echo -e "${GRAY}   Response Time: ${WHITE}${time_total:-"unknown"}s${NC}" >&2
    echo -e "${GRAY}   Response Size: ${WHITE}${size_download:-"unknown"} bytes${NC}" >&2
    echo -e "${GRAY}   Total Duration: ${WHITE}${duration}ms${NC}" >&2
    
    # Status code analysis
    case "$http_status" in
        200) echo -e "${GRAY}   Status: ${GREEN}✅ OK${NC}" >&2 ;;
        201) echo -e "${GRAY}   Status: ${GREEN}✅ Created${NC}" >&2 ;;
        400) echo -e "${GRAY}   Status: ${YELLOW}⚠️  Bad Request${NC}" >&2 ;;
        401) echo -e "${GRAY}   Status: ${YELLOW}🔒 Unauthorized${NC}" >&2 ;;
        403) echo -e "${GRAY}   Status: ${YELLOW}🚫 Forbidden${NC}" >&2 ;;
        404) echo -e "${GRAY}   Status: ${YELLOW}❓ Not Found${NC}" >&2 ;;
        500) echo -e "${GRAY}   Status: ${RED}💥 Server Error${NC}" >&2 ;;
        000|"") echo -e "${GRAY}   Status: ${RED}🔥 Connection Failed${NC}" >&2 ;;
        *) echo -e "${GRAY}   Status: ${PURPLE}❔ Unknown ($http_status)${NC}" >&2 ;;
    esac
    
    # Response body preview
    if [ ! -z "$clean_response" ]; then
        local preview="${clean_response:0:100}"
        if [ ${#clean_response} -gt 100 ]; then
            preview="${preview}..."
        fi
        echo -e "${GRAY}   Body Preview: ${WHITE}$preview${NC}" >&2
    else
        echo -e "${GRAY}   Body: ${RED}(empty)${NC}" >&2
    fi
    
    # Error analysis and suggestions
    if [ -z "$clean_response" ] && [ "$http_status" != "000" ] && [ ! -z "$http_status" ]; then
        echo -e "${RED}🚨 ISSUE DETECTED: Empty response with non-zero status${NC}" >&2
        echo -e "${RED}💡 Suggestion: Check server logs for unhandled exceptions${NC}" >&2
    fi
    
    if [ "$http_status" = "000" ] || [ -z "$http_status" ]; then
        echo -e "${RED}🚨 CRITICAL: Connection failed${NC}" >&2
        echo -e "${RED}💡 Suggestions:${NC}" >&2
        echo -e "${RED}   1. Verify server is running: ps aux | grep node${NC}" >&2
        echo -e "${RED}   2. Check if port 5001 is in use: lsof -i :5001${NC}" >&2
        echo -e "${RED}   3. Review server startup logs for errors${NC}" >&2
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    
    # Store duration for test statistics
    echo "$duration" > /tmp/last_test_duration 2>/dev/null || true
    
    # Return clean response
    echo "$clean_response"
}

# Utility functions
extract_token() {
    echo "$1" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

extract_message() {
    echo "$1" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
}

get_test_duration() {
    if [ -f /tmp/last_test_duration ]; then
        cat /tmp/last_test_duration 2>/dev/null || echo "0"
        rm /tmp/last_test_duration 2>/dev/null || true
    else
        echo "0"
    fi
}

# Print test category header
print_category_header() {
    local category="$1"
    echo -e "${WHITE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║ ${BLUE}$category${WHITE} ║${NC}"
    echo -e "${WHITE}╚════════════════════════════════════════════════╝${NC}"
    echo
}

# Initialize test environment
cleanup_test_data

# TEST CATEGORY 1: Authentication & Authorization
print_category_header "Authentication & Authorization Tests (1-6)"

# Test 1: Register new user with valid data
echo -e "${BLUE}Test 1: Register new user with valid data${NC}"
echo -e "${GRAY}Purpose: Verify user registration with valid email and password${NC}"
echo -e "${GRAY}Expected: 201 status, 'Registration successful' message${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "User Registration")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "Registration successful" ]]; then
    print_result 0 "User registration with valid data" "1" "$duration"
else
    print_result 1 "User registration with valid data" "1" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Registration successful'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
    echo -e "${RED}   Full response: $response${NC}"
fi

# Test 2: Try to register same user again (should fail)
echo -e "${BLUE}Test 2: Try to register duplicate user${NC}"
echo -e "${GRAY}Purpose: Verify duplicate email prevention${NC}"
echo -e "${GRAY}Expected: 400 status, 'User already exists' message${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "Duplicate Registration")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "User already exists" ]]; then
    print_result 0 "Duplicate user registration prevention" "2" "$duration"
else
    print_result 1 "Duplicate user registration prevention" "2" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'User already exists'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
fi

# Test 3: Register with missing data
echo -e "${BLUE}Test 3: Register with missing email${NC}"
echo -e "${GRAY}Purpose: Verify input validation for missing required fields${NC}"
echo -e "${GRAY}Expected: 400 status, 'Email and password required' message${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"password\":\"$TEST_PASSWORD\"}" "" "Missing Email Validation")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "Email and password required" ]]; then
    print_result 0 "Missing email validation" "3" "$duration"
else
    print_result 1 "Missing email validation" "3" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Email and password required'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
    if [ -z "$response" ]; then
        echo -e "${RED}   🚨 Server appears to have crashed! Check server logs.${NC}"
    fi
fi

# Test 4: Login with valid credentials
echo -e "${BLUE}Test 4: Login with valid credentials${NC}"
echo -e "${GRAY}Purpose: Verify successful authentication and JWT token generation${NC}"
echo -e "${GRAY}Expected: 200 status, 'Login successful' message, valid JWT token${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "User Login")
duration=$(get_test_duration)

message=$(extract_message "$response")
TOKEN=$(extract_token "$response")

if [[ "$message" == "Login successful" ]] && [[ -n "$TOKEN" ]]; then
    print_result 0 "User login with valid credentials" "4" "$duration"
    echo -e "${BLUE}🔑 JWT Token acquired: ${TOKEN:0:20}...${NC}"
    echo -e "${GRAY}   Token length: ${#TOKEN} characters${NC}"
    echo
else
    print_result 1 "User login with valid credentials" "4" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Login successful'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
    echo -e "${RED}   Token present: $([ -n "$TOKEN" ] && echo "Yes" || echo "No")${NC}"
    echo -e "${RED}⚠️  Cannot continue with authenticated tests without token${NC}"
    echo -e "${RED}🛑 Stopping test execution${NC}"
    exit 1
fi

# Test 5: Login with wrong password
echo -e "${BLUE}Test 5: Login with wrong password${NC}"
echo -e "${GRAY}Purpose: Verify password validation and security${NC}"
echo -e "${GRAY}Expected: 400 status, 'Wrong password' message${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"$TEST_EMAIL\",\"password\":\"wrongpassword\"}" "" "Wrong Password Test")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "Wrong password" ]]; then
    print_result 0 "Wrong password rejection" "5" "$duration"
else
    print_result 1 "Wrong password rejection" "5" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Wrong password'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
fi

# Test 6: Login with non-existent user
echo -e "${BLUE}Test 6: Login with non-existent user${NC}"
echo -e "${GRAY}Purpose: Verify user existence validation${NC}"
echo -e "${GRAY}Expected: 400 status, \"User doesn't exist\" message${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"nonexistent@example.com\",\"password\":\"$TEST_PASSWORD\"}" "" "Non-existent User Test")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "User doesn't exist" ]]; then
    print_result 0 "Non-existent user rejection" "6" "$duration"
else
    print_result 1 "Non-existent user rejection" "6" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: \"User doesn't exist\"${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
fi

# TEST CATEGORY 2: Basic Security & Empty State
print_category_header "Basic Security & Empty State Tests (7-8)"

# Test 7: Get entries without token
echo -e "${BLUE}Test 7: Get entries without authentication${NC}"
echo -e "${GRAY}Purpose: Verify JWT middleware protection${NC}"
echo -e "${GRAY}Expected: 401 status, authentication error${NC}"
response=$(make_api_call "GET" "/journal" "" "" "Unauthorized Access Test")
duration=$(get_test_duration)
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_URL/journal" 2>/dev/null)

if [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized access prevention" "7" "$duration"
else
    print_result 1 "Unauthorized access prevention" "7" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected HTTP code: 401${NC}"
    echo -e "${RED}   Actual HTTP code: $http_code${NC}"
    echo -e "${RED}   🚨 Security issue: Unauthenticated access allowed!${NC}"
fi

# Test 8: Get entries with valid token (empty state)
echo -e "${BLUE}Test 8: Get entries with valid token (empty state)${NC}"
echo -e "${GRAY}Purpose: Verify authenticated access and empty journal state${NC}"
echo -e "${GRAY}Expected: 200 status, empty array []${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Get Empty Entries")
duration=$(get_test_duration)

if [[ "$response" == "[]" ]]; then
    print_result 0 "Get empty entries list" "8" "$duration"
else
    print_result 1 "Get empty entries list" "8" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected: []${NC}"
    echo -e "${RED}   Actual: $response${NC}"
    echo -e "${RED}   🚨 Database not properly cleaned or filtered!${NC}"
fi

# TEST CATEGORY 3: Entry Creation & Validation
print_category_header "Entry Creation & Validation Tests (9-11)"

# Test 9: Create first journal entry
echo -e "${BLUE}Test 9: Create first journal entry${NC}"
echo -e "${GRAY}Purpose: Verify entry creation with valid data${NC}"
echo -e "${GRAY}Expected: 201 status, entry object with ID, text, userId, date${NC}"
ENTRY_TEXT1="This is my first test journal entry. Testing the API!"
response=$(make_api_call "POST" "/journal" "{\"text\":\"$ENTRY_TEXT1\"}" "$TOKEN" "Create First Entry")
duration=$(get_test_duration)

entry_text=$(echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4)
ENTRY_ID1=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [[ "$entry_text" == "$ENTRY_TEXT1" ]] && [[ -n "$ENTRY_ID1" ]]; then
    print_result 0 "Create first journal entry" "9" "$duration"
    echo -e "${BLUE}📄 Created entry ID: $ENTRY_ID1${NC}"
    echo -e "${GRAY}   Entry text verified: ✅${NC}"
    echo -e "${GRAY}   Entry ID assigned: ✅${NC}"
    echo
else
    print_result 1 "Create first journal entry" "9" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected text: '$ENTRY_TEXT1'${NC}"
    echo -e "${RED}   Actual text: '$entry_text'${NC}"
    echo -e "${RED}   Entry ID present: $([ -n "$ENTRY_ID1" ] && echo "Yes ($ENTRY_ID1)" || echo "No")${NC}"
    echo -e "${RED}   Full response: $response${NC}"
fi

# Test 10: Create second journal entry
echo -e "${BLUE}Test 10: Create second journal entry${NC}"
echo -e "${GRAY}Purpose: Verify multiple entries support and ID uniqueness${NC}"
echo -e "${GRAY}Expected: 201 status, new entry with different ID${NC}"
ENTRY_TEXT2="This is my second journal entry. The API is working great!"
response=$(make_api_call "POST" "/journal" "{\"text\":\"$ENTRY_TEXT2\"}" "$TOKEN" "Create Second Entry")
duration=$(get_test_duration)

entry_text=$(echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4)
ENTRY_ID2=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [[ "$entry_text" == "$ENTRY_TEXT2" ]] && [[ -n "$ENTRY_ID2" ]] && [[ "$ENTRY_ID2" != "$ENTRY_ID1" ]]; then
    print_result 0 "Create second journal entry" "10" "$duration"
    echo -e "${BLUE}📄 Created entry ID: $ENTRY_ID2${NC}"
    echo -e "${GRAY}   Entry text verified: ✅${NC}"
    echo -e "${GRAY}   Unique ID assigned: ✅ (different from $ENTRY_ID1)${NC}"
    echo
else
    print_result 1 "Create second journal entry" "10" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected text: '$ENTRY_TEXT2'${NC}"
    echo -e "${RED}   Actual text: '$entry_text'${NC}"
    echo -e "${RED}   Entry ID present: $([ -n "$ENTRY_ID2" ] && echo "Yes ($ENTRY_ID2)" || echo "No")${NC}"
    echo -e "${RED}   ID uniqueness: $([ "$ENTRY_ID2" != "$ENTRY_ID1" ] && echo "✅" || echo "❌ Duplicate ID!")${NC}"
    if [ -z "$response" ]; then
        echo -e "${RED}   🚨 Empty response indicates server crash!${NC}"
    fi
fi

# Test 11: Create entry with empty text
echo -e "${BLUE}Test 11: Create entry with empty text${NC}"
echo -e "${GRAY}Purpose: Verify input validation for empty content${NC}"
echo -e "${GRAY}Expected: 400 status, 'Entry cannot be empty' message${NC}"
response=$(make_api_call "POST" "/journal" "{\"text\":\"\"}" "$TOKEN" "Empty Text Validation")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "Entry cannot be empty" ]]; then
    print_result 0 "Empty entry validation" "11" "$duration"
else
    print_result 1 "Empty entry validation" "11" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Entry cannot be empty'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
    if [ -z "$response" ]; then
        echo -e "${RED}   🚨 Server crash on empty text validation!${NC}"
    fi
fi

# TEST CATEGORY 4: Entry Management & Error Handling
print_category_header "Entry Management & Error Handling Tests (12-16)"

# Test 12: Get all entries (should return 2 entries)
echo -e "${BLUE}Test 12: Get all entries${NC}"
echo -e "${GRAY}Purpose: Verify entry retrieval and count${NC}"
echo -e "${GRAY}Expected: 200 status, array with 2 entries${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Get All Entries")
duration=$(get_test_duration)

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "2" ]]; then
    print_result 0 "Get all entries (count verification)" "12" "$duration"
    echo -e "${GRAY}   Entries found: $entry_count ✅${NC}"
else
    print_result 1 "Get all entries (count verification)" "12" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected count: 2${NC}"
    echo -e "${RED}   Actual count: $entry_count${NC}"
    echo -e "${RED}   Response: $response${NC}"
fi

# Test 13: Delete first entry
echo -e "${BLUE}Test 13: Delete first entry${NC}"
echo -e "${GRAY}Purpose: Verify entry deletion functionality${NC}"
echo -e "${GRAY}Expected: 200 status, 'Entry removed successfully' message${NC}"
if [[ -n "$ENTRY_ID1" ]]; then
    response=$(make_api_call "DELETE" "/journal/$ENTRY_ID1" "" "$TOKEN" "Delete First Entry")
    duration=$(get_test_duration)
    
    message=$(extract_message "$response")
    if [[ "$message" == "Entry removed successfully" ]]; then
        print_result 0 "Delete journal entry" "13" "$duration"
        echo -e "${GRAY}   Deleted entry ID: $ENTRY_ID1 ✅${NC}"
    else
        print_result 1 "Delete journal entry" "13" "$duration"
        echo -e "${RED}💡 Debug Info:${NC}"
        echo -e "${RED}   Entry ID used: $ENTRY_ID1${NC}"
        echo -e "${RED}   Expected message: 'Entry removed successfully'${NC}"
        echo -e "${RED}   Actual message: '$message'${NC}"
    fi
else
    print_result 1 "Delete journal entry" "13" "0"
    echo -e "${RED}🚨 Cannot delete: ENTRY_ID1 is empty (previous test failed)${NC}"
fi

# Test 14: Verify entry deletion (should return 1 entry)
echo -e "${BLUE}Test 14: Verify entry deletion${NC}"
echo -e "${GRAY}Purpose: Confirm deletion was successful${NC}"
echo -e "${GRAY}Expected: 200 status, array with 1 entry${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Verify Entry Deletion")
duration=$(get_test_duration)

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "1" ]]; then
    print_result 0 "Entry deletion verification" "14" "$duration"
    echo -e "${GRAY}   Remaining entries: $entry_count ✅${NC}"
else
    print_result 1 "Entry deletion verification" "14" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected remaining: 1${NC}"
    echo -e "${RED}   Actual remaining: $entry_count${NC}"
    echo -e "${RED}   🚨 Entry was not properly deleted!${NC}"
fi

# Test 15: Try to delete non-existent entry
echo -e "${BLUE}Test 15: Try to delete non-existent entry${NC}"
echo -e "${GRAY}Purpose: Verify error handling for invalid entry IDs${NC}"
echo -e "${GRAY}Expected: 404 status, 'Entry not found or unathorized' message${NC}"
response=$(make_api_call "DELETE" "/journal/999999" "" "$TOKEN" "Non-existent Entry Deletion")
duration=$(get_test_duration)

message=$(extract_message "$response")
if [[ "$message" == "Entry not found or unathorized" ]]; then
    print_result 0 "Non-existent entry deletion prevention" "15" "$duration"
else
    print_result 1 "Non-existent entry deletion prevention" "15" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected message: 'Entry not found or unathorized'${NC}"
    echo -e "${RED}   Actual message: '$message'${NC}"
fi

# Test 16: Try to delete entry without authentication
echo -e "${BLUE}Test 16: Try to delete entry without authentication${NC}"
echo -e "${GRAY}Purpose: Verify authentication requirement for deletion${NC}"
echo -e "${GRAY}Expected: 401 or 404 status (both indicate proper security)${NC}"
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL/journal/999999" 2>/dev/null)

if [[ "$http_code" == "404" ]] || [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized delete prevention" "16" "N/A"
    echo -e "${GRAY}   Security status: $http_code ✅${NC}"
else
    print_result 1 "Unauthorized delete prevention" "16" "N/A"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected: 401 or 404${NC}"
    echo -e "${RED}   Actual: $http_code${NC}"
    echo -e "${RED}   🚨 Security vulnerability: Unauthorized deletion allowed!${NC}"
fi

# TEST CATEGORY 5: Cleanup & Data Integrity
print_category_header "Cleanup & Data Integrity Tests (17-18)"

# Test 17: Clean up remaining entries
echo -e "${BLUE}Test 17: Clean up remaining entries${NC}"
echo -e "${GRAY}Purpose: Remove all test data and verify cleanup functionality${NC}"
echo -e "${GRAY}Expected: Successful deletion of all remaining entries${NC}"

# Get current entries for smart cleanup
echo -e "${PURPLE}🔍 Scanning for entries to clean up...${NC}" >&2
cleanup_response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Get Entries for Cleanup")
entry_ids=$(echo "$cleanup_response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [ -z "$entry_ids" ]; then
    echo -e "${GRAY}📝 No entries found to clean up${NC}"
    print_result 0 "Cleanup: No entries to delete" "17" "0"
else
    echo -e "${GRAY}🗑️  Found entries to delete: $entry_ids${NC}"
    cleanup_success=true
    total_deleted=0
    
    for entry_id in $entry_ids; do
        echo -e "${PURPLE}🗑️ Deleting entry ID: $entry_id${NC}" >&2
        response=$(make_api_call "DELETE" "/journal/$entry_id" "" "$TOKEN" "Cleanup: Delete Entry $entry_id")
        message=$(extract_message "$response")
        if [[ "$message" == "Entry removed successfully" ]]; then
            ((total_deleted++))
            echo -e "${GRAY}   ✅ Entry $entry_id deleted${NC}"
        else
            cleanup_success=false
            echo -e "${RED}   ❌ Failed to delete entry $entry_id${NC}"
            break
        fi
    done
    
    if [ "$cleanup_success" = true ]; then
        print_result 0 "Cleanup: Delete remaining entries" "17" "N/A"
        echo -e "${GRAY}   Total entries deleted: $total_deleted ✅${NC}"
    else
        print_result 1 "Cleanup: Delete remaining entries" "17" "N/A"
        echo -e "${RED}💡 Failed during deletion of entry $entry_id${NC}"
    fi
fi

# Test 18: Verify all entries are deleted
echo -e "${BLUE}Test 18: Verify all entries deleted${NC}"
echo -e "${GRAY}Purpose: Confirm complete cleanup and data integrity${NC}"
echo -e "${GRAY}Expected: 200 status, empty array []${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Verify All Entries Deleted")
duration=$(get_test_duration)

if [[ "$response" == "[]" ]]; then
    print_result 0 "All entries cleaned up" "18" "$duration"
    echo -e "${GRAY}   Database state: Clean ✅${NC}"
else
    print_result 1 "All entries cleaned up" "18" "$duration"
    echo -e "${RED}💡 Debug Info:${NC}"
    echo -e "${RED}   Expected: []${NC}"
    echo -e "${RED}   Actual: $response${NC}"
    echo -e "${RED}   🚨 Cleanup incomplete! Data integrity issue.${NC}"
fi

# FINAL SUMMARY AND STATISTICS
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))

echo
echo -e "${WHITE}════════════════════════════════════════════════${NC}"
echo -e "${WHITE}🎉 TEST SUITE EXECUTION COMPLETE${NC}"
echo -e "${WHITE}════════════════════════════════════════════════${NC}"
echo -e "${GRAY}Completed at: $(date)${NC}"
echo -e "${GRAY}Total execution time: ${TOTAL_DURATION}s${NC}"
echo
echo -e "${WHITE}📊 DETAILED STATISTICS:${NC}"
echo -e "${GREEN}✅ Passed: $PASSED_TESTS/$TOTAL_TESTS tests${NC}"
echo -e "${RED}❌ Failed: $FAILED_TESTS/$TOTAL_TESTS tests${NC}"
echo -e "${BLUE}📈 Success Rate: $SUCCESS_RATE%${NC}"
echo

# Success rate analysis
if [ $SUCCESS_RATE -eq 100 ]; then
    echo -e "${GREEN}🏆 EXCELLENT! All tests passed. API is production-ready!${NC}"
elif [ $SUCCESS_RATE -ge 90 ]; then
    echo -e "${YELLOW}🥈 GOOD! High success rate. Minor issues need attention.${NC}"
elif [ $SUCCESS_RATE -ge 70 ]; then
    echo -e "${YELLOW}🥉 ACCEPTABLE! Some issues present. Review failed tests.${NC}"
else
    echo -e "${RED}🚨 CRITICAL! Major issues detected. Immediate fixes required.${NC}"
fi

echo
echo -e "${WHITE}💡 NEXT STEPS:${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${GRAY}1. Review failed test details above${NC}"
    echo -e "${GRAY}2. Check server logs for additional error context${NC}"
    echo -e "${GRAY}3. Fix identified issues and re-run tests${NC}"
    echo -e "${GRAY}4. Ensure 90%+ success rate before production deployment${NC}"
else
    echo -e "${GRAY}1. All tests passed! Consider adding more edge case tests${NC}"
    echo -e "${GRAY}2. Ready for frontend integration${NC}"
    echo -e "${GRAY}3. Consider performance testing with larger datasets${NC}"
fi

echo
echo -e "${WHITE}📋 HOW TO RE-RUN:${NC}"
echo -e "${GRAY}1. Ensure server is running: npm run dev (in server directory)${NC}"
echo -e "${GRAY}2. Make script executable: chmod +x test_commands.sh${NC}"
echo -e "${GRAY}3. Run tests: ./test_commands.sh${NC}"
echo -e "${WHITE}════════════════════════════════════════════════${NC}"

# Exit with appropriate code
exit $([ $FAILED_TESTS -eq 0 ] && echo 0 || echo 1)
