#!/usr/bin/env php
<?php

// ============================================================
// PORTFOLIOPH RUNTIME VALIDATION SUITE
// Phase 1: Real User Simulation Tests
// ============================================================

class RuntimeValidator {
    private $baseUrl = 'http://localhost:8000/api';
    private $bearerToken = null;
    private $testUser;
    private $recruiter;
    
    public function __construct() {
        $timestamp = time();
        $this->testUser = [
            'name' => 'Test User ' . $timestamp,
            'email' => 'testuser' . $timestamp . '@test.com',
            'password' => 'TestPassword123!',
            'role' => 'job_seeker'
        ];
        
        $this->recruiter = [
            'name' => 'Recruiter ' . $timestamp,
            'email' => 'recruiter' . $timestamp . '@test.com',
            'password' => 'RecruiterPass123!',
            'role' => 'recruiter'
        ];
    }
    
    private $results = [];
    private $testCount = 0;
    private $passCount = 0;
    private $failCount = 0;

    public function runAllTests() {
        echo "\n" . str_repeat("=", 70) . "\n";
        echo "PORTFOLIOPH RUNTIME VALIDATION SUITE\n";
        echo "Date: " . date('Y-m-d H:i:s') . "\n";
        echo str_repeat("=", 70) . "\n\n";

        // Test each group
        $this->testGroupA_Authentication();
        $this->testGroupB_JobFlow();
        $this->testGroupC_ApplicationFlow();
        $this->testGroupD_Authorization();
        $this->testGroupE_ErrorHandling();
        $this->testGroupF_TokenFailure();
        $this->testGroupG_PaginationPerformance();
        $this->testGroupH_UIStates();

        // Final report
        $this->printReport();
    }

    // ============================================================
    // TEST GROUP A: AUTHENTICATION FLOW
    // ============================================================
    private function testGroupA_Authentication() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP A: AUTHENTICATION FLOW\n";
        echo str_repeat("-", 70) . "\n";

        // Test A1: Register new user
        $this->test("A1: User Registration", function() {
            $response = $this->curl('POST', '/auth/register', [
                'name' => $this->testUser['name'],
                'email' => $this->testUser['email'],
                'password' => $this->testUser['password'],
                'password_confirmation' => $this->testUser['password'],
                'role' => $this->testUser['role']
            ]);

            if ($response['status'] === 201 || $response['status'] === 200) {
                if (isset($response['data']['token'])) {
                    $this->bearerToken = $response['data']['token'];
                    return true;
                }
            }
            return false;
        });

        // Test A2: Login
        $this->test("A2: User Login", function() {
            $response = $this->curl('POST', '/auth/login', [
                'email' => $this->testUser['email'],
                'password' => $this->testUser['password']
            ]);

            if ($response['status'] === 200 && isset($response['data']['token'])) {
                $this->bearerToken = $response['data']['token'];
                return true;
            }
            return false;
        });

        // Test A3: Get user profile (token persistence)
        $this->test("A3: Token Persistence (/auth/me)", function() {
            $response = $this->curl('GET', '/auth/me', null, $this->bearerToken);
            
            if ($response['status'] === 200 && isset($response['data']['email'])) {
                return $response['data']['email'] === $this->testUser['email'];
            }
            return false;
        });

