breed [personas persona] ;Personas dentro de la simulación
;breed [obstaculos obstaculo] ;Obstaculos dentro de la simulación
breed [puertas puerta] ;Creamos las puertas
personas-own [
  r ; Raio: entre 0,25 y 0,4 m
  w ; Peso
  v ; Velocidad
  v_nueva ; velocidad nueva
  v_goal_mod ; Módulo del término de la velocidad que decimos que tienen los agentes en dirección a la puerta
  v_goal ; Término de la velocidad que decimos que tienen los agentes en dirección a la puerta
  p ; Posición
  disconformidad ; Disconformidad que sufren los agentes debido a las fuerzas
  panic ; Pánico: Entre 0 y 1
  l ; Distancia máxima aceptable a la puerta de salida
  d_a ; Distancia mínima a la cuál un agente se separa de otro
  d_c ; Distancia radial desde el agente i que define los límites del grupo que consideramos para comportamiento de cohesión
  d_l ; Distancia radial desde el agente i que define los límites del grupo que consideramos para comportamiento de alineamiento
  m_g ; Factor asociado con el comportamiento del agente para llegar al objetivo. Es dominante cuando el agente conoce el objetivo y no interviene cuando el agente no lo conoce.
  m_c ; Factor asociado con el comportamiento del agente "siguiendo al rebaño". El comportamiento es dominante cuando el conocimiento del agente sobre el entorno es limitado
  m_s ; Factor asociado con el comportamiento de separación del agente. Se puede incrementar este factor en las zonas cercanas a las puertas de salida.
  m_l ; Factor asociado con el comportamiento de alineación del agente. Se puede incrementar cuando se necesita coordinación entre agentes como en las colas que se forman en zonas estrechas.
  m_o ; factor asociado con el comportamiento de evitación de obstáculos del agente. Se puede incrementar cuando existen muchos obstáculos
  puerta_vista
  ; Componentes de pánico
  d1
  d2
  d3
  d4
  ; Componentes de la fuerza
  ; Componentes de la función move
  w_pos_media
  x_separation
  y_aligment
  z_obstacles
  modulo_fuerza_total
  aceleracion_recibe
  aceleracion
  centro_puerta
  herido
]

globals [
  T ; Fuerza límite que recibe una persona para no poder moverse N
  T_M ; Presión máxima que recibe una persona a partir de la cual no puede moverse (N/m)
  coef ; Intervalo temporal para utilizar en la simulación
  L_max ; Distancia máxima del escenario
  v_max ; Velocidad máxima permitida
  v_min ; Velocidad mínima permitida
  A ; Coeficiente de repulsión
  B ; Longitud de caída
  k1 ; Constante de fuerza del cuerpo
  k2 ; Constante de fuerza de fricción y deslizamiento
  v_media ; Velocidad media
  g_medio ; Goal medio
  panic_medio; panico_medio de todos los agentes
  para
  milisegundo ; variable para considerar cada tick como un milisegundo
  escenario ; Variable para seleccionar el escenario
]

patches-own [ tipo ] ; Para indicar si el patch es un obstáculo o no

puertas-own [
  centro ; Indica el centro de la puerta
  radio ; Indica el radio de la puerta
  cor_x ; Indica las coordenadas x de los patches que componen la puerta
  cor_y ; Indica las coordenadas y de los patches que componen la puerta
  visibilidad ; Define la distancia a la que los agentes ven la puerta
]

to setup-A
  print "Escenario A cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  setup-patches
end

to setup-B
  print "Escenario B cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 2 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 2 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 min-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  setup-patches
end

to setup-C
  print "Escenario C cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 2 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 6 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 min-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  setup-patches
end

to setup-D
  print "Escenario D cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 6 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list min-pxcor max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro) set cor_y insert-item 0 cor_y (item 1 centro + i)]
  ]
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 6 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list min-pxcor min-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro) set cor_y insert-item 0 cor_y (item 1 centro + i)]
  ]
  setup-patches
end

to setup-E
  print "Escenario E cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 2 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list min-pxcor max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro) set cor_y insert-item 0 cor_y (item 1 centro + i)]
  ]
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max / 2 ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list max-pxcor min-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro) set cor_y insert-item 0 cor_y (item 1 centro + i)]
  ]
  setup-patches
end

