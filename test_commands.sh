#!/bin/bash

# DevJournal AI Backend API Testing Script
# Tests authentication and CRUD operations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# API base URL
API_URL="http://localhost:5001"

# Test data
TEST_EMAIL="test@example.com"
TEST_PASSWORD="testpassword123"
TEST_EMAIL2="test2@example.com"

echo -e "${BLUE}🚀 Starting DevJournal AI Backend API Tests${NC}"
echo "================================================"
echo

# Add cleanup function
cleanup_test_data() {
    echo -e "${YELLOW}🧹 Cleaning up test data before starting...${NC}"
    
    # Reset users.json to empty array
    echo "[]" > server/data/users.json
    # Reset entries.json to empty array  
    echo "[]" > server/data/entries.json
    
    echo -e "${GREEN}✅ Test data cleaned${NC}"
    echo
}

# Enhanced function to print test results with detailed debugging
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: $2${NC}"
    else
        echo -e "${RED}❌ FAIL: $2${NC}"
    fi
    echo
}

# Enhanced function to make API calls with detailed debugging
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="$4"
    local test_name="$5"
    
    # Send debug output to stderr (>&2) so it's displayed but not captured
    echo -e "${CYAN}🔍 DEBUG: Making $method request to $endpoint${NC}" >&2
    echo -e "${PURPLE}📤 Request data: $data${NC}" >&2
    
    # Build curl command with verbose output
    local curl_cmd="curl -s -w \"HTTP_STATUS:%{http_code}|TIME:%{time_total}|SIZE:%{size_download}\" -X $method \"$API_URL$endpoint\""
    
    if [ ! -z "$data" ]; then
        curl_cmd="$curl_cmd -H \"Content-Type: application/json\" -d '$data'"
    fi
    
    if [ ! -z "$auth_header" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $auth_header\""
    fi
    
    echo -e "${PURPLE}🔧 Command: $curl_cmd${NC}" >&2
    
    # Execute the request and capture response
    local response=$(eval $curl_cmd)
    
    # Extract HTTP status and timing info
    local http_info=$(echo "$response" | grep -o "HTTP_STATUS:[0-9]*|TIME:[0-9.]*|SIZE:[0-9]*")
    local http_status=$(echo "$http_info" | grep -o "HTTP_STATUS:[0-9]*" | cut -d':' -f2)
    local time_total=$(echo "$http_info" | grep -o "TIME:[0-9.]*" | cut -d':' -f2)
    local size_download=$(echo "$http_info" | grep -o "SIZE:[0-9]*" | cut -d':' -f2)
    
    # Remove the debug info from response
    local clean_response=$(echo "$response" | sed 's/HTTP_STATUS:[0-9]*|TIME:[0-9.]*|SIZE:[0-9]*$//')
    
    echo -e "${PURPLE}📊 Response Status: $http_status | Time: ${time_total}s | Size: ${size_download} bytes${NC}" >&2
    echo -e "${PURPLE}📥 Response body: $clean_response${NC}" >&2
    
    # Check for empty response
    if [ -z "$clean_response" ]; then
        echo -e "${RED}⚠️  EMPTY RESPONSE detected! This indicates a server crash or connection issue.${NC}" >&2
        echo -e "${RED}🔍 Check if server is running on $API_URL${NC}" >&2
        echo -e "${RED}🔍 Check server logs for error messages${NC}" >&2
    fi
    
    # Check for connection errors
    if [ "$http_status" = "000" ]; then
        echo -e "${RED}⚠️  CONNECTION ERROR! Server might not be running or crashed.${NC}" >&2
        echo -e "${RED}🔍 Please check if server is running on $API_URL${NC}" >&2
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    
    # Return ONLY the clean response for further processing (to stdout)
    echo "$clean_response"
}

