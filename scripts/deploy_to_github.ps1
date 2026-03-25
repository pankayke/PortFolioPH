# PortfolioPH - GitHub Deployment Script
# This script will push your code to a new GitHub repository

param(
    [Parameter(Mandatory=$false)]
    [string]$RepoUrl = "",
    [Parameter(Mandatory=$false)]
    [string]$Token = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PortfolioPH GitHub Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to prompt for repository URL if not provided
function Get-RepoUrl {
    if ([string]::IsNullOrEmpty($RepoUrl)) {
        Write-Host "Please create a new repository at: https://github.com/new" -ForegroundColor Yellow
        Write-Host "  - Repository name: portfolioph" -ForegroundColor Yellow
        Write-Host "  - Do NOT initialize with README, .gitignore, or license" -ForegroundColor Yellow
        Write-Host ""
        $url = Read-Host "Enter the new repository URL (e.g., https://github.com/auzcee/portfolioph.git)"
        return $url
    }
    return $RepoUrl
}

# Function to prompt for token if not provided
function Get-Token {
    if ([string]::IsNullOrEmpty($Token)) {
        Write-Host ""
        Write-Host "GitHub Personal Access Token needed:" -ForegroundColor Yellow
        Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor Yellow
        Write-Host "  2. Generate new token (classic)" -ForegroundColor Yellow
        Write-Host "  3. Select 'repo' scope" -ForegroundColor Yellow
        Write-Host ""
        $tok = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tok)
        $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        return $plainToken
    }
    return $Token
}

try {
    # Get repository URL
    $newRepoUrl = Get-RepoUrl
    
    if ([string]::IsNullOrEmpty($newRepoUrl)) {
        Write-Host "Error: Repository URL is required" -ForegroundColor Red
        exit 1
    }
    
    # Get token
    $accessToken = Get-Token
    
    if ([string]::IsNullOrEmpty($accessToken)) {
        Write-Host "Error: Access token is required" -ForegroundColor Red
        exit 1
    }
    
    # Extract username from URL
    if ($newRepoUrl -match "github\.com[:/]([^/]+)/([^/.]+)") {
        $username = $Matches[1]
        $repoName = $Matches[2]
    } else {
        Write-Host "Error: Invalid repository URL format" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "Configuration:" -ForegroundColor Green
    Write-Host "  Username: $username" -ForegroundColor White
    Write-Host "  Repository: $repoName" -ForegroundColor White
    Write-Host ""
    
    # Construct authenticated URL
    $authenticatedUrl = "https://${username}:${accessToken}@github.com/${username}/${repoName}.git"
    
    Write-Host "Step 1: Removing old remote..." -ForegroundColor Cyan
    git remote remove origin 2>$null
    
    Write-Host "Step 2: Adding new remote..." -ForegroundColor Cyan
    git remote add origin $authenticatedUrl
    
    Write-Host "Step 3: Pushing main branch..." -ForegroundColor Cyan
    git push -u origin main
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push main branch"
    }
    
    Write-Host "Step 4: Pushing develop branch..." -ForegroundColor Cyan
    git push -u origin develop
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push develop branch"
    }
    
    Write-Host "Step 5: Pushing tags (Sprint 1 & Sprint 2)..." -ForegroundColor Cyan
    git push origin --tags
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push tags"
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Repository deployed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your repository is now available at:" -ForegroundColor White
    Write-Host "  https://github.com/${username}/${repoName}" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Sprint Tags Created:" -ForegroundColor White
    Write-Host "  - sprint-1: Sprint 1 (Core Setup & Architecture)" -ForegroundColor Yellow
    Write-Host "  - sprint-2: Sprint 2 (Authentication & User Setup)" -ForegroundColor Yellow
    Write-Host ""
    
    # Clean up the authenticated URL from remote (security)
    Write-Host "Step 6: Securing remote configuration..." -ForegroundColor Cyan
    $cleanUrl = "https://github.com/${username}/${repoName}.git"
    git remote set-url origin $cleanUrl
    
    Write-Host "Done! Remote URL cleaned for security." -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR: Deployment failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. Repository was created on GitHub" -ForegroundColor Yellow
    Write-Host "  2. Token has 'repo' permissions" -ForegroundColor Yellow
    Write-Host "  3. Repository URL is correct" -ForegroundColor Yellow
    exit 1
}
