#/bin/sh
#---------------------------------------------------------------------------
#
# Calculo da media de chuva por bacia - versao GFS
# Release 2.0 
# By Reginaldo Ventura de Sa (reginaldo.venturadesa@gmail.com)
#  
# Desenvlvido para o LAMMOC-UFF 2014/2015 
#----------------------------------------------------------------------------- 


#
# forca linguagem ser natural ingles
#
export LANG=en_us_8859_1


#
# configuracao em linux
# padrao
# (alterar se GRADS nao esta nos diretorios abaixo
#
MACH=`uname -a | cut -c1-5` 
if [ $MACH = "Linux" ];then 
export PATH=$PATH:/usr/local/grads
export GADDIR=/usr/local/grads
export GADLIB=/usr/local/grads
export GASCRP=/usr/local/grads
fi 
#
#%
#% maquina da UFF 
#%
MACH=`uname -a | cut -c7-11` 
if [ $MACH = "DEAMA" ];then 
export PATH=/home/cataldi/SCRIPT/grads:$PATH
export GADDIR=/home/cataldi/SCRIPT/grads
export GADLIB=/home/cataldi/SCRIPT/grads
export GASCRP=/home/cataldi/SCRIPT/grads
fi 


export FIGURA=1
#----------------------------------------------------------------------------INICIO
# inicio
#  CRIAo diretorio de trabalho 
#
mkdir GFS   >./LOG.prn 2>&1 
cd GFS       >>./LOG.prn 2>&1 
#
# configurador de dados quando se deseja rodar para o passado
#
if [ $1 ="" ];then
dir_data=`date +"%Y%m%d"`
grads_data=`date +"00Z%d%b%Y"`
grads_data2=`date +"12Z%d%b%Y" -d "1  days "`
data_rodada=`date +"%d/%m/%Y"`
else
let b="$1-1"
let c="$34+$1"
dir_data=`date +"%Y%m%d" -d "$1 days ago"`
grads_data=`date +"00Z%d%b%Y" -d "$b  days ago"`
grads_data2=`date +"12Z%d%b%Y" -d "$b  days ago"`
data_rodada=`date +"%d/%m/%Y" -d "$c  days ago"`
fi
#
# cria diretorio de produção
# e copia o script  calculador 
#
mkdir $dir_data  >>./LOG.prn 2>&1
cd $dir_data   >>./LOG.prn 2>&1
cp ../../calcula_gfs_1P0.gs .
echo "["`date`"] ADQUIRINDO DADOS GFS  E GERANDO MEDIA POR BACIA" 
#
#  configurador de data para o grads
#
echo $dir_data >gfs.config   
#
# cria o .ctl 
#
echo "dset  "$dir_data"_1P0.bin" > gfs_1P0.ctl
echo "title GFS 1.0 deg starting from 00Z08jul2015, downloaded Jul 08 04:44 UTC" >>gfs_1P0.ctl
echo "undef 9.999e+20" >>gfs_1P0.ctl
echo "xdef 51 linear -80 1.00" >>gfs_1P0.ctl
echo "ydef 51 linear -40 1.00" >>gfs_1P0.ctl
echo "zdef 1 levels 1000">>gfs_1P0.ctl
echo "tdef 16 linear "$grads_data2" 1dy" >>gfs_1P0.ctl 
echo "vars 1">>gfs_1P0.ctl
echo "chuva  0  t,y,x  ** chuva mm">>gfs_1P0.ctl
echo "endvars">>gfs_1P0.ctl
#
# executa o script calculador da média por bacia
#
echo "["`date`"] GERANDO MEDIAS DIARIAS PARA CADA BACIA "                   
grads -lbc "calcula_gfs_1P0.gs"  >>./LOG.prn 2>&1