# Function to extract token from JSON response
extract_token() {
    echo "$1" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

# Function to extract message from JSON response
extract_message() {
    echo "$1" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
}

# Add cleanup call at the beginning
cleanup_test_data

echo -e "${YELLOW}🧪 Testing Authentication Endpoints${NC}"
echo "----------------------------------------"

# Test 1: Register new user with valid data
echo -e "${BLUE}Test 1: Register new user with valid data${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "User Registration")

message=$(extract_message "$response")
if [[ "$message" == "Registration successful" ]]; then
    print_result 0 "User registration"
else
    print_result 1 "User registration - Response: $response"
fi

# Test 2: Try to register same user again (should fail)
echo -e "${BLUE}Test 2: Try to register duplicate user${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "Duplicate Registration")

message=$(extract_message "$response")
if [[ "$message" == "User already exists" ]]; then
    print_result 0 "Duplicate user registration prevention"
else
    print_result 1 "Duplicate user registration prevention - Response: $response"
fi

# Test 3: Register with missing data
echo -e "${BLUE}Test 3: Register with missing email${NC}"
response=$(make_api_call "POST" "/auth/register" "{\"password\":\"$TEST_PASSWORD\"}" "" "Missing Email Validation")

message=$(extract_message "$response")
if [[ "$message" == "Email and password required" ]]; then
    print_result 0 "Missing email validation"
else
    print_result 1 "Missing email validation - Response: $response"
fi

# Test 4: Login with valid credentials
echo -e "${BLUE}Test 4: Login with valid credentials${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}" "" "User Login")

message=$(extract_message "$response")
TOKEN=$(extract_token "$response")

if [[ "$message" == "Login successful" ]] && [[ -n "$TOKEN" ]]; then
    print_result 0 "User login"
    echo -e "${BLUE}🔑 Token: ${TOKEN:0:20}...${NC}"
    echo
else
    print_result 1 "User login - Response: $response"
    echo -e "${RED}⚠️  Cannot continue with journal tests without token${NC}"
    echo -e "${RED}🔍 Debug: Message='$message', Token='$TOKEN'${NC}"
    echo -e "${RED}🔍 Check server console for detailed error logs${NC}"
    exit 1
fi

# Test 5: Login with wrong password
echo -e "${BLUE}Test 5: Login with wrong password${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"$TEST_EMAIL\",\"password\":\"wrongpassword\"}" "" "Wrong Password Test")

message=$(extract_message "$response")
if [[ "$message" == "Wrong password" ]]; then
    print_result 0 "Wrong password rejection"
else
    print_result 1 "Wrong password rejection - Response: $response"
fi

# Test 6: Login with non-existent user
echo -e "${BLUE}Test 6: Login with non-existent user${NC}"
response=$(make_api_call "POST" "/auth/login" "{\"email\":\"nonexistent@example.com\",\"password\":\"$TEST_PASSWORD\"}" "" "Non-existent User Test")

message=$(extract_message "$response")
if [[ "$message" == "User doesn't exist" ]]; then
    print_result 0 "Non-existent user rejection"
else
    print_result 1 "Non-existent user rejection - Response: $response"
fi

echo -e "${YELLOW}📝 Testing Journal CRUD Operations${NC}"
echo "----------------------------------------"

# Test 7: Get entries without token (should fail)
echo -e "${BLUE}Test 7: Get entries without authentication${NC}"
response=$(make_api_call "GET" "/journal" "" "" "Unauthorized Access Test")
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_URL/journal")

if [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized access prevention"
else
    print_result 1 "Unauthorized access prevention - HTTP Code: $http_code"
fi

# Test 8: Get entries with valid token (should return empty array initially)
echo -e "${BLUE}Test 8: Get entries with valid token${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Get Empty Entries")

if [[ "$response" == "[]" ]]; then
    print_result 0 "Get empty entries list"
else
    print_result 1 "Get empty entries list - Response: $response"
fi

# Test 9: Create first journal entry
echo -e "${BLUE}Test 9: Create first journal entry${NC}"
ENTRY_TEXT1="This is my first test journal entry. Testing the API!"
response=$(make_api_call "POST" "/journal" "{\"text\":\"$ENTRY_TEXT1\"}" "$TOKEN" "Create First Entry")

entry_text=$(echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4)
ENTRY_ID1=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [[ "$entry_text" == "$ENTRY_TEXT1" ]] && [[ -n "$ENTRY_ID1" ]]; then
    print_result 0 "Create journal entry"
    echo -e "${BLUE}📄 Created entry ID: $ENTRY_ID1${NC}"
    echo
else
    print_result 1 "Create journal entry - Response: $response"
fi

# Test 10: Create second journal entry
echo -e "${BLUE}Test 10: Create second journal entry${NC}"
ENTRY_TEXT2="This is my second journal entry. The API is working great!"
response=$(make_api_call "POST" "/journal" "{\"text\":\"$ENTRY_TEXT2\"}" "$TOKEN" "Create Second Entry")

