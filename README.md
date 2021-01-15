# OCR (Optical Character Recognition) with PowerShell

Windows 10 comes with built-in OCR, and **Windows PowerShell** can access the OCR engine (*PowerShell 7 cannot*).

**Disclaimer:** There is plenty of code out there showing how to do OCR with *PowerShell* on *Windows 10* yet I did not find a *ready-to-use* module. That's why I created this one. So no, I neither have invented this nor did I invest too much thought into this. I primarily focused on usability and wrapping up what I found in different places as a easy-to-use *PowerShell* module. The most helpful initial reference I found was [this](https://github.com/HumanEquivalentUnit/PowerShell-Misc/blob/master/Get-Win10OcrTextFromImage.ps1).

So what you find here should work like a snap to mass-OCR any number of images files. 

## Install

Install the module from the *PowerShell Gallery*:

```powershell
Install-Module -Name PsOcr -Scope CurrentUser
```

## Perform OCR

To convert an image file to text, use `Convert-PsoImageToText` and submit the path to the file:

```powershell
Convert-PsoImageToText -Path c:\some\file.png
```

This invokes the OCR engine and returns recognized lines and words:

```
Text                                                                         Words
----                                                                         -----
. DESCRIPTION                                                                {., DESCRIPTION}
Takes a path to an image file, with some text on it.                         {Takes, a, path, to...}
Runs Wi ndows 10 OCR agai nst the image.                                     {Runs, Wi, ndows, 10...}
Returns an [OcrResu1t], hopefully with a . Text property containing the text {Returns, an, [OcrResu1t],, hopefully...}
. EXAMPLE                                                                    {., EXAMPLE}
$result =                                                                    {$result, =}
. \Get-Wi n100crTextFromImage.ps1 -Path 'c: \ test. bmp'                     {., \Get-Wi, n100crTextFromImage.ps1, -...
$ result. Text                                                               {$, result., Text}
[cmdl etBi ndi ng                                                            {[cmdl, etBi, ndi, ng}
Pa ram                                                                       {Pa, ram}
# path to an image file                                                      {#, path, to, an...}
[parameter (Mandatory=$true ,                                                {[parameter, (Mandatory=$true, ,}
val ueFromPi pel i ne=$true ,                                                {val, ueFromPi, pel, i...}
val ueFromPi pel i neBypropertyName=$true ,                                  {val, ueFromPi, pel, i...}
Position 0                                                                   {Position, 0}
HelpMessage=' path to an image file, to run OCR on') ]                       {HelpMessage=', path, to, an...}
[val i dateNotNu1 lorEmpty                                                   {[val, i, dateNotNu1, lorEmpty}
Spath                                                                        Spath
```

## Language Support

For good OCR results, it is important to choose the correct OCR language. `Convert-PsoImageText` supports the parameter `-Language` which comes with built-in argument completion and suggests all available OCR languages. Simply press `TAB` or `CTRL+SPACE` to see the available languages.

```powershell
Convert-PsoImageToText -Path c:\some\file.png -Language en-us
```


## Technical Highlights

Windows 10 OCR lives in a different world and uses *WinRT* technology. This technology primarily works asychronously to provide a UI experience without lags and delays.

To automate and access WinRT, there are two major challenges to overcome:

- **Specific WinRT Types**: it is necessary to load the special *WinRT* types which isn't trivial (and won't work outside *Windows PowerShell* so you cannot use *PowerShell 7* for this).
- **Calling Async Methods**: PowerShell needs to invoke the async methods and wait for the results to come in. That requires access to a *await* method.

### Loading WinRT Types

The module loads the required types like this:

```
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
```

Only one assembly can be loaded in a classic way using `Add-Type`.

A whole bunch of other types is loaded by reading the type, and in the type declaration submitting additional information. This may look weird as the result is discarded. The purpose is to make *PowerShell* load the required types into memory.

Yet other types can only be loaded indirectly, i.e. by calling properties like *AvailableRecognizerLanguages*  which in turn loads the types of the returned objects. Again the result is discarded, and the call was just used to provoke loading of types into memory.

### Implementing Await()

To wait for async methods, *.NET Reflection* is used to call the internal await method which is then used by a *PowerShell* function: `Invoke-Async`:

```powershell
# find the awaiter method
  $awaiter = [WindowsRuntimeSystemExtensions].GetMember('GetAwaiter', 'Method',  'Public,Static') |
  Where-Object { $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } |
  Select-Object -First 1

  # define awaiter function
  function Invoke-Async([object]$AsyncTask, [Type]$As)
  {
    return $awaiter.
    MakeGenericMethod($As).
    Invoke($null, @($AsyncTask)).
    GetResult()
  }
```

`Invoke-Async` takes the *IAsyncOperation* async method plus the desired return type, then calls the internal *GetAwaiter()* function to create the appropriate generic awaiter method required for the desired return type.

### Using WnRT Methods

Once this is in place, working with WinRT methods is actually pretty straight-forward, and the entire OCR process is just a series of five steps:

```powershell
    # get image file:
    $file = [Windows.Storage.StorageFile]::GetFileFromPathAsync($path)
    $storageFile = Invoke-Async $file -As ([Windows.Storage.StorageFile])
  
    # read image content:
    $content = $storageFile.OpenAsync([Windows.Storage.FileAccessMode]::Read)
    $fileStream = Invoke-Async $content -As ([Windows.Storage.Streams.IRandomAccessStream])
  
    # get bitmap decoder:
    $decoder = [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($fileStream)
    $bitmapDecoder = Invoke-Async $decoder -As ([Windows.Graphics.Imaging.BitmapDecoder])
  
    # decode bitmap:
    $bitmap = $bitmapDecoder.GetSoftwareBitmapAsync()
    $softwareBitmap = Invoke-Async $bitmap -As ([Windows.Graphics.Imaging.SoftwareBitmap])
  
    # do optical text recognition (OCR) and return lines and words:
    $ocrResult = $ocrEngine.RecognizeAsync($softwareBitmap)
    (Invoke-Async $ocrResult -As ([Windows.Media.Ocr.OcrResult])).Lines | 
      Select-Object -Property Text, @{Name='Words';Expression={$_.Words.Text}}
```

### Dynamic Autocompletion

Which OCR engines are available to you depends largely on which languages you have installed on Windows 10. That's why the parameter `-Language` can have no fixed ValidateSet of available languages.

Instead, I am using a lesser-known attribute (*[ArgumentCompleter()]*) that allows for dynamic autocompletions, and takes the available OCR languages directly from the engine:

```powershell
param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string]
    [Alias('FullName')]
    $Path,
    
    # dynamically create auto-completion from available OCR languages:
    [ArgumentCompleter({
          # receive information about current state:
          param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
          [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages |
          Foreach-Object { 
            # create completionresult items:
            $displayname = $_.DisplayName
            $id = $_.LanguageTag
            [System.Management.Automation.CompletionResult]::new($id, $displayname, "ParameterValue", "$displayName`r`n$id")
          }
            })]
    [Windows.Globalization.Language]
    $Language
  )
```

For more information on argument completion in PowerShell: https://powershell.one/powershell-internals/attributes/auto-completion
## Notes

There is a lot of code floating around showing how to work with WinRT methods, and even how to perform OCR with *PowerShell*, so I definitely haven't invented this code or the technologies behind it. I just couldn't find an easy-to-use *PowerShell* module to do OCR which is why I researched and put together all I found in the Internet.
