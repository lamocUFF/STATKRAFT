
*  VERSAO 2.0 
*
*
*  bY regis  reginaldo.venturadesa@gmail.com 
*  uso:
*      calcula.gs (exige grads)   [00/12]   
*------------------------------------------------------------------------- 
*
*
id=read('gfs.config')
status=sublin(id,1)
config=sublin(id,2)
say config
data=subwrd(config,1)
say data
fi=baixagfs(data)
'close 1'
pi=extrai(data)

'quit'


function  extrai(data)

'open gfs.ctl'


*
*  leio arquivo bacia e processo 
* para cada item dentro desse arquivo
*

while ( 0=0 )       
*
* abre o arquivo bacias
*
id=read("../../UTIL/bacias")
*
* se status=0 tudo ok. se não ...
*
status=sublin(id,1)   

if (status>0) 
return
endif



var=sublin(id,2)
bacia=subwrd(var,1)
label=subwrd(var,2)
xxx=write("todomundo.prn",label' 'bacia,append)
*say "calculando para  bacia:"bacia
status2=status

n=1
while (n<=21)
precip=0
conta=0
t=65*(n-1)+1


while (t<=(65*(n-1)+65))
'set t ' t
'q time'
dataprev=subwrd(result,3)
*
* tendo o nome da bacia lido no arquivo "bacia"
* vou pegar os pontos d egrade que estao
* dentro da bacia
*
fd=close("../../CONTORNOS/CADASTRADAS/"bacia)
status2=0
*
* execuo esse esse bloco ate  a leitura
* de todos os pontos de grade que estao na bacia
*
while (!status2)
fd=read("../../CONTORNOS/CADASTRADAS/"bacia)
status2=sublin(fd,1)
if (status2 = 0) 
*
* ajusto set lat e set lon com as coordenadas lidas
* no arquivo que contem os pontos de grade
*
coord=sublin(fd,2)
xlon=subwrd(coord,1)
xlat=subwrd(coord,2)
'set lat 'xlat
'set lon 'xlon
*
* pego a precip do ponto de grade
*
'd sum(chuva,t='t',t='t+3')'
var=sublin(result,2)
valor=subwrd(var,4)
*say valor' 't
*say result
if (valor >=0 )
precip=precip+valor
conta=conta+1
yyy=write("logao.prn",bacia' 'xlat' 'xlon' 'valor' 'conta' 't,append)
endif 
*ay result
endif
endwhile



media=precip/(conta+(0.00001))
rc1 = math_format("%7.2f",precip)
rc2 = math_format("%7.0f",conta)
rc3 = math_format("%5.2f",media)
fim=write(bacia'.ens',data' 'dataprev' 'rc3,append)
xxx=write("todomundoens.prn",data' 'dataprev' 'rc3,append)
t=t+4
endwhile

************  da linha 36
endwhile     
'return'







function baixagfs(config)




'sdfopen http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs'config'/gep_all_00z'
'set lon 280 330'
'set lat -40 10'


n=1
t=1
while (n<=21)
'set e 'n
'q dims'
var=sublin(result,)
'set fwrite 'config''n'.ens.bin'
'set gxout fwrite'
'set e 'n
while (t<=65)
'set t 't
'd pratesfc*6*3600'
t=t+1
endwhile
n=n+1
endwhile

'disable fwrite'
'set gxout shaded'


return
