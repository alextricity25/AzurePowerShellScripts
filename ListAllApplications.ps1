# Author: Miguel Alex Cantu
# Date: 05/11/2020
# Description:
# This script lists all the applications in the Azure AD tenant

# Graph API endpoints
$azureADAppsURI = 'https://graph.microsoft.com/v1.0/applications'

function List-AllApps($accessToken) {
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
                -Uri $nextPageURI `
                -Method Get
                if ($azureADApps.value) {
                    $azureADApplications += $azureADApps.value
                    Write-Debug "$($azureADApplications.Count)"
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
    $azureADApplicationsData = @{}
    foreach ($app in $azureADApplications) {
        $azureADApplicationsData[$app.appId] = $app
    }

    return $azureADApplicationsData
}