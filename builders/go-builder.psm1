class GoBuilder {
    <#
    .SYNOPSIS
    Base Go builder class.

    .DESCRIPTION
    Base Go builder class that contains general builder methods.

    .PARAMETER Version
    The version of Go that should be built.

    .PARAMETER Platform
    The platform of Go that should be built.

    .PARAMETER Architecture
    The architecture with which Go should be built.

    .PARAMETER TempFolderLocation
    The location of temporary files that will be used during Go package generation. Using system BUILD_STAGINGDIRECTORY variable value.

    .PARAMETER ArtifactLocation
    The location of generated Go artifact. Using system environment BUILD_BINARIESDIRECTORY variable value.

    .PARAMETER InstallationTemplatesLocation
    The location of installation script template. Using "installers" folder from current repository.

    #>

    [version] $Version
    [string] $Platform
    [string] $Architecture
    [string] $TempFolderLocation
    [string] $WorkFolderLocation
    [string] $ArtifactFolderLocation
    [string] $InstallationTemplatesLocation

    GoBuilder ([version] $version, [string] $platform, [string] $architecture) {
        $this.Version = $version
        $this.Platform = $platform
        $this.Architecture = $architecture

        $this.TempFolderLocation = [IO.Path]::GetTempPath()
        $this.WorkFolderLocation = $env:BUILD_BINARIESDIRECTORY
        $this.ArtifactFolderLocation = $env:BUILD_STAGINGDIRECTORY
        

        $this.InstallationTemplatesLocation = Join-Path -Path $PSScriptRoot -ChildPath "../installers"
    }

    [uri] GetBaseUri() {
        <#
        .SYNOPSIS
        Return base URI for Go binaries.
        #>

        return "https://storage.googleapis.com/golang/"
    }

    [string] Download() {
        <#
        .SYNOPSIS
        Download Go binaries into artifact location.
        #>

        $binariesUri = $this.GetBinariesUri()
        $targetFilename = [IO.Path]::GetFileName($binariesUri)
        $targetFilepath = Join-Path -Path $this.TempFolderLocation -ChildPath $targetFilename

        Write-Debug "Download binaries from $binariesUri to $targetFilepath"
        try {
            (New-Object System.Net.WebClient).DownloadFile($binariesUri, $targetFilepath)
        } catch {
            Write-Host "Error during downloading file from '$binariesUri'"
            exit 1
        }

        Write-Debug "Done; Binaries location: $targetFilepath"
        return $targetFilepath
    }

    [void] Build() {
        <#
        .SYNOPSIS
        Generates Go artifact from downloaded binaries.
        #>

        Write-Host "Download Go $($this.Version) [$($this.Architecture)] executable..."
        $binariesArchivePath = $this.Download()

        Write-Host "Unpack binaries to target directory"
        $this.ExtractBinaries($binariesArchivePath)

        Write-Host "Create installation script..."
        $this.CreateInstallationScript()

        Write-Host "Archive artifact"
        $this.ArchiveArtifact()
    }
}
