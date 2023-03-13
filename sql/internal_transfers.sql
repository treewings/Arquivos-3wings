-- TRANSFERENCIAS INTERNAS - SND (Andra)
--tp_mov = 'A - Acompanhante, F - Infecc?o, I - Internac?o, L - Limpeza, M - Manutenc?o, O - Transferencia, R - Reserva, C - Interditado por infecc?o, T - interditado por isolamento'

SELECT 
  A.CD_ATENDIMENTO                                                                   
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
 ,L2.DS_LEITO LEITO_ANTERIOR
 ,L.DS_LEITO 
            

 FROM  ATENDIME A
      ,LEITO  L
      ,PACIENTE P
      ,MOV_INT M
      ,LEITO L2           
WHERE A.CD_ATENDIMENTO = M.CD_ATENDIMENTO
  AND M.CD_LEITO = L.CD_LEITO
  AND M.CD_LEITO_ANTERIOR = L2.CD_LEITO (+)
  AND A.CD_PACIENTE = P.CD_PACIENTE
  AND A.TP_ATENDIMENTO = 'I'
  AND M.TP_MOV = 'O' -- TRANSFERENCIA DE LEITOS
  AND To_date(a.hr_atendimento,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi') AND To_Date (SYSDATE,'dd/mm/yyyy')   

 
