;; NetLogo extensions
extensions [ table bitmap ]

;; Cria as breeds
breed [ pontes ponte ]
breed [ cercas cerca ]
breed [ empresas empresa ]
breed [ prefeituras prefeitura ]
breed [ fiscais fiscal ]
breed [ agricultores agricultor ]
breed [ empresarios empresario ]
breed [ prefeitos prefeito ]
;;breed [ vereadores vereador]

;; Cria as variáveis
agricultores-own [ id parcelas saldo producao poluicao  ]
empresarios-own [ setor produtos producao saldo poluicao ]

globals [global-polution simulation-round posicao-inicial posicao-parcelas sementes setores sementes-imagens
  tabela-produtividade tabela-poluicao-agricultor tabela-poluicao-empresario tabela-multa ]

to setup
  clear-all
  print-log (word "\n\n----------- Simulação: " date-and-time  " -----------")
  setup-inicial
  cria-area
  cria-agricultores
  cria-empresarios
  cria-fiscais
  cria-prefeito
  print-log "\nSETUP: Criação do Ambiente e dos Agentes... Feito! \n"
  reset-ticks
end

to print-log [text]
  file-open "gorim-log.txt"
  file-print text
  file-close
end

to write-log [text]
  file-open "gorim-log.txt"
  file-write text
  file-close
end

to show-log [text]
  file-open "gorim-log.txt"
  file-show text
  file-close
end

