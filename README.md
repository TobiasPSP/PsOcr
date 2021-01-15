# OCR (Optical Character Recognition) with PowerShell

Windows 10 comes with built-in OCR, and **Windows PowerShell** can access the OCR engine (*PowerShell 7 cannot*).

THIS MODULE IS NOT YET FINISHED. APPARENTLY THERE ARE SOME VERY WEIRD LOADING ISSUES. WHEN YOU IMPORT-MODULE THE MODULE WITH FULL PATH, ALL WORKS FINE. ELSE, NO COMMANDS ARE MADE AVAILABLE. INVESTIGATING.

## Install

Install the module from the *PowerShell Gallery*:

```powershell
Install-Module -Name PsOct -Scope CurrentUser
```

## Perform OCR

To convert an image file to text, use `Convert-PsoImageToText` and submit the path to the file:

```powershell
Convert-PsoImageToText -Path c:\some\file.png
```

This invokes the OCR engine and returns recognized lines and words:




Home of the PowerShell module "PsOcr" which uses the native Windows 10 OCR engine to convert image files to text
