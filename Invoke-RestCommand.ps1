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
# MIILrgYJKoZIhvcNAQcCoIILnzCCC5sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxKwIsg+YXdaP7UMZZZV22ZaD
# X5WgggkHMIIEKTCCAxGgAwIBAgILBAAAAAABMYnGN+gwDQYJKoZIhvcNAQELBQAw
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
# SIb3DQEJBDEWBBSad+S08Jee+rER97/akJjjh60KKTANBgkqhkiG9w0BAQEFAASC
# AQCIDSbm0m4JDasA6EIkoAQJGWNWW4Z5nA/qsNmDwH/9xL5/Xi7Mx+bTkmJ5JxTd
# /6bTCKIKhX0iRjLZrfHQanJzaaxJvmUSxPQyZLPDoNSgO4hfOVwRKxYLJNdOrzTE
# g+RP1WC8BkTe0+7LZoEP9NPI5CuNYVh0P3j/6K5VsZu3+yL46RhQuzb/lDMuBvIo
# pXKtXQHwFM6LuC5sg2B5SImf3898b+hXMcvDzueZmO3pTQbnaFWdI1R6iY5aihc2
# X+zydO/Nf1wqs3NF7VyDKhIVDWXfEExChInptXcBjb8o/hWvmFxyB0wvhD95q/Qf
# Mnu2q8lE8KR8QGLg88120kqE
# SIG # End signature block
