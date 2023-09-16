#   How-To Use:
#   Install Command -  powershell.exe -ExecutionPolicy Bypass -File Zoom-Install-Latest.ps1
#   Zoom Reference Link - https://support.zoom.us/hc/en-us/articles/201362163-Mass-deploying-with-preconfigured-settings-for-Windows
#   Zoom Installers - https://support.zoom.us/hc/en-us/articles/207373866-Zoom-Installers
#   

#  /i ZoomInstallerFull.msi /quiet /qn /norestart /log install.log ZoomAutoUpdate=1 zNoDesktopShortCut=True
$InstallArguments = "/qn /norestart ZoomAutoUpdate=1 zNoDesktopShortCut=True"
# Script execution pull path with file and current folder!
$mypath = $MyInvocation.MyCommand.Path
$Justpath = Split-Path $mypath -Parent
# Newest 64bit MSI Installer - https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64
$FullLink = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
$fileName = "ZoomInstallerFull.msi"

# Downloading the file
Invoke-WebRequest -Uri $FullLink -OutFile $JustPath\$fileName -ErrorAction Stop

# Get download file version details
$filePath   = "$Justpath\$fileName"
$parentPath = (Resolve-Path -Path (Split-Path -Path $filePath)).Path
$fileName   = Split-Path -Path $filePath -Leaf
$shell = New-Object -COMObject Shell.Application
$shellFolder = $Shell.NameSpace($parentPath)
$shellFile   = $ShellFolder.ParseName($fileName)
$dlVersion = $shellFolder.GetDetailsOf($shellFile,24)

# Start Logging install
$LogName = "Zoom_x64_" + $dlVersion +"_Install"
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$LogName.log" -Append -Force
# Start the Install
Write-Host "Installing - $fileName"
$Install = Start-Process -FilePath "$JustPath\$fileName" -ArgumentList $InstallArguments -Wait -PassThru
Write-Host "Install Exit Code  - "$Install.ExitCode

# Send right error code
If ( $Install.ExitCode -eq 0 ) {
    Write-Host "Install SUCCESFUL!"
    Stop-Transcript
    Exit 0
}
else {
    Write-Host "Install FAILED!!!"
    Stop-Transcript
    Exit 1
}