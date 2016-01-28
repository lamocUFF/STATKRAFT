#/bin/sh


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
export GADDIR=/opt/grads
export GADLIB=/opt/grads
export GASCRP=/opt/grads
fi 


MODDEBUG=1 
#
# Pega data do dia (relogio do micro)
# DATA0 = data de hoje
# DATA1 = data de amanha (para os produtos)
# DATA2 = data de 7 dias a frente 
# 
data=`date +"%Y%m%d"`
DATA0=`date +"%d/%m/%Y"`
DATA1=`date +"%d/%m/%Y" -d "7 days"`
DATA2=`date +"%d/%m/%Y" -d "1 days"`


#
# entra no diretorio de trabalho 
#
if [ ! -f ./CHUVA_DE_GRADE ];then 
mkdir ./CHUVA_DE_GRADE            >./LOG.prn 2>&1 
fi  
# entra no direotiro SAIDA e depois diretorio da data do dia
# onde tudo aocntece. 
cd CHUVA_DE_GRADE
mkdir $data$hora    >>./LOG.prn 2>&1 

if [ ! -f ./DADOS ];then 
mkdir ./DADOS            >./LOG.prn 2>&1 
fi  

cd DADOS



#
# baixa as 63 ultimas chuvas. se já baixou passa adiante. 
#

for n in `seq --format=%02g 1 63`
do
download_data=`date -d "$n days ago" +"%Y%m%d"`
ano=`date -d "$n days ago" +"%Y"`
 
wget -nc ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/$ano/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.$download_data".RT"  >>./LOG.prn 2>&1  
done

cd ..


grads_data=`date -d "33 days ago" +"00Z%d%b%Y"`
dir_data=`date +"%Y%m%d"`
mkdir $dir_data
cd $dir_data
cp ../../calcula_chuva_meiograuv2.gs .


#
# cria o arquivo ctl 
#
echo "dset ^../DADOS/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%y4%m2%d2.RT" >chuvameiograu.ctl
echo "options  little_endian template"                        >>chuvameiograu.ctl
echo "title global daily analysis "                           >>chuvameiograu.ctl
echo "undef -999.0 "                                          >>chuvameiograu.ctl 
echo "xdef 720 linear    0.25 0.50"                           >>chuvameiograu.ctl
echo "ydef 360  linear -89.75 0.50 "                          >>chuvameiograu.ctl
echo "zdef 1    linear 1 1 "                                  >>chuvameiograu.ctl
echo "tdef 33 linear $grads_data 1dy "                         >>chuvameiograu.ctl
echo "vars 2"                                                 >>chuvameiograu.ctl
echo "rain     1  00 the grid analysis (0.1mm/day)"           >>chuvameiograu.ctl
echo "gnum     1  00 the number of stn"                       >>chuvameiograu.ctl
echo "ENDVARS"                                                >>chuvameiograu.ctl



grads -lbc "calcula_chuva_meiograuv2.gs"  >>./LOG.prn 2>&1 

cd ..
cd ..






