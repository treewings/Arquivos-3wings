-- Sinalização de alta hospitalar convenio / particular (andra)
---------------------CONVENIO -----------------------------------------
SELECT
  'CONVENIO' TIPO 
 ,A.CD_ATENDIMENTO 
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
             --,a.hr_alta
            -- ,c.tp_convenio  

 FROM  ATENDIME A
      ,LEITO  L
      ,PACIENTE P 
      ,CONVENIO C
                
WHERE a.CD_LEITO = L.CD_LEITO
  AND A.CD_PACIENTE = P.CD_PACIENTE
  AND A.CD_CONVENIO = C.CD_CONVENIO
  AND A.TP_ATENDIMENTO = 'I'
  AND C.TP_CONVENIO = 'C'
  AND To_date(a.hr_alta,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi') AND To_Date (SYSDATE,'dd/mm/yyyy')   
 --ORDER BY a.hr_atendimento desc

UNION ALL

---------------------------- PARTICULAR --------------------------------------------
-- Sinalização de alta hospitalar convenio / particular (andra)
SELECT
  'PARTICULAR' TIPO 
 ,A.CD_ATENDIMENTO 
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
             --,a.hr_alta
            -- ,c.tp_convenio  

 FROM  ATENDIME A
      ,LEITO  L
      ,PACIENTE P 
      ,CONVENIO C
                
WHERE a.CD_LEITO = L.CD_LEITO
  AND A.CD_PACIENTE = P.CD_PACIENTE
  AND A.CD_CONVENIO = C.CD_CONVENIO
  AND A.TP_ATENDIMENTO = 'I'
  AND C.TP_CONVENIO = 'P'
  AND To_date(a.hr_alta,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi')  AND To_Date (SYSDATE,'dd/mm/yyyy')   
-- ORDER BY a.hr_atendimento desc
