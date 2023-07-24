breed [cities city]
breed [cars car]

cars-own [history travelled-distance]

to setup
  clear-all
  reset-ticks
  setup-patches
  setup-turtles
end

to setup-turtles
  ask n-of 50 patches with [pcolor = 55 and not any? other turtles-here][sprout-cities 1 [set color blue set size 2 set shape "square"]]

   create-cars 1[
    setxy -90 -90
    set color red
    set size 5
  ]
end

to setup-patches
  ask patches [set pcolor green]
  ask n-of 100 patches [set pcolor brown ask neighbors [set pcolor brown]]
end

to go
    ask cars [
    pendown
    if history <= 50  
      [set heading towards one-of cities in-radius 10]
      move-to min-one-of cities in-radius 360 [distance myself] 

      if cars in-radius 5 = true [set color yellow]
    ]
end
