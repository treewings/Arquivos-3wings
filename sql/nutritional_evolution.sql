-- QUERY EVOLUÇÃO NUTRICIONAL
-- Alto Risco – >= 72 horas com >= 48 horas notificar na cor VERMELHA 
-- Médio Risco – 96 horas com >=72  horas notificar na cor VERMELHA 
-- Baixo Risco – Sete dias, no 6° dia notificar na cor VERMELHA 
 --------------------------------------------------------------

SELECT DISTINCT   CD_ATENDIMENTO,  
       Case when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                  when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'  

                else SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(NM_PACIENTE) ||')' end Nome_Paciente ,
      To_Char (dt_nascimento , 'dd/mm/yyyy') dt_nascimento, 

        DS_RESUMO,
        DIAS,
        HORAS_ABERTO ,
        TIPO ,  
        ALERTA   
 FROM (
----------------------TRIAGEM NUTRICIONAL DOC 69 ----------------------------------------------

SELECT CD_ATENDIMENTO ,
          NM_PACIENTE ,
          DT_NASCIMENTO ,
          DS_RESUMO,
          --CD_DOCUMENTO ,
          --DH_FECHAMENTO1 ,
          HORAS_ABERTO ,
          DIAS ,
          TIPO ,       
          ALERTA                                  
   FROM                                              
     (SELECT CD_ATENDIMENTO,                
             NM_PACIENTE,
             DT_NASCIMENTO,
             CD_DOCUMENTO,
             DS_RESUMO,
             DH_FECHAMENTO DH_FECHAMENTO1,
             HORAS_ABERTO,
             DIAS,
             TIPO,        
             CASE WHEN HORAS_ABERTO_MINUTO > 2880  AND (DS_IDENTIFICADOR1= 'ckb_classifica_3' AND DS_RESPOSTA = 'true')THEN 'VERMELHO'
                  WHEN HORAS_ABERTO_MINUTO >= 4320 AND (DS_IDENTIFICADOR1= 'ckb_classifica_2' AND DS_RESPOSTA = 'true')THEN 'VERMELHO'
                  WHEN DIAS >= 6                   AND (DS_IDENTIFICADOR1= 'ckb_classifica_1' AND DS_RESPOSTA = 'true')THEN 'VERMELHO'
             ELSE 'BRANCO' END ALERTA  
      FROM
        (SELECT VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_ATENDIMENTO ,
                VDIC_RESPOSTA_DOCUMENTO_TASCOM.NM_PACIENTE ,
                VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_DOCUMENTO ,
                VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO ,
                (SYSDATE - VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO)*24*60 HORAS_ABERTO_MINUTO ,
                TO_CHAR(TRUNC(((SYSDATE - VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO)*24*60 * 60) / 3600), 'FM9900')
                 || ':' || TO_CHAR(TRUNC(MOD(((SYSDATE - VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO)*24*60 * 60), 3600) / 60), 'FM00')
                 || ':' || TO_CHAR(MOD(((SYSDATE - VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO)*24*60 * 60), 60), 'FM00') AS HORAS_ABERTO ,
                TO_DATE (SYSDATE,'DD/MM/RRRR HH24:MI:SS') - TO_DATE (VDIC_RESPOSTA_DOCUMENTO_TASCOM.DH_FECHAMENTO,'DD/MM/RRRR HH24:MI:SS') DIAS ,
                -- 'ALTO RISCO' RISCO ,
               CASE WHEN(DS_IDENTIFICADOR1 = 'ckb_classifica_3' AND DS_RESPOSTA = 'true' AND DS_RESPOSTA IS NOT NULL) THEN 'ALTO RISCO'
                    WHEN(DS_IDENTIFICADOR1 = 'ckb_classifica_2' AND DS_RESPOSTA = 'true' AND DS_RESPOSTA IS NOT NULL) THEN 'MEDIO RISCO'
                    WHEN(DS_IDENTIFICADOR1 = 'ckb_classifica_1' AND DS_RESPOSTA = 'true'AND DS_RESPOSTA IS NOT NULL) THEN 'BAIXO RISCO'
               END TIPO, 
               LEITO.DS_RESUMO ,
               DT_NASCIMENTO,
               DS_RESPOSTA,
               DS_IDENTIFICADOR1
         FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM, 
              ATENDIME ,
              LEITO ,
              PACIENTE
         WHERE VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
          AND ATENDIME.CD_LEITO = LEITO.CD_LEITO
          AND VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_PACIENTE = PACIENTE.CD_PACIENTE
          AND TP_STATUS  IN ('FECHADO','ASSINADO')
          AND DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_DOCUMENTO IN (69)-- triagem 
          AND ATENDIME.DT_ALTA IS NULL
          AND ATENDIME.TP_ATENDIMENTO = 'I'
          AND DS_RESPOSTA IS NOT NULL
          AND DS_IDENTIFICADOR1 IN ('ckb_classifica_3','ckb_classifica_2','ckb_classifica_1')
          AND DS_RESPOSTA = 'true'
          AND NOT EXISTS
             (SELECT DISTINCT V.CD_ATENDIMENTO
              FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM V ,
                   ATENDIME
              WHERE V.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
                AND TP_STATUS IN ('FECHADO','ASSINADO')
                AND V.CD_DOCUMENTO IN (468) -- DOC ANTROPOMÉTRICA      
                AND ATENDIME.DT_ALTA IS NULL
                AND ATENDIME.TP_ATENDIMENTO = 'I'                          
                AND V.CD_ATENDIMENTO = VDIC_RESPOSTA_DOCUMENTO_TASCOM.CD_ATENDIMENTO )
          )
            
         ORDER BY 1 DESC) 

----------------------EVOLUÇÃO NUTRICIONAL DOC 468 ----------------------------------------------
UNION ALL 
           
SELECT 
 CD_ATENDIMENTO,                                           
       NM_PACIENTE,
       DT_NASCIMENTO ,
       DS_RESUMO,               
       HORAS_ABERTO,
       DIAS,                                                              
       TIPO,
       --DH_FECHAMENTO1,
       CASE WHEN HORAS_ABERTO_MINUTO > 2880 AND TIPO = 'ALTO RISCO' THEN 'VERMELHO'
            WHEN HORAS_ABERTO_MINUTO >= 4320 AND TIPO = 'MEDIO RISCO' THEN 'VERMELHO'
            WHEN DIAS >= 6 AND TIPO = 'BAIXO RISCO' THEN 'VERMELHO'  ELSE 'BRANCO' END ALERTA
                                                                                                   
FROM (
SELECT DISTINCT 
       CD_ATENDIMENTO,                                           
       NM_PACIENTE,
       DT_NASCIMENTO ,
       DS_RESUMO,
       CD_DOCUMENTO , 
       DS_RESPOSTA,    
       DH_FECHAMENTO1,
      (SYSDATE - DH_FECHAMENTO1)*24*60 HORAS_ABERTO_MINUTO,
       TO_CHAR(TRUNC(((SYSDATE - DH_FECHAMENTO1)*24*60 * 60) / 3600), 'FM9900') || ':' || TO_CHAR(TRUNC(MOD(((SYSDATE - DH_FECHAMENTO1)*24*60 * 60), 3600) / 60), 'FM00') || ':' || TO_CHAR(MOD(((SYSDATE - DH_FECHAMENTO1)*24*60 * 60), 60), 'FM00') AS HORAS_ABERTO ,
       TO_DATE (SYSDATE,'DD/MM/RRRR HH24:MI:SS') - TO_DATE (DH_FECHAMENTO1, 'DD/MM/RRRR HH24:MI:SS') dias,      
      CASE WHEN  ds_resposta =  '3||Alto Risco - 4 a 5 pontos' THEN 'ALTO RISCO'
           WHEN  ds_resposta =  '2||Médio Risco - 1 a 3 pontos' THEN 'MEDIO RISCO'
           ELSE 'BAIXO RISCO' END TIPO                                                                                          

FROM (
SELECT V.CD_ATENDIMENTO,
       V.NM_PACIENTE,
       P.dt_nascimento,
       L.DS_RESUMO,
       V.CD_DOCUMENTO,
       DS_RESPOSTA, 
       CD_CAMPO2,
      (SELECT max (DH_FECHAMENTO)
       FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM V
      WHERE CD_DOCUMENTO IN (468)
        AND TP_STATUS IN ('FECHADO','ASSINADO')
        AND DS_RESPOSTA IN ('3||Alto Risco - 4 a 5 pontos','2||Médio Risco - 1 a 3 pontos','1||Baixo Risco - 0 pontos') 
        AND v.cd_campo2 = 313868
        AND cd_atendimento = ATENDIME.CD_ATENDIMENTO )DH_FECHAMENTO1     
                                 
              FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM V ,                      
                   ATENDIME,
                   PACIENTE P,
                   LEITO L
              WHERE V.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
                AND ATENDIME.CD_PACIENTE = P.CD_PACIENTE
                AND ATENDIME.CD_LEITO = L.CD_LEITO 
                AND V.CD_DOCUMENTO IN (468) -- DOC ANTROPOMÉTRICA
                AND TP_STATUS IN ('FECHADO','ASSINADO')
                AND ATENDIME.DT_ALTA IS NULL
                AND ATENDIME.TP_ATENDIMENTO = 'I'
                AND DS_RESPOSTA IN ('3||Alto Risco - 4 a 5 pontos','2||Médio Risco - 1 a 3 pontos','1||Baixo Risco - 0 pontos')
              
                 ) )
ORDER BY 1
                                                        
)WHERE ALERTA = 'VERMELHO'                                   
ORDER BY  DIAS DESC, HORAS_ABERTO


                                              