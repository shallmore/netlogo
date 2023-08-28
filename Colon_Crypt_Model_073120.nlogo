


extensions [sound] ; Ax 022316, Ax 020117

globals[ ;variables that are accessed by mutliple methods (globally) are named here
  keepgoing ;set as false when either the crypt is reduced to a single layer of cells or the crypt grows over the top of the world.
  gradientson  ;boolean used to determine whether gradients have already been turned on or not
  MonoclonalTime; used to display how many ticks it takes for monoclonal conversion to occur
  ExtinctionTime; displays the tick at which the crypt collapses
  UnboundedSizeTime; displays the tick at which the crypt produces polyps (overflow)
  CellsInLumen; displays the number of cells specifically in the lumen, above the crypt.
  FissionTime; time it takes the crypt to split into multiple crypts after random cell div. is turned on
  ;Protrusion; distance from the lumenal surface that cells protrude (usually zero)
  highest; depth of the crypt

  chemoct ; used to keep track of the chemotherapy interval.
  chemoRound ;round of chemotherapy
  preventct; Ax, keeps track of prevention treatment interval.
  cellsLastRound ;number of cells in crypt at the end of the last round of chemotherapy
  cellLoss ;number of cells lost at the beginning of the current round of chemotherapy
  cellLossAvg
  cellGain ;number of cells gained over the compensational regeneration period
  cellGainAvg
  cryptValley ;number of cells at lowest point after treatment
  cryptValleyAvg
  cryptPeak ;number of cells at the end of the crypt's compensational regeneration period
  valleyTime ;time at which valley was reached
  peakTime ;time at which peak was reached
  compensateTime ;peakTime - valleyTime
  compensateTimeAvg
  cryptRegRate ;rate at which crypt regenerates itself after each treatment round
  cryptRegRateAvg ;average rate of crypt regeneration over this treatment
  tempTotal

  timeToCure ;keeps track of how long it takes for chemotherapy to get mutants below mutantThreshold
  ;mutantThreshold ;set acceptable number of mutants in colon--when there are fewer mutants than mutantThreshold, the patient is "cured"

  colored ; binary, keeps track of whether progeny are colored or not.s
  top; size of world, altered by setup
  CellsPerRow ; number of cells per row in crypt, altered by setup
  CutOffAboveQuiescentRegion ; the cutoff between what is called a quiescent and a differentiated cell, since they are both defined as having a probability of dividing lower than DiffCellProbabilityThreshold
; is done spacially, by drawing a line "CutOffAboveQuiescentRegion" cell rows above the quiescent gradient, and all cells above this line are counted as differentiated, while cells below are counted as quiescent
; this indicator may miscount cells if the proliferating region is too small, and may need to be modified for the counts and plots below to print the desired cell groups.
ExtraVariableX; used in behavior space, because no new variables can be introduced within behavior space.
ExtraVariableY; used in behavior space


  CountSCq ; globals display respective cell types, useful for easier reporting in behavior space.
  CountProlif
  CountDiff
  CountMutantA
  CountMutantB
  CountTotal

  PropSCq ;proportions of each type of cell in the crypt
  PropProlif
  PropDiff

  PropSCqAvg
  PropProlifAvg
  PropDiffAvg


  MONOCLONALCOMPLETE; temporary variable

  ]


patches-own
[
  divgradient   ;boolean determining whether patch is in div gradient
  diegradient   ;boolean determining whether patch is in die gradient
  gradientprobdiv   ;probability of division at this point in the gradient
  gradientprobdie   ;probability of death at this point in the gradient
  gradientprobdivcolor   ;color representing probability of division at this point in the gradient
  gradientprobdiecolor   ;color representing probability of death at this point in the gradient

]

breed [cells cell]

