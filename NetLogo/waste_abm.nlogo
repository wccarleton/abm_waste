;;Extensions
extensions [ r ]

;;Globals
globals [
  climate
  agent-waste-prob
  agent-age-at-death
  agent-lifetime-adult-offspring
  agent-avg-lifetime-waste
  agent-birth-tick
  agent-neutral
  pop-age-at-death
  pop-census
  pop-age
  pop-waste-prob
  pop-neutral
]

;;Owns
turtles-own
[
  energy
  age
  birth-tick
  waste-prob
  neutral
  parent
  juv-offspring
  adult-offspring
  offspring
  n-offspring
  prov-strategy
  provisioned
  prov-dist
  prov-temp
  wasted
  lifetime-waste
  gathered
]

;; Setup
to setup
  clear-all
  setup-turtles
  setup-climate
  setup-globals
  reset-ticks
end

to setup-turtles
  create-turtles initial-num-agents
  [
    set shape "person"
    set birth-tick 0
    set energy 0
    set color yellow
    set age mature
    set waste-prob random-float 1
    set neutral random-float 1
    set lifetime-waste [0]
    set parent -1
    set juv-offspring 0
    set adult-offspring 0
    set offspring turtles with [parent = [who] of myself]
    if provision = "1"[
      set prov-strategy 1
    ]
    if provision = "2"[
      set prov-strategy 2
    ]
    if provision = "3"[
      set prov-strategy 3
    ]
    if provision = "4"[
      set prov-strategy 4
    ]
    if provision = "R"[
      set prov-strategy one-of [1 2 3 4]
    ]
  ]
end

to setup-climate
  r:put "climateAR" climateAR
  r:put "climateSD" climateSD
  r:put "nticks" nticks
  set climate r:get "arima.sim(list(ar=climateAR),mean=0,n=nticks,sd=climateSD)"
end

to setup-globals
  set agent-age-at-death []
  set agent-waste-prob []
  set agent-avg-lifetime-waste []
  set agent-lifetime-adult-offspring []
  set agent-birth-tick []
  set agent-neutral []
  set pop-census []
  set pop-age []
  set pop-waste-prob []
  set pop-neutral []
end

;;Go
to go
  tick
  if not any? turtles [
    if export-res [ ExportReports ]
    stop
  ]
  if ticks = nticks [
    ask turtles [
      ReportDeath
    ]
    if export-res [
      ExportReports
    ]
    stop
  ]
  ToAge
  TrackOffspring
  GatherReports
  ifelse climate-change [ GatherClimateChange ] [ GatherStable ]
  if waste [ ToWaste ]
  Reproduce
  ZeroEnergy
end

;;Procedures
;;Agents
to TrackOffspring
  ask turtles [
    set offspring turtles with [parent = [who] of myself]
    set juv-offspring count offspring with [age < mature]
    set adult-offspring count offspring with [age >= mature]
  ]
end

to ToProvision
    if energy > 0 [
      let provisioncost ( consume-amount * juv-offspring )
      if energy >= provisioncost [
        set provisioned provisioncost
        ask offspring with [age < mature] [
          set energy energy + ( [provisioned] of myself / [juv-offspring] of myself )
        ]
      ]
      if energy < provisioncost [
        set provisioned energy
        ;;even distribution of available energy
        if prov-strategy = 1 [
          ask offspring with [age < mature] [
            set energy energy + ( [provisioned] of myself / [juv-offspring] of myself )
          ]
        ]
        ;;randomly order the kids and provide energy beginning with first
        if prov-strategy = 2 [
          set prov-temp provisioned
          let offspring_rand [who] of offspring with [age < mature]
          foreach offspring_rand [ x ->
            if prov-temp >= consume-amount [
              set prov-temp prov-temp - consume-amount
              ask turtle x [
                set energy energy + consume-amount
              ]
            ]
            if prov-temp < consume-amount [
              ask turtle x [
                set energy energy + prov-temp
              ]
              set prov-temp 0
            ]
          ]
        ]
        ;;favour eldest offspring
        if prov-strategy = 3 [
          set prov-temp provisioned
          let offspring_age sort-on [(- age)] offspring with [age < mature]
          foreach offspring_age [ x ->
            if prov-temp >= consume-amount [
              set prov-temp prov-temp - consume-amount
              ask x [
                set energy energy + consume-amount
              ]
            ]
            if prov-temp < consume-amount [
              ask x [
                set energy energy + prov-temp
              ]
              set prov-temp 0
            ]
          ]
        ]
        ;;favour youngest (last born)
        if prov-strategy = 4 [
          set prov-temp provisioned
          let offspring_age sort-on [age] offspring with [age < mature]
          foreach offspring_age [ x ->
            if prov-temp >= consume-amount [
              set prov-temp prov-temp - consume-amount
              ask x [
                set energy energy + consume-amount
              ]
            ]
            if prov-temp < consume-amount [
              ask x [
                set energy energy + prov-temp
              ]
              set prov-temp 0
            ]
          ]
        ]
      ]
      set energy energy - provisioned
    ]
