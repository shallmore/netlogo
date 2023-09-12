What I want to do is to create agents that move randomly in NetLogo world so that it will be quite similar as in real world (since these agents are based on animals, 

so there shouldn't be any specific codes saying they need to do this or that, most living things move randomly.)

Here is what I plan, I will give a percentage on which direction they will choose, but mostly they will walk straight, here is how I plan it:



1

It might be helpful to explain in words what your code is doing- there are definitely some problems with your approach to headings here.
For a breakdown of what the ifelse statements are being evaluated, have a look at the comments I've inserted into your version. 
You'll notice that you're adding or subtracting to a turtle heading multiple times in a single code chunk:

to random-behave-old
  let p random-float 100

  if-else p <= 85 [
    ; if p is less than or equal to 85, 
    ; add 45 to heading, then subtract 45 from heading 
    set heading heading + 45
    set heading heading - 45
  ] [ 
    if-else p <= 90 [ 
      ; if p is greater than 85, but less than
      ; or equal to 90, add 45 to heading, then
      ; add another 135 to heading
      set heading heading + 45
      set  heading heading + 135
    ] [ 
      if-else p <= 95 [ 
        ; if p is greater than 90, but less than 
        ; or equal to 95, add 135 to heading, 
        ; then add 225 to heading
        set heading heading + 135
        set heading heading + 225
      ] [
        ; if p is greater than 95, add 225 to heading
        ; then add 315 to the heading.
        set  heading heading + 225
        set heading heading + 315
      ]
    ]
  ]
  if not can-move? 1 [ rt 180 ]
  fd 1
end
Now, if I understand you correctly, you want your turtles to mostly move forward the direction they are facing, is that true? 
Or do you want them to mostly move towards heading 0 (more or less north in the NetLogo world). Assuming the former, have a look at this version of your code. 
Here, rather than adding to a heading, the turtles just use right-turn (rt) to change their heading.

to random-behave
  let p random-float 100

  if-else p <= 85 [
    ; if p is less than or equal to 85, 
    ; right-turn a random value from -45 to 45
    rt random 91 - 45
  ] [ 
    if-else p <= 90 [ 
      ; if p is greater than 85, but less than
      ; or equal to 90, right-turn 90, then 
      ; right-turn a further -45 to 45
      rt 90 + random 91 - 45
      print "Turning right!"
    ] [ 
      if-else p <= 95 [ 
        ; if p is greater than 90, but less than 
        ; or equal to 95, right-turn 180, then 
        ; right-turn a further -45 to 45
        rt 180 + random 91 - 45
        print "Turning around!"
      ] [
        ; if p is greater than 95, right-turn 270, then 
        ; right-turn a further -45 to 45
        rt 270 + random 91 - 45
        print "Turning left!"
      ]
    ]
  ]
  if not can-move? 1 [ rt 180 ]
  fd 1
end
If in fact you want them to move mostly a specific direction, you can modify the above. 
For example, to move mostly north, use something like set heading 0 + random 91 - 45; 
to move mostly east, something like set heading 90 + random 91 - 45.


