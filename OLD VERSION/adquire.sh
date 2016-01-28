#/bin/bash 
#------------------------------------------------------------------------
#
#
#  SCRIPT PARA ADQUIRIR PREVISOES DO ETA 10 DIAS DO CPTEC E 
#  CALCULAR CHUVA ACUMULADA POR BACIA DO SIN 
#
#  VERSAO 2.0 
#
#
#  bY regis  reginaldo.venturadesa@gmail.com 
#  uso:
#      adquire  [00/12]
#    
# ----------------------------------------------------------------------
# Necessita de um arquivo contendo informaçoes sonre as bacias. 
#  (ver como documentar isso aqui)
#
#
#
#------------------------------------------------------------------------- 
# essa versao é feita pela conta regisgrundig e nao pela lAMOC
#
#--------------------------------------------------------------------------


MODDEBUG=1 


#
# Existem duas rodadas do modelo ao dia. Uma as 00Z e outra as 12Z
# se nada for informada na linha de comando assume-se 00z
#
#
export LANG=en_us_8859_1

#
# verifica sistema
# no cygwin (windows) 
# se bem instalado deve
# funcionar sem as variaveis
#


MACH=`uname -a | cut -c1-5` 
if [ $MACH = "Linux" ];then 
export PATH=$PATH:/usr/local/grads
export GADDIR=/usr/local/grads
export GADLIB=/usr/local/grads
export GASCRP=/usr/local/grads
fi 

 


#
# Pega data do dia (relogio do micro)
# DATA0 = data de hoje
# DATA1 = data de amanha (para os produtos)
# DATA2 = data de 7 dias a frente 
# 

if [ $1 ="" ];then
data=`date +"%Y%m%d"`
datagrads=`date +"%d%b%Y" -d "1 days"` 
else
let b="$1-1"
data=`date +"%Y%m%d" -d "$1 days ago"`
datagrads=`date +"%d%b%Y" -d "$b  days ago"` 
fi

echo $data
echo $datagrads




hora="00"


#
# cria diretorio dos produtos do dia
#
# verifica se existe diretorio SAIDA. se não cria.
#
if [ ! -f ./SAIDAS ];then 
mkdir ./SAIDAS            >./LOG.prn 2>&1 
fi  
# entra no direotiro SAIDA e depois diretorio da data do dia
# onde tudo aocntece. 
cd SAIDAS
mkdir $data   >>./LOG.prn 2>&1 
cd $data



echo "["`date`"] BAIXANDO DADOS ETA 40KM " 
#
# Adquire os dados no site do CPTEC. 
# Atençao:  
# Verifique pois o CPTEC altera os caminhos sem avisar!!!
#
wget -nc ftp://ftp1.cptec.inpe.br/modelos/io/tempo/regional/Eta40km_ENS/prec24/$data$hora/* >>./LOG.prn 2>&1
#
# existem 10 arquivos .bin
# separados fica dificil de trabalhar com os arquivos
# por isso vou juntar todos os .bin num único do arquivo
#
echo "["`date`"] CRIANDO ARQUIVOS PARA O GRADS" 
rm $data$hora".bin" >>./LOG.prn 2>&1 
rm *.ctl            >>./LOG.prn 2>&1   
for file in `ls -1 *.bin`
do
cat $file >>  $data$hora".bin"     
rm $file                            
done
file=`echo $data$hora".bin"`
#
# caso ele não exista , algo muito errado aconteceu
#
if [ ! -s $file ]
then
 exit
fi 

#
#  crio o arquivo descriptor(CTL) de acordo com a data de hoje
#  YYYMMDDHH.BIN foi criado antes (todos os bin num unico bin)
#  modelo_all.ctl é o nome para acessar YYYMMDDHH.BIN
#

let b="1"
echo "DSET ^"$data$hora".bin" >modelo_all.ctl
echo "UNDEF -9999." >>modelo_all.ctl 
echo "TITLE eta 10 dias" >>modelo_all.ctl
echo "XDEF  144 LINEAR  -83.00   0.40" >>modelo_all.ctl
echo "YDEF  157 LINEAR  -50.20   0.40" >>modelo_all.ctl
echo "ZDEF   1 LEVELS 1000" >>modelo_all.ctl
echo "TDEF   10 LINEAR 12Z"$datagrads" 24hr" >>modelo_all.ctl
echo "VARS  1" >>modelo_all.ctl
echo "PREC  0  99  Total  24h Precip.        (m)" >>modelo_all.ctl
echo "ENDVARS" >>modelo_all.ctl


##-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#  cria o script para data operativa por bacia cadastrada
#  as bacias estao cadastradas em CADASTRO/CADASTRADAS
# ver documentacao para maiores detalhes
##
echo "*"                                                                 >figura3.gs
echo "* esse script é auto gerado. documentação em adquire_eta.sh"      >>figura3.gs
echo "*By reginaldo.venturadesa@gmail.com "                             >>figura3.gs
echo "'open modelo_all.ctl'"            >>figura3.gs
#echo "*'set mpdset hires'"               >>figura3.gs
echo "'set gxout shaded'"               >>figura3.gs
#
# pega parametros de execucao do grads
# se é retrato ou paisagem
#
echo "'q gxinfo'"   >>figura3.gs
echo "var=sublin(result,2)"  >>figura3.gs
echo "page=subwrd(var,4)" >>figura3.gs
echo "*say page" >>figura3.gs
#
# se for retrato cria vpage
#
echo "if (page ="8.5") " >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'" >>figura3.gs
echo "endif"                                  >>figura3.gs
#
# Script grads: acha o dia que cai na sexta
#
#  t0= tempo inicial 
#  tsex=tempo com a sexta-feira
#  tfinal=ultimo tempo
# 
echo "t0=10"                            >>figura3.gs  
echo "tfinal=10"                        >>figura3.gs  
echo "'set t 1 last'"                   >>figura3.gs
echo "'q time'"                         >>figura3.gs
echo "var3=subwrd(result,5)"            >>figura3.gs
echo "tt=1"                             >>figura3.gs
echo "while (tt<=10)"                   >>figura3.gs
echo "'set t ' tt"                      >>figura3.gs
echo "'q time'"                         >>figura3.gs
echo "var=subwrd(result,6)"             >>figura3.gs
echo "if (var = "Fri" )"                >>figura3.gs
echo "t0=1"                            >>figura3.gs
echo "tsex=tt"                            >>figura3.gs
echo "tt=12"                            >>figura3.gs
echo "endif"                            >>figura3.gs
echo "tt=tt+1"                          >>figura3.gs
echo "endwhile"                         >>figura3.gs
echo "*say t0"                           >>figura3.gs
echo "tsab=tsex+1"                       >>figura3.gs
echo "tfinal=tsab+6"                    >>figura3.gs
#
# pega informacoes
# de data
# data de inicio 
# data do sabado 
# data final 
#
#
#  data RODADA
#
echo "'set t  0'"                     >>figura3.gs
echo "'q time'"                         >>figura3.gs
echo "var0=subwrd(result,3)"            >>figura3.gs
#
#  data da semana operativa 1
#
echo "'set t 1 'tsex"                     >>figura3.gs
echo "'q time'"                         >>figura3.gs
echo "var1=subwrd(result,3)"            >>figura3.gs
echo "var2=subwrd(result,5)"            >>figura3.gs
#
#  data da semana operativa 2
#
echo "'set t 'tsab' 'tfinal"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var3=subwrd(result,3)"            >>figura3.gs
echo "var4=subwrd(result,5)"            >>figura3.gs