to setup-inicial
  ;; define a posição inicial dos agricultores
  set posicao-inicial table:make
  table:put posicao-inicial "a0" [-25 -6]
  table:put posicao-inicial "a1" [0 -6]
  table:put posicao-inicial "a2" [25 -6]
  table:put posicao-inicial "a3" [-25 -25]
  table:put posicao-inicial "a4" [0 -25]
  table:put posicao-inicial "a5" [25 -25]

  ;; define a posição inicial das fazendas
  table:put posicao-inicial "f0" [-25 -15]
  table:put posicao-inicial "f1" [0 -15]
  table:put posicao-inicial "f2" [25 -15]
  table:put posicao-inicial "f3" [-25 -34]
  table:put posicao-inicial "f4" [0 -34]
  table:put posicao-inicial "f5" [25 -34]

  ;; define a posição inicial dos empresarios
  table:put posicao-inicial "e0" [-23 21] ;; sementes
  table:put posicao-inicial "e1" [23 21] ;; agrotóxico
  table:put posicao-inicial "e2" [-28 34] ;; fertilizante
  table:put posicao-inicial "e3" [28 34] ;; maquinas

  ;; define a posição das parcelas de terra dos agricultores
  set posicao-parcelas table:make
  table:put posicao-parcelas "a0p0" [51 374]
  table:put posicao-parcelas "a0p1" [96 374]
  table:put posicao-parcelas "a0p2" [141 374]
  table:put posicao-parcelas "a0p3" [51 419]
  table:put posicao-parcelas "a0p4" [96 419]
  table:put posicao-parcelas "a0p5" [141 419]

  table:put posicao-parcelas "a1p0" [239 374]
  table:put posicao-parcelas "a1p1" [284 374]
  table:put posicao-parcelas "a1p2" [329 374]
  table:put posicao-parcelas "a1p3" [239 419]
  table:put posicao-parcelas "a1p4" [284 419]
  table:put posicao-parcelas "a1p5" [329 419]

  table:put posicao-parcelas "a2p0" [426 374]
  table:put posicao-parcelas "a2p1" [471 374]
  table:put posicao-parcelas "a2p2" [516 374]
  table:put posicao-parcelas "a2p3" [426 419]
  table:put posicao-parcelas "a2p4" [471 419]
  table:put posicao-parcelas "a2p5" [516 419]

  table:put posicao-parcelas "a3p0" [51 516]
  table:put posicao-parcelas "a3p1" [96 516]
  table:put posicao-parcelas "a3p2" [141 516]
  table:put posicao-parcelas "a3p3" [51 561]
  table:put posicao-parcelas "a3p4" [96 561]
  table:put posicao-parcelas "a3p5" [141 561]

  table:put posicao-parcelas "a4p0" [239 516]
  table:put posicao-parcelas "a4p1" [284 516]
  table:put posicao-parcelas "a4p2" [329 516]
  table:put posicao-parcelas "a4p3" [239 561]
  table:put posicao-parcelas "a4p4" [284 561]
  table:put posicao-parcelas "a4p5" [329 561]

  table:put posicao-parcelas "a5p0" [426 516]
  table:put posicao-parcelas "a5p1" [471 516]
  table:put posicao-parcelas "a5p2" [516 516]
  table:put posicao-parcelas "a5p3" [426 561]
  table:put posicao-parcelas "a5p4" [471 561]
  table:put posicao-parcelas "a5p5" [516 561]

  ;; define variáveis globais
  set global-polution 30
  set simulation-round 0
  set sementes ["hortalica" "arroz" "soja"]
  set sementes-imagens ["hortalica_20.png" "arroz_20.jpg" "soja_20.jpg"]

  ;; setores
  set setores table:make
  table:put setores "s" "sementes"
  table:put setores "a" "agrotoxicos"
  table:put setores "f" "fertilizantes"
  table:put setores "m" "maquinas"

  ;; tabela de produtividade
  set tabela-produtividade table:make
  table:put tabela-produtividade "0---" 10 ;; hortaliça
  table:put tabela-produtividade "1---" 10 ;; arroz
  table:put tabela-produtividade "2---" 10 ;; soja

  table:put tabela-produtividade "00--" 30  ;; hortaliça + agrotóxico comum
  table:put tabela-produtividade "01--" 60  ;; hortaliça + agrotóxico premium
  table:put tabela-produtividade "02--" 100 ;; hortaliça + agrotóxico super premium

  table:put tabela-produtividade "0-0-" 20 ;; hortaliça + fertilizante comum
  table:put tabela-produtividade "0-1-" 30 ;; hortaliça + fertilizante premium
  table:put tabela-produtividade "0-2-" 40 ;; hortaliça + fertilizante super premium

  table:put tabela-produtividade "000-" 60 ;; hortaliça + agrotóxico comum + fertilizante comum
  table:put tabela-produtividade "001-" 90 ;; hortaliça + agrotóxico comum + fertilizante premium
  table:put tabela-produtividade "002-" 120 ;; hortaliça + agrotóxico comum + fertilizante super premium
  table:put tabela-produtividade "010-" 120 ;; hortaliça + agrotóxico premium + fertilizante comum
  table:put tabela-produtividade "011-" 180 ;; hortaliça + agrotóxico premium + fertilizante premium
  table:put tabela-produtividade "012-" 240 ;; hortaliça + agrotóxico premium + fertilizante super premium
  table:put tabela-produtividade "020-" 200 ;; hortaliça + agrotóxico super premium + fertilizante comum
  table:put tabela-produtividade "021-" 300 ;; hortaliça + agrotóxico super premium + fertilizante premium
  table:put tabela-produtividade "022-" 400 ;; hortaliça + agrotóxico super premium + fertilizante super premium

  table:put tabela-produtividade "0--0" 30 ;; hortaliça + pacote-maquina 1
  table:put tabela-produtividade "0--1" 60 ;; hortaliça + pacote-maquina 2
  table:put tabela-produtividade "0--2" 100 ;; hortaliça + pacote-maquina 3
  table:put tabela-produtividade "0--3" table:get tabela-produtividade "0---" ;; hortaliça + pulverizador

  table:put tabela-produtividade "0-00" 60 ;; hortaliça + fertilizante comum + pacote-maquina 1
  table:put tabela-produtividade "0-01" 120 ;; hortaliça + fertilizante comum + pacote-maquina 2
  table:put tabela-produtividade "0-02" 200 ;; hortaliça + fertilizante comum + pacote-maquina 3
  table:put tabela-produtividade "0-03" table:get tabela-produtividade "0-0-" ;; hortaliça + fertilizante comum + pulverizador

  table:put tabela-produtividade "0-10" 90 ;; hortaliça + fertilizante premium + pacote-maquina 1
  table:put tabela-produtividade "0-11" 180 ;; hortaliça + fertilizante premium + pacote-maquina 2
  table:put tabela-produtividade "0-12" 300 ;; hortaliça + fertilizante premium + pacote-maquina 3
  table:put tabela-produtividade "0-13" table:get tabela-produtividade "0-1-" ;; hortaliça + fertilizante premium + pulverizador

  table:put tabela-produtividade "0-20" 120 ;; hortaliça + fertilizante super premium + pacote-maquina 1
  table:put tabela-produtividade "0-21" 240 ;; hortaliça + fertilizante super premium + pacote-maquina 2
  table:put tabela-produtividade "0-22" 400 ;; hortaliça + fertilizante super premium + pacote-maquina 3
  table:put tabela-produtividade "0-23" table:get tabela-produtividade "0-2-" ;; hortaliça + fertilizante super premium + pulverizador

  ;; se for arroz + agrotóxico -> duplica (2x) a quantidade final de produção
  ;; se for soja + agrotóxico -> triplica (3x) a quantidade final de produção
  ;; a tabela serve para todos os tipos de sementes, não importa se é hortaliça, arroz ou soja
  ;; não é possível comprar agrotóxico junto com máquinas

  ;; define a tabela de poluicao dos agricultores (poluicao por parcela de terra)
  ;; a poluição é gerada com o plantio de arroz, soja e hortaliça e com o uso de agrotóxico
  set tabela-poluicao-agricultor table:make
  table:put tabela-poluicao-agricultor "0-" 10 ;; hortaliça
  table:put tabela-poluicao-agricultor "1-" 20 ;; arroz
  table:put tabela-poluicao-agricultor "2-" 30 ;; soja

  table:put tabela-poluicao-agricultor "00" 30 ;; hortaliça + agrotóxico super premium
  table:put tabela-poluicao-agricultor "01" 60 ;; hortaliça + agrotóxico premium
  table:put tabela-poluicao-agricultor "02" 100 ;; hortaliça + agrotóxico comum

  table:put tabela-poluicao-agricultor "10" 60 ;; arroz + agrotóxico super premium
  table:put tabela-poluicao-agricultor "11" 120 ;; arroz + agrotóxico premium
  table:put tabela-poluicao-agricultor "12" 200 ;; arroz + agrotóxico comum

  table:put tabela-poluicao-agricultor "20" 90 ;; soja + agrotóxico super premium
  table:put tabela-poluicao-agricultor "21" 180 ;; soja + agrotóxico premium
  table:put tabela-poluicao-agricultor "22" 300 ;; soja + agrotóxico comum

  ;; define a tabela de poluicao dos empresarios
  ;; poluição é gerada após a venda dos produtos
  set tabela-poluicao-empresario table:make
  table:put tabela-poluicao-empresario "s0" 1 ;; empresario semente hortaliça
  table:put tabela-poluicao-empresario "s1" 2 ;; empresario semente arroz
  table:put tabela-poluicao-empresario "s2" 3 ;; empresario semente soja

  table:put tabela-poluicao-empresario "a0" 3 ;; empresario agrotóxico comum
  table:put tabela-poluicao-empresario "a1" 2 ;; empresario agrotóxico premium
  table:put tabela-poluicao-empresario "a2" 1 ;; empresario agrotóxico super premium

  table:put tabela-poluicao-empresario "f0" 9 ;; empresario fertilizante comum
  table:put tabela-poluicao-empresario "f1" 6 ;; empresario fertilizante premium
  table:put tabela-poluicao-empresario "f2" 3 ;; empresario fertilizante super premium

  table:put tabela-poluicao-empresario "m0" 3 ;; empresario maquina pacote-maquina 1
  table:put tabela-poluicao-empresario "m1" 6 ;; empresario maquina pacote-maquina 2
  table:put tabela-poluicao-empresario "m2" 9 ;; empresario maquina pacote-maquina 3
  table:put tabela-poluicao-empresario "m3" 40 ;; empresario maquina pulverizador

  ;; define a tabela de multas
  set tabela-multa table:make
