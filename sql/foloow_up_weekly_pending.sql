SELECT
tipo,
cd_especie,
ds_especie,
Sum(qtd_do_dia) AS qtd_do_dia,
dia_semana,
dt_prev_entrega
FROM
(SELECT
TIPO,
CD_ESPECIE,
DS_ESPECIE,
QTD_DO_DIA,
CASE WHEN to_char(Dt_prevista,'D') = '1' THEN 'DOM'
             WHEN to_char(Dt_prevista ,'D') = '2' THEN 'SEG'
             WHEN to_char(Dt_prevista ,'D') = '3' THEN 'TER'
             WHEN to_char(Dt_prevista ,'D') = '4' THEN 'QUA'
             WHEN to_char(Dt_prevista ,'D') = '5' THEN 'QUI'
             WHEN to_char(Dt_prevista ,'D') = '6' THEN 'SEX'
             WHEN to_char(Dt_prevista ,'D') = '7' THEN 'SAB'
        END DIA_SEMANA,
        Dt_prevista AS DT_PREV_ENTREGA
        FROM
(SELECT 'PENDENTE' TIPO,
CD_ESPECIE,
DS_ESPECIE,
(SELECT  Count(DISTINCT produto.cd_produto) FROM produto WHERE produto.cd_produto = a.cd_produto GROUP BY cd_especie,ds_especie,dt_prevista) AS QTD_DO_DIA,
Dt_prevista


 FROM (
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
       PRODUTO.CD_ESPECIE,
       ESPECIE.DS_ESPECIE



  From Dbamv.fornecedor Fornecedor,
       Dbamv.ord_com    Ord_com,
       Dbamv.itord_pro  Itord_pro,
       Dbamv.uni_pro    Uni_pro,
       Dbamv.produto    Produto,
       DBAMV.ESTOQUE    ESTOQUE,
       DBAMV.ESPECIE    ESPECIE
     --  dbamv.sol_com   solic,
     --  dbamv.cotador cotador


 Where Ord_com.cd_fornecedor = Fornecedor.cd_fornecedor
   And Ord_com.cd_ord_com    = Itord_pro.cd_ord_com
   and        estoque.cd_estoque = ord_com.cd_estoque
   and        estoque.cd_multi_empresa = 1
   And Itord_pro.cd_uni_pro  = Uni_pro.cd_uni_pro
   And Uni_pro.cd_produto    = Produto.cd_produto
   AND PRODUTO.CD_ESPECIE = ESPECIE.CD_ESPECIE
  -- AND produto.cd_especie = 8
   And nvl(Itord_pro.qt_recebida, 0) + nvl(qt_cancelada,0) < nvl(Itord_pro.qt_comprada, 0)
   And Ord_com.tp_situacao   In ('U','L')
   And ItOrd_Pro.cd_mot_cancel is null
   And To_date(Ord_com.dt_prev_entrega,'dd/mm/rrrr') between  trunc(sysdate)-7 and SYSDATE -1

   ) a
  -- GROUP BY (CD_ESPECIE,DS_ESPECIE,Dt_prevista)
   ))
   GROUP BY (tipo,cd_especie,ds_especie,dia_semana,dt_prev_entrega)
  ORDER BY CD_ESPECIE