#
# semana 7 dias
#
echo "'set t 1 7'"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var5=subwrd(result,5)"            >>figura3.gs

# data  rodada
echo "ano0=substr(var0,9,4)"                       >>figura3.gs
echo "mes0=substr(var0,6,3)"                       >>figura3.gs
echo "dia0=substr(var0,4,2)"                       >>figura3.gs

# data inicial previsao 
echo "ano1=substr(var1,9,4)"                       >>figura3.gs
echo "mes1=substr(var1,6,3)"                       >>figura3.gs
echo "dia1=substr(var1,4,2)"                       >>figura3.gs
# data proxima sexta-feira
echo "ano2=substr(var2,9,4)"                       >>figura3.gs
echo "mes2=substr(var2,6,3)"                       >>figura3.gs
echo "dia2=substr(var2,4,2)"                       >>figura3.gs
# data sabado
echo "ano3=substr(var3,9,4)"                       >>figura3.gs
echo "mes3=substr(var3,6,3)"                       >>figura3.gs
echo "dia3=substr(var3,4,2)"                       >>figura3.gs
# data final
echo "ano4=substr(var4,9,4)"                       >>figura3.gs
echo "mes4=substr(var4,6,3)"                       >>figura3.gs
echo "dia4=substr(var4,4,2)"                       >>figura3.gs
# data 7 dias
echo "ano5=substr(var5,9,4)"                       >>figura3.gs
echo "mes5=substr(var5,6,3)"                       >>figura3.gs
echo "dia5=substr(var5,4,2)"                       >>figura3.gs


#
# a rotina varre o arquivo contendo os contornos das bacias
# para cada contorno encontrado ele gera as figuras
# 
echo "status2=0"                       >>figura3.gs
echo "while(!status2)" >>figura3.gs
echo 'fd=read("../../CONTORNOS/CADASTRADAS/limites_das_bacias.dat")' >>figura3.gs
echo "status2=sublin(fd,1) "    >>figura3.gs
echo "if (status2 = 0) "        >>figura3.gs
echo "linha=sublin(fd,2)"       >>figura3.gs
echo "bacia=subwrd(linha,1)"     >>figura3.gs
echo "shape=subwrd(linha,2)"     >>figura3.gs
echo "x0=subwrd(linha,3)"       >>figura3.gs
echo "x1=subwrd(linha,4)"       >>figura3.gs
echo "y0=subwrd(linha,5)"       >>figura3.gs
echo "y1=subwrd(linha,6)"       >>figura3.gs
echo "tipo=subwrd(linha,7)"     >>figura3.gs
echo "plota=subwrd(linha,8)"    >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de retrato 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#   FIGURAS RETRATO SEMANA OPERATIVA 1
# 
echo "if (tipo = "RETRATO" & page ="8.5" & plota="SIM") "   >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'"                                  >>figura3.gs
echo "'set t 1'"                        >>figura3.gs
echo "'cores.gs'"                    >>figura3.gs
echo "'d sum(prec,t=1,t='tsex')'"         >>figura3.gs
echo "'cbarn.gs'"                       >>figura3.gs
echo "'draw string 2.5 10.8 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 1'"  >>figura3.gs
echo "'draw string 2.5 10.6 RODADA :'dia1=0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 10.4 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs
echo "if (bacia="brasil")"                    >>figura3.gs
echo "'plota.gs'"                             >>figura3.gs
echo "else"                    >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "endif"                    >>figura3.gs
echo "'cbarn.gs'" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs  
echo "plotausina(bacia,page)" >>figura3.gs    
echo "'printim 'bacia'_semanaoperativa_1_"$data".png white'"                       >>figura3.gs
#
# FIGURAS RETARTO SEMANA OPERATIVA 2
#
echo "'c'"                                                             >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'"                                  >>figura3.gs
echo "'cores.gs'"                                                >>figura3.gs
echo "'d sum(prec,t='tsab',t='tfinal')'"                                       >>figura3.gs
echo "*'cbarn.gs'"                                                      >>figura3.gs
echo "'draw string 2.5 10.8 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 2 '">>figura3.gs
echo "'draw string 2.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 10.4 PERIODO:'dia3'/'mes3'/'ano3' a 'dia4'/'mes4'/'ano4  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'"       >>figura3.gs
echo "'basemap.gs O 50 0 M'"                 >>figura3.gs
echo "'set mpdset hires'"                    >>figura3.gs
echo "'set map 15 1 6'"                      >>figura3.gs
echo "'draw map'"                            >>figura3.gs
echo "if (bacia="brasil")"                    >>figura3.gs
echo "'plota.gs'"                             >>figura3.gs
echo "else"                    >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "endif"                    >>figura3.gs
echo "'cbarn.gs'" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs  
echo "plotausina(bacia,page)" >>figura3.gs    
echo "'printim 'bacia'_semanaoperativa_2_"$data".png white'"                       >>figura3.gs
#
# FIGURA RETRATO SEMANA 7 DIAS CORRIDOS 
#
echo "'c'"   >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'"                                  >>figura3.gs
#echo "'set mpdset hires'"                                    >>figura3.gs
echo "'cores.gs'"                                         >>figura3.gs
echo "'set gxout shaded'"                                    >>figura3.gs
echo "'d sum(prec,t=1,t=7)'"                                 >>figura3.gs
echo "'draw string 2.5 10.8 PRECIPITACAO ACUMULADA 7 DIAS '"  >>figura3.gs
echo "'draw string 2.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 10.4 PERIODO:'dia1'/'mes1'/'ano1' a 'dia5'/'mes5'/'ano5  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs
echo "'cbarn.gs'"                                            >>figura3.gs
echo "if (bacia="brasil")"                    >>figura3.gs
echo "'plota.gs'"                             >>figura3.gs
echo "else"                    >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "endif"                    >>figura3.gs
echo "'cbarn.gs'" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs  
echo "'printim 'bacia'_prec07dias_"$data"_"$hora"Z.png white'"       >>figura3.gs
echo "*say t0"                           >>figura3.gs
echo "endif"                            >>figura3.gs 
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de paisagem 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#
#  FIGURA PAISAGEM  SEMANA OPERATIVA 1
#
echo "if (tipo = "PAISAGEM" & page ="11" & plota="SIM" ) "   >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 10.5 1.88392 7.31608'"                     >>figura3.gs
echo "'set t 1'"                        >>figura3.gs
echo "'cores.gs'"                    >>figura3.gs
echo "'d sum(prec,t=1,t='tsex')'"         >>figura3.gs
echo "'cbarn.gs'"                       >>figura3.gs
echo "'draw string 2.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 1'"  >>figura3.gs
#echo "'draw string 2.5 8.1 RODADA:"$DATA0" - "$hora"Z'"                >>figura3.gs
#echo "'draw string 2.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura3.gs
echo "'draw string 2.5 8.1 RODADA :'dia0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs   
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "say shape" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs  
echo "'printim 'bacia'_semanaoperativa_1_"$data".png white'"                       >>figura3.gs
#
# FIGURA PAISAGEM SEMANA OPERATIVA 2
#
echo "'c'"                                                             >>figura3.gs
echo "'set parea 0.5 10.5 1.88392 7.31608'"                     >>figura3.gs
echo "'cores.gs'"                                                >>figura3.gs
echo "'d sum(prec,t='tsab',t='tfinal')'"                                       >>figura3.gs
echo "'cbarn.gs'"                                                      >>figura3.gs
echo "'draw string 2.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 2 '">>figura3.gs
echo "'draw string 2.5 8.1 RODADA :'dia0'/'mes0'/'ano0"               >>figura3.gs
echo "'draw string 2.5 7.9 PERIODO:'dia3'/'mes3'/'ano3' a 'dia4'/'mes4'/'ano4  "      >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs     
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                        >>figura3.gs
echo "'cbarn.gs'" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs  

