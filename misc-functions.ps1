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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
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
# MIILrgYJKoZIhvcNAQcCoIILnzCCC5sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULXvXW7ESZhFRvUOY7QQIid1m
# Ht+gggkHMIIEKTCCAxGgAwIBAgILBAAAAAABMYnGN+gwDQYJKoZIhvcNAQELBQAw
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
# SIb3DQEJBDEWBBQ12nb6BljI+GcZxMLeLT63BmDDGzANBgkqhkiG9w0BAQEFAASC
# AQDGdqvEY3Y03xUWGafPCJtrfmt0y7g9aP/w0v/ItEMLTJRhBP+FGzr/tO/AcwNW
# ohF8SkbYFcwf3/k/ftJlpTPOLsnBPNV5a1h3l+xzhSPrnNNecZtNlg1X0/D3DgsT
# BZXNJc0tkFwpVeYvKerKrL2MNc5dyyRbwbr28QZql/OMIsWJS33bJYLNAq/B1Q0/
# OUAa1QWOFMUokc9ANAGEAWEbVgA+4vQ2j8MwuNJ68688b8WNodEqsbcuWEs8V9eY
# ACA/Eaq/6wSp/cwFzN4/oEZrPtTjgKmIHa4GnRV1d1apcGSt4iqBiFYIcUQeDWHn
# dpjQoWJPRDYjwvonF6rw/v2I
# SIG # End signature block
