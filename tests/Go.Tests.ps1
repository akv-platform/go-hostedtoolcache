param (
    [Version] [Parameter (Mandatory = $true)] [ValidateNotNullOrEmpty()]
    $Version
)

Import-Module (Join-Path $PSScriptRoot "../helpers/pester-extensions.psm1")
Import-Module (Join-Path $PSScriptRoot "../helpers/common-helpers.psm1")

Describe "Go" {
    It "is available" {
        "go version" | Should -ReturnZeroExitCode
    }

    It "version is correct" {
        $versionOutput = Invoke-Expression "go version"
        $finalVersion = $Version.ToString(3)
        If ($Version.Build -eq "0"){
            $finalVersion = $Version.ToString(2)
        }
        $versionOutput | Should -Match $finalVersion
    }

    It "is used from tool-cache" {
        $goPath = (Get-Command "go").Path
        $goPath | Should -Not -BeNullOrEmpty
        $expectedPath = Join-Path -Path $env:AGENT_TOOLSDIRECTORY -ChildPath "go"
        $goPath.startsWith($expectedPath) | Should -BeTrue -Because "'$goPath' is not started with '$expectedPath'"
    }

    Set-Location -Path "source"
    $sourceLocation = Get-Location

    It "Run simple code" {
        $simpleLocation = Join-Path -Path $sourceLocation -ChildPath "simple"
        Set-Location -Path $simpleLocation
        # we need use Execute command because on windows it produces exit code -1
        # but it works as expected
        Execute-Command -Command "go mod init example.com/m" -ErrorAction Continue
        "go run simple.go" | Should -ReturnZeroExitCode
        "go build simple.go" | Should -ReturnZeroExitCode
        "./simple" | Should -ReturnZeroExitCode
    }

    It "Run maps code" {
        $mapsLocation = Join-Path -Path $sourceLocation -ChildPath "maps"
        Set-Location -Path $mapsLocation
        # we need use Execute command because on windows it produces exit code -1
        # but it works as expected
        Execute-Command -Command "go mod init example.com/m" -ErrorAction Continue
        "go run maps.go" | Should -ReturnZeroExitCode
        "go build maps.go" | Should -ReturnZeroExitCode
        "./maps" | Should -ReturnZeroExitCode
    }

    It "Run methods code" {
        $methodsLocation = Join-Path -Path $sourceLocation -ChildPath "methods"
        Set-Location -Path $methodsLocation
        # we need use Execute command because on windows it produces exit code -1
        # but it works as expected
        Execute-Command -Command "go mod init example.com/m" -ErrorAction Continue
        "go run methods.go" | Should -ReturnZeroExitCode
        "go build methods.go" | Should -ReturnZeroExitCode
        "./methods" | Should -ReturnZeroExitCode
    }
}