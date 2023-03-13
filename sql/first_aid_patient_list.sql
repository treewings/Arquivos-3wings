-- query atualizada em 01/06/22(andra)
-- foi criada uma nova view e feito ajuste no select da query anterior 

SELECT DISTINCT    
             posto ,
             tipo_leito ,
             paciente ,
             nasc ,
             sexo ,
             hd_anamnese ,
             dieta ,
             hr_int ,
             NVL (intern,'SOLICITADO INTERNACAO')intern,
             alergia ,   
             ds_idade , 
             Nvl(peso, retorna_pac_tascom(atend)) peso,
             CASE
              WHEN img_lab IS NOT  NULL 
                   AND RESULT >= 1 THEN 'LIBERADO'
          END LAB,
          CASE
              WHEN img_rx IS NOT NULL 
                   AND result2 >= 1 THEN 'LIBERADO'
          END RX,
          CASE
              WHEN img_lab IS NULL
                   AND img_rx IS NULL THEN 'SEM EXAME'
              ELSE 'TEM EXAME'
          END SEM_EXAME   
      FROM
      
        (SELECT DECODE (PAINEL_PS.leito,
                        201,'Posto A',202,'Posto A',203,'Posto A',204,'Posto A',205,'Posto A',206,'Posto A',207,'Posto A',208,'Posto A',
                        211,'Posto B',212,'Posto B',213,'Posto B',214,'Posto B',215,'Posto B',216,'Posto B',997,'Posto B',
                        221,'Posto C',222,'Posto C',223,'Posto C',224,'Posto C',225,'Posto C',226,'Posto C',
                        101,'Posto D',102,'Posto D',103,'Posto D',104,'Posto D',105,'Posto D',106,'Posto D',107,'Posto D',108,'Posto D', 109,'Posto D',
                        111,'Posto E',112,'Posto E',113,'Posto E',114,'Posto E',115,'Posto E',116,'Posto E',1031,'Posto E',1032,'Posto E',
                       NULL,'Observacao') || '  ' ||PAINEL_PS.LEITO POSTO,
                       PAINEL_PS.TIPO_LEITO,
                       PAINEL_PS.ATEND,
                       PAINEL_PS.PACIENTE,
                       to_date(PAINEL_PS.NASC, 'dd/mm/rrrr')NASC,
                       PAINEL_PS.SEXO,

           (SELECT   HD
            FROM
              (SELECT Cd_Atendimento,
                      Cd_paciente,
                      replace(to_char(wm_concat(VALOR)), ',', ' / ')HD
               FROM
                 (SELECT DISTINCT Cd_Atendimento,
                                  Cd_paciente,
                                  VALOR
                  FROM
                    (SELECT DISTINCT pw.Cd_Atendimento,
                                     PW.Cd_Paciente,
                                     pw.Cd_Campo_Pai pai,
                                     DBMS_LOB.SUBSTR(pw.Ds_Resposta, 3200, 1) valor
                     FROM dbamv.vdic_pw_resposta_documento pw
                     WHERE pw.Ds_Campo_Metadado in ('HIP DIGNOSTICA', '224_txt cid1')
                       AND pw.Cd_Documento IN (13, 4)
                       AND pw.dh_fechamento BETWEEN sysdate-1 AND SYSDATE -- andra
                       AND pw.Tp_Status in ('FECHADO','ASSINADO')
                       AND pw.Cd_Registro =
                         (SELECT max(pw3.cd_editor_registro)
                          FROM pw_documento_clinico pw2,
                               pw_editor_clinico pw3
                          WHERE pw2.cd_documento_clinico = pw3.cd_documento_clinico
                            AND pw2.cd_atendimento = PW.Cd_atendimento --- andra
                            AND  pw2.cd_paciente = PW.Cd_paciente  
                            AND pw3.cd_documento IN (13,4)
                            AND pw2.dh_fechamento BETWEEN sysdate-1 AND SYSDATE -- andra
                            AND PW2.TP_STATUS in ('FECHADO', 'ASSINADO') )))
               GROUP BY cd_atendimento,
                        cd_paciente)P_1

            WHERE p_1.cd_paciente = PAINEL_PS.same
              AND p_1.cd_atendimento = PAINEL_PS.atend -- andra

             )hd_Anamnese,
          PAINEL_PS.DIETA,
          (SELECT TIPO_INTERNACAO
            FROM
              (SELECT cd_paciente,
                      TP_ATENDIMENTO,
                      cd_atendimento,
                      Hr_Atendimento AS "DT_DOC",
                      (CASE
                           WHEN QTD >= 1 THEN 'SOLICITADO INTERNACAO'
                       END)TIPO_INTERNACAO
                     FROM
                 (SELECT COUNT (aa.cd_atendimento)QTD,
                               aa.cd_atendimento,
                               AA.CD_PACIENTE,
                               aa.Hr_Atendimento,
                               aa.TP_ATENDIMENTO
                  FROM atendime aa
                  WHERE aa.dt_atendimento >=
                      (SELECT max(ab.dt_atendimento)
                       FROM atendime ab
                       WHERE ab.tp_atendimento = 'U'
                       AND ab.cd_paciente = aa.cd_paciente
                       AND ab.cd_atendimento = aa.cd_atendimento -- andra
                         )
                    AND aa.tp_atendimento = 'U'
                  GROUP BY AA.CD_PACIENTE,
                           aa.Hr_Atendimento,
                           aa.TP_ATENDIMENTO,
                           aa.cd_atendimento)
               UNION SELECT cd_paciente,
                            TP_ATENDIMENTO,
                            cd_atendimento,
                            Hr_Atendimento AS "DT_DOC",
                            (CASE
                                 WHEN QTD >= 1 THEN 'SOLICITACAO ATENDIDA'
                             END)TIPO_INTERNACAO
               FROM
                 (SELECT COUNT (aa.cd_atendimento)QTD,
                               aa.cd_atendimento,
                               AA.CD_PACIENTE,
                               aa.Hr_Atendimento,
                               aa.TP_ATENDIMENTO
                  FROM atendime aa
                  WHERE aa.dt_atendimento >=
                      (SELECT max(ab.dt_atendimento)
                       FROM atendime ab
                       WHERE ab.tp_atendimento = 'U'
                         AND AB.DT_ALTA IS NULL -- ANDRA
                         AND ab.cd_paciente = aa.cd_paciente
                         AND ab.cd_atendimento = aa.cd_atendimento -- andra
                      )
                    AND aa.tp_atendimento = 'I'
                    AND AA.DT_ALTA IS NULL -- ANDRA
                  GROUP BY AA.CD_PACIENTE,
                           aa.Hr_Atendimento,
                           aa.TP_ATENDIMENTO,
                           aa.cd_atendimento)) intern
            WHERE intern.cd_atendimento = PAINEL_PS.atend )intern,  
              
--------------------------- PESO 

           (SELECT Ds_Resposta
            FROM
              (SELECT Ate.Cd_Atendimento Cd_Atendimento ,
                      Max(Pdc.cd_documento_clinico) ,
                      dbms_lob.substr(Erc.Lo_Valor, 10) Ds_Resposta
               FROM Dbamv.Pw_Documento_Clinico Pdc ,
                    Dbamv.Pw_Editor_Clinico Pec ,
                    Dbamv.Editor_Registro_Campo Erc ,
                    Dbamv.Atendime Ate ,
                    Dbamv.Editor_Campo Ecp 
                   -- Dbamv.Editor_Documento Doc -- COMENTADO POR ANDRA
               WHERE Pec.Cd_Documento_Clinico = Pdc.Cd_Documento_Clinico
                 AND Erc.Cd_Registro = Pec.Cd_Editor_Registro
                 AND Pdc.Cd_Atendimento = Ate.Cd_Atendimento
                 AND Ecp.Cd_Campo = Erc.Cd_campo
                 --AND Pec.Cd_Documento = Doc.Cd_Documento  
                 AND Pdc.dh_fechamento BETWEEN sysdate-1 AND SYSDATE -- ANDRA
                 AND Pec.Cd_Documento = 4
                 AND Pdc.TP_STATUS in ('FECHADO', 'ASSINADO')  -- ANDRA
                 AND Ecp.Ds_Campo = 'PESO'
               GROUP BY Ate.Cd_Atendimento,
                        dbms_lob.substr(Erc.Lo_Valor, 10)) DOC_PESO
            WHERE doc_peso.cd_atendimento = PAINEL_PS.atend ) PESO, 
            painel_ps.exa_laboratorial IMG_LAB, -- andra   
            painel_ps.exa_diag_imagem IMG_rx, -- andra
            
--------- ALERGIA  ** GEOVANNA

           (SELECT ds_alergia
            FROM triagem_atendimento
            WHERE ds_alergia IS NOT NULL  
              AND triagem_atendimento.cd_atendimento = PAINEL_PS.atend) alergia,
                                                                 

------------------------- IDADE
 (SELECT fn_idade_tascom(P.dt_nascimento, 'aA e mM', sysdate) 
 FROM PACIENTE P WHERE P.CD_PACIENTE = PAINEL_PS.SAME) ds_idade ,  
 
--------- RESUL      
           (SELECT sum(qtd)
            FROM
              (SELECT cd_atendimento,
                      COUNT(CD_ITPED_LAB)QTD
               FROM
                 (SELECT VB10.CD_ATENDIMENTO,
                         VB12.NM_PACIENTE,
                         VB10.CD_PED_LAB,
                         VB9.cd_itped_lab,
                         vb13.nm_exa_lab AS "EXAME",

                    (SELECT img_lAB
                     FROM
                       (SELECT cd_itped_lab,
                               (CASE
                                    WHEN QTD >= 1 THEN 'LIBERADO'
                                END)img_lAB
                        FROM
                          (SELECT re8.cd_itped_lab,
                                  vb8.cd_atendimento,
                                  RE8.CD_EXA_LAB,
                                  COUNT(RE8.CD_EXA_LAB)QTD
                           FROM DBAMV.itped_lab VB7,
                                ped_lab vb8,
                                RES_EXA RE8
                           WHERE vb7.cd_ped_lab = vb8.cd_ped_lab
                             AND RE8.DS_RESULTADO IS NOT NULL
                             AND VB7.cd_itped_lab = RE8.CD_ITPED_LAB
                           GROUP BY re8.cd_itped_lab,
                                    RE8.CD_EXA_LAB,
                                    VB8.CD_ATENDIMENTO))P_1
                     WHERE p_1.cd_itped_lab = vb9.cd_itped_lab )RESULTADO
                  FROM DBAMV.itped_lab VB9,
                       ped_lab vb10,
                       atendime vb11,
                       paciente vb12,
                       exa_lab vb13
                  WHERE vb9.cd_ped_lab = vb10.cd_ped_lab
                    AND vb10.cd_atendimento = vb11.cd_atendimento
                    AND vb11.cd_paciente = vb12.cd_paciente
                    AND vb9.cd_exa_lab = vb13.cd_exa_lab
                  GROUP BY VB10.CD_ATENDIMENTO,
                           VB12.NM_PACIENTE,
                           VB10.CD_PED_LAB,
                           VB9.cd_itped_lab,
                           vb13.nm_exa_lab)
               WHERE RESULTADO = 'LIBERADO'
               GROUP BY cd_atendimento)p_5
            WHERE p_5.cd_atendimento = PAINEL_PS.atend )RESULT,
            
             --------  RESULT 2     
           (SELECT sum(qtd)
            FROM 
              (SELECT cd_atendimento,
                      COUNT(CD_ITPED_rx)QTD
               FROM
                 (SELECT 'IMAGEM' AS "TIPO",
                         VB5.CD_ATENDIMENTO,
                         pp.nm_paciente,
                         vb5.cd_ped_rx,
                         vb4.CD_ITPED_RX,
                         ex.ds_exa_rx AS "EXAME",

                    (SELECT img_rx
                     FROM
                       (SELECT cd_itped_RX,
                               (CASE
                                    WHEN QTD >= 1 THEN 'LIBERADO'
                                END)img_rx
                        FROM
                          (SELECT itt.cd_itped_rx,
                                  COUNT (itt.cd_exa_rx)QTD                                 
                           FROM itped_rx itt
                           WHERE itt.cd_laudo IS NOT NULL
                           GROUP BY itt.cd_itped_rx))p_4
                     WHERE p_4.cd_itped_rx = VB4.cd_itped_rx)resultado
                  FROM itped_rx vb4,
                       DBAMV.PED_RX VB5,
                       exa_rx ex,
                       atendime AT,
                                paciente pp
                  WHERE vb4.cd_ped_rx = vb5.cd_ped_rx
                    AND vb4.cd_exa_rx = ex.cd_exa_rx
                    AND at.cd_atendimento = vb5.cd_atendimento
                    AND at.cd_paciente = pp.cd_paciente
                  GROUP BY VB5.CD_ATENDIMENTO,
                           vb5.cd_ped_rx,
                           pp.nm_paciente,
                           NULL,
                           vb4.CD_ITPED_RX,
                           ex.ds_exa_rx)
               WHERE RESULTADO = 'LIBERADO'
               GROUP BY cd_atendimento)p_5

            WHERE p_5.cd_atendimento = PAINEL_PS.atend )RESULT2   
             ,Nvl(SUBSTR((CAST(painel_ps.dt_hr_entr AS TIMESTAMP) - CAST(SYSDATE AS TIMESTAMP)),12, 8), 0) hr_int
            -- ,painel_ps.dt_hr_entr
---------- corpo query-----------------------------------
         FROM PAINEL_PS  
             , atendime a  -- andra
         WHERE painel_ps.atend = a.cd_atendimento
          AND dt_alta IS NULL 
        
         )ORDER BY 1
            
