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
Invoke-RestCommand networks -Username Edgar.Schnittenfittich -Password 'P@ssL0rd'

Get a list of all networks defined in Infoblox. UriServer and UriBase are taken from the configuration file.


.EXAMPLE
Invoke-RestCommand networks -Credential $Credential

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
	[AllowEmptyString()]
	[string] $UriServer = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriServer
	,
	# Specifes the base url to invoke
	[Parameter(Mandatory = $false)]
	[AllowEmptyString()]
	[string] $UriBase = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).UriBase
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
	
	if($QueryParameters.Contains('_return_type')) 
	{
		Log-Warning $fn "QueryParameters already contains '_return_type' header. Skipping creation of custom '_return_type' header ...";
	} 
	else 
	{
		$QueryParameters.Add('_return_type', $ReturnType);
	}
	
	if($Headers.Contains('Authorization')) 
	{
		Log-Warning $fn "Headers already contains 'Authorization' header. Skipping creation of custom 'Authorization' header ...";
	} 
	else 
	{
		$BasicUserPass = "{0}:{1}" -f $Username, $Password;
		$Headers.Add('Authorization', "Basic {0}" -f ($BasicUserPass | ConvertTo-Base64));
	}

	if($Uri.IsAbsoluteUri) 
	{
		[Uri] $UriRestCommand = $Uri;
	} 
	else 
	{
		if(!$Uri.ToString().StartsWith('/') ) 
		{
			$Uri = "/{0}" -f $Uri;
		}
		[Uri] $UriRestCommand = $UriServer;
		[Uri] $UriRestCommand = "{0}{1}{2}" -f $UriRestCommand.AbsoluteUri, $UriBase, $Uri;
	}
	if([uri]::UriSchemeHttp,[uri]::UriSchemeHttps -notcontains $UriRestCommand.Scheme)
	{
		$msg = "UriRestCommand: Parameter check FAILED. Invalid Uri Scheme '{0}'" -f $UriRestCommand;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat InvalidData -o $UriRestCommand;
		throw($gotoError);
	}
	if($UriRestCommand.Query) 
	{
		Log-Warn $fn ("QueryString already exists in UriRestCommand: '{0}'" -f $UriRestCommand.AbsoluteUri);
	} 
	else 
	{
		# Build QueryString
		$QueryString = '';
		foreach($q in $QueryParameters.GetEnumerator()) 
		{
			$QueryString += ("&{0}={1}" -f $q.Name, $q.Value);
		}
		$QueryString = "{0}" -f $QueryString.Substring(1);
		Log-Debug $fn ("QueryString: '{0}'" -f $QueryString);
		[Uri] $UriRestCommand = "{0}?{1}" -f $UriRestCommand.AbsoluteUri, $QueryString;
	}
	Log-Debug $fn ("Invoking '{0}' '{1}' as user '{2}' ..." -f $Method, $UriRestCommand.AbsoluteUri, $Username);
	if( ('GET' -eq $Method) -Or ('HEAD' -eq $Method) ) 
	{
		$r = Invoke-RestMethod -Method $Method -Uri $UriRestCommand -Headers $Headers -ContentType $ContentType -TimeoutSec $TimeoutSec;
	} 
	else 
	{
		$r = Invoke-RestMethod -Method $Method -Uri $UriRestCommand -Headers $Headers -ContentType $ContentType -TimeoutSec $TimeoutSec -Body $Body;
	}
	Log-Debug $fn ("Invoking '{0}' '{1}' as user '{2}' COMPLETED." -f $Method, $UriRestCommand.AbsoluteUri, $Username);
	$fReturn = $true;
	$OutputParameter = $r;
	
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

/##
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
 #/
