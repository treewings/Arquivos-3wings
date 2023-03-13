--hospitalization_ui_uti (andra)
SELECT tipo
       ,Count (tipo) qtd
       ,data
FROM (
-----------------INTERNACOES UI DIA  ------------- 
SELECT 'INTERNACOES DO DIA UI' TIPO
       --,Count(*) Quant
      ,cd_atendimento
      ,dt_atendimento  DATA
     -- ,LEITO.CD_LEITO

FROM dbamv.atendime,leito
WHERE dt_atendimento between trunc(sysdate) and sysdate
and cd_atendimento_pai is NULL
AND atendime.cd_leito = leito.cd_leito
--AND leito.cd_unid_int IN (5,36,39)
AND leito.cd_unid_int IN (37,28,23)-- UNIDADES DE INTERNÇAO UI
AND tp_atendimento = 'I'

UNION 
 

-- internações prox 3 dias
SELECT 'INTERNACOES PROX 3DIAS UI ' TIPO
        ,cd_atendimento
        ,DT_PREV_INTERNACAO  DATA    
     -- ,Count  (cd_paciente)QTDE_PREV_INTERN
FROM (
SELECT RES_LEI.nm_paciente
      ,RES_LEI.cd_paciente
      ,atendime.cd_atendimento
      ,RES_LEI.cd_leito
      ,RES_LEI.dt_reserva
      ,RES_LEI.dt_prev_alta
      ,RES_LEI.DT_PREV_INTERNACAO
      ,atendime.dt_alta
FROM DBAMV.RES_LEI
    ,DBAMV.ATENDIME
    ,leito
WHERE ATENDIME.cd_atendimento = RES_LEI.cd_atendimento
  AND leito.cd_leito = atendime.cd_leito
  --AND leito.cd_unid_int IN (5,36,39)
  AND leito.cd_unid_int IN (37,28,23)-- UNIDADES DE INTERNÇAO UI
  AND tp_atendimento = 'I'

  AND DT_PREV_INTERNACAO between trunc(SYSDATE + 1) and SYSDATE + 4
  ORDER BY DT_PREV_INTERNACAO
 )
UNION 
 -------------------------UTI ---------------------------------------     

SELECT 'INTERNACOES DO DIA UTI' TIPO
       --,Count(*) Quant
      ,cd_atendimento
      ,dt_atendimento  DATA
     -- ,LEITO.CD_LEITO

FROM dbamv.atendime,leito
WHERE dt_atendimento between trunc(sysdate) and sysdate
and cd_atendimento_pai is NULL
AND atendime.cd_leito = leito.cd_leito
AND leito.cd_unid_int IN (38,3,25,7,26,27,31,34,16,30)-- UNIDADES DE INTERNÇAO UTI
AND tp_atendimento = 'I'

UNION 
 
-- internações prox 3 dias
SELECT 'INTERNACOES PROX 3DIAS UTI ' TIPO
        ,cd_atendimento
        ,DT_PREV_INTERNACAO  DATA    
     -- ,Count  (cd_paciente)QTDE_PREV_INTERN
FROM (
SELECT RES_LEI.nm_paciente
      ,RES_LEI.cd_paciente
      ,atendime.cd_atendimento
      ,RES_LEI.cd_leito
      ,RES_LEI.dt_reserva
      ,RES_LEI.dt_prev_alta
      ,RES_LEI.DT_PREV_INTERNACAO
      ,atendime.dt_alta
FROM DBAMV.RES_LEI
    ,DBAMV.ATENDIME
    ,leito
WHERE ATENDIME.cd_atendimento = RES_LEI.cd_atendimento
  AND leito.cd_leito = atendime.cd_leito
  --AND leito.cd_unid_int IN (5,36,39)
  AND leito.cd_unid_int IN (38,3,25,7,26,27,31,34,16,30)-- UNIDADES DE INTERNÇAO UTI
  AND tp_atendimento = 'I'

  AND DT_PREV_INTERNACAO between trunc(SYSDATE + 1) and SYSDATE + 4
  ORDER BY DT_PREV_INTERNACAO
 )

 )   GROUP BY tipo,data
     ORDER BY data