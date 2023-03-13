-- stock_filters
-- listagem dos estoques 
SELECT estoque.cd_estoque
      ,ds_estoque

FROM estoque
WHERE cd_multi_empresa = 1
  AND ESTOQUE.CD_ESTOQUE IN (1,3,4,14, 34,66,78) -- estoques informados pelo cliente  



ORDER BY 1
