#!/bin/bash
# RUNTIME VALIDATION TEST SUITE
# Tests the complete Flutter + Laravel integration
# Run this after starting: php artisan serve

BASE_URL="http://localhost:8000/api"
TEST_RESULTS=()
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TEST_NUM=1

# ────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
# ────────────────────────────────────────────────────────────────

test_result() {
    local test_name=$1
    local expected=$2
    local actual=$3
    
    if [ "$expected" == "$actual" ]; then
        echo -e "${GREEN}✅ TEST $TEST_NUM PASS${NC}: $test_name"
        ((PASS_COUNT++))
    else
        echo -e "${RED}❌ TEST $TEST_NUM FAIL${NC}: $test_name"
        echo -e "  Expected: $expected"
        echo -e "  Actual: $actual"
        ((FAIL_COUNT++))
    fi
    ((TEST_NUM++))
}

json_extract() {
    echo "$1" | grep -o "\"$2\":[^,}]*" | cut -d: -f2 | tr -d ' "'
}

# ────────────────────────────────────────────────────────────────
# TEST 1: HEALTH CHECK
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 1: API HEALTH AND CONNECTIVITY${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "Testing: HTTP connectivity to $BASE_URL..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/health" 2>/dev/null || echo "error\n000")
HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | tail -n1)
test_result "API Health Check (HTTP $HEALTH_STATUS)" "200" "$HEALTH_STATUS"

# ────────────────────────────────────────────────────────────────
# TEST 2: REGISTRATION FLOW
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 2: USER REGISTRATION AND LOGIN${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Generate unique email
TIMESTAMP=$(date +%s)
TEST_EMAIL="testuser_$TIMESTAMP@test.com"
TEST_USERNAME="testuser_$TIMESTAMP"
TEST_PASSWORD="TestPassword123!"

echo "Registering user: $TEST_EMAIL"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Test User\",
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"username\": \"$TEST_USERNAME\"
  }")

REG_STATUS=$(echo "$REGISTER_RESPONSE" | grep -o '"success":[^,}]*' | cut -d: -f2)
test_result "Registration Success Flag" "true" "$REG_STATUS"

# Extract token from registration
TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ Failed to extract token from registration response${NC}"
    echo "Response: $REGISTER_RESPONSE"
    ((FAIL_COUNT++))
else
    echo -e "${GREEN}✅ Token extracted from registration${NC}: $(echo $TOKEN | cut -c1-20)..."
    ((PASS_COUNT++))
fi

# ────────────────────────────────────────────────────────────────
# TEST 3: BEARER TOKEN INJECTION
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 3: BEARER TOKEN VALIDATION${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -z "$TOKEN" ]; then
    echo "Testing /auth/me with Bearer token..."
    ME_RESPONSE=$(curl -s -X GET "$BASE_URL/auth/me" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
    
    ME_STATUS=$(echo "$ME_RESPONSE" | grep -o '"success":[^,}]*' | cut -d: -f2)
    test_result "Bearer Token Valid (/auth/me)" "true" "$ME_STATUS"
    
    ME_EMAIL=$(echo "$ME_RESPONSE" | grep -o '"email":"[^"]*' | head -1 | cut -d'"' -f4)
    test_result "User Email from /auth/me" "$TEST_EMAIL" "$ME_EMAIL"
else
    echo -e "${RED}❌ Cannot test Bearer token - no token available${NC}"
fi

# ────────────────────────────────────────────────────────────────
# TEST 4: 401 UNAUTHORIZED HANDLING
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 4: ERROR HANDLING - 401 UNAUTHORIZED${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "Testing /auth/me WITHOUT token..."
NO_TOKEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/auth/me" \
  -H "Content-Type: application/json")
NO_TOKEN_STATUS=$(echo "$NO_TOKEN_RESPONSE" | tail -n1)
test_result "401 Returned for Missing Token" "401" "$NO_TOKEN_STATUS"

echo "Testing /auth/me with INVALID token..."
INVALID_TOKEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer invalid_token_xyz" \
  -H "Content-Type: application/json")
INVALID_TOKEN_STATUS=$(echo "$INVALID_TOKEN_RESPONSE" | tail -n1)
test_result "401 Returned for Invalid Token" "401" "$INVALID_TOKEN_STATUS"

# ────────────────────────────────────────────────────────────────
# TEST 5: LOGIN FLOW
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 5: LOGIN FLOW AND SESSION${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "Testing login with registered user..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

LOGIN_STATUS=$(echo "$LOGIN_RESPONSE" | grep -o '"success":[^,}]*' | cut -d: -f2)
test_result "Login Success" "true" "$LOGIN_STATUS"

LOGIN_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
if [ ! -z "$LOGIN_TOKEN" ]; then
    echo -e "${GREEN}✅ Login token extracted${NC}"
    ((PASS_COUNT++))
    TOKEN=$LOGIN_TOKEN
else
    echo -e "${RED}❌ Failed to extract token from login${NC}"
    ((FAIL_COUNT++))
fi

# ────────────────────────────────────────────────────────────────
# TEST 6: PASSWORD VALIDATION
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 6: PASSWORD VALIDATION${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "Testing login with WRONG password..."
WRONG_PASS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"WrongPassword123!\"
  }")

WRONG_PASS_STATUS=$(echo "$WRONG_PASS_RESPONSE" | tail -n1)
test_result "401 for Wrong Password" "401" "$WRONG_PASS_STATUS"

# ────────────────────────────────────────────────────────────────
# TEST 7: DATA PERSISTENCE
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 7: DATABASE PERSISTENCE${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo "Verifying user saved in database..."
DB_QUERY_RESULT=$(sqlite3 database.sqlite "SELECT COUNT(*) FROM users WHERE email='$TEST_EMAIL';" 2>/dev/null || echo "0")
if [ "$DB_QUERY_RESULT" == "1" ]; then
    echo -e "${GREEN}✅ User found in database${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}❌ User NOT found in database${NC}"
    ((FAIL_COUNT++))
fi

# ────────────────────────────────────────────────────────────────
# TEST 8: LOGOUT FLOW
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUITE 8: LOGOUT AND TOKEN INVALIDATION${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -z "$TOKEN" ]; then
    echo "Testing logout..."
    LOGOUT_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/logout" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
    
    LOGOUT_STATUS=$(echo "$LOGOUT_RESPONSE" | grep -o '"success":[^,}]*' | cut -d: -f2)
    test_result "Logout Success" "true" "$LOGOUT_STATUS"
    
    echo "Testing token after logout (should fail with 401)..."
    AFTER_LOGOUT=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/auth/me" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json")
    AFTER_LOGOUT_STATUS=$(echo "$AFTER_LOGOUT" | tail -n1)
    test_result "Token Invalid After Logout" "401" "$AFTER_LOGOUT_STATUS"
else
    echo -e "${RED}❌ No token available for logout test${NC}"
fi

# ────────────────────────────────────────────────────────────────
# TEST SUMMARY
# ────────────────────────────────────────────────────────────────

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}TEST SUMMARY${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo ""
echo -e "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e ""
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e ""
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
