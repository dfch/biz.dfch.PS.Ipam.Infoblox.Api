function Enter-Server {
<#
.SYNOPSIS
Performs a login to an Infoblox server.


.DESCRIPTION
Performs a login to an Infoblox server. 

This is the first Cmdlet to be executed and required for all other Cmdlets 
of this module. It creates service references in the module variable.


.OUTPUTS
This Cmdlet returns a reference to a biz.dfch.CS.Infoblox.Wapi.RestHelper 
object, the REST wrapper to the Infoblox REST API. On failure it returns 
$null.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
$ipam = Enter-Infoblox -Credential $Credential;
$ipam

ReturnType  : JsonPretty
ContentType : application/json
UriServer   : https://infoblox/
UriBase     : wapi
Version     : v1.2.1
Credential  : System.Net.NetworkCredential
TimeoutSec  : 90

Perform a login to an Infoblox server with credentials in a PSCredential 
object and against a server defined within module configuration xml file.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Enter-Server/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/biz.dfch.PS.Ipam.Infoblox.Api.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Enter-Server/'
)]
[OutputType([biz.dfch.CS.Infoblox.Wapi.RestHelper])]

Param 
(
	# [Optional] The UriServer such as 'https://infoblox/'. If you do not 
	# specify this value it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 0)]
	[Uri] $UriServer = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriServer
	, 
	# [Optional] The UriBase such as '/wapi/'. If you do not specify this value 
	# it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $UriBase = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriBase
	, 
	# [Optional] The Version such as 'v1.2.1'. If you do not specify this value 
	# it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $Version = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Version
	, 
	# Specifies credentials for authentication of the request
	[ValidateNotNull()]
	[Parameter(Mandatory = $false, ParameterSetName = 'c')]
	[alias("cred")]
	[PSCredential] $Credential = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Credential
	,
	# Specifies the username for authentication of the request
	[Parameter(Mandatory = $true, ParameterSetName = 'u')]
	[alias("u")]
	[alias("user")]
	[string] $Username
	,
	# Specifies the password for authentication of the request
	[Parameter(Mandatory = $true, ParameterSetName = 'u')]
	[alias("p")]
	[alias("pass")]
	[string] $Password
)

BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. UriServer '{0}'; UriBase '{1}'. Username '{2}'" -f $UriServer, $UriBase, $Credential.Username ) -fac 1;
}
# BEGIN 

PROCESS 
{

[boolean] $fReturn = $false;

try 
{
	# Parameter validation
	# N/A

	if('c' -eq $PsCmdlet.ParameterSetName) 
	{
		if( (!$Credential) -Or ($Credential -isnot [PSCredential]) -Or ([string]::IsNullOrWhiteSpace($Credential.Username)) -Or ([string]::IsNullOrEmpty($Credential.Username)) ) 
		{
			$msg = "Credential: Parameter check FAILED.";
			Log-Error $fn $msg;
			$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $Credential;
			throw($gotoError);
		}
		$Username = $Credential.Username;
		$Password = $Credential.GetNetworkCredential().Password;
	}

	$Script:MODULEVAR = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly);
	$Ipam = New-Object biz.dfch.CS.Infoblox.Wapi.RestHelper -ArgumentList @(
			$UriServer, 
			$Script:MODULEVAR.Version, 
			$Script:MODULEVAR.TimeoutSec, 
			$UriBase, 
			$Script:MODULEVAR.ReturnType, 
			$Script:MODULEVAR.ContentType
		);
	$Ipam.SetCredential($Username, $Password);
	# (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).IPAM = $Ipam;
	$Script:MODULEVAR.IPAM = $Ipam;

	# $OutputParameter = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).IPAM;
	$OutputParameter = $Ipam;
	$fReturn = $true;

} 
catch 
{
	if($gotoSuccess -eq $_.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn "Login to Uri '$Uri' with Username '$Username' FAILED [$_].";
			Log-Debug $fn $ErrorText -fac 3;
		} 
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $_.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		} 
		$fReturn = $false;
		$OutputParameter = $null;
	}
}
finally 
{
	# Clean up
	# N/A
}
return $OutputParameter;

}
# PROCESS

END 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}
# END

} # function

Set-Alias -Name Connect- -Value 'Enter-Server';
Set-Alias -Name Enter- -Value 'Enter-Server';
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Enter-Server -Alias Connect-, Enter-; } 

<##
 #
 #
 # Copyright 2013, 2015 Ronald Rink, d-fens GmbH
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 #>

