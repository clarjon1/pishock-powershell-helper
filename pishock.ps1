### Params thaat can be passed:
## MANDATORY:
# -intensity <int> -- Set the intensity of the zap or buzz!

## OPTIONAL:
# -duration <int> -- Sets the duration of the zap or buzz!
# -op [1-3] -- Not used yet! Will be added for CustomZap mode later
# -mode [1-5] -- Sets the mode this will run in. Defaults to 1 Current values:
  # -mode 1 -- DefaultZap -- default buzz, wait (5s) and shock
  # -mode 2 -- RandomZap -- buzz, wait for $randmin up to $randmax, then shock
  # -mode 3 -- Fakeout -- will only buzz
  # -mode 4 -- NoWarning -- zap only, no warning
  # -mode 5 -- Ramp Mode - Will ramp up to the set amount. Will zap at 10%, 25%, 50%, 75% and then 100% of set intensity, with a delay between each zap
# -randmin <int> -- Minimum number of seconds for RandomZap mode delay range
# -randmax <int> -- maximum number of seconds for RandomZap Mode delay range
# -delay <int> -- Sets the delay between warning buzz and zap. Defaults to 5 seconds
[CmdletBinding()]
param( 
    [int]$op = '1',
    [int]$mode = '1',
    [int]$duration = '1',
    [int]$buzzduration = $duration,
    [int]$randmin = '1',
    [int]$randmax = '10',
    [int]$delay = '5',
    [Parameter(Mandatory=$true)]
    [int]$intensity = '3')

### CONFIGURATION
# To get started, grab your API key from pishock.com, and get a list of shocker share codes, and 
# populate the variables in the CONFIGURATION section below
# Note: Despite the below having two, this can have as many listed as you'd like, as it'll loop thru the list! Think collabs, parties, etc. 
$throtlimit = 10  # Powershell defaults the limit of how many asyncs go at once to five and queues 'em beyond that point. adjust this so it's more than the number of shocker sharecodes
$pishockUsername = "YourUsername"
$pishockAPIkey = "APIKEYHERE"
$shockCodeArray = 'SHARECODE1','SHARECODE2'

### BASE FUNCTIONS
function CallAPI {
  <#
  .SYNOPSIS
  Builds an API call to the pishock api 
  
  .DESCRIPTION
  This function will take the data passed to it and build a json bundle to send to pishock's API  endpoint.
  It has different defaults than the base script does, to allow for users to take its function and build their own custom
  vibration/shock patterns based on their needs.
  
  .PARAMETER shockerCode
  Share code of the shocker to target
  
  .PARAMETER pishockUsername
  Username belonging to API key below
  
  .PARAMETER op
  Which operation. 0 to shock, 1 to buzz, 2 to beep
  
  .PARAMETER duration
  Length of operation, in seconds
  
  .PARAMETER intensity
  Intensity / Power level of interaction. 1-100, can be limited on the pishock share code manager
  
  .PARAMETER apikey
  APIkey tied to a specific user account, set in pishockUsername
  
  .EXAMPLE
  CallAPI -pishockUsername DemoName -apikey APIKEYHERE -shockerCode AAAAAAA -op 0 -intensity 10 -duration 1 
  Calls the pishock for shocker associaated with sharecode AAAAAAA for an intensity of 10 power for 1 second, set to zap mode
  
  .NOTES
  This is the core magic bit!
  #>
     param (
         [Parameter(Mandatory=$true)]
         [string]$shockerCode,
         [Parameter(Mandatory = $true)]
         [string]$pishockUsername,
         [int]$op = '0',
         [int]$duration = '1',
         [int]$intensity = '1',
         [Parameter(Mandatory=$true)]
         [string]$apikey
         )

 $Form = @{
    Username = "$pishockUsername"
    Apikey = "$apikey"
    Code = "$shockerCode"
    Name = "PiShock Helper Script"
    Op = "$op"
    Duration = "$duration"
    Intensity = "$intensity"
    }

    try
    {
      $Response = Invoke-WebRequest -Uri https://do.pishock.com/api/apioperate -Method POST -Body ($Form|ConvertTo-Json) -ContentType "application/json"

        # This will only execute if the Invoke-WebRequest is successful.
        $StatusCode = $Response.StatusCode
       
        write-host "Sent: Op: $op Duration: $duration Intensity: $intensity and received  $StatusCode $Response"
    } catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Host $_.Exception.Response

    }


}


