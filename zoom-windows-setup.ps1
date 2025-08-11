# Requires Admin
# Run in elevated PowerShell

# --- STEP 1: Configuration ---
$Username = "ZoomLocal"
$ShortcutPath = "$env:PUBLIC\Desktop\Zoom (Isolated).lnk"
$TaskName = "ZoomAsZoomLocal"

# --- STEP 2: Detect Zoom executable ---
$ZoomPaths = @(
    "$env:ProgramFiles\Zoom\bin\Zoom.exe",
    "$env:APPDATA\Zoom\bin\Zoom.exe"
)

$ZoomExecutable = $null
foreach ($path in $ZoomPaths) {
    if (Test-Path $path) {
        $ZoomExecutable = $path
        break
    }
}

if (-not $ZoomExecutable) {
    Write-Error "[!] Zoom executable not found in standard locations. Is Zoom installed?"
    exit 1
}

Write-Output "[*] Zoom found at: $ZoomExecutable"

# --- STEP 3: Generate random password ---
Add-Type -AssemblyName System.Web
$Password = [System.Web.Security.Membership]::GeneratePassword(20, 4)
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# --- STEP 4: Create ZoomLocal user if it doesn't exist ---
try {
    $user = Get-LocalUser -Name $Username -ErrorAction Stop
    Write-Output "[*] User $Username already exists."
} catch {
    Write-Output "[*] Creating user $Username..."
    New-LocalUser -Name $Username -Password $SecurePassword -FullName "Zoom Local User" -Description "Used for Zoom isolation"
    Add-LocalGroupMember -Group "Users" -Member $Username
    Write-Output "[+] User $Username created successfully."
}

# --- STEP 5: Start Secondary Logon service ---
$Service = Get-Service -Name "seclogon"
if ($Service.Status -ne "Running") {
    Write-Output "[*] Starting Secondary Logon service..."
    Start-Service -Name "seclogon"
    Set-Service -Name "seclogon" -StartupType Automatic
    Write-Output "[+] Secondary Logon service is now running."
} else {
    Write-Output "[*] Secondary Logon service is already running."
}

# --- STEP 6: Delete Zoom registry keys under HKEY_CLASSES_ROOT ---
$KeysToDelete = @(
    "HKCR:\ZoomPhoneCall",
    "HKCR:\ZoomPhoneSMS"
)

foreach ($key in $KeysToDelete) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force
        Write-Output "[+] Removed registry key: $key"
    } else {
        Write-Output "[*] Registry key not found: $key"
    }
}

# --- STEP 7: Create scheduled task to run Zoom as ZoomLocal ---
Write-Output "[*] Creating scheduled task '$TaskName'..."

$Action = New-ScheduledTaskAction -Execute $ZoomExecutable
$Principal = New-ScheduledTaskPrincipal -UserId $Username -LogonType Password -RunLevel Highest
$Trigger = New-ScheduledTaskTrigger -AtStartup  # Placeholder trigger

Register-ScheduledTask -TaskName $TaskName -Action $Action -Principal $Principal -Trigger $Trigger -Password $Password -Force

Write-Output "[+] Task '$TaskName' created."

# --- STEP 8: Create desktop shortcut to launch Zoom via scheduled task ---
Write-Output "[*] Creating shortcut to launch Zoom as $Username..."

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "schtasks"
$Shortcut.Arguments = "/run /tn $TaskName"
$Shortcut.WindowStyle = 1
$Shortcut.IconLocation = "$ZoomExecutable, 0"
$Shortcut.Description = "Launch Zoom isolated as $Username"
$Shortcut.Save()

Write-Output "[+] Shortcut created at $ShortcutPath"

# --- STEP 9: Ask user whether to hide ZoomLocal from login screen ---
$response = Read-Host "`n[?] Do you want to hide the ZoomLocal user from the Windows login screen? (Y/N)"

if ($response -match '^[Yy]$') {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    New-ItemProperty -Path $regPath -Name $Username -PropertyType DWord -Value 0 -Force
    Write-Output "[+] ZoomLocal is now hidden from the login screen."
} else {
    Write-Output "[*] ZoomLocal will remain visible on the login screen."
}

Write-Output "`n[✔] Zoom Windows workaround complete."
