#!/bin/bash

# DevJournal AI Frontend-Backend Integration Test Suite
# Tests the complete user journey: Registration -> Login -> Journal Operations
# This mirrors exactly what the frontend would do

# Colors for professional output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test Configuration
API_URL="http://localhost:5001"
TEST_USER_EMAIL="integration.test@example.com"
TEST_USER_PASSWORD="securePassword123!"
TEST_USER_EMAIL2="integration.test2@example.com"

# Global Variables
USER_TOKEN=""
ENTRY_IDS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

echo -e "${WHITE}============================================================${NC}"
echo -e "${BLUE}🔄 DevJournal AI Frontend-Backend Integration Test Suite${NC}"
echo -e "${WHITE}============================================================${NC}"
echo -e "${GRAY}Purpose: Test complete user journey flow${NC}"
echo -e "${GRAY}Flow: Registration → Login → Journal CRUD Operations${NC}"
echo -e "${GRAY}Started at: $(date)${NC}"
echo -e "${GRAY}Target API: $API_URL${NC}"
echo -e "${WHITE}============================================================${NC}"
echo

# Enhanced API call function with detailed logging
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="$4"
    local test_name="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${CYAN}📡 Test $TOTAL_TESTS: ${test_name}${NC}" >&2
    echo -e "${PURPLE}   Method: $method | Endpoint: $endpoint${NC}" >&2
    if [ -n "$data" ]; then
        echo -e "${PURPLE}   Data: $data${NC}" >&2
    fi
    
    # Build curl command
    local curl_cmd="curl -s -w 'HTTP_STATUS:%{http_code}'"
    
    if [ -n "$auth_header" ]; then
        curl_cmd="$curl_cmd -H 'Authorization: Bearer $auth_header'"
    fi
    
    if [ "$method" != "GET" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json'"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -d '$data'"
    fi
    
    curl_cmd="$curl_cmd -X $method $API_URL$endpoint"
    
    # Execute API call
    local response=$(eval $curl_cmd 2>/dev/null)
    local http_status=$(echo "$response" | grep -o 'HTTP_STATUS:[0-9]*' | cut -d: -f2)
    local body=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*$//')
    
    echo -e "${GRAY}   Response: HTTP $http_status${NC}" >&2
    echo -e "${GRAY}   Body: $body${NC}" >&2
    
    # Return both status and body
    echo "${http_status}|${body}"
}

