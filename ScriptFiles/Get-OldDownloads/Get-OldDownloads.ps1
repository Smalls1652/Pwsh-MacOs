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

        $CustomFileObj = [pscustomobject]@{}
        
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