end

to cria-area
  ;; cria a grama
  ask patches [ set pcolor green - random-float 0.5 ]

  ;; cria o rio
  ask patches with [pycor > -3 and pycor < 12] [
    set pcolor blue + 0.5;
  ]

  ;; cria as pontes
  set-default-shape pontes "tile stones"
  create-pontes 1 [
    set color grey
    set size 5
    setxy -20 -3
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy -20 2
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy -20 7
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy -20 12
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy 21 -3
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy 21 2
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy 21 7
  ]
  create-pontes 1 [
    set color grey
    set size 5
    setxy 21 12
  ]
    ask pontes [
    ask patch-here [
      ask neighbors [
        set pcolor red - 3
        ask neighbors [
          set pcolor red - 3
        ]
      ]
      set pcolor red - 3
    ]
  ]

  ;; cria as empresas dos empresários da direita
  set-default-shape empresas "factory-dir"
  create-empresas 1 [
    set color brown
    set size 18
    setxy 39 35
  ]

  ask patch 35 27 [
    set plabel "machine"
  ]

  create-empresas 1 [
    set color brown
    set size 18
    setxy 34 25
  ]

  ask patch 36 17 [
    set plabel "agrotoxic"
  ]

  ;;  cria as empresas dos empresários da esquerda
  set-default-shape empresas "factory-esq"
  create-empresas 1 [
    set color brown
    set size 18
    setxy -39 35
  ]

  ask patch -32 27 [
    set plabel "fertilizer"
  ]

  create-empresas 1 [
    set color brown
    set size 18
    setxy -34 25
  ]

  ask patch -32 17 [
    set plabel "seeds"
  ]

  ;; cria a prefeitura
  set-default-shape prefeituras "prefeitura"
  create-prefeituras 1 [
    set color (grey + 4)
    set size 18
    setxy 0 30
  ]
