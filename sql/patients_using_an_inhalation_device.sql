-- Paciente em uso de dispositivo inalatório (Andra)

/* dispositivo inalatório: Flixotide 250mcg (4810), Flixotide 50mcg (304), Seretide (5578), Symbicort 6/100mcg (8696), Symbicort 6/200mcg (8717) e Spiriva (8798).
Precisamos apenas da sinalização do nome do paciente e leito com inclusão na prescrição de um desses itens (apenas o 1 dia). */
   
SELECT DISTINCT
  A.CD_ATENDIMENTO 
 ,To_Char (A.DT_ATENDIMENTO ,'DD/MM/YYYY') DT_ATENDIMENTO
 ,a.hr_atendimento 
 ,L.DS_LEITO 
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
                 
             ,To_Char (dt_nascimento , 'dd/mm/yyyy') dt_nascimento  
            -- ,dt_pre_med
            -- ,ds_tip_presc
          -- ,IT.SN_CANCELADO
             
FROM   ATENDIME A
      ,LEITO  L
      ,PACIENTE P 
      ,PRE_MED PR
      ,ITPRE_MED IT
      ,TIP_PRESC TIP
      
                
WHERE a.CD_LEITO = L.CD_LEITO
  AND A.CD_PACIENTE = P.CD_PACIENTE
  AND A.CD_ATENDIMENTO = PR.CD_ATENDIMENTO
  AND PR.CD_PRE_MED = IT.CD_PRE_MED
  AND IT.CD_TIP_PRESC = TIP.CD_TIP_PRESC
  AND A.TP_ATENDIMENTO = 'I'  
  AND NOT NVL(IT.SN_CANCELADO,'N')  IN ('S') -- TRAZER NULLOS E 'N'
  AND TIP.CD_TIP_PRESC IN (4810, 304, 5578, 8696, 8717, 8798 )
  AND To_date(pr.hr_pre_med,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi') AND To_Date (SYSDATE,'dd/mm/yyyy')