cells-own [; variables that the cells themselves posess are named here
  celltype   ;shows cell type: quiescent, proliferating, or differentiated

  probdivide ;float from 0 to 1, a cell will divide if rand is less than this value. imposed by applygradientchancedivide and can be influenced if cell is mutated.
  probdividegoal

  probdie ;float from 0 to 1, a cell will die if rand is less than this value. imposed by applygradientchancedie and can be influenced if cell is mutated.
  probdiegoal

  probdividecolor ;cell stores color reflecting its probability of division
  progenycolor ;cell stores color reflecting its progeny

  changespeeddiv; these are used for delayed feedback, stores the feedback of the current gradient
  changespeeddie

  mutantA ; JO & AX 110514
  mutantB ; JO & AX 110514

  myDivideDiff
  myDieDiff
]

to setup ; properly sizes the world, and populates it with the specified number of cells OBS ONLY

  let qdtemp QuiesceDepth; temporary variables store QuiesceDepth and RowsAtStart, which are sliders that have top as their maximum, so that the settings of these variables are not lost when top is set to 0 by clearall
  let rastemp RowsAtStart
  let ddetemp DieDepthEnd
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set CutOffAboveQuiescentRegion 5
  set top SetTop
  set RowsAtStart rastemp
  set QuiesceDepth qdtemp
  set DieDepthEnd ddetemp
  set-default-shape cells "circle"
  set CellsPerRow SetCellsPerRow
  resize-world -8 cellsPerRow + 7 0 top + 2 ; world is sized so that it fits around the crypt with four spaces of buffer to the left and right. two spaces of buffer are added to the top of the crypt.
; y coordinates move up from 0 at bottom of the world to top+2 at the top.
  set-patch-size 400 / top ; resizes world so that it will fit in the window space alotted, (Does not work in all cases, if crypt is too wide, world will overlap buttons)
  let x 0
  let y top
  while [y > top - RowsAtStart][
    set x 0
    while [x < cellsPerRow][;this section of code populates the crypt, placing a cell at every location in the crypt from the bottom to RowsAtStart, going row by row.
    makecell(.5)(.5)(x)(y) ;makecell creates cells at target location with starting values set.
    set x x + 1]
  set y y - 1]
   set keepgoing true
   set chemoct -1
   set preventct -1; Ax
   set colored false
 ;globals are set to their starting values.


;crypt is setup

 ask patches
 [
   ifelse pycor <= top
   [
     if (pxcor <= min-pxcor + 3) [set pcolor 0 set divgradient true]   ;patches in the divide gradient frame are determined and initially set to black
     if (pxcor >= max-pxcor - 3) [set pcolor 0 set diegradient true]   ;patches in the die gradient frame are determined and initially set to black
     if (pxcor > min-pxcor + 3) and (pxcor < max-pxcor - 3) [set pcolor 132  set divgradient false  set diegradient false]   ;patches in the crypt are colored light brown, patches in the gradient frame are set to black for now
   ]
   [set pcolor 0]  ;patches in top buffer above crypt are left black

 ]

;cells receive initial values and random colors

 ask cells
 [
   set probdivide probdividegoal
   set probdie probdiegoal
   set progenycolor random-float 140 ;each cell's progeny color is initially set to a random color
 ]



 set MONOCLONALCOMPLETE false

end

to go ; iterates the simulation OBS ONLY


; sound:play-note "APPLAUSE" 65 127 2, plays sound after mutant cells eliminated, with or without chemoprevention, Ax 112217

if CureSound = true and count cells with [mutantA = true] + count cells with [mutantB = true] > 0
     [set CureSound false]
if CureSound = false and count cells with [mutantA = true] + count cells with [mutantB = true] = 0
    [ set CureSound true sound:play-note "APPLAUSE" 65 127 2]


