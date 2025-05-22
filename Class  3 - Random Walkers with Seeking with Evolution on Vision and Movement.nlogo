breed [ wanderers wander ] ;;; THIS CODE SPECIFIES NEW KINDS OF TURTLES. IT IS ALWAYS PLURAL THEN SINGULAR
breed [ foods food ] ;;;

wanderers-own [ ;;; TURTLES-OWN GIVES EVERY TURTLE IN THE SIMULATION A PERSONAL VARIABLE
  wiggle ;;; ALL WANDERERS NOW HAVE A THING CALLED 'WIGGLE'. THIS DICTATES HOW RANDOM THEIR WALK IS
  vision ;;; VISION DICTATES HOW FAR THEY CAN SEE
  fitness ;;; ALL WANDERERS HAVE A THING CALLED 'FITNESS', MEASURING HOW MUCH ENERGY THEY'VE SPENT MOVING VS EATING
  target ;;; ALL WANDERS CAN IDENTIFY FOOD AND PURSUE IT
  generation
]

globals [ ;;; THIS CODE CREATES A 'GLOBAL' VARIABLE - SOMETHING THAT FLOATS IN THE AETHER OF THE SIMULATION THAT EVERY PART OF THE MODEL CAN ACCESS AND ALTER
  reproduction-countdown ;;; THIS IS A COUNTDOWN VARIABLE DICTATING HOW OFTEN REPRODUCTION TAKES PLACE
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; SET COMMANDS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup ;;; THIS IS A FUNCTION CALLED 'SETUP'. IT IS CALLED WHEN THE BUTTON IN THE INTERFACE IS CLICKED. ALL FUNCTION BEGIN 'TO ...' AND COMPLETE WITH 'END'

  ca ;;; 'CA' STANDS FOR 'CLEAR-ALL' AND WIPES THE SIMULATION CLEAN
  reset-ticks ;;; WE MUST ALSO 'RESET TICKS' (THEY BECOME RELEVANT NOW. IT'S GOOD PRACTICE TO ALWAYS HAVE CA / RESET-TICKS AT THE TOP OF ANY SIMULATION).

  create-wanderers wanderer-population [ ;;; USING 'CREATE-BREED' I ASK FOR SOME NUMBER OF WANDERERS TO EXIST, BASED ON A GLOBAL VALUE IN THE GUI
    set size 2 ;;; I SET THEIR SIZE TO 2
    setxy random-xcor random-ycor ;;; SET RANDOM LOCATION
    set generation 1
    set fitness 100 ;;; GIVE THEM SOME AMOUNT OF FITNESS (NOT STRICTLY NECESSARY IF THEY DON'T DIE OF NATURAL CAUSES).
    set target nobody ;;; THIS IS A CODE TO DETERMINE IF THEY ARE SEEKING FOOD. nobody IS A PRIMITIVE INDICATING A EMPTY/NULL AGENTSET

    set wiggle initial-wiggle-size  ;;; ALL WANDERERS BEGING WITH THE SAME INITIAL WIGGLE
    set vision initial-visual-range ;;; ALL WANDERERS CAN SEE THREE UNITS AWAY
  ]

  repopulate-food ;;; CREATE FOOD

  set reproduction-countdown 100 ;;; SET THE REPRODUCTION COUNTDOWN TIMER TO 100 TICKS

end ;;; THIS COMPLETE THE 'SETUP' FUNCTION


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RUN COMMANDS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;; MY RUN COMMANDS ARE A DIFFERENT FAMILY FROM MY SETUP COMMANDS, SO I USE A NEW HEADER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go ;;; I CALL THE 'GO' COMMAND INTO EXISTENCE

  ask wanderers [ ;;; ASK ALL WANDERERS TO
    look-and-move ;;; EXECUTE LOOK AND MOVE
    eat ;;; AND EAT
    if natural-death = TRUE [ ;;; IF THE SWITCH FOR NATURAL DEATH IS ON
      check-death ;;; THEN HAVE WANDERERS CHECK IF THEY SHOULD DIE
    ]
  ]

  repopulate-food ;;; REPOPULATE FOOD

  reproduction-functionality ;;; DO ALL THIGNS RELATED TO REPRODUCTION

  tick ;;; INCREMENT THE TICKS
  if count turtles <= 0 [stop] ;;; CODE THAT KILLS THE SIMULATION IF ALL WANDERERS HAVE DIED

  do-the-plots ;;; MANUALLY UPDATE THE PLOTS

  if wanderer-population > count wanderers [
    ask n-of (wanderer-population - count wanderers) wanderers [ hatch 1 ]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; LOOK AND MOVE COMMANDS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to look-and-move ;;; HERE I CREATE THE 'MAKE-TURTLES-RANDOM-WALK' FUNCTION

  if target = nobody [ ;;; IF THE WANDER HAS NOT IDENTIFY ANY FOOD NEARBY PREVIOUSLY
    if any? foods in-radius vision [ ;;; LOOK FOR FOOD, AND IF THERE IS ANY
      set target one-of foods in-radius vision with-min [distance self]  ;;; SET IT AS THE TARGET
    ]
  ]

  carefully [ ;;;
    face target ;;; ALL WANDERERS NO FACE THEIR TARGET FOOD
  ][] ;;; THIS FUNCTIONALITY IS 'CAREFUL' SO THAT IF THE TARGET IS 'NOBODY' IT RUNS WITHOUT AN ERROR, AND DOES NOTHING.

  right random-normal 0 abs(wiggle) ;;; HAVING FACED THE TARGET, ALL WANDERERS DO A LITTLE WIGGLE TO A DEGREE DRAWN FROM A NORMAL DISTRIBUTION WITH THE SD DICTATED BY THEIR WIGGLE VARIABLE
  forward speed ;;; THEN WANDERERS MOVE FORWARD BY A VALUE SET IN THE INTERFACE

  set fitness (fitness - 1) ;;; THEY LOSE ONE FITNESS/ENERGY FOR TAKING ONE STEP

  if evolve-vision = TRUE [ ;;; IF VISION IS ALLOWED TO EVOLVE, AN ADDITIONAL "METABOLIC" COST IS IMPLEMENTED
    set fitness (fitness - (vision / 10))
  ]

  if trail = TRUE [ ;;; IF THE SWITCH VARIABLE CALLED 'TRAIL' IS 'ON' (IF = TRUE)
    pd ;;; TO PUT THEIR 'PEN-DOWN' (TO LEAVE A TRAIL).
  ]

end

;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; EAT ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

to eat

    if any? foods in-radius 1 = TRUE [ ;;; IF THERE IS ANY FOOD IS IN 'GRABBING RANGE' (WHETHER TARGET OR NOT)
      ask one-of foods in-radius 1 [ ;;; ASK THAT FOOD
        let food-who who ;;; TO IDENTIFY ITSELF
        ask wanderers with [target = food-who][set target nobody] ;;; ASK ALL ELSE WHO MIGHT BE CHASING THIS TARGET TO RECOGNIZE IT'S DEATH
        die ;;; AND DIE
      ]
      set fitness (fitness + energy-boost) ;;; THE WANDERER INCREASES THEIR OWN FITNESS BY SOME AMOUNT
    ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; CHECK DEATH ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-death

  if fitness <= 0 [
    die
  ]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; NON-TURTLE CODE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; REPRODUCTION FUNCTIONALITY ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to reproduction-functionality

  set reproduction-countdown (reproduction-countdown - 1) ;;; DECREMENT THE COUNTDOWN TIMER

  if reproduction-countdown = 0 [ ;;; IF THE TIMER REACHES 0

    repeat ((count wanderers) / 2) [ ;;; REPEAT THIS PROCESS FOR 50% OF THE POPULATION
      ask one-of wanderers with-min [fitness][die] ;;; KILL ANY WANDERER WHO HAS THE LOWEST FITNESS
    ]

    let old-cohort wanderers ;;; SET THE AGENTSET TO BE WANDERERS THAT EXIST. THIS AVOIDS LETTING NEWLY CREATED WANDERERS ALSO REPRODUCE

    ask old-cohort [ ;;; ASK THE OLD WANDERERS
      hatch-wanderers 2 [ ;;; HATCH TWO OFFSPRING, SO AS TO REPLACE THEMSELVES AND ANOTHER WHO DID IN THE CULL
                          ;set size 2 ;;; THIS GETS INHERITED
        setxy random-xcor random-ycor ;;; SET RANDOM LOCATION
        set generation (generation + 1) ;;; RECORD THAT THEY ARE A NEW GENERATION
        set fitness 100 ;;; RESET THIS VALUE

        if evolve-wiggle = TRUE [
          set wiggle (wiggle + random-normal 0 1) ;;; NOW INTRODUCE VARIANCE
          if wiggle < 0 [set wiggle 0]
        ]

        if evolve-vision = TRUE [ ;;; IF WE ARE LETTING VISION EVOLVE
          set vision (vision + random-normal 0 .2) ;;; INHERIT THE VALUE WITH VARIANCE
          if vision < 0 [set vision 0] ;;; AND ENSURE IT'S NOT A NEGATIVE (BECAUSE OTHERWISE THEY EVOLVE NEGATIVE VISION AND GET A FITNESS BOOST FOR IT!)
        ]

      ]
      die ;;; AFTER REPRODUCING, DIE
    ]
    set reproduction-countdown 100 ;;; AND ALL WANDERERS HAVE DONE THIS, RESET THE COUNTER TO 100
  ]

  if count wanderers > wanderer-population [ ;;; IF THE POPULATION HAS AN ODD NUMBER OF MEMBERS, IT WILL OVERPRODUCE BY 1 EACH REPRODUCTIVE CYCLE. THIS IS ONE SOLUTION TO THAT PROBLEM. IDENTIFY IF THERE ARE TOO MANY, THEN KILL HOWEVER MANY EXCESS WANDERERS THERE ARE
    ask n-of (count wanderers - wanderer-population) wanderers [die]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; FOOD COMMANDS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to repopulate-food

  let food-in-world count foods ;;; COUNT HOW MUCH FOOD

  if food-in-world < food-population [ ;;; IF LESS THAN DESIRED
    ask n-of (food-population - food-in-world) patches [ ;;; CREATE SOME RANDOMLY
      sprout-foods 1 [
        set size 1
        set shape "circle"
        set color blue
      ]
    ]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; PLOT COMMANDS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-the-plots

  set-current-plot "WIGGLE SIZE"
  set-current-plot-pen "Wiggle Size"
  plot mean [wiggle] of wanderers

  set-current-plot "VISUAL RANGE"
  set-current-plot-pen "Vision Range"
  plot mean [vision] of wanderers

end
@#$#@#$#@
GRAPHICS-WINDOW
324
10
820
507
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-30
30
-30
30
0
0
1
ticks
30.0

BUTTON
1
12
64
45
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
0
59
63
92
NIL
go
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
1
101
64
134
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

BUTTON
647
510
820
543
Inspect Random
inspect one-of wanderers
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
143
92
176
speed
speed
0
5
1.0
.1
1
NIL
HORIZONTAL

SWITCH
0
188
103
221
trail
trail
1
1
-1000

SLIDER
145
11
317
44
wanderer-population
wanderer-population
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
145
49
317
82
food-population
food-population
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
145
89
317
122
energy-boost
energy-boost
1
25
13.0
1
1
NIL
HORIZONTAL

PLOT
847
10
1294
164
Wiggle Size
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Wiggle Size" 1.0 0 -16777216 true "" ""

PLOT
848
170
1295
320
Visual Range
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Vision Range" 1.0 0 -16777216 true "" ""

SWITCH
1301
170
1473
203
evolve-vision
evolve-vision
0
1
-1000

BUTTON
1302
243
1476
276
Check Visual Range
\nask one-of wanderers [ask patches in-radius vision[set pcolor red]]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1301
205
1473
238
initial-visual-range
initial-visual-range
0
10
0.5
.5
1
NIL
HORIZONTAL

SWITCH
324
510
456
543
natural-death
natural-death
0
1
-1000

SWITCH
1299
10
1470
43
evolve-wiggle
evolve-wiggle
0
1
-1000

SLIDER
1300
47
1472
80
initial-wiggle-size
initial-wiggle-size
0
45
30.0
1
1
NIL
HORIZONTAL

MONITOR
850
326
958
371
Mean Generation
MEAN [GENERATION] OF WANDERERS
2
1
11

BUTTON
1304
281
1478
314
Reset World Colour
ask patches [set pcolor black]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
