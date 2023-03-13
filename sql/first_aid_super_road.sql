--query painel original sabará , adaptada por Andra
-- qutde pacientes super via e maior tempo supervia ( prestador 8069)
SELECT Nvl (MAX(TEMPO),0)maior_tempo_super_via,
       Nvl ( Count(cd_atendimento),0)QTD_PACIENTE
FROM (
SELECT A.CD_COR_REFERENCIA,
 COR.DS_REFERENCIA,
 FILA.DS_FILA FILA,
 count(*) as QTD,
 a.cd_atendimento cd_atendimento,
 --a.cd_cor_referencia,
 TO_CHAR(24*60*(Max(SYSDATE-B.DH_PROCESSO)),'999')||' '|| 'Min' AS Maior_tempo,
 to_number (TO_CHAR(24*60*(Max(SYSDATE-B.DH_PROCESSO)),'999'))maior  ,
 SubStr(CAST(SYSDATE AS TIMESTAMP) - Max(CAST(B.DH_PROCESSO AS TIMESTAMP)), 11,9) TEMPO
 FROM TRIAGEM_ATENDIMENTO A
 LEFT JOIN SACR_TEMPO_PROCESSO B
 ON A.CD_ATENDIMENTO=B.CD_ATENDIMENTO
 LEFT JOIN ATENDIME C
 ON A.CD_ATENDIMENTO=C.CD_ATENDIMENTO
 LEFT JOIN COR_REFERENCIA COR
 ON A.CD_COR_REFERENCIA = COR.CD_COR_REFERENCIA
 LEFT JOIN fila_senha FILA
 ON A.CD_FILA_SENHA = FILA.CD_FILA_SENHA
 WHERE B.CD_TIPO_TEMPO_PROCESSO='22'
 AND C.tp_atendimento = 'U'
 AND C.cd_prestador in (8069)
 AND A.CD_FILA_SENHA IN (1,8)
 AND C.dt_diag is null
 AND C.dt_alta is null
 AND C.cd_especialid = 36
 AND C.sn_em_atendimento = 'N'
 --and a.cd_cor_referencia = TRIAGEM_ATENDIMENTO.CD_COR_REFERENCIA --
 AND to_char(sysdate,'dd/mm/rrrr') = to_char(B.DH_PROCESSO,'dd/mm/rrrr') AND
 NOT EXISTS
 (SELECT 's'
 FROM dbamv.registro_documento B
 WHERE B.cd_atendimento = C.cd_atendimento
 AND B.sn_impresso = 'N'
 UNION
 SELECT 'S'
 FROM DBAMV.PW_EDITOR_CLINICO,
 DBAMV.PW_DOCUMENTO_clinico
 WHERE pw_editor_clinico.cd_documento_clinico = pw_documento_clinico.cd_documento_clinico
 AND pw_documento_clinico.cd_atendimento = C.cd_atendimento
 AND pw_documento_clinico.tp_status = 'ABERTO'
 AND ROWNUM = 1)
 group by a.cd_cor_referencia,COR.DS_REFERENCIA, FILA.DS_FILA,a.cd_atendimento , DH_PROCESSO
)




