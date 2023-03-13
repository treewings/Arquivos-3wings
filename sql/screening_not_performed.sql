-- pacientes sem documento de triagem internados a mais de 12 horas (andra)
SELECT CD_ATENDIMENTO
      ,Nome_Paciente
      ,dt_nascimento
      ,ds_resumo
      ,tempo      
FROM (
SELECT DISTINCT 
  Ate.CD_ATENDIMENTO                                                                 
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
 ,l.ds_resumo      
 ,ate.hr_atendimento
 ,Substr(( Cast(ate.hr_atendimento AS TIMESTAMP) - Cast ( SYSDATE AS TIMESTAMP) ), 12, 8 )   TEMPO
 --,Pec.cd_documento
-- ,tp_status                               

 FROM   Dbamv.Atendime              Ate   
       ,Dbamv.Paciente               Pac 
       ,dbamv.leito                  l        
    
  WHERE Ate.cd_leito = l.cd_leito            
    AND Ate.Cd_Paciente = Pac.Cd_Paciente  
    AND ate.tp_atendimento = 'I'
    AND ate.dt_alta IS NULL                                            
    AND TRUNC(ate.hr_atendimento) BETWEEN (SYSDATE) -1  AND   SYSDATE
     AND NOT EXISTS
             (SELECT DISTINCT V.CD_ATENDIMENTO
              FROM DBAMV.VDIC_RESPOSTA_DOCUMENTO_TASCOM V ,
                   ATENDIME
              WHERE V.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
                AND TP_STATUS IN ('FECHADO',
                                  'ASSINADO')
                AND V.CD_DOCUMENTO IN (69) -- DOC ANTROPOMÉTRICA

                AND ATENDIME.DT_ALTA IS NULL
                AND ATENDIME.TP_ATENDIMENTO = 'I'
                AND TRUNC(v.hr_atendimento) BETWEEN (SYSDATE) -1  AND   SYSDATE
                AND V.CD_ATENDIMENTO = ate.cd_atendimento )   
ORDER BY  hr_atendimento
) WHERE tempo >= '12:00:00'                                                  
ORDER BY tempo DESC 