end

to cria-agricultores
  set-default-shape agricultores "agricultor"
  set-default-shape cercas "square 3"

  ;; cria os agricultores
  let i 0
  create-agricultores number-farmer [
    set size 5
    set color 137
    set label (word "f" i)
    move-to patch (item 0 table:get posicao-inicial (word "a" i)) (item 1 table:get posicao-inicial (word "a" i))

    set saldo 600
    set poluicao 0 ;; referente a rodada atual, começa com zero
    set producao 0 ;; referente a rodada atual, começa com zero
    set id i

    ;; cria as 6 paracelas de terra do agricultor
    set parcelas table:make

    set i (i + 1)
  ]

  ;; zera as 6 parcelas de terra de cada agricultor
  zera-parcelas

  ;; cria as fazendas
  set i 0
  create-cercas number-farmer [
    set size 20
    setxy (item 0 table:get posicao-inicial (word "f" i)) (item 1 table:get posicao-inicial (word "f" i))
    set i (i + 1)
  ]
end

to cria-empresarios
  set-default-shape empresarios "empresario"

  ;; "sementes" "agrotoxicos" "fertilizantes" "maquinas"
  let setores-aux ["s" "a" "f" "m"]

  ;; cria os 4 empresarios (1 - sementes; 2 - agrotóxico; 3 - fertilizantes 4 - maquinas )
  let i 0
  create-empresarios 4 [
    set size 5
    set color 137 - (i)
    set setor (item i setores-aux)
    setxy (item 0 table:get posicao-inicial (word "e" i)) (item 1 table:get posicao-inicial (word "e" i))

    set saldo 100
    set poluicao 0 ;; referente a rodada atual, começa com zero
    set producao 0 ;; referente a rodada atual, começa com zero

    set i (i + 1)
  ]

  ;; cria os produtos com seus respectivos preços
  ask empresarios [
    if setor = "s" [
      ;; key é o códido do produto, e chave é o preço e quantidade de produtos vendidos
      set produtos table:make
      table:put produtos 0 [10 0] ;; hortalica
      table:put produtos 1 [20 0] ;; arroz
      table:put produtos 2 [30 0] ;; soja
    ]

    if setor = "a" [
      ;; key é o códido do produto, e chave é o preço e quantidade de produtos vendidos
      set produtos table:make
      table:put produtos 0 [10 0] ;; comum
      table:put produtos 1 [20 0] ;; premium
      table:put produtos 2 [30 0] ;; super-premium
    ]

    if setor = "f" [
      ;; key é o códido do produto, e chave é o preço e quantidade de produtos vendidos
      set produtos table:make
      table:put produtos 0 [30 0] ;; comum
      table:put produtos 1 [60 0] ;; premium
      table:put produtos 2 [90 0] ;; super-premium
    ]

    if setor = "m" [
      ;; key é o códido do produto, e chave é o preço e quantidade de produtos vendidos
      set produtos table:make
      table:put produtos 0 [30 0] ;; pacote 1
      table:put produtos 1 [60 0] ;; pacote 2
      table:put produtos 2 [90 0] ;; pacote 3

      ;; somente tem efeito no cálculo da poluição do empresário
      ;; na produção do agricultor, não faz diferença
      table:put produtos 3 [400 0] ;; pulverizador
    ]
  ]

end

to cria-fiscais
  set-default-shape fiscais "fiscal"

  create-fiscais 1 [
    set size 5
    set color brown
    set label "supervisor"
    setxy -5 19
  ]

end

to cria-prefeito
  set-default-shape prefeitos "prefeito"

  create-prefeitos 1 [
    set size 5
    set color brown + 1
    set label "mayor"
    setxy 0 19
  ]
end

to go
  atualiza-rodada ;; zera os valores das parcelas, producao (TODO) e poluicao (TODO)

  print-log-saldo

  compra-venda-produtos ;; agricultor e empresarios

  print-log-saldo-agricultores
  print-log-producao-empresarios

  atualiza-poluicao-empresarios ;; empresário: após a venda/aluguel de produtos
  print-log-poluicao-empresarios

  planta ;; agricultor

  atualiza-producao-agricultores ;; agricultor: após a plantação
  atualiza-poluicao-agricultores ;;  agricultor: após a plantação

  print-log-producao-agricultores
  print-log-poluicao-agricultores

  ;; fiscaliza ;; fiscal
  ;; paga-imposto ;; agricultor e empresarios

   ;; TODO
  atualiza-saldo-agricultores ;; agricultor: após pagar os impostos, possíveis multas
  atualiza-saldo-empresarios ;; empresarios: após pagar os impostos, possíveis multas

  ;; atualiza-poluicao-global

  ;; aplica-medidas-prevencao-poluicao ;; prefeito: após atualizar poluição global


  tick
