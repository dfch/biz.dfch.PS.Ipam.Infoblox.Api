function Invoke-RestCommand {
<#
.SYNOPSIS
Invokes an arbitrary Infoblox REST API.


.DESCRIPTION
This Cmdlet lets you execute arbitrary API calls towards an Infoblox API rest 
endpoint. For a list of possible API calls consult the Infoblox WAPI 
documentation.


.INPUTS
See PARAMETER section for a description of input parameters.


.OUTPUTS
default | json | json-pretty | xml | xml-pretty


.EXAMPLE
Invoke-RestCommand network -Username Edgar.Schnittenfittich -Password 'P@ssw0rd'

Get a list of all networks defined in Infoblox. UriServer and UriBase are taken from the configuration file.


.EXAMPLE
Invoke-RestCommand network -Credential $Credential

Get a list of all networks defined in Infoblox. UriServer and UriBase are taken from the configuration file.


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Invoke-RestCommand/


.NOTES

See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Medium"
	,
	DefaultParameterSetName = 'c'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Invoke-RestCommand/'
)]
[OutputType([String])]
Param 
(
	# Specifies the HTTP method to invoke
	[ValidateSet("GET", "POST", "PUT", "DELETE", "HEAD", "MERGE", 'TRACE', 'OPTIONS', 'PATCH')]
	[Parameter(Mandatory = $false)]
	[alias("m")]
	[string] $Method = 'GET'
	,
	# Specifies the URL to invoke. This can be a relative or absolute URL
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[alias("Url")]
	[Uri] $Uri
	,
	# Specifies a dictionary of header to attach to the request
	[Parameter(Mandatory = $false)]
	[alias("h")]
	[ValidateNotNullOrEmpty()]
	[hashtable] $Headers = @{}
	,
	# [Optional] Specifies the body to attach to the request
	[Parameter(Mandatory = $false)]
	[alias("b")]
	[string] $Body = ''
	,
	# Specifies a dictionary of query pramaters to attach to the request
	[Parameter(Mandatory = $false)]
	[alias("q")]
	[ValidateNotNullOrEmpty()]
	[hashtable] $QueryParameters = @{}
	,
	# Specifies the server name to invoke.
	[Parameter(Mandatory = $false)]
	[ValidateNotNull()]
	[string] $UriServer = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriServer
	,
	# Specifes the base url to invoke
	[Parameter(Mandatory = $false)]
	[ValidateNotNull()]
	[string] $UriBase = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriBase
	,
	# Specifes the Infoblox WAPI version (e.g. v1.2.1) to use
	[Parameter(Mandatory = $false)]
	[ValidateNotNull()]
	[string] $Version = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Version
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet("xml", "xml-pretty", "json", "json-pretty")]
	[Parameter(Mandatory = $false)]
	[alias("a")]
	[alias("accept")]
	[string] $ReturnType = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ReturnType
	,
	# Specifies the Content-Type header of the request
	[ValidateSet('application/xml', 'application/json', 'text/xml', 'application/x-www-urlencoded')]
	[Parameter(Mandatory = $false)]
	[alias("c")]
	[alias("content")]
	[string] $ContentType = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ContentType
	,
	# Specifies a maximum wait time in seconds of the request
	[Parameter(Mandatory = $false)]
	[alias("t")]
	[int] $TimeoutSec = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TimeoutSec
	,
	# Specifies credentials for authentication of the request
	[Parameter(Mandatory = $false, ParameterSetName = 'c')]
	[alias("cred")]
	[PSCredential] $Credential = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Credential
	,
	# Specifies the username for authentication of the request
	[Parameter(Mandatory = $false, ParameterSetName = 'u')]
	[alias("u")]
	[alias("user")]
	[string] $Username
	,
	# Specifies the password for authentication of the request
	[Parameter(Mandatory = $false, ParameterSetName = 'u')]
	[alias("p")]
	[alias("pass")]
	[string] $Password
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNull()]
	[biz.dfch.CS.Infoblox.Wapi.RestHelper] $IPAM = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).IPAM
)

BEGIN 
{

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Method '{0}'. Uri '{1}'. ParameterSetName: '{2}'." -f $Method, $Uri, $PsCmdlet.ParameterSetName) -fac 1;

}
# BEGIN

