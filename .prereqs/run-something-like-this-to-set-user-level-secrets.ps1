$tfstate_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'AA-tf', 'terraform.tfstate'))
$swa_deploy_secret_value = (
    jq `
        -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="MY_AZURE_SWA_DEPLOYMENT_TOKEN") | .attributes.plaintext_value' `
        --binary `
        $tfstate_file
)
[System.Environment]::SetEnvironmentVariable('SWA_CLI_DEPLOYMENT_TOKEN', $swa_deploy_secret_value, 'User')
[System.Environment]::SetEnvironmentVariable('SWA_CLI_DEPLOYMENT_TOKEN', $swa_deploy_secret_value, 'Process')
$swa_appname = (
    jq `
        -r '.resources[] | select(.type=="azurerm_static_web_app") | .instances[0] | .attributes.name' `
        --binary `
        $tfstate_file
)
[System.Environment]::SetEnvironmentVariable('SWA_CLI_APP_NAME', $swa_appname, 'User')
[System.Environment]::SetEnvironmentVariable('SWA_CLI_APP_NAME', $swa_appname, 'Process')
Write-Host("App name is $([System.Environment]::GetEnvironmentVariable('SWA_CLI_APP_NAME'))")
$swa_deploy_secret_value = $null
$swa_appname = $null
$tfstate_file = $null