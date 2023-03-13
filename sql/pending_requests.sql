--////////////////////////////////////////////////////////////////////////////
  --Query Consumo - Solicitações                                            --
  --Autor: Adiel Junior                                                     --
  --Data: 04/08/2022                                                        --
--////////////////////////////////////////////////////////////////////////////
---------------------------------------
SELECT
       SOLIC
      ,SETOR
      ,SITUACAO
      ,SubStr(ITENS,1,4000) ITENS
FROM
(
SELECT
     SOLSAI_PRO.CD_SOLSAI_PRO SOLIC
    ,ESTOQUE.DS_ESTOQUE        SETOR
    ,Decode(SOLSAI_PRO.TP_SITUACAO,'C','PENDENTE','P','PENDENTE') SITUACAO 
    ,LISTAGG(SubStr(PRODUTO.DS_PRODUTO,0,20)||Chr(10)) WITHIN GROUP(ORDER BY SOLSAI_PRO.CD_SOLSAI_PRO,DS_ESTOQUE) ITENS
    
FROM 
    DBAMV.SOLSAI_PRO
   ,DBAMV.SETOR
   ,DBAMV.ESTOQUE
   ,DBAMV.ITSOLSAI_PRO
   ,DBAMV.PRODUTO 
WHERE
    SOLSAI_PRO.CD_SOLSAI_PRO = ITSOLSAI_PRO.CD_SOLSAI_PRO
AND SOLSAI_PRO.CD_SETOR      = SETOR.CD_SETOR
AND SOLSAI_PRO.CD_ESTOQUE_SOLICITANTE    = ESTOQUE.CD_ESTOQUE
AND ITSOLSAI_PRO.CD_PRODUTO  = PRODUTO.CD_PRODUTO
AND SOLSAI_PRO.TP_SOLSAI_PRO = 'E'
AND SOLSAI_PRO.TP_SITUACAO IN ('C','P')
AND SOLSAI_PRO.CD_ESTOQUE    = 1
AND ITSOLSAI_PRO.sn_conf_determ_usu = 'N'
AND SOLSAI_PRO.DT_SOLSAI_PRO >= SYSDATE-7
GROUP BY SOLSAI_PRO.CD_SOLSAI_PRO, ESTOQUE.DS_ESTOQUE,SOLSAI_PRO.TP_SITUACAO
ORDER BY 1 DESC
)