PROCESS 
{

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try 
{

	# Parameter validation
	if('u' -eq $PsCmdlet.ParameterSetName) 
	{
		$PasswordSecure = ConvertTo-SecureString $Password -AsPlainText -Force;
		$Credential = New-Object System.Management.Automation.PSCredential ($Username, $PasswordSecure);
		$IPAM.SetCredential($Credential.UserName, $Credential.GetNetworkCredential().Password);
	}
	if('c' -eq $PsCmdlet.ParameterSetName) 
	{
		if($Credential)
		{
			$IPAM.SetCredential($Credential.UserName, $cred.GetNetworkCredential().Password);
		}
		if( 
			(!$IPAM.Credential) -Or 
			$IPAM.Credential -isnot [System.Net.NetworkCredential] -Or 
			([string]::IsNullOrWhiteSpace($IPAM.Credential.UserName))
			) 
		{
			$msg = "Credential: Parameter validation FAILED. You either have supplied invalid Credential or not supplied credentials upon module initialisation.";
			Log-Error $fn $msg;
			$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $Credential;
			throw($gotoError);
		}
	}
	
	if($PSBoundParameters.ContainsKey('ReturnType'))
	{
		$IPAM.ReturnTypeString = $ReturnType;
	}
	if($PSBoundParameters.ContainsKey('Version'))
	{
		$IPAM.Version = $Version;
	}
	if($PSBoundParameters.ContainsKey('ContentType'))
	{
		$IPAM.ContentType = $ContentType;
	}
	if($PSBoundParameters.ContainsKey('TimeoutSec'))
	{
		$IPAM.TimeoutSec = $TimeoutSec;
	}
	if($PSBoundParameters.ContainsKey('Version'))
	{
		$IPAM.Version = $Version;
	}
	
	if($Headers.Contains('Authorization')) 
	{
		Log-Warning $fn "Headers already contains 'Authorization' header. Skipping creation of custom 'Authorization' header ...";
	} 

	Log-Debug $fn ("Invoking '{0}' '{1}' as user '{2}' ..." -f $Method, $Uri, $IPAM.Credential.UserName);
	if( ('GET' -eq $Method) -Or ('HEAD' -eq $Method) ) 
	{
		$r = $IPAM.Invoke($Method, $Uri, $QueryParameters, $Headers, $null);
	} 
	else 
	{
		$r = $IPAM.Invoke($Method, $UriRestCommand, $QueryParameters, $Headers, $Body);
	}
	Log-Info $fn ("Invoking '{0}' '{1}' as user '{2}' COMPLETED." -f $Method, $UriRestCommand.AbsoluteUri, $Username);
	$fReturn = $true;
	$OutputParameter = $r;
	
}
catch [System.Management.Automation.MethodInvocationException]
{
	$ErrorText = $_.InvocationInfo.PositionMessage;
	$ErrorText += "`n";
	$ErrorText += $_.ScriptStackTrace;
	$ErrorText += "`n";
	$ErrorText += ($_.Exception | Out-String);
	if(
		$_.Exception.InnerException -And 
		$_.Exception.InnerException -is [System.AggregateException] -And
		$_.Exception.InnerException.InnerException -And
		$_.Exception.InnerException.InnerException -is [System.Threading.Tasks.TaskCanceledException]
		)
	{
		$msg = 'The operation timed out.';
		$e = New-CustomErrorRecord -m $msg -cat OperationTimeout -o $_;
		Log-Critical $fn ("{0}`n`n{1}" -f $msg, $ErrorText);
		$PSCmdlet.ThrowTerminatingError($e);
	}
	elseif(
		$_.Exception.InnerException -And
		$_.Exception.InnerException -is [System.ArgumentException]
		)
	{
		$msg = $_.Exception.InnerException.Message;
		$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $_;
		Log-Critical $fn ("{0}`n{1}" -f $msg, $ErrorText);
		$PSCmdlet.ThrowTerminatingError($e);
	}
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
			Log-Critical $fn ("[WebException] Request '{0}' FAILED with Status '{1}'. [{2}]. [{3}]" -f $UriRestCommand.AbsoluteUri, $_.Exception.Response.StatusCode, $_, ($_.Exception.Response|Out-String));
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
} # finally

# Return values are always and only returned via OutputParameter.
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Invoke-RestCommand; } 

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
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxKwIsg+YXdaP7UMZZZV22ZaD
# X5WgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSad+S08Jee+rER
# 97/akJjjh60KKTANBgkqhkiG9w0BAQEFAASCAQCIDSbm0m4JDasA6EIkoAQJGWNW
# W4Z5nA/qsNmDwH/9xL5/Xi7Mx+bTkmJ5JxTd/6bTCKIKhX0iRjLZrfHQanJzaaxJ
# vmUSxPQyZLPDoNSgO4hfOVwRKxYLJNdOrzTEg+RP1WC8BkTe0+7LZoEP9NPI5CuN
# YVh0P3j/6K5VsZu3+yL46RhQuzb/lDMuBvIopXKtXQHwFM6LuC5sg2B5SImf3898
# b+hXMcvDzueZmO3pTQbnaFWdI1R6iY5aihc2X+zydO/Nf1wqs3NF7VyDKhIVDWXf
# EExChInptXcBjb8o/hWvmFxyB0wvhD95q/QfMnu2q8lE8KR8QGLg88120kqEoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MDcxMTA5MDUwNVowIwYJKoZIhvcNAQkEMRYEFPcTq3H9+eNLKx3HW2CgLZlkQKlg
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQBpSqMGZWrSM0wjqPmX
# q0+zZ0pb6v8AiNXFpXriA2CCii4wMHfRIa15aWCzG96KKu4fJN4OZxHc0if37zU6
# 6sZ0m8MEFeO3leQe3X/Td2pNYcSZfQpEH8HZtuQ15HmRUsMjtpvyiR588v359sT2
# Zcz+ohEdK02rrbvlt2Ps6uWNDtfDaznwftESi/veuMluSI5KnXSio0tRNeNyw0xg
# QN5Jh8FNRFigXGHeOsk9VsWHmupJV7cCs2JGWA6t07u5jEVS4FCpARXCeQv0MLlj
# h28rzguBx/RqFJCwEATFnkp4bVcvXQR0cwrGBS8MkCeFCZpNx9xXzoJsUOGFAVLK
# Ux3B
# SIG # End signature block