echo "'printim 'bacia'_semanaoperativa_2_"$data".png white'"                       >>figura3.gs
#
# FIGURA PAISAGEM SEMANA 7 dias
#
echo "'c'"   >>figura3.gs
echo "*'set parea 0.5 10.5 1.88392 7.31608'"                     >>figura3.gs
echo "'set parea off'"                                    >>figura3.gs
echo "'set mpdset hires'"                                    >>figura3.gs
echo "'cores.gs'"                                         >>figura3.gs
echo "'set gxout shaded'"                                    >>figura3.gs
echo "'d sum(prec,t=1,t=7)'"                                 >>figura3.gs
echo "'draw string 2.5 8.3 PRECIPITACAO ACUMULADA 7 DIAS '"  >>figura3.gs
#echo "'draw string 2.5 8.1 RODADA :"$DATA0" - "$hora"Z'"     >>figura3.gs
#echo "'draw string 2.5 7.9 Periodo:"$DATA2" a "$DATA1"'"     >>figura3.gs
echo "'draw string 2.5 8.1 RODADA :'dia0'/'mes0'/'ano0"               >>figura3.gs
echo "'draw string 2.5  7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia5'/'mes5'/'ano5  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs     
echo "'cbarn.gs'"                                            >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"     >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs 
echo "'printim 'bacia'_prec07dias_"$data"_"$hora"Z.png white'"       >>figura3.gs
echo "*say t0"                           >>figura3.gs
echo "endif"                            >>figura3.gs 
#
# PARTE FINAL DO SCRIPT . NÃO MEXER 
#

echo "endif"                            							>>figura3.gs 
echo "endwhile"                          							>>figura3.gs

#
# modulo de debug . para ativar MODDEBUG=1 
#

if [  MODDEBUG=1 ];then 
#
# ESCALA  ATUAL 
#
echo "* escala SUGERIDA ">coresdiaria.gs
echo "*">>cores.gscoresdiaria
echo "'define_colors.gs'">>coresdiaria.gs
echo "'set rgb 99 251 94 107'">>coresdiaria.gs
echo "'set clevs    05 10 15 20 25 30 35  50  70  100  150'">>coresdiaria.gs
echo "'set ccols 00 44 45 47 49 34 37 39  22  23  27    29   99'  ">>coresdiaria.gs

