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