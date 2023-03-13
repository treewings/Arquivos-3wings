SELECT
     pisca_vermelho
    ,cd_atendimento
    ,nm_paciente
    ,medicamento
    ,laboratorio_status
    ,laboratorio_tempo
    ,imagem
    ,repouso
    ,prescricao_horario

FROM(
SELECT CASE WHEN TEMPO_ESPERA_TOTAL = 'X'
                       THEN 'PISCA'
                       ELSE ''
                       END PISCA_VERMELHO
                      ,CD_ATENDIMENTO
                      ,NM_PACIENTE
                    --CAIXINHA_MEDICAMENTO
                      ,CASE WHEN MEDICAMENTO = 'NAO TEM' OR MEDICAMENTO IS NULL THEN
                         'BRANCO'
                      ELSE
                      CASE WHEN MEDICAMENTO = 'PENDENTE' THEN --PACIENTE AGUARDANDO PARA TOMAR MEDICACAO
                         'VERMELHA'
                      ELSE
                         'VERDE'
                      END
                      END MEDICAMENTO
                   
                      --------------- CAIXINHA LABORATORIO STATUS

                      ,CASE WHEN LABORATORIO_STATUS = 'NAO TEM' OR LABORATORIO_STATUS IS NULL THEN
                        'BRANCO'
                      ELSE
                      CASE WHEN LABORATORIO_STATUS='PENDENTE' THEN
                           CASE WHEN COLETA_ESPERA_ATUAL = '30+' THEN
                           'VERMELHA'  
                           ELSE
                            'VERMELHA'
                           END
                      ELSE
                      CASE WHEN LABORATORIO_STATUS = 'DISPONIVEL' THEN
                           CASE WHEN COLETA_ESPERA_PASSADA='30+' THEN
                                'VERDE' 
                           ELSE
                                'VERDE'
                           END
                      ELSE
                      CASE WHEN RESULTADO_LAB_ESPERA_ATUAL = '70+' THEN
                           'AMARELO' 
                                                 ELSE
                      CASE WHEN COLETA_ESPERA_PASSADA='30+' THEN
                           'AMARELA' 
                      ELSE 'AMARELA'
                      END
                      END
                      END
                      END
                      END LABORATORIO_STATUS 



-------------- CAIXINHA LABORATORIO TEMPO

                      ,CASE WHEN LABORATORIO_STATUS = 'NAO TEM' OR LABORATORIO_STATUS IS NULL THEN
                        ''
                      ELSE
                      CASE WHEN LABORATORIO_STATUS='PENDENTE' THEN
                           CASE WHEN COLETA_ESPERA_ATUAL = '30+' THEN
                           '30+'  
                           ELSE
                            ''
                           END
                      ELSE
                      CASE WHEN LABORATORIO_STATUS = 'DISPONIVEL' THEN
                           CASE WHEN COLETA_ESPERA_PASSADA='30+' THEN
                                '30+'
                           ELSE
                                ''
                           END
                      ELSE
                      CASE WHEN RESULTADO_LAB_ESPERA_ATUAL = '70+' THEN
                           '70+'
                                                 ELSE
                      CASE WHEN COLETA_ESPERA_PASSADA='30+' THEN
                            '30+'
                      ELSE ''
                      END
                      END
                      END
                      END
                      END LABORATORIO_TEMPO

                      -- caixinha imagem
                      ,CASE WHEN IMAGEM='NAO TEM' THEN
                          'BRANCO'
                      ELSE
                      CASE WHEN IMAGEM = 'PENDENTE' THEN
                          'VERMELHA'
                      ELSE
                      CASE WHEN IMAGEM='DISPONIVEL' THEN
                          'VERDE'
                      ELSE
                          'AMARELA'
                      END
                      END
                      END IMAGEM
                     , CASE WHEN REPOUSO <> 'Não' THEN 'EM REPOUSO' ELSE NULL END REPOUSO
                     , PRESCRICAO_HORARIO
      FROM (SELECT CD_ATENDIMENTO,
                   NM_PACIENTE,
                   PRIMEIRA_PRESCRICAO,
                   PRESCRICAO_HORARIO,
                   MEDICAMENTO,
                   HORA_CHAMADA_LABORATORIO,
                   LABORATORIO_STATUS,
                   CASE WHEN LABORATORIO_STATUS = 'PENDENTE' AND
                             replace(to_char(to_char(trunc((nvl(SYSDATE, '') - PRIMEIRA_PRESCRICAO) * 24),'fm09')) || ':' ||
                             to_char(to_char(trunc(mod(round(((SYSDATE -PRIMEIRA_PRESCRICAO) * 1440),4),60)),'fm09') || ':' ||
                             to_char(trunc(mod(round(((SYSDATE -PRIMEIRA_PRESCRICAO) * 86400),4),60)),'fm09')),'::',
                             '') > '00:30:00' --TEMPO DE ESPERA PARA COLETA MAIOR QUE 30 MIN
                        THEN '30+'
                   ELSE NULL
                   END AS COLETA_ESPERA_ATUAL,

                   CASE WHEN replace(to_char(to_char(trunc((nvl(HORA_CHAMADA_LABORATORIO, '') -PRIMEIRA_PRESCRICAO) * 24),'fm09')) || ':' ||
                             to_char(to_char(trunc(mod(round(((HORA_CHAMADA_LABORATORIO -PRIMEIRA_PRESCRICAO) * 1440),4),60)),'fm09') || ':' ||
                             to_char(trunc(mod(round(((HORA_CHAMADA_LABORATORIO -PRIMEIRA_PRESCRICAO) *86400),4),60)),'fm09')),'::',
                             '') > '00:30:00' --QUANDO O PACIENTE JA COLHEU MAS A ESPERA PARA COLHER FOI MAIOR QUE 40 MIN
                        THEN '30+'
                   ELSE NULL
                   END AS COLETA_ESPERA_PASSADA,

                   CASE WHEN LABORATORIO_STATUS != 'PENDENTE'
                             AND replace(to_char(to_char(trunc((nvl(SYSDATE, '') -HORA_CHAMADA_LABORATORIO) * 24),'fm09')) || ':' ||
                             to_char(to_char(trunc(mod(round(((SYSDATE - HORA_CHAMADA_LABORATORIO) * 1440),4), 60)), 'fm09') || ':' ||
                             to_char(trunc(mod(round(((SYSDATE -HORA_CHAMADA_LABORATORIO) * 86400),4), 60)),'fm09')),'::','')
                             > '01:10:00'
                        OR LABORATORIO_STATUS != 'NAO TEM' AND
                             replace(to_char(to_char(trunc((nvl(SYSDATE, '') -HORA_CHAMADA_LABORATORIO) * 24),'fm09')) || ':' ||
                             to_char(to_char(trunc(mod(round(((SYSDATE - HORA_CHAMADA_LABORATORIO) * 1440),4), 60)), 'fm09') || ':' ||
                             to_char(trunc(mod(round(((SYSDATE -HORA_CHAMADA_LABORATORIO) * 86400),4), 60)),'fm09')),'::','')
                             > '01:10:00'
                        THEN  '70+'
                   ELSE NULL
                   END AS RESULTADO_LAB_ESPERA_ATUAL,

                   CASE WHEN replace(to_char(to_char(trunc((nvl(SYSDATE, '') - PRIMEIRA_PRESCRICAO) * 24),'fm09')) || ':' ||
                             to_char(to_char(trunc(mod(round(((SYSDATE - PRIMEIRA_PRESCRICAO) * 1440),4),60)),'fm09') || ':' ||
                             to_char(trunc(mod(round(((SYSDATE - PRIMEIRA_PRESCRICAO) * 86400),4), 60)),'fm09')),'::','')
                             > '02:00:00' THEN 'X'
                   ELSE NULL
                   END AS TEMPO_ESPERA_TOTAL,
                   REPOUSO,
                   IMAGEM
            FROM (SELECT DISTINCT A.CD_ATENDIMENTO AS CD_ATENDIMENTO,
                         P.NM_PACIENTE AS NM_PACIENTE,
                         PRIMEIRA_PRESCRICAO.DATA AS PRIMEIRA_PRESCRICAO,
                         NVL(NVL(REPOUSO.STATUS,OBS.VALOR),'Não') AS REPOUSO,
                         TO_CHAR(PRIMEIRA_PRESCRICAO.DATA,'HH24:MI') AS PRESCRICAO_HORARIO,
                         (CASE WHEN ITEM_MED.STATUS = 'SIM'
                               THEN NVL(TO_CHAR(TEMPO_MED.DH_PROCESSO,'HH24:MI'),'PENDENTE')
                          ELSE
                          CASE WHEN TO_CHAR(PRIMEIRA_PRESCRICAO.DATA,'HH24:MI') IS NULL
                               THEN NULL
                          ELSE 'NAO TEM'
                          END
                          END) AS MEDICAMENTO,
                          TEMPO_LAB.DH_PROCESSO AS HORA_CHAMADA_LABORATORIO, --LAB_TEMPO
                         (CASE WHEN ITEM_LAB.STATUS = 'SIM' THEN --QUANDO O PACIENTE TEM ITEM DE LABORATORIO
                               CASE WHEN QTD_LAB_RESULTADO.QTD = QTD_EXAME_LAB.QTD
                                    THEN 'DISPONIVEL'
                               ELSE NVL(TO_CHAR(TEMPO_LAB.DH_PROCESSO,'HH24:MI'),'PENDENTE')
                               END --DATA HORA DA COLETA DO EXAME DE LABORATORIO
                          ELSE
                               CASE WHEN TO_CHAR(PRIMEIRA_PRESCRICAO.DATA,'HH24:MI') IS NULL
                                    THEN NULL
                               ELSE 'NAO TEM'
                               END
                          END) AS LABORATORIO_STATUS,
                          QTD_EXAME_LAB.QTD AS QTD_EXAMES_LAB,
                          QTD_LAB_RESULTADO.QTD AS QTD_EXAMES_RESULT,
                          (CASE WHEN ITEM_IMAGEM.STATUS = 'SIM' THEN
                                NVL(NVL(RESULTADO_IMAGEM.VALOR,TO_CHAR(TEMPO_IMA.DH_PROCESSO,'HH24:MI')),'PENDENTE')
                           ELSE
                               CASE WHEN TO_CHAR(PRIMEIRA_PRESCRICAO.DATA,'HH24:MI') IS NULL THEN
                                   NULL
                               ELSE 'NAO TEM'
                               END
                           END) AS IMAGEM
                 FROM ATENDIME A
                 INNER JOIN PACIENTE P ON A.CD_PACIENTE = P.CD_PACIENTE
                 LEFT JOIN (SELECT MIN(PM1.DH_IMPRESSAO) AS DATA,
                                   PM1.CD_ATENDIMENTO
                            FROM PRE_MED PM1
                            GROUP BY PM1.CD_ATENDIMENTO) PRIMEIRA_PRESCRICAO
                            ON PRIMEIRA_PRESCRICAO.CD_ATENDIMENTO = A.CD_ATENDIMENTO --TEMPO DE FECHAMENTO DA PRIMEIRA PRESCRICAO FEITA
                 LEFT JOIN (SELECT PM2.CD_ATENDIMENTO,
                                   'SIM' AS STATUS,
                                   TO_CHAR(PM2.DT_PRE_MED, 'HH24:MI') AS HORA
                            FROM PRE_MED PM2
                            INNER JOIN ITPRE_MED IPM2 ON IPM2.CD_PRE_MED = PM2.CD_PRE_MED
                            INNER JOIN TIP_ESQ TP2 ON TP2.CD_TIP_ESQ = IPM2.CD_TIP_ESQ
                            WHERE IPM2.CD_TIP_ESQ IN ('ASP','ANT','INA','MED','MEF','MPP','MPS','MSP','SOR')
                                  AND PM2.DH_IMPRESSAO is not null) ITEM_MED ON ITEM_MED.CD_ATENDIMENTO = A.CD_ATENDIMENTO --PRESCRICAO DE MEDICACAO
                 LEFT JOIN (SELECT MIN(SACR2.DH_PROCESSO) AS DH_PROCESSO,
                                   SACR2.CD_ATENDIMENTO AS CD_ATENDIMENTO
                            FROM SACR_TEMPO_PROCESSO SACR2 --MEDI
                            WHERE SACR2.CD_TIPO_TEMPO_PROCESSO = 71
                            GROUP BY SACR2.CD_ATENDIMENTO) TEMPO_MED ON TEMPO_MED.CD_ATENDIMENTO = A.CD_ATENDIMENTO -- TEMPO DA MEDICACAO
                 LEFT JOIN (SELECT PM3.CD_ATENDIMENTO, 'SIM' AS STATUS
                            FROM PRE_MED PM3
                            INNER JOIN ITPRE_MED IPM3 ON IPM3.CD_PRE_MED = PM3.CD_PRE_MED
                            INNER JOIN TIP_ESQ TP3 ON TP3.CD_TIP_ESQ = IPM3.CD_TIP_ESQ
                            WHERE IPM3.CD_TIP_ESQ IN ('LAB', 'LIQ', 'LAP', 'LAO')
                                  AND PM3.DH_IMPRESSAO is not null) ITEM_LAB ON ITEM_LAB.CD_ATENDIMENTO = A.CD_ATENDIMENTO --PRESCRICAO DE EXAMES LABORATORIAIS
                 LEFT JOIN (SELECT COUNT(IPM8.CD_ITPRE_MED) AS QTD,
                                   PM8.CD_ATENDIMENTO
                            FROM PRE_MED PM8
                            INNER JOIN ITPRE_MED IPM8 ON IPM8.CD_PRE_MED = PM8.CD_PRE_MED
                            INNER JOIN TIP_ESQ TP8 ON TP8.CD_TIP_ESQ = IPM8.CD_TIP_ESQ
                            WHERE IPM8.CD_TIP_ESQ IN ('LAB', 'LIQ', 'LAP', 'LAO')
                                  AND PM8.DH_IMPRESSAO is not null
                            GROUP BY PM8.CD_ATENDIMENTO) QTD_EXAME_LAB ON QTD_EXAME_LAB.CD_ATENDIMENTO = A.CD_ATENDIMENTO -- QUANTIDADE DE EXAMES LABORATORIAIS
                 LEFT JOIN (SELECT MIN(SACR3.DH_PROCESSO) AS DH_PROCESSO,
                                   SACR3.CD_ATENDIMENTO AS CD_ATENDIMENTO
                            FROM SACR_TEMPO_PROCESSO SACR3
                            WHERE SACR3.CD_TIPO_TEMPO_PROCESSO = 51
                            GROUP BY SACR3.CD_ATENDIMENTO) TEMPO_LAB ON TEMPO_LAB.CD_ATENDIMENTO = A.CD_ATENDIMENTO -- DATA_HORA COLETA EXAME LAB
                 LEFT JOIN (SELECT COUNT(DISTINCT RE8.CD_EXA_LAB) AS QTD,
                                   A8.CD_ATENDIMENTO
                            FROM ATENDIME A8
                            INNER JOIN PED_LAB PL8 ON PL8.CD_ATENDIMENTO = A8.CD_ATENDIMENTO
                            INNER JOIN ITPED_LAB IPL8 ON IPL8.CD_PED_LAB = PL8.CD_PED_LAB
                            RIGHT JOIN RES_EXA RE8 ON RE8.Cd_Ped_Lab = Pl8.Cd_Ped_Lab
                                        WHERE RE8.DS_RESULTADO IS NOT NULL
                                        GROUP BY A8.CD_ATENDIMENTO) QTD_LAB_RESULTADO
                            ON QTD_LAB_RESULTADO.CD_ATENDIMENTO = A.CD_ATENDIMENTO -- NUMERO DE ITENS LABORATORIAIS COM RESULTADO
                 LEFT JOIN (SELECT PM4.CD_ATENDIMENTO, 'SIM' AS STATUS
                            FROM PRE_MED PM4
                            INNER JOIN ITPRE_MED IPM4 ON IPM4.CD_PRE_MED = PM4.CD_PRE_MED
                            INNER JOIN TIP_ESQ TP4 ON TP4.CD_TIP_ESQ = IPM4.CD_TIP_ESQ
                            WHERE IPM4.CD_TIP_ESQ IN ('EXA', 'EXP', 'EXO')
                                  AND PM4.DH_IMPRESSAO is not null) ITEM_IMAGEM
                            ON ITEM_IMAGEM.CD_ATENDIMENTO = A.CD_ATENDIMENTO --PRESCRICAO EXAME DE IMAGEM AINDA NÃO FECHADA
                 LEFT JOIN (SELECT MIN(SACR4.DH_PROCESSO) AS DH_PROCESSO,
                                   SACR4.CD_ATENDIMENTO AS CD_ATENDIMENTO
                            FROM SACR_TEMPO_PROCESSO SACR4
                            WHERE SACR4.CD_TIPO_TEMPO_PROCESSO = 61
                            GROUP BY SACR4.CD_ATENDIMENTO) TEMPO_IMA ON TEMPO_IMA.CD_ATENDIMENTO = A.CD_ATENDIMENTO -- DATA_HORA EXAME DE IMAGEM
                 LEFT JOIN (SELECT A.CD_ATENDIMENTO, 'SIM' AS STATUS
                            FROM ATENDIME A
                            INNER JOIN PW_DOCUMENTO_CLINICO DC ON DC.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                            INNER JOIN PW_EDITOR_CLINICO PEC ON PEC.CD_DOCUMENTO_CLINICO = DC.CD_DOCUMENTO_CLINICO
                            WHERE PEC.CD_DOCUMENTO = 36) ALTA ON ALTA.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                 LEFT JOIN (SELECT DISTINCT PDC.CD_ATENDIMENTO,
                                   'DISPONIVEL' AS VALOR
                            FROM PW_DOCUMENTO_CLINICO PDC
                            INNER JOIN PW_EDITOR_CLINICO PEC  ON PEC.CD_DOCUMENTO_CLINICO = PDC.CD_DOCUMENTO_CLINICO
                            INNER JOIN dbamv.ged_conteudo GED ON GED.CD_DOCUMENTO = PEC.CD_DOCUMENTO
                            WHERE GED.BLOB_CONTEUDO IS NOT NULL) RESULTADO_IMAGEM ON RESULTADO_IMAGEM.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                 LEFT JOIN (SELECT DISTINCT PDC.CD_ATENDIMENTO,
                                   'INTERNADO' AS VALOR
                            FROM PW_DOCUMENTO_CLINICO PDC
                            INNER JOIN PW_EDITOR_CLINICO PEC ON PEC.CD_DOCUMENTO_CLINICO = PDC.CD_DOCUMENTO_CLINICO
                            WHERE PEC.CD_DOCUMENTO = 36) INTERNADO ON INTERNADO.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                 LEFT JOIN (SELECT DISTINCT A.CD_ATENDIMENTO, 'Sim' AS VALOR
                            FROM ATENDIME A
                            INNER JOIN PW_DOCUMENTO_CLINICO DC ON DC.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                            INNER JOIN PW_EDITOR_CLINICO PEC ON PEC.CD_DOCUMENTO_CLINICO = DC.CD_DOCUMENTO_CLINICO
                            WHERE pec.Cd_Documento=7 and trunc(a.dt_atendimento)=TRUNC(SYSDATE)) OBS ON OBS.CD_ATENDIMENTO=A.CD_ATENDIMENTO
                 LEFT JOIN (SELECT PM10.CD_ATENDIMENTO, 'Sim' AS STATUS
                            FROM PRE_MED PM10
                            INNER JOIN ITPRE_MED IPM10 ON IPM10.CD_PRE_MED = PM10.CD_PRE_MED
                            INNER JOIN TIP_ESQ TP10 ON TP10.CD_TIP_ESQ = IPM10.CD_TIP_ESQ
                            WHERE CD_TIP_PRESC=4437
                                  AND PM10.DH_IMPRESSAO is not null) REPOUSO
                            ON REPOUSO.CD_ATENDIMENTO = A.CD_ATENDIMENTO
                  WHERE A.TP_ATENDIMENTO = 'U'
                        AND TRUNC(A.DT_ATENDIMENTO) = TRUNC(SYSDATE)
                        AND A.DT_ALTA IS NULL
                        AND PRIMEIRA_PRESCRICAO.DATA IS NOT NULL
                        AND ALTA.STATUS IS NULL
                        AND INTERNADO.VALOR IS NULL
                  ORDER BY PRESCRICAO_HORARIO ASC)
                 )
                 )
 WHERE REPOUSO IS NULL