echo "'set lon -80.0000   -30.0000   '"                     >>figura3.gs
echo "'set lat   -35 06.0000         ' "                                    >>figura3.gs
echo " t=1"                                    >>figura3.gs
echo " while (t<=10)"                                    >>figura3.gs
echo "'c'"   >>figura3.gs
echo "'set t 't"                                    >>figura3.gs
echo "'q time'"                                    >>figura3.gs
echo "datah=subwrd(result,3) "                                    >>figura3.gs
# data 7 dias
echo "ano6=substr(datah,9,4)"                       >>figura3.gs
echo "mes6=substr(datah,6,3)"                       >>figura3.gs
echo "dia6=substr(datah,4,2)"                       >>figura3.gs
echo "'coresdiaria.gs'"                                         >>figura3.gs
echo "'set gxout shaded'"                                    >>figura3.gs
echo "'d prec'"                                 >>figura3.gs
echo "'draw string 2.5 8.3 PRECIPITACAO DIARIA '"  >>figura3.gs
echo "'draw string 2.5 8.1 RODADA :'dia1'/'mes1'/'ano1"               >>figura3.gs
echo "'draw string 2.5 7.9 DIA    :'dia6'/'mes6'/'ano6"      >>figura3.gs
#echo "'draw string 2.5 8.1 RODADA :"$DATA0" - "$hora"Z'"     >>figura3.gs
#echo "'draw string 2.5 7.9 Periodo:'datah"    >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs     
echo "'cbarn.gs'"                                            >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp'"     >>figura3.gs
#echo  "plotausina(bacia,page)"                          >>figura3.gs  
echo "'plota_hidrografia.gs'"                          >>figura3.gs
echo "'printim prec_diaria_'datah'.png white'"      >>figura3.gs
echo "t=t+1"                                    >>figura3.gs
echo "endwhile"                                    >>figura3.gs
fi 
echo "'quit'"                          								>>figura3.gs
#
#  cria arquivo de plotagem das bacias no mapa do brasil 
# 
echo "'set line 15 1 1'"                                             >plota.gs
echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp '"                 >>plota.gs
echo "'set line 1 1 1'"                                              >>plota.gs
for file in `ls -1 ../../CONTORNOS/SHAPES/contorno*.shp`
do
echo "'draw shp "$file"'"                                            >>plota.gs
done
#
#  plota a hidrografia  
# 
echo "'set line 5 1 1'"                                             >plota_hidrografia.gs
echo "'draw shp ../../CONTORNOS/SHAPES/hidrografia.shp '"                 >>plota_hidrografia.gs
echo "'set line 5 1 1'"                                             >>plota_hidrografia.gs
#
#  CRIA ESCALA DE CORES 
#   (PARA HABILITAR , RETIRE O * DA FRENTE DA LINHA E COLOQUE * NA QUE 
#    DESEJA DESABILITAR 
#
# ESCALA ANTIGA PARA GRANDES ACUMULOS
#
echo "* escala antiga 0 a 1000  " >cores.gs
echo "*'define_colors.gs' ">>cores.gs
echo "*'set clevs      1  10  20  30  40  50  60  70  80   90  100 125 150 175  200  225  250  275   300 325  350  375  400 425  450 475  500 550 600 650 700 800 900 1000'">>cores.gs
echo "*'set ccols  00 00  31  32  33  34  35  36  37  38   39  42  43   44  45   46   47   48   49   72   73    74   75  76   77   78  79  21  22  23  24  25  26  27  28  29 '">>cores.gs
echo "*'set gxout shaded'">>cores.gs
echo "* escala nova ">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99  230 230 230'">>cores.gs
echo "*'set clevs      1  05 10 15 20 25 30 35 40 45 50 60 70 80 90 100 150 200 '">>cores.gs
echo "*'set ccols  00  99 99 32 33 34 35 36 37 38 39 45 46 47 48 49  26  27  28  29 '">>cores.gs
#
# ESCALA CPTEC
#
echo "* escala CPTEC">>cores.gs 
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99  230 230 230'">>cores.gs
echo "*light green to dark green">>cores.gs
echo "*'set rgb 31 230 255 225'">>cores.gs
echo "*'set rgb 32 200 255 190'">>cores.gs
echo "*'set rgb 33 180 250 170'">>cores.gs
echo "*'set rgb 34 150 245 140'">>cores.gs
echo "*'set rgb 35 120 245 115'">>cores.gs
echo "*'set rgb 36  80 240  80'">>cores.gs
echo "*'set rgb 37  5 138  00'">>cores.gs
echo "*'set rgb 38  38 111  27'">>cores.gs
echo "*'set rgb 39  58 111  58'">>cores.gs
echo "*'set clevs      1  05 10 15 20 25 30 35 40 50 60 70  '">>cores.gs
echo "*'set ccols  00  28 27 25 23 22 21 41 42 35 36 37 38 39 '">>cores.gs
echo "*'set gxout shaded'">>cores.gs
#
# ESCALA ONS OLD
#
echo "*">>cores.gs
echo "* escala ONS semanal old">>cores.gs
echo "*">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set clevs 00 01 10 25 50 75 100 150 200'">>cores.gs
echo "*'set ccols 00 41 42 43 '">>cores.gs
#
# ESCALA ONS ATUAL 
#
echo "* escala baseada no ONS ">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99 251 94 107'">>cores.gs
echo "*'set clevs    01 05 10 15 20 25 30 40 50 75 100 150 200'">>cores.gs
echo "*'set ccols 41 42 43 47 49 34 37 39 22 23 27  99'  ">>cores.gs
echo "*">>cores.gs
#
# ESCALA  ATUAL 
#
echo "* escala SUGERIDA ">>cores.gs
echo "*">>cores.gs
echo "'define_colors.gs'">>cores.gs
echo "'set rgb 99 251 94 107'">>cores.gs
echo "'set clevs    20 25 30 40 50 75 100 150 200 250 300'">>cores.gs
echo "'set ccols 00 44 45 47 49 34 37 39  22  23  27  29 99'  ">>cores.gs



#
# ESSE ARQUIVO CONTEM AS LOCALIZACOES DAS USNINAS
# A SEREM PLOTADOS NAS FIGURAS xxxxxxx
#
cat  ../../UTIL/modulo_grads.mod  >> figura3.gs





echo "["`date`"] CALCULANDO MEDIA POR BACIA" 
#
# Geracao de produtos
#
cp ../../calcula_versao3.gs .
echo "["`date`"] CALCULANDO MÉDIA POR BACIA " 
grads -lbc "calcula_versao3.gs" >>./LOG.prn 2>&1




echo "["`date`"] PLOTANDO FIGURAS SEMANA OPERATIVA FORMATO RETRATO POR BACIAS" 
grads -pbc "figura3.gs"  >>./LOG.prn 2>&1
echo "["`date`"] PLOTANDO FIGURAS SEMANA OPERATIVA FORMATO PAISAGEM POR BACIAS" 
grads -lbc "figura3.gs"  >>./LOG.prn 2>&1
echo "["`date`"] AJUSTANDO CRIAÇÕES " 
mkdir imagens_semanaoperativa_1  >>./LOG.prn 2>&1
mkdir imagens_semanaoperativa_2 >>./LOG.prn 2>&1
mkdir imagens_7dias   >>./LOG.prn 2>&1
mkdir diaria >>./LOG.prn 2>&1
mv *semanaoperativa_1*  imagens_semanaoperativa_1  >>./LOG.prn 2>&1
mv *semanaoperativa_2*  imagens_semanaoperativa_2  >>./LOG.prn 2>&1
mv *prec07dias* imagens_7dias                      >>./LOG.prn 2>&1
mv prec_diaria* diaria

cd ..
cd ..
pwd

echo "["`date`"] FIM DO PROCESSO ETA 40KM" 

echo "["`date`"] ADQUIRINDO DADOS OBSERVADOS" 



echo "-----------------------------------------------------------------------------------------------------------------"


export LANG=en_us_8859_1

#
# verifica sistema
# no cygwin (windows) 
# se bem instalado deve
# funcionar sem as variaveis
#
MACH=`uname -a | cut -c1-5` 
if [ $MACH = "Linux" ];then 
export PATH=$PATH:/usr/local/grads
export GADDIR=/usr/local/grads
export GADLIB=/usr/local/grads
export GASCRP=/usr/local/grads
fi 



MODDEBUG=1 
#
# Pega data do dia (relogio do micro)
# DATA0 = data de hoje
# DATA1 = data de amanha (para os produtos)
# DATA2 = data de 7 dias a frente 
# 

#data=`date +"%Y%m%d" -d "$1 days ago"`