end

to atualiza-rodada
  ;; zera as percelas de terra de todos os agricultores
  zera-parcelas
  zera-producao-e-poluicao
  zera-quantidade-produtos-vendidos

  ;; apaga na interface as imagens nas parcelas
  clear-drawing

  set simulation-round simulation-round + 1

  print-log "******************************"
  print-log (word "*********  RODADA " simulation-round "  *********")
  print-log "******************************"
end

to zera-parcelas
  ask agricultores [
    let p 0
    while [p < 6] [
      table:put parcelas (word "p" p "s") "-"
      table:put parcelas (word "p" p "a") "-"
      table:put parcelas (word "p" p "f") "-"
      table:put parcelas (word "p" p "m") "-"
      table:put parcelas (word "p" p "p") "-"
      table:put parcelas (word "p" p "producao") "-"
      table:put parcelas (word "p" p "poluicao") "-"

      set p (p + 1)
    ]
  ]
end

to zera-producao-e-poluicao
  ask agricultores [
    set producao 0
    set poluicao 0
  ]

  ask empresarios [
    set producao 0
    set poluicao 0
  ]
end

to zera-quantidade-produtos-vendidos
  ask empresarios [
    let p 0 ;; produto
    let quant 3 ;; quantidade de produtos por setor

    ;; os setores sementes, agrotóxico e fertilizantes têm 3 produtos
    ;; no setor de máquinas, há 4 produtos
    if setor = "m" [
      set quant 4
    ]

    while [p < quant] [
      let valor-produto (item 0 (table:get produtos p))

      ;; atualiza a quantidade de produtos vendido
      ;; valor do produto não pode alterar
      table:put produtos p (list valor-produto 0)
      set p p + 1
    ]
  ]
end

to compra-venda-produtos
  compra-semente
  ;; compra-agrotoxico
  ;; compra-fertilizante
  ;; compra-maquina
end

to compra-semente
  ;; cada agricultor deve comprar pelo menos 1 semente dos 3 tipos
  ;; TODO Permitir agricultores plantarem mais de um tipo de semente em suas plantações
  ask agricultores [
    let s random 3 ;; semente aleatória
    if type-of-seed = "vegetable" [
      set s 0
    ]
    if type-of-seed = "rice" [
      set s 1
    ]
    if type-of-seed = "soy" [
      set s 2
    ]

    let p (random 6) + 1 ;; quantidade aleatória de parcelas (de 1 a 6)
    let valorsem 0

    ask empresarios with [setor = "s"] [
      ;; valor da semente
      set valorsem (item 0 (table:get produtos s))
    ]

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior que o valor da semente, então COMPRA
    if saldo > p * valorsem [
      ask empresarios with [setor = "s"] [
        ;; atualiza o produção (ganhos) do empresario, após a venda
        set producao (producao + p * valorsem)

        let quantsem (item 1 (table:get produtos s))

        ;; atualiza a quantidade de produtos vendido
        ;; valor do produto não pode alterar
        table:put produtos s (list valorsem (quantsem + p))
      ]

      print-log (word "agricultor " id " comprou " p " saco(s) de " (item s sementes) " ($" valorsem ")" " por R$ " (p * valorsem))

      ;; atualiza o saldo do agricultor
      set saldo (saldo - p * valorsem)

      let i 0
      while [i < p] [ ;; atualiza nas parcelas qual semente foi comprada
        table:put parcelas (word "p" i "s") s
        set i i + 1
      ]
    ]
  ]
end

to compra-agrotoxico
  ;; cada agricultor pode comprar ou não agrotóxico
  let continua random 2
  if continua = 1 [

    ask agricultores [
      ;; seleciona agricultores aleatórios

    ]
  ]
end

to atualiza-poluicao-empresarios
  ask empresarios [
    let p 0 ;; produto
    let quant 3 ;; quantidade de produtos por setor

    ;; os setores sementes, agrotóxico e fertilizantes têm 3 produtos
    ;; no setor de máquinas, há 4 produtos
    if setor = "m" [
      set quant 4
    ]

    while [p < quant] [
      let quant-produtos-vendidos (item 1 (table:get produtos p))
      if quant-produtos-vendidos > 0 [
        set poluicao poluicao + quant-produtos-vendidos * (table:get tabela-poluicao-empresario (word setor p))
      ]
      set p p + 1
    ]
  ]
end