to setup-F
  print "Escenario F cargado"
  create-puertas 1 [
    set hidden? true
    set visibilidad L_max ; Definimos la visibilidad como la mayor distancia del escenario
    set centro list 0 max-pycor
    set radio 1
    set cor_x []
    set cor_y []
    foreach (range (- radio) (radio + 1)) [i -> set cor_x insert-item 0 cor_x (item 0 centro + i) set cor_y insert-item 0 cor_y (item 1 centro)]
  ]
  ask patches with [pxcor = ceiling (min-pxcor / 3) and pycor > (4 * min-pycor / 5) and pycor < (2 * max-pycor / 5)] [set tipo "obstaculo" set pcolor red]
  ask patches with [pxcor > ceiling (min-pxcor / 3) and pxcor = -1 * pycor + 7 and pxcor < ceiling (2 * max-pxcor / 3)] [set tipo "obstaculo" set pcolor red]
  setup-patches
end

to setup-patches
  ; Dibujamos el escenario y señalamos las paredes como obstáculos
  ask patches with [pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor] [set pcolor red set tipo "obstaculo"]
  let pix_x_puertas []
  let pix_y_puertas []
  ask puertas [
    foreach cor_x [i -> set pix_x_puertas insert-item 0 pix_x_puertas i]
    foreach cor_y [i -> set pix_y_puertas insert-item 0 pix_y_puertas i]
  ]
  (foreach pix_x_puertas pix_y_puertas [ [c d] -> ask patches with [pxcor = c and pycor = d] [set pcolor blue set tipo "puerta"] ])
end
to setup-personas
  ; Inicializamos las personas en el mapa, con su anchura, peso, velocidad, posición y pánico
  set-default-shape personas "circle"
  create-personas numero_personas
  ask personas [
    let clase "libre"
    set color white
    let x_cor random (max-pxcor - min-pxcor - 1) + min-pxcor + 1
    let y_cor random (max-pycor - min-pycor - 1) + min-pycor + 1
    ask patches with [pxcor = x_cor and pycor = y_cor] [set clase tipo]
    while [(any? personas with [xcor = x_cor and ycor = y_cor]) or clase = "obstaculo"]
    [
    set x_cor random (max-pxcor - min-pxcor - 1) + min-pxcor + 1
    set y_cor random (max-pycor - min-pycor - 1) + min-pycor + 1
    ask patches with [pxcor = x_cor and pycor = y_cor] [set clase tipo]
    ]
    set xcor x_cor
    set ycor y_cor
    set p list x_cor y_cor
    set puerta_vista 0
  ]
  ask personas [
    set r (random 15 + 25) / 100
    set l (10 * r) / coef
    set d_a (2 * r + 2) / coef ;+ 2
    set d_c (8 * r); (8 * r) / coef
    set d_l (4 * r); (4 * r) / coef
    set m_g 6.5
    set m_c 1.5
    set m_s 0;2.5
    set m_l 1.5
    set m_o 0;3.5
    set w (random-normal 25 15 + 40)
    set v list v_min v_min
    set v_goal_mod random-normal (v_min + ((v_max - v_min) / 2)) (((v_max - v_min) / 2) * 0.4)
    set panic 0
    set size 2 * r
  ]
end

to reset
  clear-all
end
to setup
  set coef 1
  set para 0
  set milisegundo 10
  set L_max sqrt ( (2 * max-pxcor + 1 ) ^ 2 + (2 * max-pycor + 1) ^ 2 ) ; Máxima distancia del escenario
  set T 750
  set v_max 1.95
  set v_min 0.35
  set A 2000
  set B 0.08
  set k1 12000
  set k2 24000
  set L_max sqrt ( (2 * max-pxcor + 1 ) ^ 2 + (2 * max-pycor + 1) ^ 2 ) ; Máxima distancia del escenario
  if escenario = "A" [setup-A]
  if escenario = "B" [setup-B]
  if escenario = "C" [setup-C]
  if escenario = "D" [setup-D]
  if escenario = "E" [setup-E]
  if escenario = "F" [setup-F]
  setup-personas
  reset-ticks
end

to-report modulo [lista]
  report sqrt ((item 0 lista) ^ 2 + (item 1 lista) ^ 2)
end

