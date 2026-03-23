#Ensure the hypervisor is configured to start automatically:确保虚拟机管理程序配置为自动启动：

bcdedit /set hypervisorlaunchtype auto

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
reboot


wsl --update
wsl --shutdown
wsl --uninstall
wsl --install --no-distribution

systeminfo
#Look for a section similar to “Hyper-V Requirements: A hypervisor has been detected.”
#查找类似于 “Hyper-V 要求：已检测到虚拟机管理程序”的部分。


#如果提示未检测到虚拟机管理程序，则问题出在操作系统/虚拟机管理程序的启动级别，而不是 WSL。您还可以检查：
Get-Service vmcompute