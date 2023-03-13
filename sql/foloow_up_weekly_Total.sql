SELECT * FROM
(SELECT tipo,
cd_especie,
ds_especie,
Sum(total_por_especie) AS total_por_especie
FROM (SELECT
'PEND' AS TIPO,
cd_especie,
ds_especie,
(SELECT count(DISTINCT cd_produto) FROM produto WHERE produto.cd_produto = a.cd_produto GROUP BY cd_especie,ds_especie) total_por_especie



 FROM
 (
Select Fornecedor.cd_fornecedor Cd_fornecedor,
       Fornecedor.nm_fornecedor Nm_fornecedor,
       Ord_com.dt_prev_entrega  Dt_prevista,
       round(Sysdate - Ord_com.dt_prev_entrega) Dias_atrazo,
       Uni_pro.cd_produto       Cd_produto,
       Produto.ds_produto       Ds_produto,
       Uni_pro.cd_unidade       Cd_unidade,
       Uni_pro.Ds_unidade       Ds_unidade,
       Uni_pro.vl_fator              vl_fator,
       Nvl(Itord_pro.qt_comprada, 0) Qt_comprada,
       Nvl(Itord_pro.qt_recebida, 0) Qt_recebida,
       Nvl(Itord_pro.qt_comprada, 0) - Nvl(Itord_pro.qt_recebida, 0) - Nvl(Itord_pro.qt_cancelada, 0) Qt_atrazo,
       Ord_com.cd_ord_com,
       especie.ds_especie,
       PRODUTO.CD_ESPECIE



  From Dbamv.fornecedor Fornecedor,
       Dbamv.ord_com    Ord_com,
       Dbamv.itord_pro  Itord_pro,
       Dbamv.uni_pro    Uni_pro,
       Dbamv.produto    Produto,
       DBAMV.ESTOQUE    ESTOQUE,
       dbamv.especie    especie
     --  dbamv.sol_com   solic,
     --  dbamv.cotador cotador


 Where Ord_com.cd_fornecedor = Fornecedor.cd_fornecedor
   And Ord_com.cd_ord_com    = Itord_pro.cd_ord_com
   and        estoque.cd_estoque = ord_com.cd_estoque
   and        estoque.cd_multi_empresa = 1
   And Itord_pro.cd_uni_pro  = Uni_pro.cd_uni_pro
   And Uni_pro.cd_produto    = Produto.cd_produto
   AND produto.cd_especie = especie.cd_especie
  -- AND produto.cd_especie = 1
   And nvl(Itord_pro.qt_recebida, 0) + nvl(qt_cancelada,0) < nvl(Itord_pro.qt_comprada, 0)
   And Ord_com.tp_situacao   In ('U','L')
   And ItOrd_Pro.cd_mot_cancel is null
   And To_date(Ord_com.dt_prev_entrega,'dd/mm/rrrr') between  trunc(SYSDATE ,'MM') and SYSDATE -1

   )a) GROUP BY tipo,cd_especie,ds_especie


UNION

SELECT
TIPO,
CD_ESPECIE,
DS_ESPECIE,
qtd  AS total_por_especie
        FROM
(SELECT
'ENTREGUE' AS TIPO,
ESPECIE.CD_ESPECIE,
ESPECIE.DS_ESPECIE,
Count(PRODUTO.CD_PRODUTO) AS QTD
FROM DBAMV.itent_pro ITENT_PRO,
DBAMV.ent_pro ENT_PRO,
DBAMV.produto PRODUTO,
DBAMV.ord_com  ORD_COM,
DBAMV.ESPECIE ESPECIE
WHERE itent_pro.cd_ent_pro = ent_pro.cd_ent_pro
AND produto.cd_produto = itent_pro.cd_produto
AND ord_com.cd_ord_com = ent_pro.cd_ord_com
AND PRODUTO.CD_ESPECIE = ESPECIE.CD_ESPECIE
AND ord_com.tp_situacao = 'T'
--AND produto.cd_especie = 1
And To_date(ent_pro.dt_entrada,'dd/mm/rrrr') between  trunc(SYSDATE ,'MM') and SYSDATE -1
GROUP BY ESPECIE.DS_ESPECIE,ESPECIE.CD_ESPECIE)
ORDER BY CD_ESPECIE
)
ORDER BY 2












