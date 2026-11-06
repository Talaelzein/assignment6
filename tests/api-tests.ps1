$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:3000"
$script:passed = 0

function Test-Api {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [int]$Expected,
        [string]$Body
    )

    $options = @{
        Uri = "$baseUrl$Endpoint"
        Method = $Method
        ErrorAction = "Stop"
        UseBasicParsing = $true
    }

    if ($PSBoundParameters.ContainsKey("Body")) {
        $options.ContentType = "application/json"
        $options.Body = $Body
    }

    $content = $null

    try {
        $response = Invoke-WebRequest @options
        $status = [int]$response.StatusCode
        $content = $response.Content
    }
    catch {
        if (-not $_.Exception.Response) {
            throw "FAIL: $Name - Cannot reach API: $($_.Exception.Message)"
        }

        $status = [int]$_.Exception.Response.StatusCode
        $content = $_.ErrorDetails.Message

        if ([string]::IsNullOrWhiteSpace($content)) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Dispose()
                }
            }
            catch {
                throw "FAIL: $Name - Cannot read error response"
            }
        }
    }

    # Verify HTTP status
    if ($status -ne $Expected) {
        throw "FAIL: $Name - Expected $Expected, got $status. Response: $content"
    }

    # Verify the response contains valid JSON
    try {
        $parsed = ConvertFrom-Json -InputObject $content -ErrorAction Stop
    }
    catch {
        throw "FAIL: $Name - Response is not valid JSON"
    }

    # Verify meaningful JSON error messages
    if ($Expected -ge 400) {
        if ($null -eq $parsed.error -or
            $parsed.error -isnot [string] -or
            [string]::IsNullOrWhiteSpace($parsed.error)) {
            throw "FAIL: $Name - Missing meaningful JSON error message"
        }
    }

    $script:passed++
    Write-Host "PASS: $Name ($status)" -ForegroundColor Green

    # Return data only for successful requests
    if ($Expected -lt 400) {
        return $parsed
    }
}

# TEST 1: Retrieve all tasks
$null = Test-Api "GET all tasks" "GET" "/api/tasks" 200

# TEST 2: Create a task
$body = @{
    title = "Automated Test"
    description = "Testing CRUD"
    completed = $false
} | ConvertTo-Json

$created = Test-Api "Create task" "POST" "/api/tasks" 201 $body
$id = $created.id

if (-not $id -or
    $created.title -ne "Automated Test" -or
    $created.description -ne "Testing CRUD" -or
    $created.completed -ne 0) {
    throw "FAIL: Created task contains incorrect data"
}

# TEST 3: Retrieve the created task
$task = Test-Api "GET one task" "GET" "/api/tasks/$id" 200

if ($task.id -ne $id -or
    $task.title -ne "Automated Test" -or
    $task.description -ne "Testing CRUD") {
    throw "FAIL: Retrieved task does not match created task"
}

# TEST 4: Update the task
$update = @{
    title = "Updated Automated Test"
    description = "Updated successfully"
    completed = $true
} | ConvertTo-Json

$updated = Test-Api "Update task" "PUT" "/api/tasks/$id" 200 $update

if ($updated.id -ne $id -or
    $updated.title -ne "Updated Automated Test" -or
    $updated.description -ne "Updated successfully" -or
    $updated.completed -ne 1) {
    throw "FAIL: Updated task contains incorrect data"
}

# TEST 5: Invalid POST
$invalid = '{"title":"","description":"test","completed":false}'
$null = Test-Api "Invalid POST" "POST" "/api/tasks" 400 $invalid

# TEST 6: Invalid PUT
$null = Test-Api "Invalid PUT" "PUT" "/api/tasks/$id" 400 $invalid

# TEST 7: Confirm invalid PUT did not change the task
$unchanged = Test-Api "Verify unchanged task" "GET" "/api/tasks/$id" 200

if ($unchanged.title -ne "Updated Automated Test" -or
    $unchanged.description -ne "Updated successfully" -or
    $unchanged.completed -ne 1) {
    throw "FAIL: Invalid PUT modified existing task"
}

# TEST 8: Nonexistent task
$null = Test-Api "Missing task" "GET" "/api/tasks/999999" 404

# TEST 9: Invalid task ID
$null = Test-Api "Invalid ID" "GET" "/api/tasks/abc" 400

# TEST 10: Malformed JSON
$null = Test-Api "Malformed JSON" "POST" "/api/tasks" 400 '{"title":"test",}'

# TEST 11: Missing title
$null = Test-Api "Missing title" "POST" "/api/tasks" 400 '{"description":"No title"}'

# TEST 12: Invalid description type
$null = Test-Api "Invalid description" "POST" "/api/tasks" 400 '{"title":"Test","description":123}'

# TEST 13: Invalid completed type
$null = Test-Api "Invalid completed value" "POST" "/api/tasks" 400 '{"title":"Test","completed":"true"}'

# TEST 14: Incomplete PUT request
$null = Test-Api "Incomplete PUT" "PUT" "/api/tasks/$id" 400 '{"title":"Test"}'

# TEST 15: Unknown endpoint
$null = Test-Api "Unknown endpoint" "GET" "/api/does-not-exist" 404

# TEST 16: Update a nonexistent task
$null = Test-Api "Missing PUT target" "PUT" "/api/tasks/999999" 404 $update

# TEST 17: Delete a nonexistent task
$null = Test-Api "Missing DELETE target" "DELETE" "/api/tasks/999999" 404

# TEST 18: Create a task with optional fields omitted
$defaults = Test-Api "POST default values" "POST" "/api/tasks" 201 '{"title":"Default Test"}'

if (-not $defaults.id -or
    $defaults.title -ne "Default Test" -or
    $defaults.description -ne "" -or
    $defaults.completed -ne 0) {
    throw "FAIL: Optional POST defaults are incorrect"
}

# TEST 19: Delete the default-values test task
$null = Test-Api "Delete default test task" "DELETE" "/api/tasks/$($defaults.id)" 200

# TEST 20: Delete the main test task
$deleted = Test-Api "Delete task" "DELETE" "/api/tasks/$id" 200

if ($deleted.message -ne "Task deleted successfully") {
    throw "FAIL: Incorrect deletion confirmation"
}

# TEST 21: Verify the task was deleted
$null = Test-Api "Verify deletion" "GET" "/api/tasks/$id" 404

# TEST 22: Check the database connection
$health = Test-Api "Database health" "GET" "/api/health" 200

if ($health.status -ne "ok" -or
    $health.database -ne "connected") {
    throw "FAIL: Database health check failed"
}

# Final result
if ($script:passed -ne 22) {
    throw "FAIL: Only $script:passed of 22 tests passed"
}

Write-Host ""
Write-Host "22/22 API TESTS PASSED!" -ForegroundColor Green