to-report move
    ; Inicializamos los vectores w_pos_media, x_separation, y_aligment, z_obstacles y v a 0
  set w_pos_media [0 0]
  set x_separation [0 0]
  set y_aligment [0 0]
  set z_obstacles [0 0]

  let posx item 0 p
  let posy item 1 p

  ; Calculamos w_pos_media como la componente de la velocidad que hace que la persona se mueva hacia el centro de masas del grupo
  let contador 0
  let comp0 item 0 w_pos_media
  let comp1 item 1 w_pos_media
  ask personas in-radius d_c;with [sqrt ( (posx - [item 0 p] of self) ^ 2 + (posy - [item 1 p] of self) ^ 2 ) < d_c and [who] of self != [who] of myself]
  [
    if [who] of self != [who] of myself [
      set comp0 (comp0) + item 0 p
      set comp1 (comp1) + item 1 p
      set contador contador + 1
    ]
  ]
  if contador != 0 [
    set w_pos_media list (comp0 / contador) (comp1 / contador)
  ]

  ; Calculamos x_separation como la componente de la velocidad que hace que la persona se separe de otra que está muy cerca
  set comp0 item 0 x_separation
  set comp1 item 1 x_separation
  ask personas in-radius d_a;with [sqrt ( (posx - [item 0 p] of self) ^ 2 + (posy - [item 1 p] of self) ^ 2 ) < d_a and [who] of self != [who] of myself]
  [
    if [who] of self != [who] of myself [
      set comp0 (comp0) - (item 0 p - posx)
      set comp1 (comp1) - (item 1 p - posy)
    ]
  ]
  set x_separation list comp0 comp1

  ; Calculamos y_aligment como la velocidad media de las velocidades de las personas del grupo que consideramos
  set contador 0
  set comp0 item 0 y_aligment
  set comp1 item 1 y_aligment
  ask personas in-radius d_l ;with [sqrt ( (posx - [item 0 p] of self) ^ 2 + (posy - [item 1 p] of self) ^ 2 ) < d_l and [who] of self != [who] of myself]
  [
    if [who] of self != [who] of myself [
      set comp0 (comp0) + (item 0 v)
      set comp1 (comp1) + (item 1 v)
      set contador contador + 1
    ]
  ]
  if contador != 0 [
    set y_aligment list (comp0 / contador) (comp1 / contador)
  ]

  ; Calculamos z_obstacles como la componente de la velocidad que hace que la persona se aleje de los obstáculos
  set comp0 item 0 z_obstacles
  set comp1 item 1 z_obstacles
  ask patches in-radius d_a ;with [sqrt ( (posx - [pxcor] of self) ^ 2 + (posy - [pycor] of self) ^ 2 ) < [d_a] of myself and tipo = "obstaculo"]
  [
    set comp0 (comp0) - (pxcor - posx)
    set comp1 (comp1) - (pycor - posy)
  ]
  set z_obstacles list comp0 comp1

  ; Calculamos la velocidad de cada agente como una ponderación de los componentes calculados anteriormente
  ;let v_pass_x ( m_c * (item 0 w_pos_media - item 0 p) + m_s * item 0 x_separation + m_l * (item 0 y_aligment - item 0 v) + 0 * item 0 z_obstacles )
  ;let v_pass_y ( m_c * (item 1 w_pos_media - item 1 p) + m_s * item 1 x_separation + m_l * (item 1 y_aligment - item 1 v) + 0 * item 1 z_obstacles )
  report list ( m_c * (item 0 w_pos_media - item 0 p) + m_s * item 0 x_separation + m_l * (item 0 y_aligment - item 0 v) + m_o * item 0 z_obstacles ) ( m_c * (item 1 w_pos_media - item 1 p) + m_s * item 1 x_separation + m_l * (item 1 y_aligment - item 1 v) + m_o * item 1 z_obstacles )
end

to-report goal ; Devuelve la velocidad hacia el objetivo
  let v_devuelve list 0 0
  ifelse puerta_vista = 0 [
    ask puertas [
      let dis_puerta sqrt ( (item 0 centro - [item 0 p] of myself) ^ 2 + (item 1 centro - [item 1 p] of myself) ^ 2 )
      ifelse (dis_puerta < visibilidad)
      [set v_devuelve list ([m_g] of myself * [v_goal_mod] of myself * (item 0 centro - [item 0 p] of myself) / dis_puerta ) ([m_g] of myself * [v_goal_mod] of myself * (item 1 centro - [item 1 p] of myself) / dis_puerta )
       ask myself [ set puerta_vista 1]
       ask myself [ set centro_puerta [centro] of myself ]
       stop]
      [
        let v_random list (-1 + random-float 2) (-1 + random-float 2)
        let mod_v_random modulo v_random
        set v_devuelve list ([m_g] of myself * [v_goal_mod] of myself * (item 0 v_random) / mod_v_random ) ([m_g] of myself * [v_goal_mod] of myself * (item 1 v_random) / mod_v_random )
      ]
    ]
  ]
  [ let dis_puerta sqrt ( (item 0 centro_puerta - item 0 p) ^ 2 + (item 1 centro_puerta - item 1 p) ^ 2 )
    set v_devuelve list (m_g * v_goal_mod * (item 0 centro_puerta - item 0 p) / dis_puerta ) (m_g * v_goal_mod * (item 1 centro_puerta - item 1 p) / dis_puerta )]
  report v_devuelve
