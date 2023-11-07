### Welcome to Toy Dragon's Pishock control script!
## This project aims to make it easier for other tools, such as bikubot, to fire off various common
## pishock commands. These commands will, by default, be run in parallel on all configured zappers. 
## I plan on adding individual zapper targeting in the future!!
## By default, this script will provide a warning buzz, a 5 second delay, then send the zap,
## however there are a few more modes available, documented below.

### Params thaat can be passed:
## MANDATORY:
# -intensity <int> -- Set the intensity of the zap or buzz!

## OPTIONAL:
# -duration <int> -- Sets the duration of the zap or buzz!
# -op [1-3] -- Not used yet! Will be added for CustomZap mode later
# -mode [1-4] -- Sets the mode this will run in. Defaults to 1 Current values:
  # -mode 1 -- default zap -- default buzz, wait (5s) and shock
  # -mode 2 -- random zap -- buzz, wait for $randmin up to $randmax, then shock
  # -mode 3 -- fakeout -- will only buzz
  # -mode 4 -- no warning -- zap only, no warning
# -randmin <int> -- Minimum number of seconds for RandoZap mode delay range
# -randmax <int> -- maximum number of seconds for RandoZap Mode delay range
# -delay <int> -- Sets the delay between warning buzz and zap. Defaults to 5 seconds
param( 
    [int]$op = '1',
    [int]$mode = '1',
    [int]$duration = '1',
    [int]$randmin = '3',
    [int]$randmax = '10',
    [int]$delay = '5',
    [Parameter(Mandatory=$true)]
    [int]$intensity)

### CONFIGURATION
# To get started, grab your API key from pishock.com, and get a list of shocker share codes, and 
# populate the variables in the CONFIGURATION section below
# Note: Despite the below having two, this can have as many listed as you'd like, as it'll loop thru the list! Think collabs, parties, etc. 
$pishockUsername = "YourUsername"
$pishockAPIkey = "APIKEYHERE"
$shockCodeArray = 'SHARECODE1','SHARECODE2'



######### FUNCTIONS
function Zap {
     param (
         [Parameter(Mandatory=$true)]
         [string]$shockerCode,
         [string]$pishockUsername,
         [int]$op = '1',
         [int]$duration = '1',
         [int]$intensity = '3',
         [Parameter(Mandatory=$true)]
         [string]$apikey
         )

 $Form = @{
    Username = "$pishockUsername"
    Apikey = "$apikey"
    Code = "$shockerCode"
    Name = "ToyDragonShockerScript"
    Op = "$op"
    Duration = "$duration"
    Intensity = "$intensity"
    }

Invoke-WebRequest -Uri https://do.pishock.com/api/apioperate -Method POST -Body ($Form|ConvertTo-Json) -ContentType "application/json"
}

function DefaultZap {
$funcDef = ${function:Zap}.ToString()
 $shockCodeArray | foreach-Object -parallel {
   Write-output "Working on $_"
   ${function:Zap} = $using:funcDef
   Zap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
   Start-Sleep -Seconds $using:delay
   Zap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration  -pishockUsername $using:pishockUsername
  }
}

function RandoZap {
$funcDef = ${function:Zap}.ToString()

 $shockCodeArray | foreach-Object -parallel {
   Write-output "Working on $_"
   ${function:Zap} = $using:funcDef
    $random = Get-Random -Minimum $using:randmin -Maximum $using:randmax
   Zap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
   Start-Sleep -Seconds $random
   Zap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
  }
}

function FakeOut { 
$funcDef = ${function:Zap}.ToString()

 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"
   ${function:Zap} = $using:funcDef

   Zap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
  }
}

function NoWarning {
$funcDef = ${function:Zap}.ToString()

 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"
   ${function:Zap} = $using:funcDef

   Zap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
  }
}

### Switches
# This be the part where we check what we're gonna do
switch ($mode){
    1 {DefaultZap}
    2 {RandoZap}
    3 {Fakeout}
    4 {NoWarning}
}