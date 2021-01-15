# make sure all required assemblies are loaded BEFORE any class definitions use them:
Add-Type -AssemblyName System.Runtime.WindowsRuntime
    
# WinRT assemblies are loaded indirectly:
$null = [Windows.Storage.StorageFile,                Windows.Storage,         ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine,                Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Foundation.IAsyncOperation`1,       Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.SoftwareBitmap,    Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.RandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]
$se = [WindowsRuntimeSystemExtensions]
    
# some WinRT assemblies such as [Windows.Globalization.Language] are loaded indirectly by returning
# the object types:
$null = [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
    
# define the class only AFTER all types have been loaded

. "$PSScriptRoot\Convert-PsoImageToText.ps1"