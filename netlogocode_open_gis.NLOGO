;References: https://github.com/tonysdatamodels/netlogo_gis_extension/blob/main/netlogocode_open_gis.NLOGO
Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

;Personalise all code for your own project

;GIS extenstion for netlogo
Extensions [gis]

;Globals used for my model 
globals [tollymore-forest-dataset
         tollymore-farms-dataset]

;Turtle variables for each landscape type 
breed [wolfs wolf]
breed [sheeps sheep]

;Patches variables for each landacape type 
patches-own [is-forest
             is-farm]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Resize world based on outer limits of .asc file extracted from GIS
to setup-gis-map
  resize-world 0 135 0 151

  ;Setup the first section of the world which includes the forest
  set tollymore-forest-dataset gis:load-dataset "your/file/path/file.asc"

  ;Setup second section of the world which includes the farms
   set tollymore-farms-dataset gis:load-dataset "your/file/path/file.asc"
   
  ;Set the world envelope to match that of the asc files extracted from GIS
  gis:set-world-envelope (gis:envelope-of tollymore-farms-dataset)

  ;Determine variables of your patches and make these match you asc files. (e.g is-forest, is-farm are "patches-own" variables)
  gis:apply-raster tollymore-forest-dataset is-forest
  gis:apply-raster tollymore-farms-dataset is-farm

  ;Set overall background colour as green
  ask patches [set pcolor green]

  ;Ask forests to be brown
  ask patches with [is-forest = 1][set pcolor brown - 1]

  ;Ask livestock farms to be green
  ask patches with [is-farm = 1][set pcolor green + 3]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Code used to setup wolf population in forest
to setup-wolf
  create-wolfs wolf-population
     [set shape "wolf"
      set color black
      move-to one-of patches with [pcolor = brown - 1]]
end

;Code used to setup sheep population on farms
to setup-sheep
  create-sheeps sheep-population
     [set shape "sheep"
      set color white
      move-to one-of patches with [pcolor = green + 3]]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Code used to reset model
to reset
  print "resetting  model"
  clear-all
  reset-ticks
  clear-patches
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
