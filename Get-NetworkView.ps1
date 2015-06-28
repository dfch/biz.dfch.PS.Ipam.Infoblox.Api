function Get-InfobloxNetworkView {
<#
.SYNOPSIS

Gets the network view from an Infoblox REST endpoint.


.DESCRIPTION

Gets the network view from an Infoblox REST endpoint.


.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.


.INPUTS
See PARAMETER section for a description of input parameters.


.EXAMPLE
Get-NetworkView

Gets the network view from the Infoblox endpoint.


.EXAMPLE
Get-NetworkView -Default

Gets the 'default' network view from the Infoblox endpoint.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/Get-NetworkView/


.NOTES
See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/Ipam/Infoblox/Api/biz.dfch.PS.Ipam.Infoblox.Api.psd1/


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/PS/Ipam/Infoblox/Api/Get-NetworkView/'
)]
Param 
(
	# Specifies whether to retrieve the 'default' network view
	[Parameter(Mandatory = $false, Position = 0)]
	[switch] $Default = $false
)
BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Param1 '{0}'. Param2 '{1}'. Param3 '{2}'. ParameterSetName: '{3}'." -f $aram1, $Param2, $Param3, $PsCmdlet.ParameterSetName) -fac 1;
}

PROCESS 
{

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try 
{

	# Parameter validation
	# N/A
	# Here you should check your variable input.
	
	$ht = @{};
	if($Default) 
	{
		$ht.Add('name', 'default');
	}
	$r = Invoke-InfobloxRestCommand 'networkview' -QueryParameters $ht;
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
}

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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-NetworkView; } 

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
#
