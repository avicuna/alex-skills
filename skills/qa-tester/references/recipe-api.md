# Recipe: API Testing (Bash + curl)

Use this recipe when testing REST APIs, GraphQL endpoints, or any HTTP service.

#### Setup

```bash
BASE_URL="http://localhost:PORT"  # or the actual deployed URL
AUTH_TOKEN="..."                   # if applicable
```

#### Request Patterns

**GET request with assertions:**
```bash
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/endpoint")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
[ "$HTTP_CODE" = "200" ] && echo "PASS" || echo "FAIL: HTTP $HTTP_CODE"
```

**POST with JSON body:**
```bash
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"key": "value"}' \
  "$BASE_URL/endpoint")
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')
```

**JSON field assertion with jq:**
```bash
ACTUAL=$(echo "$BODY" | jq -r '.fieldName')
[ "$ACTUAL" = "expected" ] && echo "PASS" || echo "FAIL: expected 'expected', got '$ACTUAL'"
```

**Check response contains key:**
```bash
echo "$BODY" | jq -e '.requiredField' >/dev/null 2>&1 && echo "PASS" || echo "FAIL: missing .requiredField"
```

**Response time measurement:**
```bash
TIME=$(curl -s -o /dev/null -w "%{time_total}" "$BASE_URL/endpoint")
# TIME is in seconds (e.g., 0.045)
```

#### What to Test

- **Happy path:** Valid request → 200/201 + correct response body
- **Validation errors:** Missing required fields → 400 + descriptive error message
- **Not found:** Invalid resource ID → 404 + appropriate message
- **Auth - missing token:** No Authorization header → 401
- **Auth - invalid token:** Malformed or expired token → 401 or 403
- **Auth - insufficient permissions:** Valid token, wrong role → 403
- **Method not allowed:** Wrong HTTP method → 405
- **Content type:** Send wrong content type → 415 or 400
- **Rate limiting:** If applicable, hit the endpoint rapidly → 429; then wait and retry once to confirm recovery
- **Empty body:** POST with empty body → appropriate error
- **Oversized payload:** Very large request body → 413 or appropriate handling
- **CORS headers:** If browser-facing API, check `Access-Control-Allow-Origin` in response headers
- **Pagination:** If list endpoint, test `?page=1&limit=10`, boundary values, page beyond results
- **Idempotency:** Repeat the same PUT/PATCH → same result, no side effects

#### Rate Limit Handling

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/endpoint")
if [ "$HTTP_CODE" = "429" ]; then
  sleep 2
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/endpoint")
  [ "$HTTP_CODE" = "200" ] && echo "PASS: recovered after rate limit" || echo "FAIL: still rate limited"
fi
```

#### Cleanup Note

Track any resources created during testing (POST responses with IDs). At the end of the API test section, list them:

> "Created resources during testing: POST /users → id:abc123, POST /items → id:def456. These should be cleaned up or will expire via TTL."

If the API provides DELETE endpoints, clean up created resources after each section.

#### Error Evidence Collection (API)

On any `FAIL`:
- Record the full curl command (sanitize auth tokens in the report)
- Record HTTP status code
- Record response body (first 100 lines if large)
- Record response headers if relevant (e.g., rate limit headers, CORS headers)
- Record request body that was sent
