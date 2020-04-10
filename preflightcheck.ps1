# Param (
#     [string]$domainToJoin,
#     [string]$domainUsername,
#     [string]$domainPassword,
#     [string]$TenantUsername, 
#     [string]$TenantPassword
# )

$domainToJoin = "mylab.local"
$domainUsername = "dcAdmin"
$domainPasswordConvert = "dcAdmin12345"| ConvertTo-SecureString -AsPlainText -Force

# Test 1 : DNS resolution
try {
    Resolve-DnsName -Name $domainToJoin -ErrorAction Stop
}
catch [System.ComponentModel.Win32Exception] {
    Write-Verbose -Verbose "DNS name does not exist, DNS resolution fail!"
}
catch {
    #my_variable = (Get-Counter -ListSet IPAddress) != null
    Write-Verbose -Verbose "DNS resolution success!"
}

$domainlist = (Get-WmiObject Win32_ComputerSystem).Domain
$domaincredential = $domainToJoin + "\" + $domainUsername
$credential = New-Object System.Management.Automation.PSCredential($domaincredential ,$domainPasswordConvert)

Function addComputerTest {
    try {
        Add-Computer -Domain $domainToJoin -Credential $credential -ErrorAction Stop
    }
    catch [System.InvalidOperationException] {
        # password or user wrong or domain wrong
        Write-Verbose -Verbose "failed to join domain"
    }
    # To do : clarify the wrong type
    # catch [System.InvalidOperationException] {
    #     # domain wrong
    #     Write-Verbose -Verbose "failed to join domain with following error message: 
    #     The specified domain either does not exist or could not be contacted or  with following error message: The user name or password is incorrect."
    # }
    catch {
        Write-Verbose -Verbose "Join an Active Directory domain success!"
    }
}

Function removeComputerTest {
    # vm has joined aimed domain, start unjoin
    try {
        #Remove-Computer -UnjoinDomaincredential mylab.local\dcAdmin
        Remove-Computer -UnjoinDomaincredential $credential -Force -ErrorAction Stop
    }
    catch [System.InvalidOperationException] {
        # TO do : clarify credential user error or password wrong
        Write-Verbose -Verbose "failed to unjoin domain"
    }
    catch {
        Write-Verbose -Verbose "Unjoin an Active Directory domain success!"
    }
}

# Test 2 :  add / remove computer
if ($domainlist -eq "WORKGROUP") {
    # this computer hasn't join domain, start join and injoin
    addComputerTest
    removeComputerTest
}
elseif ($domainlist -eq $domainToJoin) {
    # this computer has joined aimed domain, start test unjoin and join by this credential
    removeComputerTest
    addComputerTest
}
else {
    # this computer has joined another AD
    Write-Verbose -Verbose "This device is joined to another AD. To join an Active Directory domain, you must first go to settings and choose to disconnect your device from your work or school"
}