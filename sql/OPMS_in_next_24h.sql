/*OPMS nas proximas 24h*/

SELECT
                   Round(((T1.total/T2.total)*100),2) AS "OPME-24h"
                FROM

              ( SELECT 
               Sum(qtd) total
               ,'OPME' AS PRC
               FROM (
              SELECT 
                      Count(CIRURGIA.cd_cirurgia) qtd
                     ,CIRURGIA.DS_CIRURGIA
               FROM IT_AV_PRODUTOS, CIRURGIA
              WHERE cd_aviso_cirurgia IN (
               SELECT cd_aviso_cirurgia FROM AGE_CIR  WHERE Trunc(dt_inicio_age_cir) BETWEEN Trunc(sysdate) and Trunc(SYSDATE+1))
              AND IT_AV_PRODUTOS.cd_cirurgia = CIRURGIA.CD_CIRURGIA
              GROUP BY CIRURGIA.DS_CIRURGIA ) t1 ) T1,
             ( SELECT 
               Sum(qtd) total
               ,'PROCEDIMENTO' AS PRC
               FROM (

                   SELECT Count(CIRURGIA_AVISO.CD_CIRURGIA) QTD
                          ,CIRURGIA.DS_CIRURGIA
                     FROM AGE_CIR
                                ,CIRURGIA_AVISO
                                ,CIRURGIA
                     WHERE Trunc(AGE_CIR.dt_inicio_age_cir) BETWEEN Trunc(sysdate) and Trunc(SYSDATE+1)
                     AND AGE_CIR.cd_aviso_cirurgia = CIRURGIA_AVISO.cd_aviso_cirurgia
                     AND CIRURGIA_AVISO.CD_CIRURGIA = CIRURGIA.CD_CIRURGIA
                     GROUP BY CIRURGIA.DS_CIRURGIA ) T2 )T2