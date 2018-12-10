Param(
	[Parameter(
		Mandatory=$true,
		Position = 1
	)]
	[String] $ConfigRawGistURL
)
. { Invoke-WebRequest -useb http://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression
get-boxstarter -Force
Install-BoxstarterPackage -PackageName $ConfigRawGistURL -DisableReboots