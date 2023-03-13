--  Correção (Ivaldo)
--- (07/06/2022 16:38): Inclusão da Coluna cd_solsai_pro
--- inclusão SOLSAI_PRO.sn_urgente in ('S','N')


SELECT 
                  cd_atendimento
                  ,cd_solsai_pro
                  ,To_Char(DT_SOLSAI_PRO, 'DD/MM/RRRR') HR_SOLSAI_PRO
                  ,ds_leito
                  ,Sum (ITEM_SOLICITADO) qtd_ITEM
                  ,Case when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                  when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                else SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(NM_PACIENTE) ||')' end Nome_Paciente
                ,To_Char(dt_nascimento, 'DD/MM/RRRR') dt_nascimento
                  ,(CASE WHEN tp_situacao = 'P'  AND TEMPO  >  '01:00:00' THEN ('VERMELHO')
                          WHEN tp_situacao IN ('C')  AND TEMPO  >= '01:00:00' THEN ('AMARELO')
                            END) AS COR  
                FROM (
                SELECT
                     solsai_pro.cd_solsai_pro 
                    ,atendime.cd_atendimento
                    ,atendime.dt_atendimento
                    ,leito.ds_leito
                    ,( ITSOLSAI_PRO.QT_SOLICITADO - ITSOLSAI_PRO.QT_ATENDIDA ) QTD_ITENS
                    ,(CASE WHEN  ( ITSOLSAI_PRO.QT_SOLICITADO - ITSOLSAI_PRO.QT_ATENDIDA ) = 0 THEN  ITSOLSAI_PRO.QT_SOLICITADO ELSE  ( ITSOLSAI_PRO.QT_SOLICITADO - ITSOLSAI_PRO.QT_ATENDIDA ) END )ITEM_SOLICITADO
                    ,ITSOLSAI_PRO.QT_ATENDIDA
                    ,paciente.Nm_Paciente
                    ,paciente.dt_nascimento
                    ,SOLSAI_PRO.HR_SOLSAI_PRO
                    ,SOLSAI_PRO.DT_SOLSAI_PRO
                    ,(SUBSTR( (CAST(SOLSAI_PRO.HR_SOLSAI_PRO AS TIMESTAMP) - CAST(SYSDATE  AS TIMESTAMP) ),12,8 ) ) AS TEMPO
                    ,SOLSAI_PRO.TP_SITUACAO

                  FROM  SOLSAI_PRO,ITSOLSAI_PRO, atendime, paciente , leito   
                    WHERE  To_date(SOLSAI_PRO.dt_solsai_pro,'dd/mm/yyyy') = To_Date (SYSDATE,'dd/mm/yyyy') -- AND SYSDATE
                    AND solsai_pro.cd_solsai_pro = ITSOLSAI_PRO.cd_solsai_pro  
                    AND SOLSAI_PRO.cd_atendimento = atendime.cd_atendimento
                    AND   atendime.cd_paciente = paciente.cd_paciente
                    AND   atendime.cd_leito = leito.cd_leito
                    AND   atendime.hr_alta IS NULL
                    AND   solsai_pro.cd_pre_med IS NULL 
                    AND   solsai_pro.TP_SOLSAI_PRO = 'P'
                    AND SOLSAI_PRO.sn_urgente in ('S','N')
                    AND SOLSAI_PRO.cd_estoque = 2
                    AND SOLSAI_PRO.tp_situacao IN ('P','C') )
                    WHERE TEMPO >= '01:00:00'
                    GROUP BY cd_atendimento
                     ,To_Char(DT_SOLSAI_PRO, 'DD/MM/RRRR')
                    ,ds_leito
                    ,NM_PACIENTE
                    ,cd_solsai_pro
                     ,dt_nascimento
                     ,tp_situacao
                     ,TEMPO
