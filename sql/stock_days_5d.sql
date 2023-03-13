SELECT cd_produto
     , nm_produto
     , especie
     , saldo_estoque
     , dias_para_acabar
FROM ( 
SELECT CD_PRODUTO
      ,DS_PRODUTO  NM_PRODUTO
      ,DS_ESPECIE  ESPECIE
      ,QT_ESTOQUE_ATUAL  SALDO_ESTOQUE
      ,ROUND(QT_ESTOQUE_ATUAL/QT_CONSUMO_ATUAL_DIA)DIAS_PARA_ACABAR
FROM (
SELECT cd_produto
     , ds_produto
     , qt_estoque_atual
     , ds_especie
     , (QT_CONSUMO_MES/30) AS QT_CONSUMO_ATUAL_DIA  
FROM (
SELECT CD_PRODUTO,
       DS_PRODUTO,
       QT_ESTOQUE_ATUAL,
       DS_ESPECIE,
       FNC_MGES_RETORNA_CONSUMO_MEDIO (CD_PRODUTO,
                                        CD_ESTOQUE,
                                        06,
                                        SN_MESTRE,
                                        1,
                                        Trunc (SYSDATE - 30),
                                        Trunc (SYSDATE),
                                        'M')as QT_CONSUMO_MES
FROM (
SELECT 
        PRODUTO.CD_PRODUTO,
        PRODUTO.DS_PRODUTO,
        PRODUTO.SN_MESTRE,
        EST_PRO.QT_ESTOQUE_ATUAL,
        ESPECIE.DS_ESPECIE,
        ESTOQUE.CD_ESTOQUE 
       -- nullif(EST_PRO.QT_CONSUMO_MES/30,0) QT_CONSUMO_ATUAL_DIA
 
FROM 
        EST_PRO,
        PRODUTO,
        ESPECIE,
        ESTOQUE 
  WHERE EST_PRO.CD_PRODUTO = PRODUTO.CD_PRODUTO
    AND PRODUTO.CD_ESPECIE = ESPECIE.CD_ESPECIE
    AND EST_PRO.CD_ESTOQUE = ESTOQUE.CD_ESTOQUE 
    --AND EST_PRO.QT_ESTOQUE_ATUAL > 0
    AND PRODUTO.SN_PADRONIZADO = 'S'
    AND PRODUTO.TP_ATIVO = 'S' 
    AND estoque.CD_ESTOQUE IN (1)
    AND ESTOQUE.CD_MULTI_EMPRESA =1 
    AND PRODUTO.SN_MESTRE = 'N'
    AND produto.cd_produto in (select cd_produto from tscm_view_prod_do_almox_geral)
ORDER BY 1
)
) WHERE QT_CONSUMO_MES >= 1 
) 
) WHERE dias_para_acabar < 5
ORDER BY dias_para_acabar