# Define paths
$SOURCE_DIR = "$env:APPDATA\SAP\SAP GUI\ABAP Editor\abap_spec.xml"
$THEMES_URL = "https://letu-sap.vercel.app/themes"
$THEMES_JSON = "$THEMES_URL/themes.json"

# Fetch themes list
try {
    $themesList = Invoke-RestMethod -Uri $THEMES_JSON
    $FILES = $themesList.themes
} catch {
    Write-Host "Error: Could not retrieve themes list."
    exit 0
}

# Number of theme files
$FILES_LENGTH = $FILES.Count

# Offset for default option
$FILES_OFFSET = 1

# Format file name to display name
function Format-Name {
    param ($filePath)
    return ($filePath -replace "_theme.xml", "" -replace "_", " ")
}

# Handle theme change
function Change-Theme {
    param ($selectedFile)
    try {
        # Get user selected theme file
        $themeUrl = "$THEMES_URL/$selectedFile"

        # Change theme
        Invoke-WebRequest -Uri $themeUrl -OutFile $SOURCE_DIR

        Write-Host "Changed theme to $(Format-Name $selectedFile) successfully!"
        Write-Host "Please restart SAP GUI for changes to take effect."
    } catch {
        Write-Host "Error: Change theme failed!"
    }
}

# Check if there are theme files
if ($FILES_LENGTH -eq 0) {
    Write-Host "No theme XML file found."
    exit 0
}

# Main menu
while ($true) {
    Write-Host "======================="
    Write-Host "[0] Exit program"
    Write-Host "-----------------------"
    Write-Host "Available themes:"
    for ($i = 0; $i -lt $FILES_LENGTH; $i++) {
        Write-Host "[$($i + $FILES_OFFSET)] $(Format-Name $FILES[$i]) theme"
    }
    Write-Host "======================="

    $choice = Read-Host "Enter your option"

    # Validate user input
    if ($choice -match "^[0-9]+$" -and
        $choice -ge 0 -and
        $choice -le ($FILES_LENGTH + $FILES_OFFSET)) {
        break
    } else {
        Clear-Host
        Write-Host "Not a valid input. Please try again."
    }
}

# Handle user choice
switch ($choice) {
    0 { exit 0 }
    default {
        $selectedFile = $FILES[$choice - $FILES_OFFSET]
        Change-Theme $selectedFile
    }
}

# Wait for user input before exit
Read-Host "Press any key to exit"
