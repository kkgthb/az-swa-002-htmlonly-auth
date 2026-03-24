$folder_with_swa_cli_config_json_in_it = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..'))
Push-Location($folder_with_swa_cli_config_json_in_it)

# swa deploy copies staticwebapp.config.json from --swa-config-location into the
# app folder while staging the upload, then leaves it behind. Remove it first so
# a stale copy never shadows the intended config on the next run.
$stale_config = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($folder_with_swa_cli_config_json_in_it, 'src', 'web', 'staticwebapp.config.json'))
if (Test-Path $stale_config) { Remove-Item $stale_config }

# Note:  the following OS environment variables must be set first:
#   SWA_CLI_DEPLOYMENT_TOKEN  -> from: terraform output -raw swa_deployment_token
#   SWA_CLI_APP_NAME          -> from: terraform output -raw swa_app_name
swa deploy `
    --config './swa-cli.config.json' `
    --swa-config-location './configfile' `
    --env 'production' `
    --app-location './src/web'

# Clean up just for good measure
$stale_config = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($folder_with_swa_cli_config_json_in_it, 'src', 'web', 'staticwebapp.config.json'))
if (Test-Path $stale_config) { Remove-Item $stale_config }

Pop-Location
