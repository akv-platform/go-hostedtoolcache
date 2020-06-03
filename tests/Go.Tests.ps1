param (
    [Version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")

Describe "Go" {
    It "is available" {
        "go version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression "go version"
        $versionOutput | Should -Match $Version
    }

    It "is used from tool-cache" {
        $goPath = (Get-Command "go").Path
        $goPath | Should -Not -BeNullOrEmpty
        $expectedPath = Join-Path -Path $env:AGENT_TOOLSDIRECTORY -ChildPath "go"
        $goPath.startsWith($expectedPath) | Should -BeTrue -Because "'$goPath' is not started with '$expectedPath'"
    }

    It "Run simple code" {
        "go install ./simpletest" | Should -ReturnZeroExitCode
        "./simpletest" | Should -ReturnZeroExitCode
    }
}