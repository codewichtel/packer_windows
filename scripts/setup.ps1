$ErrorActionPreference = "Stop"

# Create a folder for installation logs
$logFolder = 'C:\install_logs'
if (-not (Test-Path -Path $logFolder)) {
    Write-Host "Creating log folder at $logFolder..."
    New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
}

# Mount VirtIO ISO and install drivers silently
$virtioDrive = "E:\"  # Assuming the VirtIO ISO is mounted as drive E:
$virtioInstaller = Join-Path -Path $virtioDrive -ChildPath "virtio-win-gt-x64.msi"
$qemuInstaller = Join-Path -Path $virtioDrive -ChildPath "qemu-ga-x86_64.msi"

# Install VirtIO drivers
if (Test-Path $virtioInstaller) {
    Write-Host "Running VirtIO driver installation from $virtioInstaller..."
    try {
        # Execute the silent installation
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$virtioInstaller`" /qn ADDLOCAL=ALL /norestart" -Wait -NoNewWindow
        Write-Host "VirtIO driver installation completed successfully."
    }
    catch {
        Write-Error "Failed to run VirtIO driver installation: $_"
        exit 1
    }
}
else {
    Write-Error "VirtIO installer not found at $virtioInstaller. Exiting..."
    exit 1
}

# Install QEMU Guest Agent
if (Test-Path $qemuInstaller) {
    Write-Host "Installing QEMU Guest Agent from $qemuInstaller..."
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$qemuInstaller`" /qn" -Wait -NoNewWindow
        Start-Service -Name qemu-ga
        Set-Service -Name qemu-ga -StartupType Automatic
        Write-Host "QEMU Guest Agent installed and configured successfully."
    }
    catch {
        Write-Error "Failed to install QEMU Guest Agent: $_"
        exit 1
    }
}
else {
    Write-Error "QEMU Guest Agent installer not found at $qemuInstaller. Skipping installation."
}

# WinRM Configuration
Write-Host "Configuring WinRM..."
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow remoteip=any
Set-Service winrm -startuptype "auto"
Restart-Service winrm

# Reset auto logon count
Write-Host "Resetting auto logon count..."
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

