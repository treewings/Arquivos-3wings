-- query para listar alerta de mudança de dieta (ANDRA)

SELECT cd_atendimento
      ,Nome_Paciente
      ,dt_nascimento
      ,ds_resumo
      ,DIETA1 
      ,STATUS  
      ,DIETA2
 
FROM (
SELECT DISTINCT a.cd_atendimento
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
      ,ds_resumo
      ,muda_dieta.DIETA1
      ,muda_dieta.DIETA2
      ,muda_dieta.PRESC1
      ,muda_dieta.NOVA_DIETA
      ,muda_dieta.PRESC2 
      ,CASE WHEN DIETA2 <> DIETA1 THEN 'MUDA DIETA' ELSE DIETA1 END status      

 FROM 
  pre_med pre, 
  itpre_med IT,                            
  tip_presc tp,
  leito l,
  atendime a,
  paciente p,
  -------------------------------------------------
   
(SELECT cd_atendimento
       ,DIETA1
       ,PRESC1
       ,DIETA2
       ,PRESC2
       ,CASE WHEN PRESC1 <>  PRESC2 THEN DIETA2 ELSE 'NAO TEM NOVA' END NOVA_DIETA
       
FROM (
SELECT  pre.cd_atendimento
        ,Max (ds_tip_presc) DIETA1 
        ,Min  (ds_tip_presc) DIETA2 
        ,Max (pre.cd_pre_med) PRESC1
        ,MIN (pre.cd_pre_med) PRESC2

 FROM 
  pre_med pre, 
  itpre_med med,                            
  tip_presc tp

 where med.cd_tip_presc = tp.cd_tip_presc                          
   and pre.cd_pre_med = med.cd_pre_med
   and med.cd_tip_esq in ('DIE')                
   AND pre.dt_referencia >= Trunc (SYSDATE )
   and pre.fl_impresso = 'S'                                  
   AND dh_cancelado IS NULL                   
GROUP BY  pre.cd_atendimento
 
ORDER BY 1
 ) )MUDA_DIETA

  -------------------------------------------------

 where IT.cd_tip_presc = tp.cd_tip_presc                          
   and pre.cd_pre_med = IT.cd_pre_med
   AND pre.cd_atendimento = a.cd_atendimento
   AND a.cd_leito = l.cd_leito
   AND a.cd_paciente = p.cd_paciente
   AND a.cd_atendimento = muda_dieta.cd_atendimento 
   and IT.cd_tip_esq in ('DIE')                
   AND pre.dt_referencia >= Trunc (SYSDATE )
   and pre.fl_impresso = 'S'                                  
   AND dh_cancelado IS NULL           
   AND muda_dieta.nova_dieta NOT IN ('NAO TEM NOVA')
) WHERE STATUS = 'MUDA DIETA'
