--Medication_not_delivered_on_time.sql
-- alterado de itens para solicitações
-- atualizado em 11/10/22 andra
SELECT NAO_ENTREGUE.NAO_ENTREGUE
     , ENTREGUE.ENTREGUE
     ,(NAO_ENTREGUE.NAO_ENTREGUE + ENTREGUE.ENTREGUE) AS TOTAL
FROM (
select NVL(sum (total),0) NAO_ENTREGUE

from (
select hr_solicitado
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
     ,(case when (hr_solicitado < hr_recebido) and hr_rec_am > hr_inicial then 'NAO ENTREGUE' ELSE 'ENTREGUE'end) HORARIO
from (
select 
       Count (s.cd_solsai_pro)solicitacao
      ,s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro as hr_solicitado
      ,to_char(s.hr_solsai_pro,'hh:mi am') as hr_sol_am
      ,e.hr_entrega	as hr_recebido
      ,to_char(e.hr_entrega,'hh:mi am') as hr_rec_am
      ,s.cd_turno
      ,T.DS_TURNO
      ,to_char(t.hr_inicial,'hh:mi am') hr_inicial

from solsai_pro s										   
    ,mvto_estoque e
    ,turno_setor t
where s.cd_solsai_pro = e.cd_solsai_pro
  and s.cd_turno = t.cd_turno
  and e.cd_estoque = 2 -- Farmacia Central  
  and s.cd_pre_med is not null
  and s.tp_situacao in ('S','C') --- 'S' = Confirmados, 'C' = Parcialmente Atendido
  AND s.TP_SOLSAI_PRO  IN ('P') -- PEDIDO PACIENTE 
  AND S.tp_situacao NOT IN ('A') -- CANCELADA
                                     
  and trunc(S.hr_solsai_pro)BETWEEN trunc (SYSDATE)  AND trunc (SYSDATE)-- >= trunc(SYSDATE )
GROUP BY 
  s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro 
      ,s.hr_solsai_pro
      ,e.hr_entrega
      ,e.hr_entrega
      ,s.cd_turno
      ,DS_TURNO
      ,hr_inicial) 
 
) where HORARIO like 'NAO ENTREGUE'  
group by hr_solicitado
)
)NAO_ENTREGUE,
-------------------- ENTREGUE ABAIXO ----------------
(select NVL(sum (total),0) ENTREGUE
from (
select hr_solicitado
      ,Sum (solicitacao)total

from (
select 
       solicitacao 
     , cd_atendimento
     , cd_pre_med
     , hr_solicitado
     , hr_sol_am
     , hr_recebido
     , hr_rec_am
     , cd_turno
     , DS_TURNO
     , hr_inicial
     ,(case when (hr_solicitado < hr_recebido) and hr_rec_am > hr_inicial then 'NAO ENTREGUE' ELSE 'ENTREGUE'end) HORARIO
from (
select 
       Count (s.cd_solsai_pro)solicitacao 
      ,s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro as hr_solicitado
      ,to_char(s.hr_solsai_pro,'hh:mi am') as hr_sol_am
      ,e.hr_entrega	as hr_recebido
      ,to_char(e.hr_entrega,'hh:mi am') as hr_rec_am
      ,s.cd_turno
      ,T.DS_TURNO
      ,to_char(t.hr_inicial,'hh:mi am') hr_inicial

from solsai_pro s										   
    ,mvto_estoque e
    ,turno_setor t
where s.cd_solsai_pro = e.cd_solsai_pro
  and s.cd_turno = t.cd_turno
  and e.cd_estoque = 2 -- Farmacia Central  
  and s.cd_pre_med is not null
  and s.tp_situacao in ('C','S') --- 'S' = Confirmados, 'C' = Parcialmente Atendido
  AND s.TP_SOLSAI_PRO  IN ('P') -- PEDIDO PACIENTE                                       
  AND S.tp_situacao NOT IN ('A') -- CANCELADA
  and trunc(S.hr_solsai_pro)BETWEEN trunc (SYSDATE)  AND trunc (SYSDATE)-- >= trunc(sysdate)

 GROUP BY 
       s.cd_atendimento
      ,s.cd_pre_med
      ,s.hr_solsai_pro 
      ,s.hr_solsai_pro
      ,e.hr_entrega
      ,e.hr_entrega
      ,s.cd_turno
      ,DS_TURNO
      ,hr_inicial  )
 
) where HORARIO like 'ENTREGUE'  
group by hr_solicitado
)
)ENTREGUE
ORDER BY 3