end

to-report panico
  ; Calculamos la componente 1 de pánico que depende de la distancia a la que estemos de la puerta
  ; Calculamos la distancia del agente a la puerta que ve, suponiendo que no puede ver dos puertas por simplicidad
  let D L_max
  ask puertas [
    if (sqrt ( (item 0 centro - [item 0 p] of myself) ^ 2 + (item 1 centro - [item 1 p] of myself) ^ 2 ) < visibilidad)
      [ set D sqrt ( (item 0 centro - [item 0 p] of myself) ^ 2 + (item 1 centro - [item 1 p] of myself) ^ 2 ) stop]
  ]

  set d1 (D - l) / L_max ; Componente d1 de pánico

  ; Calculamos la componente 2 de pánico que tiene que ver con la diferencia de velocidades entre los vecinos y el agente
  let contador 0
  let comp0 0
  let comp1 0
  let v_aux 0
  ask personas with [sqrt ( ([item 0 p] of myself - [item 0 p] of self) ^ 2 + ([item 1 p] of myself - [item 1 p] of self) ^ 2 ) < d_l and [who] of self != [who] of myself]
  [
    set comp0 (comp0) + (item 0 [v] of self)
    set comp1 (comp1) + (item 1 [v] of self)
    set contador contador + 1
  ]
  if contador != 0 [
    set v_aux sqrt ( (comp0 / contador) ^ 2 + (comp1 / contador) ^ 2 )
  ]

  ;print v_aux
  let auxiliar v_aux - modulo v
  ifelse auxiliar < 0 [set d2 0]
  [set d2 auxiliar / v_max] ; Componente d2 de pánico
  ; Calculamos la tercera componente de pánico

  ; Contamos los agentes que tienen un nivel de disconformidad por encima de T
  let cuenta_incomodos 0
  let cuenta_total 0
  ask personas with [modulo list ([item 0 p] of myself - [item 0 p] of self) ([item 1 p] of myself - [item 1 p] of self) < d_c and [who] of self != [who] of myself] [
    set disconformidad modulo_fuerza_total / (2 * r * pi)
    ;print disconformidad
    if disconformidad > T [
      set cuenta_incomodos cuenta_incomodos + 1
    ]
    set cuenta_total cuenta_total + 1
  ]
  set d3 0
  if cuenta_total > 0 [
    set d3 cuenta_incomodos / cuenta_total ; Componente d3 de pánico
  ]
  ; Calculamos la cuarta componente de pánico

  set auxiliar (v_min - modulo v)
  ifelse auxiliar < 0 [set d4 0]
  [set d4 auxiliar / v_max]


  let nuevo_panico (d1 + d2 + d3 + d4) / 4
  report (panic + nuevo_panico) / 2
end

to-report fuerzas
  let termino_1 list 0 0
  let termino_2 list 0 0
  let termino_3 list 0 0
