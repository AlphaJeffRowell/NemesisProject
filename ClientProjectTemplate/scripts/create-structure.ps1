# Nemesis Project — Client Project Template Deployment
# Creates folder structure and template files for new client projects

param(
    [string]$ClientName,
    [string]$PhaseNumber,
    [string]$FolderPattern,
    [string]$AsanaGID,
    [string]$AsanaPAT
)

# Get template directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$templateDir = Split-Path -Parent $scriptDir
$projectRoot = "c:\Repo\Projects\Project-$ClientName"
$phaseFolder = Join-Path $projectRoot "Phase $PhaseNumber"

# Create phase folder
if (-not (Test-Path $phaseFolder)) {
    New-Item -ItemType Directory -Path $phaseFolder -Force | Out-Null
}

# Folder structure to create
$folders = @(
    "00 - Project Overview",
    "01 - Requirements",
    "02 - Technical Specs",
    "03 - Architecture",
    "04 - Implementation",
    "05 - Testing",
    "06 - Deployment",
    "07 - Documentation",
    "08 - Meeting Notes",
    "scripts"
)

# Create all folders
foreach ($folder in $folders) {
    $folderPath = Join-Path $phaseFolder $folder
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    }
}

# Copy template README files
$templates = @{
    "00 - Project Overview" = "00_project_overview_README.md"
    "01 - Requirements" = "01_requirements_README.md"
    "02 - Technical Specs" = "02_technical_specs_README.md"
    "03 - Architecture" = "03_architecture_README.md"
    "04 - Implementation" = "04_implementation_README.md"
    "05 - Testing" = "05_testing_README.md"
    "06 - Deployment" = "06_deployment_README.md"
    "07 - Documentation" = "07_documentation_README.md"
    "08 - Meeting Notes" = "08_meeting_notes_README.md"
    "scripts" = "scripts_README.md"
}

foreach ($folder in $folders) {
    $templateFile = $templates[$folder]
    $sourcePath = Join-Path (Join-Path $templateDir "templates") $templateFile
    $destPath = Join-Path (Join-Path $phaseFolder $folder) "README.md"

    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
    }
}

# Create .asana-config.json at project root
$asanaConfig = @{
    asanaGID = $AsanaGID
    asanaPAT = $AsanaPAT
} | ConvertTo-Json

$configFile = Join-Path $projectRoot ".asana-config.json"
Set-Content -Path $configFile -Value $asanaConfig -Encoding UTF8

Write-Host "[OK] Project structure created at: $phaseFolder"
