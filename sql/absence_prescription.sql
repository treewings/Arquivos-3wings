-- AUSENCIA DE PRESCRIÇAO NO PS - SND (Andra)
SELECT CD_ATENDIMENTO
      ,NOME_PACIENTE
      ,DT_NASCIMENTO
      ,DS_RESUMO
      ,TO_CHAR(TRUNC((HORAS_ABERTO_MINUTO * 60) / 3600), 'FM9900') || ':' ||
       TO_CHAR(TRUNC(MOD((HORAS_ABERTO_MINUTO * 60), 3600) / 60), 'FM00') || ':' ||
       TO_CHAR(MOD((HORAS_ABERTO_MINUTO * 60), 60), 'FM00') horas_minutos 

FROM (
 
SELECT  DISTINCT A.CD_ATENDIMENTO
       ,Case when SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) || ')'

                  when SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) || ')'  

                else SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(P.NM_PACIENTE) ||')' END NOME_PACIENTE
      ,To_Char (p.dt_nascimento , 'dd/mm/yyyy') DT_NASCIMENTO
      ,L.DS_RESUMO
      ,(SYSDATE - HR_ATENDIMENTO )*24*60 HORAS_ABERTO_MINUTO

   FROM LEITO L                                               
     ,ATENDIME A
     ,PACIENTE P
     ,PRE_MED PR
     ,ITPRE_MED I            

 WHERE A.CD_PACIENTE = P.CD_PACIENTE
   AND A.CD_ATENDIMENTO = PR.CD_ATENDIMENTO(+)
   AND PR.CD_PRE_MED = I.CD_PRE_MED
   AND L.CD_LEITO = A.CD_LEITO
   AND L.TP_OCUPACAO IN ('O','I')     
   AND To_date(dt_atendimento,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi') AND To_Date (SYSDATE,'dd/mm/yyyy') 
   AND A.DT_ALTA IS NULL 
   AND NOT EXISTS 
    (select tp.ds_tip_presc
  from pre_med pre, 
  itpre_med med,                         
   tip_presc tp
 where med.cd_tip_presc = tp.cd_tip_presc                          
   and pre.cd_pre_med = med.cd_pre_med
   and med.cd_tip_esq in ('DIE', 'DIP', 'DIV')                
   AND pre.dt_referencia  BETWEEN sysdate-1 AND SYSDATE
   and pre.fl_impresso = 'S'        
   AND cd_atendimento = a.cd_atendimento )
 )  
ORDER BY horas_minutos DESC 