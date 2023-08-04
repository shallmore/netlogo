globals [ previous-carbon ]

to setup
  clear-all
  set previous-carbon 0
  system-dynamics-setup    ;; defined by the System Dynamics Modeler
  do-plot
end

to go
  system-dynamics-go       ;; defined by the System Dynamics Modeler
  do-plot
  set previous-carbon carbon
end

to do-plot
  set-current-plot "output"
  set-current-plot-pen "carbon"
  plotxy ticks carbon
  set-current-plot-pen "nitrogen"
  plotxy ticks nitrogen
  set-current-plot "productivity"
  set-current-plot-pen "productivity"
  plotxy ticks productivity
  set-current-plot "trees"
  system-dynamics-do-plot
 end

to-report pulse [volume initial interval]
  set interval abs interval
  let our-x ticks - initial
  let peak volume / dt
  let slope peak / ( dt / 2 )
  let offset abs our-x
  ;; if we have passed the initial pulse, then recalibrate
  ;; to the next pulse interval, if there IS an interval given
  if ( interval > 0 and our-x > ( dt / 2 ) )
    [ set offset  ( our-x mod interval )
      if ( offset > dt / 2 ) [ set offset 0 + offset - interval ]  ]
  ;; the down side of the pulse
  if ( offset >= 0 and offset <= dt / 2  )
     [ report peak - ( slope * offset ) ]
  ;; the upside of the pulse
  if ( offset < 0 and offset >= ( 0 - ( dt / 2 ) ) )
     [ report slope * min (list ( dt / 2 ) ( abs ( interval - offset ) ) ) ]
  report 0
end
