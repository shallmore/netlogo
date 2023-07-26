ask patches [
  let choice random 4
  (ifelse
    any? unit1s-here [
      set interview interview + 1
    ]
    any? unit2s-here [
      set interview interview + 1
    ]
    choice = 2 [
      set pcolor green
      set plabel "g"
    ]
    ; elsecommands
    [
      set pcolor yellow
      set plabel "y"
  ])
]
