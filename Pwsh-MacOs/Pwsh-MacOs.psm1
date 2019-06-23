function convertFileSize {
    param(
        $bytes
    )

    if ($bytes -lt 1MB) {
        return "$([Math]::Round($bytes / 1KB, 2)) KB"
    }
    elseif ($bytes -lt 1GB) {
        return "$([Math]::Round($bytes / 1MB, 2)) MB"
    }
    elseif ($bytes -lt 1TB) {
        return "$([Math]::Round($bytes / 1GB, 2)) GB"
    }
}

function Clear-Trash {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        Write-Verbose "Getting files from trash."
        $TrashBinFiles = Get-ChildItem -Path (Join-Path -Path $env:HOME -ChildPath ".Trash")
    }

    process {
        $DeletedFiles = @()
        foreach ($File in $TrashBinFiles) {
            if ($PSCmdlet.ShouldProcess($File.FullName, "Delete")) {
                Remove-Item -Path $File -Recurse -Force -Confirm:$false
                $DeletedFiles += $File
            }
        }
    }

    end {
        return $DeletedFiles
    }
}

function Get-OldDownloads {
    [CmdletBinding()]
    param(
        [datetime]$DownloadAge = ((Get-Date).AddMonths(-2))
    )

    begin {
        filter FilterDownloadAge {
            if ($PSItem.CreationTime -le $DownloadAge) {
                $PSItem
            }
        }

        $DownloadsFolder = Get-ChildItem -Path (Join-Path -Path $env:HOME -ChildPath "Downloads") | FilterDownloadAge

        $ReturnData = @()
    }

    process {
        $ReturnData = foreach ($File in $DownloadsFolder) {

            $CustomFileObj = [pscustomobject]@{ }
        
            foreach ($p in $File.PSObject.Properties) {
                Add-Member -InputObject $CustomFileObj -MemberType NoteProperty -Name $p.Name -Value $p.Value
            }
        
            Add-Member -InputObject $CustomFileObj -MemberType NoteProperty -Name "FileSize" -Value (convertFileSize -bytes $CustomFileObj.Length)

            $defaultOutput = "Mode", "CreationTime", "FileSize", "Name"
            $defaultPropertSet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet", [string[]]$defaultOutput)
            $CustomOutput = [System.Management.Automation.PSMemberInfo[]]@($defaultPropertSet)
            Add-Member -InputObject $CustomFileObj -MemberType MemberSet -Name PSStandardMembers -Value $CustomOutput

            $CustomFileObj
        }
    }

    end {
        return $ReturnData
    }
}