Describe "Azure SWA tests" {
    BeforeAll {
        [System.Environment]::SetEnvironmentVariable(`
                'AZURE_SUBSCRIPTION_ID', `
                "$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))", `
                'Process'`
        )
        $tfstate_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'AA-tf', 'terraform.tfstate'))
        $swa_deploy_secret_value = (
            jq `
                -r '.resources[] | select(.type=="github_actions_secret") | .instances[] | select(.attributes.secret_name=="MY_AZURE_SWA_DEPLOYMENT_TOKEN") | .attributes.plaintext_value' `
                --binary `
                $tfstate_file
        )
        [System.Environment]::SetEnvironmentVariable('SWA_CLI_DEPLOYMENT_TOKEN', $swa_deploy_secret_value, 'Process')
        $swa_appname = (
            jq `
                -r '.resources[] | select(.type=="azurerm_static_web_app") | .instances[0] | .attributes.name' `
                --binary `
                $tfstate_file
        )
        [System.Environment]::SetEnvironmentVariable('SWA_CLI_APP_NAME', $swa_appname, 'Process')
        $swa_hostname = (
            jq `
                -r '.resources[] | select(.type=="azurerm_static_web_app") | .instances[0] | .attributes.default_host_name' `
                --binary `
                $tfstate_file
        )
    }
    It "should be working from a local hello world" {
        $allegedly_uploaded_body = Get-Content `
            -Path ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'src', 'web', 'index.html'))) `
            -Raw
        $allegedly_uploaded_body | Should -Match 'Hello World'
    }
    It "should accept deployments from this local context" {
        & ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', '.cicd-helpers', 'deploy.ps1')))
    }
    It "should have hello world in the body" {
        $live_site_body = Invoke-WebRequest `
            -Method 'GET' `
            -Uri "https://$swa_hostname/" `
        | Select-Object `
            -Property 'Content'`
            -ExpandProperty 'Content'
        $live_site_body | Should -Match 'Hello World'
    }
    AfterAll {
        [System.Environment]::SetEnvironmentVariable('SWA_CLI_APP_NAME', $null, 'Process')
        [System.Environment]::SetEnvironmentVariable('SWA_CLI_DEPLOYMENT_TOKEN', $null, 'Process')
        $swa_deploy_secret_value = $null
        $swa_hostname = $null
        $swa_appname = $null
        $tfstate_file = $null
        [System.Environment]::SetEnvironmentVariable('AZURE_SUBSCRIPTION_ID', $null, 'Process')
    }
}