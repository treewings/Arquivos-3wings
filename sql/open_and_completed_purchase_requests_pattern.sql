-- Solicitações de compras (abertas e concluídas mes ) - padrao (Rafael)
--P - Parcialmente atendida  C -Cancelada  A -Aberta   N -Lançamento  F -Fechada  S -Solicitada


SELECT
       * 
FROM (

SELECT 
       TIPO
      ,Count(cd_sol_com) QT_SOLIC
      ,Round(Sum(VL_TOTAL),2) VL_TOTAL
     
FROM ( 


Select   
        DISTINCT
          'FECHADO' TIPO  
         ,SOL_COM.cd_sol_com           cd_sol_com
         ,Count(sol_com.cd_sol_com)    QT_SOLIC
         ,Nvl(sol_com.VL_TOTAL,0)      VL_TOTAL



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
AND      produto.sn_padronizado = 'S'
AND      TP_SITUACAO IN ('F')
and      estoque.cd_multi_empresa = 1
AND      DT_SOL_COM BETWEEN  (SYSDATE-30)  AND  SYSDATE
AND      SOL_COM.DT_MAXIMA BETWEEN (SYSDATE-30) AND SYSDATE

GROUP BY SOL_COM.cd_sol_com,sol_com.VL_TOTAL
ORDER BY 2 

)  GROUP BY TIPO 


UNION ALL


SELECT 
       TIPO
      ,Count(cd_sol_com) QT_SOLIC
      ,Round(Sum(VL_TOTAL),2) VL_TOTAL
     
FROM ( 


Select   
        DISTINCT
          'ABERTO' TIPO  
         ,SOL_COM.cd_sol_com           cd_sol_com
         ,Count(sol_com.cd_sol_com)    QT_SOLIC
         ,Nvl(sol_com.VL_TOTAL,0)      VL_TOTAL
         ,sol_com.dt_sol_com


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
AND      produto.sn_padronizado = 'S'
and      itsol_com.cd_mot_cancel is NULL
AND      TP_SITUACAO IN ('A','P', 'S')
AND      sol_com.tp_sol_com = 'P'
and      estoque.cd_multi_empresa = 1
AND      nvl(itsol_com.qt_atendida,0) < nvl(itsol_com.qt_solic,0)
AND      (itsol_com.qt_atendida IS NULL OR itsol_com.qt_atendida < itsol_com.qt_solic)
AND      DT_SOL_COM BETWEEN  (SYSDATE-180)  AND  SYSDATE
AND      SOL_COM.DT_MAXIMA BETWEEN (SYSDATE-180) AND SYSDATE


GROUP BY SOL_COM.cd_sol_com,sol_com.VL_TOTAL,sol_com.dt_sol_com
ORDER BY 5 

)  GROUP BY TIPO

)

 