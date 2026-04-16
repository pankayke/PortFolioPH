$ErrorActionPreference = 'Stop'

$helperPath = Join-Path $PSScriptRoot '..\lib\http_helpers.ps1'
. $helperPath

Describe 'Get-HttpStatusCode' {
    It 'returns status code when response exists on exception' {
        $ex = New-Object System.Exception 'boom'
        Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 429 }) -Force
        $err = [System.Management.Automation.ErrorRecord]::new(
            $ex,
            'test-id',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            $null
        )

        $statusCode = Get-HttpStatusCode -ErrorRecord $err
        $statusCode | Should Be 429
    }

    It 'returns null when exception has no response' {
        $ex = New-Object System.Exception 'no response'
        $err = [System.Management.Automation.ErrorRecord]::new(
            $ex,
            'test-id',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            $null
        )

        $statusCode = Get-HttpStatusCode -ErrorRecord $err
        $statusCode | Should Be $null
    }
}

Describe 'Invoke-JsonRequestWithRetry' {
    It 'supports GET requests' {
        Remove-Item Function:Invoke-RestMethod -ErrorAction SilentlyContinue
        function global:Invoke-RestMethod {
            param([string]$Uri, [string]$Method, [hashtable]$Headers)
            return [pscustomobject]@{
                uri = $Uri
                method = $Method
                headerCount = $Headers.Count
            }
        }

        $result = Invoke-JsonRequestWithRetry -Method 'Get' -Url 'http://localhost/api/health' -Headers @{ 'X-Test' = '1' } -MaxRetries 1

        $result.method | Should Be 'Get'
        $result.uri | Should Be 'http://localhost/api/health'
        $result.headerCount | Should Be 1
    }

    It 'supports POST requests with JSON body' {
        Remove-Item Function:Invoke-RestMethod -ErrorAction SilentlyContinue
        function global:Invoke-RestMethod {
            param([string]$Uri, [string]$Method, [string]$ContentType, [string]$Body)
            return [pscustomobject]@{
                uri = $Uri
                method = $Method
                contentType = $ContentType
                body = $Body
            }
        }

        $result = Invoke-JsonRequestWithRetry -Method 'Post' -Url 'http://localhost/api/auth/login' -Body @{ email = 'a@b.com' } -MaxRetries 1

        $result.method | Should Be 'Post'
        $result.contentType | Should Be 'application/json'
        $result.body | Should Match 'a@b.com'
    }

    It 'retries transient 500 responses and succeeds before max retries' {
        Remove-Item Function:Invoke-RestMethod -ErrorAction SilentlyContinue
        $script:restAttempt = 0
        function global:Invoke-RestMethod {
            param([string]$Uri, [string]$Method)
            if ($script:restAttempt -lt 2) {
                $script:restAttempt++
                $ex = New-Object System.Exception 'transient failure'
                Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 500 }) -Force
                throw $ex
            }

            return [pscustomobject]@{ ok = $true; uri = $Uri; method = $Method }
        }

        $result = Invoke-JsonRequestWithRetry -Method 'Get' -Url 'http://localhost/api/ping' -MaxRetries 3

        $result.ok | Should Be $true
        $script:restAttempt | Should Be 2
    }

    It 'throws when failures exceed retries' {
        Remove-Item Function:Invoke-RestMethod -ErrorAction SilentlyContinue
        function global:Invoke-RestMethod {
            param([string]$Uri, [string]$Method)
            $ex = New-Object System.Exception 'hard failure'
            Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 500 }) -Force
            throw $ex
        }

        { Invoke-JsonRequestWithRetry -Method 'Get' -Url 'http://localhost/api/ping' -MaxRetries 1 } | Should Throw
    }
}

Describe 'Invoke-StatusGetWithRetry' {
    It 'returns HTTP status code from web exception response' {
        Remove-Item Function:Invoke-WebRequest -ErrorAction SilentlyContinue
        function global:Invoke-WebRequest {
            param([string]$Uri, [string]$Method, [hashtable]$Headers, [int]$TimeoutSec)
            $ex = New-Object System.Exception 'not found'
            Add-Member -InputObject $ex -MemberType NoteProperty -Name Response -Value ([pscustomobject]@{ StatusCode = 404 }) -Force
            throw $ex
        }

        $statusCode = Invoke-StatusGetWithRetry -Url 'http://localhost/missing' -MaxRetries 1
        $statusCode | Should Be 404
    }

    It 'passes no-redirect mode to web request call' {
        Remove-Item Function:Invoke-WebRequest -ErrorAction SilentlyContinue
        $script:maxRedirection = -1
        function global:Invoke-WebRequest {
            param([string]$Uri, [string]$Method, [hashtable]$Headers, [int]$TimeoutSec, [int]$MaximumRedirection)
            $script:maxRedirection = $MaximumRedirection
            return [pscustomobject]@{ StatusCode = 302 }
        }

        $statusCode = Invoke-StatusGetWithRetry -Url 'http://localhost/admin' -NoRedirect -MaxRetries 1
        $statusCode | Should Be 302
        $script:maxRedirection | Should Be 0
    }
}
