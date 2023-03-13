--query painel sabará 
--TOTAL CIRURGIAS MES  -- atualizada em 04/04/22 
SELECT 'CIRURGIAS MES' TIPO
      , Count(b.cd_cirurgia) total_pacientes_operados -- adicionado por Andra     
from      
dbamv.cirurgia a,
dbamv.cirurgia_aviso b,
dbamv.aviso_cirurgia c,
dbamv.especialid d,
dbamv.paciente pac,
dbamv.atendime ate,
dbamv.prestador_aviso pa,
dbamv.prestador prest         
where 
 a.cd_cirurgia(+) = b.cd_cirurgia
 and b.cd_aviso_cirurgia(+) = c.cd_aviso_cirurgia
 and d.cd_especialid(+) = b.cd_especialid
 and c.cd_atendimento = ate.cd_atendimento
 and ate.cd_paciente = pac.cd_paciente
 and pa.cd_aviso_cirurgia = b.cd_aviso_cirurgia
 and pa.cd_cirurgia_aviso = b.cd_cirurgia_aviso
 and pa.cd_prestador = prest.cd_prestador
 and pa.sn_principal = 'S'
 and b.sn_principal = 'S'
 AND trunc(c.dt_realizacao) between  trunc(sysdate,'MM') and SYSDATE 

UNION ALL 
--PACIENTES OPERADOS MES

SELECT 'PACIENTES OPERADOS MES' TIPO
       ,Count(cd_paciente) total_pacientes_operados -- adicionado por Andra
       FROM ( select 
             d.ds_especialid
            ,count(b.cd_cirurgia_aviso) qt
            ,pac.cd_paciente cd_paciente   
from      
dbamv.cirurgia a,
dbamv.cirurgia_aviso b,
dbamv.aviso_cirurgia c,
dbamv.especialid d,
dbamv.paciente pac,
dbamv.atendime ate,
dbamv.prestador_aviso pa,
dbamv.prestador prest

where 
 a.cd_cirurgia(+) = b.cd_cirurgia
 and b.cd_aviso_cirurgia(+) = c.cd_aviso_cirurgia
 and d.cd_especialid(+) = b.cd_especialid
 and c.cd_atendimento = ate.cd_atendimento
 and ate.cd_paciente = pac.cd_paciente
 and pa.cd_aviso_cirurgia = b.cd_aviso_cirurgia
 and pa.cd_cirurgia_aviso = b.cd_cirurgia_aviso
 and pa.cd_prestador = prest.cd_prestador
 and pa.sn_principal = 'S'
 and b.sn_principal = 'S'
 AND trunc(c.dt_realizacao) between  trunc(sysdate,'MM') and SYSDATE 
group by d.ds_especialid ,pac.cd_paciente
order by 1 )

UNION ALL 
--TOTAL CIRURGIAS DIA
SELECT 'CIRURGIAS REALIZADAS DIA' TIPO
      , Count(b.cd_cirurgia) total_pacientes_operados -- adicionado por Andra     
from      
dbamv.cirurgia a,
dbamv.cirurgia_aviso b,
dbamv.aviso_cirurgia c,
dbamv.especialid d,
dbamv.paciente pac,
dbamv.atendime ate,
dbamv.prestador_aviso pa,
dbamv.prestador prest         
where 
 a.cd_cirurgia(+) = b.cd_cirurgia
 and b.cd_aviso_cirurgia(+) = c.cd_aviso_cirurgia
 and d.cd_especialid(+) = b.cd_especialid
 and c.cd_atendimento = ate.cd_atendimento
 and ate.cd_paciente = pac.cd_paciente
 and pa.cd_aviso_cirurgia = b.cd_aviso_cirurgia
 and pa.cd_cirurgia_aviso = b.cd_cirurgia_aviso
 and pa.cd_prestador = prest.cd_prestador
 and pa.sn_principal = 'S'
 and b.sn_principal = 'S'
 AND C.tp_situacao = 'R'   
 and trunc(c.dt_realizacao)= to_date(sysdate) 

 UNION ALL 
 --TOTAL CIRURGIAS CANCELADAS DIA
SELECT 'CIRURGIAS CANCELADAS DIA' TIPO
      , Count(b.cd_cirurgia) total_pacientes_operados -- adicionado por Andra     
from      
dbamv.cirurgia a,
dbamv.cirurgia_aviso b,
dbamv.aviso_cirurgia c,
dbamv.especialid d,
dbamv.paciente pac,
dbamv.atendime ate,
dbamv.prestador_aviso pa,
dbamv.prestador prest         
where 
 a.cd_cirurgia(+) = b.cd_cirurgia
 and b.cd_aviso_cirurgia(+) = c.cd_aviso_cirurgia
 and d.cd_especialid(+) = b.cd_especialid
 and c.cd_atendimento = ate.cd_atendimento
 and ate.cd_paciente = pac.cd_paciente
 and pa.cd_aviso_cirurgia = b.cd_aviso_cirurgia
 and pa.cd_cirurgia_aviso = b.cd_cirurgia_aviso
 and pa.cd_prestador = prest.cd_prestador
 and pa.sn_principal = 'S'
 and b.sn_principal = 'S'
 AND C.tp_situacao = 'C'   
 and trunc(c.dt_realizacao)= to_date(sysdate)       

 UNION ALL  
--PACIENTES OPERADOS DIA

SELECT 'PACIENTES OPERADOS DIA' TIPO
       ,Count(cd_paciente) total_pacientes_operados -- adicionado por Andra
       FROM ( select 
             d.ds_especialid
            ,count(b.cd_cirurgia_aviso) qt
            ,pac.cd_paciente cd_paciente   
from      
dbamv.cirurgia a,
dbamv.cirurgia_aviso b,
dbamv.aviso_cirurgia c,
dbamv.especialid d,
dbamv.paciente pac,
dbamv.atendime ate,
dbamv.prestador_aviso pa,
dbamv.prestador prest

where 
 a.cd_cirurgia(+) = b.cd_cirurgia
 and b.cd_aviso_cirurgia(+) = c.cd_aviso_cirurgia
 and d.cd_especialid(+) = b.cd_especialid
 and c.cd_atendimento = ate.cd_atendimento
 and ate.cd_paciente = pac.cd_paciente
 and pa.cd_aviso_cirurgia = b.cd_aviso_cirurgia
 and pa.cd_cirurgia_aviso = b.cd_cirurgia_aviso
 and pa.cd_prestador = prest.cd_prestador
 and pa.sn_principal = 'S'
 and b.sn_principal = 'S'
 and trunc(c.dt_realizacao)= to_date(sysdate) 

group by d.ds_especialid ,pac.cd_paciente
order by 1 )

