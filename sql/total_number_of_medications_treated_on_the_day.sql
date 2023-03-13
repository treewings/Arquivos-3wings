 -- total de solicitações atendidos no dia (andra)
 -- retirado o filtro de urgente a pedido do cliente - 29/07/22 - andra
SELECT Sum (qt_atendida_dia)qt_atendida_dia
       ,dt_solsai_pro
FROM(
SELECT Count (CD_SOLSAI_PRO) qt_atendida_dia
       ,dt_solsai_pro
FROM (
SELECT  s.DT_solsai_pro
       ,s.CD_SOLSAI_PRO
FROM  ATENDIME  A
     ,SOLSAI_PRO S
     ,ITSOLSAI_PRO I
     ,MVTO_ESTOQUE E

WHERE A.CD_ATENDIMENTO = S.CD_ATENDIMENTO
  AND S.CD_SOLSAI_PRO = I.CD_SOLSAI_PRO
  AND s.CD_SOLSAI_PRO = E.cd_solsai_pro(+)
  AND e.cd_estoque = 2 -- farmacia central 
  AND S.tp_situacao IN ('C','S') -- C- PARCIAL ATENDIDO S- ATENDIDO 
  AND S.tp_situacao NOT IN ('A') -- CANCELADA
  AND s.TP_SOLSAI_PRO  IN ('P') -- PEDIDO PACIENTE                                       
  AND Trunc (S.DT_solsai_pro) between Trunc (SYSDATE -1) AND Trunc (SYSDATE)

GROUP BY  
        s.DT_solsai_pro
       ,s.CD_SOLSAI_PRO
) GROUP BY  dt_solsai_pro
  ORDER BY 2   DESC)
  GROUP BY dt_solsai_pro