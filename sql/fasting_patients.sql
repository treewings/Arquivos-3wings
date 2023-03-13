-- pacientes em Jejum (fasting_patients) - andra
SELECT          cd_atendimento 
               ,NM_PACIENTE
               ,DT_NASCIMENTO
               ,DS_RESUMO                                                
               ,HORAS_PRESC_ABERTO
               ,status
              
              
FROM (
SELECT  pre.cd_atendimento
        ,Max (ds_tip_presc) DIETA2 
        ,Max (pre.cd_pre_med) PRESC2
        ,DH_CRIACAO          
        ,To_Char (dt_nascimento , 'dd/mm/yyyy')DT_NASCIMENTO
        ,Case when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                  when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'  

                else SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(NM_PACIENTE) ||')' end NM_PACIENTE
       ,LEITO.DS_RESUMO 
       ,TO_CHAR(TRUNC(((SYSDATE - DH_CRIACAO)*24*60 * 60) / 3600), 'FM9900') || ':' ||
                TO_CHAR(TRUNC(MOD(((SYSDATE - DH_CRIACAO)*24*60 * 60), 3600) / 60), 'FM00') || ':' ||
                TO_CHAR(MOD(((SYSDATE - DH_CRIACAO)*24*60 * 60), 60), 'FM00') AS HORAS_PRESC_ABERTO
       ,status.status   

                                                   
 FROM                                   
--------------------------------TABELA PRE -------------------------------------------
  (SELECT 
          ATENDIME.cd_atendimento cd_atendimento
         ,Max(PRE.DH_CRIACAO) DH_CRIACAO
         ,TP.cd_tip_presc  cd_tip_presc
         ,Max(pre.cd_pre_med) cd_pre_med
         , pre.fl_impresso
     FROM                                   
      PRE_MED PRE, 
      ITPRE_MED MED,                            
      TIP_PRESC TP,
      ATENDIME       
 where med.cd_tip_presc = tp.cd_tip_presc                          
   AND pre.cd_pre_med = med.cd_pre_med
   AND pre.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO  
   AND med.cd_tip_esq in ('DIE')
   AND ds_tip_presc LIKE '%JEJUM%' 
   AND Trunc (pre.dh_criacao) BETWEEN (SYSDATE) -1 AND trunc(SYSDATE)-- inseri mascara de data 
   --AND MED.SN_CANCELADO = 'N'
   AND pre.fl_impresso = 'S'                                  
   AND dh_cancelado IS NULL                         
   AND DT_ALTA IS NULL
   
   GROUP BY ATENDIME.cd_atendimento,TP.cd_tip_presc,pre.fl_impresso ) PRE,
-------------------------------TABELA STATUS-------------------------------------------
   
(
SELECT CASE WHEN DIETA1 LIKE '%JEJUM%'     AND DIETA2  LIKE '%JEJUM%'    AND PRESC1 = PRESC2  AND dh_cancelado IS null THEN DIETA2
            WHEN DIETA1 LIKE '%JEJUM%'     AND DIETA2 NOT LIKE '%JEJUM%' AND PRESC1 = PRESC2  AND dh_cancelado IS null THEN 'JEJUM MAIS'
            WHEN DIETA1 NOT LIKE '%JEJUM%' AND DIETA2 LIKE '%JEJUM%'     AND PRESC1 = PRESC2  AND dh_cancelado IS null THEN 'JEJUM MAIS' 
            WHEN DIETA1 LIKE '%JEJUM%'     AND DIETA2 NOT LIKE '%JEJUM%' AND PRESC1 <> PRESC2 AND dh_cancelado IS null THEN DIETA2
            WHEN DIETA1 NOT LIKE '%JEJUM%' AND DIETA2  LIKE '%JEJUM%'    AND PRESC1 <> PRESC2 AND dh_cancelado IS NULL THEN  DIETA2
       ELSE 'DIETA_NOVA' END STATUS
       ,cd_atendimento
       ,DIETA1
       ,DIETA2
FROM( 
SELECT  pre.cd_atendimento 
        ,Min   (ds_tip_presc) DIETA1       
        ,Max  (ds_tip_presc) DIETA2   
        ,MIN (pre.cd_pre_med) PRESC1
        ,Max (pre.cd_pre_med) PRESC2
        ,dh_cancelado
 FROM 
  pre_med pre,                                                                         
  itpre_med med,                            
  tip_presc tp

 where med.cd_tip_presc = tp.cd_tip_presc                          
   and pre.cd_pre_med = med.cd_pre_med
   and med.cd_tip_esq in ('DIE')                    
   AND pre.dt_referencia >= Trunc (SYSDATE )
   AND trunc (pre.dt_referencia) BETWEEN (SYSDATE) -1 AND trunc(SYSDATE) -- andra inseri mascara de data
   and pre.fl_impresso = 'S'                             
   AND dh_cancelado IS NULL
GROUP BY   pre.cd_atendimento
          ,dh_cancelado) 

) status,     
-----------------------------TABELAS---------------------------------------------
 
                               ITPRE_MED MED,                            
                               TIP_PRESC TP,
                               ATENDIME,
                               LEITO,
                               PACIENTE


 where med.cd_tip_presc = tp.cd_tip_presc                          
   AND pre.cd_pre_med = med.cd_pre_med
   AND pre.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO            
   AND ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE
   AND ATENDIME.CD_LEITO = LEITO.CD_LEITO  
   AND ATENDIME.CD_ATENDIMENTO = status.CD_ATENDIMENTO ---
   AND med.cd_tip_esq in ('DIE')
   AND ds_tip_presc LIKE '%JEJUM%' 
   AND trunc (pre.dh_criacao) BETWEEN (SYSDATE) -1 AND trunc(SYSDATE) -- andra inseri mascara de data
  -- AND MED.SN_CANCELADO = 'N'
   AND pre.fl_impresso = 'S'                                  
   AND dh_cancelado IS NULL                         
   AND DT_ALTA IS NULL

                                       
GROUP BY  pre.cd_atendimento 
         ,DH_CRIACAO
         ,DT_NASCIMENTO
         ,DS_RESUMO                    
         ,NM_PACIENTE
         ,status.status

        
 
ORDER BY 1
 )WHERE status LIKE '%JEJUM%'
GROUP BY cd_atendimento                    
               ,NM_PACIENTE                   
               ,DT_NASCIMENTO
               ,DS_RESUMO                  
               --,DIETA1
               ,HORAS_PRESC_ABERTO 
               ,DH_CRIACAO
               ,status

ORDER BY 2 