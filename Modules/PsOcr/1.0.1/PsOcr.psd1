

@{

# Module Loader File
RootModule = 'root.ps1'

# Version Number
ModuleVersion = '1.0.1'

# Unique Module ID
GUID = '8b8b571f-57e4-419b-97fe-ac61a5aaed34'

# Module Author
Author = 'Dr. Tobias Weltner'

# Company
CompanyName = 'https://powershell.one'

# Copyright
Copyright = '(c) 2021 Dr. Tobias Weltner. All rights reserved.'

# Module Description
Description = 'convert images to text by using the Windows 10 built-in OCR engine'

# Minimum PowerShell Version Required
PowerShellVersion = '5.1'
CompatiblePSEditions = @('Desktop')

# Name of Required PowerShell Host
PowerShellHostName = ''

# Minimum Host Version Required
PowerShellHostVersion = ''

# List of exportable functions
FunctionsToExport = 'Convert-PsoImageToText'


# List of exportable aliases
AliasesToExport = 'Convert-ImageToText'

# Private data that needs to be passed to this module
PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @(
                'OCR'
                'WinRT'
                'Async'
                'Class'
                'Await'
                'powershell.one'
                'Windows'
            )

            # A URL to the license for this module.
            #LicenseUri = 'https://github.com/xxx/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/TobiasPSP/PsOcr'


        } # End of PSData hashtable

    } # End of PrivateData hashtable

}