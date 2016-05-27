$installPath = Join-Path ${env:ProgramFiles(x86)} 'Impero Solutions Ltd\Impero Server'

$compatibleVersion = @{
    'v5321' = @( 'v5321' )
}

$version = 'v5321'

$dataPath = @(
    'Data',
    'Recordings',
    'ConsoleLogs',
    'Inventory'
)

function Test-DataPath{
    $dataPath.ForEach({join-path $installPath $psitem}) | Test-Path
}

function mklink{
    Param(
        # Location of the directory to be linked
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=0)]
        [string]
        $Link
        
        , # Location of the files to link to.
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=1)]
        [string]
        $Target
    )
    Process{
        $leaf = split-path $link -leaf

        $linkTarget = Join-Path $Target $leaf
        write-host ("cmd /c mklink /J $args ")
    }
}

function Mount-Impero{
    $dataPath.ForEach({join-path $installPath $psitem}) | mklink -Target (Join-Path 'U:\' $version)
}

function Set-ImperoDnsRecord($ipAddress,[switch]$confrm){
    $New = $DNS = Get-DnsServerResourceRecord -ComputerName bhs-dc01 -ZoneName bhs.internal -RRType A -name Impero_Server
  
    if($confim -and $ipAddress){
        $new.RecordData.IPv4Address = [System.Net.IPAddress]::parse($ipAddress)
        Set-DnsServerResourceRecord -NewInputObject $New -OldInputObject $DNS -ZoneName bhs.internal -ComputerName bhs-dc01
    } else {
        return $New
    }
}

Export-ModuleMember -Function Mount-Impero, Test-DataPath, Set-ImperoDnsRecord
