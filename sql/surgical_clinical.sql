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
