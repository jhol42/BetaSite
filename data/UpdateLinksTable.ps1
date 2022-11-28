# run
#.\GenerateSponsorTable.ps1 | clip
# Then past into index.html
class Link{
    $Name 
    $Url 
}

$index = Get-Content ../index.html

$links = [Link[]] (Get-Content Links.json | ConvertFrom-Json)

$lineNumber = 0
$beginTable = 0
$endTable = 0

foreach($line in $index)
{
    if($line -match "<!--\s*begin\s*links\s*-->")
    {
        $beginTable = $lineNumber+1
    }
    if($line -match "<!--\s*end\s*links\s*-->")
    {
        $endTable = $lineNumber
    }
    $lineNumber += 1
}

if($beginTable -eq 0)
{
    Write-Error "'<!-- begin links -->' not found"
    throw 
}
if($endTable -eq 0)
{
    Write-Error "'<!-- end links -->' not found"
    throw 
}

$first = $index | Select-Object -First $beginTable
$rest = $index | Select-Object -Skip $endTable

$tempFile = New-TemporaryFile

Set-Content -Path $tempFile -Value $first

foreach($link in $links)
{

    Out-File -FilePath $tempFile -Append -InputObject "        <tr>"
    Out-File -FilePath $tempFile -Append -InputObject "          <td><div style=`"word-wrap: break-word;`">$($link.Name)</div></td>"
    Out-File -FilePath $tempFile -Append -InputObject "          <td><a href=`"$($link.Url)`">$($link.Url)</a></td>"
    Out-File -FilePath $tempFile -Append -InputObject "        </tr>"
}

Out-File -FilePath $tempFile -Append -InputObject $rest -Encoding utf8
$timestamp = (Get-Date -Format "mm-dd-yyyy_hh.m.ss")
$fullpath = (resolve-path ..\index.html).Path
$indexInfos = New-Object System.IO.FileInfo($fullpath)
$backupFilename =  [System.IO.Path]::Combine($indexInfos.Directory.FullName, "index_$timestamp.html.bak") 
Move-Item -Path ..\index.html -Destination $backupFilename
Move-Item -Path $tempFile -Destination ..\index.html