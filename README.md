# The smallest GitHub website you can make that will build an Azure Static Web App

_(Accompanies [associated blog post on Katie Kodes](katiekodes.com/azure-swa-mvb/))_

---

## First-time setup

1. Under the "**Use this template** dropdown at the top-right of [the original repository hosting this tutorial](https://github.com/kkgthb/az-swa-001-htmlonly-tiny), click "**[Create a new repository](https://github.com/kkgthb/az-swa-001-htmlonly-tiny/generate)**" and go through the steps to make your own repository based off of this one.<br/>_(Note:  There's a good chance that if you go into the **Actions** tab of your new respository, you'll see a failed run of "Azure Static Web Apps CI/CD" where the "Build and Deploy Job" failed because "`deployment_token provided was invalid.`"  That's okay -- you'll get one soon.)_
1. Go into your new repository's **Settings** tab and then to **Secrets and Variables** -> **Actions** in the left-nav.
1. Add a **Repository secret** named `MY_AZURE_SWA_DEPLOYMENT_TOKEN` and put the phrase "`hello`" in as its value, for now, just so you don't forget you're going to need it.

## Every-6-hours setup

### Spin up a fresh copy of Azure and log your PowerShell command line into it

1. Log into [A Cloud Guru](https://learn.acloud.guru/dashboard) and click on[ the **Playground** icon in the top-nav](https://learn.acloud.guru/cloud-playground).
1. Under **Azure Sandbox**, click the **Start Azure Sandbox** buton.
1. Fire up PowerShell _(you need to have the **`Az`** modules installed and be on version 7)_ and run:
    ```powershell
    Connect-AzAccount -UseDeviceAuthentication
    ```
1. Open a brand new incognito/private web browser tab in a browser you don't already have incognito/private sessions open in and use it to visit [https://microsoft.com/devicelogin](https://microsoft.com/devicelogin).
1. When prompted "Enter the code displayed on your app or device," enter the code where `XXXXXX` would be from waiting PowerShell hint reading "WARNING: To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code XXXXXX to authenticate."  Click **Next**.
1. Copy the **Username** from A Cloud Guru's **Azure Sandbox** info onto your clipboard.
1. Paste that username into the "Email, phone, or Skype" prompt under "Sign in:  You're signing in to Microsoft Azure PowerShell on another device located in United States. If it's not you, close this page" back in your incognito/private web browser tab and click **Next**.
1. Copy the **Password** from A Cloud Guru's **Azure Sandbox** info onto your clipboard.
1. Paste that username into the "Password" prompt ack in your incognito/private web browser tab and click **Sign in**.
1. When asked, in your incognito/private web browser tab, "Are you trying to sign in to Microsoft Azure PowerShell?  Only continue if you downloaded the app from a store or website that you trust," click **Continue**.
1. You can leave this session open for a few minutes from now.  Or if you're a neat freak, feel free to close your incognito/private web browser session when you see the message "Microsoft Azure PowerShell:  You have signed in to the Microsoft Azure PowerShell application on your device. You may now close this window."
1. Back in PowerShell, validate that your PowerShell session is _really_ logged into A Cloud Guru's version of Azure with the following command _(you should see the phrase "Hands-On Labs" as part of the displayed **Name** property when you run it)_:
    ```powershell
    Get-AzContext
    ```

### Create a new, empty Static Web App in your fresh copy of Azure

1. In PowerShell, create a new **Static Web App** resource inside of your temporary Azure environment from A Cloud Guru _(it'll last about 6 hours)_ by running the following 3 commands:
    ```powershell
    $my_resource_group_name = (Get-AzResourceGroup).ResourceGroupName
    $my_swa_name = 'my-first-swa'
    $my_static_web_app = New-AzStaticWebApp -ResourceGroupName $my_resource_group_name -Name $my_swa_name -Location 'Central US' -SkuName 'Standard' -RepositoryUrl $null
    ```
1. When it is done, run the following command in PowerShell to open a web browser to the URL where your "production" Static Web App will soon live.  _(You can close the tab it opens once you see this web page -- you'll revisit it again later.)_  It should say, "Your Azure Static Web App is live and waiting for your content":
    ```powershell
    start ("https://$($my_static_web_app.defaultHostname)/")
    ```

### Tell your GitHub repository how to talk to this brand new Static Web App

1. Copy the point-and-click URL for managing your Static Web App onto your Windows clipboard by running the following PowerShell command:
    ```powershell
    Set-Clipboard -Value "https://portal.azure.com/#@azurelabs.linuxacademy.com/resource/subscriptions/$((Get-AzSubscription).Id)/resourceGroups/$($my_resource_group_name)/providers/Microsoft.Web/staticSites/$($my_swa_name)/staticsite"
    ```
1. Open a brand new incognito/private web browser session if you closed the old one.  If you didn't go back to the old one's tab saying you could close the browser.  Into the URL bar, paste the URL that PowerShell just copied onto your clipboard and visit it.
1. If you closed and reopened, you'll have to re-copy-and-paste the **Username** and **Password** out of A Cloud Guru's **Azure Sandbox** info again, of course, to get logged back into Azure in your web browser.
1. Once you're viewing the management portal for the Azure Static Web App resource you created, click its **Manage deployment token** tab toward the top.
1. In the panel that flies out from the right-hand side of the screen, copy the value from **Deployment token** onto your clipboard.
1. Back in the GitHub repository you made as a copy of this one, go into your new repository's **Settings** tab and then to **Secrets and Variables** -> **Actions** in the left-nav.  Edit the **Repository secret** named `MY_AZURE_SWA_DEPLOYMENT_TOKEN` _(it's a pencil icon with hover-text of "Update secret")_ and paste your Static Web App's deployment token from your clipboard into the **Value** box.  Click **Update secret**.

### Validate that your GitHub repository really can talk to the Static Web App

1. Validate that running the "Azure Static Web Apps CI/CD" GitHub Action included in this codebase can push a website onto your new Static Web App by going into your repository's **Actions** tab, clicking "**Azure Static Web Apps CI/CD**" in the left-nav, dropping down the "**Run workflow**" picklist toward the right, and clicking the "**Run workflow**" button _(leaving the branch set to `main)_.
1. Reload the **Actions** summary page to see the progress of your manual run.  When it says it's done successfully, back in PowerShell, visit your live website one more time by running this command, admiring that now it has a big `<h1>` tag greeting you with the words "**Hello World**":
    ```powershell
    start ("https://$($my_static_web_app.defaultHostname)/")
    ```

---

## Ongoing steps

Play with your new website codebase.  Here are some ideas:

### Watch a direct update to `main` update your live URL

1. Update `/src/web/index.html` in your `main` branch to say "**Later, Friends**" instead of "Hello World."
1. Note that doing so will fire off a GitHub Action _(you can see its progress in your repository's **Actions** tab)_.
1. When that Action is finished running, opening the "`https://something.somenumber.azurestaticapps.net/` website that `start ("https://$($my_static_web_app.defaultHostname)/")` brings up for you now shows a big `<h1>` tag greeting you with the words "**Later, Friends**".

### Look at a preview URL for a pull request

1. Create a new branch off of `main` called `just-testing`.
1. Update `/src/web/index.html` in that `just-testing` branch to say "**Hello, Goodbye**" between the H1 tags.
1. Create a Pull Request from `just-testing` back into `main`.
1. Note that doing so will fire off a GitHub Action and when that Action is finished, you can see that the "`https://something.somenumber.azurestaticapps.net/` website that `start ("https://$($my_static_web_app.defaultHostname)/")` brings up for you still shows the greeting contained in your `main` branch.
1. However, there's now a URL in a comment from the `github-actions` bot saying, "Azure Static Web Apps: Your stage site is ready! Visit it here: `https://something-yourpullrequestnumber.yourazureregion.somenumber.azurestaticapps.net`" inside your pull request's detail page above the validation box noting that "**Azure Static Web Apps CI/CD / Build and Deploy Job (pull_request)**" was successful.
1. Go ahead and visit that URL from the comment.
1. The preview URL should show a big `<h1>` tag greeting you with the words "**Hello, Goodbye**" even while your primary URL stays in sync with what's on the `main` branch.

### Watch a preview URL die

1. Go ahead and merge your `just-testing` branch into main and close the pull request.
1. You should see 2 more **Actions** fire up for your repository.
1. One is against `main` and is running the "**Build and Deploy Job**" part of this repository's GitHub Action _(but skipping "Close Pull Request Job")_.
1. Another is against `just-testing` and is running the "**Close Pull Request Job**" part of this repository's GitHub Action _(but skipping "Build and Deploy Job")_.
1. If you go back and visit the old pull request's URL, that `https://something-yourpullrequestnumber.yourazureregion.somenumber.azurestaticapps.net` preview URL from the comment, when clicked, should have disappeared off the internet and be returning a **404** HTTP error.
1. Meanwhile, opening the "`https://something.somenumber.azurestaticapps.net/` website that `start ("https://$($my_static_web_app.defaultHostname)/")` brings up for you now shows a big `<h1>` tag greeting you with the words "**Hello, Goodbye**" since you merged that changed to `/src/web/index.html` into your `main` branch of your repository.

_(Note:  once all GitHub Actions have finished running, you can delete your `just-testing` branch, but personally, I wouldn't do it until the GitHub Actions have safely finished running.)_

---

## Quick note to self

```sh
swa start './src/web'
```
