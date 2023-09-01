;; this model gives the turtles the possibility to sense the other's value and, according to that value, make their own move.

turtles-own [value]

to setup
  clear-all
  set-default-shape turtles "circle"
  create-turtles 30
  [ setxy random-xcor random-ycor
    set color red
    set size 2
    set value random 10 ]
  create-turtles 30
  [ setxy random-xcor random-ycor
    set color blue
    set size 2
    set value random 10 ]
end

to go
  ask turtles with [color = red]
  [ let neighbor one-of turtles in-radius 5 with [color = red]
    ifelse value > [value] of neighbor
    [ set heading 270 ]
    [ set heading 0 ]
    forward 1 + random-float 1
    right random 10 - random 5
  ]
  ask turtles with [color = blue]
  [ let neighbor one-of turtles in-radius 5 with [color = blue]
    ifelse value > [value] of neighbor
    [ set heading 90 ]
    [ set heading 180 ]
    forward 1 + random-float 1
    right random 5 - random 10
  ]
end
