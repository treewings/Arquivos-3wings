-- PACIENTES COM ALERGIA - SND (Andra)
-- se o paciente tiver cadastrado varios tipos de alergia irão aparecer varios tipos de alergia. 
SELECT DISTINCT  
  A.CD_ATENDIMENTO 
 ,L.DS_RESUMO                                                                
 ,Case when SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) || ')'

                  when SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(p.NM_PACIENTE) || ')'       

                else SUBSTR(p.NM_PACIENTE, 1 , (INSTR(p.NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(p.NM_PACIENTE) ||')' end Nome_Paciente
 ,To_Char (p.dt_nascimento , 'dd/mm/yyyy') dt_nascimento  
 ,alergia.ds_alergia
        
 FROM  (SELECT cd_paciente 
             ,ds_alergia
             ,tp_severidade                 
             ,ds_aviso                 
      FROM DBAMV.HIST_SUBS_PAC 
          ,dbamv.substancia
      WHERE HIST_SUBS_PAC.cd_substancia = substancia.cd_substancia (+)
        AND TP_ALERGIA = 'A' -- ALIMENTO 
        AND SN_ATIVO = 'S' --ATIVO

      )ALERGIA
      ,ATENDIME A
      ,PACIENTE P 
      ,LEITO L                
WHERE A.CD_PACIENTE = P.CD_PACIENTE
  AND A.CD_LEITO = L.CD_LEITO         
  AND alergia.cd_paciente = p.cd_paciente  
 -- AND A.TP_ATENDIMENTO = 'I' 
  AND A.DT_ALTA IS NULL  
 -- AND To_date(dt_atendimento,'dd/mm/yyyy hh24:mi') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi')-1 AND To_Date (SYSDATE,'dd/mm/yyyy')   
  GROUP BY A.CD_ATENDIMENTO
          ,p.NM_PACIENTE          
          ,p.dt_nascimento   
          ,alergia.ds_alergia
          ,A.DT_ATENDIMENTO
          ,P.CD_PACIENTE
          ,L.DS_RESUMO

 ORDER BY 1   