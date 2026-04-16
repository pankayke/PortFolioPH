$ErrorActionPreference = 'Stop'

$helperPath = Join-Path $PSScriptRoot '..\lib\url_normalization.ps1'
. $helperPath

Describe 'Normalize-ApiRootUrl' {
    It 'keeps host root URL unchanged' {
        $result = Normalize-ApiRootUrl -Url 'http://localhost:8000'
        $result | Should Be 'http://localhost:8000'
    }

    It 'strips trailing slash from host root URL' {
        $result = Normalize-ApiRootUrl -Url 'http://localhost:8000/'
        $result | Should Be 'http://localhost:8000'
    }

    It 'strips terminal /api suffix' {
        $result = Normalize-ApiRootUrl -Url 'http://localhost:8000/api'
        $result | Should Be 'http://localhost:8000'
    }

    It 'strips terminal /api suffix with trailing slash' {
        $result = Normalize-ApiRootUrl -Url 'http://localhost:8000/api/'
        $result | Should Be 'http://localhost:8000'
    }

    It 'handles uppercase API suffix' {
        $result = Normalize-ApiRootUrl -Url 'http://localhost:8000/API'
        $result | Should Be 'http://localhost:8000'
    }
}