to planta
  ;; realiza a plantação das sementes
  ask agricultores [
    let p 0
    let plantou false
    while [p < 6] [
      let s table:get parcelas (word "p" p "s")

      if s != "-" [ ;; verifica se tem semente comprada para esta parcela
        set plantou true

        let x (item 0 (table:get posicao-parcelas (word "a" id "p" p)))
        let y (item 1 (table:get posicao-parcelas (word "a" id "p" p)))

        ;; realiza a plantação
        bitmap:copy-to-drawing (bitmap:import (item s sementes-imagens)) x y
      ]

      set p p + 1
    ]

    if plantou [
      print-log (word "agricultor " id " finalizou a plantação!")
    ]
  ]
end

to atualiza-producao-agricultores
  ask agricultores [
    let p 0
    while [p < 6] [
      let s table:get parcelas (word "p" p "s")
      let a table:get parcelas (word "p" p "a")
      let f table:get parcelas (word "p" p "f")
      let m table:get parcelas (word "p" p "m")

      if s != "-" [ ;; verifica se tem semente comprada para esta parcela
        let ganho-parcela table:get tabela-produtividade (word s a f m)

        ;; atualiza a produtividade da parcela
        table:put parcelas (word "p" p "producao") ganho-parcela

        ;; atualiza a produtividade total do agricultor (soma da produção de cada parcela)
        set producao producao + ganho-parcela
      ]

      set p p + 1
    ]
  ]
end

to atualiza-saldo-agricultores
  ask agricultores [
    set saldo saldo + producao
  ]
end

to atualiza-saldo-empresarios
  ask empresarios [
    set saldo saldo + producao
  ]
end

to atualiza-poluicao-agricultores
  ask agricultores [
    let p 0
    while [p < 6] [
      let s table:get parcelas (word "p" p "s")
      let a table:get parcelas (word "p" p "a")

      if s != "-" [ ;; verifica se tem semente comprada para esta parcela
        let poluicao-parcela table:get tabela-poluicao-agricultor (word s a)

        ;; atualiza a poluicao da parcela
        table:put parcelas (word "p" p "poluicao") poluicao-parcela

        ;; atualiza a poluicao individual do agricultor (soma da poluicao de cada parcela)
        set poluicao poluicao + poluicao-parcela
      ]

      set p p + 1
    ]
  ]
end

to print-log-saldo-agricultores
  print-log ""
  ask agricultores [
    print-log (word "Saldo atual: agricultor " id ": " saldo)
  ]
  print-log ""
end

to print-log-saldo
  print-log ""
  ask agricultores [
    print-log (word "Saldo atual: agricultor " id ": " saldo)
  ]
  print-log ""
  ask empresarios [
    print-log (word "Saldo atual: empresário de "  (table:get setores setor) ": " saldo)
  ]
  print-log ""
end

to print-log-producao-agricultores
  print-log ""
  ask agricultores [
    if producao > 0 [
      print-log (word "Ganhos do agricultor " id ": " producao)
    ]
  ]
  print-log ""
end

to print-log-producao-empresarios
  ;; print-log ""
  ask empresarios [
    if producao > 0 [
      print-log (word "Ganhos do empresário de "  (table:get setores setor) ": " producao)
    ]
  ]
  print-log ""
end

to print-log-poluicao-agricultores
  ;; print-log ""
  ask agricultores [
    print-log (word "Poluição do agricultor " id ": " poluicao)
  ]
  print-log ""
end

to print-log-poluicao-empresarios
  ;; print-log ""
  ask empresarios [
    print-log (word "Poluição do empresário de "  (table:get setores setor) ": " poluicao)
  ]
  print-log ""
end

