;;Extensions
extensions [ r ]

;;Globals
globals [
  climate
  survival-cost
  lifetime-offspring
  age-at-death
  reporter-lifetime-offspring
  reporter-age-at-death
  reporter-population
  reporter-age
  reporter-energy
  reporter-waste-prob
  reporter-waste-rate
  reporter-repro-prob
]

;;Owns
turtles-own
[
  energy
  age
  waste-prob
  waste-rate
  repro-prob
  babies
]

patches-own
[
  start-resources
  resources
]

;; Setup
to setup
  clear-all
  setup-patches
  setup-turtles
  setup-climate
  setup-globals
  reset-ticks
end

to setup-patches
  ask patches
  [
    set start-resources random max-resources
    set resources start-resources
    set pcolor scale-color grey resources 0 max-resources
  ]
end

to setup-turtles
  create-turtles initial-num-agents
  [
    set shape "person"
    set energy start-energy
    setxy random-xcor random-ycor
    set color yellow
    set age 1
    set waste-prob random-float 1
    set waste-rate random-float 1
    set repro-prob random-float 1
  ]
end

to setup-climate
  r:put "climateAR" climateAR
  r:put "climateSD" climateSD
  r:put "nticks" nticks
  set climate r:get "arima.sim(list(ar=climateAR),n=nticks,sd=climateSD)"
end

to setup-globals
  set survival-cost move-cost + consume-cost
  set age-at-death []
  set lifetime-offspring []
  set reporter-lifetime-offspring []
  set reporter-age-at-death []
  set reporter-population []
  set reporter-age []
  set reporter-energy []
  set reporter-waste-prob []
  set reporter-waste-rate []
  set reporter-repro-prob []
end

;;Go
to go
  if not any? turtles [
    export-reports
    stop
  ]
  if ticks = nticks [
    if export_res [
      export-reports
    ]
    stop
  ]
  gather-reports
  reset-globals
  if ClimateChange [ climate-change ]
  grow-patches
  gather-turtles
  consume-turtles
  move-turtles
  if Waste [ waste-turtles ]
  ifelse MaxRepro [ reproduce-turtles-max ] [ reproduce-turtles-rand ]
  death
  if Decay [ decay-energy ]
  age-turtles
  tick
end

;;Procedures
;;Agents
to move-turtles
  ask turtles [
    if energy >= move-cost [
      right random 360
      forward 1
      set energy energy - move-cost
    ]
  ]
end

to consume-turtles
  ask turtles [
    if energy >= consume-cost [
      set energy energy - consume-cost
    ]
  ]
end

to gather-turtles
  ask turtles [
    if resources > 0 [
      let gather-amount resources * gather-rate
      set resources resources - gather-amount
      set energy energy + gather-amount
      set pcolor scale-color grey resources 0 max-resources
    ]
  ]
end

to waste-turtles
  ask turtles [
    if random-float 1 <= waste-prob and energy > 1 [
      let surplus energy - 1
      set energy ifelse-value WasteRate [ ( 1 - waste-rate ) * surplus ] [ surplus ]
    ]
  ]
end

to reproduce-turtles-max
  ask turtles [
    if energy >= repro-cost [
      set energy energy - repro-cost
      set babies babies + 1
      hatch 1 [
        set age 0
        set babies 0
        set energy start-energy
        set waste-prob random-normal waste-prob waste-drift
        if waste-prob > 1 [
          set waste-prob 1
        ]
        if waste-prob < 0 [
          set waste-prob 0
        ]
        set waste-rate random-normal waste-rate waste-rate-drift
        if waste-rate > 1 [
          set waste-rate 1
        ]
        if waste-rate < 0 [
          set waste-rate 0
        ]
      ]
    ]
  ]
end

to reproduce-turtles-rand
  ask turtles [
    if random-float 1 <= repro-prob and energy >= repro-cost [
      set energy energy - repro-cost
      set babies babies + 1
      hatch 1 [
        set age 0
        set babies 0
        set energy start-energy
        set repro-prob random-normal repro-prob repro-drift
        if repro-prob > 1 [
          set repro-prob 1
        ]
        if repro-prob < 0 [
          set repro-prob 0
        ]
        set waste-prob random-normal waste-prob waste-drift
        if waste-prob > 1 [
          set waste-prob 1
        ]
        if waste-prob < 0 [
          set waste-prob 0
        ]
        set waste-rate random-normal waste-rate waste-rate-drift
        if waste-rate > 1 [
          set waste-rate 1
        ]
        if waste-rate < 0 [
          set waste-rate 0
        ]
      ]
    ]
  ]
end

to age-turtles
  ask turtles [
    set age age + 1
  ]
end

to decay-energy
  ask turtles [
    if energy > 0 [
      set energy energy * ( 1 - decay-rate )
    ]
  ]
end

to death
  ask turtles [
    if energy < 1 or age >= max-age [
      set age-at-death lput age age-at-death
      set lifetime-offspring lput babies lifetime-offspring
      die
    ]
  ]
end

;;Patches
to climate-change
  if ClimateChange [
    ask patches [
      set resources resources + item ticks climate
      if resources < 0 [
        set resources 0
      ]
    ]
  ]
end

to grow-patches
  ask patches [
    if resources < start-resources [
      set resources resources + regrowth
      if resources > start-resources [
        set resources start-resources
      ]
    ]
  ]
end

;;reporters
to gather-reports
  set reporter-population lput count turtles reporter-population
  set reporter-lifetime-offspring lput lifetime-offspring reporter-lifetime-offspring
  set reporter-age-at-death lput age-at-death reporter-age-at-death
  set reporter-age lput [age] of turtles reporter-age
  set reporter-energy lput [energy] of turtles reporter-energy
  set reporter-waste-prob lput [waste-prob] of turtles reporter-waste-prob
  set reporter-waste-rate lput [waste-rate] of turtles reporter-waste-rate
  set reporter-repro-prob lput [repro-prob] of turtles reporter-repro-prob
