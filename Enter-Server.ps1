function Enter-Server {
<#
.SYNOPSIS
Performs a login to an Infoblox server.


.DESCRIPTION
Performs a login to an Infoblox server. 

This is the first Cmdlet to be executed and required for all other Cmdlets of this module. It creates service references in the module variable.


.OUTPUTS
This Cmdlet returns a reference to a InfobloxWapi.RestHelper object, the REST wrapper to the Infoblox REST API. On failure it returns $null.


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

Perform a login to an Infoblox server with credentials in a PSCredential object and against a server defined within module configuration xml file.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Enter-Server/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/biz.dfch.PS.Ipam.Infoblox.Api.psd1/


#>
[CmdletBinding(
	HelpURI='http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Enter-Server/'
)]
[OutputType([InfobloxWapi.RestHelper])]

Param 
(
	# [Optional] The ServerBaseUri such as 'https://infoblox/'. If you do not 
	# specify this value it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 0)]
	[Uri] $ServerBaseUri = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ServerBaseUri
	, 
	# [Optional] The BaseUrl such as '/wapi/'. If you do not specify this value 
	# it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $BaseUrl = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).BaseUrl
	, 
	# [Optional] The Version such as 'v1.2.1'. If you do not specify this value 
	# it is taken from the module configuration file.
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $Version = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Version
	, 
	# Specifies credentials for authentication of the request
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
	Log-Debug $fn ("CALL. ServerBaseUri '{0}'; BaseUrl '{1}'. Username '{2}'" -f $ServerBaseUri, $BaseUrl, $Credential.Username ) -fac 1;
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
	
	$Ipam = New-Object InfobloxWapi.RestHelper
		(
			$ServerBaseUri, 
			(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Version, 
			(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).TimeoutSec, 
			$BaseUrl, 
			(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ReturnType, 
			(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).ContentType
		);
	$Ipam.SetCredential($Username, $Password);
	(Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).IPAM = $Ipam;

	$OutputParameter = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).IPAM;
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
 # Copyright 2014, 2015 Ronald Rink, d-fens GmbH
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
