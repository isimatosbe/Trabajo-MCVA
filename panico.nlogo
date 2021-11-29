; La variables que necesitamos son
; m_g que es el factor de objetivo
; m_c que es el factor de cohesion
; m_s que es el factor de separacion
; m_l que es el factor de alineamiento
; m_o que es el factor de obstaculo (aun no lo usamos)
; T el umbral de incomodidad
; T_M el umbral de invalidez, si alguien recive una fuerza mayor a esta no podra moverse

; Luego creo algunas variables que nos pueden ser utiles
; vMedia que sera la velocidad media de las personas
; pMedio sera el panico medio
; fMedio la fuerza media que recibe una persona
; coef que es el factor de conversion de metros a patch de NetLogo (he estado probando con 1 y 2, con 2 parece que se vuelve loco por lo que lo dejo casi siempre en 1)
; visibility es un vector que contiene las visibilidades de cada salida
; globals [m_g m_c m_s m_l m_o T T_M vMedia pMedio fMedio coef visibility]
globals [m_o T T_M vMedia pMedio fMedio coef visibility]


; Algunas propiedades de las personas,
; seeExit es si ve o no la salida
; r es el radio de la persona (la mitad de la distancia entre hombro y hombro)
; w es el peso de una persona
; v es la velocidad de una persona
; p es el panico de una persona
; F la fuerza que recibe
; out es 1 si la persona ha salido ya, y 0 si no
; exit es un vector con la pos de la salida que ve mas cerca
;turtles-own [seeExit r w v p F out exit]

; g es el vector goal, lo uso para poder calcular la media para los que no ven
turtles-own [seeExit r w v p F out exit m_g m_c m_s m_l g]

; Los patches tienen las siguientes propiedades,
; tipo nos dice el tipo del patch, puede ser obstaculo, exit o puerta (las casillas laterales de la exit)
; vis es la visibilidad de una salida (solo tendran este atributo las salidas para el resto valdra 0)
; id es un numero que representa a una salida, de esta forma sabremos hacia que salida va cada persona (este atributo solo lo tienen patches tipo exit)
patches-own [tipo vis id]

; Inicializamos las constantes que hemos definido. En el articulo se habla de que podriamos hacerlas propiedades de las personas que varien segun su estado, eso podria
; ser interesante. Estos valores los he reducido porque con los que nos daba el autor del articulo salian locuras, he mantenido mas o menos la proporcion que el plantea
; 40-50% del movimiento es el objetivo, 30% son los obstaculos y el resto es cohesion, separacion y alineacion, como en el ejemplo A no hay obstaculos he aumentado los
; valores para que sigan siendo 100%. Dejo comentado los valores originales.
to setup-cte
  set m_g 0.65 ;6.5
  set m_c 0.1  ;1.5
  set m_s 0.15 ;2.5
  set m_l 0.1  ;1.5
  set m_o 0.29 ;3.5
  set T 750
  set T_M 1600
  set coef 1
end

; Necesitamos un setup general para poder hacer mas comodo el proceso dependiendo de los ejemplos
to setup
  ;setup-cte
  set-default-shape turtles "circle"
  clear-turtles ; Por si queremos probar con diferentes disposiciones de personas
  clear-all-plots ; Para reiniciar las graficas
  create-wall
  ask patches with [tipo != "obstaculo" and tipo != "exit" and tipo != "puerta"] [if count turtles < nPersonas [sprout 1 [setup-person setup-cte]]]
  ask turtles [setup-person]
  reset-ticks
end

; create-wall se encarga de crear las paredes y establecer su tipo a obstaculo y crear el hueco de la puerta
to create-wall
  ask patches with [(pxcor = max-pxcor or pxcor = min-pxcor or pycor = max-pycor or pycor = min-pycor) and tipo != "exit" and tipo != "puerta"] [set pcolor red]
  ask patches with [tipo = "exit"] [ask other patches in-radius 1 [set pcolor black set tipo "puerta"]]
  ask patches with [pcolor = red] [set tipo "obstaculo"]
  ; La linea de abajo crea un arco verde con el campo de vision de cada salida
  ask patches with [tipo = "exit" and vis != 1] [let x pxcor let y pycor let a vis ask other patches in-radius ((2 * max (list max-pxcor max-pycor) + 2) * vis)
    with [tipo = 0] [if (distancexy x y > (((2 * max (list max-pxcor max-pycor) + 2) * a - 1))) [set pcolor green]]]
