# run
#.\GenerateSponsorTable.ps1 | clip
# Then past into index.html
class Sponsor{
    $BusinessName 
    $Website 
    $Years
}

$index = Get-Content ../index.html

$sponsors = [Sponsor[]] (Get-Content Sponsors2.json | ConvertFrom-Json)
$sponsors = $sponsors | Sort-Object -Property businessName

$lineNumber = 0
$beginTable = 0
$endTable = 0

foreach($line in $index)
{
    if($line -match "<!--\s*begin\s*sponsors\s*-->")
    {
        $beginTable = $lineNumber+1
    }
    if($line -match "<!--\s*end\s*sponsors\s*-->")
    {
        $endTable = $lineNumber
    }
    $lineNumber += 1
}

if($beginTable -eq 0)
{
    Write-Error "'<!-- begin sponsors -->' not found"
    throw 
}
if($endTable -eq 0)
{
    Write-Error "'<!-- end sponsors -->' not found"
    throw 
}

$first = $index | Select-Object -First $beginTable
$rest = $index | Select-Object -Skip $endTable


$tempFile = New-TemporaryFile

Set-Content -Path $tempFile -Value $first

foreach($sponsor in $sponsors)
{

    Out-File -FilePath $tempFile -Append -InputObject "        <tr>"
    Out-File -FilePath $tempFile -Append -InputObject "          <td><div style=`"word-wrap: break-word;`">$($sponsor.BusinessName)</div></td>"
    Out-File -FilePath $tempFile -Append -InputObject "          <td><a href=`"$($sponsor.Website)`">$($sponsor.Website)</a></td>"
    Out-File -FilePath $tempFile -Append -InputObject "          <td>$($sponsor.Years -join ', ')</td>"
    Out-File -FilePath $tempFile -Append -InputObject "        </tr>"
}

Out-File -FilePath $tempFile -Append -InputObject $rest -Encoding utf8
$timestamp = (Get-Date -Format "mm-dd-yyyy_hh.m.ss")
$fullpath = (resolve-path ..\index.html).Path
$indexInfos = New-Object System.IO.FileInfo($fullpath)
$backupFilename =  [System.IO.Path]::Combine($indexInfos.Directory.FullName, "index_$timestamp.html.bak") 
Move-Item -Path ..\index.html -Destination $backupFilename
Move-Item -Path $tempFile -Destination ..\index.html