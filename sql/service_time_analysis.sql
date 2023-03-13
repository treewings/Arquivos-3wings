 -- Análise do tempo de atendimento (das solciitações) - Padrão 
 -- top 10 solicitações abertas mais antigas 
--tp_situacao (solicitaçao) --P - Parcialmente atendida  C -Cancelada  A -Aberta   N -Lançamento  F -Fechada  S -Solicitada
SELECT  ROWNUM || 'o' "RANK"  
                
         , QT_DIAS
         , QTD_SOLICITACOES
         
 FROM (
SELECT   QT_DIAS
        ,COUNT(QT_DIAS) AS QTD_SOLICITACOES
        
      
 FROM (

 
Select   
        DISTINCT
          'ABERTO' TIPO  
         ,SOL_COM.cd_sol_com           cd_sol_com
         ,Count(sol_com.cd_sol_com)    QT_SOLIC
         ,Nvl(sol_com.VL_TOTAL,0)      VL_TOTAL
         ,sol_com.dt_sol_com
         ,Round (SYSDATE - sol_com.DT_SOL_COM) qt_dias


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



GROUP BY SOL_COM.cd_sol_com,sol_com.VL_TOTAL,sol_com.dt_sol_com
ORDER BY 5 
 

)
GROUP BY QT_DIAS

ORDER BY qt_dias DESC 
)  WHERE  ROWNUM < 11