# Test result validation function
validate_test() {
    local expected_status="$1"
    local actual_status="$2"
    local response_body="$3"
    local test_name="$4"
    local additional_checks="$5"
    
    if [ "$actual_status" = "$expected_status" ]; then
        # Run additional checks if provided
        if [ -n "$additional_checks" ]; then
            if eval "$additional_checks"; then
                echo -e "${GREEN}   ✅ PASS: $test_name${NC}" >&2
                PASSED_TESTS=$((PASSED_TESTS + 1))
                return 0
            else
                echo -e "${RED}   ❌ FAIL: $test_name (Additional validation failed)${NC}" >&2
                FAILED_TESTS=$((FAILED_TESTS + 1))
                return 1
            fi
        else
            echo -e "${GREEN}   ✅ PASS: $test_name${NC}" >&2
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        fi
    else
        echo -e "${RED}   ❌ FAIL: $test_name${NC}" >&2
        echo -e "${RED}      Expected HTTP $expected_status, got HTTP $actual_status${NC}" >&2
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Environment setup and cleanup
setup_test_environment() {
    echo -e "${YELLOW}🔧 Setting up test environment...${NC}"
    
    # Check if server is running
    local health_check=$(make_api_call "GET" "/health" "" "" "Server Health Check")
    local status=$(echo "$health_check" | cut -d'|' -f1)
    
    if [ "$status" != "200" ] && [ "$status" != "404" ]; then
        echo -e "${RED}❌ Server is not running on $API_URL${NC}"
        echo -e "${YELLOW}💡 Please start the server with: cd server && npm start${NC}"
        exit 1
    fi
    
    # Clean up previous test data
    echo -e "${GRAY}   Cleaning up previous test data...${NC}"
    [ -f "server/data/users.json" ] && echo "[]" > server/data/users.json
    [ -f "server/data/entries.json" ] && echo "[]" > server/data/entries.json
    
    echo -e "${GREEN}✅ Test environment ready${NC}"
    echo
}

# Test Suite 1: User Registration Flow
test_user_registration() {
    echo -e "${BOLD}${BLUE}📝 Test Suite 1: User Registration${NC}"
    echo -e "${GRAY}=======================================${NC}"
    
    # Test 1.1: Successful Registration
    local response=$(make_api_call "POST" "/auth/register" \
        "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        "" "User Registration")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "201" "$status" "$body" "User Registration" \
        "echo '$body' | grep -q 'Registration successful'"
    
    # Test 1.2: Duplicate Registration (Should Fail)
    local response=$(make_api_call "POST" "/auth/register" \
        "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        "" "Duplicate Registration Prevention")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "400" "$status" "$body" "Duplicate Registration Prevention" \
        "echo '$body' | grep -q 'User already exists'"
    
    # Test 1.3: Invalid Email Format
    local response=$(make_api_call "POST" "/auth/register" \
        "{\"email\":\"invalid-email\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        "" "Invalid Email Validation")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "400" "$status" "$body" "Invalid Email Validation"
    
    echo
}

# Test Suite 2: User Authentication Flow
test_user_authentication() {
    echo -e "${BOLD}${BLUE}🔐 Test Suite 2: User Authentication${NC}"
    echo -e "${GRAY}=====================================${NC}"
    
    # Test 2.1: Successful Login
    local response=$(make_api_call "POST" "/auth/login" \
        "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        "" "User Login")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    if validate_test "200" "$status" "$body" "User Login" \
        "echo '$body' | grep -q 'token'"; then
        # Extract token for subsequent tests
        USER_TOKEN=$(echo "$body" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        echo -e "${GREEN}   🔑 Token extracted successfully${NC}" >&2
    else
        echo -e "${RED}❌ Cannot proceed without valid token${NC}"
        exit 1
    fi
    
    # Test 2.2: Wrong Password
    local response=$(make_api_call "POST" "/auth/login" \
        "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"wrongpassword\"}" \
        "" "Wrong Password Rejection")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "400" "$status" "$body" "Wrong Password Rejection"
    
    # Test 2.3: Non-existent User
    local response=$(make_api_call "POST" "/auth/login" \
        "{\"email\":\"nonexistent@example.com\",\"password\":\"$TEST_USER_PASSWORD\"}" \
        "" "Non-existent User Rejection")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "400" "$status" "$body" "Non-existent User Rejection"
    
    echo
}

# Test Suite 3: Journal Operations (Complete CRUD)
test_journal_operations() {
    echo -e "${BOLD}${BLUE}📔 Test Suite 3: Journal CRUD Operations${NC}"
    echo -e "${GRAY}==========================================${NC}"
    
    # Test 3.1: Get Empty Journal (Initially)
    local response=$(make_api_call "GET" "/journal" "" "$USER_TOKEN" "Get Empty Journal")
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "200" "$status" "$body" "Get Empty Journal" \
        "echo '$body' | grep -q '\[\]'"
    
    # Test 3.2: Create First Journal Entry
    local response=$(make_api_call "POST" "/journal" \
        "{\"text\":\"My first integration test journal entry!\"}" \
        "$USER_TOKEN" "Create First Entry")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    if validate_test "201" "$status" "$body" "Create First Entry" \
        "echo '$body' | grep -q 'id'"; then
        # Extract entry ID
        local entry_id=$(echo "$body" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        ENTRY_IDS+=("$entry_id")
        echo -e "${GREEN}   📝 Entry ID extracted: $entry_id${NC}" >&2
    fi
    
    # Test 3.3: Create Second Journal Entry
    local response=$(make_api_call "POST" "/journal" \
        "{\"text\":\"Second entry for comprehensive testing of the journal functionality.\"}" \
        "$USER_TOKEN" "Create Second Entry")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    if validate_test "201" "$status" "$body" "Create Second Entry"; then
        local entry_id=$(echo "$body" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        ENTRY_IDS+=("$entry_id")
    fi
    
    # Test 3.4: Get All Entries (Should have 2)
    local response=$(make_api_call "GET" "/journal" "" "$USER_TOKEN" "Get All Entries")
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "200" "$status" "$body" "Get All Entries" \
        "echo '$body' | grep -o '\"id\":' | wc -l | grep -q '2'"
    
    # Test 3.5: Update First Entry
    if [ ${#ENTRY_IDS[@]} -gt 0 ]; then
        local first_entry_id=${ENTRY_IDS[0]}
        local response=$(make_api_call "PUT" "/journal/$first_entry_id" \
            "{\"text\":\"Updated first entry - testing edit functionality!\"}" \
            "$USER_TOKEN" "Update First Entry")
        
        local status=$(echo "$response" | cut -d'|' -f1)
        local body=$(echo "$response" | cut -d'|' -f2)
        
        validate_test "200" "$status" "$body" "Update First Entry" \
            "echo '$body' | grep -q 'Updated first entry'"
    fi
    
    # Test 3.6: Delete Second Entry
    if [ ${#ENTRY_IDS[@]} -gt 1 ]; then
        local second_entry_id=${ENTRY_IDS[1]}
        local response=$(make_api_call "DELETE" "/journal/$second_entry_id" \
            "" "$USER_TOKEN" "Delete Second Entry")
        
        local status=$(echo "$response" | cut -d'|' -f1)
        local body=$(echo "$response" | cut -d'|' -f2)
        
        validate_test "200" "$status" "$body" "Delete Second Entry"
    fi
    
    # Test 3.7: Verify Deletion (Should have 1 entry)
    local response=$(make_api_call "GET" "/journal" "" "$USER_TOKEN" "Verify Deletion")
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "200" "$status" "$body" "Verify Deletion" \
        "echo '$body' | grep -o '\"id\":' | wc -l | grep -q '1'"
    
    echo
}

# Test Suite 4: Authorization & Security
test_authorization() {
    echo -e "${BOLD}${BLUE}🔒 Test Suite 4: Authorization & Security${NC}"
    echo -e "${GRAY}=========================================${NC}"
    
    # Test 4.1: Unauthorized Journal Access
    local response=$(make_api_call "GET" "/journal" "" "" "Unauthorized Access")
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "401" "$status" "$body" "Unauthorized Access"
    
    # Test 4.2: Invalid Token
    local response=$(make_api_call "GET" "/journal" "" "invalid.token.here" "Invalid Token")
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "403" "$status" "$body" "Invalid Token"
    
    # Test 4.3: Empty Text Entry (Should Fail)
    local response=$(make_api_call "POST" "/journal" \
        "{\"text\":\"\"}" \
        "$USER_TOKEN" "Empty Text Validation")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "400" "$status" "$body" "Empty Text Validation"
    
    echo
}

# Test Suite 5: Edge Cases
test_edge_cases() {
    echo -e "${BOLD}${BLUE}⚡ Test Suite 5: Edge Cases & Error Handling${NC}"
    echo -e "${GRAY}============================================${NC}"
    
    # Test 5.1: Non-existent Entry Update
    local response=$(make_api_call "PUT" "/journal/999999" \
        "{\"text\":\"Trying to update non-existent entry\"}" \
        "$USER_TOKEN" "Non-existent Entry Update")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "404" "$status" "$body" "Non-existent Entry Update"
    
    # Test 5.2: Non-existent Entry Deletion
    local response=$(make_api_call "DELETE" "/journal/999999" \
        "" "$USER_TOKEN" "Non-existent Entry Deletion")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "404" "$status" "$body" "Non-existent Entry Deletion"
    
    # Test 5.3: Very Long Text Entry
    local long_text=$(printf 'A%.0s' {1..1000})
    local response=$(make_api_call "POST" "/journal" \
        "{\"text\":\"$long_text\"}" \
        "$USER_TOKEN" "Long Text Entry")
    
    local status=$(echo "$response" | cut -d'|' -f1)
    local body=$(echo "$response" | cut -d'|' -f2)
    
    validate_test "201" "$status" "$body" "Long Text Entry"
    
    echo
}

# Final cleanup
cleanup_test_data_final() {
    echo -e "${YELLOW}🧹 Final Cleanup${NC}"
    echo -e "${GRAY}=================${NC}"
    
    # Clean up test data
    echo "[]" > server/data/users.json
    echo "[]" > server/data/entries.json
    
    echo -e "${GREEN}✅ Test data cleaned up${NC}"
    echo
}

# Generate final report
generate_report() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    echo -e "${WHITE}========================================${NC}"
    echo -e "${BOLD}📊 Integration Test Report${NC}"
    echo -e "${WHITE}========================================${NC}"
    echo -e "${GREEN}✅ Passed: $PASSED_TESTS tests${NC}"
    echo -e "${RED}❌ Failed: $FAILED_TESTS tests${NC}"
    echo -e "${BLUE}📈 Success Rate: $success_rate%${NC}"
    echo -e "${GRAY}⏱️  Duration: ${duration}s${NC}"
    echo -e "${WHITE}========================================${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED! Frontend-Backend integration is ready!${NC}"
        echo -e "${CYAN}💡 You can now confidently test the frontend UI${NC}"
        return 0
    else
        echo -e "${RED}⚠️  Some tests failed. Please fix issues before frontend testing.${NC}"
        return 1
    fi
}

# Main execution flow
main() {
    setup_test_environment
    test_user_registration
    test_user_authentication
    test_journal_operations
    test_authorization
    test_edge_cases
    cleanup_test_data_final
    generate_report
}

# Run the test suite
main 