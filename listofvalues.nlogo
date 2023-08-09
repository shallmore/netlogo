turtles-own [my-list]

to setup
  clear-all
  create-turtles 10
  ask turtles [
    set my-list []
    repeat 5 [
      set my-list lput random-float 1 my-list
    ]
  ]
end

to go
  ask turtles [
    set heading random 360
    fd 1
  ]
end