# SIG # Begin signature block
# MIILrgYJKoZIhvcNAQcCoIILnzCCC5sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZiqc7SKWsCosIwAV3NULNsrq
# 202gggkHMIIEKTCCAxGgAwIBAgILBAAAAAABMYnGN+gwDQYJKoZIhvcNAQELBQAw
# TDEgMB4GA1UECxMXR2xvYmFsU2lnbiBSb290IENBIC0gUjMxEzARBgNVBAoTCkds
# b2JhbFNpZ24xEzARBgNVBAMTCkdsb2JhbFNpZ24wHhcNMTEwODAyMTAwMDAwWhcN
# MTkwODAyMTAwMDAwWjBaMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2ln
# biBudi1zYTEwMC4GA1UEAxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNI
# QTI1NiAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo+/Rnynp
# 2NOCdjxioNJJ1hYe8c/w0LpIQwMtpx3yATRJpBDpYhP0E/QWg7XVV0JIhiuVWIfq
# KAR0y3IRD2Em4focYRXHKJtNC4IPJiuQOpbtpNBrKZz1YYjmpFdv7vRw0I0X3uZm
# dl90Hl4MUzhdkPTfMC0bE9F5mFQaSzgE9AfEIwPTksv3gF2qnFYGRC1BTEi0Lew1
# kprGldf1zpAx4nazYbjxdVdCrDvOK8iQSei3Js+7DInL0MOjaqHJ1eOcUytXJv5W
# mnb9YUaiYOwpRkfyzeCCYsYEWuftTkBcSAZ9nV/ndMmehGUNW97c0yQctBQR66u/
# xB+kupnQF1g1zQIDAQABo4H9MIH6MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8E
# CDAGAQH/AgEAMB0GA1UdDgQWBBQZSrha5E0xpRTlXuwvoxz6gIwyazBHBgNVHSAE
# QDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2ln
# bi5jb20vcmVwb3NpdG9yeS8wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5n
# bG9iYWxzaWduLm5ldC9yb290LXIzLmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAf
# BgNVHSMEGDAWgBSP8Et/qC5FJK5NUPpjmove4t0bvDANBgkqhkiG9w0BAQsFAAOC
# AQEAebBpNOIFh/b+1GAsL4Z5NAPgsQeTDIRc+eTcbM9utewKXLoL0GgxLj9kvQ+C
# a2Z3gX/GKaUX2PCJTYMkEfZu/p3hSAoooOJ7JICk7MKaANewbWzNiNUVeM8T+Yil
# c03BNivcy87bfnzSi+8vvbNPTTqtu2JuKJPEDMvZ5srgEQKUA7C9P5QoVpAeU8In
# 1ck8zRpjHoJZFbZAyqeBqsNVrzPRtXXoCepHCEgi+10b8yx6aX7F11peVjM8rVfo
# kyVCw9JecTtKHFTtqVWsKAXHxGxd3DyT9mk8glHOGhU9XgFz/0Ci6rSu04767l1s
# R8dB9dRWV/IYNzLW1MxL9nHgdjCCBNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mG
# Eea62TANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xv
# YmFsU2lnbiBudi1zYTEwMC4GA1UEAxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBD
# QSAtIFNIQTI1NiAtIEcyMB4XDTE1MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVow
# VTELMAkGA1UEBhMCQ0gxDDAKBgNVBAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYD
# VQQKEwtkLWZlbnMgR21iSDEUMBIGA1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/u
# se7p8mpnBZ4cf5b4qV3rqQd62rJHRlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xn
# DgMiVCqVRAeQsWebafWdTvWmONBSlxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZS
# WpQ0NqF9zBadjsJRVatQuPkTDrwLeWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX
# 9o0TQTkOmxXIL3IJ0UxdpyDpLEkttBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGM
# SiLFzTkBA1fOlA6ICMYjB8xIFxVvrN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZ
# MIIBlTAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAy
# BggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9y
# eS8wCQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDeg
# NaAzhjFodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEy
# ZzIuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3Nl
# Y3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQw
# OAYIKwYBBQUHMAGGLGh0dHA6Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVz
# aWduc2hhMmcyMB0GA1UdDgQWBBTNGDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSME
# GDAWgBQZSrha5E0xpRTlXuwvoxz6gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAAps
# OzSX1alF00fTeijB/aIthO3UB0ks1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7
# ClNH3iQpaH5IEaUENT9cNEXdKTBG8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvX
# DvpmfyM2NwHF/nNVj7NzmczrLRqN9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy
# 14Iz+P5Z2cnw+QaYzAuweTZxEUcJbFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfk
# c7DNBnx74PlRzjFmeGC/hxQt0hvoeaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb
# 7ne3I538hWeTdU5q9jGCAhEwggINAgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNp
# Z25pbmcgQ0EgLSBTSEEyNTYgLSBHMgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsO
# AwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqG
# SIb3DQEJBDEWBBSvlXOj8SFA3DeZIoqn5hBTM60zETANBgkqhkiG9w0BAQEFAASC
# AQBu5IRl/HGdNsBA/TQFfrrhzS3jOcKYng0JDJNJlOrkAGHWUVyRsRDLBi5MpjOG
# UaPLaluM4/Wx2IZAD9K2DyZI7Y3CPK4M+cazlETP6hyLostXkxXXuxbz8s95ul4y
# TONQqcsWVK5AgzkY353uy4dnu+XQXmkwqCUKTzsrnMBQ0VU0Fab8xB3x5x28TLgF
# xYw6wmugpUlXb5Wp3GoZ6f1FCFZKX8vCb2sxVidKJkl6ZdSbf04HM+2x5X0fRJGy
# TnFYYccWPdkXKkKuGqx+TGdqfxLJ5rMDwBQ2gDvOr3P14HX1Q2iC6l9VOlh8aWAc
# lwoljawxduhf70jkVIBLFNEW
# SIG # End signature block
