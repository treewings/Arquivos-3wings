-- query avaliação antropométrica
/*Quando for preenchido Alto Risco (Documento PEP - Triagem Nutricional doc 69) ,
 deve ser preenchido o documento Avaliação Antropométrica em até 10 dias,
 no  9° dia deve sinalizar no command center usando de base a data do documento Triagem Nutricional doc,
 e os demais usando de base a data/hora que foi preenchido o documento avaliação Antropométria. */
    
    SELECT
          CD_ATENDIMENTO
          ,NOME_PACIENTE
          ,DT_NASCIMENTO 
          ,DS_RESUMO
          ,DH_FECHAMENTO
          ,HORAS_ABERTO
          ,DIAS         
          ,CASE WHEN DIAS >= 7 THEN 'ALERTA' ELSE 'NORMAL' END ALERTA
    FROM
    (
    SELECT V1.CD_ATENDIMENTO 
          ,Case when SUBSTR(V1.NM_PACIENTE, 1 , 
          (INSTR(V1.NM_PACIENTE , ' ' , 1 , 1 ) -1 )) || ' ('||OBTER_INICIAIS(V1.NM_PACIENTE ) ||')' LIKE '%RNA%'
           THEN SUBSTR(V1.NM_PACIENTE , 1 , (INSTR(V1.NM_PACIENTE , ' ' , 1 , 1 ) -1 )) || ' ('||OBTER_INICIAIS(V1.NM_PACIENTE) || ')'

           WHEN SUBSTR(V1.NM_PACIENTE, 1 , (INSTR(V1.NM_PACIENTE , ' ' , 1 , 1 ) -1 )) || ' ('||OBTER_INICIAIS(V1.NM_PACIENTE ) ||')' LIKE '%RN%'                            
           THEN SUBSTR(V1.NM_PACIENTE ,1 , (INSTR(V1.NM_PACIENTE , ' ' , 1 , 2 ) -1 )) || ' ('||OBTER_INICIAIS(V1.NM_PACIENTE ) || ')'  

           ELSE SUBSTR(V1.NM_PACIENTE , 1 , (INSTR(V1.NM_PACIENTE , ' ' , 1 , 1 ) -1 )) || '('||OBTER_INICIAIS(V1.NM_PACIENTE ) ||')' end NOME_PACIENTE 
          ,TO_CHAR (DT_NASCIMENTO , 'DD/MM/YYYY') DT_NASCIMENTO
          ,LEITO.DS_RESUMO
          ,V1.CD_DOCUMENTO
          ,V1.DH_FECHAMENTO
          ,(SYSDATE - V1.DH_FECHAMENTO)*24*60 HORAS_ABERTO_MINUTO
          ,TO_CHAR(TRUNC(((SYSDATE - V1.DH_FECHAMENTO)*24*60 * 60) / 3600), 'FM9900') || ':' ||
           TO_CHAR(TRUNC(MOD(((SYSDATE - V1.DH_FECHAMENTO)*24*60 * 60), 3600) / 60), 'FM00') || ':' ||
           TO_CHAR(MOD(((SYSDATE - V1.DH_FECHAMENTO)*24*60 * 60), 60), 'FM00') AS HORAS_ABERTO    
          ,To_date (SYSDATE ,'DD/MM/RRRR HH24:MI:SS')  - To_date ( Dh_Criacao ,'DD/MM/RRRR HH24:MI:SS') DIAS 
    FROM 
      DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM V1
     ,ATENDIME
     ,LEITO 
     ,PACIENTE  
    WHERE 
      V1.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
      AND ATENDIME.CD_LEITO = LEITO.CD_LEITO 
      AND ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE
      AND TP_STATUS IN ('FECHADO','ASSINADO')
      AND V1.CD_DOCUMENTO IN (69) -- DOC DE TRIAGEM 
      AND ATENDIME.DT_ALTA IS NULL 
      AND ATENDIME.TP_ATENDIMENTO = 'I'
      AND DS_RESPOSTA IS NOT NULL                                    
      AND (DS_IDENTIFICADOR1= 'ckb_classifica_3' AND DS_RESPOSTA = 'true')    --ALTO RISCO   
      AND NOT EXISTS (
          SELECT DISTINCT  V.CD_ATENDIMENTO   
          FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM  V
               ,ATENDIME 
          WHERE V.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
          AND TP_STATUS IN ('FECHADO','ASSINADO')
          AND V.CD_DOCUMENTO IN (271) -- DOC ANTROPOMÉTRICA
          AND ATENDIME.DT_ALTA IS NULL 
          AND ATENDIME.TP_ATENDIMENTO = 'I'  
          AND V.CD_ATENDIMENTO = V1.CD_ATENDIMENTO
         
      ))  
      WHERE DIAS >= 7           
 ORDER BY DIAS DESC
                                  