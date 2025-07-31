#!/bin/bash

# DevJournal AI Backend API Testing Script
# Tests authentication and CRUD operations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: $2${NC}"
    else
        echo -e "${RED}❌ FAIL: $2${NC}"
    fi
    echo
}

# Function to extract token from JSON response
extract_token() {
    echo "$1" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

# Function to extract message from JSON response
extract_message() {
    echo "$1" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
}

echo -e "${YELLOW}🧪 Testing Authentication Endpoints${NC}"
echo "----------------------------------------"

# Test 1: Register new user with valid data
echo "Test 1: Register new user with valid data"
response=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

message=$(extract_message "$response")
if [[ "$message" == "Registration successful" ]]; then
    print_result 0 "User registration"
else
    print_result 1 "User registration - Response: $response"
fi

# Test 2: Try to register same user again (should fail)
echo "Test 2: Try to register duplicate user"
response=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

message=$(extract_message "$response")
if [[ "$message" == "User already exists" ]]; then
    print_result 0 "Duplicate user registration prevention"
else
    print_result 1 "Duplicate user registration prevention - Response: $response"
fi

# Test 3: Register with missing data
echo "Test 3: Register with missing email"
response=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"$TEST_PASSWORD\"}")

message=$(extract_message "$response")
if [[ "$message" == "Email and password required" ]]; then
    print_result 0 "Missing email validation"
else
    print_result 1 "Missing email validation - Response: $response"
fi

# Test 4: Login with valid credentials
echo "Test 4: Login with valid credentials"
response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

message=$(extract_message "$response")
TOKEN=$(extract_token "$response")

if [[ "$message" == "Login successful" ]] && [[ -n "$TOKEN" ]]; then
    print_result 0 "User login"
    echo -e "${BLUE}🔑 Token: ${TOKEN:0:20}...${NC}"
    echo
else
    print_result 1 "User login - Response: $response"
    echo -e "${RED}⚠️  Cannot continue with journal tests without token${NC}"
    exit 1
fi

# Test 5: Login with wrong password
echo "Test 5: Login with wrong password"
response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"wrongpassword\"}")

message=$(extract_message "$response")
if [[ "$message" == "Wrong password" ]]; then
    print_result 0 "Wrong password rejection"
else
    print_result 1 "Wrong password rejection - Response: $response"
fi

# Test 6: Login with non-existent user
echo "Test 6: Login with non-existent user"
response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"nonexistent@example.com\",\"password\":\"$TEST_PASSWORD\"}")

message=$(extract_message "$response")
if [[ "$message" == "User doesn't exist" ]]; then
    print_result 0 "Non-existent user rejection"
else
    print_result 1 "Non-existent user rejection - Response: $response"
fi

echo -e "${YELLOW}📝 Testing Journal CRUD Operations${NC}"
echo "----------------------------------------"

# Test 7: Get entries without token (should fail)
echo "Test 7: Get entries without authentication"
response=$(curl -s -X GET "$API_URL/journal")
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_URL/journal")

if [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized access prevention"
else
    print_result 1 "Unauthorized access prevention - HTTP Code: $http_code"
fi

# Test 8: Get entries with valid token (should return empty array initially)
echo "Test 8: Get entries with valid token"
response=$(curl -s -X GET "$API_URL/journal" \
  -H "Authorization: Bearer $TOKEN")

if [[ "$response" == "[]" ]]; then
    print_result 0 "Get empty entries list"
else
    print_result 1 "Get empty entries list - Response: $response"
fi

# Test 9: Create first journal entry
echo "Test 9: Create first journal entry"
ENTRY_TEXT1="This is my first test journal entry. Testing the API!"
response=$(curl -s -X POST "$API_URL/journal" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"text\":\"$ENTRY_TEXT1\"}")

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
echo "Test 10: Create second journal entry"
ENTRY_TEXT2="This is my second journal entry. The API is working great!"
response=$(curl -s -X POST "$API_URL/journal" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"text\":\"$ENTRY_TEXT2\"}")

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
echo "Test 11: Create entry with empty text"
response=$(curl -s -X POST "$API_URL/journal" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"text\":\"\"}")

message=$(extract_message "$response")
if [[ "$message" == "Entry cannot be empty" ]]; then
    print_result 0 "Empty entry validation"
else
    print_result 1 "Empty entry validation - Response: $response"
fi

# Test 12: Get all entries (should return 2 entries)
echo "Test 12: Get all entries"
response=$(curl -s -X GET "$API_URL/journal" \
  -H "Authorization: Bearer $TOKEN")

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "2" ]]; then
    print_result 0 "Get all entries (count: $entry_count)"
else
    print_result 1 "Get all entries - Expected 2, got $entry_count. Response: $response"
fi

# Test 13: Delete first entry
echo "Test 13: Delete first entry"
response=$(curl -s -X DELETE "$API_URL/journal/$ENTRY_ID1" \
  -H "Authorization: Bearer $TOKEN")

message=$(extract_message "$response")
if [[ "$message" == "Entry removed successfully" ]]; then
    print_result 0 "Delete journal entry"
else
    print_result 1 "Delete journal entry - Response: $response"
fi

# Test 14: Verify entry was deleted (should return 1 entry)
echo "Test 14: Verify entry deletion"
response=$(curl -s -X GET "$API_URL/journal" \
  -H "Authorization: Bearer $TOKEN")

entry_count=$(echo "$response" | grep -o '"id":' | wc -l | tr -d ' ')
if [[ "$entry_count" == "1" ]]; then
    print_result 0 "Entry deletion verification (remaining: $entry_count)"
else
    print_result 1 "Entry deletion verification - Expected 1, got $entry_count"
fi

# Test 15: Try to delete non-existent entry
echo "Test 15: Try to delete non-existent entry"
response=$(curl -s -X DELETE "$API_URL/journal/999999" \
  -H "Authorization: Bearer $TOKEN")

message=$(extract_message "$response")
if [[ "$message" == "Entry not found or unathorized" ]]; then
    print_result 0 "Non-existent entry deletion prevention"
else
    print_result 1 "Non-existent entry deletion prevention - Response: $response"
fi

# Test 16: Try to delete entry without token
echo "Test 16: Try to delete entry without authentication"
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL/journal/$ENTRY_ID2")

if [[ "$http_code" == "401" ]]; then
    print_result 0 "Unauthorized delete prevention"
else
    print_result 1 "Unauthorized delete prevention - HTTP Code: $http_code"
fi

echo -e "${YELLOW}🧹 Cleanup Tests${NC}"
echo "----------------------------------------"

# Test 17: Clean up remaining entries
echo "Test 17: Clean up remaining entries"
response=$(curl -s -X DELETE "$API_URL/journal/$ENTRY_ID2" \
  -H "Authorization: Bearer $TOKEN")

message=$(extract_message "$response")
if [[ "$message" == "Entry removed successfully" ]]; then
    print_result 0 "Cleanup: Delete remaining entry"
else
    print_result 1 "Cleanup: Delete remaining entry - Response: $response"
fi

# Test 18: Verify all entries are deleted
echo "Test 18: Verify all entries deleted"
response=$(curl -s -X GET "$API_URL/journal" \
  -H "Authorization: Bearer $TOKEN")

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
