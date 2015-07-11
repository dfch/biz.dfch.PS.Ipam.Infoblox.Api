[CmdletBinding()]
PARAM
( 
	[string] $ModuleName = ([regex]::Match((Get-Item $PSScriptRoot).Name, '^(.+)\.\d\.\d\.\d$')).Groups[1].Value
)

END
{
	if([String]::IsNullOrWhiteSpace($ModuleName))
	{
		$ex = New-Object System.ArgumentNullException('ModuleName', 'ModuleName: Parameter validation FAILED. Parameter must not be null or empty. Please choose a module name.');
		throw $ex;
	}
    $modulePath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules";
    $targetDirectory = Join-Path -Path $modulePath -ChildPath $ModuleName;

    $scriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent;
    $sourceDirectory = Join-Path -Path $scriptRoot -ChildPath Tools;

	Write-Verbose ("Creating/updating module '{0}' in '{1}' ..." -f $ModuleName, $targetDirectory);
    Update-Directory -Source $sourceDirectory -Destination $targetDirectory;

    if ($PSVersionTable.PSVersion.Major -lt 4)
    {
        $modulePaths = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine') -split ';'
        if ($modulePaths -notcontains $modulePath)
        {
            Write-Verbose "Adding '$modulePath' to PSModulePath."

            $modulePaths = @(
                $modulePath
                $modulePaths
            )

            $newModulePath = $modulePaths -join ';'

            [Environment]::SetEnvironmentVariable('PSModulePath', $newModulePath, 'Machine');
            $env:PSModulePath += ";$modulePath";
        }
    }
}

BEGIN
{
    function Update-Directory
    {
        [CmdletBinding()]
        PARAM
		(
            [Parameter(Mandatory = $true)]
            [string] $Source
			,
            [Parameter(Mandatory = $true)]
            [string] $Destination
        )

        $Source = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Source);
        $Destination = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Destination);

        if (!(Test-Path -LiteralPath $Destination))
        {
            $null = New-Item -Path $Destination -ItemType Directory -ErrorAction Stop;
        }

        try
        {
            $sourceItem = Get-Item -LiteralPath $Source -ErrorAction Stop
            $destItem = Get-Item -LiteralPath $Destination -ErrorAction Stop

            if ($sourceItem -isnot [System.IO.DirectoryInfo] -or $destItem -isnot [System.IO.DirectoryInfo])
            {
                throw ("ERROR: '{0}' and '{1}' are not of type [DirectoryInfo]." -f ($sourceItem | Out-String), ($destItem | Out-String));
            }
        }
        catch
        {
            throw 'ERROR: Both Source and Destination must be directory paths.';
        }

        $sourceFiles = Get-ChildItem -Path $Source -Recurse | Where-Object { -not $_.PSIsContainer };

        foreach ($sourceFile in $sourceFiles)
        {
            $relativePath = Get-RelativePath $sourceFile.FullName -RelativeTo $Source;
            $targetPath = Join-Path -Path $Destination -ChildPath $relativePath;

            $sourceHash = Get-FileHash -Path $sourceFile.FullName;
            $destHash = Get-FileHash -Path $targetPath;

            if ($sourceHash -ne $destHash)
            {
                $targetParent = Split-Path $targetPath -Parent;

                if (-not (Test-Path -Path $targetParent -PathType Container))
                {
                    $null = New-Item -Path $targetParent -ItemType Directory -ErrorAction Stop;
                }

                Write-Verbose "Updating file $relativePath to new version.";
                Copy-Item $sourceFile.FullName -Destination $targetPath -Force -ErrorAction Stop;
            }
        }

        $targetFiles = Get-ChildItem -Path $Destination -Recurse | Where-Object { -not $_.PSIsContainer };
    
        foreach ($targetFile in $targetFiles)
        {
            $relativePath = Get-RelativePath $targetFile.FullName -RelativeTo $Destination;
            $sourcePath = Join-Path -Path $Source -ChildPath $relativePath;

            if (-not (Test-Path $sourcePath -PathType Leaf))
            {
                Write-Verbose "Removing unknown file $relativePath from module folder.";
                Remove-Item -LiteralPath $targetFile.FullName -Force -ErrorAction Stop;
            }
        }

    }

    function Get-RelativePath
    {
        PARAM
		(
			[string] $Path
			,
			[string] $RelativeTo 
		)
        return $Path -replace "^$([regex]::Escape($RelativeTo))\\?"
    }

    function Get-FileHash
    {
        PARAM
		(
			[string] $Path
		)

        if (-not (Test-Path -LiteralPath $Path -PathType Leaf))
        {
            return $null;
        }

        $item = Get-Item -LiteralPath $Path;
        if ($item -isnot [System.IO.FileSystemInfo])
        {
            return $null;
        }

        $stream = $null;

        try
        {
            $sha = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider;
            $stream = $item.OpenRead();
            $bytes = $sha.ComputeHash($stream);
            return [convert]::ToBase64String($bytes);
        }
        finally
        {
            if ($null -ne $stream) { $stream.Close() };
            if ($null -ne $sha)    { $sha.Clear() };
        }
    }
}

# SIG # Begin signature block
# MIILrgYJKoZIhvcNAQcCoIILnzCCC5sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwTVm9G1K20oawJBEDJg5iR8E
# pUOgggkHMIIEKTCCAxGgAwIBAgILBAAAAAABMYnGN+gwDQYJKoZIhvcNAQELBQAw
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
# SIb3DQEJBDEWBBQmd5xQjBzniOkitEDKGgkrUf11ADANBgkqhkiG9w0BAQEFAASC
# AQAsqPalLhAFXxwLsFgARNXaCIuOId1TXxKF9le2fIICQ6tWjrDwtCxJkp3BeR2/
# V1PMi9PZULKiuY4EAC+duub2P96heDFXTm0LMpRH41lnpmOf0NOFBMAR3fuPAbnj
# lX4BrM5IsFHLVSA3LQJoWDKCPLFSxK9GX+ENqiAEV57FO+VCLMkOE0XuDBIc0pYx
# FdYUEXVI8/J1XhTWTy8k/zadLPiH97lv0I7MlhIdEvlG4Q1mkhe+ZYNZslt7k+RZ
# uDFlVw0oCm8g0s/A5Qk6P586RWisN9pxFMm5dzrLaMZycnd+oBN3owgWsbona0vx
# /i0E9XdE1UDpxnzgikaZvAYG
# SIG # End signature block
