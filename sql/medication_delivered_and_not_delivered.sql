--medication_delivered_and_not_delivered -- grafico de linhas 
-- grafico de linhas -- ANDRA   atualizado em 11/10/22

SELECT HORARIO status
     -- ,hr_sol_am
      ,Nvl (To_Char (hr_entrega, 'hh:mi'),To_Char (hr_solicitado,'hh:mi')) hora_entrega
      ,Sum (solicitacao)total
    
from (  

select solicitacao
     , cd_atendimento
     , cd_pre_med
     , hr_solicitado
     , hr_sol_am
     , hr_recebido
     , hr_rec_am
     , cd_turno
     , DS_TURNO
     , hr_inicial
     , hr_entrega
     ,(case when (hr_solicitado < hr_recebido) and hr_rec_am > hr_inicial then 'NAO ENTREGUE' ELSE 'ENTREGUE'end)HORARIO
from (
select 
       Count (s.cd_solsai_pro)solicitacao
      ,s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro as hr_solicitado
      ,to_char(s.hr_solsai_pro,'hh:mi am') as hr_sol_am
      ,e.hr_entrega	as hr_recebido
      ,to_char(e.hr_entrega,'hh:mi am') as hr_rec_am
      ,e.hr_entrega
      ,s.cd_turno
      ,T.DS_TURNO
      ,to_char(t.hr_inicial,'hh:mi am') hr_inicial

from solsai_pro s										   
   -- ,itsolsai_pro i
    ,mvto_estoque e
    ,turno_setor t
where --s.cd_solsai_pro = i.cd_solsai_pro
      s.cd_solsai_pro = e.cd_solsai_pro
  and s.cd_turno = t.cd_turno
  and e.cd_estoque = 2 -- Farmacia Central  
  and s.cd_pre_med is not null
  and s.tp_situacao in ('S','C') --- 'S' = Confirmados, 'C' = Parcialmente Atendido
  AND s.TP_SOLSAI_PRO  IN ('P') -- PEDIDO PACIENTE                                       
  --AND e.hr_entrega IS NOT NULL  --hr_entrega = Hora do recebimento  
  and trunc(s.hr_solsai_pro)BETWEEN trunc (SYSDATE)  AND trunc (SYSDATE)-- >= trunc(SYSDATE )
GROUP BY 
  s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro 
      ,s.hr_solsai_pro
      ,e.hr_entrega
      ,s.cd_turno
      ,DS_TURNO
      ,hr_inicial
      ) 
 
) 
group BY  hr_solicitado
         ,hr_entrega
         ,hr_sol_am
         ,HORARIO
ORDER BY 2                    
 