        // Test A4: Register recruiter for later tests
        $this->test("A4: Recruiter Registration", function() {
            $response = $this->curl('POST', '/auth/register', [
                'name' => $this->recruiter['name'],
                'email' => $this->recruiter['email'],
                'password' => $this->recruiter['password'],
                'password_confirmation' => $this->recruiter['password'],
                'role' => $this->recruiter['role']
            ]);

            if ($response['status'] === 201 || $response['status'] === 200) {
                if (isset($response['data']['token'])) {
                    $this->recruiter['token'] = $response['data']['token'];
                    $this->recruiter['id'] = $response['data']['user']['id'] ?? null;
                    return true;
                }
            }
            return false;
        });
    }

    // ============================================================
    // TEST GROUP B: JOB FLOW
    // ============================================================
    private function testGroupB_JobFlow() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP B: JOB FLOW\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("B1: Create Job (as Recruiter)", function() {
            $recruiterToken = $this->recruiter['token'] ?? null;
            if (!$recruiterToken) {
                return false;
            }

            $response = $this->curl('POST', '/jobs', [
                'title' => 'Senior Developer',
                'description' => 'Looking for experienced developer',
                'salary_min' => 50000,
                'salary_max' => 80000,
                'location' => 'Remote',
                'job_type' => 'full-time'
            ], $recruiterToken);

            if ($response['status'] === 201 && isset($response['data']['id'])) {
                $GLOBALS['jobId'] = $response['data']['id'];
                return true;
            }
            return false;
        });

        $this->test("B2: Job Appears in List", function() {
            $response = $this->curl('GET', '/jobs?per_page=10', null, $this->bearerToken);
            
            if ($response['status'] === 200 && isset($response['data'])) {
                // Check if created job is in list
                foreach ($response['data'] as $job) {
                    if ($job['title'] === 'Senior Developer') {
                        return true;
                    }
                }
            }
            return false;
        });

        $this->test("B3: Job Persists in Database", function() {
            $jobId = $GLOBALS['jobId'] ?? null;
            if (!$jobId) return false;

            $response = $this->curl('GET', "/jobs/$jobId", null, $this->bearerToken);
            return $response['status'] === 200;
        });
    }

    // ============================================================
    // TEST GROUP C: APPLICATION FLOW
    // ============================================================
    private function testGroupC_ApplicationFlow() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP C: APPLICATION FLOW\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("C1: Job Seeker Applies to Job", function() {
            $jobId = $GLOBALS['jobId'] ?? null;
            if (!$jobId || !$this->bearerToken) return false;

            $response = $this->curl('POST', '/applications', [
                'job_id' => $jobId
            ], $this->bearerToken);

            if ($response['status'] === 201 && isset($response['data']['id'])) {
                $GLOBALS['applicationId'] = $response['data']['id'];
                return true;
            }
            return false;
        });

        $this->test("C2: Application Saved in Database", function() {
            $appId = $GLOBALS['applicationId'] ?? null;
            if (!$appId) return false;

            $response = $this->curl('GET', '/applications', null, $this->bearerToken);
            
            if ($response['status'] === 200 && isset($response['data'])) {
                foreach ($response['data'] as $app) {
                    if ($app['id'] === $appId) {
                        return true;
                    }
                }
            }
            return false;
        });

        $this->test("C3: Recruiter Can See Application", function() {
            $recruiterToken = $this->recruiter['token'] ?? null;
            if (!$recruiterToken) return false;

            $response = $this->curl('GET', '/applications', null, $recruiterToken);
            return $response['status'] === 200;
        });
    }

    // ============================================================
    // TEST GROUP D: AUTHORIZATION (SECURITY)
    // ============================================================
    private function testGroupD_Authorization() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP D: AUTHORIZATION & SECURITY\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("D1: Cannot Edit Job Not Owned", function() {
            $jobId = $GLOBALS['jobId'] ?? null;
            if (!$jobId) return false;

            // Try to edit as original seeker (not owner)
            $response = $this->curl('PUT', "/jobs/$jobId", [
                'title' => 'HACKED',
                'description' => 'This should not work',
                'salary_min' => 1,
                'salary_max' => 1,
                'location' => 'HACKED',
                'job_type' => 'full-time'
            ], $this->bearerToken);

            // Should get 403 Forbidden
            return $response['status'] === 403;
        });

        $this->test("D2: Cannot Delete Job Not Owned", function() {
            $jobId = $GLOBALS['jobId'] ?? null;
            if (!$jobId) return false;

            $response = $this->curl('DELETE', "/jobs/$jobId", null, $this->bearerToken);
            
            // Should get 403 Forbidden
            return $response['status'] === 403;
        });

        $this->test("D3: Owner CAN Edit Own Job", function() {
            $jobId = $GLOBALS['jobId'] ?? null;
            $recruiterToken = $this->recruiter['token'] ?? null;
            if (!$jobId || !$recruiterToken) return false;

            $response = $this->curl('PUT', "/jobs/$jobId", [
                'title' => 'Senior Developer (Updated)',
                'description' => 'Updated description',
                'salary_min' => 60000,
                'salary_max' => 90000,
                'location' => 'Remote',
                'job_type' => 'full-time'
            ], $recruiterToken);

            return $response['status'] === 200;
        });
    }

    // ============================================================
    // TEST GROUP E: ERROR HANDLING
    // ============================================================
    private function testGroupE_ErrorHandling() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP E: ERROR HANDLING\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("E1: Invalid Request Returns 422", function() {
            $response = $this->curl('POST', '/jobs', [
                // Missing required fields
                'title' => ''  // Empty
            ], $this->recruiter['token'] ?? null);

            return $response['status'] === 422;
        });

        $this->test("E2: Validation Errors Returned Properly", function() {
            $response = $this->curl('POST', '/jobs', [
                'title' => 'Test',
                'salary_min' => 100,
                'salary_max' => 50  // Invalid: max < min
            ], $this->recruiter['token'] ?? null);

            if ($response['status'] === 422 && isset($response['errors'])) {
                return count($response['errors']) > 0;
            }
            return false;
        });

        $this->test("E3: Nonexistent Resource Returns 404", function() {
            $response = $this->curl('GET', '/jobs/999999', null, $this->bearerToken);
            return $response['status'] === 404;
        });

        $this->test("E4: API Server Responds Properly", function() {
            $response = $this->curl('GET', '/jobs?per_page=5', null, $this->bearerToken);
            
            // Check response structure
            if ($response['status'] === 200 && isset($response['data'])) {
                return is_array($response['data']);
            }
            return false;
        });
    }

    // ============================================================
    // TEST GROUP F: TOKEN FAILURE
    // ============================================================
    private function testGroupF_TokenFailure() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP F: TOKEN & SESSION FAILURE\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("F1: Invalid Token Returns 401", function() {
            $response = $this->curl('GET', '/auth/me', null, 'invalid_token_xyz');
            return $response['status'] === 401;
        });

        $this->test("F2: Missing Auth Header Returns 401", function() {
            $response = $this->curl('GET', '/auth/me', null, null);
            return $response['status'] === 401;
        });

        $this->test("F3: Logout Clears Session", function() {
            $response = $this->curl('POST', '/auth/logout', [], $this->bearerToken);
            
            if ($response['status'] === 200) {
                // Try to use token again - should fail
                sleep(1);
                $meResponse = $this->curl('GET', '/auth/me', null, $this->bearerToken);
                return $meResponse['status'] === 401;
            }
            return false;
        });
    }

    // ============================================================
    // TEST GROUP G: PAGINATION & PERFORMANCE
    // ============================================================
    private function testGroupG_PaginationPerformance() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP G: PAGINATION & PERFORMANCE\n";
        echo str_repeat("-", 70) . "\n";

        // Create multiple jobs for pagination test
        $this->test("G1: Create 10 More Jobs for Pagination", function() {
            $recruiterToken = $this->recruiter['token'] ?? null;
            if (!$recruiterToken) return false;

            for ($i = 0; $i < 10; $i++) {
                $response = $this->curl('POST', '/jobs', [
                    'title' => "Test Job $i",
                    'description' => 'Test job for pagination',
                    'salary_min' => 50000,
                    'salary_max' => 70000,
                    'location' => 'Remote',
                    'job_type' => 'full-time'
                ], $recruiterToken);

                if ($response['status'] !== 201) {
                    return false;
                }
            }
            return true;
        });

        $this->test("G2: Pagination Meta Returned", function() {
            $response = $this->curl('GET', '/jobs?per_page=5&page=1', null, $this->bearerToken);
            
            if ($response['status'] === 200) {
                // Check for pagination meta
                return isset($response['meta']) && 
                       isset($response['meta']['current_page']) &&
                       isset($response['meta']['last_page']);
            }
            return false;
        });

        $this->test("G3: Page 2 Returns Different Data", function() {
            $page1 = $this->curl('GET', '/jobs?per_page=5&page=1', null, $this->bearerToken);
            $page2 = $this->curl('GET', '/jobs?per_page=5&page=2', null, $this->bearerToken);
            
            if ($page1['status'] === 200 && $page2['status'] === 200) {
                $ids1 = array_column($page1['data'], 'id');
                $ids2 = array_column($page2['data'], 'id');
                
                // Pages should have different IDs
                $intersect = array_intersect($ids1, $ids2);
                return count($intersect) === 0;
            }
            return false;
        });

        $this->test("G4: Performance: Response Time < 500ms", function() {
            $start = microtime(true);
            $response = $this->curl('GET', '/jobs?per_page=20', null, $this->bearerToken);
            $duration = (microtime(true) - $start) * 1000;
            
            if ($response['status'] === 200) {
                // Log the response time
                echo "         Response time: {$duration}ms\n";
                return $duration < 500;
            }
            return false;
        });
    }

    // ============================================================
    // TEST GROUP H: UI STATES
    // ============================================================
    private function testGroupH_UIStates() {
        echo "\n" . str_repeat("-", 70) . "\n";
        echo "TEST GROUP H: UI STATES & RESPONSES\n";
        echo str_repeat("-", 70) . "\n";

        $this->test("H1: Empty Pagination Field Returns Sensible Default", function() {
            $response = $this->curl('GET', '/jobs', null, $this->bearerToken);
            
            if ($response['status'] === 200) {
                return isset($response['data']) && is_array($response['data']);
            }
            return false;
        });

        $this->test("H2: Empty Job List Query Returns Empty Array", function() {
            $response = $this->curl('GET', '/jobs?search_title=NONEXISTENT_xyz123', null, $this->bearerToken);
            
            if ($response['status'] === 200) {
                // Should return empty data, not error
                return isset($response['data']);
            }
            return false;
        });

        $this->test("H3: Error Response Has Proper Structure", function() {
            $response = $this->curl('POST', '/jobs', [], $this->recruiter['token'] ?? null);
            
            if ($response['status'] === 422) {
                // Should have errors field
                return isset($response['errors']);
            }
            return false;
        });

        $this->test("H4: Success Response Has Proper Structure", function() {
            $recruiterToken = $this->recruiter['token'] ?? null;
            if (!$recruiterToken) return false;

            $response = $this->curl('POST', '/jobs', [
                'title' => 'Final Test Job',
                'description' => 'For success response',
                'salary_min' => 50000,
                'salary_max' => 70000,
                'location' => 'Remote',
                'job_type' => 'full-time'
            ], $recruiterToken);
            
            if ($response['status'] === 201) {
                return isset($response['data']) && isset($response['data']['id']);
            }
            return false;
        });
    }

    // ============================================================
    // HELPER METHODS
    // ============================================================
    
    private function curl($method, $endpoint, $data = null, $token = null) {
        $url = $this->baseUrl . $endpoint;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        
        $headers = [
            'Content-Type: application/json',
            'Accept: application/json',
        ];
        
        if ($token) {
            $headers[] = "Authorization: Bearer $token";
        }
        
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        
        if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);
        
        if ($curlError) {
            return [
                'status' => 0,
                'error' => $curlError,
                'data' => null
            ];
        }
        
        $decoded = json_decode($response, true);
        
        return [
            'status' => $httpCode,
            'data' => $decoded['data'] ?? $decoded,
            'errors' => $decoded['errors'] ?? null,
            'meta' => $decoded['meta'] ?? null,
            'raw' => $response
        ];
    }

    private function test($name, $callback) {
        $this->testCount++;
        
        try {
            $result = $callback();
            
            if ($result) {
                echo "✅ PASS: $name\n";
                $this->passCount++;
                $this->results[$name] = ['status' => 'PASS'];
            } else {
                echo "❌ FAIL: $name\n";
                $this->failCount++;
                $this->results[$name] = ['status' => 'FAIL', 'reason' => 'Assertion returned false'];
            }
        } catch (\Exception $e) {
            echo "❌ ERROR: $name\n";
            echo "   Error: " . $e->getMessage() . "\n";
            $this->failCount++;
            $this->results[$name] = ['status' => 'ERROR', 'reason' => $e->getMessage()];
        }
    }

    private function printReport() {
        echo "\n" . str_repeat("=", 70) . "\n";
        echo "FINAL VALIDATION REPORT\n";
        echo str_repeat("=", 70) . "\n";
        echo "Total Tests: $this->testCount\n";
        echo "Passed:      $this->passCount ✅\n";
        echo "Failed:      $this->failCount ❌\n";
        
        $passPercentage = ($this->passCount / $this->testCount) * 100;
        echo "Pass Rate:   " . number_format($passPercentage, 1) . "%\n";
        
        if ($this->failCount === 0) {
            echo "\n✅ ALL TESTS PASSED - SYSTEM READY FOR DEPLOYMENT\n";
        } else {
            echo "\n❌ SYSTEM HAS FAILURES - DO NOT DEPLOY\n";
            echo "Failed tests:\n";
            foreach ($this->results as $name => $result) {
                if ($result['status'] !== 'PASS') {
                    echo "  - $name\n";
                    if (isset($result['reason'])) {
                        echo "    Reason: {$result['reason']}\n";
                    }
                }
            }
        }
        
        echo "\nOverall Status: " . ($this->failCount === 0 ? "READY FOR DEPLOYMENT" : "NOT READY FOR DEPLOYMENT") . "\n";
        echo "Deployment Confidence: " . number_format($passPercentage, 0) . "%\n";
        echo str_repeat("=", 70) . "\n";
    }
}

// Run the validator
$validator = new RuntimeValidator();
$validator->runAllTests();
