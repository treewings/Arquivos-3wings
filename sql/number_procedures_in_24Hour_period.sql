/* numeros de procedimentos no periodo de 24h*/

SELECT 
               Sum(qtd) nr_procedimento_24h 
               FROM (

                   SELECT Count(CIRURGIA_AVISO.CD_CIRURGIA) QTD
                          ,CIRURGIA.DS_CIRURGIA
                     FROM AGE_CIR
                                ,CIRURGIA_AVISO
                                ,CIRURGIA
                     WHERE Trunc(AGE_CIR.dt_inicio_age_cir) BETWEEN Trunc(sysdate) and Trunc(SYSDATE+1)
                     AND AGE_CIR.cd_aviso_cirurgia = CIRURGIA_AVISO.cd_aviso_cirurgia
                     AND CIRURGIA_AVISO.CD_CIRURGIA = CIRURGIA.CD_CIRURGIA
                     GROUP BY CIRURGIA.DS_CIRURGIA ) T2

  
