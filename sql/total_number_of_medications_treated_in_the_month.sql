-- total de solicitações atendidos mes (andra)
-- inserido filtro estoque 2 farmacia central
SELECT 
      'MES ATUAL' TIPO
      ,Sum ( qt_atendida) qtd_mes_atual
FROM (
SELECT   s.dt_solsai_pro
        ,Count (s.CD_SOLSAI_PRO ) qt_atendida  
         FROM  ATENDIME  A
              ,SOLSAI_PRO S
              ,ITSOLSAI_PRO I
              ,MVTO_ESTOQUE E

          WHERE A.CD_ATENDIMENTO = S.CD_ATENDIMENTO
            AND S.CD_SOLSAI_PRO = I.CD_SOLSAI_PRO
            AND s.CD_SOLSAI_PRO = E.cd_solsai_pro(+)
            AND e.cd_estoque = 2 -- estoque farmacia central
            AND S.tp_situacao IN ('C','S') -- C- PARCIAL ATENDIDO S- ATENDIDO             
            AND s.TP_SOLSAI_PRO  IN ('P') -- PEDIDO PACIENTE                                       
            AND trunc(S.dt_solsai_pro) between  trunc(sysdate,'MM') and trunc(sysdate)

GROUP BY  s.dt_solsai_pro
 ORDER BY dt_solsai_pro
 )

 UNION ALL 

SELECT 'MES ANTERIOR' TIPO
        ,Sum ( qt_atendida) qtd_mes_anterior
FROM (
SELECT   s.dt_solsai_pro
        ,Count (s.CD_SOLSAI_PRO ) qt_atendida  
         FROM  ATENDIME  A
              ,SOLSAI_PRO S
              ,ITSOLSAI_PRO I
              ,MVTO_ESTOQUE E

          WHERE A.CD_ATENDIMENTO = S.CD_ATENDIMENTO
            AND S.CD_SOLSAI_PRO = I.CD_SOLSAI_PRO
            AND s.CD_SOLSAI_PRO = E.cd_solsai_pro(+)
            AND e.cd_estoque = 2 -- estoque farmacia central
            AND S.tp_situacao IN ('C','S') -- C- PARCIAL ATENDIDO S- ATENDIDO             
            AND trunc(S.dt_solsai_pro) between  trunc(sysdate,'MM')-30 and trunc(SYSDATE,'MM')-1

GROUP BY  s.dt_solsai_pro
 ORDER BY dt_solsai_pro
)