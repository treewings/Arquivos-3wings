-- Internações dia
SELECT 'INTERNACOES DO DIA' TIPO,
       Count(*) Quant
FROM dbamv.atendime
WHERE dt_atendimento between trunc(sysdate) and sysdate
and cd_atendimento_pai is null
AND tp_atendimento = 'I'

 
UNION ALL 
-- internações prox 3 dias
SELECT 'INTERNACOES PROX 3DIAS' TIPO, 
      Count  (cd_paciente)QTDE_PREV_INTERN
FROM (
SELECT RES_LEI.nm_paciente 
      ,RES_LEI.cd_paciente
      ,atendime.cd_atendimento
      ,RES_LEI.cd_leito 
      ,RES_LEI.dt_reserva
      ,RES_LEI.dt_prev_alta
      ,DT_PREV_INTERNACAO
      ,atendime.dt_alta
FROM DBAMV.RES_LEI
    ,DBAMV.ATENDIME
WHERE ATENDIME.cd_atendimento = RES_LEI.cd_atendimento
  AND atendime.dt_alta IS  NULL
  AND tp_atendimento = 'I'

  AND Trunc (DT_PREV_INTERNACAO) between trunc(sysdate) and SYSDATE + 2 
  ORDER BY DT_PREV_INTERNACAO
 )
UNION ALL 
-- internações prox 8 dias
SELECT 'INTERNACOES PROX 8DIAS' TIPO, 
      Count  (cd_paciente)QTDE_PREV_INTERN
FROM (
SELECT RES_LEI.nm_paciente 
      ,RES_LEI.cd_paciente
      ,atendime.cd_atendimento
      ,RES_LEI.cd_leito 
      ,RES_LEI.dt_reserva
      ,RES_LEI.dt_prev_alta
      ,DT_PREV_INTERNACAO
      ,atendime.dt_alta
FROM DBAMV.RES_LEI
    ,DBAMV.ATENDIME
WHERE ATENDIME.cd_atendimento = RES_LEI.cd_atendimento
  AND atendime.dt_alta IS  NULL
  AND tp_atendimento = 'I'

  AND Trunc (DT_PREV_INTERNACAO) between trunc(sysdate) and SYSDATE + 7
  ORDER BY DT_PREV_INTERNACAO
 )