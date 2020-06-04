using module "./builders/go-builder.psm1"

class NixGoBuilder : GoBuilder {
    <#
    .SYNOPSIS
    Ubuntu Go builder class.

    .DESCRIPTION
    Contains methods that required to build Ubuntu Go artifact from sources. Inherited from base NixGoBuilder.

    .PARAMETER platform
    The full name of platform for which Go should be built.

    .PARAMETER version
    The version of Go that should be built.

    #>

    [string] $InstallationTemplateName
    [string] $InstallationScriptName
    [string] $OutputArtifactName

    NixGoBuilder(
        [version] $version,
        [string] $platform,
        [string] $architecture
    ) : Base($version, $platform, $architecture) {
        $this.InstallationTemplateName = "nix-setup-template.sh"
        $this.InstallationScriptName = "setup.sh"
        $this.OutputArtifactName = "go-$Version-$Platform-$Architecture.tar.gz"
    }

    [uri] GetBinariesUri() {
        <#
        .SYNOPSIS
        Get base Go URI and return complete URI for Go installation executable.
        #>

        $base = $this.GetBaseUri()
        $arch = $this.Architecture

        If ($this.Version.Build -eq "0") {
            $goVersion = "go$($this.Version.ToString(2))"
        } else {
            $goVersion = "go$($this.Version.ToString(3))"
        }
        If ($this.Architecture -eq "x64"){
            $arch = "amd64"
        }
        $filename = "$goVersion.$($this.Platform)-$arch.tar.gz"

        return "${base}/$filename"
    }

    [void] ExtractBinaries($archivePath) {
        Extract-TarArchive -ArchivePath $archivePath -OutputDirectory $this.WorkFolderLocation
    }

    [void] CreateInstallationScript() {
        <#
        .SYNOPSIS
        Create Go artifact installation script based on template specified in InstallationTemplateName property.
        #>

        $installationScriptLocation = New-Item -Path $this.WorkFolderLocation -Name $this.InstallationScriptName -ItemType File
        $installationTemplateLocation = Join-Path -Path $this.InstallationTemplatesLocation -ChildPath $this.InstallationTemplateName

        $installationTemplateContent = Get-Content -Path $installationTemplateLocation -Raw
        $installationTemplateContent = $installationTemplateContent -f $this.Version.ToString(3)
        $installationTemplateContent | Out-File -FilePath $installationScriptLocation

        Write-Debug "Done; Installation script location: $installationScriptLocation)"
    }

    [void] ArchiveArtifact() {
        $OutputPath = Join-Path $this.ArtifactFolderLocation $this.OutputArtifactName
        Create-TarArchive -SourceFolder $this.WorkFolderLocation -ArchivePath $OutputPath
    }
}
