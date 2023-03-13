/*listagem de procedimentos OPMES*/

 SELECT   it_av_produtos.DS_PRODUTO as OPMES
  FROM    IT_AV_PRODUTOS, CIRURGIA , produto
  WHERE   cd_aviso_cirurgia IN (
                                SELECT cd_aviso_cirurgia 
                                FROM AGE_CIR  
                                WHERE Trunc(dt_inicio_age_cir) between Trunc(SYSDATE-30) AND Trunc(SYSDATE)
                                ) 
  AND     IT_AV_PRODUTOS.cd_cirurgia = CIRURGIA.CD_CIRURGIA
  AND     produto.cd_produto = it_av_produtos.cd_produto  
  --AND     SN_CONSIGNADO = 'S'
GROUP BY   it_av_produtos.DS_PRODUTO
        , CIRURGIA.DS_CIRURGIA  
        , produto.DS_PRODUTO