; two reasons why the simulation would need to stop, either the crypt overflows or the crypt dies, the rest of the simulation assumes neither of these occured.

  if count cells = 0 and keepgoing = true[set keepgoing false set ExtinctionTime ticks print (word "the crypt died at tick " ExtinctionTime)]; if there is less than one full row of cells, cell death and division stops, and the crypt is considdered dead.
  if count cells with [ycor = top + 2]> 0 and keepgoing = true [ set keepgoing false set UnboundedSizeTime ticks print (word "the crypt overflowed at tick" UnboundedSizeTime) ]
  if keepgoing = true[  ; keepgoing is set to false if the crypt dies or overflows, prevents simulation from continuing at that point.

; sets up highest (approx number of rows of cells)

  set highest round(count cells / cellsperrow); determines the approximate top of the crypt, estimated by the average height of the cell columns.


; sets up and applies gradient functions

  ; exponential gradient functions take arguments start height, end height, start value, end value
  ; and power. this scales the function y = x^(power) from zero to 1 so that the
  ; range is applied from start height to end height and so that the y value is proprtionally
  ; gradient values scaled to range between startvalue and endvalue.

  applygradientprobdivide(top)(top - highest)(cptdivmin)(cptdivmax)(cptdivpwr)(DivideFbk) ;feedbackdiv set to quiescefeed so that both could be modified in parallel in behavior space.
  applygradientprobdie(top - DieDepthEnd)(top)(cptdiemin)(cptdiemax)(cptdiepwr)(DieFbk) ;applies gradient that sets probdie of cells at every iteration
  applygradientprobdivide(0)(top - quiescedepth)(0)(0)(0)(QuiescentFbk) ;quiescent gradient applies to cell division.
  ask cells[set probdivide probdivide + (probdividegoal - probdivide) * changespeeddiv
      set probdie probdie + (probdiegoal - probdie) * changespeeddie ; gradients are applied to cells, cells are only affected by the last probdivide and probdie gradients, in order as in the code


; cell division and death occurs here, revised by DA 12/12/16 to include "set probdivide probdivide * ExtraVariableY"

if Circadian = true[
set ExtraVariableY 1.00591 + 0.143376 * cos (60 * ticks - 175.574) ; DA revised 012017
]
if Circadian = false[
  set ExtraVariableY 1
]
    let rand random-float 1
; generates a random floating point number from 0 to 1 for every comparison called rand
set probdivide probdivide * ExtraVariableY
    if rand < probdivide [
      hatch-cells 1
       makespace(self) ; if rand is less than the probdivide, the cell reproduces
      ]]
ask cells [    ; after cell proliferation is taken care of, all cells have a probability of dying.
    let rand random-float 1
    if rand < probdie [    ; if rand is less than probdie, the cell dies
      die
      ]]


; sets up and applies chemotherapy

if activechemo = true and chemoct = -1 [
 set chemoct 1
 set chemoRound 1
 set cryptRegRateAvg 0
 set cellLossAvg 0
 set cryptValleyAvg 0
 set compensateTimeAvg 0
 set timeToCure 0
 ]
if activechemo = true and chemoct <= duration [sound:play-note "Clarinet" 65 30 1]  ; AX 022316 add this line for sound, works
if activechemoP2 = true and preventct <= pduration [sound:play-note "Clarinet" 75 30 1]; Ax 110917 sound for Chemotherapy P2
if activechemo = false and chemoct > -1 [set chemoct -1] ; stops chemotherapy if activechemo is set to false

if activechemo = true[  ;VD 080717
  if count cells with [mutantA = true] > mutantThreshold[set timeToCure timeToCure + 1]]

if chemoRound = 1 and chemoct = 1 [set cellsLastRound count cells]

if chemoct = 1[
  set cryptValley count cells
  set valleyTime 0
  set peakTime 0]

if chemoct >= 1 [
  set tempTotal count cells

  if chemoct <= duration[
    ask cells[
      let rand random-float 1
      if rand / lethality < probdivide[
      die]
    ]
  ]

ifelse tempTotal <= cryptValley [set cryptValley tempTotal set valleyTime chemoct set cryptPeak cryptValley]
[if tempTotal > cryptPeak [set cryptPeak tempTotal set peakTime chemoct]]

ifelse chemoct = interval[
  set chemoct 1
  set cellGain cryptPeak - cryptValley
  set cellGainAvg (cellGain * (chemoRound - 1) + cellGain) / chemoRound
  set cellLoss cellsLastRound - cryptValley
  set cellLossAvg (cellLossAvg * (chemoRound - 1) + cellLoss) / chemoRound
  set cryptValleyAvg (cryptValleyAvg * (chemoRound - 1) + cryptValley) / chemoRound
  if peakTime != valleyTime [set cryptRegRate (cryptPeak - cryptValley) / (peakTime - valleyTime)]
  set cryptRegRateAvg (cryptRegRateAvg * (chemoRound - 1) + cryptRegRate) / chemoRound
  set compensateTime peakTime - valleyTime
  set compensateTimeAvg (compensateTimeAvg * (chemoRound - 1) + compensateTime) / chemoRound
  set chemoRound chemoRound + 1
  set cellsLastRound tempTotal] ;updates chemo round
  [set chemoct chemoct + 1]
]


    ; Ax, REVISE FROM HERE. sets up and applies chemoprevention, using "sets up and applies chemotherapy" as example. 2nd try.

  if ActiveChemoP2 = true and preventct = -1 [set preventct 0 ]; Ax, initates chemoprevention
  if ActiveChemoP2 = true and preventct < pduration and ptreatment > cptdiemax [ set cptdiemax ptreatment]
  if preventct >= pduration [set cptdiemax 0.2]
  if ActiveChemoP2 = false and preventct > -1 [set preventct  -1] ; Ax, stops chemoprevention if activepreventtreat is set to false
  if preventct >= 0 [
    if preventct < pduration [
      ask cells [
        let rand random-float 1
        if rand / ptreatment < probdivide [
          die]
        ]
      ]
   ifelse preventct = pinterval[set preventct 0]
   [set preventct preventct + 1]
  ]

  ; Result. Above seems to work. CptDieMax cycles between ptreatment value and cptdiemax = 0.2 when Apply Chemoprevention is ON.
  ; Semms to have reasonable pinterval times and pduration times.
  ; Crypt stable for ptreatment = 1.5, but not 1.6 and above. Goes extinct.
  ; See white (dead) cells flush out at top, periodically.

  shiftdown; keeps cell columns without gaps by forcing cells to move up if there is a space above them.


; colors cells

ask cells with [mutantA = false and mutantB = false]
[
  ifelse probdivide <= DiffCellProbabilityThreshold [set probdividecolor probdie / CptDieMax * 5 + 94]
    [set probdividecolor probdivide / CptDivMax * 9 + 11]

  ifelse viewprogeny = true [set color progenycolor][set color probdividecolor] ;depending on choice of view, sets cell color to progeny color or to color reflecting probability of division
]

ask cells with [mutantA = true][set color 45] ; changes color of mutantA cells to yellow so that they are easily visible. Yellow color is retained even if viewprogeny is true
ask cells with [mutantB = true][set color 65] ; changes color of mutantB cells to lime so that they are easily visible. Yellow color is retained even if viewprogeny is true


; sets up FissionTime reporter

  ifelse PolarDivision[
    set FissionTime 0][
    let emptycolumn false
    let x 0
    repeat CellsPerRow [
      if count cells with [xcor = x] = 0[
        set emptycolumn true]
      set x x + 1] ; iterates through all cell columns, seeing if any of them are empty
    if emptycolumn = false [
      set FissionTime FissionTime + 1]; if no empty column exists, fission time will continue to be incremented
  ]


; misc.

 ; do-plot ; plots cell populations at the end of each iteration.
 ; if AdjustTime > ticks and cryptsizeadjust = true [
 ;   adjustcptdiemax]  ; applies cryptsizeadjust if it is being used.


;sets celltype and counts number of cells of a given type

set CountSCq 0
set CountDiff 0
set CountProlif 0
set CountMutantA 0
set CountMutantB 0
set CountTotal 0

ask cells[
  if (ycor < top - quiescedepth + CutOffAboveQuiescentRegion) and (probdivide < DiffCellProbabilityThreshold) and (MutantA = false) and (MutantB = false)[
  set celltype "SCq"
  set CountSCq CountSCq + 1]

  if (ycor >= top - quiescedepth + CutOffAboveQuiescentRegion) and (probdivide < DiffCellProbabilityThreshold) and (MutantA = false) and (MutantB = false)[
  set celltype "Diff"
  set CountDiff CountDiff + 1]

  if (probdivide >= DiffCellProbabilityThreshold) and (MutantA = false)[
  set celltype "Prolif"
  set CountProlif CountProlif + 1]

  if MutantA = true[
  set celltype "MutantA"
  set CountMutantA CountMutantA + 1]

  if MutantB = true[
  set celltype "MutantB"
  set CountMutantB CountMutantB + 1]
]

set CountTotal CountSCq + CountDiff + CountProlif + CountMutantA + CountMutantB

if CountTotal > 0[
set PropSCq CountSCq / CountTotal
set PropProlif CountProlif / CountTotal
set PropDiff CountDiff / CountTotal]

ifelse ticks <= 1 or CountTotal = 0 [set PropSCqAvg PropSCq set PropProlifAvg PropProlif set PropDiffAvg PropDiff][
  set PropSCqAvg (PropSCqAvg * (ticks - 1) + PropSCq) / ticks
  set PropProlifAvg (PropProlifAvg * (ticks - 1) + PropProlif) / ticks
  set PropDiffAvg (PropDiffAvg * (ticks - 1) + PropDiff) / ticks]

;calls plotting function

do-plot ; plots cell populations at the end of each iteration.
if AdjustTime > ticks and cryptsizeadjust = true [
   adjustcptdiemax]  ; applies cryptsizeadjust if it is being used.


;determines whether or not monoclonal conversion has been achieved and if so at what tick

if CountTotal = 0 [set ExtinctionTime ticks]

if CountTotal > 0[
  let testcolor 0
  ask one-of cells [set testcolor progenycolor]
  if MONOCLONALCOMPLETE = false[
    set MONOCLONALCOMPLETE true
    ask cells [if progenycolor != testcolor [set MONOCLONALCOMPLETE false]]

  if MONOCLONALCOMPLETE = true [set monoclonaltime ticks]
]
]

  ]
     tick; view is updated at every tick

