/*cirurgias com OPME no proximo dia*/


SELECT   it_av_produtos.CD_AVISO_CIRURGIA  aviso
      , it_av_produtos.DS_PRODUTO       procedimento 
      ,Count(CIRURGIA.cd_cirurgia) qtd_solicitada
FROM IT_AV_PRODUTOS, CIRURGIA
WHERE cd_aviso_cirurgia IN (
SELECT cd_aviso_cirurgia FROM AGE_CIR  WHERE Trunc(dt_inicio_age_cir) = Trunc(SYSDATE+1))
AND IT_AV_PRODUTOS.cd_cirurgia = CIRURGIA.CD_CIRURGIA   
GROUP BY  it_av_produtos.CD_AVISO_CIRURGIA  , it_av_produtos.DS_PRODUTO ,CIRURGIA.DS_CIRURGIA



                                    