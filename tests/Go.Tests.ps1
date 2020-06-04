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

    Set-Location -Path "source"
    $sourceLocation = Get-Location
    Write-Host "GOROOT ${env:GOROOT}"
    Write-Host "PATH ${env:PATH}"
    It "Run simple code" {
        $simpleLocation = Join-Path -Path $sourceLocation -ChildPath "simple"
        Set-Location -Path $simpleLocation
        try {
            go mod init example.com/m
        } 
        catch{
            Write-Host "LASTEXITCODE $LASTEXITCODE"
        } 
        finally{
        "go run simple.go" | Should -ReturnZeroExitCode
        "go build simple.go" | Should -ReturnZeroExitCode
        "./simple" | Should -ReturnZeroExitCode
        }
    }

    It "Run maps code" {
        $mapsLocation = Join-Path -Path $sourceLocation -ChildPath "maps"
        Set-Location -Path $mapsLocation
        try{
            go mod init example.com/m
        }
        catch {
            Write-Host "LASTEXITCODE $LASTEXITCODE"
        }
        finally {
            "go run maps.go" | Should -ReturnZeroExitCode
            "go build maps.go" | Should -ReturnZeroExitCode
            "./maps" | Should -ReturnZeroExitCode
        }
    }

    It "Run methods code" {
        $methodsLocation = Join-Path -Path $sourceLocation -ChildPath "methods"
        Set-Location -Path $methodsLocation
        try{
            go mod init example.com/m
        }
        catch {
            Write-Host "LASTEXITCODE $LASTEXITCODE"
        }
        finally {
            "go run methods.go" | Should -ReturnZeroExitCode
            "go build methods.go" | Should -ReturnZeroExitCode
            "./methods" | Should -ReturnZeroExitCode
        }
    }
}