#---------------------------------------------------------------------------------[FIGURAS]
#  
#    CRIACAO DE FIGURAS DE DIVERSOS TIPOS
#
#
#
#
#-----------------------------------------------------------------------------------------
#  cria o script para data operativa por bacia cadastrada
#  as bacias estao cadastradas em CADASTRO/CADASTRADAS
# ver documentacao para maiores detalhes
##------------------------------------------------------------------------------------------
echo "*"                                                                 >figura4.gs
echo "* esse script é auto gerado. documentação em adquire_eta.sh"      >>figura4.gs
echo "*By reginaldo.venturadesa@gmail.com "                             >>figura4.gs
echo "'open gfs_1P0.ctl'"            >>figura4.gs
echo "'set gxout shaded'"               >>figura4.gs
#
# pega parametros de execucao do grads
# se é retrato ou paisagem
#
echo "'q gxinfo'"   >>figura4.gs
echo "var=sublin(result,2)"  >>figura4.gs
echo "page=subwrd(var,4)" >>figura4.gs
echo "*say page" >>figura4.gs
#
# se for retrato cria vpage
#
echo "t0=10"                            >>figura4.gs  
echo "tfinal=16"                        >>figura4.gs  
echo "'set t 1 last'"                   >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var3=subwrd(result,5)"            >>figura4.gs
echo "tt=1"                             >>figura4.gs
echo "while (tt<=16)"                   >>figura4.gs
echo "'set t ' tt"                      >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var=subwrd(result,6)"             >>figura4.gs
echo "if (var = "Fri" )"                >>figura4.gs
echo "t0=1"                            >>figura4.gs
echo "tsex=tt"                            >>figura4.gs
echo "tt=22"                            >>figura4.gs
echo "endif"                            >>figura4.gs
echo "tt=tt+1"                          >>figura4.gs
echo "endwhile"                         >>figura4.gs
echo "tt=tsex+1"                             >>figura4.gs
echo "while (tt<=16)"                   >>figura4.gs
echo "'set t ' tt"                      >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var=subwrd(result,6)"             >>figura4.gs
echo "if (var = "Fri" )"                >>figura4.gs
echo "t02=1"                            >>figura4.gs
echo "tsex2=tt"                            >>figura4.gs
echo "tt=22"                            >>figura4.gs
echo "endif"                            >>figura4.gs
echo "tt=tt+1"                          >>figura4.gs
echo "endwhile"                         >>figura4.gs


echo "*say t0"                           >>figura4.gs
echo "tsab=tsex+1"                       >>figura4.gs
echo "tsab2=tsex2+1"                       >>figura4.gs
echo "tfinal=tsab2+6"                    >>figura4.gs




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
echo "'set t 0'"                     >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var0=subwrd(result,3)"            >>figura4.gs
#
#  data da semana operativa 1
#
echo "'set t 1 'tsex"                     >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var1=subwrd(result,3)"            >>figura4.gs
echo "var2=subwrd(result,5)"            >>figura4.gs
#
#  data da semana operativa 2
#
echo "'set t 'tsab' 'tsex2"                     >>figura4.gs   
echo "'q time'"                           >>figura4.gs 
echo "var3=subwrd(result,3)"            >>figura4.gs
echo "var4=subwrd(result,5)"            >>figura4.gs


#
#  data da semana operativa 3
#
echo "'set t 'tsab2' 'tfinal"                     >>figura4.gs
echo "'q time'"                         >>figura4.gs
echo "var6=subwrd(result,3)"            >>figura4.gs
echo "var7=subwrd(result,5)"            >>figura4.gs





#
# semana 7 dias
#
echo "'set t 1 7'"                     >>figura4.gs   
echo "'q time'"                           >>figura4.gs 
echo "var5=subwrd(result,5)"            >>figura4.gs

# data  rodada
echo "ano0=substr(var0,9,4)"                       >>figura4.gs
echo "mes0=substr(var0,6,3)"                       >>figura4.gs
echo "dia0=substr(var0,4,2)"                       >>figura4.gs

