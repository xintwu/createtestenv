Param (
    [string]$domainToJoin,
    [string]$domainUsername,
    [string]$domainPassword,
)

$domainPasswordConvert = $domainPassword | ConvertTo-SecureString -AsPlainText -Force

$domainlist = (Get-WmiObject Win32_ComputerSystem).Domain
$domaincredential = $domainToJoin + "\" + $domainUsername
$credential = New-Object System.Management.Automation.PSCredential($domaincredential ,$domainPasswordConvert)

Add-Computer -Domain $domainToJoin -Credential $credential -ErrorAction Stop