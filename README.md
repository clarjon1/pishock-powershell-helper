# pishock-powershell-helper
A helper script written in powershell for automating some functions of pishock control

This project relies on features made available in powershell 7.2

 This project aims to make it easier for other tools, such as bikubot, to fire off various common
pishock commands. These commands will, by default, be run in parallel on all configured zappers. 
 I plan on adding individual zapper targeting in the future!!
 By default, this script will provide a warning buzz, a 5 second delay, then send the zap,
however there are a few more modes available, documented below.

## Params that can be passed:
### MANDATORY:
```
 -intensity <int> -- Set the intensity of the zap or buzz!
```

### OPTIONAL:
```
 -duration <int> -- Sets the duration of the zap or buzz! Defaults to 1 second
 -buzzduration <int> -- Sets the duration of the buzz! Defaults to -duration's set value
 -op [1-3] -- Not used yet! Will be added for CustomZap mode later
 -mode [1-5] -- Sets the mode this will run in. Defaults to 1 Current values:
   -mode 1 -- DefaultZap -- default buzz, wait (5s) and shock
   -mode 2 -- RandomZap -- buzz, wait for $randmin up to $randmax, then shock
   -mode 3 -- Fakeout -- will only buzz
   -mode 4 -- NoWarning -- zap only, no warning
   -mode 5 -- Ramp Mode - Will ramp up to the set amount. Will zap at 10%, 25%, 50%, 75% and then 100% of set intensity, with a delay between each zap
 -randmin <int> -- Minimum number of seconds for RandoZap mode delay range
 -randmax <int> -- maximum number of seconds for RandoZap Mode delay range
 -delay <int> -- Sets the delay between warning buzz and zap. Defaults to 5 seconds

 ```

## Configuration

Edit the powershell and find the `###CONFIGURATION` block. Here you provide:
- `$pishockUsername` your Pishock Username
- `$pishockAPIkey` your pishock api key
- `$shockCodeArray` list of shocker share codes, separated by commas. Minimum 1 required, and can include share codes provided to you by other users.

## Powershell security

Powershell with default settings will not like letting you use the script. use `Unblock-File path\to\wherever\you\put\pishock.ps1` to make it behave!