end

; Con setup-person inicializamos los valores de las personas,
; El r va entre 0.25 - 0.4
; El w entre 40 - 80
; La v entre 0.35 - 1.95, como es un vector lo convierto en una lista usando la direccion de la persona
; El panico es un valor entre 0 y 1
; Ponemos que aun no han salido (out 0) y que su color sea blanco
to setup-person
  ask turtles-here [set r (coef * (random 15 + 25) / 100) set w (random 40 + 40) set v setup-velocidad set p (random 100 / 100) set out 0 set color white]
end

to-report setup-velocidad
  let a ((random 160 + 35) / 100)
  let c1 (coef * dx * a)
  let c2 (coef * dy * a)
  report list c1 c2
end

; choose-exit nos permite ver cual de las salidas (que ve la persona) esta mas cerca
to choose-exit
  let x xcor
  let y ycor
  let c list 0 0
  let d (2 * max (list max-pxcor max-pycor) + 2)
  let md (2 * max (list max-pxcor max-pycor) + 2)
  ask patches with [tipo = "exit"] [if (distancexy x y <= (d * vis) and distancexy x y <= d) [set c (list pxcor pycor) set d (distancexy x y)]]
  if c != list 0 0 [set seeExit 1 set exit c]
end

; Con el setup-A coloco la posicion que define el ejemplo A. Primero hago las paredes y la salida y en el interior coloco a la gente. En este caso empiezan con seeExit 1,
; porque es una de las hipotesis del ejemplo y out 0 porque estan todos dentro. Esta puesto para que dos personas no puedan aparecer en el mismo patch porque eso es algo
; que fisicamente es imposible, pero esta comentada la funcion que lo permite.
to setup-A
  clear-all
  set nPersonas 400
  ask patch 0 max-pycor [set tipo "exit" set vis 1 set id 1]
end

to setup-B
  clear-all
  set nPersonas 400
  ask patch 0 max-pycor [set tipo "exit" set vis 0.45 set id 1]
  ask patch 0 min-pycor [set tipo "exit" set vis 0.45 set id 2]
end

to setup-C
end

to setup-D
end

to setup-E
end

to setup-F
end

; go es la funcion que va a hacer que se muevan las personas. Inicializamos los valores informativos a 0 y luego los dividimos por el numero de personas que no han salido aun,
; que son a los que les aplicamos evacuate. Por comodidad movemos a todas las personas que han salido a la casilla de salida para que sea mas visual lo que ocurre
to go
  set vMedia 0
  set pMedio 0
  set fMedio 0
  let nP (nPersonas - (count turtles with [out = 1]))
  ask turtles with [out = 0] [choose-exit evacuate]
  ask turtles with [out = 1] [set xcor (item 0 exit) set ycor (item 1 exit)]
  set vMedia (vMedia / nP)
  set pMedio (pMedio / nP)
  set fMedio (fMedio / nP)
  tick
end

