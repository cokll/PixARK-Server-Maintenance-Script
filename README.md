# PixARK Server Maintenance Script

This powershell script will install, backup, update and reboot your pixark server when executed.

To install simply copy the folders to your C: Drive and edit the variables section of StartPixArkServer.ps1 in order to configure your PixARK Server.

You can create a Scheduled Task with the template provided to run it on a schedule

To run it manually right click on the script and select "Run with powershell"

To configure your server type you need to edit the following after the server started once : 

In : "C:\PixArk\ShooterGame\Saved\Config\WindowsServer\GameUserSettings.ini"
Under : [ServerSettings]
Add/Set one of those settings :

For Pioneering :

CanPVPAttack=False
ServerPVPCanAttack=False

For Fury :

ServerPVE=False
CanPVPAttack=True
ServerPVPCanAttack=False

For Chaos:

ServerPVE=False
CanPVPAttack=False
ServerPVPCanAttack=True


# Disclaimer : 

I'm am in no way responsible for anything that this script will do, you are responsible for reading and understanding what this script will do before executing it.

7zip, mcrcon and SteamCMD are not developed or supported by me, they are included in this package to simplify the installation.

7zip : https://www.7-zip.org/

mcrcon : https://github.com/Tiiffi/mcrcon

SteamCMD : https://developer.valvesoftware.com/wiki/SteamCMD