# data inicial previsao 
echo "ano1=substr(var1,9,4)"                       >>figura4.gs
echo "mes1=substr(var1,6,3)"                       >>figura4.gs
echo "dia1=substr(var1,4,2)"                       >>figura4.gs
# data proxima sexta-feira
echo "ano2=substr(var2,9,4)"                       >>figura4.gs
echo "mes2=substr(var2,6,3)"                       >>figura4.gs
echo "dia2=substr(var2,4,2)"                       >>figura4.gs
# data sabado
echo "ano3=substr(var3,9,4)"                       >>figura4.gs
echo "mes3=substr(var3,6,3)"                       >>figura4.gs
echo "dia3=substr(var3,4,2)"                       >>figura4.gs
# data final
echo "ano4=substr(var4,9,4)"                       >>figura4.gs
echo "mes4=substr(var4,6,3)"                       >>figura4.gs
echo "dia4=substr(var4,4,2)"                       >>figura4.gs
# data 7 dias
echo "ano5=substr(var5,9,4)"                       >>figura4.gs
echo "mes5=substr(var5,6,3)"                       >>figura4.gs
echo "dia5=substr(var5,4,2)"                       >>figura4.gs
# sema operativa 3
echo "ano6=substr(var6,9,4)"                       >>figura4.gs
echo "mes6=substr(var6,6,3)"                       >>figura4.gs
echo "dia6=substr(var6,4,2)"                       >>figura4.gs
echo "ano7=substr(var7,9,4)"                       >>figura4.gs
echo "mes7=substr(var7,6,3)"                       >>figura4.gs
echo "dia7=substr(var7,4,2)"                       >>figura4.gs


#
# a rotina varre o arquivo contendo os contornos das bacias
# para cada contorno encontrado ele gera as figuras
# 
echo "status2=0"                       >>figura4.gs
echo "while(!status2)" >>figura4.gs
echo 'fd=read("../../UTIL/limites_das_bacias.dat")' >>figura4.gs
echo "status2=sublin(fd,1) "    >>figura4.gs
echo "if (status2 = 0) "        >>figura4.gs
echo "linha=sublin(fd,2)"       >>figura4.gs
echo "say linha"       >>figura4.gs
echo "bacia=subwrd(linha,4)"     >>figura4.gs
echo "shape=subwrd(linha,5)"     >>figura4.gs
echo "x0=subwrd(linha,6)"       >>figura4.gs
echo "x1=subwrd(linha,7)"       >>figura4.gs
echo "y0=subwrd(linha,8)"       >>figura4.gs
echo "y1=subwrd(linha,9)"       >>figura4.gs
echo "tipo=subwrd(linha,10)"     >>figura4.gs
echo "say bacia' 'shape' 'x0' 'x1' 'y0' 'y1' 'tipo"    >>figura4.gs
echo "plota=subwrd(linha,11)"    >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de retrato 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#   FIGURAS RETRATO SEMANA OPERATIVA 1
# 
echo "if (tipo = "RETRATO" & page ="8.5" & plota="SIM") "   >>figura4.gs
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                                  >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'set t 1'"                        >>figura4.gs
echo "'cores.gs'"                    >>figura4.gs
echo "'d sum(chuva,t=1,t='tsex')'"         >>figura4.gs
echo "'draw string 1.5 10.8 PRECIPITACAO ACUMULADA GFS SEMANA OPERATIVA 1'"  >>figura4.gs
echo "'draw string 1.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura4.gs
echo "'draw string 1.5 10.4 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.gs
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs
echo "if (bacia="brasil")"                    >>figura4.gs
echo "'plota.gs'"                             >>figura4.gs
echo "else"                    >>figura4.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura4.gs
echo "endif"                    >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs  
echo "plotausina(bacia,page)" >>figura4.gs    
echo "'cbarn.gs 1.0 0 '"                      >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_1_"$data".png white'"                       >>figura4.gs
#
# FIGURAS RETARTO SEMANA OPERATIVA 2
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                                  >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                                >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t='tsab',t='tsex2')'"                                       >>figura4.gs
echo "'draw string 1.5 10.8 PRECIPITACAO ACUMULADA GFS SEMANA OPERATIVA 2 '">>figura4.gs
echo "'draw string 1.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura4.gs
echo "'draw string 1.5 10.4 PERIODO:'dia3'/'mes3'/'ano3' a 'dia4'/'mes4'/'ano4  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'"       >>figura4.gs
echo "'basemap.gs O 50 0 M'"                 >>figura4.gs
echo "'set mpdset hires'"                    >>figura4.gs
echo "'set map 15 1 6'"                      >>figura4.gs
echo "'draw map'"                            >>figura4.gs
echo "if (bacia="brasil")"                    >>figura4.gs
echo "'plota.gs'"                             >>figura4.gs
echo "else"                    >>figura4.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura4.gs
echo "endif"                    >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs  
echo "plotausina(bacia,page)" >>figura4.gs    
echo "'cbarn.gs 1.0 0 '"  >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_2_"$data".png white'"                       >>figura4.gs
#
# FIGURAS RETARTO SEMANA OPERATIVA 3
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                                  >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                                >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t='tsab2',t='tfinal')'"                                       >>figura4.gs
echo "'draw string 1.5 10.8 PRECIPITACAO ACUMULADA GFS SEMANA OPERATIVA 3 '">>figura4.gs
echo "'draw string 1.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura4.gs
echo "'draw string 1.5 10.4 PERIODO:'dia6'/'mes6'/'ano6' a 'dia7'/'mes7'/'ano7  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'"       >>figura4.gs
echo "'basemap.gs O 50 0 M'"                 >>figura4.gs
echo "'set mpdset hires'"                    >>figura4.gs
echo "'set map 15 1 6'"                      >>figura4.gs
echo "'draw map'"                            >>figura4.gs
echo "if (bacia="brasil")"                    >>figura4.gs
echo "'plota.gs'"                             >>figura4.gs
echo "else"                    >>figura4.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura4.gs
echo "endif"                    >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs  
echo "plotausina(bacia,page)" >>figura4.gs    
echo "'cbarn.gs 1.0 0 '" >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_3_"$data".png white'"                       >>figura4.gs

