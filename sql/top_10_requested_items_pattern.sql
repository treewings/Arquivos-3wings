-- Top 10 ítens solicitados (30 dias) PADRÃO 
SELECT DISTINCT * FROM (
SELECT  ROWNUM || 'o' "RANK" ,          
              cd_produto ,
              DS_PRODUTO, 
              TOTAL_DE_SOLICITACOES  
 FROM   
 (
 SELECT produto.cd_produto , 
        PRODUTO.DS_PRODUTO ds_produto, 
        COUNT(SOL_COM.CD_SOL_COM) TOTAL_DE_SOLICITACOES 
 FROM  ITSOL_COM, 
       SOL_COM, 
       PRODUTO
 WHERE ITSOL_COM.CD_SOL_COM = SOL_COM.CD_SOL_COM
   AND ITSOL_COM.CD_PRODUTO = PRODUTO.CD_PRODUTO
   AND sn_padronizado = 'S'  -- PRODUTOS
   AND ITSOL_COM.CD_MOT_CANCEL IS NULL 
   AND SOL_COM.DT_SOL_COM BETWEEN SYSDATE-30 AND SYSDATE
   
 GROUP BY PRODUTO.cd_produto, produto.DS_PRODUTO
 ORDER BY 3 DESC
 )
)
WHERE  ROWNUM < 11 
			