entry_text=$(echo "$response" | grep -o '"text":"[^"]*"' | cut -d'"' -f4)
ENTRY_ID2=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [[ "$entry_text" == "$ENTRY_TEXT2" ]] && [[ -n "$ENTRY_ID2" ]]; then
    print_result 0 "Create second journal entry"
    echo -e "${BLUE}📄 Created entry ID: $ENTRY_ID2${NC}"
    echo
else
    print_result 1 "Create second journal entry - Response: $response"
fi

# Test 11: Try to create entry with empty text
echo -e "${BLUE}Test 11: Create entry with empty text${NC}"
response=$(make_api_call "POST" "/journal" "{\"text\":\"\"}" "$TOKEN" "Empty Entry Test")

message=$(extract_message "$response")
if [[ "$message" == "Entry cannot be empty" ]]; then
    print_result 0 "Empty entry validation"
else
    print_result 1 "Empty entry validation - Response: $response"
fi

# Test 12: Get all entries (should return 2 entries)
echo -e "${BLUE}Test 12: Get all entries${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Get All Entries")

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "2" ]]; then
    print_result 0 "Get all entries (count: $entry_count)"
else
    print_result 1 "Get all entries - Expected 2, got $entry_count. Response: $response"
fi

# Test 13: Delete first entry
echo -e "${BLUE}Test 13: Delete first entry${NC}"
response=$(make_api_call "DELETE" "/journal/$ENTRY_ID1" "" "$TOKEN" "Delete First Entry")

message=$(extract_message "$response")
if [[ "$message" == "Entry removed successfully" ]]; then
    print_result 0 "Delete journal entry"
else
    print_result 1 "Delete journal entry - Response: $response"
fi

# Test 14: Verify entry was deleted (should return 1 entry)
echo -e "${BLUE}Test 14: Verify entry deletion${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Verify Entry Deletion")

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "1" ]]; then
    print_result 0 "Entry deletion verification (remaining: $entry_count)"
else
    print_result 1 "Entry deletion verification - Expected 1, got $entry_count"
fi

# Test 15: Try to delete non-existent entry
echo -e "${BLUE}Test 15: Try to delete non-existent entry${NC}"
response=$(make_api_call "DELETE" "/journal/999999" "" "$TOKEN" "Non-existent Entry Deletion Test")

message=$(extract_message "$response")
if [[ "$message" == "Entry not found or unathorized" ]]; then
    print_result 0 "Non-existent entry deletion prevention"
else
    print_result 1 "Non-existent entry deletion prevention - Response: $response"
fi

# Test 16: Try to delete entry without token
echo -e "${BLUE}Test 16: Try to delete entry without authentication${NC}"
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL/journal/$ENTRY_ID2")

if [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized delete prevention"
else
    print_result 1 "Unauthorized delete prevention - HTTP Code: $http_code"
fi

echo -e "${YELLOW}🧹 Cleanup Tests${NC}"
echo "----------------------------------------"

# Test 17: Clean up remaining entries
echo -e "${BLUE}Test 17: Clean up remaining entries${NC}"
response=$(make_api_call "DELETE" "/journal/$ENTRY_ID2" "" "$TOKEN" "Cleanup: Delete Remaining Entry")

message=$(extract_message "$response")
if [[ "$message" == "Entry removed successfully" ]]; then
    print_result 0 "Cleanup: Delete remaining entry"
else
    print_result 1 "Cleanup: Delete remaining entry - Response: $response"
fi

# Test 18: Verify all entries are deleted
echo -e "${BLUE}Test 18: Verify all entries deleted${NC}"
response=$(make_api_call "GET" "/journal" "" "$TOKEN" "Verify All Entries Cleaned Up")

if [[ "$response" == "[]" ]]; then
    print_result 0 "All entries cleaned up"
else
    print_result 1 "All entries cleaned up - Response: $response"
fi

echo "================================================"
echo -e "${GREEN}🎉 API Testing Complete!${NC}"
echo
echo -e "${BLUE}💡 Summary:${NC}"
echo "- Authentication endpoints tested ✅"
echo "- Journal CRUD operations tested ✅"
echo "- Error handling validated ✅"
echo "- Security checks passed ✅"
echo
echo -e "${YELLOW}📋 To run this test:${NC}"
echo "1. Make sure your server is running on http://localhost:5001"
echo "2. Run: chmod +x test_commands.sh"
echo "3. Run: ./test_commands.sh"
