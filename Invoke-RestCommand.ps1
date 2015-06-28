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
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL82OkI7BgMl4kPzFoDkL8dpi
# fgKgghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# BCgwggMQoAMCAQICCwQAAAAAAS9O4TVcMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290
# IENBMRswGQYDVQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAw
# WhcNMTkwNDEzMTAwMDAwWjBRMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEnMCUGA1UEAxMeR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAt
# IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsk8U5xC+1yZyqzaX
# 71O/QoReWNGKKPxDRm9+KERQC3VdANc8CkSeIGqk90VKN2Cjbj8S+m36tkbDaqO4
# DCcoAlco0VD3YTlVuMPhJYZSPL8FHdezmviaJDFJ1aKp4tORqz48c+/2KfHINdAw
# e39OkqUGj4fizvXBY2asGGkqwV67Wuhulf87gGKdmcfHL2bV/WIaglVaxvpAd47J
# MDwb8PI1uGxZnP3p1sq0QB73BMrRZ6l046UIVNmDNTuOjCMMdbbehkqeGj4KUEk4
# nNKokL+Y+siMKycRfir7zt6prjiTIvqm7PtcYXbDRNbMDH4vbQaAonRAu7cf9DvX
# c1Qf8wIDAQABo4H6MIH3MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBQIbti2nIq/7T7Xw3RdzIAfqC9QejBHBgNVHSAEQDA+MDwG
# BFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20v
# cmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2NybC5nbG9iYWxz
# aWduLm5ldC9yb290LmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAfBgNVHSMEGDAW
# gBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEAIlzF3T30
# C3DY4/XnxY4JAbuxljZcWgetx6hESVEleq4NpBk7kpzPuUImuztsl+fHzhFtaJHa
# jW3xU01UOIxh88iCdmm+gTILMcNsyZ4gClgv8Ej+fkgHqtdDWJRzVAQxqXgNO4yw
# cME9fte9LyrD4vWPDJDca6XIvmheXW34eNK+SZUeFXgIkfs0yL6Erbzgxt0Y2/PK
# 8HvCFDwYuAO6lT4hHj9gaXp/agOejUr58CgsMIRe7CZyQrFty2TDEozWhEtnQXyx
# Axd4CeOtqLaWLaR+gANPiPfBa1pGFc0sGYvYcJzlLUmIYHKopBlScENe2tZGA7Bo
# DiTvSvYLJSTvJDCCBJ8wggOHoAMCAQICEhEhBqCB0z/YeuWCTMFrUglOAzANBgkq
# hkiG9w0BAQUFADBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBu
# di1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAe
# Fw0xNTAyMDMwMDAwMDBaFw0yNjAzMDMwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8w
# HQYDVQQKExZHTU8gR2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxT
# aWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal
# +oTDYUDFRrVZUjtCoi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1A
# cjzyCXenSZKX1GyQoHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFF
# WbIub2Jd4NkZrItXnKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7sp
# Tj1Tk7Om+o/SWJMVTLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5
# crCpGTkqUPqp0Dw6yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAO
# BgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEF
# BQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYD
# VR0TBAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAz
# hjFodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIu
# Y3JsMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5n
# bG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0O
# BBYEFNSihEo4Whh/uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0
# hZuw3WrWFKnBMA0GCSqGSIb3DQEBBQUAA4IBAQCAMtwHjRygnJ08Kug9IYtZoU1+
# zETOA75+qrzE5ntzu0vxiNqQTnU3KDhjudcrD1SpVs53OZcwc82b2dkFRRyNpLgD
# XU/ZHC6Y4OmI5uzXBX5WKnv3FlujrY+XJRKEG7JcY0oK0u8QVEeChDVpKJwM5B8U
# FiT6ddx0cm5OyuNqQ6/PfTZI0b3pBpEsL6bIcf3PvdidIZj8r9veIoyvp/N3753c
# o3BLRBrweIUe8qWMObXciBw37a0U9QcLJr2+bQJesbiwWGyFOg32/1onDMXeU+dU
# PFZMyU5MMPbyXPsajMKCvq1ZkfYbTVV7z1sB3P16028jXDJHmwHzwVEURoqbMIIE
# rTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsrp6UyMA0GCSqGSIb3DQEBBQUAMFEx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQD
# Ex5HbG9iYWxTaWduIENvZGVTaWduaW5nIENBIC0gRzIwHhcNMTIwNjA4MDcyNDEx
# WhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQGEwJERTEbMBkGA1UECBMSU2NobGVz
# d2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHplaG9lMR0wGwYDVQQKDBRkLWZlbnMg
# R21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1mZW5zIEdtYkggJiBDby4gS0cwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTG4okWyOURuYYwTbGGokj+lvB
# go0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHpQ8/QEMs87aalzHz2wtYN1dUIBUae
# dV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/pxu7yOwkAwn/iR+FWbfAyFoCThJYk
# 9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9sypQfrEToe5kBWkDYfid7U0rUkH/m
# bff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7D2f2hy9zTcdgzKVSPw41WTsQtB3i
# 05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHItN6zHpUAYxWwoyWLOcWcS69InAgMB
# AAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAy
# ATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVw
# b3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHR8E
# NzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzY29kZXNp
# Z25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAGCCsGAQUFBzAChjRodHRwOi8vc2Vj
# dXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc2NvZGVzaWduZzIuY3J0MB0GA1Ud
# DgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAfBgNVHSMEGDAWgBQIbti2nIq/7T7X
# w3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOCAQEAB3ZotjKh87o7xxzmXjgiYxHl
# +L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVgBHZAXqPKnlmAMAWj0+Tm5yATKvV6
# 82HlCQi+nZjG3tIhuTUbLdu35bss50U44zNDqr+4wEPwzuFMUnYF2hFbYzxZMEAX
# Vlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYVz3RhD4VdDPmMFv0P9iQ+npC1pmNL
# mCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7LbWSzZXedam6DMG0nR1Xcx0qy9wY
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zGC
# BK4wggSqAgEBMGcwUTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBHMgIS
# ESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTNdSSrgV8KFNXQ0YoE
# IC+IgIc50DANBgkqhkiG9w0BAQEFAASCAQCCxUakqDRkZek9JyQrnx/VqF14MZ67
# LX6ge61XIdMoFbD1gVPaUD0LeX4f++MAOAOLXir+nkA+QEfJorhCHKdD/wBdVvBc
# GM11KD78V/OzSOIpTiGULKY9MccP7ACOpUHBNgq0UgyzUjOwE/wKQvWYdQpynoQW
# oskbu1LtJg6lGqgTtxkoVEANMfVrbrq4owWp2OvWOn9NiMro+WVUS6RI/LpsQt4Q
# VV9+hAt3pkNLD6TSi2caS1dSPE5NX0N1dMbsasAOoQzVWIFXnaVbo/GY3/4ZXux2
# pir7pfA71++Sz+yNEXgdAn4kYv3Yd3qSXDy/skvJ+4m82eYavB4dOwpnoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDQx
# NjExMTUwNVowIwYJKoZIhvcNAQkEMRYEFBYRW/S00rfhSan6VB+s4FcptuZ4MIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7EsKeYw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhBqCB
# 0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQB5jkhm2bx1ZC7vhVHH8JHc
# cbgXBWlwyerLBr7Xg4B1mRcHBeJBDgtjHr/QJPGlZ/k3KrXcb8fo5gfCqu5FQebI
# KxFtXt5ddizI44MiwZLOpH9R/HIaQTwXFhrBtWxy0ColJ0Ixg3Qn+kFTW8U1pKnh
# 1s1IZPiwvewah6KTLXdAkpjfGjzyjHieOzsCVWvYm+tapAd4K1xR9DeFsRcK9SWm
# 0zJVjHXjXUSKH4yHzQUSIUVdUwKz+KpYcm0KfvuAWgUwQXd/eQDe53+XfDqqCLC5
# Z4ssNac5COv8RGrjVnG0qYJivWbCflejbrEhxLALO+pdhpDIIAno7IU4J4/bXZAq
# SIG # End signature block
