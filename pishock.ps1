#########
######### PARAMETERS AND DOCS
#########
param( 
         [int]$op = '1',
         [int]$mode = '1',
         [int]$duration = '1',
         [int]$randmin = '3',
         [int]$randmax = '10',
         [Parameter(Mandatory=$true)]
         [int]$intensity
     )

### Welcome to Toy Dragon's Pishock control script!

## This project is to make it easier for other tools, such as bikubot, to fire off various common
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
#  1 -- default zaappy -- Buzz, pause for 5 seconds, zaap!~
#  2 -- Rando zappy -- Buzz, wait a random amount per tracker, zaap!!
#  3 -- fakeout -- will only buzz.
#  4 -- NoWarning -- Will zap WITHOUT warning buzz

# -randmin <int> -- Minimum number of seconds for Rando Zappy mode delay range
# -randmax <int> -- maximum number of seconds for Rando Zappy Mode delay range

# To get started, grab your API key from pishock.com, and get a list of shocker share codes, and 
# populate the variables in the CONFIGURATION section below


#########
######### CONFIGURATION
#########
# Some needed info to get started! API key and aa list of sharecodes of shockers!
# Note: Despite the below having two, this can have as many listed as you'd like, as it'll loop thru the list! Great for say collab events ;3 

$pishockUsername = "YourUsername"
$pishockAPIkey = "APIKEYHERE"

$shockCodeArray = 'SHARECODE1','SHARECODE2'


#########
######### FUNCTIONS
#########

function ZappyZap
{
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
    Username  = "$pishockUsername"
    Apikey  = "$apikey"
    Code      = "$shockerCode"
    Name     = "ToyDragonShockerScript"
    Op   = "$op"
    Duration    = "$duration"
    Intensity = "$intensity"
  }
Invoke-WebRequest -Uri https://do.pishock.com/api/apioperate -Method POST -Body ($Form|ConvertTo-Json) -ContentType "application/json"
}



function DefaultZappy 
{
## Default function called. This does a buzz, a pause for 5 seconds, then a zap.
$funcDef = ${function:ZappyZap}.ToString()


 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"

   ${function:ZappyZap} = $using:funcDef


   ZappyZap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
   Start-Sleep -Seconds 5
   ZappyZap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration  -pishockUsername $using:pishockUsername
}
}

function RandoZappy 
{
## Does a buzz, then waits a random amount, then 
$funcDef = ${function:ZappyZap}.ToString()


 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"

   ${function:ZappyZap} = $using:funcDef
    $random = Get-Random -Minimum $using:randmin -Maximum $using:randmax

   ZappyZap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
   Start-Sleep -Seconds $random
   ZappyZap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
}
}


function FakeOut
{
## Does a buzz, then waits a random amount, then 
$funcDef = ${function:ZappyZap}.ToString()


 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"

   ${function:ZappyZap} = $using:funcDef
    $random = Get-Random -Minimum $using:randmin -Maximum $using:randmax

   ZappyZap -shockerCode $_ -op 1 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername
}
}

function NoWarning
{
## Does a buzz, then waits a random amount, then 
$funcDef = ${function:ZappyZap}.ToString()


 $shockCodeArray | foreach-Object   -parallel {
   Write-output "Working on $_"

   ${function:ZappyZap} = $using:funcDef
    $random = Get-Random -Minimum $using:randmin -Maximum $using:randmax

   ZappyZap -shockerCode $_ -op 0 -apikey $using:pishockAPIKey  -intensity $using:intensity -duration $using:duration -pishockUsername $using:pishockUsername

}
}



######
######
###### MAGIC TIME

# This be the part where we check what we're gonna do. 
# -mode 1 -- default zaappy -- will default to this
# -mode 2 -- Rando zappy -- will wait a random amount per tracker 
# -mode 3 -- fakeout -- will only buzz.

switch ($mode){
    1 {DefaultZappy}
    2 {RandoZappy}
    3 {Fakeout}
    4 {NoWarning}
}