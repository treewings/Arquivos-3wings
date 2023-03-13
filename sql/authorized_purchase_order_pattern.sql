SELECT   situacao,
         QTD_ORDEM_COMPRAS,
         VALOR_TOTAL

 FROM (
							  SELECT situacao,
        Count(CD_ORD_COM ) QTD_ORDEM_COMPRAS,
        Sum (VL_TOTAL) VALOR_TOTAL
 FROM (

SELECT  distinct
        CD_ORD_COM                 
       ,DT_ORD_COM                   
       ,VL_TOTAL
       ,tp_situacao
       ,CASE WHEN tp_situacao = 'U' THEN 'AUTORIZADA'  
              END SITUACAO   
from (
select         ORD_COM.CD_ORD_COM                   CD_ORD_COM
               ,ord_com.dt_ord_com
               ,ord_com.vl_total
			   ,ord_com.tp_situacao
			   

FROM      DBAMV.ORD_COM  
         ,DBAMV.FORNECEDOR                         
         ,DBAMV.CONDICOES_PAGAMENTO     
	     ,DBAMV.ESTOQUE
         ,DBAMV.ORD_COM_MOEDA
         ,dbamv.itord_pro
WHERE   ORD_COM.CD_FORNECEDOR                      =  FORNECEDOR.CD_FORNECEDOR
AND     ORD_COM.CD_CONDICAO_PAGAMENTO = CONDICOES_PAGAMENTO.CD_CONDICAO_PAGAMENTO
and     ord_com.cd_ord_com = itord_pro.cd_ord_com
and     itord_pro.cd_produto in (select cd_produto from produto where sn_padronizado = 'S')
AND     TRUNC( ORD_COM.DT_ORD_COM )BETWEEN Trunc(SYSDATE-30)  AND trunc(SYSDATE)
AND     FORNECEDOR.TP_CLIENTE_FORN	  IN ( 'F', 'A' ,'R', 'T')
AND     ESTOQUE.CD_ESTOQUE = ORD_COM.CD_ESTOQUE
AND     ORD_COM.cd_ord_com = ord_com_moeda.cd_ord_com(+)
AND     NVL( ORD_COM.SN_CONSIGNADO_FATURA_DIRETA,'N' ) = 'N'
and     ORD_COM.tp_situacao = 'U'
ORDER BY ORD_COM.CD_ORD_COM, FORNECEDOR.CD_FORNECEDOR
)
) GROUP BY situacao
union
 SELECT situacao,
        Count(CD_ORD_COM ) QTD_ORDEM_COMPRAS,
        Sum (VL_TOTAL) VALOR_TOTAL
 FROM (

SELECT  distinct
        CD_ORD_COM                 
       ,DT_ORD_COM                   
       ,VL_TOTAL
       ,tp_situacao
       ,CASE WHEN tp_situacao <> 'U' THEN 'PENDENTE AUTORIZACAO'  
              END SITUACAO   
from (
select         ORD_COM.CD_ORD_COM                   CD_ORD_COM
               ,ord_com.dt_ord_com
               ,ord_com.vl_total
			   ,ord_com.tp_situacao


FROM      DBAMV.ORD_COM  
         ,DBAMV.FORNECEDOR                         
         ,DBAMV.CONDICOES_PAGAMENTO     
	     ,DBAMV.ESTOQUE
         ,DBAMV.ORD_COM_MOEDA
         ,dbamv.itord_pro
WHERE   ORD_COM.CD_FORNECEDOR                      =  FORNECEDOR.CD_FORNECEDOR
AND     ORD_COM.CD_CONDICAO_PAGAMENTO = CONDICOES_PAGAMENTO.CD_CONDICAO_PAGAMENTO
and     ord_com.cd_ord_com = itord_pro.cd_ord_com
and     itord_pro.cd_produto in (select cd_produto from produto where sn_padronizado = 'S')
AND     TRUNC( ORD_COM.DT_ORD_COM )BETWEEN Trunc(SYSDATE-180)  AND trunc(SYSDATE)
AND     FORNECEDOR.TP_CLIENTE_FORN	  IN ( 'F', 'A' ,'R', 'T')
AND     ESTOQUE.CD_ESTOQUE = ORD_COM.CD_ESTOQUE
AND     ORD_COM.cd_ord_com = ord_com_moeda.cd_ord_com(+)
AND     NVL( ORD_COM.SN_CONSIGNADO_FATURA_DIRETA,'N' ) = 'N'
AND     ORD_COM.tp_situacao IN ('O','A')  -- U= AUTORIZADAS O= AGUARDANDO PROX NIVEL DE AUTORIZAÇAÕ  A= ABERTA

ORDER BY ORD_COM.CD_ORD_COM, FORNECEDOR.CD_FORNECEDOR
)
) GROUP BY situacao
)