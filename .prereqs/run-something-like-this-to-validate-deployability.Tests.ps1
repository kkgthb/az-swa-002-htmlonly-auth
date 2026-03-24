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
        # Let's make sure that the later "-Match" isn't failing 
        # over something silly like forgetting we changed the content 
        # of the home page.
        $allegedly_uploaded_body = Get-Content `
            -Path ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'src', 'web', 'index.html'))) `
            -Raw
        $allegedly_uploaded_body | Should -Match 'Hello World'
    }
    Describe "Deploy and visit the live site" {
        BeforeAll {
            # Deploy a fresh version of the live site
            & ([System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', '.cicd-helpers', 'deploy.ps1')))
            # Visit the live site
            try {
                $live_site = Invoke-WebRequest `
                    -Method 'GET' `
                    -Uri "https://$swa_hostname/" `
                    -MaximumRedirection 0 `
                    -ErrorAction 'Continue'
            }
            catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                $exception_status_code = [int]$_.Exception.Response.StatusCode
                $exception_location_header = $_.Exception.Response.Headers.Location
            }
        }
        It "should redirect to auth" {
            # Skip for now because I have issues with the actual auth part 
            # in my playground environment 
            # so for now I will just settle for 
            # a 302 to the correct auth endpoint.
            $exception_status_code | Should -Be '302'
            $exception_location_header | Should -Be '/.auth/login/aad'
        }
        It "should have hello world in the body" -Skip {
            # Skip for now because I have issues with the actual auth part 
            # so I cannot actually test for "Hello World" but I do not want 
            # to forget to do it later.
            If ($live_site) {
                $live_site_body = $live_site | Select-Object `
                    -Property 'Content'`
                    -ExpandProperty 'Content'
                $live_site_body | Should -Match 'Hello World'
            }
        }
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