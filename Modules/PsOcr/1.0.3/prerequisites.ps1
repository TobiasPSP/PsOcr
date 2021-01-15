# make sure all required assemblies are loaded BEFORE any class definitions use them:
try
{
 Add-Type -AssemblyName System.Runtime.WindowsRuntime
    
 # WinRT assemblies are loaded indirectly:
 $null = [Windows.Storage.StorageFile,                Windows.Storage,         ContentType = WindowsRuntime]
 $null = [Windows.Media.Ocr.OcrEngine,                Windows.Foundation,      ContentType = WindowsRuntime]
 $null = [Windows.Foundation.IAsyncOperation`1,       Windows.Foundation,      ContentType = WindowsRuntime]
 $null = [Windows.Graphics.Imaging.SoftwareBitmap,    Windows.Foundation,      ContentType = WindowsRuntime]
 $null = [Windows.Storage.Streams.RandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]
 $null = [WindowsRuntimeSystemExtensions]
    
 # some WinRT assemblies such as [Windows.Globalization.Language] are loaded indirectly by returning
 # the object types:
 $null = [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
}
catch
{
  throw 'OCR requires Windows 10 and Windows PowerShell. You cannot use this module in PowerShell 7'
}
# define the class only AFTER all types have been loaded