
SELECT tipo
       ,Count (tipo) qtd
       ,data
FROM (
SELECT 'INTERNACOES DO DIA HD' TIPO
       --,Count(*) Quant
      ,cd_atendimento
      ,dt_atendimento  DATA

FROM dbamv.atendime,leito
WHERE dt_atendimento between trunc(sysdate) and sysdate
and cd_atendimento_pai is NULL
AND atendime.cd_leito = leito.cd_leito
AND leito.cd_unid_int IN (5,36,39)
AND tp_atendimento = 'I'


UNION ALL
-- internações prox 3 dias
SELECT 'INTERNACOES PROX 3DIAS HD ' TIPO
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
  AND leito.cd_unid_int IN (5,36,39)
 -- AND atendime.dt_alta IS  NULL
  AND tp_atendimento = 'I'

  AND DT_PREV_INTERNACAO between trunc(SYSDATE + 1) and SYSDATE + 4
  ORDER BY DT_PREV_INTERNACAO
 )
 )   GROUP BY tipo,data
     ORDER BY data
