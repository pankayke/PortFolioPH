<?php

// Quick API diagnostic test

echo "=== API DIAGNOSTIC TEST ===\n\n";

// Test 1: Can we reach the server?
echo "1. Testing API connectivity...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api/jobs');
curl_setopt($ch, CURLOPT_TIMEOUT, 5);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "   ❌ ERROR: $error\n";
    exit(1);
} else {
    echo "   ✅ Connected (Status: $code)\n";
}

// Test 2: Try registration
echo "\n2. Testing registration endpoint...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api/register');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'name' => 'Test User',
    'email' => 'testuser'.time().'@test.com',
    'password' => 'TestPass123!',
    'password_confirmation' => 'TestPass123!',
    'role' => 'job_seeker',
]));
$response = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$data = json_decode($response, true);
echo "   Status: $code\n";
echo '   Response structure: '.(is_array($data) ? 'Valid JSON' : 'Invalid JSON')."\n";

if (isset($data['data'])) {
    echo "   ✅ Has 'data' field\n";
    if (isset($data['data']['token'])) {
        echo "   ✅ Has 'data.token' field\n";
    } else {
        echo "   ⚠️  Missing 'data.token' field\n";
        echo '   Response: '.json_encode($data, JSON_PRETTY_PRINT)."\n";
    }
} else {
    echo "   ❌ Missing 'data' field\n";
    echo '   Full response: '.json_encode($data, JSON_PRETTY_PRINT)."\n";
}

// Test 3: Check routes
echo "\n3. Checking available routes...\n";
$routes = [
    '/api/register' => 'POST',
    '/api/login' => 'POST',
    '/api/logout' => 'POST',
    '/api/auth/me' => 'GET',
    '/api/jobs' => 'GET',
];

foreach ($routes as $route => $method) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000'.$route);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json']);
    curl_setopt($ch, CURLOPT_TIMEOUT, 3);
    $response = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $status = ($code < 500 && $code != 0) ? '✅' : '❌';
    echo "   $status $method $route (HTTP $code)\n";
}

echo "\n=== END DIAGNOSTIC ===\n";
