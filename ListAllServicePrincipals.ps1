# Author: Miguel Alex Cantu
# Date: 05/11/2020
# Description:
# This script lists all the service principals in the Azure AD tenant.
# with a servicePrincipalType of "Application"

# Graph API endpoints
$azureADSPResultsURI = "https://graph.microsoft.com/v1.0/servicePrincipals?&`$filter=servicePrincipalType eq `'Application`'"

function List-AllServicePrincipals($accessToken) {
    $azureADServicePrincipals = @()

    $azureADSPResults = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
    -Uri $azureADSPResultsURI `
    -Method Get
    #$azureADSPResults | Get-Member
    

    # Paginating through the results
    if ($azureADSPResults.value) {
        $azureADServicePrincipals += $azureADSPResults.value
        if ($azureADSPResults.'@odata.nextLink') {
            $nextPageURI = $azureADSPResults.'@odata.nextLink'
            do {
                $azureADSPResults = $null
                $azureADSPResults = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
                -Uri $nextPageURI `
                -Method Get
                if ($azureADSPResults.value) {
                    $azureADServicePrincipals += $azureADSPResults.value
                    Write-Debug "$($azureADServicePrincipals.Count)"
                }
                if ($azureADSPResults.'@odata.nextLink'){
                    $nextPageURI = $azureADSPResults.'@odata.nextLink'
                }
                else {
                    $nextPageURI = $null
                }
            } until (!$nextPageURI)
        }
    }

    $azureADServicePrincipalsData = @{}
    foreach ($sp in $azureADServicePrincipals) {
        $azureADServicePrincipalsData[$sp.id] = $sp
    }

    return $azureADServicePrincipalsData
}