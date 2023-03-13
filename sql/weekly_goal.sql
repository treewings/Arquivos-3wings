-- % a soma de tudo fechado na semana / pelo total de solicitações da semana(ABERTA, FECHADA, PARC ATEND ... ETC)
-- PAINEL DE META SEMANA - NÃO PADRÃO
-- RAFAEL RAMOS

SELECT 
       TIPO
      ,semana
      ,QT_SOLIC
      ,total_semanas
      ,CASE WHEN SEMANA = 1 THEN percentual_atendido_semana1
             WHEN SEMANA = 2 THEN percentual_atendido_semana2 
              WHEN SEMANA = 3 THEN percentual_atendido_semana3
               WHEN SEMANA = 4 THEN percentual_atendido_semana4
                 WHEN SEMANA = 5 THEN percentual_atendido_semana5
        END PERCENTUAL_ATENDIDO



FROM ( 


SELECT 
       TIPO
      ,semana
      ,QT_SOLIC
      ,TOTAL_SEMANAS
      ,Round(CASE WHEN SEMANA = 1 THEN ((SELECT tscm_calculo_metas('FECHADO',1,'N') FROM dual)*100)/TOTAL_SEMANAS END ,1)percentual_atendido_semana1
      ,Round(CASE WHEN SEMANA = 2 THEN ((SELECT tscm_calculo_metas('FECHADO',2,'N') FROM dual)*100)/TOTAL_SEMANAS END ,1)percentual_atendido_semana2
      ,Round(CASE WHEN SEMANA = 3 THEN ((SELECT tscm_calculo_metas('FECHADO',3,'N') FROM dual)*100)/TOTAL_SEMANAS END ,1)percentual_atendido_semana3
      ,Round(CASE WHEN SEMANA = 4 THEN ((SELECT tscm_calculo_metas('FECHADO',4,'N') FROM dual)*100)/TOTAL_SEMANAS END ,1)percentual_atendido_semana4
      ,Round(CASE WHEN SEMANA = 5 THEN ((SELECT tscm_calculo_metas('FECHADO',5,'N') FROM dual)*100)/TOTAL_SEMANAS END ,1)percentual_atendido_semana5

FROM (


SELECT 
        TIPO
       ,semana
       ,QT_SOLIC
       ,CASE WHEN SEMANA = 1 THEN TOTAL_SEMANA1
             WHEN SEMANA = 2 THEN TOTAL_SEMANA2 
             WHEN SEMANA = 3 THEN TOTAL_SEMANA3
             WHEN SEMANA = 4 THEN TOTAL_SEMANA4
             WHEN SEMANA = 5 THEN TOTAL_SEMANA5
         END TOTAL_SEMANAS

FROM ( 

 SELECT 
        TIPO
       ,semana
       ,QT_SOLIC
       ,CASE WHEN semana = 1 AND tipo = 'FECHADO' THEN qt_solic + aberto_acrescimo1 END TOTAL_SEMANA1
       ,CASE WHEN semana = 2 AND tipo = 'FECHADO' THEN qt_solic + aberto_acrescimo2 END TOTAL_SEMANA2
       ,CASE WHEN semana = 3 AND tipo = 'FECHADO' THEN qt_solic + aberto_acrescimo3 END TOTAL_SEMANA3
       ,CASE WHEN semana = 4 AND tipo = 'FECHADO' THEN qt_solic + aberto_acrescimo4 END TOTAL_SEMANA4
       ,CASE WHEN semana = 5 AND tipo = 'FECHADO' THEN qt_solic + aberto_acrescimo5 END TOTAL_SEMANA5

FROM (

SELECT  TIPO
        ,semana
        ,Nvl(QT_SOLIC,0) QT_SOLIC
                                                     
                                                                                                        
        ,Nvl(CASE WHEN SEMANA = 1  THEN (SELECT tscm_calculo_metas('ABERTO',1,'N') teste FROM dual) END,0) aberto_acrescimo1

        ,Nvl(CASE WHEN SEMANA = 2  THEN (SELECT tscm_calculo_metas('ABERTO',2,'N') teste FROM dual) END,0) aberto_acrescimo2
        
        ,Nvl(CASE WHEN SEMANA = 3  THEN (SELECT tscm_calculo_metas('ABERTO',3,'N') teste FROM dual) END,0) aberto_acrescimo3
        
        ,Nvl(CASE WHEN SEMANA = 4  THEN (SELECT tscm_calculo_metas('ABERTO',4,'N') teste FROM dual) END,0)aberto_acrescimo4 
       
        ,Nvl(CASE WHEN SEMANA = 5 THEN  (SELECT tscm_calculo_metas('ABERTO',5,'N') teste FROM dual) END,0) aberto_acrescimo5 


FROM (
 
 
 SELECT 
       TIPO
       ,semana
       ,QT_SOLIC

FROM (


SELECT 
       TIPO
       ,semana
       ,QT_SOLIC
       

FROM (

------------------------------------------- SOLICITAÇÕES ABERTAS -------------------------------------------


SELECT  TIPO
       ,semana
       ,Count (QT_SOLIC) QT_SOLIC

FROM (

SELECT 
       TIPO,
       CD_SOL_COM,
       dt_sol_com,
       Sum (QT_SOLIC) QT_SOLIC,
       semana

FROM (


SELECT 
       DISTINCT
       TIPO,
       cd_sol_com,
       dt_sol_com,
       COUNT (cd_sol_com) OVER ( PARTITION BY cd_sol_com) QT_SOLIC,
       semana
  
       
FROM ( 

Select      
          'ABERTO' TIPO          
         ,sol_com.cd_sol_com          cd_sol_com
         ,sol_com.dt_sol_com           dt_sol_com
      
         ,itsol_com.qt_solic                  qt_solic
         ,produto.cd_produto           cd_produto
         ,to_char(sol_com.DT_SOL_COM ,'W')  semana 
     

From      dbamv.sol_com               sol_com
         ,dbamv.itsol_com             itsol_com
         ,dbamv.cotador               cotador
         ,dbamv.setor                 setor
         ,dbamv.estoque               estoque
         ,dbamv.produto               produto
         ,dbamv.uni_pro               uni_pro
         ,dbamv.mot_ped               mot_ped


WHERE    sol_com.cd_sol_com     = itsol_com.cd_sol_com
and      sol_com.cd_cotador     = cotador.cd_cotador(+)
and      sol_com.cd_setor       = setor.cd_setor
and      sol_com.cd_estoque     = estoque.cd_estoque
and      itsol_com.cd_produto   = produto.cd_produto
and      itsol_com.cd_uni_pro   = uni_pro.cd_uni_pro
and      sol_com.cd_mot_ped     = mot_ped.cd_mot_ped
AND      produto.sn_padronizado = 'N'
and      itsol_com.cd_mot_cancel is NULL
AND      TP_SITUACAO IN ('A','P', 'S')
AND      sol_com.tp_sol_com = 'P'
and      estoque.cd_multi_empresa = 1
AND      nvl(itsol_com.qt_atendida,0) < nvl(itsol_com.qt_solic,0)
AND      (itsol_com.qt_atendida IS NULL OR itsol_com.qt_atendida < itsol_com.qt_solic)
AND      sol_com.DT_SOL_COM BETWEEN  trunc(SYSDATE,'MM') and trunc(LAST_DAY(SYSDATE))


GROUP BY sol_com.dt_sol_com ,itsol_com.qt_solic ,produto.cd_produto,sol_com.cd_sol_com,sol_com.DT_SOL_COM
ORDER BY 2  

) 

GROUP BY TIPO,cd_sol_com,dt_sol_com,semana

) GROUP BY TIPO,CD_SOL_COM,dt_sol_com,semana 



 UNION ALL

------------------------------------------- SOLICITAÇÕES FECHADAS -------------------------------------------


 SELECT 
       TIPO,
       CD_SOL_COM,
       dt_sol_com,
       Sum (QT_SOLIC) QT_SOLIC,
       semana

FROM (


SELECT 
       DISTINCT
       TIPO,
       cd_sol_com,
       dt_sol_com,
       COUNT (cd_sol_com) OVER ( PARTITION BY cd_sol_com) QT_SOLIC,
       semana
FROM ( 

Select      
          'FECHADO' TIPO          
         ,sol_com.cd_sol_com          cd_sol_com
         ,sol_com.dt_sol_com           dt_sol_com
         ,itsol_com.qt_solic           qt_solic
         ,to_char(sol_com.DT_SOL_COM ,'W')  semana
         ,produto.cd_produto           cd_produto
     

From      dbamv.sol_com               sol_com
         ,dbamv.itsol_com             itsol_com
         ,dbamv.cotador               cotador
         ,dbamv.setor                 setor
         ,dbamv.estoque               estoque
         ,dbamv.produto               produto
         ,dbamv.uni_pro               uni_pro
         ,dbamv.mot_ped               mot_ped


WHERE    sol_com.cd_sol_com     = itsol_com.cd_sol_com
and      sol_com.cd_cotador     = cotador.cd_cotador(+)
and      sol_com.cd_setor       = setor.cd_setor
and      sol_com.cd_estoque     = estoque.cd_estoque
and      itsol_com.cd_produto   = produto.cd_produto
and      itsol_com.cd_uni_pro   = uni_pro.cd_uni_pro
and      sol_com.cd_mot_ped     = mot_ped.cd_mot_ped
AND      sol_com.tp_sol_com = 'P'
AND      produto.sn_padronizado = 'N'
AND      TP_SITUACAO IN ('F')
and      estoque.cd_multi_empresa = 1
AND      sol_com.DT_SOL_COM BETWEEN  trunc(SYSDATE,'MM') and trunc(LAST_DAY(SYSDATE))


GROUP BY sol_com.dt_sol_com ,itsol_com.qt_solic ,produto.cd_produto,sol_com.cd_sol_com,sol_com.DT_SOL_COM
ORDER BY 2  

) 

GROUP BY TIPO,cd_sol_com,dt_sol_com,semana

) GROUP BY TIPO,CD_SOL_COM,dt_sol_com,semana


) GROUP BY TIPO
           ,semana

  ORDER BY 2 
                                                    
)))))))