# echo `date +"%Y%m%d" -d "$1 days ago"`
# echo $1
# echo $data


#
# entra no diretorio de trabalho 
#
if [ ! -f ./CHUVA_DE_GRADE ];then 
mkdir ./CHUVA_DE_GRADE            >./LOG.prn 2>&1 
fi  
# entra no direotiro SAIDA e depois diretorio da data do dia
# onde tudo aocntece. 
cd CHUVA_DE_GRADE
mkdir $data    >>./LOG.prn 2>&1 

if [ ! -f ./DADOS ];then 
mkdir ./DADOS            >>./LOG.prn 2>&1 
fi  

cd DADOS



#
# baixa as 63 ultimas chuvas. se jรก baixou passa adiante. 
#




for n in `seq --format=%02g 0 33`
do
#let b="$n + $1"
#echo $b
download_data=`date +"%Y%m%d" -d "$n days ago"`
ano=`date +"%Y"`
wget -nc ftp1.cptec.inpe.br/modelos/io/produtos/MERGE/$ano/prec_$download_data".bin" >>./LOG.prn 2>&1
###wget -nc ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/$ano/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.$download_data".RT"  >>./LOG.prn 2>&1  
done

cd ..



#let b="33 + $1"
grads_data=`date -d "34 days ago" +"12Z%d%b%Y"`
#data=`date +"%Y%m%d" -d "$1 days ago"`
mkdir $data
cd $data
cp ../../calcula_chuva_merge.gs .





#
# cria o arquivo ctl 
#
echo "dset ^../DADOS/prec_%y4%m2%d2.bin" >chuvamerge.ctl
echo "options  little_endian template"                        >>chuvamerge.ctl
echo "title global daily analysis "                           >>chuvamerge.ctl
echo "undef -999.0 "                                          >>chuvamerge.ctl 
echo "xdef 245 linear    -82.8000 0.2000"                           >>chuvamerge.ctl
echo "ydef 313 linear -50.2000  0.2000 "                          >>chuvamerge.ctl
echo "zdef 1    linear 1 1 "                                  >>chuvamerge.ctl
echo "tdef 34 linear $grads_data 1dy "                         >>chuvamerge.ctl
echo "vars 2"                                                 >>chuvamerge.ctl
echo "rain     1  00 the grid analysis (0.1mm/day)"           >>chuvamerge.ctl
echo "gnum     1  00 the number of stn"                       >>chuvamerge.ctl
echo "ENDVARS"                                                >>chuvamerge.ctl

echo "["`date`"] CALCULANDO CHUVA  OBSERVADA" 

grads -lbc "calcula_chuva_merge.gs"  >>./LOG.prn 2>&1 

#----------------------------------------------------

#-----------------------------------------------------------------------------------------
#  cria o script para data operativa por bacia cadastrada
#  as bacias estao cadastradas em CADASTRO/CADASTRADAS
# ver documentacao para maiores detalhes
#
echo "*"                                                                 >figura3.gs
echo "* esse script é auto gerado. documentação em adquire_eta.sh"      >>figura3.gs
echo "*By reginaldo.venturadesa@gmail.com "                             >>figura3.gs
echo "'open chuvamerge.ctl'"            >>figura3.gs
#echo "*'set mpdset hires'"               >>figura3.gs
echo "'set gxout shaded'"               >>figura3.gs
#
# pega parametros de execucao do grads
# se é retrato ou paisagem
#
echo "'q gxinfo'"   >>figura3.gs
echo "var=sublin(result,2)"  >>figura3.gs
echo "page=subwrd(var,4)" >>figura3.gs
echo "*say page" >>figura3.gs
#
# se for retrato cria vpage
#
echo "if (page ="8.5") " >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'" >>figura3.gs
echo "endif"                                  >>figura3.gs
#
# Script grads: acha o dia que cai na sexta
#
#  t0= tempo inicial 
#  tsex=tempo com a sexta-feira
#  tfinal=ultimo tempo
# 
# echo "t0=10"                            >>figura3.gs  
# echo "tfinal=10"                        >>figura3.gs  
# echo "'set t 1 last'"                   >>figura3.gs
# echo "'q time'"                         >>figura3.gs
# echo "var3=subwrd(result,5)"            >>figura3.gs
# echo "tt=1"                             >>figura3.gs
# echo "while (tt<=10)"                   >>figura3.gs
# echo "'set t ' tt"                      >>figura3.gs
# echo "'q time'"                         >>figura3.gs
# echo "var=subwrd(result,6)"             >>figura3.gs
# echo "if (var = "Fri" )"                >>figura3.gs
# echo "t0=1"                            >>figura3.gs
# echo "tsex=tt"                            >>figura3.gs
# echo "tt=12"                            >>figura3.gs
# echo "endif"                            >>figura3.gs
# echo "tt=tt+1"                          >>figura3.gs
# echo "endwhile"                         >>figura3.gs
# echo "*say t0"                           >>figura3.gs
# echo "tsab=tsex+1"                       >>figura3.gs
# echo "tfinal=tsab+6"                    >>figura3.gs
#
# pega informacoes
# de data
# data de inicio 
# data do sabado 
# data final 
#
#
#  data RODADA                 UGAMONGA
#
echo "'set t  0'"                     >>figura3.gs
echo "'q time'"                         >>figura3.gs
echo "var0=subwrd(result,3)"            >>figura3.gs
#
#  data da semana operativa 1
#
# echo "'set t 1 'tsex"                     >>figura3.gs
# echo "'q time'"                         >>figura3.gs
# echo "var1=subwrd(result,3)"            >>figura3.gs
# echo "var2=subwrd(result,5)"            >>figura3.gs
# #
# #  data da semana operativa 2
# #
# echo "'set t 'tsab' 'tfinal"                     >>figura3.gs   
# echo "'q time'"                           >>figura3.gs 
# echo "var3=subwrd(result,3)"            >>figura3.gs
# echo "var4=subwrd(result,5)"            >>figura3.gs

# #
# # semana 7 dias
# #
# echo "'set t 1 7'"                     >>figura3.gs   
# echo "'q time'"                           >>figura3.gs 
# echo "var5=subwrd(result,5)"            >>figura3.gs

# # data  rodada
# echo "ano0=substr(var0,9,4)"                       >>figura3.gs
# echo "mes0=substr(var0,6,3)"                       >>figura3.gs
# echo "dia0=substr(var0,4,2)"                       >>figura3.gs