; evacuate es la primera funcion intensa, sigue el proceso descrito en el articulo. Dado que NetLogo no trabaja con vectores, he tenido que improvisar y trabajar con listas. He
; intentado seguir la nomenclatura del articulo en la mayor parte de las cosas
to evacuate
  goal
  let O_g (map [a -> a * m_g] g)
  let O_m (move m_s m_l m_o)
  let O_i (map + O_g O_m)
  ; En la siguiente linea actualizo el valor del panico, que aunque no lo describa en el algoritmo, en la figura 1 si lo describe asi, y entiendo que es necesario.
  ifelse (p >= 0.5) [set O_i (move 0 0 0) set p p_avg] [set p panic]
  set pMedio (pMedio + p)
  set v (map + (map [a -> (1 - p) * a] O_i) (map [a -> a * p] v))
  let module sqrt((item 0 v) ^ 2 + (item 1 v) ^ 2)
  set vMedia (vMedia + module)

  ; Una vez esta todo calculado sumo los vectores p y v componente a componente. Y compruebo si queda fuera de los limites, si es asi aplico un "rebote"
  let x (item 0 v + xcor)
  if x < (min-pxcor + 1) [set x (min-pxcor + 1 + ((- x) mod (2 * max-pxcor - 1)))]
  if x > (max-pxcor - 1) [set x (max-pxcor - 1 - (x mod (2 * max-pxcor - 1)))]
  let y (item 1 v + ycor)
  if y < (min-pycor + 1) [set y (min-pycor + 1 + ((- y) mod (2 * max-pycor - 1)))]
  ; Si esta a 0.75 de la salida asumo que ha salido
  if (seeExit = 1 and distancexy (item 0 exit) (item 1 exit) < 2) [set y (item 1 exit) set x (item 0 exit) set out 1]
  if y > (max-pycor - 1) and x != 0  [set y (max-pycor - 1 - (y mod (2 * max-pycor - 1)))]

  ; Para realizar el movimiento final habia dos opciones "teletransportar" a la persona al sitio correspondiente (seria el setxy que esta comentado) o evitar que una persona pudiera
  ; cruzar sobre otra. Esto lo hago dividiendo el movimiento en pasos, de tamaño r (el radio de una persona) para que sea un valor arbitrario e intrinseco de cada individuo, es como
  ; si fuera un paso. Lo que hago es "apuntar" a la casilla a la que debo ir, y el modulo de ese vector, la distancia a ese vector, es lo que me debo de mover, lo hago de r en r.
  ;setxy x y
  facexy x y
  let mov (distancexy x y)
  let mov2 r

  ; Si no he salido de la sala (esto debemos de comprobarlo cada vez que se mueve), ni se choca con una pared (puedeMoverse) o se choca con alguien (puedeIr) y ademas el movimiento que
  ; me queda es mayor que lo que voy a hacer en este paso y el movimiento que me queda no es 0, pues me muevo. Reduzco del movimiento que me queda el paso y si el siguiente paso es mas
  ; grande que lo que me queda, me muevo la diferencia solo para acabar el movimiento.
  while [(seeExit = 0 or not fuera) and (not puedeMoverse mov2 or puedeIr mov2) and mov > mov2 and mov != 0] [fd mov2 set mov (mov - mov2) if mov < mov2 [set mov2 (mov2 - mov)]]

  ; Por ultimo, calculamos las fuerzas que se le aplica a la persona. Para esto vemos cuanta fuerza le ejerce cada persona de su entorno, y esto lo calculamos con la funcion fuerza
  let sumaF 0
  let ri r
  let vi v
  let pos (list xcor ycor)
  ask other turtles in-radius (coef * 8 * r) with [out = 0] [set sumaF (sumaF + (fuerza ri pos vi))]
  set F sumaF ; Esto es mu grande, hay q arreglar algo
  set fMedio (fMedio + F)

  ; Si la fuerza es mayor que T_M queda inavilitado (le cambiamos el color y no debe de moverse, esto no esta hecho aun), si esta incomodo, le cambiamos el color pero este si se mueve.
  (ifelse (F >= T_M) [set color blue] (F >= T) [set color grey] [])
end

; puedeIr comprueba si al moverse se choca con el hombro de alguna persona, es decir, su distancia a esa persona es menor que el radio de dicha persona. Si esto ocurre, no se mueve.
to-report puedeIr [mov]
  let x xcor + (mov * dx)
  let y ycor + (mov * dy)
  let b 0
  ask other turtles in-radius (2 * mov) with [out = 0] [if distancexy x y < r [set b (b + 1)]]
  ifelse b = 0 [report true] [report false]
end

; puedeMoverse comprueba si al moverse no se choca con una pared
to-report puedeMoverse [mov]
  let x xcor + (mov * dx)
  let y ycor + (mov * dy)
  report x <= max-pxcor - 1 and x >= min-pxcor + 1 and y <= max-pycor - 1 and y >= min-pycor + 1
end

; fuera comprueba en cada paso si hemos salido o no ya.
to-report fuera
  let x (item 0 exit)
  let y (item 1 exit)
  ifelse (distancexy x y < 2) [set out 1 set xcor x set ycor y report true] [report false]
end

