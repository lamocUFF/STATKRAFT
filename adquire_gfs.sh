#/bin/sh
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
grads_data2=`date +"00Z%d%b%Y"`

mkdir $dir_data  >>./LOG.prn 2>&1
cd $dir_data   >>./LOG.prn 2>&1
cp ../../gfs.gs .
cp ../../gfsens.gs .
cp ../../GFS_1P0.gs .

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

echo "dset  "$dir_data"_1P0.bin" > gfs_1P0.ctl
echo "title GFS 1.0 deg starting from 00Z08jul2015, downloaded Jul 08 04:44 UTC" >>gfs_1P0.ctl
echo "undef 9.999e+20" >>gfs_1P0.ctl
echo "xdef 51 linear -80 1.00" >>gfs_1P0.ctl
echo "ydef 51 linear -40 1.00" >>gfs_1P0.ctl
echo "zdef 1 levels 1000">>gfs_1P0.ctl
echo "tdef 33 linear "$grads_data2" 12hr" >>gfs_1P0.ctl 
echo "vars 1">>gfs_1P0.ctl
echo "chuva  0  t,y,x  ** chuva mm">>gfs_1P0.ctl
echo "endvars">>gfs_1P0.ctl


echo "dset  "$dir_data".ens.bin" > gfsens.ctl
echo "title GFS 0.25 deg starting from 00Z08jul2015, downloaded Jul 08 04:44 UTC" >>gfsens.ctl
echo "undef 9.999e+20" >>gfsens.ctl
echo "xdef 50 linear -80 0.25" >>gfsens.ctl
echo "ydef 50 linear -40 0.25" >>gfsens.ctl
echo "zdef 1 levels 1000">>gfsens.ctl
echo "tdef 1365 linear "$grads_data" 360mn" >>gfsens.ctl 
echo "vars 1">>gfsens.ctl
echo "chuva  0  t,y,x  ** chuva mm">>gfsens.ctl
echo "endvars">>gfsens.ctl


grads -lbc "gfs.gs"  >>./LOG.prn 2>&1
grads -lbc "GFS_1P0.gs"  >>./LOG.prn 2>&1

#grads -lbc "gfsens.gs"  >>./LOG.prn 2>&1



#-----------------------------------------------------------------------------------------
#  cria o script para data operativa por bacia cadastrada
#  as bacias estao cadastradas em CADASTRO/CADASTRADAS
# ver documentacao para maiores detalhes
#
echo "*"                                                              >figuras_gfs.gs
echo "* esse script é auto gerado. documentação em adquire_eta.sh"   >>figuras_gfs.gs
echo "*By reginaldo.venturadesa@gmail.com "                             >>figuras_gfs.gs
echo "'open gfs_1P0.ctl'"            >>figuras_gfs.gs
#echo "*'set mpdset hires'"               >>figuras_gfs.gs
echo "'set gxout shaded'"               >>figuras_gfs.gs
#
# pega parametros de execucao do grads
# se é retrato ou paisagem
#
echo "'q gxinfo'"   >>figuras_gfs.gs
echo "var=sublin(result,2)"  >>figuras_gfs.gs
echo "page=subwrd(var,4)" >>figuras_gfs.gs
echo "*say page" >>figuras_gfs.gs
#
# se for retrato cria vpage
#
# echo "if (page ="8.5") " >>figuras_gfs.gs
# echo "'set parea 0.5 8.5 1.5 10.2'" >>figuras_gfs.gs
# echo "endif"                                  >>figuras_gfs.gs
#
#  data RODADA
#
echo "'set t  0'"                     >>figuras_gfs.gs
echo "'q time'"                         >>figuras_gfs.gs
echo "var0=subwrd(result,3)"            >>figuras_gfs.gs




#
# ESCALA  ATUAL 
#
echo "* escala SUGERIDA ">coresdiaria.gs
echo "*">>cores.gscoresdiaria
echo "'define_colors.gs'">>coresdiaria.gs
echo "'set rgb 99 251 94 107'">>coresdiaria.gs
echo "'set clevs    05 10 15 20 25 30 35  50  70  100  150'">>coresdiaria.gs
echo "'set ccols 00 44 45 47 49 34 37 39  22  23  27    29   99'  ">>coresdiaria.gs

echo "'set lon -80.0000   -30.0000   '"                     >>figuras_gfs.gs
echo "'set lat   -35 06.0000         ' "                                    >>figuras_gfs.gs
echo "'set t 1 last'"                     >>figuras_gfs.gs
echo "'q time'"                         >>figuras_gfs.gs
echo "var1=subwrd(result,3)"            >>figuras_gfs.gs
echo "ano1=substr(var1,9,4)"                       >>figuras_gfs.gs
echo "mes1=substr(var1,6,3)"                       >>figuras_gfs.gs
echo "dia1=substr(var1,4,2)"                       >>figuras_gfs.gs

echo " t=1"                                    >>figuras_gfs.gs
echo " while (t<=33)"                                    >>figuras_gfs.gs
echo "'c'"   >>figuras_gfs.gs
# data inicial previsao 




echo "'set t 't"                                    >>figuras_gfs.gs
echo "'q time'"                                    >>figuras_gfs.gs
echo "datah=subwrd(result,3) "                                    >>figuras_gfs.gs
# data 7 dias
echo "ano6=substr(datah,9,4)"                       >>figuras_gfs.gs
echo "mes6=substr(datah,6,3)"                       >>figuras_gfs.gs
echo "dia6=substr(datah,4,2)"                       >>figuras_gfs.gs




echo "'coresdiaria.gs'"                                         >>figuras_gfs.gs
echo "'set gxout shaded'"                                    >>figuras_gfs.gs
echo "'d sum(chuva,t='t',t='t+1')'"                                 >>figuras_gfs.gs
echo "'draw string 2.5 8.3 PRECIPITACAO DIARIA GFS '"  >>figuras_gfs.gs
echo "'draw string 2.5 8.1 RODADA :'dia1'/'mes1'/'ano1"               >>figuras_gfs.gs
echo "'draw string 2.5 7.9 DIA    :'dia6'/'mes6'/'ano6"      >>figuras_gfs.gs
#echo "'draw string 2.5 8.1 RODADA :"$DATA0" - "$hora"Z'"     >>figuras_gfs.gs
#echo "'draw string 2.5 7.9 Periodo:'datah"    >>figuras_gfs.gs
echo "'set rgb 50   255   255    255'" >>figuras_gfs.gs
echo "'basemap.gs O 50 0 M'" >>figuras_gfs.gs
echo "'set mpdset hires'" >>figuras_gfs.gs
echo "'set map 15 1 6'" >>figuras_gfs.gs
echo "'draw map'" >>figuras_gfs.gs     
echo "'cbarn.gs'"                                            >>figuras_gfs.gs
echo "'draw shp ../../CONTORNOS/SHAPES/BRASIL.shp'"     >>figuras_gfs.gs
echo "'plota.gs'"                             >>figuras_gfs.gs
#echo  "plotausina(bacia,page)"                          >>figuras_gfs.gs  
echo "'plota_hidrografia.gs'"                          >>figuras_gfs.gs
echo "'printim prec_diaria_'datah'.png white'"      >>figuras_gfs.gs
echo "t=t+2"                                    >>figuras_gfs.gs
echo "endwhile"                                    >>figuras_gfs.gs
echo "'quit'" >>figuras_gfs.gs 


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



grads -lbc "figuras_gfs.gs"  >>./LOG.prn 2>&1
cd ..
cd ..

