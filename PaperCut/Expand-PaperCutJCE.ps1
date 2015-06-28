Param
(
    # Path to JCE zip
    [Parameter(Mandatory=$true,
                Position=0)]
    [string]
    $JCEZipFile
)

$PaperCutPath         = "C:\Program Files\PaperCut MF"
$RuntimeLibSecurity   = "$PaperCutPath\runtime\jre\lib\security", "$PaperCutPath\runtime\win64\jre\lib\security"
$PolicyFiles          = "local_policy.jar", "US_export_policy.jar"


Function Start-PolicyBackup
{
    $RuntimeLibSecurity | % {
        $RuntimeLibSecurity = $_
        $PolicyFiles | % {
            Move-Item -Path $RuntimeLibSecurity\$_ `
                      -Destination $RuntimeLibSecurity\$_.bak `
                      -ErrorAction SilentlyContinue
        }
    }
}

# http://stackoverflow.com/questions/24672560/most-elegant-way-to-extract-a-directory-from-a-zipfile-using-powershell
Function Expand-JCEZipFile ($JCEZipFile)
{
    $JCEZipFile = $JCEZipFile -replace '"',""
    [IO.Compression.ZipFile]::OpenRead($JCEZipFile).Entries | ? {
        $_.FullName -like "*.jar"
    } | % {
        $ZipFile = $_
        $RuntimeLibSecurity | % {
            $RuntimeLibSecurity = $_
            $PolicyFiles | % {
                $DestinationFile = "$RuntimeLibSecurity\$_"
                [IO.Compression.ZipFileExtensions]::ExtractToFile($ZipFile, $DestinationFile, $true)
            }
        }
        
    }
}

Start-PolicyBackup
Expand-JCEZipFile $JCEZipFile