; Esta funcion me esta fallando, me devuelve valores anormalmente grandes, no se que ocurre.
; Sigue 100% la estructura del articulo, resolviendo algunos detalles que estan mal explicados en el articulo, lo podeis consultar en el PDF
; Simulating dynamical features.
to-report fuerza [radio pos vel]
  let A 2
  let B (coef * 0.08)
  let k1 120
  let k2 (240 / coef)
  let Rij (radio + r)
  let dij (distancexy (item 0 pos) (item 1 pos)) ; Como hemos dicho que la gente no se mueve si se choca, esto nunca va a ser 0
  let nu 0
  ifelse (Rij - dij) >= 0 [set nu (Rij - dij)] [set nu 0]
  let f1 (A * e ^ ((Rij - dij) / B) + k1 * nu)
  let mij (map [x -> x / dij] (map - pos (list xcor ycor)))
  set f1 (map [x -> x * f1] mij)
  let vel2 (map - v vel)
  let d ((item 0 vel2) * -1 * (item 1 mij) + (item 1 vel2) * (item 0 mij))
  let d2 (map [x -> x * d] (list (-1 * item 1 mij) (item 0 mij)))
  let f2 (map [x -> x * k2 * nu] d2)
  let f3 (map + f1 f2)
  report sqrt((item 0 f3) ^ 2 + (item 1 f3) ^ 2)
end

; La funcion goal no esta acabada, solo esta hecha para si ve ir y si no 0. Esta funcion creo que la vamos a tener que cambiar bastante porque no esta muy
; bien explicada en el articulo, la creacion de mapas no parece algo trivial y el del articulo le dedica la figura 2 que no explica mucho.
; La idea que yo vi mas comoda y realista seria la imagen que os añado en recurso que se llama goal.
; En principio en esta funcion lo que hago es hacer que todos apunten hacia la salida, porque la estan viendo, dependiendo de lo lejos que esten
; el modulo del vector que apunta a la salida lo he hecho mas grande, como que la gente del fondo esta mas nerviosa, tiene mas prisa.
to goal
  let c list 0 0
  ifelse seeExit = 1 [setup-cte let x (item 0 exit) let y (item 1 exit) facexy x y
  (ifelse distancexy x y >= 2 * 2 * max-pycor / 3 [set c (list (2 * dx) (2 * dy))]
    distancexy x y >= 2 * max-pycor / 3 [set c (list (1.5 * dx) (1.5 * dy))]
      [set c list dx dy])]
  [let a (list 0 0)
    let N (count other turtles in-radius (coef * 8 * r) with [g != 0 and g != list 0 0])
    ifelse (N != 0) [ask other turtles in-radius (coef * 8 * r) with [g != 0 and g != list 0 0] [set a (map + a g)]
                     ifelse (a != list 0 0) [set c (map [b -> b / N] a)] [set c (list ((random 2 - (xcor / abs(xcor)))) ((random 3 - 1)))]]
                    [set c (list ((random 2 - (xcor / abs(xcor)))) ((random 3 - 1)))]]
  set g c
end

; La funcion move tambien sigue la estructura del articulo. Creo los valores iniciales con los valores de la persona en cuention para luego no tener
; que quitarla al hacer las cuentas (porque en ese momento no sabia sorry)
to-report move[m_1 m_2 m_3]
  let w_m (list (- xcor) (- ycor))
  let pos (list xcor ycor)
  let x (list 0 0)
  let y (map [a -> -1 * a] v)
  let z (list 0 0)
  let v_m 0

  ask turtles in-radius (coef * 8 * r) with [out = 0] [set w_m (map + w_m (list xcor ycor))]
  let nV (count turtles in-radius (coef * 8 * r) with [out = 0])
  ifelse (nV = 1) [set w_m (list 0 0)] [set w_m (map [a -> a / (nV - 1)] w_m)]
  set w_m (map [a -> a * m_c] (map - w_m pos))

  ask turtles in-radius (coef * (2 * r + 2)) with [out = 0] [set x (map - x (map - (list xcor ycor) pos))]
  set x (map [a -> a * m_1] x)

  ask turtles in-radius (coef * 4 * r) with [out = 0] [set y (map + y v)]
  set nV (count turtles in-radius (coef * 4 * r) with [out = 0])
  ifelse (nV = 1) [set y (list 0 0)] [set y (map [a -> a / (nV - 1)] y)]
  set y (map [a -> a * m_2] (map - y v))

  ask patches with [tipo = "obstaculo"] in-radius ((2 * r + 2)) [set z (map - z (map - (list pxcor pycor) pos))]
  set z (map [a -> a * m_3] z)

  set v_m (map + (map + w_m x) (map + y z))
  report v_m
end

