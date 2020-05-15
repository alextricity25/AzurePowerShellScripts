# Author: Miguel Alex Cantu
# Date: 05/11/2020
# Description:
# This script lists all the applications in our Azure AD tenant

# Loading functions
. ./AzureAuthenticate.ps1

# Graph API endpoints
$azureADAppsURI = 'https://graph.microsoft.com/v1.0/applications'

# Getting access tokens
$accessToken = Get-AccessToken

function List-AllApps {
    $azureADApplications = @()

    $azureADApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
    -Uri $azureADAppsURI `
    -Method Get
    #$azureADApps | Get-Member
    

    # Paginating through the results
    if ($azureADApps.value) {
        $azureADApplications += $azureADApps.value
        if ($azureADApps.'@odata.nextLink') {
            $nextPageURI = $azureADApps.'@odata.nextLink'
            do {
                $azureADApps = $null
                $azureADApps = Invoke-RestMethod -Headers @{Authorization = "Bearer $($accessToken.AccessToken)" } `
                -Uri $azureADAppsURI `
                -Method Get
                if ($azureADApps.value) {
                    $azureADApplications += $azureADApps.value
                    $azureADApplications.Count
                }
                if ($azureADApps.'@odata.nextLink'){
                    $nextPageURI = $azureADApps.'@odata.nextLink'
                }
                else {
                    $nextPageURI = $null
                }
            } until (!$nextPageURI)
        }
    }

    return $azureADApplications
}

List-AllApps