# # data inicial previsao 
# echo "ano1=substr(var1,9,4)"                       >>figura3.gs
# echo "mes1=substr(var1,6,3)"                       >>figura3.gs
# echo "dia1=substr(var1,4,2)"                       >>figura3.gs
# # data proxima sexta-feira
# echo "ano2=substr(var2,9,4)"                       >>figura3.gs
# echo "mes2=substr(var2,6,3)"                       >>figura3.gs
# echo "dia2=substr(var2,4,2)"                       >>figura3.gs
# # data sabado
# echo "ano3=substr(var3,9,4)"                       >>figura3.gs
# echo "mes3=substr(var3,6,3)"                       >>figura3.gs
# echo "dia3=substr(var3,4,2)"                       >>figura3.gs
# # data final
# echo "ano4=substr(var4,9,4)"                       >>figura3.gs
# echo "mes4=substr(var4,6,3)"                       >>figura3.gs
# echo "dia4=substr(var4,4,2)"                       >>figura3.gs
# # data 7 dias
# echo "ano5=substr(var5,9,4)"                       >>figura3.gs
# echo "mes5=substr(var5,6,3)"                       >>figura3.gs
# echo "dia5=substr(var5,4,2)"                       >>figura3.gs


#
# a rotina varre o arquivo contendo os contornos das bacias
# para cada contorno encontrado ele gera as figuras
# 
echo "status2=0"                       >>figura3.gs
echo "while(!status2)" >>figura3.gs
echo 'fd=read("../../CONTORNOS/CADASTRADAS/limites_das_bacias.dat")' >>figura3.gs
echo "status2=sublin(fd,1) "    >>figura3.gs
echo "if (status2 = 0) "        >>figura3.gs
echo "linha=sublin(fd,2)"       >>figura3.gs
echo "bacia=subwrd(linha,1)"     >>figura3.gs
echo "shape=subwrd(linha,2)"     >>figura3.gs
echo "x0=subwrd(linha,3)"       >>figura3.gs
echo "x1=subwrd(linha,4)"       >>figura3.gs
echo "y0=subwrd(linha,5)"       >>figura3.gs
echo "y1=subwrd(linha,6)"       >>figura3.gs
echo "tipo=subwrd(linha,7)"     >>figura3.gs
echo "plota=subwrd(linha,8)"    >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs


#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de retrato 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#   FIGURAS RETRATO SEMANA OPERATIVA 1
# 
echo "if (tipo = "RETRATO" & page ="8.5" & plota="SIM") "   >>figura3.gs
echo "t=1 "    >>figura3.gs 
echo "while (t<=33) "    >>figura3.gs 
echo "'set t 't"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var1=subwrd(result,3)"            >>figura3.gs
echo "ano1=substr(var1,9,4)"                       >>figura3.gs
echo "mes1=substr(var1,6,3)"                       >>figura3.gs
echo "dia1=substr(var1,4,2)"                       >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 8.5 1.5 10.2'"                                  >>figura3.gs
echo "'set t 1'"                        >>figura3.gs
echo "'cores.gs'"                    >>figura3.gs
echo "'d rain'"            >>figura3.gs
echo "'cbarn.gs'"                       >>figura3.gs
echo "'draw string 2.5 10.8 PRECIPITACAO ACUMULADA DIARIA'"  >>figura3.gs
echo "'draw string 2.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 10.4 DIA    :'dia1'/'mes1'/'ano1'  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" 								>>figura3.gs
echo "'basemap.gs O 50 0 M'" 										>>figura3.gs
echo "'set mpdset hires'" 											>>figura3.gs
echo "'set map 15 1 6'" 											>>figura3.gs
echo "'draw map'" 													>>figura3.gs
echo "if (bacia="brasil")"                    >>figura3.gs
echo "'plota.gs'"                             >>figura3.gs
echo "else"                    >>figura3.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "endif"                    >>figura3.gs
echo "'cbarn.gs'" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs  
echo "plotausina(bacia,page)" >>figura3.gs    
echo "'printim 'bacia'_diario_"$data".png white'"                       >>figura3.gs
echo "t=t+1"                    >>figura3.gs
echo "c"                    >>figura3.gs
echo "endwhile"                    >>figura3.gs

#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de paisagem 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#
#  FIGURA PAISAGEM  SEMANA OPERATIVA 1
#
echo "if (tipo = "PAISAGEM" & page ="11" & plota="SIM" ) "   >>figura3.gs
echo "t=1 "    >>figura3.gs 
echo "while (t<=33) "    >>figura3.gs 
echo "'set t 't"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var1=subwrd(result,3)"            >>figura3.gs
echo "ano1=substr(var1,9,4)"                       >>figura3.gs
echo "mes1=substr(var1,6,3)"                       >>figura3.gs
echo "dia1=substr(var1,4,2)"                       >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 10.5 1.88392 7.31608'"                     >>figura3.gs
echo "'set t 1'"                        >>figura3.gs
echo "'cores.gs'"                    >>figura3.gs
echo "'d rain'"         >>figura3.gs
echo "'cbarn.gs'"                       >>figura3.gs
echo "'draw string 2.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 1'"  >>figura3.gs
#echo "'draw string 2.5 8.1 RODADA:"$DATA0" - "$hora"Z'"                >>figura3.gs
#echo "'draw string 2.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura3.gs
echo "'draw string 2.5 8.1 RODADA :'dia0'/'mes0'/'ano0 "               >>figura3.gs
echo "'draw string 2.5 7.9 DIA    :'dia1'/'mes1'/'ano1'   "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs   
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "say shape" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs  
echo "'printim 'bacia'_diaria_"$data".png white'"                       >>figura3.gs
echo "'c'"                                                             >>figura3.gs
echo "t=t+1"                    >>figura3.gs
echo "c"                    >>figura3.gs
echo "endwhile"                    >>figura3.gs

#
# PARTE FINAL DO SCRIPT . NÃO MEXER 
#

echo "endif"                            							>>figura3.gs 
echo "endwhile"                          							>>figura3.gs

#
# modulo de debug . para ativar MODDEBUG=1 
#

if [  MODDEBUG=1 ];then 
#
# ESCALA  ATUAL 
#
echo "* escala SUGERIDA ">coresdiaria.gs
echo "*">>cores.gscoresdiaria
echo "'define_colors.gs'">>coresdiaria.gs
echo "'set rgb 99 251 94 107'">>coresdiaria.gs
echo "'set clevs    05 10 15 20 25 30 35  50  70  100  150'">>coresdiaria.gs
echo "'set ccols 00 44 45 47 49 34 37 39  22  23  27    29   99'  ">>coresdiaria.gs

