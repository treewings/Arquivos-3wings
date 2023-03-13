/*total de procedimentos solicitados com opme nos proximos 30 dias*/

SELECT Sum(TOTALa) qtd_solicitada
                 ,A.DATA 
          FROM 

/*Total com OPME*/
( SELECT 
               Sum(qtd) totalA
               ,DATA
         
            FROM (SELECT 
                     Count( CIRURGIA.cd_cirurgia) QTD
                     ,CIRURGIA.DS_CIRURGIA
                     ,Trunc(AGE_CIR.dt_inicio_age_cir) DATA
               FROM IT_AV_PRODUTOS, CIRURGIA,AGE_CIR
              WHERE IT_AV_PRODUTOS.cd_aviso_cirurgia = AGE_CIR.cd_aviso_cirurgia 
              AND   Trunc(AGE_CIR.dt_inicio_age_cir) between Trunc(SYSDATE-30) AND Trunc(SYSDATE)
              AND IT_AV_PRODUTOS.cd_cirurgia = CIRURGIA.CD_CIRURGIA
                GROUP BY CIRURGIA.DS_CIRURGIA
                     ,AGE_CIR.dt_inicio_age_cir )
              GROUP BY DATA ) a
--                   ,
--    /*TOTAL SEM OPME*/          
-- (SELECT 
--               Sum(qtd) totalB
--               ,DATA 
--               FROM (

--                   SELECT Count(CIRURGIA_AVISO.CD_CIRURGIA) QTD
--                          ,CIRURGIA.DS_CIRURGIA
--                          ,Trunc(AGE_CIR.dt_inicio_age_cir)  DATA
--                     FROM AGE_CIR
--                                ,CIRURGIA_AVISO
--                                ,CIRURGIA
--                     WHERE Trunc(AGE_CIR.dt_inicio_age_cir) between Trunc(SYSDATE-30) AND Trunc(SYSDATE)
--                     AND AGE_CIR.cd_aviso_cirurgia = CIRURGIA_AVISO.cd_aviso_cirurgia
--                     AND CIRURGIA_AVISO.CD_CIRURGIA = CIRURGIA.CD_CIRURGIA
--                     AND CIRURGIA_AVISO.CD_AVISO_CIRURGIA NOT IN (
--                                                                  SELECT  IT_AV_PRODUTOS.CD_AVISO_CIRURGIA
--                                                                    FROM  IT_AV_PRODUTOS, CIRURGIA,AGE_CIR
--                                                                    WHERE IT_AV_PRODUTOS.cd_aviso_cirurgia = AGE_CIR.cd_aviso_cirurgia 
--                                                                    AND   Trunc(AGE_CIR.dt_inicio_age_cir) between Trunc(SYSDATE-30) AND Trunc(SYSDATE)
--                                                                    AND   IT_AV_PRODUTOS.cd_cirurgia = CIRURGIA.CD_CIRURGIA
--                                                                  )
--                     GROUP BY CIRURGIA.DS_CIRURGIA,Trunc(AGE_CIR.dt_inicio_age_cir) ) T2 ) b
                   GROUP BY A.DATA
                   ORDER BY data
