# pishock-powershell-helper
A helper script written in powershell for automating some functions of pishock control



 This project aims to make it easier for other tools, such as bikubot, to fire off various common
pishock commands. These commands will, by default, be run in parallel on all configured zappers. 
 I plan on adding individual zapper targeting in the future!!
 By default, this script will provide a warning buzz, a 5 second delay, then send the zap,
however there are a few more modes available, documented below.

## Params thaat can be passed:
### MANDATORY:
```
 -intensity <int> -- Set the intensity of the zap or buzz!
```

### OPTIONAL:
```
 -duration <int> -- Sets the duration of the zap or buzz! Defaults to 1 second
 -buzzduration <int> -- Sets the duration of the buzz! Defaults to -duration's set value
 -op [1-3] -- Not used yet! Will be added for CustomZap mode later
 -mode [1-4] -- Sets the mode this will run in. Defaults to 1 Current values:
   -mode 1 -- default zap -- default buzz, wait (5s) and shock
   -mode 2 -- random zap -- buzz, wait for $randmin up to $randmax, then shock
   -mode 3 -- fakeout -- will only buzz
   -mode 4 -- no warning -- zap only, no warning
 -randmin <int> -- Minimum number of seconds for RandoZap mode delay range
 -randmax <int> -- maximum number of seconds for RandoZap Mode delay range
 -delay <int> -- Sets the delay between warning buzz and zap. Defaults to 5 seconds

 ```
