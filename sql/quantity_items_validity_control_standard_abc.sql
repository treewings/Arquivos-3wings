-- TOTAL DOS ITENS dos produtos críticos por controle de validade (30 -60 e 90 DIAS) - PADRÃO 
-- quantity_items_validity_control_standard_abc 
-- CRITICO - 0-10
-- ATENCAO - 10.01-20
-- ABASTECIDO- 20.01-40
-- EXCESSO - >40.01

SELECT  COR,
        SITUACAO,
        TP_CLASSIFICACAO_ABC, 
        CD_ESTOQUE,
        Count (Nvl(TP_CLASSIFICACAO_ABC,0) )  TOTAL
        

FROM (
SELECT  CD_PRODUTO,
        DS_PRODUTO, 
        CASE WHEN (dias_venc) BETWEEN 0  AND  30 THEN '1- VERMELHO'
             WHEN (dias_venc) BETWEEN 31 AND  60 THEN '2- AMARELO'
             WHEN (dias_venc) BETWEEN 61 AND  90 THEN '3- VERDE'
             ELSE '4- OUTROS' END COR,  
        QTD_LOTE,
        CASE WHEN (SALDO) BETWEEN 0     AND  10 THEN '1- CRITICO'   
             WHEN (SALDO) BETWEEN 10.01 AND  20 THEN '2- ATENCAO'
             WHEN (SALDO) BETWEEN 20.01 AND  40 THEN '3- ABASTECIDO'
             ELSE '4- EXCESSO' END SITUACAO,
        CD_ESTOQUE,
        dias_venc,
        TP_CLASSIFICACAO_ABC,             
        Round(SALDO,2)saldo 
FROM ( 
 
SELECT         
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,
       Sum (QTD_LOTE)QTD_LOTE,
       TP_CLASSIFICACAO_ABC,
       dias_venc,
       CASE WHEN FNC_MGES_RETORNA_CONSUMO_MEDIO (CD_PRODUTO,
                                 CD_ESTOQUE,
                                 6, -- referente ao semestre
                                 SN_MESTRE,
                                 1,
                                 Trunc (SYSDATE - 30),
                                 Trunc (SYSDATE),
                                 'M') /30  >0
       THEN QT_ESTOQUE_ATUAL /    (  FNC_MGES_RETORNA_CONSUMO_MEDIO (CD_PRODUTO,
                                 CD_ESTOQUE,
                                 6, -- referente ao semestre
                                 SN_MESTRE,
                                 1,
                                 Trunc (SYSDATE - 30),
                                 Trunc (SYSDATE),
                                 'M') /30) ELSE 0 END SALDO


FROM ( 

SELECT 
       PRODUTO.DS_PRODUTO DS_PRODUTO,
       PRODUTO.CD_PRODUTO CD_PRODUTO,                      
       ESTOQUE.CD_ESTOQUE CD_ESTOQUE, 
       PRODUTO.SN_MESTRE  SN_MESTRE,                                        
       EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC TP_CLASSIFICACAO_ABC,
       EST_PRO.QT_ESTOQUE_ATUAL,    
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
  AND EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC IS NOT NULL 
  AND PRODUTO.SN_PADRONIZADO = 'S' -- PRODUTO PADRÃO 
  AND EST_PRO.QT_ESTOQUE_ATUAL IS NOT NULL                                                      
  AND ESTOQUE.CD_MULTI_EMPRESA =1 
  AND EST_PRO.QT_ESTOQUE_ATUAL > 0
  AND LOT_PRO.qt_estoque_atual > 0
  AND ESTOQUE.CD_ESTOQUE IN (1,3,4,14, 34,66,78) -- estoques informados pelo cliente  
  AND estoque.cd_multi_empresa = 1
  AND PRODUTO.CD_ESPECIE IN (1,2) -- MATERIAL E MEDICACAO
  AND LOT_PRO.DT_VALIDADE IS NOT NULL
  AND LOT_PRO.cd_lote IS NOT NULL  
  AND LOT_PRO.DT_VALIDADE >= SYSDATE   
    
GROUP BY PRODUTO.DS_PRODUTO,
         PRODUTO.CD_PRODUTO,
         PRODUTO.SN_MESTRE,
         EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC,         
         EST_PRO.QT_ESTOQUE_ATUAL,
         ESTOQUE.CD_ESTOQUE , 
         LOT_PRO.DT_VALIDADE,
         LOT_PRO.qt_estoque_atual                
) GROUP BY ds_produto
         , cd_produto
         , SN_MESTRE
         , QT_ESTOQUE_ATUAL
         , cd_estoque
         , tp_classificacao_abc
         , dias_venc  

)WHERE dias_venc  BETWEEN 30  AND  90
   AND saldo > 0    
)GROUP BY SITUACAO,
          COR,
          TP_CLASSIFICACAO_ABC,   
          CD_ESTOQUE
 
 ORDER BY cd_estoque