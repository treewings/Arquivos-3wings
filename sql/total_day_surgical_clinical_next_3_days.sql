 SELECT 'INTERNACOES DO DIA' TIPO,
       Count(ATENDIME.CD_ATENDIMENTO) Quant,
       TIPO_INTERNACAO
FROM dbamv.atendime,
(SELECT DISTINCT CD_ATENDIMENTO, CASE WHEN cd_tipo_internacao IN (1,2) THEN 'CIRURGIA' ELSE 'CLINICA' END AS TIPO_INTERNACAO FROM (SELECT cd_atendimento,cd_tipo_internacao FROM atendime
WHERE tp_atendimento = 'I'
AND CD_TIPO_INTERNACAO IN (1,2,3,4))) TIPO
WHERE dt_atendimento between trunc(sysdate) and sysdate
and cd_atendimento_pai is null
AND tp_atendimento = 'I'
AND TIPO.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
GROUP BY (TIPO_INTERNACAO)

UNION ALL

SELECT 'INTERNACOES PROX 3DIAS' TIPO,
      Count  (cd_paciente) QUANT,
       TIPO_INTERNACAO
FROM (
SELECT RES_LEI.nm_paciente
      ,RES_LEI.cd_paciente
      ,atendime.cd_atendimento
      ,RES_LEI.cd_leito
      ,RES_LEI.dt_reserva
      ,RES_LEI.dt_prev_alta
      ,DT_PREV_INTERNACAO
      ,atendime.dt_alta,
      TIPO.TIPO_INTERNACAO
FROM DBAMV.RES_LEI
    ,DBAMV.ATENDIME
    ,(SELECT DISTINCT CD_ATENDIMENTO,
     CASE WHEN cd_tipo_internacao IN (1,2) THEN 'CIRURGIA' ELSE 'CLINICA' END AS TIPO_INTERNACAO
     FROM (SELECT cd_atendimento,cd_tipo_internacao FROM atendime
WHERE tp_atendimento = 'I'
AND CD_TIPO_INTERNACAO IN (1,2,3,4))) TIPO


WHERE ATENDIME.cd_atendimento = RES_LEI.cd_atendimento
  AND atendime.dt_alta IS  NULL
  AND tp_atendimento = 'I'
  AND TIPO.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO

  AND Trunc (DT_PREV_INTERNACAO) between trunc(sysdate) and SYSDATE + 2
  ORDER BY DT_PREV_INTERNACAO
 )
   GROUP BY (TIPO_INTERNACAO)