#
# FIGURA RETRATO SEMANA 7 DIAS CORRIDOS 
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                                  >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                         >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set gxout shaded'"                                    >>figura4.gs
echo "'d sum(chuva,t=1,t=7)'"                                 >>figura4.gs
echo "'draw string 1.5 10.8 PRECIPITACAO ACUMULADA GFS 7 DIAS '"  >>figura4.gs
echo "'draw string 1.5 10.6 RODADA :'dia0'/'mes0'/'ano0 "               >>figura4.gs
echo "'draw string 1.5 10.4 PERIODO:'dia1'/'mes1'/'ano1' a 'dia5'/'mes5'/'ano5  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.gs
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs
echo "if (bacia="brasil")"                    >>figura4.gs
echo "'plota.gs'"                             >>figura4.gs
echo "else"                    >>figura4.gs
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura4.gs
echo "endif"                    >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs
echo "plotausina(bacia,page)" >>figura4.gs  
echo "'cbarn.gs 1.0 0 '"  >>figura4.gs
echo "'printim 'bacia'_prec07dias_"$data"_"$hora"Z.png white'"       >>figura4.gs
echo "*say t0"                           >>figura4.gs
#
#
#

#
#
#



echo "endif"                            >>figura4.gs 
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de paisagem 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#
#  FIGURA PAISAGEM  SEMANA OPERATIVA 1
#
echo "if (tipo = "PAISAGEM" & page ="11" & plota="SIM" ) "   >>figura4.gs
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 10.5 1.5 7.6'"                     >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'set t 1'"                        >>figura4.gs
echo "'cores.gs'"                    >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t=1,t='tsex')'"         >>figura4.gs
echo "'draw string 1.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 1'"  >>figura4.gs
#echo "'draw string 2.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura4.gs
echo "'draw string 1.5 8.1 RODADA :'dia0'/'mes0'/'ano0 "               >>figura4.gs
echo "'draw string 1.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia2'/'mes2'/'ano2  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.gs
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs   
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura4.gs
echo "say shape" >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs
echo "plotausina(bacia,page)" >>figura4.gs  
echo "'cbarn.gs 1.0 0 '"  >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_1_"$data".png white'"                       >>figura4.gs
#
# FIGURA PAISAGEM SEMANA OPERATIVA 2
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 10.5 1.5 7.6'"                     >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                                >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t='tsab',t='tsex2')'"                                       >>figura4.gs
echo "'draw string 1.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 2 '">>figura4.gs
echo "'draw string 1.5 8.1 RODADA :'dia0'/'mes0'/'ano0"               >>figura4.gs
echo "'draw string 1.5 7.9 PERIODO:'dia3'/'mes3'/'ano3' a 'dia4'/'mes4'/'ano4  "      >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.gs
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs     
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                        >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs
echo "plotausina(bacia,page)" >>figura4.gs  
echo "'cbarn.gs 1.0 0 '"  >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_2_"$data".png white'"                       >>figura4.gs
#
# FIGURA PAISAGEM SEMANA OPERATIVA 3
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 10.5 1.5 7.6'"                     >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                                >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t='tsab',t='tfinal')'"                                       >>figura4.gs
echo "'draw string 1.5 8.3 PRECIPITACAO ACUMULADA SEMANA OPERATIVA 3 '">>figura4.gs
echo "'draw string 1.5 8.1 RODADA :'dia0'/'mes0'/'ano0"               >>figura4.gs
echo "'draw string 1.5 7.9 PERIODO:'dia6'/'mes6'/'ano6' a 'dia7'/'mes7'/'ano7  "      >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.g
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs     
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                        >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs
echo "plotausina(bacia,page)" >>figura4.gs  
echo "'cbarn.gs 1.0 0 '"  >>figura4.gs
echo "'printim 'bacia'_semanaoperativa_3_"$data".png white'"                       >>figura4.gs


