------ Pacientes sem emissão de documentos de recociliação  a mais de 24hrs 
--patients_without_issuance_of_reconciliation
 SELECT * FROM (
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
 ,SUBSTR( (CAST(a.hr_atendimento  AS TIMESTAMP) - CAST( SYSDATE AS TIMESTAMP) ),12,8 ) TEMPO
   
    
      FROM DBAMV.ATENDIME A,
           DBAMV.PACIENTE P,
           DBAMV.LEITO L

 WHERE A.CD_PACIENTE = P.CD_PACIENTE
   AND A.CD_LEITO   = L.CD_LEITO  
   AND a.tp_atendimento = 'I'
   AND a.dt_alta IS NULL 
  -- AND To_date(a.hr_atendimento,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi') AND To_Date (SYSDATE,'dd/mm/yyyy')  
  
  AND NOT  EXISTS (
  SELECT 1         
                    FROM DBAMV.ATENDIME At,  
                         DBAMV.PW_DOCUMENTO_CLINICO DC,
                         DBAMV.PW_EDITOR_CLINICO EC  

                  WHERE  At.CD_ATENDIMENTO = DC.CD_ATENDIMENTO 
                    AND DC.CD_DOCUMENTO_CLINICO = EC.CD_DOCUMENTO_CLINICO 
                    AND At.TP_ATENDIMENTO = 'I'
                    AND DC.TP_STATUS 		IN ('FECHADO', 'ASSINADO')  
                    AND EC.CD_DOCUMENTO IN (143, 100)--RECONCILIACAO (100 - EVOLUÇÃO FARMACIA)
                    AND AT.cd_atendimento = A.CD_ATENDIMENTO 
                    AND DC.DH_CRIACAO BETWEEN SYSDATE -1 AND sysdate                      
)
 ) WHERE TEMPO >= '24:00:00'