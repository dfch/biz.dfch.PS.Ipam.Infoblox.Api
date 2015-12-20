function Get-InfobloxIpAddress {
<#

.SYNOPSIS

This is a short description of the Cmdlet.



.DESCRIPTION

This is a short description of the Cmdlet.

This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. 



.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

Here we describe the input to the Cmdlet. See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Param1

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param2

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param3

Description of the parameter. You may be more elaborate on this.



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxIpAddress -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxIpAddress -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.LINK

Online Version: http://dfch.biz/PS/Infoblox/Api/Get-InfobloxIpAddress/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium",
	HelpURI='http://dfch.biz/PS/Infoblox/Api/Get-InfobloxIpAddress/'
)]
[OutputType([String])]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[Alias('ref')]
	[string] $Network
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[int] $Number = 1
) # Param
BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Network '{0}'. Number '{1}'. ParameterSetName: '{2}'." -f $Network, $Number, $PsCmdlet.ParameterSetName) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	if($Network -isnot [String]) {
		$msg = ("Network: Parameter validation FAILED. [{0}]" -f $Network.GetType());
		$e = New-CustomErrorRecord -e $msg -cat InvalidArgument -o $Network;
		throw($gotoError);
	} # if
	
	if($PSCmdlet.ShouldProcess(("[{0}] address from network '{1}'." -f $Number, $Network))) {
		$r = Invoke-InfobloxRestCommand -Method 'POST' -Uri $Network -QueryParameters @{ "_function"="next_available_ip";"num"=$Number };
		if(!$r) { throw($gotoFailure); }
		$fReturn = $true;
		$OutputParameter = $r;
	} # if
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
} # finally

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

} # END

} # function
Export-ModuleMember -Function Get-InfobloxIpAddress;

function New-InfobloxHostRecord {
<#

.SYNOPSIS

This is a short description of the Cmdlet.



.DESCRIPTION

This is a short description of the Cmdlet.

This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. 



.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

Here we describe the input to the Cmdlet. See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Param1

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param2

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param3

Description of the parameter. You may be more elaborate on this.



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

New-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

New-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.LINK

Online Version: http://dfch.biz/PS/Infoblox/Api/New-InfobloxHostRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium",
	HelpURI='http://dfch.biz/PS/Infoblox/Api/New-InfobloxHostRecord/'
)]
[OutputType([String])]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[alias("Hostname")]
	[string] $Name
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[string[]] $Address
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[string[]] $Alias
	,
	[Parameter(Mandatory = $false, Position = 3)]
	[string] $Comment
	,
	[Parameter(Mandatory = $false)]
	[switch] $Disable = $false
	,
	[Parameter(Mandatory = $false)]
	[switch] $AutoProvision = $true
) # Param
BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Name '{0}'. Disable '{1}'. AutoProvision '{2}'. ParameterSetName: '{3}'." -f $Name, $Disable, $AutoProvision, $PsCmdlet.ParameterSetName) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	$aAddress = @();
	foreach($a in $Address) {
		$aAddress += @{'ipv4addr' = $a.ToString()};
	} # foreach

	$aAlias = @();
	foreach($a in $Alias) {
		$aAlias += $a.ToString();
	} # foreach
	
	# Build Infoblox host:record entry
	$Record = @{};
	$Record.name = $Name;
	$Record.ipv4addrs = $aAddress;
	$Record.aliases = $aAlias;
	if($Comment) { $Record.comment = $Comment; }
	if($Disable) { $Record.disable = $true; } else { $Record.disable = $false; }
	$aExtAttr = @{};
	if($AutoProvision) {
		$aExtAttr.Add("AutoProvisioned", "TRUE");
	} else {
		$aExtAttr.Add("AutoProvisioned", "FALSE");
	} # if
	$Record.'extensible_attributes' = $aExtAttr;
	
	$Body = ConvertTo-Json $Record;
	Log-Debug $fn ("Body: '{0}'" -f $Body);
	$r = Invoke-InfobloxRestCommand -Uri 'record:host' -Body $Body -Method 'POST';
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
} # finally

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

} # END

} # function
Export-ModuleMember -Function New-InfobloxHostRecord;