#
# FIGURA PAISAGEM SEMANA 7 dias
#
echo "'reset'"                        >>figura4.gs
echo "'c'"                        >>figura4.gs
echo "'set parea 0.5 10.5 1.5 7.6'"                     >>figura4.gs
echo "'set gxout shaded'"                        >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'set lon 'x1' 'x0 "       >>figura4.gs
echo "'set lat 'y1' 'y0 "       >>figura4.gs
echo "'cores.gs'"                                         >>figura4.gs
echo "'set gxout shaded'"                                    >>figura4.gs
echo "'set csmooth on'"                     >>figura4.gs
echo "'d sum(chuva,t=1,t=14)'"                                 >>figura4.gs
echo "'draw string 1.5 8.3 PRECIPITACAO ACUMULADA 7 DIAS '"  >>figura4.gs
echo "'draw string 1.5 8.1 RODADA :'dia0'/'mes0'/'ano0"               >>figura4.gs
echo "'draw string 1.5 7.9 PERIODO:'dia1'/'mes1'/'ano1' a 'dia5'/'mes5'/'ano5  "                     >>figura4.gs
echo "'set rgb 50   255   255    255'" >>figura4.gs
echo "'basemap.gs O 50 0 M'" >>figura4.gs
echo "'set mpdset hires'" >>figura4.gs
echo "'set map 15 1 6'" >>figura4.gs
echo "'draw map'" >>figura4.gs     
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"     >>figura4.gs
echo "'plota_hidrografia.gs'"     >>figura4.gs
echo "plotausina(bacia,page)" >>figura4.gs 
echo "'cbarn.gs 1.0 0 '"                                           >>figura4.gs
echo "'printim 'bacia'_prec07dias_"$data"_"$hora"Z.png white'"       >>figura4.gs
echo "endif"                            >>figura4.gs 
#
# PARTE FINAL DO SCRIPT . NÃO MEXER 
#
echo "endif"                            							>>figura4.gs 
echo "endwhile"                          							>>figura4.gs
echo "'quit'"                          								>>figura4.gs
#
#  adiciona o scripts o script que plota bacias
#
cat  ../../UTIL/modulo_grads.mod  >> figura4.gs
#




















#----------------------------------------------------------------------------------



