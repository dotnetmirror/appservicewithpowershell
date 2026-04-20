# 1. Define Variables
$RESOURCE_GROUP = "DNMAzureAppPowerShellDemo"
$LOCATION = "Canada Central"
$PLAN_NAME = "DNMWebPlanWithPS"
$WEBAPP_NAME = "dnm-webapp-$(Get-Date -Format 'MMddyyyyHHmmss')" # Timestamp for uniqueness
$RUNTIME = "DOTNETCORE|8.0" # Standard Runtime for 2024/2025
$SKU = "Free"

# 2. Login (Uncomment if running interactively)
# Write-Host "Authenticating with Azure..." -ForegroundColor Cyan
# Connect-AzAccount

# 3. Create the Resource Group
Write-Host "Creating resource group: $RESOURCE_GROUP..." -ForegroundColor Yellow
New-AzResourceGroup -Name $RESOURCE_GROUP -Location $LOCATION -Force

# 4. Create the App Service Plan
Write-Host "Creating App Service Plan: $PLAN_NAME..." -ForegroundColor Yellow
New-AzAppServicePlan -Name $PLAN_NAME `
    -Location $LOCATION `
    -ResourceGroupName $RESOURCE_GROUP `
    -Tier $SKU

# 5. Create the Web App
Write-Host "Creating Web App: $WEBAPP_NAME..." -ForegroundColor Yellow
New-AzWebApp -Name $WEBAPP_NAME `
    -AppServicePlan $PLAN_NAME `
    -ResourceGroupName $RESOURCE_GROUP

# 6. Prepare and Deploy Code
# Note: Assumes you are in the project root directory
Write-Host "Publishing .NET project locally..." -ForegroundColor Cyan
dotnet publish -c Release -o ./publish

Write-Host "Creating deployment package (ZIP)..." -ForegroundColor Cyan
if (Test-Path "deploy.zip") { Remove-Item "deploy.zip" }
Compress-Archive -Path ./publish/* -DestinationPath deploy.zip

Write-Host "Deploying code to $WEBAPP_NAME..." -ForegroundColor Green
Publish-AzWebApp -ResourceGroupName $RESOURCE_GROUP `
    -Name $WEBAPP_NAME `
    -ArchivePath "./deploy.zip" `
    -Force

Write-Host "`nDeployment complete! Live at: https://$WEBAPP_NAME.azurewebsites.net" -ForegroundColor Green
