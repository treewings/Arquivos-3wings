-- total de solicitações avulsas atendidas (Mais de uma hora e no horario)
--Total_single_request_central_pharmacy.sql
-- (IVALDO /ANDRA) 09/09/22 --atualizado 11/10/22
-- atualizado filtro de data
SELECT
  Sum(Nvl(TEMP1,0)) AS foradohorario
  ,Sum(Nvl(tempo2,0)) AS dentrodohorario

  FROM (
 SELECT

                  (CASE WHEN tp_situacao in ('P','S','C')  AND TEMPO  >  '01:00:00' THEN 1
                          WHEN tp_situacao = 'C'  AND TEMPO  >= '01:00:00' THEN 1
                            END) AS TEMP1
                  ,TEMPO
                  ,Count((CASE WHEN tp_situacao in ('P','S','C')  AND TEMPO  <  '01:00:00' THEN 1
                          WHEN tp_situacao = 'C'  AND TEMPO  < '01:00:00' THEN 1
                            END)) AS tempo2

                FROM (
                                                                                                      
  SELECT
            distinct solsai_pro.cd_solsai_pro
                    ,atendime.cd_atendimento
                    ,atendime.dt_atendimento
                    ,leito.ds_leito
                    ,paciente.Nm_Paciente
                    ,paciente.dt_nascimento
                    ,SOLSAI_PRO.HR_SOLSAI_PRO
                    ,SOLSAI_PRO.DT_SOLSAI_PRO
                     ,CASE 
                      WHEN Nvl((SELECT Min(hr_mvto_estoque) as hr_mvto_estoque  FROM mvto_estoque WHERE cd_solsai_pro = solsai_pro.cd_solsai_pro ),SYSDATE) >  SOLSAI_PRO.HR_SOLSAI_PRO THEN 
                       (SUBSTR( (CAST(SOLSAI_PRO.HR_SOLSAI_PRO AS TIMESTAMP) - CAST(Nvl((SELECT Min(hr_mvto_estoque) as hr_mvto_estoque  FROM mvto_estoque WHERE cd_solsai_pro = solsai_pro.cd_solsai_pro ),SYSDATE)  AS TIMESTAMP) ),12,8 ) )
                       ELSE '00:00:00' END AS TEMPO

                    ,SOLSAI_PRO.TP_SITUACAO

                  FROM  SOLSAI_PRO, atendime, paciente , leito, mvto_estoque
                    WHERE SOLSAI_PRO.cd_atendimento = atendime.cd_atendimento  
                    --  AND To_date(SOLSAI_PRO.hr_solsai_pro,'dd/mm/yyyy hh24:mi:ss') BETWEEN To_Date (SYSDATE,'dd/mm/yyyy hh24:mi:ss')  AND SYSDATE
                    AND Trunc (SOLSAI_PRO.hr_solsai_pro) between Trunc (SYSDATE) AND Trunc (SYSDATE)    
                  --  AND Trunc (SOLSAI_PRO.DT_solsai_pro) between Trunc (SYSDATE) AND Trunc (SYSDATE)
                    AND atendime.cd_paciente = paciente.cd_paciente
                    AND atendime.cd_leito = leito.cd_leito
                    AND solsai_pro.cd_solsai_pro = mvto_estoque.cd_solsai_pro(+)
                    AND solsai_pro.dt_solsai_pro = mvto_estoque.dt_mvto_estoque (+) 
                    AND SOLSAI_PRO.sn_urgente in ('N')
                    AND solsai_pro.TP_SOLSAI_PRO = 'P'
                    AND SOLSAI_PRO.cd_estoque = 2
                    AND SOLSAI_PRO.tp_situacao IN ('C','S') -- retirei o tipo P 28/09/22
                    AND SOLSAI_PRO.tp_situacao NOT IN ('A') -- CANCELADA
                    AND SOLSAI_PRO.cd_pre_med IS NULL 
                    )
                    GROUP BY
                     tp_situacao
                     ,TEMPO )