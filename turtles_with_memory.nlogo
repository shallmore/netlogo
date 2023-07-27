turtles-own
[
  best-prices ; list of best prices by crops [corn soy wheat]
  last-patch
]

patches-own
[
  price ; price for a crop
  crop  ; crop
]

globals
[
  crops
]

to setup
  ca
  create-turtles 50
  [
    setxy random-xcor random-ycor
  ]
  set crops ["corn" "soy" "wheat"]
  ask patches [ set crop one-of crops]
  ask patches [ set price random 10]
  ask turtles[
    set best-prices map [cr -> mean [price] of patches with [crop = cr]] crops  
  ]
end

to go
  ask turtles [
    ifelse patch-here != last-patch [
      let alpha .1
      let cr [crop] of patch-here
      let pr [price] of patch-here
      let idx position cr crops
      let new_prc (item idx best-prices * (1 - alpha) + alpha * pr)
      set best-prices replace-item idx best-prices new_prc
      set last-patch patch-here
    ][
      set heading heading + (random-float 1 - random-float 1)
      forward .001
    ]
  ]
end

;;
https://groups.google.com/g/netlogo-users/c/LXEPfRmBE3E
Google groups is a really good tool.

You could copy and past it and add a setup and go button in the interface, but it won't visually display much useful info,

If you want to get something interesting, you should click on the different agents and inspect their variables.

each turtle's initial prices for the crops are:

ask turtles[
    set best-prices map [cr -> mean [price] of patches with [crop = cr]] crops  
]

which is a list of the mean price of all patches for each crop. A lot of the code in there is just for manipulating lists, getting values from indices and replacing them. This is the rolling update:

let new_prc (item idx best-prices * (1 - alpha) + alpha * pr)

You could implement this differently but this essentially does the update weighting the current best new price information as 10% of the total contribution and the accumulation of all historical prices as 90% of the contribution.

;;