end

to makecell[setprobdivide setprobdie x y];places a cell with specified parameters at the specified x y coordinates, called by setup, OBS ONLY

  create-cells 1 [
    setxy x y
    set probdivide setprobdivide; setprobdivide and setprobdie are specified at the method call.
    set probdie setprobdie ; if cell falls within gradient limits, these values will be overwritten by gradient
    ; set mutant false
    set mutantA false ; JO & Ax 110514
    set mutantB false ; JO & Ax 110514
    set color 9.9
    ]
end


; duplicated "mutaterows" to "mutaterowsA" and "mutaterowsB" JO & Ax 110514
to mutaterowsA;turns proportion cells between rows startH and endH mutant, startH and endH counting from bottom of crypt

  if startD > endD [let temp startD
    set startD endD
    set endD temp]
  ask cells with [top - ycor >= startD and top - ycor <= endD][
    let rand random-float 1
   ; if rand < proportion[
      if rand < proportionA[ ; JO & Ax 111214
     ; set mutant true
       set mutantA true]]
end

to mutaterowsB;turns proportion cells between rows startH and endH mutant, startH and endH counting from bottom of crypt

  if startD > endD [let temp startD
    set startD endD
    set endD temp]
  ask cells with [top - ycor >= startD and top - ycor <= endD][
    let rand random-float 1
    ;if rand < proportion[
      if rand < proportionB[
     ; set mutant true
       set mutantB true]]
end

to makespace[celltomove]; forces cells out of the way to make room for a newly generated cell
  let currx [xcor] of celltomove
  let curry [ycor] of celltomove
  let nextx 0
  ifelse polardivision [
    set nextx random 2 + 1 + currx]
  [set nextx random 3 - 1 + currx]; depending on whether or not divdirrand is on, cells will either move preferentially to the right, or move down with no right-left preference.
  let nexty curry - 1
  if nextx < 0 [
    set nextx CellsperRow + nextx]
  if nextx >= CellsperRow [
    set nextx nextx - CellsperRow]
  let nextcell one-of cells with [xcor = nextx and ycor = nexty]
  ask celltomove[
    setxy nextx nexty
    while [count turtles-at 0 1 = 0 and ycor != top][setxy xcor ycor + 1]]
  if nextcell != nobody [
    makespace(nextcell)]
end

to shiftdown ;forces all cells up in columns so there are no gaps in the crypt.
  let y top - 1
  while [y >= 0][; goes from the top of the world to the bottom.
  ask cells with [ycor = y and count cells-at 0 1 = 0][; gets all cells with an empty space above them in a particular row,
    let movedown 0
  while[count cells-at 0 (movedown + 1) = 0 and y + movedown <= top - 1][
    set movedown movedown + 1] ; finds the highest space above the cell that does not contain a cell.
    setxy xcor ycor + movedown ] ; moves the cell to this location
  set y y - 1]
end

to do-plot ; parameters used in conjunction with plots, called by Go function at the end of each iteration, does not affect simulation itself.
  set-current-plot "Total Cells"
  set-current-plot-pen "cellspen"
  plot CountTotal
   set-current-plot "Quiescent Stem Cells"
  set-current-plot-pen "CountQuiescentpen"
  plot CountSCq
  set-current-plot "Proliferating Cells"
  set-current-plot-pen "CountProliferatingPen"
  plot CountProlif
  set-current-plot "Differentiated Cells"
  set-current-plot-pen "CountDifPen"
  plot CountDiff
  ; set-current-plot "Proportion Mutant Cells"
  ; set-current-plot-pen "PropMuts"
  ; if count cells > 0 [plot count cells with [mutant = true]/ count cells] ; Proportion Mutant cells diplays number of mutant cells divided by total number of cells.
  ; JO & AX 110514
set-current-plot "Proportion MutantA Cells" ; JO & Ax 111214, and following lines. Make new plot boxes.
  set-current-plot-pen "PropMutsA"
  if count cells > 0 [plot count cells with [mutantA = true]/ count cells] ; Proportion Mutant cells diplays number of mutant cells divided by total number of cells.
set-current-plot "Proportion MutantB Cells"
  set-current-plot-pen "PropMutsB"
  if count cells > 0 [plot count cells with [mutantB = true]/ count cells] ; Proportion Mutant cells diplays number of mutant cells divided by total number of cells.
; NOTE: will need to make 2 boxes for "Proportion MutantA Cells"
set-current-plot "Chemotherapy" ; Ax 031317 from Ax 022316, to add Chemotherapy plot that indicates Lethality as function of time, with Interval, Duration, and Lethality inputs
   set-current-plot-pen "lethality"
   set-plot-pen-color 14
  if activechemo = true and chemoct > duration [plot 1] ; in order to see chemoplot for lethality = 1, temporarily need to revise default [plot 1] to [plot 0.5] and interface x max from 3 to 2
  if activechemo = true and chemoct < duration  [plot lethality]
;set-current-plot "Chemoprevention" ;Ax 031317, to add Chemoprevention plot that indicates PTreatment as function of time, with PInterval, PDuration, and Ptreatment inputs
;   set-current-plot-pen "PTreatment"
;   set-plot-pen-color 64
;  if activepreventtreat = true and preventct > duration [plot 0.2]
;  if activepreventtreat = true and preventct < duration  [plot ptreatment]
set-current-plot "Chemotherapy P2" ; Ax 050617, changed from "Chemoprevention" to "Chemotherapy 2"
   set-current-plot-pen "PTreatment"
   set-plot-pen-color 64
  if ActiveChemoP2 = true and preventct > duration [plot 0.2]
  if ActiveChemoP2 = true and preventct < duration  [plot ptreatment]

end


;The following two reporters work with the gradient functions immediately after

to-report getgradientprobdiv
  report gradientprobdiv
end

to-report getgradientprobdie
  report gradientprobdie
end

; The following code creates a gradient effect over the area, startval and endval must be between 0 and 1, startpoint and endpoint must be between the
; beginning and end of the model. note, the variable that the gradient affects cannot be stated as a parameter for the function, so the
; function had to be duplicated to affect probdivide and probdie.


to applygradientprobdivide [starty endy startval endval power feedback] ; gradient that applies to probdivide of all cells between startval and endval.
  if starty != endy [
  if power < 0[ ; the function used here is x^n, where x is from 0 to 1. the value of x ranges between 0 and 1 regardless of the value of n,
    let temp endy
    set endy starty
    set starty temp
    set temp endval
    set endval startval
    set startval temp] ; this bit of code reverses variables so that negative powers cause the graph's inflection to bow outward from 0 to 1.
  let range starty - endy ; graph originally goes from 0 to 1, but is scaled by range and set to go from starty to endy.
  let shift startval - endval ; similarly, in x^n from 0 to 1, the value of x goes from 0 to 1, but is scaled by shift and set to go from startval to endval
  let y starty
  let counter 0
  ;if gradientdivcalculated = false[
  while[counter <= abs(range)][
    ask patches with[(pycor = y) and (divgradient = true)][   ;patches in the divide gradient frame determine the divide gradient at this y
      ifelse shift > 0
      [set gradientprobdiv (- abs((pycor - starty) / range)^ abs(power)) * abs(shift) + startval]
      [set gradientprobdiv abs((pycor - starty) / range)^ abs(power) * abs(shift) + startval]; positive scaled graph x^n is applied here

      ifelse shift > 0
      [set gradientprobdivcolor 61 + 7 * (- abs((pycor - starty) / range)^ abs(power)) * abs(shift) + startval] ; to apply negative gradient, scaled graph x^n is inverted
      [set gradientprobdivcolor 61 + 7 * abs((pycor - starty) / range)^ abs(power) * abs(shift) + startval] ;pcolor is affected rather than probdivide and probdie.
    ]

    ask cells with[ycor = y][
      set probdividegoal [getgradientprobdiv] of patch min-pxcor y
      if mutantA = true[set probdividegoal probdividegoal + mutantAdividediff]
      if mutantB = true[set probdividegoal probdividegoal + mutantBdividediff]
      set changespeeddiv feedback
    ]

    ifelse range < 0[set y y + 1][set y y - 1]
    set counter counter + 1
  ]

  ifelse showgradients = true
  [ask patches with [divgradient = true][set pcolor gradientprobdivcolor]]
  [ask patches with [divgradient = true][set pcolor 0]]

]

end

to applygradientprobdie [starty endy startval endval power feedback] ; a duplicate of applygradientprobdivide, only it affects probdie.
  if starty != endy [
  if power < 0[
    let temp endy
    set endy starty
    set starty temp
    set temp endval
    set endval startval
    set startval temp]
  let range starty - endy
  let shift startval - endval
  let y starty
  let counter 0
  while[counter <= abs(range)][
    ask patches with[(pycor = y) and (diegradient = true)][   ;patches in the die gradient frame determine the die gradient at this y
      ifelse shift > 0
      [set gradientprobdie (- abs((pycor - starty) / range)^ abs(power)) * abs(shift) + startval]
      [set gradientprobdie abs((pycor - starty) / range)^ abs(power) * abs(shift) + startval]; positive scaled graph x^n is applied here

      ifelse shift > 0
      [set gradientprobdiecolor 12 + 7 * (- abs((pycor - starty) / range)^ abs(power)) * abs(shift) + startval] ; to apply negative gradient, scaled graph x^n is inverted
      [set gradientprobdiecolor 12 + 7 * abs((pycor - starty) / range)^ abs(power) * abs(shift) + startval] ;pcolor is affected rather than probdivide and probdie.
    ]

    ask cells with[ycor = y][
      set probdiegoal [getgradientprobdie] of patch max-pxcor y
      if mutantA = true[set probdiegoal probdiegoal + mutantAdiediff]
      if mutantB = true[set probdiegoal probdiegoal + mutantBdiediff]
      set changespeeddie feedback
    ]

    ifelse range < 0[set y y + 1][set y y - 1]
    set counter counter + 1
  ]

  ifelse showgradients = true
  [ask patches with [diegradient = true][set pcolor gradientprobdiecolor]]
  [ask patches with [diegradient = true][set pcolor 0]]

]

end


to defaults ; sets defaults for all variables modifyable in main interface, see information for justifications for values.
   set Settop 100
   set RowsAtStart 61; gets crypt into a steady state position as quickly as possible.
   set setcellsperrow 38; simulates approximate number of cells to produce proper crypt diameter if wrapped into a cylinder
   set quiescedepth 60; produces the proper number of cell rows
   set CptDivMin 0; cells will not divide towards the top of the crypt
   set CptDivMax .5; gives cells a high probability of dividing near the bottom of the crypt, so that feedback has greater effect
   set CptDivPwr 11.5; keeps cell division happening only near the bottom of the crypt.
   set CptDieMin 0; cells near the bottom of the crypt have almost zero probability of dividing, with cell removal only happening near the top
   set CptDieMax .2; this kills off cells at the proper rate to keep a steady crypt with the right proportions of cells.
   set CptDiePwr 14; keeps cell death only happening towards the extremem top of the crypt.
   set DieDepthEnd 100; die gradient speads over the entire area of the crypt.
   set DiffCellProbabilityThreshold .02; this value only changes the classification of cells in the crypt, and was adjusted to get proper cell proportions.
   ; set mutantdividediff .16; makes mutant cells divide more quickly, one of the hallmarks of mutation leading to cancer.
   ; set mutantdiediff .1; makes mutant cells more likely to die, also typically occurs with early mutant cells (less stability than normal cells.)
   ; JO & Ax 110514

   set mutantAdividediff .16; makes mutant cells divide more quickly, one of the hallmarks of mutation leading to cancer.
   set mutantAdiediff .1; makes mutant cells more likely to die, also typically occurs with early mutant cells (less stability than normal cells.)set MutateDepth 59
   set mutantBdividediff .16; makes mutant cells divide more quickly, one of the hallmarks of mutation leading to cancer.
   set mutantBdiediff .1; makes mutant cells more likely to die, also typically occurs with early mutant cells (less stability than normal cells.)
   set mutantThreshold 0 ;sets acceptable number of mutants to 0

   set showgradients false; increases running speed.
   set Lethality 2; adjusted to this value to be more effective at killing off cells, since the crypt is more robust.
   set ptreatment 0.2 ; Ax, same initial value as initial CptDieMax
   set activechemo false
   set ActiveChemoP2 false
   ; if activepreventtreat true [CptDieMax ptreatment] ; Ax, is this necessary?
   set interval 24
   set pinterval 24 ; Ax
   set duration 3
   set pduration 3 ; Ax
   set startD 55; ensures mutant cells begin in the quiescent region
   set PolarDivision true
   set endD 60
   ; set proportion .2 ; JO & Ax 111214
   set proportionA .2
   set proportionB .2
   set cryptsizeadjust false; activate if modifying other variables to keep crypt at proper size
   set AdjustTime 1000
   set CellTarget 2428; approx. number of cells in actual crypt, as observed experimentally.
   set AdjustStr .1
   set DivideFbk .5; values set to produce cell proportions most similar to those observed.
   set DieFbk .5
   set QuiescentFbk .1
   set Circadian false ; Ax 112216
   set showgradients false;
   set viewprogeny false;
   ; set CureSound false; Ax 112117
   set CureSound true ; Ax 112217

end

to mutateonecell ; randomly sets a cell in the given row to mutate.
  ; JO & Ax 110514 ; will mutate one cell of A and one cell of B, simultaneously
  ; ifelse count cells with [ycor = top - mutatedepth and mutant = false] > 0[
  ; ask one-of cells with [ycor = top - mutatedepth and mutant = false] [set mutant true]][
  ; print "no elligible cells in the chosen row"]

  ifelse count cells with [ycor = top - mutatedepth and mutantA = false] > 0[
  ask one-of cells with [ycor = top - mutatedepth and mutantA = false] [set mutantA true]][
  print "no elligible cells in the chosen row"]

end

to adjustCptDieMax; method is called by CryptSizeAdjust to attempt to set the size of the crypt to the requested value
  set CptDieMax CptDieMax + (count turtles - Celltarget)/ Celltarget * (AdjustTime - ticks) / (AdjustTime) * AdjustStr
  if CptDieMax < 0 [set CptDieMax 0]
  if CptDieMax > 1 [set CptDieMax 1]
end
