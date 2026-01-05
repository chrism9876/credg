if(!('CredentialGuard' -match ((Get-ComputerInfo).DeviceGuardSecurityServicesConfigured))){
write-output "Credential Guard already disabled"
start-sleep 5
exit 0
}


$regkey="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$name="LsaCfgFlags"
if((Get-ItemProperty $regkey).PSObject.Properties.Name -contains $name){
Set-ItemProperty -Path $regkey -name $name -Value 0
}else{
new-ItemProperty -Path $regkey -name $name -Value 0 -Type Dword -ErrorAction SilentlyContinue
}

$regkey="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
$name="LsaCfgFlags"
if((Get-ItemProperty $regkey).PSObject.Properties.Name -contains $name){
Set-ItemProperty -Path $regkey -name $name -Value 0
}else{
new-ItemProperty -Path $regkey -name $name -Value 0 -Type Dword -ErrorAction SilentlyContinue
}


mountvol X: /s
start-process cmd -NoNewWindow -argumentlist "/c copy %WINDIR%\System32\SecConfig.efi X:\EFI\Microsoft\Boot\SecConfig.efi /Y"
start-process bcdedit -NoNewWindow -argumentlist "/create {0cb3b571-2f2e-4343-a879-d86a476d7215} /d `"DebugTool`" /application osloader"
start-process bcdedit -NoNewWindow -argumentlist "/set {0cb3b571-2f2e-4343-a879-d86a476d7215} path `"\EFI\Microsoft\Boot\SecConfig.efi`""
start-process bcdedit -NoNewWindow -argumentlist "/set {bootmgr} bootsequence {0cb3b571-2f2e-4343-a879-d86a476d7215}"
start-process bcdedit -NoNewWindow -argumentlist "/set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO"
start-process bcdedit -NoNewWindow -argumentlist "/set {0cb3b571-2f2e-4343-a879-d86a476d7215} device partition=X:"
mountvol X: /d

shutdown /r /t 10