# echo "'set lon -80.0000   -30.0000   '"                     >>figura3.gs
# echo "'set lat   -35 06.0000         ' "                                    >>figura3.gs
# echo " t=1"                                    >>figura3.gs
# echo " while (t<=33)"                                    >>figura3.gs
# echo "'c'"   >>figura3.gs
# echo "'set t 't"                                    >>figura3.gs
# echo "'q time'"                                    >>figura3.gs
# echo "datah=subwrd(result,3) "                                    >>figura3.gs
# # data 7 dias
# echo "ano6=substr(datah,9,4)"                       >>figura3.gs
# echo "mes6=substr(datah,6,3)"                       >>figura3.gs
# echo "dia6=substr(datah,4,2)"                       >>figura3.gs
# echo "'coresdiaria.gs'"                                         >>figura3.gs
# echo "'set gxout shaded'"                                    >>figura3.gs
# echo "'d rain'"                                 >>figura3.gs
# echo "'draw string 2.5 8.3 PRECIPITACAO DIARIA '"  >>figura3.gs
# echo "'draw string 2.5 8.1 RODADA :'dia1'/'mes1'/'ano1"               >>figura3.gs
# echo "'draw string 2.5 7.9 DIA    :'dia6'/'mes6'/'ano6"      >>figura3.gs
# #echo "'draw string 2.5 8.1 RODADA :"$DATA0" - "$hora"Z'"     >>figura3.gs
# #echo "'draw string 2.5 7.9 Periodo:'datah"    >>figura3.gs
# echo "'set rgb 50   255   255    255'" >>figura3.gs
# echo "'basemap.gs O 50 0 M'" >>figura3.gs
# echo "'set mpdset hires'" >>figura3.gs
# echo "'set map 15 1 6'" >>figura3.gs
# echo "'draw map'" >>figura3.gs     
# echo "'cbarn.gs'"                                            >>figura3.gs
# echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp'"     >>figura3.gs
# #echo  "plotausina(bacia,page)"                          >>figura3.gs  
# echo "'plota_hidrografia.gs'"                          >>figura3.gs
# echo "'printim prec_diaria_'datah'.png white'"      >>figura3.gs
# echo "t=t+1"                                    >>figura3.gs
# echo "endwhile"                                    >>figura3.gs
# fi 
echo "'quit'"                          								>>figura3.gs
#
#  cria arquivo de plotagem das bacias no mapa do brasil 
# 
echo "'set line 15 1 1'"                                             >plota.gs
echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp '"                 >>plota.gs
echo "'set line 1 1 1'"                                              >>plota.gs
for file in `ls -1 ../../CONTORNOS/SHAPES/contorno*.shp`
do
echo "'draw shp "$file"'"                                            >>plota.gs
done
#
#  plota a hidrografia  
# 
echo "'set line 5 1 1'"                                             >plota_hidrografia.gs
echo "'draw shp ../../CONTORNOS/SHAPES/hidrografia.shp '"                 >>plota_hidrografia.gs
echo "'set line 5 1 1'"                                             >>plota_hidrografia.gs
#
#  CRIA ESCALA DE CORES 
#   (PARA HABILITAR , RETIRE O * DA FRENTE DA LINHA E COLOQUE * NA QUE 
#    DESEJA DESABILITAR 
#
# ESCALA ANTIGA PARA GRANDES ACUMULOS
#
echo "* escala antiga 0 a 1000  " >cores.gs
echo "*'define_colors.gs' ">>cores.gs
echo "*'set clevs      1  10  20  30  40  50  60  70  80   90  100 125 150 175  200  225  250  275   300 325  350  375  400 425  450 475  500 550 600 650 700 800 900 1000'">>cores.gs
echo "*'set ccols  00 00  31  32  33  34  35  36  37  38   39  42  43   44  45   46   47   48   49   72   73    74   75  76   77   78  79  21  22  23  24  25  26  27  28  29 '">>cores.gs
echo "*'set gxout shaded'">>cores.gs
echo "* escala nova ">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99  230 230 230'">>cores.gs
echo "*'set clevs      1  05 10 15 20 25 30 35 40 45 50 60 70 80 90 100 150 200 '">>cores.gs
echo "*'set ccols  00  99 99 32 33 34 35 36 37 38 39 45 46 47 48 49  26  27  28  29 '">>cores.gs
#
# ESCALA CPTEC
#
echo "* escala CPTEC">>cores.gs 
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99  230 230 230'">>cores.gs
echo "*light green to dark green">>cores.gs
echo "*'set rgb 31 230 255 225'">>cores.gs
echo "*'set rgb 32 200 255 190'">>cores.gs
echo "*'set rgb 33 180 250 170'">>cores.gs
echo "*'set rgb 34 150 245 140'">>cores.gs
echo "*'set rgb 35 120 245 115'">>cores.gs
echo "*'set rgb 36  80 240  80'">>cores.gs
echo "*'set rgb 37  5 138  00'">>cores.gs
echo "*'set rgb 38  38 111  27'">>cores.gs
echo "*'set rgb 39  58 111  58'">>cores.gs
echo "*'set clevs      1  05 10 15 20 25 30 35 40 50 60 70  '">>cores.gs
echo "*'set ccols  00  28 27 25 23 22 21 41 42 35 36 37 38 39 '">>cores.gs
echo "*'set gxout shaded'">>cores.gs
#
# ESCALA ONS OLD
#
echo "*">>cores.gs
echo "* escala ONS semanal old">>cores.gs
echo "*">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set clevs 00 01 10 25 50 75 100 150 200'">>cores.gs
echo "*'set ccols 00 41 42 43 '">>cores.gs
#
# ESCALA ONS ATUAL 
#
echo "* escala baseada no ONS ">>cores.gs
echo "*'define_colors.gs'">>cores.gs
echo "*'set rgb 99 251 94 107'">>cores.gs
echo "*'set clevs    01 05 10 15 20 25 30 40 50 75 100 150 200'">>cores.gs
echo "*'set ccols 41 42 43 47 49 34 37 39 22 23 27  99'  ">>cores.gs
echo "*">>cores.gs
#
# ESCALA  ATUAL 
#
echo "* escala SUGERIDA ">>cores.gs
echo "*">>cores.gs
echo "'define_colors.gs'">>cores.gs
echo "'set rgb 99 251 94 107'">>cores.gs
echo "'set clevs    20 25 30 40 50 75 100 150 200 250 300'">>cores.gs
echo "'set ccols 00 44 45 47 49 34 37 39  22  23  27  29 99'  ">>cores.gs




#--------------------------------------------------

