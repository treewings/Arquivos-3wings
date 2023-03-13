SELECT 

  to_char(DATA_EVENTO,'DD/MM/YYYY')
 ,STATUS
 ,QUANTIDADE

 FROM (

SELECT 

 DATA_EVENTO
,SUM(TOTAL_AGENDADO) TOTAL_AGENDADO
,SUM(TOTAL_REALIZADO) TOTAL_REALIZADO
,SUM(TOTAL_CANCELADO) TOTAL_CANCELADO

 FROM (

 SELECT
 
  AGENDADO_PARA DATA_EVENTO
 , COUNT(*) TOTAL_AGENDADO
 , 0 TOTAL_REALIZADO
 , 0 TOTAL_CANCELADO
 
  FROM (
 
 SELECT 

  AVISO_CIRURGIA.CD_AVISO_CIRURGIA
 ,TRUNC (AVISO_CIRURGIA.DT_AVISO_CIRURGIA) DATA_AVISO
 ,DECODE(AVISO_CIRURGIA.TP_SITUACAO, 'A', 'AVISO',
                                                                   'C', 'CANCELADO',
                                                                   'G', 'AGENDADO',
                                                                   'R', 'REALIZADO') SITUACAO
 ,TRUNC(AGE_CIR.DT_INICIO_AGE_CIR)                                     AGENDADO_PARA                                                                
 ,TRUNC(AVISO_CIRURGIA.DT_CANCELAMENTO) CANCELADO_EM
 ,TRUNC(AVISO_CIRURGIA.DT_REALIZACAO) REALIZADO_EM
                                      
 FROM
 
  AVISO_CIRURGIA
 ,AGE_CIR
                                     
 WHERE
   
         AVISO_CIRURGIA.CD_AVISO_CIRURGIA = AGE_CIR.CD_AVISO_CIRURGIA (+)                                                           
 AND AVISO_CIRURGIA.TP_SITUACAO IN ('A', 'C', 'G', 'R')
 --AND AVISO_CIRURGIA.DT_AVISO_CIRURGIA BETWEEN SYSDATE - 10 AND SYSDATE     
 
 ORDER BY 
 
  AGE_CIR.DT_INICIO_AGE_CIR DESC                                                                                               
 )
 
 /*WHERE
 
 SITUACAO = 'AGENDADO'*/
 
 GROUP BY 
 
 AGENDADO_PARA


 UNION 

  SELECT 
 
 REALIZADO_EM DATA_EVENTO
, 0 TOTAL_AGENDADO
, COUNT(*) TOTAL_REALIZADO
, 0 TOTAL_CANCELADO

 FROM (
 
 SELECT 

  AVISO_CIRURGIA.CD_AVISO_CIRURGIA
 ,TRUNC(AVISO_CIRURGIA.DT_AVISO_CIRURGIA) DATA_AVISO
 ,DECODE(AVISO_CIRURGIA.TP_SITUACAO, 'A', 'AVISO',
                                                                   'C', 'CANCELADO',
                                                                   'G', 'AGENDADO',
                                                                   'R', 'REALIZADO') SITUACAO
 ,TRUNC(AGE_CIR.DT_INICIO_AGE_CIR)                                     AGENDADO_PARA                                                                
 ,TRUNC(AVISO_CIRURGIA.DT_CANCELAMENTO) CANCELADO_EM
 ,TRUNC(AVISO_CIRURGIA.DT_REALIZACAO) REALIZADO_EM
                                      
 FROM
 
  AVISO_CIRURGIA
 ,AGE_CIR
                                     
 WHERE
   
         AVISO_CIRURGIA.CD_AVISO_CIRURGIA = AGE_CIR.CD_AVISO_CIRURGIA (+)                                                           
 AND AVISO_CIRURGIA.TP_SITUACAO IN ('A', 'C', 'G', 'R')
 --AND AVISO_CIRURGIA.DT_AVISO_CIRURGIA BETWEEN SYSDATE - 10 AND SYSDATE     
 
 ORDER BY 
 
  AGE_CIR.DT_INICIO_AGE_CIR DESC                                                                                               
 )
 
/* WHERE
 
 SITUACAO = 'REALIZADO'*/
 
 GROUP BY 
 
 REALIZADO_EM
  
 UNION 
  
  SELECT 
 
 CANCELADO_EM DATA_EVENTO
, 0 TOTAL_AGENDADO
, 0 TOTAL_REALIZADO
, COUNT(*) TOTAL_CANCELADO

 FROM (
 
 SELECT 

  AVISO_CIRURGIA.CD_AVISO_CIRURGIA
 ,TRUNC(AVISO_CIRURGIA.DT_AVISO_CIRURGIA) DATA_AVISO
 ,DECODE(AVISO_CIRURGIA.TP_SITUACAO, 'A', 'AVISO',
                                                                   'C', 'CANCELADO',
                                                                   'G', 'AGENDADO',
                                                                   'R', 'REALIZADO') SITUACAO
 ,TRUNC(AGE_CIR.DT_INICIO_AGE_CIR)                                     AGENDADO_PARA                                                                
 ,TRUNC(AVISO_CIRURGIA.DT_CANCELAMENTO) CANCELADO_EM
 ,TRUNC(AVISO_CIRURGIA.DT_REALIZACAO) REALIZADO_EM
                                      
 FROM
 
  AVISO_CIRURGIA
 ,AGE_CIR
                                     
 WHERE
   
         AVISO_CIRURGIA.CD_AVISO_CIRURGIA = AGE_CIR.CD_AVISO_CIRURGIA (+)                                                           
 AND AVISO_CIRURGIA.TP_SITUACAO IN ('A', 'C', 'G', 'R')
 --AND AVISO_CIRURGIA.DT_AVISO_CIRURGIA BETWEEN SYSDATE - 10 AND SYSDATE     
 
 ORDER BY 
 
  AGE_CIR.DT_INICIO_AGE_CIR DESC                                                                                               
 )
 
 WHERE
 
 SITUACAO = 'CANCELADO'
 
 GROUP BY 
 
 CANCELADO_EM
 
 )
 
 WHERE 
 
 DATA_EVENTO between  trunc(sysdate,'MM')and SYSDATE + 3
 
 GROUP BY
 
 DATA_EVENTO
 
 ORDER BY 
 
 DATA_EVENTO )
 
UNPIVOT ( QUANTIDADE FOR STATUS  IN (TOTAL_AGENDADO, TOTAL_REALIZADO, TOTAL_CANCELADO))