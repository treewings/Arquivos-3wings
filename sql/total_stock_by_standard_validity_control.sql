-- TOTAL ESTOQUE por controle de validade (30 -60 e 90 DIAS) - PADRÃO 
-- total_stock_by_standard_validity_control.sql
-- CRITICO - 0-10
-- ATENCAO - 10.01-20
-- ABASTECIDO- 20.01-40
-- EXCESSO - >40.01

SELECT  Round (Sum (VALOR_ESTOQUE),2) VALOR_ESTOQUE,  
        CD_ESTOQUE     
FROM (
SELECT  CD_PRODUTO,
        DS_PRODUTO, 
        CASE WHEN (dias_venc) BETWEEN 0  AND  30 THEN '1- VERMELHO'
             WHEN (dias_venc) BETWEEN 31 AND  60 THEN '2- AMARELO'
             WHEN (dias_venc) BETWEEN 61 AND  90 THEN '3- VERDE'
             ELSE '4- OUTROS' END COR,  
        QTD_LOTE,                                 
        CD_ESTOQUE,
        dias_venc,
        (VL_TOTAL_PRODUTO * QTD_LOTE )VALOR_ESTOQUE
FROM ( 
SELECT         
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,
       QT_ESTOQUE_ATUAL,
       QTD_LOTE, 
       dias_venc,                 

       DBAMV.VERIF_VL_CUSTO_MEDIO(CD_PRODUTO, Trunc(SysDate), 'H',VL_CUSTO_MEDIO, SYSDATE,1) As VL_TOTAL_PRODUTO
      
FROM ( SELECT 
       PRODUTO.DS_PRODUTO DS_PRODUTO,
       PRODUTO.CD_PRODUTO CD_PRODUTO,
       PRODUTO.SN_MESTRE  SN_MESTRE,
       ESTOQUE.cd_estoque,
       PRODUTO.VL_CUSTO_MEDIO,                   
       EST_PRO.QT_ESTOQUE_ATUAL ,    
       Sum (LOT_PRO.qt_estoque_atual)QTD_LOTE, --OVER(PARTITION BY LOT_PRO.DT_VALIDADE) QTD_LOTE,
       Round ((LOT_PRO.DT_VALIDADE - SYSDATE ),0) dias_venc    
 FROM         
      DBAMV.PRODUTO,
      DBAMV.SUB_CLAS,
      DBAMV.EMPRESA_PRODUTO,  
      DBAMV.EST_PRO,
      DBAMV.ESTOQUE, --
      DBAMV.LOT_PRO --

WHERE PRODUTO.CD_SUB_CLA = SUB_CLAS.CD_SUB_CLA
  AND EMPRESA_PRODUTO.CD_PRODUTO = PRODUTO.CD_PRODUTO                  
  AND PRODUTO.TP_ATIVO = 'S'
  AND PRODUTO.CD_CLASSE = SUB_CLAS.CD_CLASSE
  AND PRODUTO.CD_ESPECIE = SUB_CLAS.CD_ESPECIE   
  AND EST_PRO.CD_PRODUTO = PRODUTO.CD_PRODUTO 
  AND EST_PRO.CD_ESTOQUE = ESTOQUE.CD_ESTOQUE --
  AND lot_pro.cd_produto = EST_PRO.cd_produto  --
  AND lot_pro.CD_ESTOQUE = EST_PRO.CD_ESTOQUE --        
  AND PRODUTO.SN_PADRONIZADO = 'S' -- PRODUTO PADRÃO 
  AND PRODUTO.SN_MESTRE =  'N'
  AND EMPRESA_PRODUTO.CD_MULTI_EMPRESA =1 
  AND EST_PRO.QT_ESTOQUE_ATUAL > 0
  AND LOT_PRO.qt_estoque_atual > 0
  AND estoque.cd_multi_empresa = 1
  AND ESTOQUE.CD_ESTOQUE IN (1,3,4,14, 34,66,78) -- estoques informados pelo cliente  
  AND PRODUTO.CD_ESPECIE IN (1,2) -- MATERIAL E MEDICACAO
  AND LOT_PRO.DT_VALIDADE >= SYSDATE   
    
GROUP BY PRODUTO.DS_PRODUTO,
         PRODUTO.CD_PRODUTO,
         PRODUTO.SN_MESTRE,
         PRODUTO.VL_CUSTO_MEDIO,
         EST_PRO.QT_ESTOQUE_ATUAL,
         LOT_PRO.DT_VALIDADE,
         ESTOQUE.cd_estoque,
         LOT_PRO.qt_estoque_atual
                         
) GROUP BY ds_produto
         , cd_produto
         , SN_MESTRE
         , cd_estoque
         , dias_venc 
         , VL_CUSTO_MEDIO 
         , QT_ESTOQUE_ATUAL
         ,QTD_LOTE
   
)WHERE dias_venc BETWEEN 30  AND  90
  -- AND SALDO > 0
    )
 GROUP BY CD_ESTOQUE
 ORDER BY cd_estoque
          