# echo "*"                                                              >figura3.gs
# echo "* esse script é auto gerado. documentação em adquire_eta.sh"   >>figura3.gs
# echo "*By reginaldo.venturadesa@gmail.com "                             >>figura3.gs
# echo "'open chuvamerge.ctl'"            >>figura3.gs
# #echo "*'set mpdset hires'"               >>figura3.gs
# echo "'set gxout shaded'"               >>figura3.gs
# #
# echo "'set lon -80.0000   -30.0000   '"                     >>figura3.gs
# echo "'set lat   -35 06.0000         ' "                                    >>figura3.gs
# echo "'set t 1'"                                    >>figura3.gs
# echo "'q time'"                                    >>figura3.gs
# echo "datah=subwrd(result,3) "                                    >>figura3.gs
# # data 7 dias
# echo "ano1=substr(datah,9,4)"                       >>figura3.gs
# echo "mes1=substr(datah,6,3)"                       >>figura3.gs
# echo "dia1=substr(datah,4,2)"                       >>figura3.gs
# echo " t=1"                                    >>figura3.gs
# echo " while (t<=34)"                                    >>figura3.gs
# echo "'c'"   >>figura3.gs
# echo "'set t 't"                                    >>figura3.gs
# echo "'q time'"                                    >>figura3.gs
# echo "datah=subwrd(result,3) "                                    >>figura3.gs
# # data 7 dias
# echo "ano6=substr(datah,9,4)"                       >>figura3.gs
# echo "mes6=substr(datah,6,3)"                       >>figura3.gs
# echo "dia6=substr(datah,4,2)"                       >>figura3.gs
# echo "'coresdiaria.gs'"                                         >>figura3.gs
# echo "'set gxout shaded'"                                    >>figura3.gs
# echo "'d rain'"                                 >>figura3.gs
# echo "'set string 1 c '"                                 >>figura3.gs
# echo "'draw string 2.5 10.8 PRECIPITACAO DIARIA  OBSERVADA'"  >>figura3.gs
# echo "'draw string 2.0 10.6 RODADA :'dia1'/'mes1'/'ano1"               >>figura3.gs
# echo "'draw string 2.0 10.4 DIA    :'dia6'/'mes6'/'ano6"      >>figura3.gs
# #echo "'draw string 2.5 8.1 RODADA :"$DATA0" - "$hora"Z'"     >>figura3.gs
# #echo "'draw string 2.5 7.9 Periodo:'datah"    >>figura3.gs
# echo "'set rgb 50   255   255    255'" >>figura3.gs
# echo "'basemap.gs O 50 0 M'" >>figura3.gs
# echo "'set mpdset hires'" >>figura3.gs
# echo "'set map 15 1 6'" >>figura3.gs
# echo "'draw map'" >>figura3.gs     
# echo "'cbarn.gs'"                                            >>figura3.gs
# echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp'"     >>figura3.gs
# #echo  "plotausina(bacia,page)"                          >>figura3.gs  
# echo "'plota_hidrografia.gs'"                          >>figura3.gs
# echo "'printim prec_diaria_'ano6 mes6 dia6'.png white'"      >>figura3.gs
# echo "t=t+1"                                    >>figura3.gs
# echo "endwhile"                                    >>figura3.gs
# echo "'quit'"                          								>>figura3.gs

#
#  cria arquivo de plotagem das bacias no mapa do brasil 
# 
echo "'set line 15 1 1'"                                             >plota.gs
echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp '"                 >>plota.gs
echo "'set line 1 1 1'"                                              >>plota.gs
for file in `ls -1 ../../CONTORNOS/SHAPES/contorno*.shp`
do
echo "'draw shp "$file"'"                                            >>plota.gs
done
#
#  plota a hidrografia  
# 
echo "'set line 5 1 1'"                                             >plota_hidrografia.gs
echo "'draw shp ../../CONTORNOS/SHAPES/hidrografia.shp '"                 >>plota_hidrografia.gs
echo "'set line 5 1 1'"                                             >>plota_hidrografia.gs


#
# ESCALA  cores diaria 
#
echo "* escala SUGERIDA ">coresdiaria.gs
echo "*">>cores.gscoresdiaria
echo "'define_colors.gs'">>coresdiaria.gs
echo "'set rgb 99 251 94 107'">>coresdiaria.gs
echo "'set clevs    00 05 10 15 20 25 30 35  50  70  100  150'">>coresdiaria.gs
echo "'set ccols 00 43 45 47 49 34 37 39 25  27  29   57   58 59'  ">>coresdiaria.gs

echo "["`date`"] CRIANDO FIGURAS OBSERVADO" 
cat  ../../UTIL/modulo_grads.mod  >> figura3.gs

grads -pbc "figura3.gs"  >>./LOG.prn 2>&1 
cd ..
cd ..

#-------------------------------------------------------------------------------------------
#
#         GFS
#
#-------------------------------------------------------------------------------------------

echo "["`date`"] INICIO PREVISAO GFS " 

#
# entra no diretorio de trabalho 
#
#
# força a libguagem ser inglês
#
export LANG=en_us_8859_1

#
# verifica sistema
# no cygwin (windows) 
# se bem instalado deve
# funcionar sem as variaveis
#
MACH=`uname -a | cut -c1-5` 
if [ $MACH = "Linux" ];then 
export PATH=$PATH:/usr/local/grads
export GADDIR=/usr/local/grads
export GADLIB=/usr/local/grads
export GASCRP=/usr/local/grads
fi 

mkdir GFS   >./LOG.prn 2>&1 
cd GFS       >>./LOG.prn 2>&1 
dir_data=`date +"%Y%m%d"`
grads_data=`date +"12Z%d%b%Y"`
mkdir $dir_data  >>./LOG.prn 2>&1
cd $dir_data   >>./LOG.prn 2>&1
cp ../../gfs.gs .
echo $dir_data >gfs.config   

echo "dset  "$dir_data".bin" > gfs.ctl
echo "title GFS 0.25 deg starting from 00Z08jul2015, downloaded Jul 08 04:44 UTC" >>gfs.ctl
echo "undef 9.999e+20" >>gfs.ctl
echo "xdef 200 linear -80 0.25" >>gfs.ctl
echo "ydef 200 linear -40 0.25" >>gfs.ctl
echo "zdef 1 levels 1000">>gfs.ctl
echo "tdef 81 linear "$grads_data" 180mn" >>gfs.ctl 
echo "vars 1">>gfs.ctl
echo "chuva  0  t,y,x  ** chuva mm">>gfs.ctl
echo "endvars">>gfs.ctl

echo "["`date`"] PROCESSANDO " 
grads -lbc "gfs.gs"  >>./LOG.prn 2>&1
cd ..
cd ..





echo "["`date`"] FIM DO PROCESSO" 



