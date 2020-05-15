# Author: Miguel Alex Cantu
# Date: 05/11/2020
# Description:
# This script contains a single function for authentcating with Azure AD using
# a client secret and application permissions.

function Get-AccessToken {
    $tenantID = $env:APP_AUDITOR_TENANT_ID
    $clientID = $env:APP_AUDITOR_CLIENT_ID
    $clientSecret = (ConvertTo-SecureString $env:APPAUDITORSECRET -AsPlainText -Force)
    $accessToken = Get-MsalToken -clientID $clientID -clientSecret $clientSecret -tenantID $tenantID | Select-Object -Property AccessToken
    return $accessToken
}
<#
If you want to authenticate using a client certificate:
    PS C:\>$ClientCertificate = Get-Item Cert:\CurrentUser\My\0000000000000000000000000000000000000000
    PS C:\>$MsalClientApplication = Get-MsalClientApplication -ClientId '00000000-0000-0000-0000-000000000000' -ClientCertificate $ClientCertificate -TenantId '00000000-0000-0000-0000-000000000000'
    PS C:\>$MsalClientApplication | Get-MsalToken -Scope 'https://graph.microsoft.com/.default'
    Pipe in confidential client options object to get a confidential client application using a client certificate and target a specific tenant.
Please see:
https://github.com/jasoth/MSAL.PS/blob/master/src/Get-MsalToken.ps1
#>