$folder_with_swa_cli_config_json_in_it = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..'))
Push-Location($folder_with_swa_cli_config_json_in_it)

# Note:  the following OS environment variables must be set first:
#   SWA_CLI_DEPLOYMENT_TOKEN  -> from: terraform output -raw swa_deployment_token
#   SWA_CLI_APP_NAME          -> from: terraform output -raw swa_app_name
swa deploy `
    --config './swa-cli.config.json' `
    --swa-config-location './configfile' `
    --env 'production' `
    --app-location './src/web'

Pop-Location