end

to Consume
  if energy < consume-amount [
    ReportDeath
    if juv-offspring > 0 [
      ask offspring with [age < mature][
        ReportDeath
        die
      ]
    ]
    die
  ]
  if energy >= consume-amount [
    set energy (energy - consume-amount)
  ]
end

to GatherClimateChange
  ask turtles with [age >= mature] [
    let climate-mod 1 + ( item ticks climate )
    let capacity ( base-agents / (count turtles) )
    let gather-amount capacity * abs ( climate-mod )
    set energy energy + gather-amount
    Consume
    if juv-offspring > 0 [
      ToProvision
      ask offspring with [age < mature] [
        Consume
      ]
    ]
  ]
end

to GatherStable
  ask turtles with [age >= mature] [
    let capacity ( base-agents / (count turtles) )
    let gather-amount capacity
    set energy energy + gather-amount
    set gathered gather-amount
    Consume
    if juv-offspring > 0 [
      ToProvision
      ask offspring with [age < mature] [
        Consume
      ]
    ]
  ]
end

to ToWaste
  ask turtles [
    if random-float 1 < waste-prob and energy > 0 [
      set wasted energy
      set energy 0
      set lifetime-waste lput wasted lifetime-waste
    ]
  ]
end

to Reproduce
  ask turtles [
    if energy >= repro-cost [
      set energy energy - repro-cost
      set n-offspring n-offspring + 1
      hatch 1 [
        set parent [who] of myself
        set age 0
        set birth-tick ticks
        set offspring []
        set n-offspring 0
        set adult-offspring 0
        set juv-offspring 0
        set energy 0
        set wasted 0
        set lifetime-waste [0]
        set provisioned 0
        set waste-prob random-normal waste-prob waste-mutate
        if waste-prob > 1 [
          let waste_diff ( waste-prob - 1 )
          set waste-prob ( 1 - waste_diff )
        ]
        if waste-prob < 0 [
          set waste-prob abs waste-prob
        ]
        set neutral random-normal neutral waste-mutate
        if neutral > 1 [
          let neutral_diff ( neutral - 1 )
          set neutral ( 1 - neutral_diff )
        ]
        if neutral < 0 [
          set neutral abs neutral
        ]
      ]
    ]
  ]
end

to ToAge
  ask turtles [
    set age age + 1
  ]
end

to ZeroEnergy
  ask turtles [
    set energy 0
  ]
end

to ReportDeath
  set agent-age-at-death lput age agent-age-at-death
  set agent-waste-prob lput waste-prob agent-waste-prob
  set agent-avg-lifetime-waste lput mean lifetime-waste agent-avg-lifetime-waste
  set agent-lifetime-adult-offspring lput adult-offspring agent-lifetime-adult-offspring
  set agent-neutral lput neutral agent-neutral
  set agent-birth-tick lput birth-tick agent-birth-tick
end

;;reporters
to GatherReports
  set pop-census lput count turtles pop-census
  set pop-age lput [age] of turtles pop-age
  set pop-waste-prob lput [waste-prob] of turtles pop-waste-prob
  set pop-neutral lput [neutral] of turtles pop-neutral
end

to ExportReports
  r:put "expname" ExperimentName
  r:eval "f <- paste(expname,gsub(':','-',Sys.time()[1]),sep='_')"
  r:put "outpath" output_path
  r:put "agent_waste_prob" agent-waste-prob
  r:put "agent_neutral" agent-neutral
  r:put "agent_avg_lifetime_waste" agent-avg-lifetime-waste
  r:put "agent_age_at_death" agent-age-at-death
  r:put "agent_birth_tick" agent-birth-tick
  r:put "agent_lifetime_adult_offspring" agent-lifetime-adult-offspring
  r:put "pop_census" pop-census
  r:put "pop_age" pop-age
  r:put "pop_waste_prob" pop-waste-prob
  r:put "pop_neutral" pop-neutral
  r:put "climate" climate
  r:eval "save.image(file=paste(outpath,f,'.RData',sep=''))"
  r:clear
  r:gc
