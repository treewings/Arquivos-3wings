SELECT
TIPO,
CD_ESPECIE,
DS_ESPECIE,
qtd,
CASE WHEN to_char(dt_entrada,'D') = '1' THEN 'DOM'
             WHEN to_char(dt_entrada ,'D') = '2' THEN 'SEG'
             WHEN to_char(dt_entrada ,'D') = '3' THEN 'TER'
             WHEN to_char(dt_entrada ,'D') = '4' THEN 'QUA'
             WHEN to_char(dt_entrada ,'D') = '5' THEN 'QUI'
             WHEN to_char(dt_entrada ,'D') = '6' THEN 'SEX'
             WHEN to_char(dt_entrada ,'D') = '7' THEN 'SAB'
        END DIA_SEMANA,
        dt_entrada
        FROM
(SELECT
'ENTREGUE' AS TIPO,
ESPECIE.CD_ESPECIE,
ESPECIE.DS_ESPECIE,
Count(PRODUTO.CD_PRODUTO) AS QTD,
ENT_PRO.DT_ENTRADA
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
And To_date(ent_pro.dt_entrada,'dd/mm/rrrr') between  trunc(sysdate)-7 and SYSDATE -1
GROUP BY ESPECIE.DS_ESPECIE,ENT_PRO.DT_ENTRADA,ESPECIE.CD_ESPECIE)
ORDER BY CD_ESPECIE



