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
mkdir $dir_data  >>./LOG.prn 2>&1
cd $dir_data   >>./LOG.prn 2>&1
cp ../../gfs.gs .
cp ../../gfsens.gs .

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
#grads -lbc "gfsens.gs"  >>./LOG.prn 2>&1

cd ..
cd ..

