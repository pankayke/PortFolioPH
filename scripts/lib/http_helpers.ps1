function Get-HttpStatusCode {
    param(
        [Parameter(Mandatory = $true)]$ErrorRecord
    )

    try {
        if ($ErrorRecord.Exception -and $ErrorRecord.Exception.Response) {
            return [int]$ErrorRecord.Exception.Response.StatusCode
        }
    } catch {
        return $null
    }

    return $null
}

function Invoke-JsonRequestWithRetry {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('Get', 'Post', 'Put')][string]$Method,
        [Parameter(Mandatory = $true)][string]$Url,
        [hashtable]$Headers = @{},
        $Body,
        [int]$MaxRetries = 3
    )

    $attempt = 0
    while ($true) {
        try {
            if ($Method -eq 'Get') {
                return Invoke-RestMethod -Uri $Url -Method Get -Headers $Headers
            }

            return Invoke-RestMethod -Uri $Url -Method $Method -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 10) -Headers $Headers
        } catch {
            $attempt++
            $statusCode = Get-HttpStatusCode -ErrorRecord $_
            if ($attempt -lt $MaxRetries -and ($statusCode -eq 429 -or $statusCode -ge 500)) {
                Start-Sleep -Seconds 1
                continue
            }
            throw
        }
    }
}

function Invoke-JsonGetWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [hashtable]$Headers = @{},
        [int]$MaxRetries = 3
    )

    return Invoke-JsonRequestWithRetry -Method 'Get' -Url $Url -Headers $Headers -MaxRetries $MaxRetries
}

function Invoke-JsonPostWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)]$Body,
        [hashtable]$Headers = @{},
        [int]$MaxRetries = 3
    )

    return Invoke-JsonRequestWithRetry -Method 'Post' -Url $Url -Body $Body -Headers $Headers -MaxRetries $MaxRetries
}

function Invoke-JsonPutWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)]$Body,
        [hashtable]$Headers = @{},
        [int]$MaxRetries = 3
    )

    return Invoke-JsonRequestWithRetry -Method 'Put' -Url $Url -Body $Body -Headers $Headers -MaxRetries $MaxRetries
}

function Invoke-StatusGetWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [hashtable]$Headers = @{},
        [switch]$NoRedirect,
        [int]$MaxRetries = 3
    )

    $attempt = 0
    while ($true) {
        try {
            if ($NoRedirect) {
                return (Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -Headers $Headers -TimeoutSec 30 -MaximumRedirection 0).StatusCode
            }

            return (Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -Headers $Headers -TimeoutSec 30).StatusCode
        } catch {
            $attempt++
            $statusCode = Get-HttpStatusCode -ErrorRecord $_
            if ($statusCode -ne $null) {
                if ($attempt -lt $MaxRetries -and ($statusCode -eq 429 -or $statusCode -ge 500)) {
                    Start-Sleep -Seconds 1
                    continue
                }
                return $statusCode
            }

            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds 1
                continue
            }

            throw
        }
    }
}