function Get-InfobloxHostRecord {
<#

.SYNOPSIS

This is a short description of the Cmdlet.



.DESCRIPTION

This is a short description of the Cmdlet.

This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. 



.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

Here we describe the input to the Cmdlet. See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Param1

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param2

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param3

Description of the parameter. You may be more elaborate on this.



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.LINK

Online Version: http://dfch.biz/PS/Infoblox/Api/Get-InfobloxHostRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium",
	HelpURI='http://dfch.biz/PS/Infoblox/Api/Get-InfobloxHostRecord/'
)]
[OutputType([String])]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[alias("Hostname")]
	[string] $Name
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'r')]
	[alias("MaxResult")]
	[int] $Count = 2
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'h')]
	[switch] $HostOnly = $true
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'e')]
	[alias("FQDN")]
	[switch] $ExactMatch = $true
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'r')]
	[switch] $RegExp = $true
) # Param
BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Name '{0}'. Count '{1}'. ParameterSetName: '{2}'." -f $Name, $Count, $PsCmdlet.ParameterSetName) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	
	switch($PsCmdlet.ParameterSetName) {
	'r' {
		if($RegExp) {
			$QueryParameterName = 'name~';
			$QueryParameterValue = '{0}';
		} else {
			$QueryParameterName = 'name';
		$QueryParameterValue = '{0}';
		} # if
	} # case r
	'h' {
		$QueryParameterName = 'name~';
		$QueryParameterValue = '^{0}\.';
	} # case h
	'e' {
		$QueryParameterName = 'name';
		$QueryParameterValue = '{0}';
	} # case e
	default {
		$msg = "ERROR: Unknown ParameterSetName: '{0}'" -f $PsCmdlet.ParameterSetName;
		Log-Critical $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PsCmdlet.ParameterSetName;
		throw($gotoError);
	} # default
	} # switch
	
	$r = Invoke-InfobloxRestCommand -Method 'GET' -Uri 'record:host' -QueryParameters @{$QueryParameterName=($QueryParameterValue -f $Name); '_max_results'=$Count};
	if($r) {
		if( ($PsCmdlet.ParameterSetName -eq 'h') -And ($r.Count -gt 1) ) {
			Log-Warn $fn ("Request for hostname '{0}' returned more than 1 record. This might lead to unpredictable results.");
		} # if
		$fReturn = $true;
		$OutputParameter = $r;
	} # if
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
} # finally

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

} # END

} # function
Export-ModuleMember -Function Get-InfobloxHostRecord;

function Remove-InfobloxHostRecord {
<#

.SYNOPSIS

This is a short description of the Cmdlet.



.DESCRIPTION

This is a short description of the Cmdlet.

This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. 



.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

Here we describe the input to the Cmdlet. See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Param1

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param2

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param3

Description of the parameter. You may be more elaborate on this.



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Remove-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Remove-InfobloxHostRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.LINK

Online Version: http://dfch.biz/PS/Infoblox/Api/Remove-InfobloxHostRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium",
	HelpURI='http://dfch.biz/PS/Infoblox/Api/Remove-InfobloxHostRecord/'
)]
[OutputType([String])]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Ref
) # Param
BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Ref '{0}'.ParameterSetName: '{1}'." -f $Ref, $PsCmdlet.ParameterSetName) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	
	if($PsCmdlet.ShouldConfirm($Ref)) {
		$r = Invoke-InfobloxRestCommand -Method 'DELETE' -Uri $Ref;
		if($r) {
			$fReturn = $true;
			$OutputParameter = $r;
		} # if
	} # if
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
} # finally

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

} # END

} # function
Export-ModuleMember -Function Remove-InfobloxHostRecord;

