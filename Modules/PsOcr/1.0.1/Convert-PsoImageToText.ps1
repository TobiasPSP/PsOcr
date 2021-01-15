
class AsyncHelper
{
  hidden static [System.Reflection.MethodInfo]$awaiter = $null
  
  # initialize the class
  static AsyncHelper()
  {    
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    # find the awaiter method
    [AsyncHelper]::awaiter = [WindowsRuntimeSystemExtensions].GetMember('GetAwaiter', 'Method',  'Public,Static') |
      Where-Object { $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } |
      Select-Object -First 1
  }
  
  # invokes a async method and waits for the return values to be available:

  static [object] Invoke([object]$AsyncTask, [Type]$ResultType)
  {
    return [AsyncHelper]::awaiter.
       MakeGenericMethod($ResultType).
       Invoke($null, @($AsyncTask)).
       GetResult()
  }
}

function Convert-PsoImageToText
{
  <#
      .SYNOPSIS
      Converts an image file to text by using Windows 10 built-in OCR
      .DESCRIPTION
      Detailed Description
      .EXAMPLE
      Convert-ImageToText -Path c:\temp\image.png
      Converts the image in image.png to text
      .NOTES
      Original work from https://github.com/HumanEquivalentUnit/PowerShell-Misc

  #>
  [CmdletBinding()]
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
  
  begin
  { 
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
     
    # [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
    if ($PSBoundParameters.ContainsKey('Language'))
    {
      $ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage($Language)
    }
    else
    {
      $ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    }
  
    
    # PowerShell doesn't have built-in support for Async operations, 
    # but all the WinRT methods are Async.
    # This function wraps a way to call those methods, and wait for their results.
    
  }
  
  process
  {
    # all of these methods run asynchronously because they are tailored for responsive UIs
    # PowerShell is single-threaded and synchronous so a helper class is used to 
    # run the async methods and wait for them to complete, essentially reversing the async 
    # behavior
    
    # [AsyncHelper]::Invoke() requires the async method and the desired return type
  
    # get image file:
    $file = [Windows.Storage.StorageFile]::GetFileFromPathAsync($path)
    $storageFile = [AsyncHelper]::Invoke($file, [Windows.Storage.StorageFile])
  
    # read image content:
    $content = $storageFile.OpenAsync([Windows.Storage.FileAccessMode]::Read)
    $fileStream = [AsyncHelper]::Invoke($content, [Windows.Storage.Streams.IRandomAccessStream])
  
    # get bitmap decoder:
    $decoder = [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($fileStream)
    $bitmapDecoder = [AsyncHelper]::Invoke($decoder, [Windows.Graphics.Imaging.BitmapDecoder])
  
    # decode bitmap:
    $bitmap = $bitmapDecoder.GetSoftwareBitmapAsync()
    $softwareBitmap = [AsyncHelper]::Invoke($bitmap, [Windows.Graphics.Imaging.SoftwareBitmap])
  
    # do optical text recognition (OCR) and return lines and words:
    $ocrResult = $ocrEngine.RecognizeAsync($softwareBitmap)
    [AsyncHelper]::Invoke($ocrResult, [Windows.Media.Ocr.OcrResult]).Lines | 
      Select-Object -Property Text, @{Name='Words';Expression={$_.Words.Text}}
  }
}

Set-Alias -Name Convert-ImageToText -Value Convert-PsoImageToText