echo "["`date`"] GERANDO FIGURAS POR BACIA" 
#------------------------------------------------------------------------------
#              AUTO SCRIPT PARA CRIAÇÃO DE FIGURAS
#-----------------------------------------------------------------------------------------
#  cria o script para data operativa por bacia cadastrada
#  as bacias estao cadastradas em CADASTRO/CADASTRADAS
# ver documentacao para maiores detalhes
#
echo "*"                                                                 >figura3.gs
echo "* esse script é auto gerado. documentação em adquire_eta.sh"      >>figura3.gs
echo "*By reginaldo.venturadesa@gmail.com "                             >>figura3.gs
echo "'open gfs_1P0.ctl'"            >>figura3.gs
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
# a rotina varre o arquivo contendo os contornos das bacias
# para cada contorno encontrado ele gera as figuras
# 
echo "status2=0"                       >>figura3.gs
echo "while(!status2)" >>figura3.gs
echo 'fd=read("../../UTIL/limites_das_bacias.dat")' >>figura3.gs
echo "status2=sublin(fd,1) "    >>figura3.gs
echo "if (status2 = 0) "        >>figura3.gs
echo "linha=sublin(fd,2)"       >>figura3.gs
echo "bacia=subwrd(linha,4)"     >>figura3.gs
echo "shape=subwrd(linha,5)"     >>figura3.gs
echo "x0=subwrd(linha,6)"       >>figura3.gs
echo "x1=subwrd(linha,7)"       >>figura3.gs
echo "y0=subwrd(linha,8)"       >>figura3.gs
echo "y1=subwrd(linha,9)"       >>figura3.gs
echo "tipo=subwrd(linha,10)"     >>figura3.gs
echo "plota=subwrd(linha,11)"    >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de retrato 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#   FIGURAS RETRATO 
# 
echo "if (tipo = "RETRATO" & page ="8.5" & plota="SIM") "   >>figura3.gs
echo "'reset'"                        >>figura3.gs
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                        >>figura3.gs
echo "'set gxout shaded'"                        >>figura3.gs
echo "'set csmooth on'"                     >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs
echo "t=1 "    >>figura3.gs 
echo "while (t<=15) "    >>figura3.gs 
echo "'set t 't"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var1=subwrd(result,3)"            >>figura3.gs
echo "ano1=substr(var1,9,4)"                       >>figura3.gs
echo "mes1=substr(var1,6,3)"                       >>figura3.gs
echo "dia1=substr(var1,4,2)"                       >>figura3.gs
echo "'reset'"                        >>figura3.gs
echo "'set t 't"                     >>figura3.gs   
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 8.0 1.5 10.2'"                       >>figura3.gs
echo "'set gxout shaded'"                        >>figura3.gs
echo "'set csmooth on'"                     >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs                             >>figura3.gs
echo "'coresdiaria.gs'"                    >>figura3.gs
echo "'set csmooth on'"                     >>figura3.gs
echo "'d chuva'"            >>figura3.gs
echo "'draw string 1.5 10.8     PRECIPITACAO ACUMULADA DIARIA GFS '"  >>figura3.gs
echo "'draw string 1.5 10.6 RODADA :"$data_rodada"'"               >>figura3.gs
echo "'draw string 1.5 10.4 DIA    :'dia1'/'mes1'/'ano1  "                     >>figura3.gs
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
echo "'cbarn.gs 1.0 0 '"                         >>figura3.gs
echo "'printim 'bacia'_diario_'var1'.png white'"                       >>figura3.gs
echo "t=t+1"                    >>figura3.gs
echo "c"                    >>figura3.gs
echo "endwhile"                    >>figura3.gs
echo "endif" 					>>figura3.gs
#------------------------------------------------------------------------------------
# caso a bacia se ja em forma de paisagem 
# definido no arquivo limites_das_bacias em CONTORNOS/CADASTRADAS
#
#
#  FIGURA PAISAGEM 
#
echo "if (tipo = "PAISAGEM" & page ="11" & plota="SIM" ) "   >>figura3.gs
echo "t=1 "    >>figura3.gs 