; Fuerzas de interacción entre agentes
  let fuerza_recibida list 0 0
  let modulo_fuerza_total_aux 0
  ask personas with [modulo list ([item 0 p] of myself - [item 0 p] of self) ([item 1 p] of myself - [item 1 p] of self) < d_l and [who] of self != [who] of myself]
  [
    ; Distancia entre agentes
    let d_ij modulo list ([item 0 p] of myself - [item 0 p] of self) ([item 1 p] of myself - [item 1 p] of self)
    ; Vector unitario en la dirección que une dos agentes
    if d_ij = 0 [set d_ij 0.01]
    let n_ij list (([item 0 p] of myself - [item 0 p] of self) / d_ij) (([item 1 p] of myself - [item 1 p] of self) / d_ij)
    ; Suma de la anchura de dos agentes
    let r_ij [r] of myself + [r] of self
    ;Termino auxiliar
    let r_d (r_ij - d_ij)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; CALCULO DEL TERMINO 2 y 3
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ifelse (d_ij < r_ij) ;Programacion de la funcion g(x)
    [ set termino_2 list (item 0 n_ij * k1 * r_d) (item 1 n_ij * k1 * r_d)
      let t_ij list (- item 1 n_ij) (item 0 n_ij)
      let dv_ji list ([item 0 v] of self - [item 0 v] of myself) ([item 1 v] of self - [item 1 v] of myself)
      set termino_3 list (k2 * r_d * item 0 dv_ji * item 0 t_ij) (k2 * r_d * item 1 dv_ji * item 1 t_ij) ]
    [ set termino_2 list 0 0
      set termino_3 list 0 0]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; CALCULO DE LA FUERZA TOTAL RECIBIDA
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ifelse milisegundo < 11 ; Solo consideramos el término de separación por fuerza social cada segundo
    [ ; Primer término de la fuerza entre dos agentes
      set termino_1 list (A * e ^ (r_d / B) * item 0 n_ij) (A * e ^ (r_d / B) * item 1 n_ij)
    ]
    [
      set termino_1 list 0 0
    ]
    let f list ((item 0 termino_1) + (item 0 termino_2) + (item 0 termino_3)) ((item 1 termino_1) + (item 1 termino_2) + (item 1 termino_3))
    set fuerza_recibida list (item 0 fuerza_recibida + item 0 f) (item 1 fuerza_recibida + item 1 f)
    set modulo_fuerza_total_aux (modulo_fuerza_total_aux + modulo f)
]
  set modulo_fuerza_total modulo_fuerza_total_aux
  report fuerza_recibida

end

to-report fuerzas_patches
; Fuerzas de interacción entre agentes
  let termino_1 list 0 0
  let termino_2 list 0 0
  let termino_3 list 0 0
  let fuerza_recibida list 0 0
  let modulo_fuerza_total_aux 0
  ask patches in-radius d_l with [tipo = "obstaculo"]
  [
    ; Distancia entre agentes
    let d_ij modulo list ([item 0 p] of myself - pxcor) ([item 1 p] of myself - pycor)
    ; Vector unitario en la dirección que une dos agentes
    if d_ij = 0 [set d_ij 0.01]
    let n_ij list (([item 0 p] of myself - pxcor) / d_ij) (([item 1 p] of myself - pycor) / d_ij)
    ; Suma de la anchura de dos agentes
    let r_ij [r] of myself + 0.5
    ;Termino auxiliar
    let r_d (r_ij - d_ij)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; CALCULO DEL TERMINO 2 y 3
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ifelse (d_ij < r_ij) ;Programacion de la funcion g(x)
    [ set termino_2 list (item 0 n_ij * k1 * r_d) (item 1 n_ij * k1 * r_d)
      let t_ij list (- item 1 n_ij) (item 0 n_ij)
      let dv_ji list ([item 0 v] of myself) ([item 1 v] of myself)
      set termino_3 list (k2 * r_d * item 0 dv_ji * item 0 t_ij) (k2 * r_d * item 1 dv_ji * item 1 t_ij)
    ]
    [ set termino_2 list 0 0
      set termino_3 list 0 0
    ]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; CALCULO DE LA FUERZA TOTAL RECIBIDA
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ifelse milisegundo < 11 ; Solo consideramos el término de separación por fuerza social cada segundo
    [ ; Primer término de la fuerza entre dos agentes
      set termino_1 list (A * e ^ (r_d / B) * item 0 n_ij) (A * e ^ (r_d / B) * item 1 n_ij)
    ]
    [
      set termino_1 list 0 0
    ]
    let f list ((item 0 termino_1) + (item 0 termino_2) + (item 0 termino_3)) ((item 1 termino_1) + (item 1 termino_2) + (item 1 termino_3))
    set fuerza_recibida list (item 0 fuerza_recibida + item 0 f) (item 1 fuerza_recibida + item 1 f)
    set modulo_fuerza_total_aux (modulo_fuerza_total_aux + modulo f)
]
  set modulo_fuerza_total modulo_fuerza_total + modulo_fuerza_total_aux
  report fuerza_recibida

end

