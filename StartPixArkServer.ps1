# April 2018
# Created by ShadowOffice and Patrix of https://bucherons.ca

# Run this script to Stop->Backup->Update->Start your server.

#---------------------------------------------------------
# Variables
#---------------------------------------------------------

# Variables you should change.
$serverName="[TAG] SERVER NAME" 										#Name of the server
$serverMaxPlayers=20													#Max number of Players
$rconPassword="RCONPASSWORD"											#Rcon Password
$serverPort=7777														#Server Port
$serverSeed=1234														#Server Seed
$worldName="World"														#World Name
$ShowFloatingDamageText="true"											#Display Floating Damage Text

#Variables you might need to change.
$queryPort=27015														#Query Port
$cubePort=27018															#Cube Port
$rconPort=27020															#Rcon Port

#Variables you should probably not change.
$ProcessName="PixArkServer"												#Process name in the task manager
$serverPath="C:\PixArk"													#Server folder
$serverExec="C:\PixArk\ShooterGame\Binaries\Win64\PixARKServer.exe"		#Path to server executable
$steamCMDExec="C:\SteamCMD\steamcmd.exe"								#SteamCMD
$7zExec="C:\7z\7za.exe"													#7zip
$mcrconExec="C:\mcrcon\mcrcon.exe"										#mcrcon
$steamAppID="824360"													#SteamAppID
$serverSaves="C:\PixArk\ShooterGame\Saved"								#Folder to include in backup
$backupPath="C:\PixArkBackups"											#Backup Folder
$backupDays="7"															#Number of days of backups to keep.
$backupWeeks="4"														#Number of weeks of weekly backups to keep.
$rconIP="127.0.0.1"														#Rcon IP, usually localhost


<#

In : "C:\PixArk\ShooterGame\Saved\Config\WindowsServer\GameUserSettings.ini"
Under : [ServerSettings]
Add/Set one of those settings :

Pioneering :

CanPVPAttack=False
ServerPVPCanAttack=False

Fury :

ServerPVE=False
CanPVPAttack=True
ServerPVPCanAttack=False

Chaos:

ServerPVE=False
CanPVPAttack=False
ServerPVPCanAttack=True

#>


#Do not modify below this line
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#


$ServerStartArguments="CubeWorld_Light?listen?MaxPlayers="+$serverMaxPlayers+"?Port="+$serverPort+"?QueryPort="+$queryPort+"?RCONEnabled=True?ShowFloatingDamageText="+$ShowFloatingDamageText+"?RCONPort="+$rconPort+"?SessionName="+$serverName+"?ServerAdminPassword="+$rconPassword+"?CULTUREFORCOOKING=en"

#---------------------------------------------------------
#Config Check
#---------------------------------------------------------
Write-Host Checking config

if (!(Test-Path $serverPath)){
	Write-Host "Server path : $serverPath is invalid"
	pause
	exit
}
if (!(Test-Path $steamCMDExec)){
	Write-Host "SteamCMD.exe not found at : $steamCMDExec"
	pause
	exit
}
if (!(Test-Path $7zExec)){
	Write-Host "7za.exe not found at : $7zExec"
	pause
	exit
}
if (!(Test-Path $mcrconExec)){
	Write-Host "mcrcon.exe not found at : $mcrconExec"
	pause
	exit
}

#---------------------------------------------------------
#Install if not installed
#---------------------------------------------------------
if (!(Test-Path $serverExec)){
	Write-Host "Server is not installed : Installing $serverName ..."
	& $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath +app_update $steamAppID +validate +quit
}else{

#---------------------------------------------------------
#If Server is running warn players then stop server
#---------------------------------------------------------

	Write-Host "Checking if server is running"
	$server=Get-Process $ProcessName -ErrorAction SilentlyContinue
	if ($server) {
		Write-Host "Server is running... Warning users about restart..."
		& $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "broadcast THE SERVER WILL REBOOT IN 5 MINUTES !"
		Start-Sleep -s 240
		& $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "broadcast THE SERVER WILL REBOOT IN 1 MINUTE !"
		Start-Sleep -s 60
		& $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "broadcast THE SERVER IS REBOOTING !"
		#Force Save
		Write-Host "Saving world..."
		& $mcrconExec -c -H $rconIP -P $rconPort -p $rconPassword "saveworld"
		Start-Sleep -s 10
		#Stop the server
		Write-Host "Stopping Server..."
		$server.CloseMainWindow()
		Start-Sleep -s 10
		if ($server.HasExited) {
			Write-Host "Server succesfully shutdown"
		}else{
			Write-Host "Trying again to stop the Server..."
			#Try Again
			$server | Stop-Process
			Start-Sleep -s 10
			if ($server.HasExited) {
				Write-Host "Server succesfully shutdown on second try"
			}else{
				Write-Host "Forcing server shutdown..."
				#Force Stop
				$server | Stop-Process -Force
			}
		}
	}else{
		Write-Host "Server is not running"
	}

#---------------------------------------------------------
#Backup
#---------------------------------------------------------

	Write-Host "Creating Backup"
	#Create backup name from date and time
	$backupName=Get-Date -UFormat %Y-%m-%d_%H-%M-%S
	#Check if it's friday (Sunday is 0)
	if ((Get-Date -UFormat %u) -eq 5){
		#Weekly backup
		#Check / Create Path
		New-Item -ItemType directory -Path $backupPath\Weekly -ErrorAction SilentlyContinue
		& $7zExec a -tzip -mx=1 $backupPath\Weekly\$backupName.zip $serverSaves
	}else {
		#Daily backup
		#Check / Create Path
		New-Item -ItemType directory -Path $backupPath\Daily -ErrorAction SilentlyContinue
		& $7zExec a -tzip -mx=1 $backupPath\Daily\$backupName.zip $serverSaves
	}
	Write-Host "Backup Created : $backupName.zip"

	#Delete old Daily backup
	Write-Host "Deleting daily backup older than $backupDays"
	$limit = (Get-Date).AddDays(-$backupDays)
	Get-ChildItem -Path $backupPath\Daily -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force
	
	#Delete old Weekly backup
	Write-Host "Deleting weekly backup older than $backupWeeks"
	$limit = (Get-Date).AddDays(-($backupWeeks)*7)
	Get-ChildItem -Path $backupPath\Weekly -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force


#---------------------------------------------------------
#Update
#---------------------------------------------------------

	Write-Host "Updating Server..."

	& $steamcmdExec +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir $serverPath +app_update $steamAppID +quit

}

#---------------------------------------------------------
#Start Server
#---------------------------------------------------------

Write-Host "Starting Server..."

& $serverExec $ServerStartArguments "-NoHangDetection -CubePort=$cubePort -cubeworld=$worldName -Seed=$serverSeed -nosteamclient -game -server -log"

Start-Sleep -s 5