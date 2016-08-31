
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve) -Filter '*.ps1' |
    Where-Object { $_.Name -notlike '*.Tests.ps1' } |
    ForEach-Object { . $_.FullName }