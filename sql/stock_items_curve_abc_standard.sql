-- stock_items_curve_abc_standard.sql - PADRAO
-- CRITICO - 0-10 - saldo em estoque
-- ATENCAO - 10.01-20
-- ABASTECIDO - 20.01-40
-- EXCESSO - >40.01
 
SELECT /*+ RULE */     
       SITUACAO, 
       TP_CLASSIFICACAO_ABC,       
       CD_ESTOQUE,     
       Count (TP_CLASSIFICACAO_ABC)TOTAL
FROM( 
SELECT 

 CASE WHEN (SALDO) BETWEEN 0  AND  10 THEN '1- CRITICO'   
         WHEN (SALDO) BETWEEN 10.01 AND  20 THEN '2- ATENCAO'
         WHEN (SALDO) BETWEEN 20.01 AND  40 THEN '3- ABASTECIDO'
         ELSE '4- EXCESSO' END SITUACAO,  
       
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,     
       QT_ESTOQUE_ATUAL ,  
       TP_CLASSIFICACAO_ABC
     --  Round(SALDO,2)saldo 
FROM ( 


SELECT         
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,     
       QT_ESTOQUE_ATUAL , 
       TP_CLASSIFICACAO_ABC,     
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
SELECT PRODUTO.DS_PRODUTO DS_PRODUTO,
       PRODUTO.CD_PRODUTO CD_PRODUTO,
       PRODUTO.SN_MESTRE,                      
       ESTOQUE.CD_ESTOQUE CD_ESTOQUE,                                           
       EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC,
       EST_PRO.QT_ESTOQUE_ATUAL                          

 FROM 
      
      DBAMV.MVTO_ESTOQUE,
      DBAMV.ITMVTO_ESTOQUE,                         
      DBAMV.ESTOQUE,
      DBAMV.PRODUTO,     
      DBAMV.EMPRESA_PRODUTO,  
      DBAMV.EST_PRO

WHERE --trunc(MVTO_ESTOQUE.DT_MVTO_ESTOQUE) BETWEEN SYSDATE -30  AND SYSDATE 
      MVTO_ESTOQUE.CD_MVTO_ESTOQUE = ITMVTO_ESTOQUE.CD_MVTO_ESTOQUE
  AND ITMVTO_ESTOQUE.CD_PRODUTO    = PRODUTO.CD_PRODUTO  
  AND MVTO_ESTOQUE.CD_ESTOQUE      = ESTOQUE.CD_ESTOQUE
  AND ESTOQUE.CD_MULTI_EMPRESA     = EMPRESA_PRODUTO.CD_MULTI_EMPRESA     
  AND EMPRESA_PRODUTO.CD_PRODUTO = PRODUTO.CD_PRODUTO                  
  AND PRODUTO.TP_ATIVO = 'S'                       
  AND PRODUTO.CD_PRODUTO =  EST_PRO.CD_PRODUTO 
  AND EST_PRO.CD_ESTOQUE = ESTOQUE.CD_ESTOQUE 
  AND EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC IS NOT NULL 
  AND PRODUTO.SN_PADRONIZADO = 'S' -- PRODUTO PADRÃO 
  AND EST_PRO.QT_ESTOQUE_ATUAL IS NOT NULL 
  AND ESTOQUE.CD_MULTI_EMPRESA =1 
  AND ESTOQUE.CD_ESTOQUE IN (1,3,4,14, 34,66,78) -- estoques informados pelo cliente  
--  AND EST_PRO.cd_produto IN (33, 95,543,1034,1193,11483, 7999, 6195 )

GROUP BY PRODUTO.DS_PRODUTO,
         PRODUTO.CD_PRODUTO,
         PRODUTO.SN_MESTRE,
         EMPRESA_PRODUTO.TP_CLASSIFICACAO_ABC,     
         EST_PRO.QT_ESTOQUE_ATUAL,
         ESTOQUE.CD_ESTOQUE
 ) )WHERE CONSUMO_DIA > 0
 )  
GROUP BY TP_CLASSIFICACAO_ABC, 
         SITUACAO,
         CD_ESTOQUE
ORDER BY SITUACAO,
         TP_CLASSIFICACAO_ABC