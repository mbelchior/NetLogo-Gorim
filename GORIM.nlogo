;; NetLogo extensions
extensions [ table bitmap ]

;; Cria as breeds
breed [ pontes ponte ]
breed [ cercas cerca ] ;; farm
breed [ empresas empresa ]
breed [ prefeituras prefeitura ]
breed [ fiscais fiscal ]
breed [ agricultores agricultor ]
breed [ empresarios empresario ]
breed [ prefeitos prefeito ]
;;breed [ vereadores vereador]

;; Cria as variáveis
agricultores-own [ id parcelas saldo producao poluicao multa quant-semente-plantada ]
empresarios-own [ setor produtos producao saldo poluicao multa ]
prefeitos-own [ saldo ]

globals [ global-pollution simulation-round posicao-inicial posicao-parcelas tipos-semente tipos-agrotoxico tipos-fertilizante tipos-maquina setores
  sementes-imagens agrotoxico-imagens fertilizante-imagens maquina-imagens selo-verde-imagem
  tabela-produtividade tabela-poluicao-agricultor tabela-poluicao-empresario tabela-poluicao-produtividade
  tipos-multa reducao-poluicao medida-prevencao
  caminho-prefeito caminho-fiscal-to-farmers caminho-fiscal-to-businessman
  caminho-agricultores-para-empresario-semente caminho-agricultores-para-empresario-agrotoxico caminho-agricultores-para-empresario-fertilizante
  caminho-agricultores-para-empresario-maquina
  stop? tempo-espera-movimentacao ]

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
  table:put posicao-inicial "f1" [1 -15]
  table:put posicao-inicial "f2" [27 -15]
  table:put posicao-inicial "f3" [-25 -34]
  table:put posicao-inicial "f4" [1 -34]
  table:put posicao-inicial "f5" [27 -34]

  ;; define a posição inicial dos empresarios
  table:put posicao-inicial "e0" [-23 21] ;; sementes
  table:put posicao-inicial "e1" [23 21] ;; agrotóxico
  table:put posicao-inicial "e2" [-28 34] ;; fertilizante
  table:put posicao-inicial "e3" [28 34] ;; maquinas

  ;; define a posição das parcelas de terra dos agricultores
  set posicao-parcelas table:make
  table:put posicao-parcelas "a0p0" [35 374]
  table:put posicao-parcelas "a0p1" [88 374]
  table:put posicao-parcelas "a0p2" [140 374]
  table:put posicao-parcelas "a0p3" [35 419]
  table:put posicao-parcelas "a0p4" [88 419]
  table:put posicao-parcelas "a0p5" [140 419]

  table:put posicao-parcelas "a1p0" [230 374]
  table:put posicao-parcelas "a1p1" [283 374]
  table:put posicao-parcelas "a1p2" [335 374]
  table:put posicao-parcelas "a1p3" [230 419]
  table:put posicao-parcelas "a1p4" [283 419]
  table:put posicao-parcelas "a1p5" [335 419]

  table:put posicao-parcelas "a2p0" [425 374]
  table:put posicao-parcelas "a2p1" [478 374]
  table:put posicao-parcelas "a2p2" [530 374]
  table:put posicao-parcelas "a2p3" [425 419]
  table:put posicao-parcelas "a2p4" [478 419]
  table:put posicao-parcelas "a2p5" [530 419]

  table:put posicao-parcelas "a3p0" [35 516]
  table:put posicao-parcelas "a3p1" [88 516]
  table:put posicao-parcelas "a3p2" [140 516]
  table:put posicao-parcelas "a3p3" [35 561]
  table:put posicao-parcelas "a3p4" [88 561]
  table:put posicao-parcelas "a3p5" [140 561]

  table:put posicao-parcelas "a4p0" [230 516]
  table:put posicao-parcelas "a4p1" [283 516]
  table:put posicao-parcelas "a4p2" [335 516]
  table:put posicao-parcelas "a4p3" [230 561]
  table:put posicao-parcelas "a4p4" [283 561]
  table:put posicao-parcelas "a4p5" [335 561]

  table:put posicao-parcelas "a5p0" [425 516]
  table:put posicao-parcelas "a5p1" [478 516]
  table:put posicao-parcelas "a5p2" [530 516]
  table:put posicao-parcelas "a5p3" [425 561]
  table:put posicao-parcelas "a5p4" [478 561]
  table:put posicao-parcelas "a5p5" [530 561]

  ;; define variáveis globais
  set global-pollution 20
  set simulation-round 0
  set reducao-poluicao 0
  set tipos-semente ["hortalica" "arroz" "soja"]
  set tipos-agrotoxico ["comum" "premium" "super premium"]
  set tipos-fertilizante ["comum" "premium" "super premium"]
  set tipos-maquina ["pacote 1 - semeadora" "pacote 2 - semeadora e colheitadeira" "pacote 3 - semeadora, colheitadeira e drone"]
  set sementes-imagens ["icones/semente_hortalica.png" "icones/semente_arroz.png" "icones/semente_soja.png"]
  set agrotoxico-imagens ["icones/agrotoxico_comum.png" "icones/agrotoxico_premium.png" "icones/agrotoxico_super_premium.png"]
  set fertilizante-imagens ["icones/fertilizante_comum.png" "icones/fertilizante_premium.png" "icones/fertilizante_super_premium.png"]
  set maquina-imagens ["icones/maquina_semeadora.png" "icones/maquina_colheitadeira.png" "icones/maquina_drone.png" "icones/maquina_pulverizador.png"]
  set selo-verde-imagem "icones/selo.png"
  set tipos-multa ["sem multa" "multa leve" "multa média" "multa alta"]
  set medida-prevencao [ "água" "lixo" "esgoto" ]
  set stop? false

  ;; agent-movement-speed -> 1 a 10
  ;; tempo-espera-movimentacao -> 0.1 a 0.01
  ;; atualiza a velocidade dos agentes
  set tempo-espera-movimentacao 0.1 / agent-movement-speed

  ;; poluição global mostrada no rio
  atualiza-poluicao-global-interface

  ;; Caminhos
  set caminho-prefeito [[0 19] [0 17] [0 15] [0 13]]

  let caminho-0-fiscal [[-5 19] [-5 15] [-9 15] [-13 15] [-17 15] [-20 15] [-20 11] [-20 7] [-20 3] [-20 -1] [-20 -6] [-22 -6] [-22 -6]]
  let caminho-1-fiscal [[-5 19] [-5 15] [-9 15] [-13 15] [-17 15] [-20 15] [-20 11] [-20 7] [-20 3] [-20 -1] [-20 -6] [-16 -6] [-12 -6] [-8 -6] [-3 -6] [-3 -6] ]
  let caminho-2-fiscal [[-5 19] [-5 15] [-1 15] [3 15] [7 15] [12 15] [17 15] [21 15] [21 11] [21 7] [21 3] [21 -1] [21 -6] [22 -6] [22 -6]]
  let caminho-3-fiscal [[-5 19] [-5 15] [-9 15] [-13 15] [-17 15] [-20 15] [-20 11] [-20 7] [-20 3] [-20 -1] [-20 -6] [-16 -6] [-12 -6] [-12 -10] [-12 -14] [-12 -18] [-12 -22] [-12 -25] [-16 -25] [-20 -25] [-22 -25] [-22 -25]]
  let caminho-4-fiscal [[-5 19] [-5 15] [-9 15] [-13 15] [-17 15] [-20 15] [-20 11] [-20 7] [-20 3] [-20 -1] [-20 -6] [-16 -6] [-12 -6] [-12 -10] [-12 -14] [-12 -18] [-12 -22] [-12 -25] [-8 -25] [-3 -25] [-3 -25]]
  let caminho-5-fiscal [[-5 19] [-5 15] [-1 15] [3 15] [7 15] [12 15] [17 15] [21 15] [21 11] [21 7] [21 3] [21 -1] [21 -6] [15 -6] [12 -6] [12 -10] [12 -14] [12 -18] [12 -22] [12 -25] [17 -25] [22 -25]]
  set caminho-fiscal-to-farmers (list caminho-0-fiscal caminho-1-fiscal caminho-2-fiscal caminho-3-fiscal caminho-4-fiscal caminho-5-fiscal)

  set caminho-fiscal-to-businessman [[-5 19] [-9 19] [-13 19] [-17 19] [-19 19] [-19 21] [-19 21] ;; até empresário de sementes
    [-19 25] [-19 29] [-19 34] [-21 34] [-24 34] [-24 34] ;;até empresário de fertilizantes
    [-21 34] [-18 34] [-14 34] [-14 30] [-14 26] [-14 22] [-14 18] [-14 15] [-10 15] [-6 15] [-2 15] [2 15] [6 15] [10 15] [14 15] [14 19] [14 21] [18 21] [20 21] [20 21] ;; até empresário de agrotóxico
    [20 25] [20 29] [20 34] [25 34] [25 34] ;; até empresário de máquinas
    [21 34] [16 34] [16 30] [16 26] [16 22] [16 18] [16 15] [12 15] [8 15] [4 15] [0 15] [-5 15] [-5 19] ] ;; volta para a origem


  let caminho-agricultor-0-sementes [[-25 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-19 21] [-19 21]]
  let caminho-agricultor-1-sementes [[0 -6] [-4 -6] [-8 -6] [-12 -6] [-16 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-19 21] [-19 21]]
  let caminho-agricultor-2-sementes [[25 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [17 15] [13 15] [8 15] [4 15] [0 15] [-4 15] [-8 15] [-12 15] [-15 15] [-15 18] [-15 21] [-19 21] [-19 21]]
  let caminho-agricultor-3-sementes [[-25 -25] [-21 -25] [-17 -25] [-13 -25] [-13 -21] [-13 -17] [-13 -13] [-13 -9] [-13 -6] [-17 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 19] [-19 21] [-19 21] ]
  let caminho-agricultor-4-sementes [[0 -25] [-4 -25] [-8 -25] [-12 -25] [-12 -21] [-12 -17] [-12 -13] [-12 -9] [-12 -6] [-16 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 19] [-19 21] [-19 21]]
  let caminho-agricultor-5-sementes [[25 -25] [21 -25] [17 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [17 15] [13 15] [8 15] [4 15] [0 15] [-4 15] [-8 15] [-12 15] [-15 15] [-15 18] [-15 21] [-19 21] [-19 21]]

  set caminho-agricultores-para-empresario-semente (list caminho-agricultor-0-sementes caminho-agricultor-1-sementes caminho-agricultor-2-sementes caminho-agricultor-3-sementes caminho-agricultor-4-sementes caminho-agricultor-5-sementes)

  let caminho-agricultor-0-agrotoxico [[-25 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-17 18] [-14 18] [-14 15] [-10 15] [-6 15] [-2 15] [2 15] [6 15] [10 15] [14 15] [14 19] [14 21] [18 21] [20 21] [20 21]]
  let caminho-agricultor-1-agrotoxico [[0 -6] [4 -6] [9 -6] [13 -6][17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [20 21] [20 21]]
  let caminho-agricultor-2-agrotoxico [[25 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [20 21] [20 21]]
  let caminho-agricultor-3-agrotoxico [[-25 -25] [-21 -25] [-17 -25] [-13 -25] [-13 -21] [-13 -17] [-13 -13] [-13 -9] [-13 -6] [-17 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 18] [-17 18] [-14 18] [-14 15] [-10 15] [-6 15] [-2 15] [2 15] [6 15] [10 15] [14 15] [14 19] [14 21] [18 21] [20 21] [20 21]]
  let caminho-agricultor-4-agrotoxico [[0 -25] [4 -25] [9 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [20 21] [20 21]]
  let caminho-agricultor-5-agrotoxico [[25 -25] [21 -25] [17 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [20 21] [20 21]]

  set caminho-agricultores-para-empresario-agrotoxico (list caminho-agricultor-0-agrotoxico caminho-agricultor-1-agrotoxico caminho-agricultor-2-agrotoxico caminho-agricultor-3-agrotoxico caminho-agricultor-4-agrotoxico caminho-agricultor-5-agrotoxico)

  let caminho-agricultor-0-fertilizante [[-25 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-20 22] [-20 26] [-20 30] [-20 34] [-24 34] [-24 34]]
  let caminho-agricultor-1-fertilizante [[0 -6] [-4 -6] [-8 -6] [-12 -6] [-16 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-20 22] [-20 26] [-20 30] [-20 34] [-24 34] [-24 34]]
  let caminho-agricultor-2-fertilizante [[25 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [17 15] [13 15] [8 15] [4 15] [0 15] [-4 15] [-8 15] [-12 15] [-15 15] [-15 19] [-15 23] [-15 27] [-15 31] [-15 34] [-19 34] [-24 34] [-24 34]]
  let caminho-agricultor-3-fertilizante [[-25 -25] [-21 -25] [-17 -25] [-13 -25] [-13 -21] [-13 -17] [-13 -13] [-13 -9] [-13 -6] [-17 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 18] [-20 22] [-20 26] [-20 30] [-20 34] [-24 34] [-24 34]]
  let caminho-agricultor-4-fertilizante [[0 -25] [-4 -25] [-8 -25] [-12 -25] [-12 -21] [-12 -17] [-12 -13] [-12 -9] [-12 -6] [-16 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 18] [-20 22] [-20 26] [-20 30] [-20 34] [-24 34] [-24 34]]
  let caminho-agricultor-5-fertilizante [[25 -25] [21 -25] [17 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [17 15] [13 15] [8 15] [4 15] [0 15] [-4 15] [-8 15] [-12 15] [-15 15] [-15 18] [-15 22] [-15 26] [-15 30] [-15 34] [-19 34] [-24 34] [-24 34]]

  set caminho-agricultores-para-empresario-fertilizante (list caminho-agricultor-0-fertilizante caminho-agricultor-1-fertilizante caminho-agricultor-2-fertilizante caminho-agricultor-3-fertilizante caminho-agricultor-4-fertilizante caminho-agricultor-5-fertilizante)

  let caminho-agricultor-0-maquina [[-25 -6] [-20 -6] [-20 -2] [-20 2] [-20 6] [-20 10] [-20 14] [-20 18] [-17 18] [-14 18] [-14 15] [-10 15] [-6 15] [-2 15] [2 15] [6 15] [10 15] [14 15] [14 19] [14 23] [14 27] [14 31] [14 34] [18 34] [22 34] [25 34] [25 34]]
  let caminho-agricultor-1-maquina [[0 -6] [4 -6] [9 -6] [13 -6][17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [21 23] [21 27] [21 31] [21 34] [25 34] [25 34]]
  let caminho-agricultor-2-maquina [[25 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [21 23] [21 27] [21 31] [21 34] [25 34] [25 34]]
  let caminho-agricultor-3-maquina [[-25 -25] [-21 -25] [-17 -25] [-13 -25] [-13 -21] [-13 -17] [-13 -13] [-13 -9] [-13 -6] [-17 -6] [-20 -6] [-20 -1] [-20 3] [-20 7] [-20 11] [-20 15] [-20 18] [-17 18] [-14 18] [-14 15] [-10 15] [-6 15] [-2 15] [2 15] [6 15] [10 15] [14 15] [14 19] [14 23] [14 27] [14 31] [14 34] [18 34] [22 34] [25 34] [25 34]]
  let caminho-agricultor-4-maquina [[0 -25] [4 -25] [9 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19]  [21 23] [21 27] [21 31] [21 34] [25 34] [25 34]]
  let caminho-agricultor-5-maquina [[25 -25] [21 -25] [17 -25] [13 -25] [13 -21] [13 -17] [13 -13] [13 -9] [13 -6] [17 -6] [21 -6] [21 -2] [21 2] [21 7] [21 11] [21 15] [21 19] [21 23] [21 27] [21 31] [21 34] [25 34] [25 34]]

  set caminho-agricultores-para-empresario-maquina (list caminho-agricultor-0-maquina caminho-agricultor-1-maquina caminho-agricultor-2-maquina caminho-agricultor-3-maquina caminho-agricultor-4-maquina caminho-agricultor-5-maquina)


  ;; setores
  set setores table:make
  table:put setores "s" "sementes"
  table:put setores "a" "agrotoxicos"
  table:put setores "f" "fertilizantes"
  table:put setores "m" "maquinas"

  ;; tabela de produtividade
  set tabela-produtividade table:make
  table:put tabela-produtividade "0---" 10 ;; hortaliça, arroz e soja
  ;;table:put tabela-produtividade "1---" 10 ;; arroz ;; produtividade é igual a da hortaliça
  ;;table:put tabela-produtividade "2---" 10 ;; soja ;; produtividade é igual a da hortaliça

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

  table:put tabela-poluicao-agricultor "00" 100 ;; hortaliça + agrotóxico comum
  table:put tabela-poluicao-agricultor "01" 60 ;; hortaliça + agrotóxico premium
  table:put tabela-poluicao-agricultor "02" 30 ;; hortaliça + agrotóxico super premium

  table:put tabela-poluicao-agricultor "10" 200 ;; arroz + agrotóxico comum
  table:put tabela-poluicao-agricultor "11" 120 ;; arroz + agrotóxico premium
  table:put tabela-poluicao-agricultor "12" 60 ;; arroz + agrotóxico super premium

  table:put tabela-poluicao-agricultor "20" 300 ;; soja + agrotóxico comum
  table:put tabela-poluicao-agricultor "21" 180 ;; soja + agrotóxico premium
  table:put tabela-poluicao-agricultor "22" 90 ;; soja + agrotóxico super premium

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

  ;; define a tabela de poluição por produtividade
  set tabela-poluicao-produtividade table:make
  table:put tabela-poluicao-produtividade 0 100 ;; [0 29] 100
  table:put tabela-poluicao-produtividade 10 100 ;; [0 29] 100
  table:put tabela-poluicao-produtividade 20 100 ;; [0 29] 100
  table:put tabela-poluicao-produtividade 30 90 ;; [30 39] 90
  table:put tabela-poluicao-produtividade 40 80 ;; [40 49] 80
  table:put tabela-poluicao-produtividade 50 70 ;; [50 59] 70
  table:put tabela-poluicao-produtividade 60 60 ;; [60 69] 60
  table:put tabela-poluicao-produtividade 70 40 ;; [70 79] 40
  table:put tabela-poluicao-produtividade 80 20 ;; [80 99] 20
  table:put tabela-poluicao-produtividade 90 20 ;; [80 99] 20
  table:put tabela-poluicao-produtividade 100 0 ;; [100 100] 0
end

to cria-area
  ;; cria a grama
  ask patches [ set pcolor green - random-float 0.5 ]

  ;; cria o rio
  muda-cor-rio -0.5 0

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

  muda-cor-ponte

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

to muda-cor-ponte
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
end

to cria-agricultores
  set-default-shape agricultores "agricultor"
  set-default-shape cercas "square 4"

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

    set saldo 1000
  ]
end

to go

  ;; move-agricultor 4 (item 4 caminho-agricultores-para-empresario-agrotoxico)

  atualiza-rodada ;; zera os valores das parcelas, producao (TODO) e poluicao (TODO)

  print-log "\nETAPA 1\n"

  print-log-saldo
  print-log-poluicao-global

  compra-venda-produtos ;; agricultor e empresarios

  print-log-saldo-agricultores
  atualiza-producao-empresarios-pela-poluicao-global-e-print-log

  atualiza-poluicao-empresarios ;; empresário: após a venda/aluguel de produtos
  print-log-poluicao-empresarios

  ;;pede-selo-verde ;; agricultor ;; se não usou agrotóxico, o pedido de selo verde está automático

  planta ;; agricultor

  atualiza-producao-agricultores ;; agricultor: após a plantação

  atualiza-poluicao-agricultores ;;  agricultor: após a plantação

  atualiza-producao-agricultores-pela-poluicao-global-e-print-log
  print-log-poluicao-agricultores

  print-log "ETAPA 2\n"

  concede-selo-verde ;; fiscal

  fiscaliza ;; fiscal

  paga-imposto ;; agricultor e empresarios e atualiza o saldo do prefeito

  atualiza-saldo-agricultores ;; agricultor: após pagar os impostos, possíveis multas
  atualiza-saldo-empresarios ;; empresarios: após pagar os impostos, possíveis multas

  print-log-saldo

  atualiza-poluicao-global
  print-log-poluicao-global

  aplica-medidas-prevencao-poluicao ;; prefeito: após atualizar poluição global
  atualiza-poluicao-global-apos-tratamento
  atualiza-cor-rio

  print-log-saldo-prefeito
  print-log-poluicao-global
  tick

  if stop? [
    ;;user-message "Global pollution has reached a value equal to or greater than 100%"
    stop
  ]
end

to atualiza-rodada
  ;; zera as percelas de terra de todos os agricultores
  zera-parcelas
  zera-producao-e-poluicao
  zera-quantidade-produtos-vendidos
  zera-multa

  set reducao-poluicao 0

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
      table:put parcelas (word "p" p "pl") "-"
      table:put parcelas (word "p" p "producao") "-"
      table:put parcelas (word "p" p "poluicao") "-"
      table:put parcelas (word "p" p "sv") false

      set p (p + 1)
    ]

    ;; zera a quantidade de produtos vendidos
    set quant-semente-plantada 0 ;; varia de 0 a 6
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

to zera-multa
  ask agricultores [
    set multa 0
  ]

  ask empresarios [
    set multa 0
  ]
end

to compra-venda-produtos
  compra-semente
  compra-agrotoxico
  compra-fertilizante
  aluga-maquina
  aluga-pulverizador
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
    let valor-sem 0 ;; valor da semente

    if use-all-farm-land? [
      set p 6
    ]

    ask empresarios with [setor = "s"] [
      ;; valor da semente
      set valor-sem (item 0 (table:get produtos s))
    ]

    ifelse set-farmer-0? and id = 0 [
      realiza-compra-sementes-agricultor-0
    ][

      ;; movimentação do agente agricultor
      if enable-agent-movement? [
        ;; caminha até o empresário de sementes
        move-agricultor id (item id caminho-agricultores-para-empresario-semente)
      ]

      while [p > 0] [
        ;; verificar antes se agricultor tem saldo para comprar
        ;; se saldo do agricultor for maior, então COMPRA
        ifelse saldo >= p * valor-sem [
          ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
          agricultor-realiza-compra-sementes id 0 p p valor-sem s

          ;; como já conseguiu comprar, sai do laço
          set p 0
        ][
          ;; não conseguiu comprar, tenta com menos produtos (quantidade menor)
          set p p - 1
        ]
      ]
    ]
  ]
end

to realiza-compra-sementes-agricultor-0
  ask agricultores with [id = 0] [
    ;; movimentação do agente agricultor
    if farmer-0-vegetable + farmer-0-rice + farmer-0-soy > 0 [
      if enable-agent-movement? [
        ;; caminha até o empresário de sementes
        move-agricultor id (item id caminho-agricultores-para-empresario-semente)
      ]
    ]

    let valor-hortalica 0
    let valor-arroz 0
    let valor-soja 0

    ask empresarios with [setor = "s"] [
      set valor-hortalica (item 0 (table:get produtos 0))
      set valor-arroz (item 0 (table:get produtos 1))
      set valor-soja (item 0 (table:get produtos 2))
    ]

    let i 0 ;; indice das parcelas (varia de 0 a 5)
    let parcelas-disponiveis 6

    ;; 1- COMPRA DE HORTALIÇA

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior, então COMPRA HORTALIÇAS
    if farmer-0-vegetable > 0 and saldo > farmer-0-vegetable * valor-hortalica [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-sementes 0 0 farmer-0-vegetable farmer-0-vegetable valor-hortalica 0
    ]

    ;; 2- COMPRA DE ARROZ
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-vegetable
    if farmer-0-rice > parcelas-disponiveis [
      set farmer-0-rice parcelas-disponiveis
    ]

    ;; ...então COMPRA ARROZ
    if farmer-0-rice > 0 and saldo > farmer-0-rice * valor-arroz [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-sementes 0 farmer-0-vegetable farmer-0-rice (farmer-0-vegetable + farmer-0-rice) valor-arroz 1
    ]

    ;; 3- COMPRA DE SOJA
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-rice
    if farmer-0-soy > parcelas-disponiveis [
      set farmer-0-soy parcelas-disponiveis
    ]

    ;; ...então COMPRA SOJA
    if farmer-0-soy > 0 and saldo > farmer-0-soy * valor-soja [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-sementes 0 (farmer-0-rice + farmer-0-vegetable) farmer-0-soy (farmer-0-vegetable + farmer-0-rice + farmer-0-soy) valor-soja 2
    ]
  ]
end

to agricultor-realiza-compra-sementes [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
  ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  agricultor-realiza-compra identificador indice-parcela "s" quant-produto num-parcelas-ocupadas valor-produto produto

  ask agricultores with [id = identificador] [
    ;; atualiza a quantidade de sementes vendidas
    set quant-semente-plantada quant-semente-plantada + quant-produto

    print-log-compra-de-semente id quant-produto produto valor-produto
  ]
end

to agricultor-realiza-compra [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  ask agricultores with [id = identificador] [
    empresario-realiza-venda setor-empr quant-produto produto

    ;; atualiza o saldo do agricultor
    set saldo precision (saldo - quant-produto * valor-produto) 2

    ;; atualiza nas parcelas qual produto foi comprada
    while [indice-parcela < num-parcelas-ocupadas] [
      table:put parcelas (word "p" indice-parcela setor-empr) produto
      set indice-parcela indice-parcela + 1
    ]
  ]
end

to empresario-realiza-venda [setor-empr quant-produto produto]

  if setor-empr = "pl" [
    set setor-empr "m"
  ]

  ask empresarios with [setor = setor-empr] [
    let valor-produto (item 0 (table:get produtos produto))

    ;; atualiza a produção (ganhos) do empresario, após a venda
    set producao (producao + quant-produto * valor-produto)

    let quant-produtos (item 1 (table:get produtos produto))

    ;; atualiza a quantidade de produtos vendidos: quantidade atual + as novas vendas
    ;; valor do produto não pode alterar
    table:put produtos produto (list valor-produto (quant-produtos + quant-produto))
  ]
end

to-report get-produtividade-poluicao
  let pg global-pollution
  if pg < 0 [
    report 100
  ]
  if pg > 100 [
    report 0
  ]

  set pg (floor (pg / 10)) * 10
  report table:get tabela-poluicao-produtividade pg
end

to compra-agrotoxico
  ask agricultores [
    ifelse set-farmer-0? and id = 0 [
      realiza-compra-agrotoxicos-agricultor-0
    ][
      if type-of-agrotoxic != "no-agrotoxic" [
        ;; movimentação do agente agricultor
        if enable-agent-movement? [
          ;; caminha até o empresário de agrotóxico
          move-agricultor id (item id caminho-agricultores-para-empresario-agrotoxico)
        ]

        let a random 3 ;; agrotóxico aleatório

        if type-of-agrotoxic = "common" [
          set a 0
        ]
        if type-of-agrotoxic = "premium" [
          set a 1
        ]
        if type-of-agrotoxic = "super-premium" [
          set a 2
        ]

        let p random (quant-semente-plantada + 1) ;; quantidade aleatória de parcelas (de 0 a 6)
        let valor-agro 0 ;; valor do agrotóxico

        if use-all-farm-land? [
          set p quant-semente-plantada
        ]

        ;; cada agricultor pode comprar ou não agrotóxico
        if p != 0 [
          ask empresarios with [setor = "a"] [
            ;; valor do agrotóxico
            set valor-agro (item 0 (table:get produtos a))
          ]

          while [p > 0] [
            ;; verificar antes se agricultor tem saldo para comprar
            ;; se saldo do agricultor for maior, então COMPRA
            ifelse saldo >= p * valor-agro [
              ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
              agricultor-realiza-compra-agrotoxicos id 0 p p valor-agro a

              ;; como já conseguiu comprar, sai do laço
              set p 0
            ][
              ;; não conseguiu comprar, tenta com menos produtos (quantidade menor)
              set p p - 1
            ]

          ]
        ]
      ]
    ]
  ]
end

to agricultor-realiza-compra-agrotoxicos [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
  ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  agricultor-realiza-compra identificador indice-parcela "a" quant-produto num-parcelas-ocupadas valor-produto produto

  ask agricultores with [id = identificador] [
    ;; [ identificador quantidade agrotoxico valor ]
    print-log-compra-de-agrotoxico id quant-produto produto valor-produto
  ]
end

to realiza-compra-agrotoxicos-agricultor-0
  ask agricultores with [id = 0] [

    if farmer-0-common-agrotoxic + farmer-0-premium-agrotoxic + farmer-0-super-premium-agrotoxic > 0 and quant-semente-plantada > 0 [
      ;; movimentação do agente agricultor
      if enable-agent-movement? [
        ;; caminha até o empresário de agrotóxico
        move-agricultor id (item id caminho-agricultores-para-empresario-agrotoxico)
      ]
    ]

    let valor-agro-comum 0
    let valor-agro-premium 0
    let valor-agro-super-premium 0

    ask empresarios with [setor = "a"] [
      set valor-agro-comum (item 0 (table:get produtos 0))
      set valor-agro-premium (item 0 (table:get produtos 1))
      set valor-agro-super-premium (item 0 (table:get produtos 2))
    ]

    let i 0 ;; indice das parcelas (varia de 0 a 5)
    let parcelas-disponiveis quant-semente-plantada ;; para usar com agrotóxico

    ;; 1- COMPRA DE AGROTÓXICO COMUM
    if farmer-0-common-agrotoxic > parcelas-disponiveis [
      set farmer-0-common-agrotoxic parcelas-disponiveis
    ]

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior, então COMPRA AGROTÓXICO COMUM
    if farmer-0-common-agrotoxic > 0 and saldo > farmer-0-common-agrotoxic * valor-agro-comum [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-agrotoxicos 0 0 farmer-0-common-agrotoxic farmer-0-common-agrotoxic valor-agro-comum 0
    ]

    ;; 2- COMPRA DE AGROTÓXICO PREMIUM
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-common-agrotoxic
    if farmer-0-premium-agrotoxic > parcelas-disponiveis [
      set farmer-0-premium-agrotoxic parcelas-disponiveis
    ]

    ;; ...então COMPRA PREMIUM
    if farmer-0-premium-agrotoxic > 0 and saldo > farmer-0-premium-agrotoxic * valor-agro-premium [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-agrotoxicos 0 farmer-0-common-agrotoxic farmer-0-premium-agrotoxic (farmer-0-common-agrotoxic + farmer-0-premium-agrotoxic) valor-agro-premium 1
    ]

    ;; 3- COMPRA DE AGROTÓXICO SUPER-PREMIUM
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-premium-agrotoxic
    if farmer-0-super-premium-agrotoxic > parcelas-disponiveis [
      set farmer-0-super-premium-agrotoxic parcelas-disponiveis
    ]

    ;; ...então COMPRA SUPER-PREMIUM
    if farmer-0-super-premium-agrotoxic > 0 and saldo > farmer-0-super-premium-agrotoxic * valor-agro-super-premium [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-agrotoxicos 0 (farmer-0-common-agrotoxic + farmer-0-premium-agrotoxic) farmer-0-super-premium-agrotoxic (farmer-0-common-agrotoxic + farmer-0-premium-agrotoxic + farmer-0-super-premium-agrotoxic) valor-agro-super-premium 2
    ]
  ]
end


to compra-fertilizante
  ask agricultores [
    ifelse set-farmer-0? and id = 0 [
      realiza-compra-fertilizantes-agricultor-0
    ][
      if type-of-fertilizer != "no-fertilizer" [
        ;; movimentação do agente agricultor
        if enable-agent-movement? [
          ;; caminha até o empresário de agrotóxico
          move-agricultor id (item id caminho-agricultores-para-empresario-fertilizante)
        ]

        let f random 3 ;; fertilizante aleatório

        if type-of-fertilizer = "common" [
          set f 0
        ]
        if type-of-fertilizer = "premium" [
          set f 1
        ]
        if type-of-fertilizer = "super-premium" [
          set f 2
        ]

        let p random (quant-semente-plantada + 1) ;; quantidade aleatória de parcelas (de 0 a 6)
        let valor-fert 0 ;; valor do fertilizante

        if use-all-farm-land? [
          set p quant-semente-plantada
        ]

        ;; cada agricultor pode comprar ou não fertilizante
        if p != 0 [
          ask empresarios with [setor = "f"] [
            ;; valor do fertilizante
            set valor-fert (item 0 (table:get produtos f))
          ]

          while [p > 0] [
            ;; verificar antes se agricultor tem saldo para comprar
            ;; se saldo do agricultor for maior, então COMPRA
            ifelse saldo >= p * valor-fert [
              ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
              agricultor-realiza-compra-fertilizantes id 0 p p valor-fert f

              ;; como já conseguiu comprar, sai do laço
              set p 0
            ][
              ;; não conseguiu comprar, tenta com menos produtos (quantidade menor)
              set p p - 1
            ]
          ]
        ]
      ]
    ]
  ]
end

to realiza-compra-fertilizantes-agricultor-0
  ask agricultores with [id = 0] [

    if farmer-0-common-fertilizer + farmer-0-premium-fertilizer + farmer-0-super-premium-fertilizer > 0 and quant-semente-plantada > 0 [
      ;; movimentação do agente agricultor
      if enable-agent-movement? [
        ;; caminha até o empresário de fertilizante
        move-agricultor id (item id caminho-agricultores-para-empresario-fertilizante)
      ]
    ]

    let valor-fert-comum 0
    let valor-fert-premium 0
    let valor-fert-super-premium 0

    ask empresarios with [setor = "f"] [
      set valor-fert-comum (item 0 (table:get produtos 0))
      set valor-fert-premium (item 0 (table:get produtos 1))
      set valor-fert-super-premium (item 0 (table:get produtos 2))
    ]

    let i 0 ;; indice das parcelas (varia de 0 a 5)
    let parcelas-disponiveis quant-semente-plantada ;; para usar com fertilizantes

    ;; 1- COMPRA DE FERTILIZANTE COMUM
    if farmer-0-common-fertilizer > parcelas-disponiveis [
      set farmer-0-common-fertilizer parcelas-disponiveis
    ]

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior, então COMPRA AGROTÓXICO COMUM
    if farmer-0-common-fertilizer > 0 and saldo > farmer-0-common-fertilizer * valor-fert-comum [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-fertilizantes 0 0 farmer-0-common-fertilizer farmer-0-common-fertilizer valor-fert-comum 0
    ]

    ;; 2- COMPRA DE FERTILIZANTE PREMIUM
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-common-fertilizer
    if farmer-0-premium-fertilizer > parcelas-disponiveis [
      set farmer-0-premium-fertilizer parcelas-disponiveis
    ]

    ;; ...então COMPRA PREMIUM
    if farmer-0-premium-fertilizer > 0 and saldo > farmer-0-premium-fertilizer * valor-fert-premium [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-fertilizantes 0 farmer-0-common-fertilizer farmer-0-premium-fertilizer (farmer-0-common-fertilizer + farmer-0-premium-fertilizer) valor-fert-premium 1
    ]

    ;; 3- COMPRA DE FERTILIZANTE SUPER-PREMIUM
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-premium-fertilizer
    if farmer-0-super-premium-fertilizer > parcelas-disponiveis [
      set farmer-0-super-premium-fertilizer parcelas-disponiveis
    ]

    ;; ...então COMPRA SUPER-PREMIUM
    if farmer-0-super-premium-fertilizer > 0 and saldo > farmer-0-super-premium-fertilizer * valor-fert-super-premium [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-compra-fertilizantes 0 (farmer-0-common-fertilizer + farmer-0-premium-fertilizer) farmer-0-super-premium-fertilizer (farmer-0-common-fertilizer + farmer-0-premium-fertilizer + farmer-0-super-premium-fertilizer) valor-fert-super-premium 2
    ]
  ]
end

to agricultor-realiza-compra-fertilizantes [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
  ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  agricultor-realiza-compra identificador indice-parcela "f" quant-produto num-parcelas-ocupadas valor-produto produto

  ask agricultores with [id = identificador] [
    ;; [ identificador quantidade fertilizante valor ]
    print-log-compra-de-fertilizante id quant-produto produto valor-produto
  ]
end


to aluga-maquina
  ask agricultores [
    ifelse set-farmer-0? and id = 0 [
      realiza-aluguel-maquina-agricultor-0
    ][
      ;; se agricultor NÃO estiver usando agrotóxico, então PODE alugar máquina
      ifelse type-of-agrotoxic = "no-agrotoxic"[
        if type-of-machine != "no-machine" [
          ;; movimentação do agente agricultor
          if enable-agent-movement? [
            ;; caminha até o empresário de máquinas
            move-agricultor id (item id caminho-agricultores-para-empresario-maquina)
          ]

          let m random 3 ;; máquina (pacote) aleatória

          if type-of-machine = "combination-1" [
            set m 0
          ]
          if type-of-machine = "combination-2" [
            set m 1
          ]
          if type-of-machine = "combination-3" [
            set m 2
          ]

          let p random (quant-semente-plantada + 1) ;; quantidade aleatória de parcelas (de 0 a 6)
          let valor-maquina 0 ;; valor da máquina (pacote)

          if use-all-farm-land? [
            set p quant-semente-plantada
          ]

          ;; cada agricultor pode aluguar ou não máquinas (pacote)
          if p != 0 [
            ask empresarios with [setor = "m"] [
              ;; valor da máquina (pacote)
              set valor-maquina (item 0 (table:get produtos m))
            ]

            while [p > 0] [
              ;; verificar antes se agricultor tem saldo para comprar
              ;; se saldo do agricultor for maior, então COMPRA
              ifelse saldo >= p * valor-maquina [
                ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
                agricultor-realiza-aluguel-maquinas id 0 p p valor-maquina m

                ;; como já conseguiu alugar, sai do laço
                set p 0
              ][
                ;; não conseguiu alugar, tenta com menos produtos (quantidade menor)
                set p p - 1
              ]
            ]
          ]
        ]
      ][
        set type-of-machine "no-machine"
      ]
    ]
  ]
end

to realiza-aluguel-maquina-agricultor-0
  ask agricultores with [id = 0] [

    let valor-maquina-p1 0
    let valor-maquina-p2 0
    let valor-maquina-p3 0

    ask empresarios with [setor = "m"] [
      set valor-maquina-p1 (item 0 (table:get produtos 0))
      set valor-maquina-p2 (item 0 (table:get produtos 1))
      set valor-maquina-p3 (item 0 (table:get produtos 2))
    ]

    let i 0 ;; indice das parcelas (varia de 0 a 5)
    let parcelas-disponiveis quant-semente-plantada ;; para usar com máquinas (pacotes)

    ;; somente é possível alugar máquina quando não há agrotóxico
    let quant-agrotoxicos-escolhidos farmer-0-common-agrotoxic + farmer-0-premium-agrotoxic + farmer-0-super-premium-agrotoxic
    set parcelas-disponiveis parcelas-disponiveis - quant-agrotoxicos-escolhidos

    if farmer-0-combination-1-machine + farmer-0-combination-2-machine + farmer-0-combination-3-machine > 0 and parcelas-disponiveis > 0 [
      ;; movimentação do agente agricultor
      if enable-agent-movement? [
        ;; caminha até o empresário de máquina
        move-agricultor id (item id caminho-agricultores-para-empresario-maquina)
      ]
    ]

    ;; 1- COMPRA DE PACOTE 1
    if farmer-0-combination-1-machine > parcelas-disponiveis [
      set farmer-0-combination-1-machine parcelas-disponiveis
    ]

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior, então COMPRA PACOTE 1
    if farmer-0-combination-1-machine > 0 and saldo > farmer-0-combination-1-machine * valor-maquina-p1 [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-aluguel-maquinas 0 (quant-agrotoxicos-escolhidos) farmer-0-combination-1-machine (farmer-0-combination-1-machine + quant-agrotoxicos-escolhidos) valor-maquina-p1 0
    ]

    ;; 2- COMPRA DE PACOTE 2
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-combination-1-machine
    if farmer-0-combination-2-machine > parcelas-disponiveis [
      set farmer-0-combination-2-machine parcelas-disponiveis
    ]

    ;; ...então COMPRA PACOTE 2
    if farmer-0-combination-2-machine > 0 and saldo > farmer-0-combination-2-machine * valor-maquina-p2 [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-aluguel-maquinas 0 (farmer-0-combination-1-machine + quant-agrotoxicos-escolhidos) farmer-0-combination-2-machine (farmer-0-combination-1-machine + farmer-0-combination-2-machine + quant-agrotoxicos-escolhidos) valor-maquina-p2 1
    ]

    ;; 3- COMPRA DE PACOTE 3
    set parcelas-disponiveis parcelas-disponiveis - farmer-0-combination-2-machine
    if farmer-0-combination-3-machine > parcelas-disponiveis [
      set farmer-0-combination-3-machine parcelas-disponiveis
    ]

    ;; ...então COMPRA PACOTE 3
    if farmer-0-combination-3-machine > 0 and saldo > farmer-0-combination-3-machine * valor-maquina-p3 [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-aluguel-maquinas 0 (farmer-0-combination-1-machine + farmer-0-combination-2-machine + quant-agrotoxicos-escolhidos) farmer-0-combination-3-machine (farmer-0-combination-1-machine + farmer-0-combination-2-machine + farmer-0-combination-3-machine + quant-agrotoxicos-escolhidos) valor-maquina-p3 2
    ]
  ]
end

to agricultor-realiza-aluguel-maquinas [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
  ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  agricultor-realiza-compra identificador indice-parcela "m" quant-produto num-parcelas-ocupadas valor-produto produto

  ask agricultores with [id = identificador] [
    ;; [ identificador quantidade maquina valor ]
    print-log-aluguel-de-maquina id quant-produto produto valor-produto
  ]
end

to aluga-pulverizador
  ask agricultores [
    ifelse set-farmer-0? and id = 0 [
      realiza-aluguel-pulverizador-agricultor-0
    ][
      if use-of-pulverizer != "no-pulverizer" [
        ;; Se não alugou máquina (pacotes), então tem que fazer a movimentação (se sim, a movimentação já foi feita)
        ;; até o empresário de máquina para compra pulverizador
        if type-of-machine = "no-machine" [
          ;; movimentação do agente agricultor
          if enable-agent-movement? [
            ;; caminha até o empresário de máquinas
            move-agricultor id (item id caminho-agricultores-para-empresario-maquina)
          ]
        ]

        let pl random 2 ;; máquina (pulverizador) aleatório (de 0 a 1)
        let p quant-semente-plantada
        let valor-pulverizador 0 ;; valor da máquina (pacote)
        let quant-produto 0

        if use-of-pulverizer = "always" or use-all-farm-land? [
          set pl 1
        ]

        ask empresarios with [setor = "m"] [
          ;; valor da máquina (pulverizador)
          set valor-pulverizador (item 0 (table:get produtos 3))
        ]

        ;; percorre as parcelas de terra que foram plantadas, e verifica se tenta alugar o pulverizador
        let i 0 ;; indice das parcelas (varia de 0 a 5)
        while [i < p] [

          if use-all-farm-land? = false and use-of-pulverizer != "always" [
            set pl random 2 ;; aleatório (de 0 a 1)
          ]

          if pl = 1 [
            let s table:get parcelas (word "p" i "s")
            ;; verifica se tem semente comprada para esta parcela
            if s != "-" [
              ;; verificar antes se agricultor tem saldo para comprar
              ;; se saldo do agricultor for maior, então COMPRA
              if saldo > valor-pulverizador [
                ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
                agricultor-realiza-compra id i "pl" 1 (i + 1) valor-pulverizador 3

                set quant-produto quant-produto + 1
              ]
            ]
          ]

          set i i + 1
        ]

        if quant-produto > 0 [
          ;; [ identificador quantidade valor ]
          print-log-aluguel-de-pulverizador id quant-produto valor-pulverizador
        ]

      ]
    ]
  ]
end

to agricultor-realiza-aluguel-pulverizador [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
  ;; [identificador indice-parcela setor-empr quant-produto num-parcelas-ocupadas valor-produto produto]
  agricultor-realiza-compra identificador indice-parcela "pl" quant-produto num-parcelas-ocupadas valor-produto produto

  ask agricultores with [id = identificador] [
    ;; [ identificador quantidade valor ]
    print-log-aluguel-de-pulverizador id quant-produto valor-produto
  ]
end

to realiza-aluguel-pulverizador-agricultor-0
  ask agricultores with [id = 0] [
    let valor-pulverizador 0

    ask empresarios with [setor = "m"] [
      set valor-pulverizador (item 0 (table:get produtos 3))
    ]

    let i 0 ;; indice das parcelas (varia de 0 a 5)
    let parcelas-disponiveis quant-semente-plantada ;; para usar com máquinas (pulverizadores)

    ;; Se não alugou máquina (pacotes), então tem que fazer a movimentação (se sim, a movimentação já foi feita)
    if farmer-0-combination-1-machine + farmer-0-combination-2-machine + farmer-0-combination-3-machine = 0 and farmer-0-pulverizer > 0 and parcelas-disponiveis > 0 [
      ;; movimentação do agente agricultor
      if enable-agent-movement? [
        ;; caminha até o empresário de máquina
        move-agricultor id (item id caminho-agricultores-para-empresario-maquina)
      ]
    ]

    if farmer-0-pulverizer > parcelas-disponiveis [
      set farmer-0-pulverizer parcelas-disponiveis
    ]

    ;; verificar antes se agricultor tem saldo para comprar
    ;; se saldo do agricultor for maior, então COMPRA PULVERIZADOR
    if farmer-0-pulverizer > 0 and saldo > farmer-0-pulverizer * valor-pulverizador [
      ;; [identificador indice-parcela quant-produto num-parcelas-ocupadas valor-produto produto]
      agricultor-realiza-aluguel-pulverizador 0 0 farmer-0-pulverizer farmer-0-pulverizer valor-pulverizador 3
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

        ;; 1- semente
        let x (item 0 (table:get posicao-parcelas (word "a" id "p" p)))
        let y (item 1 (table:get posicao-parcelas (word "a" id "p" p)))

        ;; realiza a plantação (interface)
        bitmap:copy-to-drawing (bitmap:import (item s sementes-imagens)) x y

        ;; 2- agrotóxico
        let a table:get parcelas (word "p" p "a")
        if a != "-" [ ;; verifica se tem agrotóxico comprado para esta parcela
          ;; coloca o agrotóxico na fazenda (interface)
          bitmap:copy-to-drawing (bitmap:import (item a agrotoxico-imagens)) x + 21 y
        ]

        ;; 3- fertilizante
        let f table:get parcelas (word "p" p "f")
        if f != "-" [ ;; verifica se tem fertilizante comprado para esta parcela
          ;; coloca o fertilizante na fazenda (interface)
          bitmap:copy-to-drawing (bitmap:import (item f fertilizante-imagens)) x y + 21
        ]

        ;; 4- máquina (pacotes)
        let m table:get parcelas (word "p" p "m")
        if m != "-" [ ;; verifica se tem máquina (pacote) alugada para esta parcela
          ;; coloca a máquina (pacote) na fazenda (interface)
          bitmap:copy-to-drawing (bitmap:import (item m maquina-imagens)) x + 20 y + 25
        ]

        ;; 5- máquina (pulverizador)
        let pl table:get parcelas (word "p" p "pl")
        if pl != "-" [ ;; verifica se tem máquina (pulverizador) alugado para esta parcela
          ;; coloca a máquina (pulverizador) na fazenda (interface)
          bitmap:copy-to-drawing (bitmap:import (item pl maquina-imagens)) x + 35 y + 25
        ]
      ]

      set p p + 1
    ]

    if plantou [
      print-log (word "Agricultor " id " finalizou a plantação!")
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
        ;; considera sempre a hortaliça (semente de referência)
        let ganho-parcela table:get tabela-produtividade (word 0 a f m)

        ;; a produtividade só muda quando arroz ou soja foram compradas junto com algum tipo de agrotóxico
        if a != "-" [ ;; verifica se tem semente comprada para esta parcela
          if s = 1 [  ;; se a semente é arroz
            set ganho-parcela ganho-parcela * 2 ;; produção é duplicada
          ]
          if s = 2 [ ;; se a semente é soja
            set ganho-parcela ganho-parcela * 3 ;; produção é triplicada
          ]
        ]

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
    set saldo precision (saldo + producao) 2
  ]
end

to atualiza-saldo-empresarios
  ask empresarios [
    set saldo precision (saldo + producao) 2
  ]
end

to atualiza-poluicao-agricultores
  ask agricultores [
    let p 0
    while [p < 6] [
      let s table:get parcelas (word "p" p "s")
      let a table:get parcelas (word "p" p "a")
      let pl table:get parcelas (word "p" p "pl")

      if s != "-" [ ;; verifica se tem semente comprada para esta parcela
        let poluicao-parcela table:get tabela-poluicao-agricultor (word s a)

        ;; se usou pulverizador na parcela, reduz na metade a puluição da parcela
        if pl != "-" [
          set poluicao-parcela poluicao-parcela / 2
        ]

        ;; atualiza a poluicao da parcela
        table:put parcelas (word "p" p "poluicao") poluicao-parcela

        ;; atualiza a poluicao individual do agricultor (soma da poluicao de cada parcela)
        set poluicao poluicao + poluicao-parcela
      ]

      set p p + 1
    ]
  ]
end

to concede-selo-verde
  if green-seal != "no-green-seal" [
    let selo-verde false

    ask agricultores [

      let parcelas-log "" ;; parcelas para o log
      set selo-verde false
      let p 0
      while [p < 6] [ ;; percorre as parcelas de terra que foram plantadas, e verifica se concede selo verde
        let a table:get parcelas (word "p" p "a")
        let s table:get parcelas (word "p" p "s")

        ;; verifica se não tem agrotóxico comprado para esta parcela e se tem semente comprada para esta parcela
        if a = "-" and s != "-" [

          let sv random 2 ;; selo verde aleatório (de 0 a 1)
          if green-seal = "always" [
            set sv 1
          ]

          if sv = 1 [
            let x (item 0 (table:get posicao-parcelas (word "a" id "p" p)))
            let y (item 1 (table:get posicao-parcelas (word "a" id "p" p)))

            ;; coloca o selo verde na fazenda (interface)
            bitmap:copy-to-drawing (bitmap:import selo-verde-imagem) x + 21 y
            table:put parcelas (word "p" p "sv") true

            ;; atualiza parcelas para o log
            set parcelas-log (word parcelas-log (p + 1) " ")
            set selo-verde true
          ]
        ]

        set p p + 1
      ]

      if selo-verde [
        print-log-selo-verde id (but-last parcelas-log)
      ]
    ]
    if selo-verde [
      print-log ""
    ]
  ]
end

to fiscaliza
  ifelse fine? [
    ;; movimentação do agente fiscal
    if enable-agent-movement? [
      ;; caminha até os todos empresários
      move-fiscal-so-ida caminho-fiscal-to-businessman

      ;; caminha até os agricultores
      let i 0
      while [i < number-farmer] [
        if enable-agent-movement? [
          move-fiscal (item i caminho-fiscal-to-farmers)
        ]
        set i i + 1
      ]
    ]

    let total-multas 0

    ;; Aplicação de multa para os agricultores
    ask fiscais [
      ask agricultores [
        let p poluicao / 6 ;; média de poluicao de todas as 6 parcelas de terra do agricultor
        ;;set multa 0 ;; aqui a multa já está zerada: pode remover
        let tipo-multa 0
        let peso 1

        if p >= 90 and p < 120 [
          set multa p
          set tipo-multa 1
        ]
        if p >= 120 and p < 200 [
          set peso 2
          set multa peso * p
          set tipo-multa 2
        ]
        if p >= 200 [
          set peso 3
          set multa peso * p
          set tipo-multa 3
        ]

        set saldo precision (saldo - multa) 2
        set total-multas total-multas + multa

        if tipo-multa != 0 [
          print-log (word "Multa (" (item tipo-multa tipos-multa) ") para agricultor " id " no valor de D$"
            multa " (" peso " * " p ")" )
        ]
      ]

      ;; Aplicação de multa para os empresários
      ask empresarios [
        let p poluicao
        ;;set multa 0 ;; aqui a multa já está zerada: pode remover
        let tipo-multa 0
        let peso 1

        if p >= 90 and p < 120 [
          set multa p
          set tipo-multa 1
        ]
        if p >= 120 and p < 200 [
          set peso 2
          set multa peso * p
          set tipo-multa 2
        ]
        if p >= 200 [
          set peso 3
          set multa peso * p
          set tipo-multa 3
        ]

        set saldo precision (saldo - multa) 2
        set total-multas total-multas + multa

        if tipo-multa != 0 [
          print-log (word "Multa (" (item tipo-multa tipos-multa) ") para empresário de " (table:get setores setor)
            " no valor de D$" multa " (" peso " * " p ")" )
        ]
      ]
    ]

    ;; atualiza o saldo da prefeitura com as multas
    ask prefeitos [
      set saldo precision (saldo + total-multas) 2
    ]

    if total-multas != 0 [ print-log "" ]

    print-log "Fiscal finalizou a fiscalização!\n"

  ][
    print-log "Fiscal não realizou a fiscalização!\n"
  ]
end

to paga-imposto
  let total-imposto 0

  ask agricultores [
    let pr producao
    let imposto 10
    let faixa 0
    let desconto 0

    ;; calcula o desconto no imposto

    let p 0
    while [p < 6] [
      let sv table:get parcelas (word "p" p "sv")

      if sv [
        ;; 5% de desconto para cada parcela com selo verde
        set desconto desconto + 0.05 / 6
      ]

      set p p + 1
    ]

    set desconto 1 - desconto ;; calcula o desconto

    if pr > 0 and pr <= 200 [
      set imposto 0.1 * pr
      set faixa 10
    ]
    if pr > 200 [
      set imposto 0.3 * pr
      set faixa 30
    ]

    set imposto precision (imposto * desconto) 2 ;; realiza o desconto no imposto

    set saldo precision (saldo - imposto) 2
    set total-imposto total-imposto + imposto

    let msg (word "Imposto do agricultor " id ": D$" imposto)
    let msg-com-explicacao (word msg " (" faixa "% do ganho de D$" producao ")")
    let desconto-total precision ( (1 - desconto) * 100 ) 2
    let msg-desconto-total (word " (desconto total de " desconto-total"%)")

    ifelse desconto-total > 0 [
      ifelse faixa = 0 [
        print-log (word msg msg-desconto-total)
      ][
        print-log (word msg-com-explicacao msg-desconto-total)
      ]
    ][
      ifelse faixa = 0 [
        print-log msg
      ][
        print-log msg-com-explicacao
      ]
    ]
  ]

  print-log ""

  ask empresarios [
    let pr producao
    let imposto 10
    let faixa 0

    if pr > 0 and pr <= 200 [
      set imposto 0.1 * pr
      set faixa 10
    ]
    if pr > 200 [
      set imposto 0.3 * pr
      set faixa 30
    ]

    set imposto precision ( imposto ) 2
    set saldo precision (saldo - imposto) 2
    set total-imposto total-imposto + imposto

    let msg (word "Imposto do empresario de " (table:get setores setor) ": D$" imposto)

    ifelse faixa = 0 [
      print-log msg
    ][
      print-log (word msg " (" faixa "% do ganho de D$" producao ")")
    ]
  ]

  print-log ""

  ;; atualiza o saldo da prefeitura com os impostos
  ask prefeitos [
    set saldo precision (saldo + total-imposto) 2
  ]
end

to atualiza-poluicao-global
  let poluicao-agricultores 0
  let poluicao-empresarios 0
  let poluicao-rodada 0

  ask agricultores [
    let p 0 ;; poluicao
    set p poluicao / 6 / 10000
    set poluicao-agricultores poluicao-agricultores + p
  ]

  ask empresarios [
    let p 0 ;; poluicao
    set p poluicao / 10000
    set poluicao-empresarios poluicao-empresarios + p
  ]

  ;; poluicao da rodada atual
  set poluicao-rodada poluicao-agricultores + poluicao-empresarios

  set global-pollution global-pollution / 100

  ;; poluicao global sem a redução das medidas de prevenção
  set global-pollution (global-pollution + poluicao-rodada) * 100

  set global-pollution precision ( global-pollution ) 2

  ;; atualiza na interface a poluição global do ambiente
  atualiza-poluicao-global-interface

  ifelse global-pollution >= 100 [
    set stop? true
  ][
    set stop? false
  ]
end

to atualiza-poluicao-global-interface
  ;; atualiza na interface a poluição global do ambiente
  ask patch 0 4 [
    set plabel (word global-pollution "%")
  ]
end

to atualiza-poluicao-global-apos-tratamento
  ;; poluicao global após a aplicação das medidas de prevenção
  set global-pollution global-pollution * (1 - reducao-poluicao)

  set global-pollution precision ( global-pollution ) 2

  atualiza-poluicao-global-interface
end

to atualiza-cor-rio
  ;; teste da cor do rio
  ;;if global-pollution < 100 [
  ;;  set global-pollution global-pollution + 1
  ;;]

  ifelse global-pollution < 20 [
    muda-cor-rio -0.5 0
  ][
    let x 0

    if global-pollution >= 20 and global-pollution <= 39.99 [
      set x 0.66
    ]
    if global-pollution >= 40 and global-pollution <= 59.99 [
      set x 1.32
    ]
    if global-pollution >= 60 and global-pollution <= 69.99 [
      set x 1.98
    ]
    if global-pollution >= 70 and global-pollution <= 79.99 [
      set x 2.64
    ]
    if global-pollution >= 80 and global-pollution <= 89.99 [
      set x 3.3
    ]
    if global-pollution >= 90 [
      set x 4
    ]

    muda-cor-rio x 0.3
  ]
end

to muda-cor-rio [tonalidade variacao]
  ask patches with [pycor > -3 and pycor < 12] [
    set pcolor blue - tonalidade - random-float variacao
  ]

  muda-cor-ponte
end

to aplica-medidas-prevencao-poluicao
  ask prefeitos [
    ifelse type-of-pollution-treatment != "no-treatment" [

      ;; movimentação do agente prefeito
      if enable-agent-movement? [
        move-prefeito caminho-prefeito
      ]

      let t random 3 ;; medida aleatória
      set reducao-poluicao 0
      let custo 0

      if type-of-pollution-treatment = "water-treatment" [
        set t 0
      ]
      if type-of-pollution-treatment = "waste-treatment" [
        set t 1
      ]
      if type-of-pollution-treatment = "sewage-treatment" [
        set t 2
      ]

      if t = 0 [
        ifelse global-pollution < 30 [
          set custo 800
        ][
          set custo global-pollution - 20 + 800
        ]
      ]
      if t = 1 [
        ifelse global-pollution < 30 [
          set custo 1600
        ][
          set custo global-pollution - 20 + 1600
        ]
      ]
      if t = 2 [
        ifelse global-pollution < 30 [
          set custo 2400
        ][
          set custo global-pollution - 20 + 2400
        ]
      ]

      ifelse saldo >= custo [
        set saldo precision (saldo - custo) 2

        if t = 0 [
          set reducao-poluicao 0.05
          print-log (word "Tratamento de " (item t medida-prevencao) " realizado (redução de " (reducao-poluicao * 100) "%)! \n")
        ]
        if t = 1 [
          set reducao-poluicao 0.1
          print-log (word "Tratamento de " (item t medida-prevencao) " realizado (redução de " (reducao-poluicao * 100) "%)! \n")
        ]
        if t = 2 [
          set reducao-poluicao 0.15
          print-log (word "Tratamento de " (item t medida-prevencao) " realizado (redução de " (reducao-poluicao * 100) "%)! \n")
        ]
      ][
        print-log (word "Prefeito sem saldo para aplicar medida de prevenção (tratamento de " (item t medida-prevencao) ")! \n")
      ]
    ][
      print-log "Nenhum medida de tratamento da poluição foi aplicada! \n"
    ]
  ]
end


to print-log-saldo-agricultores
  print-log ""
  ask agricultores [
    print-log (word "Saldo atual do agricultor " id ": D$" saldo)
  ]
  print-log ""
end

to print-log-saldo-prefeito
  ;;print-log ""
  ask prefeitos [
    print-log (word "Saldo atual da prefeitura: D$" saldo)
  ]
  print-log ""
end

to print-log-saldo
  ;; print-log ""
  ask agricultores [
    print-log (word "Saldo atual do agricultor " id ": D$" saldo)
  ]
  print-log ""
  ask empresarios [
    print-log (word "Saldo atual do empresário de "  (table:get setores setor) ": D$" saldo)
  ]
  print-log ""
  ask prefeitos [
    print-log (word "Saldo atual da prefeitura: D$" saldo)
  ]
  print-log ""
end

to print-log-producao-agricultores [producao-sem-reducao producao-com-reducao reducao-produtividade]
  print-log (word "Ganhos do agricultor " id ": D$" producao-com-reducao " (" reducao-produtividade "% de D$" producao-sem-reducao ")")
end

to atualiza-producao-agricultores-pela-poluicao-global-e-print-log
  print-log ""
  let reducao-produtividade get-produtividade-poluicao
  ask agricultores [
    let producao-sem-reducao producao
    set producao producao * (reducao-produtividade / 100)
    print-log-producao-agricultores producao-sem-reducao producao reducao-produtividade
  ]
  print-log ""
end

to print-log-producao-empresarios [setor-empresario producao-sem-reducao producao-com-reducao reducao-produtividade]
  print-log (word "Ganhos do empresário de "  (table:get setores setor-empresario) ": D$" producao-com-reducao " (" reducao-produtividade "% de D$" producao-sem-reducao ")")
end

to atualiza-producao-empresarios-pela-poluicao-global-e-print-log
  ;;print-log ""
  let reducao-produtividade get-produtividade-poluicao
  ask empresarios [
    let producao-sem-reducao producao
    set producao producao * (reducao-produtividade / 100)
    print-log-producao-empresarios setor producao-sem-reducao producao reducao-produtividade
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
    if poluicao > 0 [
      print-log (word "Poluição do empresário de "  (table:get setores setor) ": " poluicao )
    ]
  ]
  print-log ""
end

to print-log-poluicao-global
  print-log (word "Poluição global: " global-pollution "%")
  print-log ""
end

to print-log-compra-de-semente [ identificador quantidade semente valor ]
  ;; print-log (word "Agricultor " id " comprou " p " saco(s) de " (item s tipos-semente) " (D$" valor-sem ")" " por D$" (p * valor-sem))
  print-log (word "Agricultor " identificador " comprou " quantidade " saco(s) de " (item semente tipos-semente) " (D$" valor ")" " por D$" (quantidade * valor))
end

to print-log-compra-de-agrotoxico [ identificador quantidade agrotoxico valor ]
  ;; print-log (word "Agricultor " id " comprou " p " agrotóxico(s) " (item a tipos-agrotoxico) " (D$" valor-agro ")" " por D$" (p * valor-agro))
  print-log (word "Agricultor " identificador " comprou " quantidade " agrotóxico(s) " (item agrotoxico tipos-agrotoxico) " (D$" valor ") por D$" (quantidade * valor))
end

to print-log-compra-de-fertilizante [ identificador quantidade fertilizante valor ]
  print-log (word "Agricultor " identificador " comprou " quantidade " fertilizante(s) " (item fertilizante tipos-fertilizante) " (D$" valor ") por D$" (quantidade * valor))
end

to print-log-aluguel-de-maquina [ identificador quantidade maquina valor ]
  print-log (word "Agricultor " identificador " alugou " quantidade " pacote(s) de máquinas \n\t\t(" (item maquina tipos-maquina) ") (D$" valor ") por D$" (quantidade * valor))
end

to print-log-aluguel-de-pulverizador [ identificador quantidade valor ]
  print-log (word "Agricultor " identificador " alugou " quantidade " pulverizador (D$" valor ") por D$" (quantidade * valor))
end

to print-log-selo-verde [ identificador parcelas-selo-verde]
  print-log (word "Fiscal concedeu selo verde para agricultor " identificador " na(s) parcela(s) (" parcelas-selo-verde ")")
end

to move-prefeito [lista]
  let tam length lista
  let i  0

  ask prefeitos [
    while [i  <= tam - 1] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i + 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]

    set i tam - 1
    while [i >= 0] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i - 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]
  ]
end

to move-fiscal [lista]
  move-fiscal-so-ida lista

  let tam length lista
  let i  0

  ask fiscais [
    set i tam - 1
    while [i >= 0] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i - 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]
  ]
end

to move-fiscal-so-ida [lista]
  let tam length lista
  let i  0

  ask fiscais [
    while [i  <= tam - 1] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i + 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]
  ]
end

to move-agricultor [identificador lista]
  let tam length lista
  let i  0

  ask agricultores with [id = identificador] [
    while [i  <= tam - 1] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i + 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]

    set i tam - 1
    while [i >= 0] [
      let x item 0 (item i lista)
      let y item 1 (item i lista)
      setxy x y
      set i i - 1
      wait tempo-espera-movimentacao
      set tempo-espera-movimentacao 0.1 / agent-movement-speed
    ]
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
21
28
85
61
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
91
10
182
43
go once
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
87
183
120
number-farmer
number-farmer
1
6
1.0
1
1
NIL
HORIZONTAL

CHOOSER
21
174
159
219
type-of-agrotoxic
type-of-agrotoxic
"random" "common" "premium" "super-premium" "no-agrotoxic"
1

CHOOSER
22
273
160
318
type-of-machine
type-of-machine
"random" "combination-1" "combination-2" "combination-3" "no-machine"
4

CHOOSER
21
224
159
269
type-of-fertilizer
type-of-fertilizer
"random" "common" "premium" "super-premium" "no-fertilizer"
1

CHOOSER
20
125
158
170
type-of-seed
type-of-seed
"random" "vegetable" "rice" "soy"
3

MONITOR
852
12
956
57
simulation-round
simulation-round
17
1
11

MONITOR
852
67
1009
112
farmer-0-account-balance
[saldo] of agricultores with [id = 0]
17
1
11

MONITOR
852
117
1009
162
farmer-1-account-balance
[saldo] of agricultores with [id = 1]
17
1
11

MONITOR
852
167
1009
212
farmer-2-account-balance
[saldo] of agricultores with [id = 2]
17
1
11

MONITOR
852
216
1009
261
farmer-3-account-balance
[saldo] of agricultores with [id = 3]
17
1
11

MONITOR
852
266
1009
311
farmer-4-account-balance
[saldo] of agricultores with [id = 4]
17
1
11

MONITOR
853
315
1010
360
farmer-5-account-balance
[saldo] of agricultores with [id = 5]
17
1
11

MONITOR
852
377
1059
422
businessman-seeds-account-balance
[saldo] of empresarios with [setor = \"s\"]
17
1
11

MONITOR
852
426
1060
471
businessman-agrotoxic-account-balance
[saldo] of empresarios with [setor = \"a\"]
17
1
11

MONITOR
852
475
1061
520
businessman-fertilizer-account-balance
[saldo] of empresarios with [setor = \"f\"]
17
1
11

MONITOR
853
524
1062
569
businessman-machine-account-balance
[saldo] of empresarios with [setor = \"m\"]
17
1
11

CHOOSER
22
322
160
367
use-of-pulverizer
use-of-pulverizer
"random" "always" "no-pulverizer"
2

SWITCH
24
468
162
501
fine?
fine?
0
1
-1000

PLOT
1071
248
1456
501
farmers' pollution
simulation-round
pollution
0.0
20.0
0.0
500.0
true
false
"" ""
PENS
"farmers" 1.0 0 -16777216 true "" "plot sum [poluicao] of agricultores "

MONITOR
853
581
986
626
mayor-account-balance
[saldo] of prefeitos
17
1
11

PLOT
1072
505
1456
758
farmers' gain
simulation-round
gain
0.0
20.0
0.0
500.0
true
false
"" ""
PENS
"gain" 1.0 0 -16777216 true "" "plot sum [producao] of agricultores "

SWITCH
23
557
199
590
enable-agent-movement?
enable-agent-movement?
1
1
-1000

PLOT
1463
249
1848
501
businessmen's pollution
simulation-round
pollution
0.0
20.0
0.0
100.0
true
false
"" ""
PENS
"pollution" 1.0 0 -16777216 true "" "plot sum [poluicao] of empresarios "

PLOT
1463
506
1848
759
businessmen's gain
simulation-round
gain
0.0
20.0
0.0
500.0
true
false
"" ""
PENS
"gain" 1.0 0 -16777216 true "" "plot sum [producao] of empresarios "

PLOT
1071
10
1455
242
global-pollution
simulation-round
polution (%)
0.0
20.0
0.0
100.0
true
false
"" ""
PENS
"polution" 1.0 0 -16777216 true "" "plot global-pollution"

CHOOSER
23
506
182
551
type-of-pollution-treatment
type-of-pollution-treatment
"random" "water-treatment" "waste-treatment" "sewage-treatment" "no-treatment"
4

SWITCH
23
377
184
410
use-all-farm-land?
use-all-farm-land?
0
1
-1000

TEXTBOX
17
703
155
753
Open \"gorim-log.txt\" file in \".\\NetLogo-Gorim\" for simulation details.
12
62.0
1

SWITCH
26
638
158
671
set-farmer-0?
set-farmer-0?
1
1
-1000

SLIDER
163
714
295
747
farmer-0-soy
farmer-0-soy
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
163
638
295
671
farmer-0-vegetable
farmer-0-vegetable
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
163
676
295
709
farmer-0-rice
farmer-0-rice
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
300
638
496
671
farmer-0-common-agrotoxic
farmer-0-common-agrotoxic
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
300
676
496
709
farmer-0-premium-agrotoxic
farmer-0-premium-agrotoxic
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
300
714
496
747
farmer-0-super-premium-agrotoxic
farmer-0-super-premium-agrotoxic
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
501
639
696
672
farmer-0-common-fertilizer
farmer-0-common-fertilizer
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
501
677
696
710
farmer-0-premium-fertilizer
farmer-0-premium-fertilizer
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
501
715
696
748
farmer-0-super-premium-fertilizer
farmer-0-super-premium-fertilizer
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
701
640
892
673
farmer-0-combination-1-machine
farmer-0-combination-1-machine
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
701
678
891
711
farmer-0-combination-2-machine
farmer-0-combination-2-machine
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
701
716
892
749
farmer-0-combination-3-machine
farmer-0-combination-3-machine
0
6
0.0
1
1
NIL
HORIZONTAL

SLIDER
899
640
1033
673
farmer-0-pulverizer
farmer-0-pulverizer
0
6
0.0
1
1
NIL
HORIZONTAL

BUTTON
91
48
183
81
go forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
23
594
199
627
agent-movement-speed
agent-movement-speed
1
10
1.0
1
1
NIL
HORIZONTAL

CHOOSER
24
419
162
464
green-seal
green-seal
"random" "always" "no-green-seal"
2

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

square 4
false
0
Rectangle -6459832 true false -30 60 -15 240
Rectangle -6459832 true false 300 60 315 240
Rectangle -6459832 true false -30 240 315 255
Rectangle -6459832 true false -30 45 315 60
Line -6459832 false -30 150 315 150
Line -6459832 false 90 60 90 240
Line -16777216 false -15 240 300 240
Line -6459832 false 195 60 195 240
Line -16777216 false 300 60 300 240
Line -16777216 false -15 60 300 60
Line -16777216 false -15 60 -15 240

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
<experiments>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F C" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F 0" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F SP" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F C" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F R" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F 0, T ESG" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F SP, T ESG" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F C, T ESG" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F 0, T ESG" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F SP, T ESG" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F C, T ESG" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F R, T ESG" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;sewage-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, F C P SP, M 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, F C P SP, M 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, F C P SP, M 2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, F C P SP, M 3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, M 1 2 3, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-1&quot;"/>
      <value value="&quot;combination-2&quot;"/>
      <value value="&quot;combination-3&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - 1 P, S SOY, F C P SP, M 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - 1 P, S SOY, F C P SP, M 2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - 1 P, S SOY, F C P SP, M 3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;combination-1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F P" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F C" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F SP, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F P, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F C, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F SP, Sem Fine" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F P, Sem Fine" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F C, Sem Fine" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F SP, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F P, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F C, Sem Fine" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, S SOY, A C P SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, S SOY, A C P SP, F P" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, S SOY, A C P SP, F C" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, 1 P, S SOY, F C P SP, M 1 2 3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, 1 P, S SOY, F C P SP, M 1 2 3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Pulverizador, S SOY, A SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Pulverizador 2, S SOY, A SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [poluicao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Pulverizador 3, S SOY, A SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [poluicao] of empresarios with [setor = "m"]</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Pulverizador 4, S SOY, A SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Pulverizador 4, S SOY, A SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C P SP, F P" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A R, F P" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S S R V, A 0, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
      <value value="&quot;rice&quot;"/>
      <value value="&quot;vegetable&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S S R V, A 0, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
      <value value="&quot;rice&quot;"/>
      <value value="&quot;vegetable&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S SOY, A C, F SP, Fine R" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, 1 P, S SOY, F SP, M 3, Selo Verde" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;no-agrotoxic&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;always&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A C P SP, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Saldo, S SOY, A R, F 0" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [saldo] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, S SOY, A C P SP, F 0" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Produção, S SOY, A R, F 0" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [producao] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;no-fertilizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Hort, A C P SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;vegetable&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Hort, A C P SP, F P" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;vegetable&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Hort, A C P SP, F C" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;vegetable&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Arroz, A C P SP, F SP" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;rice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Arroz, A C P SP, F P" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;rice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - S Arroz, A C P SP, F C" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>global-pollution</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;rice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment GORIM - Multa, S SOY, A C P SP, F SP (P C)" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="50"/>
    <metric>first [multa] of agricultores</metric>
    <enumeratedValueSet variable="number-farmer">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-seed">
      <value value="&quot;soy&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-agrotoxic">
      <value value="&quot;common&quot;"/>
      <value value="&quot;premium&quot;"/>
      <value value="&quot;super-premium&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-fertilizer">
      <value value="&quot;common&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-machine">
      <value value="&quot;no-machine&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type-of-pollution-treatment">
      <value value="&quot;no-treatment&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-of-pulverizer">
      <value value="&quot;no-pulverizer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fine?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-seal">
      <value value="&quot;no-green-seal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="use-all-farm-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enable-agent-movement?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agent-movement-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="set-farmer-0?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-2-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-vegetable">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-premium-agrotoxic">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-1-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-common-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-combination-3-machine">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-pulverizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-super-premium-fertilizer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-rice">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmer-0-soy">
      <value value="0"/>
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