; Esta funcion calcula el panico medio de los vecinos (las tortugas de los 8 patches que rodean a una persona)
to-report p_avg
  let suma_p 0
  let vecinos 0
  ask neighbors [set suma_p (suma_p + (sum [r] of turtles-here with [out = 0])) set vecinos (vecinos + (count turtles-here with [out = 0]))]
  (ifelse (vecinos = 0) [report p] [report suma_p / vecinos])
end

; Por ultimo esta funcion corresponde con lo que se habla en la seccion III.B, y sigo los pasos tal y como los describe.
to-report panic
  let D (distancexy 0 max-pycor)
  if seeExit = 0 [set D (2 * max-pycor + 1)]
  let d1 (D - 10 * r)/(2 * max-pycor + 1)

  let vi (list 0 0)
  let module (sqrt((item 0 v) ^ 2 + (item 1 v) ^ 2))
  ask turtles in-radius (coef * 4 * r) [set vi (map + vi v)]
  let d2 ((sqrt((item 0 vi) ^ 2 + (item 1 vi) ^ 2) - module) / (coef * 1.95))

  ;d3 depende de las fuerzas
  let O (count turtles in-radius (coef * 8 * r) with [out = 0 and F >= T])
  let d3 O / (count turtles with [out = 0])

  let d4 (coef * 0.35 - module) / (coef * 1.95)

  let xi (d1 + d2 + d3 + d4) / 4
  let p_i (p + xi) / 2
  report p_i
end

; Para dibujar los obstaculos ejecutamos una función de manera indefinida (FOREVER) y comprobamos donde hace click el
; usuario, en esas casillas mata a las tortugas que haya, las pinta de rojo y pone que son de tipo obstaculo. Si da doble
; click sobre uno lo elimina y para que esto funcione bien tenemos que esperar un poco tras cada click
to draw-obstaculos
  if mouse-down? [ask patch mouse-xcor mouse-ycor [ask turtles-here [die] ifelse pcolor = red [set pcolor black set tipo 0] [set pcolor red set tipo "obstaculo"]]]
  wait .05
end
@#$#@#$#@
GRAPHICS-WINDOW
13
13
763
708
-1
-1
14.0
1
10
1
1
1
0
0
0
1
-26
26
-24
24
0
0
1
ticks
30.0

BUTTON
780
121
850
155
A
setup-A
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
774
188
856
250
nPersonas
400.0
1
0
Number

BUTTON
774
253
858
288
Go
;if count turtles with [out = 0] < nPersonas / 50 [stop]\nlet c (count turtles with [out = 1])\nrepeat 10 [go]\nif c = count turtles with [out = 1] [stop]
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
774
291
859
326
Go 1
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

PLOT
1239
20
1439
170
OUT
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" "if (count turtles with [out = 1]) >= (count turtles - 2) [stop]"
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [out = 1]"

PLOT
1239
175
1439
325
Velocidad Media
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot vMedia"

PLOT
1241
330
1441
480
Panico Medio
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot pMedio"

MONITOR
1372
107
1430
152
OUT
count turtles with [out = 1]
1
1
11

PLOT
1242
484
1442
634
Fuerza Media
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
"default" 1.0 0 -16777216 true "" "plot fMedio"

TEXTBOX
780
17
1232
115
Para los ejemplos del artículo pueden configurarse directamente con los botones siguientes:\n- A: Una sola salida en el medio que todo el mundo puede ver.\n- B: Dos salidas en el medio con visibilidad media.\n- C: Dos salidas en el medio con visibilidad media y baja.\n- D: Dos salidas en las esquinas izquierdas con baja visibilidad.\n- E: Dos salidas en esquinas opuestas con visibilidad media.\n- F: Una salida en el medio con visibilidad completa y obstáculos.
11
0.0
1

BUTTON
856
121
926
155
B
setup-B
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
932
121
1002
155
C
setup-C
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
1008
121
1078
155
D
setup-D
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
1084
121
1154
155
E
setup-E
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
1160
121
1230
155
F
setup-F
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
781
338
874
371
Obstaculos
draw-obstaculos
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
915
204
980
238
Setup
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

PLOT
1446
23
1646
173
goal Medio
NIL
NIL
0.0
10.0
0.0
2.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if count turtles with [g != 0] != 0\n[plot (sum [sqrt((item 0 g) ^ 2 + (item 1 g) ^ 2)] of turtles with [g != 0]) / (count turtles with [g != 0])]"

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
NetLogo 6.2.1
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
