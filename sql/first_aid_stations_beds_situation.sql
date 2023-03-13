--QUERY DO PAINEL ORIGINAL DO SABARA (PAINEL ANDAR 2) E ADAPTADA POR ANDRA - 22/04/22
--first_aid_stations_beds_situation  - atualizada em 31/05/22

SELECT  
     COR,
     ds_leito
FROM ( 
--- OBSERVADOS -- 

------------------------------------------------------------------
SELECT tipo,
       qtd_paciente,
       COR,
       cd_leito,
       ds_leito    
FROM   (SELECT '1-PAC OBSERVADOS NO PS' TIPO,
               Count (qtd)          QTD_PACIENTE,
              'AZUL' COR,
               cd_leito,
               ds_leito,
               UNIDADE --- PRA VER A UNIDADE    
FROM(

select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO
 
 from atendime a,
 leito l3,
 unid_int u3    
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int,hr_atendimento,l3.cd_leito, l3.ds_leito       

 UNION ALL 
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+) 
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito
) WHERE UNIDADE = 'REAVALIAÇÃO'
  GROUP BY cd_leito, ds_leito,UNIDADE ) 

UNION ALL     

SELECT tipo,
       qtd_paciente,
       COR,
       cd_leito,
       ds_leito
FROM (

SELECT '2-INTERNADOS NO PS ATE 4 HORAS' TIPO,
               Count (qtd)   QTD_PACIENTE,
              'VERDE' COR,
               cd_leito,
               ds_leito,
               tempo
FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,
-- a.hr_atendimento,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3  
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,        
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3    
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento 
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3                 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3      
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
) WHERE  tempo <= '04:00:00' 

UNION ALL 

-------------Pacientes internados PS até 8h         
SELECT tipo,
       qtd_paciente,
       COR,
       cd_leito,
       ds_leito
FROM (

SELECT '3- PAC INTERNADOS NO PS ATE 8H' TIPO,
               Count (qtd)           QTD_PACIENTE,
               'ROXO' COR,
               cd_leito,
               ds_leito,
               tempo

FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,   
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3  
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,      
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3    
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento 
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3                 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito  
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
)WHERE  tempo between '04:00:01' and  '08:00:00' 

UNION ALL 
-------------Pacientes internados PS até 8h                 
SELECT tipo,
       qtd_paciente,
       COR,
        cd_leito,
       ds_leito
      -- tempo
FROM  (SELECT '4- PAC INTERNADOS NO PS ACIMA 8H' TIPO,
              Count (qtd)           QTD_PACIENTE,
               'ROSA' COR,
               cd_leito,
               ds_leito,
               tempo
FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,
-- a.hr_atendimento,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento  
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3  
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito  (+)
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito   
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3      
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
)WHERE  tempo >= '08:00:00' 
                                 

--**************************--
UNION ALL -- TODOS OS OUTROS LEITOS VAGOS
--**************************--
SELECT NULL TIPO,
       NULL QTD_PACIENTE,
       'VAZIO' COR,
        L1.CD_LEITO CD_LEITO,
        L1.DS_LEITO DS_LEITO
FROM LEITO L1, UNID_INT UI
WHERE  L1.CD_UNID_INT = UI.CD_UNID_INT
AND L1.TP_SITUACAO = 'A'
AND L1.DS_LEITO LIKE '%OBS%'
AND UI.TP_UNID_INT = 'U'
AND L1.CD_LEITO NOT IN ( SELECT CD_LEITO 
FROM (                                                      


---------------------------------------------------------
SELECT tipo,
       qtd_paciente,
       COR,
       cd_leito,
       ds_leito
FROM (

SELECT '2-INTERNADOS NO PS ATE 4 HORAS' TIPO,
               Count (qtd)   QTD_PACIENTE,
              'COR 2' COR,
               cd_leito,
               ds_leito,
               tempo
FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,
-- a.hr_atendimento,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3  
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,        
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3    
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento 
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3                 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito (+)
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3      
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
) WHERE  tempo <= '04:00:00' 

UNION ALL 

-------------Pacientes internados PS até 8h         
SELECT tipo,
       qtd_paciente,
       COR,
       cd_leito,
       ds_leito
FROM (

SELECT '3- PAC INTERNADOS NO PS ATE 8H' TIPO,
               Count (qtd)           QTD_PACIENTE,
               'COR 3' COR,
               cd_leito,
               ds_leito,
               tempo

FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,   
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3  
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,      
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3    
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento 
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3                 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito 
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito  
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3 
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
)WHERE  tempo between '04:00:01' and  '08:00:00' 

UNION ALL 
-------------Pacientes internados PS até 8h                 
SELECT tipo,
       qtd_paciente,
       COR,
        cd_leito,
       ds_leito
      -- tempo
FROM  (SELECT '4- PAC INTERNADOS NO PS ACIMA 8H' TIPO,
              Count (qtd)           QTD_PACIENTE,
               'COR 4' COR,
               cd_leito,
               ds_leito,
               tempo
FROM (
 (select distinct 
 'REAVALIAÇÃO', 
 DECODE(u3.ds_unid_int, 'OBSERVACAO PRONTO ATENDIMENTO','REAVALIAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by  u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento
 
 UNION ALL
 
 select distinct 
 'SOLICITADO INTERNAÇÃO', 
 DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNAÇÃO',u3.ds_unid_int)UNIDADE,
 count (a.cd_atendimento) qtd,
 l3.cd_leito,
 l3.ds_leito,
-- a.hr_atendimento,  
 Substr(( Cast(a.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 from atendime a,
 leito l3,
 unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where a.cd_leito = l3.cd_leito (+)
 and l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = a.cd_paciente
 AND pv.Cd_atendimento = a.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 group by u3.ds_unid_int, l3.cd_leito, l3.ds_leito, a.hr_atendimento  
 
 UNION ALL
 
 SELECT DISTINCT NULL,
 'REAVALIAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3  
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito 
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO')) 
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito   
 
 union all 
 
 SELECT DISTINCT NULL,
 'SOLICITADO INTERNAÇÃO' UNIDADE,
 count (pm.cd_atendimento) QTD,
 l3.cd_leito,
 l3.ds_leito,
 Substr(( Cast(aa.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO

 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa,
 leito l3      
 
 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND aa.cd_leito = l3.cd_leito  
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists 
 (select 'X'
 from vdic_pw_resposta_documento pv
 where pv.Cd_Paciente = aa.cd_paciente
 AND pv.Cd_atendimento = aa.cd_atendimento
 and pv.Cd_Documento = 36
 and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
 and pv.Tp_Status in ('FECHADO','ASSINADO'))
 GROUP BY hr_atendimento, l3.cd_leito, l3.ds_leito )
 ) WHERE UNIDADE NOT IN  'REAVALIAÇÃO'
GROUP BY cd_leito, ds_leito ,tempo  
)WHERE  tempo >= '08:00:00' )
) 
) WHERE ds_leito IS NOT NULL     
ORDER BY DS_LEITO