to evacuate
  if milisegundo = 10 [
    set panic_medio 0
    let contador_pro 0
  ask personas[


    ; Calculo la velocidad asociada a llegar al objetivo
    set v_goal goal
    set g_medio (g_medio + (modulo v_goal))

    ; Calculo la velocidad por la interacción con otros agentes
    let v_m move
    ; Sumo los términos anteriores para calcular la velocidad total
    set v_nueva list (item 0 v_goal + item 0 v_m) (item 1 v_goal + item 1 v_m)
    ; Nos aseguramos que estamos dentro de los límites para la velocidad
    let mod_v_nueva modulo v_nueva
    if mod_v_nueva > v_max and mod_v_nueva != 0 [set v_nueva list ((v_max * (item 0 v_nueva)) / mod_v_nueva) ((v_max * (item 1 v_nueva)) / mod_v_nueva)]
    if mod_v_nueva < v_min and mod_v_nueva != 0 [set v_nueva list ((v_min * (item 0 v_nueva)) / mod_v_nueva) ((v_min * (item 1 v_nueva)) / mod_v_nueva)]

    ; Actualizo el pánico

    set panic panico
    if panic >= 0.5 [
      set m_s 0
      set m_l 0
      set m_o 0
      set v_nueva move
      let panico_medio 0
      let contador_cercanos 0
      ask personas with [modulo list ([item 0 p] of myself - [item 0 p] of self) ([item 1 p] of myself - [item 1 p] of self) < d_c and [who] of self != [who] of myself] [
        set panico_medio panico_medio + [panic] of self
        set contador_cercanos contador_cercanos + 1
      ]
      if contador_cercanos != 0 [
        set panic panico_medio / contador_cercanos
      ]
      set contador_pro contador_pro + 1
    ]
    set m_s 0 ;2.5
    set m_l 1.5
    set m_o 0 ;3.5
    ifelse count personas > 1 and para = 0
      [
        set g_medio (g_medio / count personas)
        set panic_medio (contador_pro / count personas)
      ] [stop]
    ]
    set milisegundo 0
  ]
  set v_media 0 ; Para representar la velocidad media de todas las personas
  ask personas[
    ; Elimino los agentes que han cruzado la puerta
    if [tipo] of patch-here = "puerta" [
      die
    ]
    ; Calculo las fuerzas
    if modulo_fuerza_total / (2 * r * pi) > T [set color blue set herido 1]
    set aceleracion_recibe (map [ i -> i / w ] (map + fuerzas fuerzas_patches))
    ; Consideramos una aceleración social añadida, que viene dada por la desviación de la velocidad objetivo que lleva cada persona y calculamos la aceleración total
    set aceleracion (map + (aceleracion_recibe) (map - v_nueva v))
    set v (map + v (map [ i -> i * 0.1 ] aceleracion))

    ; Nos aseguramos que estamos dentro de los límites para la velocidad
    let mod_v modulo v
    if mod_v > v_max and mod_v != 0 [set v list ((v_max * (item 0 v)) / mod_v) ((v_max * (item 1 v)) / mod_v)]
    if mod_v < v_min and mod_v != 0 [set v list ((v_min * (item 0 v)) / mod_v) ((v_min * (item 1 v)) / mod_v)]
    set v_media v_media + modulo v
    ; Actualizo la posición
    set p list (item 0 p + item 0 v * 0.1) (item 1 p + item 1 v * 0.1)
    set xcor (item 0 p)  set ycor (item 1 p)
  ]
  ifelse count personas > 1 and para = 0
  [
    set v_media (v_media / count personas)
  ] [stop]
  set milisegundo milisegundo + 1
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
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
0
0
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

INPUTBOX
6
11
161
71
numero_personas
700.0
1
0
Number

BUTTON
8
84
78
117
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
82
84
165
117
evacuate
;let c (count turtles)\n;repeat 25 [evacuate]\n\nif (count turtles < 1 ) [stop]\nevacuate
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
8
120
78
153
A
set escenario \"A\"\nprint \"Has elegido el escenario A\"
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
82
119
165
152
B
set escenario \"B\"\nprint \"Has elegido el escenario B\"
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
8
156
78
189
C
set escenario \"C\"\nprint \"Has elegido el escenario C\"
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
83
155
165
188
D
set escenario \"D\"\nprint \"Has elegido el escenario D\"
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
8
192
77
225
E
set escenario \"E\"\nprint \"Has elegido el escenario E\"
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
82
191
165
224
F
set escenario \"F\"\nprint \"Has elegido el escenario F\"
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
673
15
873
165
OUT
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
"default" 1.0 0 -16777216 true "" "plot (numero_personas - count turtles)"

PLOT
679
181
879
331
vMedia
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
"default" 1.0 0 -16777216 true "" "plot v_media"

PLOT
685
349
885
499
gMedio
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
"default" 1.0 0 -16777216 true "" "plot g_medio"

PLOT
1009
124
1209
274
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
"default" 1.0 0 -16777216 true "" "plot panic_medio"

MONITOR
1119
327
1196
372
milisegundo
milisegundo
17
1
11

BUTTON
48
249
111
282
NIL
reset
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
