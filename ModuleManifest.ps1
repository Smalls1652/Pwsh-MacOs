$ManifestSplat = @{
    "Path" = "./Pwsh-MacOs/Pwsh-MacOs.psd1";
    "ModuleVersion" = "1906.23.01";
    "FunctionsToExport" = @("Clear-Trash", "Get-OldDownloads")
}

Update-ModuleManifest @ManifestSplat