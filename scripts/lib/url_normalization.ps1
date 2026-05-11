function Normalize-ApiRootUrl {
    param(
        [Parameter(Mandatory = $true)][string]$Url
    )

    $trimmed = $Url.Trim()
    $trimmed = $trimmed.TrimEnd('/')

    if ($trimmed -match '(?i)/api$') {
        $trimmed = $trimmed.Substring(0, $trimmed.Length - 4).TrimEnd('/')
    }

    return $trimmed
}
