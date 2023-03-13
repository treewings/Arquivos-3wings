-- LISTAGEM DOS PRODUTOS COM CONTROLE DE VALIDAE - SITUAÇAO A (30 -60 e 90 DIAS) - NAO PADRÃO 
-- non_standard_validity_control_listing.sql
-- CRITICO - 0-10
-- ATENCAO - 10.01-20
-- ABASTECIDO- 20.01-40
-- EXCESSO - >40.01

SELECT /*+ RULE */ 
        COR,
        CD_PRODUTO,
        DS_PRODUTO, 
        QTD_LOTE,
        CD_ESTOQUE
       -- dias_venc,
      --  DT_VALIDADE

FROM ( 
SELECT  CD_PRODUTO,
        DS_PRODUTO, 
        CASE WHEN (dias_venc) BETWEEN 0  AND  30 THEN '1- VERMELHO'
             WHEN (dias_venc) BETWEEN 31 AND  60 THEN '2- AMARELO'
             WHEN (dias_venc) BETWEEN 61 AND  90 THEN '3- VERDE'
             ELSE '4- OUTROS' END COR,  
        QTD_LOTE,
         CASE WHEN (SALDO) BETWEEN 0  AND  10 THEN '1- CRITICO'   
         WHEN (SALDO) BETWEEN 10.01 AND  20 THEN '2- ATENCAO'
         WHEN (SALDO) BETWEEN 20.01 AND  40 THEN '3- ABASTECIDO'
         ELSE '4- EXCESSO' END SITUACAO,
        CD_ESTOQUE, 
        dias_venc,
        DT_VALIDADE            
FROM (
 
SELECT         
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,
       QT_ESTOQUE_ATUAL,
       QTD_LOTE, 
       TP_CLASSIFICACAO_ABC,
       dias_venc,
       DT_VALIDADE,
       FNC_MGES_RETORNA_CONSUMO_MEDIO (CD_PRODUTO,
                                 CD_ESTOQUE,
                                 6, -- referente ao semestre
                                 SN_MESTRE,
                                 1,
                                 Trunc (SYSDATE - 30),
                                 Trunc (SYSDATE),
                                 'M') /30 consumo_dia ,  
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
       PRODUTO.SN_MESTRE,                     
       ESTOQUE.CD_ESTOQUE CD_ESTOQUE,                                           
       EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC TP_CLASSIFICACAO_ABC,
       EST_PRO.QT_ESTOQUE_ATUAL,    
       Sum (LOT_PRO.qt_estoque_atual)QTD_LOTE, --OVER(PARTITION BY LOT_PRO.DT_VALIDADE) QTD_LOTE,
       Round ((LOT_PRO.DT_VALIDADE - SYSDATE ),0) dias_venc,
       DT_VALIDADE 
 FROM 
        
      DBAMV.PRODUTO,
      DBAMV.SUB_CLAS,
      DBAMV.EMPRESA_PRODUTO,  
      DBAMV.EST_PRO,
      DBAMV.ESTOQUE, 
      DBAMV.LOT_PRO

WHERE PRODUTO.CD_SUB_CLA = SUB_CLAS.CD_SUB_CLA
  AND EMPRESA_PRODUTO.CD_PRODUTO = PRODUTO.CD_PRODUTO                  
  AND PRODUTO.TP_ATIVO = 'S'
  AND PRODUTO.CD_CLASSE = SUB_CLAS.CD_CLASSE
  AND PRODUTO.CD_ESPECIE = SUB_CLAS.CD_ESPECIE   
  AND EST_PRO.CD_PRODUTO = PRODUTO.CD_PRODUTO 
  AND EST_PRO.CD_ESTOQUE = ESTOQUE.CD_ESTOQUE 
  AND lot_pro.cd_produto = EST_PRO.cd_produto 
  AND lot_pro.CD_ESTOQUE = EST_PRO.CD_ESTOQUE         
  AND EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC IS NOT NULL 
  AND PRODUTO.SN_PADRONIZADO = 'N' -- PRODUTO PADRÃO 
--AND EST_PRO.QT_ESTOQUE_ATUAL IS NOT NULL 
  AND EST_PRO.QT_ESTOQUE_ATUAL > 0
  AND LOT_PRO.qt_estoque_atual > 0
  AND ESTOQUE.CD_ESTOQUE IN (1,3,4,14,34,66,78) -- estoques informados pelo cliente  
  AND EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC = 'A'   
  AND estoque.cd_multi_empresa = 1
  AND PRODUTO.CD_ESPECIE IN (1,2) -- MATERIAL E MEDICACAO
  AND LOT_PRO.DT_VALIDADE IS NOT NULL
  AND LOT_PRO.cd_lote IS NOT NULL  
  AND LOT_PRO.DT_VALIDADE >= SYSDATE 
 -- AND produto.cd_produto = 33868
    
GROUP BY PRODUTO.DS_PRODUTO,
         PRODUTO.CD_PRODUTO,
         PRODUTO.SN_MESTRE,                      
         EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC,     
         EST_PRO.QT_ESTOQUE_ATUAL,
         ESTOQUE.CD_ESTOQUE,                 
         LOT_PRO.DT_VALIDADE,
         LOT_PRO.qt_estoque_atual 
                        
)
GROUP BY ds_produto
         , cd_produto
         , SN_MESTRE
         , cd_estoque
         , tp_classificacao_abc   
         , QT_ESTOQUE_ATUAL
         , dias_venc
         ,DT_VALIDADE 
         ,QTD_LOTE       
)WHERE SALDO >0
  
)WHERE dias_venc BETWEEN 30  AND  90
 ORDER BY cor,
          dias_venc,
          cd_estoque