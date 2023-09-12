breed [units unit]

to setup
  clear-all
  set-default-shape units "turtle"
  create-units 5 [
    set color brown - 1
    set size 1.2
    setxy random-xcor random-ycor
  ]
end

to go  
  ask turtles [
    fd 1
    rt random 360
    fd 1
    set heading 0
    fd 1
  ]
end
