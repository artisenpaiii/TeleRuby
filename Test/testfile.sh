#!/bin/bash

# Color definitions
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo "Starting tests for Router Application..."

BASE_URL="http://127.0.0.1:3000/people"

# Helper function to run tests
run_test() {
  local description=$1
  local method=$2
  local endpoint=$3
  local expected_status=$4
  local expected_body=$5
  local data=$6
  local headers=$7

  echo -e "${YELLOW}Running Test: $description${RESET}"
  response=$(curl -X $method "$BASE_URL$endpoint" -H "$headers" -d "$data" -s -w "HTTPSTATUS:%{http_code}")
  body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
  status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

  if [ "$status" -ne "$expected_status" ]; then
    echo -e "${RED}❌ Test Failed: Expected HTTP Status $expected_status but got $status${RESET}"
    echo -e "${RED}Response Body: $body${RESET}"
    exit 1
  fi

  if [[ "$body" != *"$expected_body"* ]]; then
    echo -e "${RED}❌ Test Failed: Expected Body to contain '$expected_body' but got '$body'${RESET}"
    exit 1
  fi

  echo -e "${GREEN}✅ Test Passed${RESET}"
}

# Test 1: Static Route
run_test "Static Route" "GET" "/" 200 '{"message":"Static People Route!"}' ""

# Test 2: Dynamic Route
run_test "Dynamic Route with ID" "GET" "/123" 200 '{"message":"Dynamic People Route!","id":"123"}' ""

# Test 3: Query Parameters - Valid
run_test "Valid Query Parameters" "GET" "/query/validate?query1=value1&query2=value2" 200 '{"message":"Valid Query Parameters!","query1":"value1","query2":"value2"}' ""

# Test 4: POST Body - Valid
run_test "Valid POST Body" "POST" "/body/validate" 200 '{"message":"Valid Body Parameters!","body1":"value1","body2":"value2"}' '{"body1":"value1","body2":"value2"}' "Content-Type: application/json"

# Test 5: POST Body - Missing Fields
run_test "Invalid POST Body" "POST" "/body/invalid" 400 '{"error":"Missing Fields in Body"}' '{"body1":"value1"}' "Content-Type: application/json"

# Test 6: Route without HTTPResponse
run_test "Non-HTTPResponse Route" "GET" "/noresponse" 500 '{"error":"Handler must return an HTTPResponse"}' ""

# Test 7: Invalid Path
run_test "Invalid Path" "GET" "/unknown" 404 '{"error":"Not Found"}' ""

# Complex Route 1: Dynamic Path with Query Validation
run_test "Search with Valid Query" "GET" "/search/type?q=query" 200 '{"message":"Search Successful","type":"type","query":"query"}' ""
run_test "Search with Invalid Query" "GET" "/search/type?q=" 200 '{"message":"Search Successful","type":"type","query":""}' ""
run_test "Search with Missing Query" "GET" "/search/type" 400 '{"error":"Invalid Query Parameters"}' ""

# Complex Route 2: Dynamic Path with Query and Body Validation
run_test "Update User with Valid Query and Body" "POST" "/user/1?active=true" 200 '{"message":"User Updated Successfully","id":"1","active":"true","name":"John Doe","age":30}' '{"name":"John Doe","age":30}' "Content-Type: application/json"
run_test "Update User Missing Query Parameter" "POST" "/user/1" 400 '{"error":"Invalid Query Parameters"}' '{"name":"John Doe","age":30}' "Content-Type: application/json"
run_test "Update User Missing Body Parameters" "POST" "/user/1?active=true" 400 '{"error":"Missing Query or Body Parameters"}' '{"name":"John Doe"}' "Content-Type: application/json"
run_test "Update User Missing Both Query and Body Parameters" "POST" "/user/1" 400 '{"error":"Invalid Query Parameters"}' "" ""

# Complex Route 3: Query Validation with Optional Body
run_test "Update with Valid Query and Body" "POST" "/update?id=1" 200 '{"message":"Update Received","id":"1","body":{"key":"value"}}' '{"key":"value"}' "Content-Type: application/json"
run_test "Update with Valid Query Without Body" "POST" "/update?id=1" 200 '{"message":"Update Received","id":"1"}' "" ""
run_test "Update Missing Query Parameter" "POST" "/update" 400 '{"error":"Invalid Query Parameters"}' "" ""
run_test "Update Missing Query Parameter With Body" "POST" "/update" 400 '{"error":"Invalid Query Parameters"}' '{"key":"value"}' "Content-Type: application/json"

# Final success message with color
echo -e "${GREEN}All tests completed successfully.${RESET}"

