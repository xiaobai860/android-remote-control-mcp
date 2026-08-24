$ErrorActionPreference = 'SilentlyContinue'
# 扫描 app 下所有 flavor 的 ui 目录
$roots = @(
  'app/src/main/kotlin',
  'app/src/gms/kotlin',
  'app/src/foss/kotlin'
)
$results = @()
foreach ($r in $roots) {
  if (-not (Test-Path $r)) { continue }
  $files = Get-ChildItem -Recurse -Filter *.kt $r
  foreach ($f in $files) {
    $lines = Get-Content -Encoding utf8 $f.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
      $line = $lines[$i]
      # Text("...") 且非 stringResource
      if ($line -match 'Text\(\s*"') {
        if ($line -notmatch 'stringResource') {
          if ($line -match 'Text\(\s*"([^"]*)"') {
            $results += [PSCustomObject]@{
              File = $f.FullName.Replace($PWD.Path + '\', '')
              Line = $i + 1
              Kind = 'Text'
              Value = $Matches[1]
            }
          }
        }
      }
      # contentDescription = "..."
      if ($line -match 'contentDescription\s*=\s*"([^"]*)"') {
        $results += [PSCustomObject]@{
          File = $f.FullName.Replace($PWD.Path + '\', '')
          Line = $i + 1
          Kind = 'desc'
          Value = $Matches[1]
        }
      }
    }
  }
}
$results | Sort-Object File, Line | ForEach-Object {
  "{0}:{1}  [{2}]  {3}" -f $_.File, $_.Line, $_.Kind, $_.Value
}
Write-Output ""
Write-Output ("TOTAL: " + $results.Count)