end

to export-reports
  r:put "expname" ExperimentName
  r:eval "f <- paste(expname,gsub(':','-',Sys.time()[1]),sep='_')"
  r:put "outpath" output_path
  r:put "reporter_population" reporter-population
  r:put "reporter_lifetime_offspring" reporter-lifetime-offspring
  r:put "reporter_age_at_death" reporter-age-at-death
  r:put "reporter_age" reporter-age
  r:put "reporter_energy" reporter-energy
  r:put "reporter_waste_prob" reporter-waste-prob
  r:put "reporter_waste_rate" reporter-waste-rate
  r:put "reporter_repro_prob" reporter-repro-prob
  r:put "climate" climate
  r:eval "save.image(file=paste(outpath,f,'.RData',sep=''))"
  r:clear
  r:gc
end

to reset-globals
  set age-at-death []
  set lifetime-offspring []
end
@#$#@#$#@
GRAPHICS-WINDOW
584
10
1021
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
7
10
73
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
74
10
137
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
6
189
120
249
initial-num-agents
1000.0
1
0
Number

INPUTBOX
7
890
122
950
max-resources
100.0
1
0
Number

INPUTBOX
121
251
238
311
start-energy
2.0
1
0
Number

PLOT
257
10
581
160
Population Size
Ticks
Population
0.0
10.0
0.0
1000.0
true
false
"" ""
PENS
"Agents" 1.0 0 -14070903 true "" "plot count turtles"

INPUTBOX
124
890
239
950
regrowth
10.0
1
0
Number

PLOT
257
161
581
311
Energy
Ticks
Mean Energy
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"Energy" 1.0 1 -14730904 true "" "histogram [energy] of turtles"

INPUTBOX
121
189
238
249
gather-rate
0.2
1
0
Number

INPUTBOX
7
573
124
633
waste-drift
0.1
1
0
Number

PLOT
257
464
581
614
Waste Probability
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"Agents" 0.1 1 -16777216 true "" "histogram [waste-prob] of turtles"

PLOT
257
312
581
462
Age
NIL
NIL
1.0
10.0
0.0
10.0
true
false
"set-plot-x-range 1 max-age" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [age] of turtles"

TEXTBOX
6
172
156
190
Agent Initialization
11
0.0
1

TEXTBOX
7
873
157
891
Environment Initialization
11
0.0
1

INPUTBOX
7
952
122
1012
climateAR
0.0
1
0
Number

INPUTBOX
124
952
239
1012
climateSD
5.0
1
0
Number

INPUTBOX
139
10
237
70
nticks
1000.0
1
0
Number

PLOT
585
454
1021
604
Climate
Ticks
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot item ticks climate "

SWITCH
7
1016
239
1049
ClimateChange
ClimateChange
0
1
-1000

PLOT
585
607
1021
757
Mean Probabilities
Ticks
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Waste" 1.0 0 -16777216 true "" "plot mean [waste-prob] of turtles"
"Repro" 1.0 0 -13345367 true "" "plot mean [repro-prob] of turtles"
"WasteRate" 1.0 0 -2674135 true "" "plot mean [waste-rate] of turtles"

INPUTBOX
7
678
124
738
decay-rate
1.0
1
0
Number

SWITCH
7
642
124
675
Decay
Decay
0
1
-1000

INPUTBOX
121
313
238
373
repro-cost
5.0
1
0
Number

INPUTBOX
6
313
120
373
consume-cost
1.0
1
0
Number

SWITCH
7
538
124
571
Waste
Waste
0
1
-1000

TEXTBOX
7
512
157
530
Dynamics
11
0.0
1

INPUTBOX
6
373
120
433
move-cost
1.0
1
0
Number

MONITOR
6
434
120
479
survival cost
consume-cost + move-cost
2
1
11

PLOT
584
768
908
918
Age at Death
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Age at Death" 1.0 0 -16777216 true "" "plot mean age-at-death"

PLOT
584
920
908
1070
Lifetime Offspring
NIL
NIL
0.0
10.0
0.0
3.0
true
false
"" ""
PENS
"Offspring" 1.0 0 -16777216 true "" "plot mean lifetime-offspring"

PLOT
257
616
581
766
Waste Rate
NIL
NIL
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" "histogram [waste-rate] of turtles"

SWITCH
125
538
251
571
WasteRate
WasteRate
0
1
-1000

INPUTBOX
126
573
251
633
waste-rate-drift
0.1
1
0
Number

SWITCH
126
642
251
675
MaxRepro
MaxRepro
0
1
-1000

INPUTBOX
126
678
251
738
repro-drift
0.1
1
0
Number

PLOT
257
768
581
918
Reproduction Probability
NIL
NIL
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"ReproProb" 0.1 1 -16777216 true "" "histogram [repro-prob] of turtles"

INPUTBOX
6
251
120
311
max-age
25.0
1
0
Number

INPUTBOX
6
111
236
171
ExperimentName
exp9
1
0
String

SWITCH
7
44
132
77
export_res
export_res
0
1
-1000

INPUTBOX
7
1053
425
1113
output_path
/PATH/TO/OUTPUT/FOLDER/
1
0
String

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="climateSD">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp1&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="climateSD">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp2&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="climateSD">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp3&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment4" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="climateSD">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp4&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment5" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp5&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment6" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp6&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment7" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp7&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment8" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp8&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment9" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="move-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrowth">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Decay">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ClimateChange">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxRepro">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Trade">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-age">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gather-rate">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="WasteRate">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-energy">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;exp9&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-rate-drift">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