function Get-InfobloxCnameRecord {
<#

.SYNOPSIS

This is a short description of the Cmdlet.



.DESCRIPTION

This is a short description of the Cmdlet.

This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. This is the full description of the Cmdlet. 



.OUTPUTS

Here we describe the output of the Cmdlet. This Cmdlet returns a [String] parameter. On failure the string contains $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

Here we describe the input to the Cmdlet. See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER Param1

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param2

Description of the parameter. You may be more elaborate on this.



.PARAMETER Param3

Description of the parameter. You may be more elaborate on this.



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxCnameRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.EXAMPLE

Here we give examples on how to use the Cmdlet in various scenarios. If your Cmdlet supports parameter sets you should give examples for each parameter set.

Get-InfobloxCnameRecord -Param1 "Value1" -Param2 "Value2" -Param3 "Value3"



.LINK

Online Version: http://dfch.biz/PS/Infoblox/Api/Get-InfobloxCnameRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Medium",
	HelpURI='http://dfch.biz/PS/Infoblox/Api/Get-InfobloxCnameRecord/'
)]
[OutputType([String])]
Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[alias("Hostname")]
	[string] $Name
	,
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'r')]
	[alias("MaxResult")]
	[int] $Count = 2
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'h')]
	[switch] $HostOnly = $true
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'e')]
	[alias("FQDN")]
	[switch] $ExactMatch = $true
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'r')]
	[switch] $RegExp = $true
) # Param
BEGIN {

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Name '{0}'. Count '{1}'. ParameterSetName: '{2}'." -f $Name, $Count, $PsCmdlet.ParameterSetName) -fac 1;

} # BEGIN
PROCESS {

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;

try {

	# Parameter validation
	
	switch($PsCmdlet.ParameterSetName) {
	'r' {
		if($RegExp) {
			$QueryParameterName = 'name~';
			$QueryParameterValue = '{0}';
		} else {
			$QueryParameterName = 'name';
		$QueryParameterValue = '{0}';
		} # if
	} # case r
	'h' {
		$QueryParameterName = 'name~';
		$QueryParameterValue = '^{0}\.';
	} # case h
	'e' {
		$QueryParameterName = 'name';
		$QueryParameterValue = '{0}';
	} # case e
	default {
		$msg = "ERROR: Unknown ParameterSetName: '{0}'" -f $PsCmdlet.ParameterSetName;
		Log-Critical $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PsCmdlet.ParameterSetName;
		throw($gotoError);
	} # default
	} # switch
	
	$r = Invoke-InfobloxRestCommand -Method 'GET' -Uri 'record:cname' -QueryParameters @{$QueryParameterName=($QueryParameterValue -f $Name); '_max_results'=$Count};
	if($r) {
		if( ($PsCmdlet.ParameterSetName -eq 'h') -And ($r.Count -gt 1) ) {
			Log-Warn $fn ("Request for hostname '{0}' returned more than 1 record. This might lead to unpredictable results.");
		} # if
		$fReturn = $true;
		$OutputParameter = $r;
	} # if
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up
} # finally

# Return values are always and only returned via OutputParameter.
return $OutputParameter;

} # PROCESS

END {

$datEnd = [datetime]::Now;
Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

} # END

} # function
Export-ModuleMember -Function Get-InfobloxCnameRecord;

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULXvXW7ESZhFRvUOY7QQIid1m
# Ht+gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ12nb6BljI+GcZ
# xMLeLT63BmDDGzANBgkqhkiG9w0BAQEFAASCAQDGdqvEY3Y03xUWGafPCJtrfmt0
# y7g9aP/w0v/ItEMLTJRhBP+FGzr/tO/AcwNWohF8SkbYFcwf3/k/ftJlpTPOLsnB
# PNV5a1h3l+xzhSPrnNNecZtNlg1X0/D3DgsTBZXNJc0tkFwpVeYvKerKrL2MNc5d
# yyRbwbr28QZql/OMIsWJS33bJYLNAq/B1Q0/OUAa1QWOFMUokc9ANAGEAWEbVgA+
# 4vQ2j8MwuNJ68688b8WNodEqsbcuWEs8V9eYACA/Eaq/6wSp/cwFzN4/oEZrPtTj
# gKmIHa4GnRV1d1apcGSt4iqBiFYIcUQeDWHndpjQoWJPRDYjwvonF6rw/v2IoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MDcxMTA5MDUwNVowIwYJKoZIhvcNAQkEMRYEFAckJ9BP3QtyYudIbSZl7Ip7/29a
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQBmBj21gf6XSVu+cIjU
# DJctdgrHm7pi7jqGf/2gSiQdDRauANcvHQBhl9z/u1ry+4TWkAqUmzhcm8HybR8e
# mLMBuyBZvs1cunCKllu8kczWZzp3o7heuxStrnbh0R7SiNKc89qVedK3jPBfWM8g
# e32JBM4n230OplNl9DxGsx7UP3t7R83kgWPltZdSUR8hiDSp3U8KDqj67jOreflB
# hd/nIRS9kNcH8tx87dcR2xcx7K1FKC5M4Q0EQQx6ASd2kU+WS9Lu+OvgjYkU6MXg
# qzYjKv3gr+tVEbWvJNivtcRHXFVEZqz2dgjep0cp9oXzTza3zbEAhKKYOCeBr0WH
# mGe/
# SIG # End signature block
