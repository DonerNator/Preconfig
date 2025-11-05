# Windows Pre-configuration Scripts

This project is a collection of PowerShell scripts designed to automate the configuration of new Windows machines. The process is divided into three stages, with a main script that calls other modules to perform specific tasks.

## How it works

The process is divided into three stages:

*   **Stage 1:** A menu for user input (PC name, AV choice, etc.), creating a local admin user, bypassing the Out-of-Box Experience (OOBE), and scheduling `Stage2.ps1` to run on the next logon.
*   **Stage 2:** Runs after the first reboot. It handles applying various system settings (Time, Language, UAC, etc.), installing Adobe Reader, removing HP Wolf security, setting the hostname and password, and scheduling `Stage3.ps1` to run on the next logon.
*   **Stage 3:** The final stage of the configuration. It handles removing bloatware and HP software, installing the selected Antivirus (ESET or SentinelOne), installing Microsoft Office, applying RDP settings, installing Windows Updates, and cleaning up all temporary files.

## Scripts

### Main Scripts

*   **`Setup - RUN AS ADMIN.cmd`**: The entry point of the entire process. It launches `Stage1.ps1` with elevated privileges.
*   **`Stage1.ps1`**: The first stage of the configuration.
*   **`Stage2.ps1`**: The second stage, which runs after the first reboot.
*   **`Stage3.ps1`**: The final stage of the configuration.

### PowerShell Modules

The `Powershell modules` directory contains a collection of scripts that are called by the main stage scripts to perform specific tasks. Here is a summary of each module:

*   **`Check-For-ESET-Agent-And-Reinstall.ps1`**: Checks if the ESET agent is installed and reinstalls it if necessary.
*   **`Cleanup-Task-Deployment-Temp.ps1`**: Cleans up temporary files and scheduled tasks.
*   **`CtrlAltDelFix-V2.ps1`**: A script to fix an issue with Ctrl+Alt+Delete not working, likely after the OOBE.
*   **`ESETCloudAgentScriptPS.ps1`**: Downloads and installs the ESET Management Agent.
*   **`ESETInstallEndpointSecurity.ps1`**: Downloads and installs ESET Endpoint Security.
*   **`Exit-Start-Menu.ps1`**: Sends an "Escape" keystroke, likely to close the start menu.
*   **`InstallOffice.ps1`**: Installs Microsoft Office using a configuration XML file.
*   **`RDP-Setting.ps1`**: Configures RDP settings, specifically disabling password saving.
*   **`Remove-DefaultUser0.ps1`**: Removes the `DefaultUser0` account.
*   **`RemoveUnknowProfiles.ps1`**: Removes unknown user profiles from the system.
*   **`SentinelOne-Default-site-installer.ps1`**: Downloads and installs SentinelOne.
*   **`Set-Correct-Time.ps1`**: Sets the system time zone to "W. Europe Standard Time".
*   **`Set-DutchSettings.ps1`**: Configures the system language, keyboard layout, and other settings to Dutch.
*   **`Set-Hostname-And-Password-Service.percom.ps1`**: Sets the computer hostname and the password for the `Service.percom` user.
*   **`Set-PowerCFG.ps1`**: Configures power settings based on whether the device is a laptop or a desktop.
*   **`Set-RegistryKeys.ps1`**: Applies various registry changes, such as disabling FastBoot and privacy questions.
*   **`Set-Service.percom-To-Hidden.ps1`**: Hides the `Service.percom` user from the login screen.
*   **`Set-UAC.ps1`**: Sets the User Account Control (UAC) level.
*   **`Uninstall_HPWolf.ps1`**: Uninstalls HP Wolf Security.
*   **`Uninstall-HP-Full-Cleanup-Script.ps1`**: A comprehensive script to uninstall a wide range of HP bloatware.
*   **`UninstallBloatware.ps1`**: Uninstalls various bloatware, including Microsoft Office, Xbox apps, and other pre-installed software.
*   **`Windows-Updates.ps1`**: Installs Windows updates, excluding cumulative updates.
*   **`Winget-Adobe-Install.ps1`**: Installs Adobe Acrobat Reader using Chocolatey, with a fallback to Winget.
*   **`Winget-Install-7Zip.ps1`**: Installs 7-Zip using Winget.

## Usage

1.  Run `Setup - RUN AS ADMIN.cmd` as an administrator.
2.  Follow the prompts in the console.
3.  The script will reboot the machine multiple times.

## Disclaimer

This script is provided as-is and without any warranty. Use it at your own risk. The author is not responsible for any damage to your system.
It is highly recommended to test the script in a virtual machine before using it on a production machine.
