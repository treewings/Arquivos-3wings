-- TOTAL ESTOQUE - PADRAO  - andra
--total_standard_stock.sql  -- Traz todos os estoques q tenham saldo
-- atualizado baseado no relatório 'R_POS_EST_S' enviado pelo cliente
SELECT  CD_ESTOQUE
       ,Round (Sum (VL_TOTAL_PRODUTO),2 )VALOR_ESTOQUE
              
FROM (
SELECT 

       
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,     
       QT_ESTOQUE_ATUAL,
       QT_ESTOQUE_ATUAL * (DBAMV.VERIF_VL_CUSTO_MEDIO(CD_PRODUTO, Trunc(SysDate), 'H',VL_CUSTO_MEDIO, SYSDATE,1)) As VL_TOTAL_PRODUTO
                               
FROM (  

SELECT         
       CD_PRODUTO,
       DS_PRODUTO,
       CD_ESTOQUE,     
       QT_ESTOQUE_ATUAL , 
       VL_CUSTO_MEDIO                       

FROM (  
SELECT PRODUTO.DS_PRODUTO DS_PRODUTO,
       PRODUTO.CD_PRODUTO CD_PRODUTO,
       PRODUTO.SN_MESTRE,
       PRODUTO.VL_CUSTO_MEDIO,                      
       ESTOQUE.CD_ESTOQUE CD_ESTOQUE,                                           
       EST_PRO.QT_ESTOQUE_ATUAL                          

 FROM     
      DBAMV.ESTOQUE,  
      DBAMV.PRODUTO,     
      DBAMV.EMPRESA_PRODUTO,  
      DBAMV.EST_PRO

WHERE ESTOQUE.CD_MULTI_EMPRESA     = EMPRESA_PRODUTO.CD_MULTI_EMPRESA     
  AND EMPRESA_PRODUTO.CD_PRODUTO = PRODUTO.CD_PRODUTO                  
  AND PRODUTO.TP_ATIVO = 'S'                       
  AND PRODUTO.CD_PRODUTO =  EST_PRO.CD_PRODUTO 
  AND EST_PRO.CD_ESTOQUE = ESTOQUE.CD_ESTOQUE 
  AND PRODUTO.SN_PADRONIZADO = 'S' -- PRODUTO PADRÃO 
  AND PRODUTO.SN_MESTRE = 'N'
  AND EST_PRO.QT_ESTOQUE_ATUAL >0          
  AND ESTOQUE.CD_MULTI_EMPRESA =1 
  AND ESTOQUE.CD_ESTOQUE IN(1,3,4,14, 34,66,78) -- estoques informados pelo cliente  
 -- AND produto.cd_produto = 40823
GROUP BY PRODUTO.DS_PRODUTO,
         PRODUTO.CD_PRODUTO,
         PRODUTO.SN_MESTRE,
         PRODUTO.VL_CUSTO_MEDIO,           
         EST_PRO.QT_ESTOQUE_ATUAL,
         ESTOQUE.CD_ESTOQUE  ))

) GROUP BY cd_estoque 
  ORDER BY 2 DESC 