to atualiza-cor-rio
  let x 0
  if global-polution < 20 [
    set pcolor blue + 0.5
  ]
  if global-polution >= 20 and global-polution <= 39 [
    set x 0.66
  ]
  if global-polution >= 40 and global-polution <= 59 [
    set x 1.32
  ]
  if global-polution >= 60 and global-polution <= 69 [
    set x 1.98
  ]
  if global-polution >= 70 and global-polution <= 79 [
    set x 2.64
  ]
  if global-polution >= 80 and global-polution <= 89 [
    set x 3.3
  ]
  if global-polution >= 90 and global-polution <= 100 [
    set x 3.96
  ]
  ask patches with [pycor > -3 and pycor < 12] [
    set pcolor blue + 0.5 - x - random-float 0.25
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
825
626
-1
-1
7.5
1
10
1
1
1
0
0
0
1
-40
40
-40
40
0
0
1
ticks
30.0

BUTTON
20
39
83
72
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
102
39
165
72
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

SLIDER
20
93
192
126
number-farmer
number-farmer
1
6
6.0
1
1
NIL
HORIZONTAL

CHOOSER
21
186
159
231
type-of-agrotoxic
type-of-agrotoxic
"random" "common" "premium" "super-premium" "no-agrotoxic"
0

CHOOSER
22
285
160
330
type-of-machine
type-of-machine
"random" "combination-1" "combination-2" "combination-3" "no-machine"
0

CHOOSER
21
236
159
281
type-of-fertilizer
type-of-fertilizer
"random" "commum" "premium" "super-premium" "no-fertilizer"
0

CHOOSER
20
137
158
182
type-of-seed
type-of-seed
"random" "vegetable" "rice" "soy"
2

SWITCH
21
456
175
489
water-treatment?
water-treatment?
0
1
-1000

SWITCH
21
493
176
526
waste-treatment?
waste-treatment?
0
1
-1000

SWITCH
21
530
185
563
sewage-treatment?
sewage-treatment?
0
1
-1000

MONITOR
944
11
1038
56
global-polution
(word global-polution \"%\")
17
1
11

MONITOR
833
11
937
56
simulation-round
simulation-round
17
1
11

MONITOR
833
85
990
130
farmer-0-account-balance
[saldo] of agricultores with [id = 0]
17
1
11

MONITOR
833
135
990
180
farmer-1-account-balance
[saldo] of agricultores with [id = 1]
17
1
11

MONITOR
833
185
990
230
farmer-2-account-balance
[saldo] of agricultores with [id = 2]
17
1
11

MONITOR
833
234
990
279
farmer-3-account-balance
[saldo] of agricultores with [id = 3]
17
1
11

MONITOR
833
284
990
329
farmer-4-account-balance
[saldo] of agricultores with [id = 4]
17
1
11

MONITOR
834
333
991
378
farmer-5-account-balance
[saldo] of agricultores with [id = 5]
17
1
11

MONITOR
836
404
1052
449
businessman-seeds-account-balance
[saldo] of empresarios with [setor = \"s\"]
17
1
11

MONITOR
836
453
1071
498
businessman-agrotoxic-account-balance
[saldo] of empresarios with [setor = \"a\"]
17
1
11

MONITOR
836
502
1064
547
businessman-fertilizer-account-balance
[saldo] of empresarios with [setor = \"f\"]
17
1
11

MONITOR
837
551
1065
596
businessman-machine-account-balance
[saldo] of empresarios with [setor = \"m\"]
17
1
11

MONITOR
999
84
1124
129
farmer-0-gain
[producao] of agricultores with [id = 0]
17
1
11

MONITOR
999
135
1088
180
farmer-1-gain
[producao] of agricultores with [id = 1]
17
1
11

MONITOR
1000
185
1089
230
farmer-2-gain
[producao] of agricultores with [id = 2]
17
1
11

MONITOR
1001
234
1090
279
farmer-3-gain
[producao] of agricultores with [id = 3]
17
1
11

MONITOR
1001
283
1090
328
farmer-4-gain
[producao] of agricultores with [id = 4]
17
1
11

MONITOR
1002
333
1091
378
farmer-5-gain
[producao] of agricultores with [id = 5]
17
1
11

CHOOSER
22
334
160
379
use-of-pulverizer
use-of-pulverizer
"random" "pulverizer" "no-pulverizer"
0

SWITCH
23
401
131
434
fine?
fine?
0
1
-1000

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

agricultor
false
0
Rectangle -7500403 true true 135 75 165 94
Polygon -7500403 true true 120 90 120 180 105 270 105 270 135 270 150 210 165 270 195 270 195 270 180 180 180 90
Polygon -1 true false 75 165 90 180 120 120 120 195 180 195 180 120 210 180 225 165 195 90 165 90 150 105 150 105 135 90 105 90
Circle -7500403 true true 108 3 84
Polygon -13345367 true false 120 90 120 150 120 165 105 255 105 270 135 270 150 210 165 270 195 270 195 270 180 165 180 90 180 90 165 120 135 120 120 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 30 188 36 224 23 222 14 180 15 180 0

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

casa
false
0
Rectangle -7500403 true true 15 165 285 255
Rectangle -1 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -13791810 true false 30 180 105 240
Rectangle -13791810 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -16777216 true false 0 165 150 90 150 120 150 90 210 120 300 165

casadupla
false
0
Polygon -6459832 true false 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 75 135 270 255
Rectangle -6459832 true false 124 195 187 256
Rectangle -11221820 true false 210 195 255 240
Rectangle -11221820 true false 90 150 135 180
Rectangle -11221820 true false 150 150 195 180
Rectangle -7500403 true true 15 180 75 255
Polygon -6459832 true false 60 135 285 135 240 90 105 90
Line -6459832 false 75 135 75 180
Rectangle -11221820 true false 30 195 93 240
Line -6459832 false 60 135 285 135
Line -6459832 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255
Rectangle -11221820 true false 210 150 255 180

casasimples
false
0
Rectangle -6459832 true false 255 120 270 255
Rectangle -7500403 true true 15 180 270 255
Polygon -955883 true false 0 180 300 180 240 135 60 135 0 180
Rectangle -1 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -11221820 true false 45 195 105 240
Rectangle -11221820 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -955883 false 0 180 300 180

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

empresario
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -16777216 true false 120 90 105 90 75 180 90 195 120 135 120 180 105 285 120 285 135 285 150 225 165 285 195 285 195 285 180 180 180 135 210 195 225 180 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 135 75 165 91
Polygon -13345367 true false 195 210 195 285 270 255 270 180
Rectangle -13791810 true false 180 210 195 285
Polygon -14835848 true false 180 211 195 211 270 181 255 181
Polygon -13345367 true false 209 187 209 201 244 187 243 173

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

factory-dir
false
15
Rectangle -7500403 true false 75 150 285 270
Rectangle -7500403 true false 30 120 59 231
Rectangle -11221820 true false 90 210 270 240
Line -7500403 false 90 195 90 255
Line -7500403 false 90 225 270 225
Circle -1 true true 22 103 32
Circle -1 true true 25 68 54
Circle -1 true true 51 51 42
Circle -1 true true 75 70 32
Circle -1 true true 69 34 42
Rectangle -7500403 true false 14 228 78 270
Rectangle -11221820 true false 90 165 270 195
Line -7500403 false 90 180 270 180
Line -7500403 false 120 150 120 255
Line -7500403 false 150 150 150 240
Line -7500403 false 180 150 180 255
Line -7500403 false 210 150 210 240
Line -7500403 false 240 165 240 240

factory-esq
false
15
Rectangle -7500403 true false 15 150 225 270
Rectangle -7500403 true false 241 120 270 231
Rectangle -11221820 true false 30 210 210 240
Line -7500403 false 210 195 210 255
Line -7500403 false 210 225 30 225
Circle -1 true true 246 103 32
Circle -1 true true 221 68 54
Circle -1 true true 207 51 42
Circle -1 true true 193 70 32
Circle -1 true true 189 34 42
Rectangle -7500403 true false 222 228 286 270
Rectangle -11221820 true false 30 165 210 195
Line -7500403 false 210 180 30 180
Line -7500403 false 180 150 180 255
Line -7500403 false 150 150 150 240
Line -7500403 false 120 150 120 255
Line -7500403 false 90 150 90 240
Line -7500403 false 60 165 60 240

fiscal
false
0
Polygon -1 true false 124 91 135 195 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 105 285 105 285 135 285 150 225 165 285 195 285 195 285
Polygon -13345367 true false 120 90 120 90 75 165 90 180 120 135 120 195 180 195 180 135 210 180 225 165 180 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 138 75 165 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -16777216 false 150 105 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24

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

prefeito
false
0
Rectangle -1 true false 120 150 180 210
Rectangle -7500403 true true 135 75 165 95
Polygon -1 true false 120 90 75 180 90 195 120 150 180 150 210 195 225 180 180 90
Polygon -16777216 true false 180 180 120 180 105 270 105 285 135 285 150 210 165 285 195 285 195 270
Circle -7500403 true true 110 5 80
Circle -16777216 true false 150 105 0
Circle -16777216 true false 150 105 0
Circle -16777216 true false 150 105 0
Circle -16777216 false false 150 135 0
Line -7500403 true 150 90 150 180
Polygon -13345367 true false 135 90 165 90 150 105 135 90 150 105 150 105
Polygon -13345367 true false 150 105 135 120 150 165 165 120 150 105

prefeitura
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Polygon -7500403 true true 0 60 150 15 300 60
Circle -1 true false 135 26 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

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
Rectangle -6459832 true false 105 120 120 210
Rectangle -6459832 true false 180 120 195 225
Rectangle -6459832 true false 105 210 180 225
Rectangle -6459832 true false 135 105 195 120
Rectangle -6459832 true false 105 105 135 120

square 3
false
0
Rectangle -6459832 true false 0 60 15 240
Rectangle -6459832 true false 285 60 300 240
Rectangle -6459832 true false 0 240 300 255
Rectangle -6459832 true false 0 45 300 60
Line -6459832 false 15 150 285 150
Line -6459832 false 105 60 105 240
Line -16777216 false 15 240 285 240
Line -6459832 false 195 60 195 240
Line -16777216 false 285 60 285 240
Line -16777216 false 15 60 285 60
Line -16777216 false 15 60 15 240

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

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

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
NetLogo 6.1.0
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