end
@#$#@#$#@
GRAPHICS-WINDOW
7
45
45
84
-1
-1
30.0
1
10
1
1
1
0
0
0
1
0
0
0
0
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
100.0
true
false
"" ""
PENS
"Agents" 1.0 0 -14070903 true "" "plot count turtles"
"Carrying Capacity" 1.0 0 -16777216 true "" "plot base-agents"

INPUTBOX
6
449
119
509
waste-mutate
0.01
1
0
Number

PLOT
583
161
907
311
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
"Agents" 0.01 1 -16777216 true "" "histogram [waste-prob] of turtles"

PLOT
257
312
581
462
Age
NIL
NIL
1.0
100.0
0.0
100.0
true
false
"" ""
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
9
530
159
548
Environmental Dynamics
11
0.0
1

INPUTBOX
6
586
119
646
climateAR
0.3
1
0
Number

INPUTBOX
121
586
235
646
climateSD
0.3
1
0
Number

INPUTBOX
139
10
237
70
nticks
2000.0
1
0
Number

PLOT
582
10
907
160
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
"default" 1.0 0 -16777216 true "" "plot abs item ticks climate"
"pen-1" 1.0 0 -7500403 true "" "plot abs ( 1 + ( item ticks climate ) )"

SWITCH
6
551
158
584
climate-change
climate-change
0
1
-1000

PLOT
257
161
581
311
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
"Neutral" 1.0 0 -7500403 true "" "plot mean [neutral] of turtles"

INPUTBOX
6
336
120
396
repro-cost
1.0
1
0
Number

INPUTBOX
121
336
235
396
consume-amount
1.0
1
0
Number

SWITCH
6
415
119
448
waste
waste
0
1
-1000

TEXTBOX
9
399
159
417
Waste Dynamics
11
0.0
1

INPUTBOX
6
111
236
171
ExperimentName
longrun
1
0
String

SWITCH
6
682
131
715
export-res
export-res
1
1
-1000

INPUTBOX
6
717
350
777
output_path
/Volumes/WCCDefiant/Academia/Projects/Waste/Data/001/
1
0
String

CHOOSER
121
250
229
295
provision
provision
"1" "2" "3" "4" "R"
0

INPUTBOX
6
250
120
310
mature
10.0
1
0
Number

PLOT
458
463
780
613
Provisioned
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [provisioned] of turtles with [juv-offspring >= 1]"

PLOT
257
463
457
613
Provisioning
NIL
NIL
1.0
5.0
0.0
1000.0
false
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [prov-strategy] of turtles "

PLOT
908
161
1203
311
Neutral
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
"default" 0.01 1 -16777216 true "" "histogram [neutral] of turtles"

PLOT
582
312
799
462
N. Off.
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [n-offspring] of turtles with [age >= mature]"

TEXTBOX
7
319
157
337
Survival Costs
11
0.0
1

PLOT
800
312
1000
462
N. Juvenile Off.
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [juv-offspring] of turtles with [age >= mature and juv-offspring > 0]"

PLOT
1001
312
1201
462
N. Adult Off.
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [adult-offspring] of turtles with [age >= mature]"

INPUTBOX
121
189
229
249
base-agents
2000.0
1
0
Number

TEXTBOX
10
663
160
681
Output
11
0.0
1

PLOT
908
10
1203
160
Resources Gathered
NIL
NIL
0.0
100.0
0.0
5.0
true
false
"" ""
PENS
"No Climate" 1.0 0 -16777216 true "" "plot base-agents / ( count turtles )"
"Climate" 1.0 0 -7500403 true "" "plot abs (item ticks climate) * ( base-agents / ( count turtles ) ) "

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
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="longrun006" repetitions="138" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/006/Long/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="longrun005" repetitions="300" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/005/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="longrun004" repetitions="300" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/004/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="longrun003" repetitions="300" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/003/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="longrun002" repetitions="300" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/002/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="longrun001" repetitions="300" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <enumeratedValueSet variable="export-res">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateSD">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climateAR">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-agents">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-num-agents">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="provision">
      <value value="&quot;R&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="climate-change">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="output_path">
      <value value="&quot;/Volumes/WCCDefiant/Academia/Projects/Waste/Data/001/&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste-mutate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="repro-cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="waste">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mature">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nticks">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ExperimentName">
      <value value="&quot;longrun&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consume-amount">
      <value value="1"/>
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
