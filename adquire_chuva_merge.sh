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
if [ ! -f ./CHUVA_MERGE ];then 
mkdir ./CHUVA_MERGE            >./LOG.prn 2>&1 
fi  
# entra no direotiro SAIDA e depois diretorio da data do dia
# onde tudo aocntece. 
cd CHUVA_MERGE
mkdir $data    >>./LOG.prn 2>&1 

if [ ! -f ./DADOS ];then 
mkdir ./DADOS            >./LOG.prn 2>&1 
fi  

cd DADOS



#
# baixa as 63 ultimas chuvas. se já baixou passa adiante. 
#

for n in `seq --format=%02g 1 33`
do
download_data=`date -d "$n days ago" +"%Y%m%d"`
ano=`date -d "$n days ago" +"%Y"`
wget -nc  ftp://ftp1.cptec.inpe.br/modelos/io/produtos/MERGE/$ano/prec_$download_data".bin" 
###wget -nc ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/$ano/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.$download_data".RT"  >>./LOG.prn 2>&1  
done

cd ..


grads_data=`date -d "33 days ago" +"12Z%d%b%Y"`
dir_data=`date +"%Y%m%d"`
mkdir $dir_data
cd $dir_data
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



grads -lbc "calcula_chuva_merge.gs"  >>./LOG.prn 2>&1 

cd ..
cd ..






