cd $PSScriptRoot

$passwordArg=""
if (Test-Path "C:\tools\mysql\current\initialized" -PathType Leaf) {
    if ($env:MYSQL_ROOT_PASSWORD) {
        $passwordArg="-p${env:MYSQL_ROOT_PASSWORD}"
    }
}

$started=$false
For ($i=0; $i -le 180; $i++) {
    mysqladmin -h localhost -P 3306 -u root $passwordArg status | Out-Null
    if ($LastExitCode -eq 0) {
        $started=$true
        break;
    }
    Start-Sleep 1
}
if (!$started) {
    Get-EventLog -LogName System -After (Get-Date).AddMinutes(-5) | Select -ExpandProperty Message
    Write-Error "mysql failed to start in 180 seconds"
    exit 1
}

if (!(Test-Path "C:\tools\mysql\current\initialized" -PathType Leaf)) {
    if ($env:MYSQL_ROOT_PASSWORD) {
        $command=""
        $command="${command}CREATE USER 'root'@'%' IDENTIFIED BY '${env:MYSQL_ROOT_PASSWORD}';"
        $command="${command}GRANT ALL ON *.* TO 'root'@'%';"
        $command="${command}ALTER USER 'root'@'localhost' IDENTIFIED BY '${env:MYSQL_ROOT_PASSWORD}';"
        mysql -h localhost -P 3306 -u root -e $command
    }
    New-Item -ItemType file "C:\tools\mysql\current\initialized" | Out-Null
}

Get-EventLog -LogName System -After (Get-Date).AddMinutes(-5) | Select -ExpandProperty Message
$idx = (get-eventlog -LogName System -Newest 1).Index;
while ($true)
{
    start-sleep -Seconds 1
    $idx2  = (Get-EventLog -LogName System -newest 1).index
    get-eventlog -logname system -newest ($idx2 - $idx) |  sort index | Select -ExpandProperty Message
    $idx = $idx2
}