### SCRIPTED FUNCTIONS
function DefaultZap {
$funcDef = ${function:CallAPI}.ToString()
 $shockCodeArray | foreach-Object -parallel {
   Write-output "Default Zap, targeting trackers on $_ with intensity $using:intensity "
   ${function:CallAPI} = $using:funcDef
   CallAPI -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:buzzduration -pishockUsername $using:pishockUsername
   $delay = $using:delay + $using:buzzduration
   Start-Sleep -Seconds $delay
   CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration  -pishockUsername $using:pishockUsername
  } -throttlelimit $throtlimit 
}

function RampingZap {
  $funcDef = ${function:CallAPI}.ToString()
   $shockCodeArray | foreach-Object -parallel {
    [int]$ramp1 = $using:intensity * (10/100)
    [int]$ramp2 = $using:intensity * (25/100)
    [int]$ramp3 = $using:intensity * (50/100)
    [int]$ramp4 = $using:intensity * (75/100)

     Write-output "Ramping Zap targeting $_ with intensities of $ramp1 $ramp2 $ramp3 $ramp4 $using:intensity"
     ${function:CallAPI} = $using:funcDef
     CallAPI -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:buzzduration -pishockUsername $using:pishockUsername
     $delay = $using:delay + $using:buzzduration
     Start-Sleep -Seconds $delay
     CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $ramp1 -duration $using:duration  -pishockUsername $using:pishockUsername
     Start-Sleep -Seconds $delay
     CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $ramp2 -duration $using:duration  -pishockUsername $using:pishockUsername
     Start-Sleep -Seconds $delay
     CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $ramp3 -duration $using:duration  -pishockUsername $using:pishockUsername
     Start-Sleep -Seconds $delay
     CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $ramp4 -duration $using:duration  -pishockUsername $using:pishockUsername
     Start-Sleep -Seconds $delay
     CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration  -pishockUsername $using:pishockUsername
    } -throttlelimit $throtlimit 
  }
function RandomZap {
$funcDef = ${function:CallAPI}.ToString()
 $shockCodeArray | foreach-Object -parallel {
   Write-output "Random Zap targeting $_"
   ${function:CallAPI} = $using:funcDef
    $random = Get-Random -Minimum $using:randmin -Maximum $using:randmax
   CallAPI -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:buzzduration -pishockUsername $using:pishockUsername
   $delay = $random + $using:buzzduration
   Start-Sleep -Seconds $delay
   CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
  } -throttlelimit $throtlimit 
}

function Fakeout { 
$funcDef = ${function:CallAPI}.ToString()
 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Faking out (buzz only) targeting $_"
   ${function:CallAPI} = $using:funcDef
   CallAPI -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:buzzduration -pishockUsername $using:pishockUsername
  } -throttlelimit $throtlimit 
}

function NoWarning {
$funcDef = ${function:CallAPI}.ToString()
 $shockCodeArray | foreach-Object   -parallel {
   Write-output "No warning zap targeting $_ at intensity $using:intensity"
   ${function:CallAPI} = $using:funcDef
   CallAPI -shockerCode $_ -op 0 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
  } -throttlelimit $throtlimit 
}

### Switches
switch ($mode){
    1 {DefaultZap}
    2 {RandomZap}
    3 {Fakeout}
    4 {NoWarning}
    5 {RampingZap}
}