echo "while (t<=15) "    >>figura3.gs 
echo "'set t 't"                     >>figura3.gs   
echo "'q time'"                           >>figura3.gs 
echo "var1=subwrd(result,3)"            >>figura3.gs
echo "ano1=substr(var1,9,4)"                       >>figura3.gs
echo "mes1=substr(var1,6,3)"                       >>figura3.gs
echo "dia1=substr(var1,4,2)"                       >>figura3.gs
echo "'reset'"                        >>figura3.gs
echo "'set t 't"                     >>figura3.gs   
echo "'c'"                        >>figura3.gs
echo "'set parea 0.5 10.5 1.5 7.6'"                     >>figura3.gs
echo "'set gxout shaded'"                        >>figura3.gs
echo "'set csmooth on'"                     >>figura3.gs
echo "'set lon 'x1' 'x0 "       >>figura3.gs
echo "'set lat 'y1' 'y0 "       >>figura3.gs                             >>figura3.gs
echo "'coresdiaria.gs'"                    >>figura3.gs
echo "'set csmooth on'"                     >>figura3.gs
echo "'d chuva'"         >>figura3.gs
echo "'draw string 1.5 8.3  PRECIPITACAO ACUMULADA DIARIA GFS'"  >>figura3.gs
echo "'draw string 1.5 8.1 RODADA :"$data_rodada"'"               >>figura3.gs
echo "'draw string 1.5 7.9 DIA    :'dia1'/'mes1'/'ano1  "                     >>figura3.gs
echo "'set rgb 50   255   255    255'" >>figura3.gs
echo "'basemap.gs O 50 0 M'" >>figura3.gs
echo "'set mpdset hires'" >>figura3.gs
echo "'set map 15 1 6'" >>figura3.gs
echo "'draw map'" >>figura3.gs   
echo "'draw shp ../../CONTORNOS/SHAPES/'shape"                                                  >>figura3.gs
echo "say shape" >>figura3.gs
echo "'plota_hidrografia.gs'"     >>figura3.gs
echo "plotausina(bacia,page)" >>figura3.gs  
echo "'cbarn.gs 1.0 0 '"    >>figura3.gs  
echo "'printim 'bacia'_diaria_'var1'.png white'"                       >>figura3.gs
echo "'c'"                                                             >>figura3.gs
echo "t=t+1"                    >>figura3.gs
echo "'c'"                    >>figura3.gs
echo "endwhile"                    >>figura3.gs
#
# PARTE FINAL DO SCRIPT . NÃO MEXER 
#
echo "endif"                            							>>figura3.gs 
echo "endif"                            							>>figura3.gs 
echo "endwhile"                          							>>figura3.gs
echo "'quit'"                          								>>figura3.gs

#
#  cria parte comum como tabelas de cores e escalas, hidrografoa etc...
#
../../common_stuff.sh  

echo "["`date`"] CRIANDO FIGURAS GFS DIARIO"                   
#------------------------------------------------------------------------------
#  FIM DO AUTOSCRIPT DE CRIAÇÃO DE FIGURAS
#------------------------------------------------------------------------------
#
#
#  adiciona o scripts o script que plota bacias
#
cat  ../../UTIL/modulo_grads.mod  >> figura3.gs
cat  ../../UTIL/modulo_grads.mod  >> figura4.gs
../../common_stuff.sh
cp ../../opoly_mres.asc .

if [ FIGURA=1 ];then 
#
#  EXECUTA O SCRIPT GERADO PELO AUTO SCRIPT PARA GERAÇÃO DE FIGURAS
#
grads -lbc "figura3.gs"  >>./LOG.prn 2>&1
grads -pbc "figura3.gs"  >>./LOG.prn 2>&1
mkdir diaria >>./LOG.prn 2>&1
mv *.png  diaria
echo "["`date`"] CRIANDO FIGURAS GFS SEMANAS OPEARTIVAS"   
grads -lbc "figura4.gs"  >>./LOG.prn 2>&1
grads -pbc "figura4.gs"  >>./LOG.prn 2>&1
mkdir imagens_semanaoperativa_1  >>./LOG.prn 2>&1
mkdir imagens_semanaoperativa_2 >>./LOG.prn 2>&1
mkdir imagens_semanaoperativa_3 >>./LOG.prn 2>&1
mkdir imagens_7dias   >>./LOG.prn 2>&1
mkdir diaria >>./LOG.prn 2>&1
mv *semanaoperativa_1*  imagens_semanaoperativa_1  >>./LOG.prn 2>&1
mv *semanaoperativa_2*  imagens_semanaoperativa_2  >>./LOG.prn 2>&1
mv *semanaoperativa_3*  imagens_semanaoperativa_3  >>./LOG.prn 2>&1

mv *prec07dias* imagens_7dias                      >>./LOG.prn 2>&1
#
# COPIA AS FIGURAS GERADAS PARA O DIRETORIA DIARIO
#
fi
echo "["`date`"] FIM DO PROCESSO GFS" 

cd ..
cd ..

