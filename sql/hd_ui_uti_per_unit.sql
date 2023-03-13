--PAINEL POR AREA -- ANDRA 
-- retirado filtro para trazer todas a unidades - solicitado via email por Hallan em 04/06/22 
--hd_ui_uti_per_unit
SELECT DISTINCT DS_UNID_INT,
                SITUACAO,
                DS_RESUMO, 
               -- CD_ATENDIMENTO, 
                DATA1,
                --DATA2,
                STATUS_PRESCRICAO,
                STATUS_COR,
                qtd_presc,                      
                feito,   
                qtd_pend_presc,  
                LABORATORIO_STATUS,   
                QTD_EXAMES_LAB,  
                QTD_PEND_LAB,
                IMAGEM_STATUS,  
                QTD_EX_IMAG,                           
                QTD_PEND_IMAG, 
                TEMPO_MANUTENCAO        
FROM (     

SELECT DISTINCT SITUACAO,
                CD_LEITO,
                DS_RESUMO,
                DS_UNID_INT,
                CD_ATENDIMENTO,
                NM_PACIENTE,
                DATA1,
                DATA2,
                STATUS_COR,
                qtd_presc,   
                feito,
                STATUS_PRESCRICAO,
                qtd_pend_presc,
                ITEM_MED,
                MEDICAMENTO,
                LABORATORIO_STATUS,
                Nvl (QTD_EXAMES_LAB,0) QTD_EXAMES_LAB,
                Nvl (QTD_EXAMES_RESULT_LAB,0)QTD_EXAMES_RESULT_LAB,
                Nvl (QTD_PEND_LAB,0)QTD_PEND_LAB,
                IMAGEM_STATUS,
                Nvl (QTD_EX_IMAG,0)QTD_EX_IMAG,
                Nvl (QTD_RESULTADO_IMAG,0)QTD_RESULTADO_IMAG,
                Nvl (QTD_PEND_IMAG,0)QTD_PEND_IMAG,
                NULL  TEMPO_MANUTENCAO
FROM(
SELECT DISTINCT   CASE WHEN TP_OCUPACAO IN ('O','I','A') THEN 'OCUPADO' END SITUACAO,
                  L.CD_LEITO,
                  L.DS_RESUMO,
                  U.DS_UNID_INT,                             
                  A.CD_ATENDIMENTO , 
                  P.NM_PACIENTE, 
                  PRESCRICAO.DATA1,
                  PRESCRICAO.DATA2,
                  STATUS_PRESCRICAO.STATUS_COR,
                  STATUS_PRESCRICAO.qtd_presc,
                  STATUS_PRESCRICAO.feito,
                  STATUS_PRESCRICAO.STATUS_PRESCRICAO,
                  CASE WHEN  Nvl (STATUS_PRESCRICAO.feito,0) = 0 THEN  Nvl (STATUS_PRESCRICAO.qtd_presc,0)
                  ELSE (STATUS_PRESCRICAO.qtd_presc - STATUS_PRESCRICAO.feito)END  qtd_pend_presc, 
                    
                  ITEM_MED.STATUS ITEM_MED,        
                  (CASE WHEN ITEM_MED.STATUS = 'SIM' THEN NVL(TO_CHAR(TEMPO_MED.DH_PROCESSO,'HH24:MI'),'PENDENTE') ELSE
                  CASE WHEN TO_CHAR(PRESCRICAO.DATA1,'HH24:MI') IS NULL  THEN NULL  ELSE 'NAO TEM' END  END) AS MEDICAMENTO, -- MEDICAMENTO
 
                 (CASE WHEN ITEM_LAB.STATUS = 'SIM' THEN --QUANDO O PACIENTE TEM ITEM DE LABORATORIO
                  CASE WHEN QTD_LAB_RESULTADO.QTD = QTD_EXAME_LAB.QTD  THEN 'DISPONIVEL' ELSE NVL(TO_CHAR(TEMPO_LAB.DH_PROCESSO,'HH24:MI'),'PENDENTE') END --DATA HORA DA COLETA
             ELSE CASE WHEN TO_CHAR(PRESCRICAO.DATA1,'HH24:MI') IS NULL   THEN NULL ELSE 'NAO TEM' END  END) AS LABORATORIO_STATUS,  --STATUS LABORATORIO
                  QTD_EXAME_LAB.QTD AS QTD_EXAMES_LAB,
                  QTD_LAB_RESULTADO.QTD AS QTD_EXAMES_RESULT_LAB,

                  CASE WHEN Nvl (QTD_LAB_RESULTADO.QTD,0) = 0 THEN  Nvl (QTD_EXAME_LAB.QTD,0)
                  ELSE Nvl (QTD_EXAME_LAB.QTD,0)- Nvl (QTD_LAB_RESULTADO.QTD,0) END  QTD_PEND_LAB,

                  (CASE WHEN ITEM_IMAGEM.STATUS = 'SIM' THEN --QUANDO O PACIENTE TEM ITEM DE imagem
                  CASE WHEN RESULTADO_IMAGEM.QTD = QTD_EX_IMAG.QTD  THEN 'DISPONIVEL' ELSE NVL(TO_CHAR(TEMPO_IMA.DH_PROCESSO,'HH24:MI'),'PENDENTE') END --DATA HORA DA COLETA
             ELSE CASE WHEN TO_CHAR(PRESCRICAO.DATA1,'HH24:MI') IS NULL   THEN NULL ELSE 'NAO TEM' END  END) AS IMAGEM_STATUS,  --STATUS IMAGEM 

                  QTD_EX_IMAG.QTD AS QTD_EX_IMAG, 
                  RESULTADO_IMAGEM.QTD QTD_RESULTADO_IMAG,

                  

                  CASE WHEN Nvl (RESULTADO_IMAGEM.QTD,0) = 0 THEN   Nvl (QTD_EX_IMAG.QTD,0)
             ELSE Nvl (QTD_EX_IMAG.QTD,0) - Nvl (RESULTADO_IMAGEM.QTD,0) END QTD_PEND_IMAG
              
     
--------------------inicio------------------------------------------------------------------- 
 FROM 
(SELECT Max (PM1.DH_IMPRESSAO) AS DATA1,
          MIN(PM1.DH_IMPRESSAO) AS DATA2,
          PM1.CD_ATENDIMENTO
 FROM PRE_MED PM1
  WHERE  PM1.dt_referencia >= trunc(SYSDATE) 
 -- AND  PM1.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  comentado em 05/06/22
  AND PM1.TP_PRE_MED = 'M'    
 GROUP BY PM1.CD_ATENDIMENTO 
)PRESCRICAO,                                          

(SELECT PM2.CD_ATENDIMENTO,
            'SIM' AS STATUS,
             TO_CHAR(PM2.DT_PRE_MED, 'HH24:MI') AS HORA                           
     FROM PRE_MED PM2,
          ITPRE_MED IPM2,
          TIP_ESQ TP2     
 WHERE IPM2.CD_TIP_ESQ IN ('ASP','ANT','INA','MED','MEF','MPP','MPS','MSP','SOR','UME','UAT','UMD','PRO') 
   AND TP2.CD_TIP_ESQ = IPM2.CD_TIP_ESQ
   AND IPM2.CD_PRE_MED = PM2.CD_PRE_MED 
  -- AND  PM2.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND PM2.dt_referencia >= trunc(SYSDATE)  
   AND PM2.DH_IMPRESSAO is not NULL
)ITEM_MED,  -- prescriçao de medicaçao 
    
(SELECT MIN(SACR2.DH_PROCESSO) AS DH_PROCESSO,
        SACR2.CD_ATENDIMENTO AS CD_ATENDIMENTO  
 FROM SACR_TEMPO_PROCESSO SACR2 --MEDI
 WHERE SACR2.CD_TIPO_TEMPO_PROCESSO = 71
 AND SACR2.DH_PROCESSO >= trunc(SYSDATE)
    GROUP BY SACR2.CD_ATENDIMENTO
)TEMPO_MED,

(SELECT PM3.CD_ATENDIMENTO, 'SIM' AS STATUS  
 FROM PRE_MED PM3,
      ITPRE_MED IPM3,
      TIP_ESQ TP3  
 WHERE IPM3.CD_TIP_ESQ IN ('LAB', 'LIQ', 'LAP', 'LAO')
   AND IPM3.CD_PRE_MED = PM3.CD_PRE_MED
   AND TP3.CD_TIP_ESQ = IPM3.CD_TIP_ESQ    
   AND PM3.DH_IMPRESSAO is not NULL
   --AND PM3.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND PM3.dt_referencia >= trunc(SYSDATE)  
) ITEM_LAB,     

(SELECT DISTINCT  COUNT(DISTINCT RE8.CD_EXA_LAB) AS QTD,
         A8.CD_ATENDIMENTO
 FROM ATENDIME A8,
      PRE_MED P,
      ITPRE_MED IP,  
      PED_LAB PL8,
      ITPED_LAB IPL8, 
      RES_EXA RE8
 WHERE P.cd_atendimento = A8.CD_ATENDIMENTO
   AND RE8.DS_RESULTADO IS NOT NULL  
   AND PL8.CD_ATENDIMENTO = A8.CD_ATENDIMENTO
   AND IP.CD_PRE_MED = P.CD_PRE_MED
   AND IPL8.CD_PED_LAB = PL8.CD_PED_LAB
   AND  RE8.Cd_Ped_Lab = Pl8.Cd_Ped_Lab(+)
   AND IP.CD_TIP_ESQ IN ('LAB', 'LIQ', 'LAP', 'LAO')
  -- AND P.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND IPL8.dt_laudo IS NOT NULL
   AND PL8.dt_pedido >= trunc(SYSDATE)                                
 GROUP BY A8.CD_ATENDIMENTO  --- Resultado
 ORDER BY A8.CD_ATENDIMENTO DESC
 )QTD_LAB_RESULTADO,
 
(SELECT MIN(SACR3.DH_PROCESSO) AS DH_PROCESSO,
 SACR3.CD_ATENDIMENTO AS CD_ATENDIMENTO 
 FROM SACR_TEMPO_PROCESSO SACR3
 WHERE SACR3.CD_TIPO_TEMPO_PROCESSO = 51    ----- analisar esse processo
 AND SACR3.DH_PROCESSO >= trunc(SYSDATE)
 GROUP BY SACR3.CD_ATENDIMENTO
) TEMPO_LAB,                                       
 
(SELECT COUNT(DISTINCT IPL8.CD_EXA_LAB) AS QTD,
 PM8.CD_ATENDIMENTO
 FROM PRE_MED PM8
     ,ITPRE_MED IPM8
     ,TIP_ESQ TP8
     ,PED_LAB PL8 
     ,ITPED_LAB IPL8 

 WHERE  PM8.CD_PRE_MED = IPM8.CD_PRE_MED
   AND  IPM8.CD_TIP_ESQ = TP8.CD_TIP_ESQ 
   AND PM8.CD_PRE_MED = PL8.CD_PRE_MED    
   AND  PL8.CD_PED_LAB = IPL8.CD_PED_LAB   
   AND IPM8.CD_TIP_ESQ IN ('LAB', 'LIQ', 'LAP', 'LAO')
   AND PM8.DH_IMPRESSAO is not NULL
  -- AND PM8.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades 
   AND PL8.dt_pedido >= trunc(SYSDATE)
   --AND PM8.cd_atendimento = 1600292 --1600421
 GROUP BY PM8.CD_ATENDIMENTO      
 ORDER BY PM8.CD_ATENDIMENTO DESC

)QTD_EXAME_LAB,

(SELECT PM4.CD_ATENDIMENTO, 'SIM' AS STATUS   
 FROM PRE_MED PM4,
      ITPRE_MED IPM4,
      TIP_ESQ TP4
 WHERE IPM4.CD_TIP_ESQ IN ('EXA', 'EXP', 'EXO')
   AND IPM4.CD_PRE_MED = PM4.CD_PRE_MED   
   AND TP4.CD_TIP_ESQ = IPM4.CD_TIP_ESQ    
   AND PM4.DH_IMPRESSAO is not NULL
   --AND PM4.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND PM4.dt_referencia >= trunc(SYSDATE) ) ITEM_IMAGEM,-- prescrição exame de imagem    

(SELECT COUNT(DISTINCT ITPED_RX.cd_exa_rx) AS QTD,
        pm8.cd_atendimento
    FROM  PRE_MED PM8,
          ITPRE_MED IPM8,
          TIP_ESQ TP8,
          DBAMV.PED_RX, 
          DBAMV.ITPED_RX    
 WHERE PM8.CD_PRE_MED = PED_RX.CD_PRE_MED
   AND PED_RX.CD_PED_RX	= ITPED_RX.CD_PED_RX   
   AND IPM8.CD_TIP_ESQ IN ('EXA', 'EXP', 'EXO')
   AND IPM8.CD_PRE_MED = PM8.CD_PRE_MED
   AND TP8.CD_TIP_ESQ = IPM8.CD_TIP_ESQ  
   AND PM8.DH_IMPRESSAO is not NULL
   --AND PM8.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND PED_RX.dt_pedido >= trunc(SYSDATE)    
   GROUP BY pm8.cd_atendimento  
) QTD_EX_IMAG ,

(SELECT MIN(SACR4.DH_PROCESSO) AS DH_PROCESSO,
         SACR4.CD_ATENDIMENTO AS CD_ATENDIMENTO   
 FROM SACR_TEMPO_PROCESSO SACR4
 WHERE SACR4.CD_TIPO_TEMPO_PROCESSO = 61
 AND SACR4.DH_PROCESSO >= trunc(SYSDATE)
 GROUP BY SACR4.CD_ATENDIMENTO
) TEMPO_IMA,-- DATA_HORA EXAME DE IMAGEM 

( SELECT COUNT(DISTINCT ITPED_RX.cd_exa_rx) AS QTD,
         pm8.cd_atendimento 
    FROM  PRE_MED PM8,
          ITPRE_MED IPM8,
          TIP_ESQ TP8,
          DBAMV.PED_RX,
          DBAMV.ITPED_RX   
 WHERE PM8.CD_PRE_MED = PED_RX.CD_PRE_MED
   AND PED_RX.CD_PED_RX	= ITPED_RX.CD_PED_RX   
   AND IPM8.CD_TIP_ESQ IN ('EXA', 'EXP', 'EXO')
   AND IPM8.CD_PRE_MED = PM8.CD_PRE_MED
   AND TP8.CD_TIP_ESQ = IPM8.CD_TIP_ESQ  
   AND PM8.DH_IMPRESSAO is not NULL    
   AND ITPED_RX.cd_laudo IS NOT NULL
   AND ITPED_RX.SN_REALIZADO IS NOT NULL
   AND ITPED_RX.DT_REALIZADO IS NOT NULL
  -- AND PM8.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   AND PED_RX.dt_pedido >= trunc(SYSDATE) 
   GROUP BY pm8.cd_atendimento 
) RESULTADO_IMAGEM,
-----------------------------------------------------------------------------------------
(SELECT 
       STATUS_COR,
       CD_ATENDIMENTO,
       qtd_presc,            
       CASE WHEN status_cor = 'BRANCO' THEN Count (status_cor)END feito,
       STATUS_PRESCRICAO      

FROM (                                                                                   
SELECT DISTINCT 
CASE 
     WHEN (CLASSIFICACAO = 1 AND  STATUS <> 'NAP') THEN 'BRANCO'
     WHEN CLASSIFICACAO = 1 AND STATUS = 'NAP' THEN 'ROXO' 
     WHEN (CLASSIFICACAO <> 1 AND STATUS <> 'NAP') THEN 'BRANCO'                          
     WHEN CLASSIFICACAO <> 1 AND STATUS = 'NAP' THEN 'VERDE'  END STATUS_COR
,STATUS
,CD_ATENDIMENTO
,CD_PRE_MED                                                                               
,Count (CD_PRE_MED) OVER(PARTITION BY CD_ATENDIMENTO) qtd_presc
,classificacao                                                          
,CASE                                                                    
    WHEN CLASSIFICACAO = 1  THEN 'PRIMEIRA PRESCRICAO'
    WHEN CLASSIFICACAO <> 1 THEN 'OUTRAS' END STATUS_PRESCRICAO     
FROM(
  SELECT
      DH_IMPRESSAO,
      CD_ATENDIMENTO,
      CD_PRE_MED,
      STATUS, -- NAP = NAO APRAZADO / OUTROS = APRAZADO
      TP_PRE_MED,
      DENSE_RANK() OVER (PARTITION BY CD_ATENDIMENTO ORDER BY CD_PRE_MED) classificacao
                                                                                         
  FROM (
    SELECT 
      DH_IMPRESSAO,
      PM1.CD_ATENDIMENTO,
      PM1.CD_PRE_MED,
      DBAMV.FNC_CHECAGEM_ATENDIMENTO( PM1.CD_ATENDIMENTO,PM1.CD_PRE_MED) STATUS, -- NAP = NAO APRAZADO / OUTROS = APRAZADO
      TP_PRE_MED 
        FROM PRE_MED PM1,                                                                      
             ITPRE_MED IPM1  ,
             TIP_ESQ TP1
       WHERE IPM1.CD_PRE_MED = PM1.CD_PRE_MED                   
         AND PM1.CD_UNID_INT  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- UNIDADES  cpmentado em 05/06/22                                                                       
         AND TP1.CD_TIP_ESQ = IPM1.CD_TIP_ESQ
         AND IPM1.CD_TIP_ESQ IN ('ASP','ANT','INA','MED','MEF','MPP','MPS','MSP','SOR','UME','UAT','UMD','PRO')   
         AND PM1.DT_REFERENCIA >= TRUNC(SYSDATE) 
         AND PM1.TP_PRE_MED = 'M' 
         GROUP BY PM1.CD_ATENDIMENTO, DH_IMPRESSAO, PM1.CD_PRE_MED ,TP_PRE_MED 
         ORDER BY 2  
  ) TAB
        WHERE TAB.STATUS IS NOT NULL         
        ORDER BY TAB.DH_IMPRESSAO DESC , cd_pre_med        
     )--WHERE cd_atendimento = 1592220 --1599880
     GROUP BY classificacao,STATUS,CD_ATENDIMENTO,CD_PRE_MED
     ORDER BY 3,4,6  )
     GROUP BY STATUS_COR,
              CD_ATENDIMENTO,
              qtd_presc,STATUS_PRESCRICAO
 )STATUS_PRESCRICAO, 
------------------------------------------------------------------------------------                   
   ATENDIME A,
   PACIENTE P,
   LEITO L,
   UNID_INT U
                                           
     
-----------------------------------------------------------------------------
 WHERE  A.CD_PACIENTE = P.CD_PACIENTE
    AND A.CD_LEITO = L.CD_LEITO 
    AND L.CD_UNID_INT = U.CD_UNID_INT   
    AND PRESCRICAO.CD_ATENDIMENTO (+) = A.CD_ATENDIMENTO
    AND ITEM_MED.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO --PRESCRICAO DE MEDICACAO
    AND TEMPO_MED.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO -- TEMPO DA MEDICACAO                                         
    AND ITEM_LAB.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO --PRESCRICAO DE EXAMES LABORATORIAIS  
    AND QTD_LAB_RESULTADO.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO -- NUMERO DE ITENS LABORATORIAIS COM RESULTADO   -- analisar
    AND TEMPO_LAB.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO -- DATA_HORA COLETA EXAME LAB   
    AND QTD_EXAME_LAB.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO -- QUANTIDADE DE EXAMES LABORATORIAIS 
    AND ITEM_IMAGEM.CD_ATENDIMENTO (+)= A.CD_ATENDIMENTO --PRESCRICAO EXAME DE IMAGEM AINDA NÃO FECHADA
    AND QTD_EX_IMAG.CD_ATENDIMENTO (+) = A.CD_ATENDIMENTO   
    AND TEMPO_IMA.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO -- DATA_HORA EXAME DE IMAGEM                            
    AND RESULTADO_IMAGEM.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO             

   AND STATUS_PRESCRICAO.CD_ATENDIMENTO(+) = A.CD_ATENDIMENTO
    
  --  AND U.CD_UNID_INT IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades   comentado em 05/06/22
    AND A.TP_ATENDIMENTO = 'I'                                                                 
    AND A.DT_ALTA IS NULL 
    AND L.tp_situacao = 'A' )

 
--------------------------------leitos  --------------------------
UNION ALL 
  
SELECT DISTINCT   
      SITUACAO,
      CD_LEITO,
      DS_RESUMO,
      DS_UNID_INT,
      0 CD_ATENDIMENTO,
      NULL NM_PACIENTE,
      NULL DATA1,
      NULL DATA2,
      NULL STATUS_COR,
      0 qtd_presc,
      0 feito,
      NULL STATUS_PRESCRICAO,
      0 qtd_pend_presc,
      NULL  ITEM_MED,
      NULL MEDICAMENTO,
      NULL LABORATORIO_STATUS,
      0 QTD_EXAMES_LAB,
      0 QTD_EXAMES_RESULT_LAB,
      0 QTD_PEND_LAB,
      NULL IMAGEM_STATUS,
      0 QTD_EX_IMAG,
      0 QTD_RESULTADO_IMAG,
      0 QTD_PEND_IMAG,
      TEMPO_MANUTENCAO


FROM ( SELECT DISTINCT sit_leito.cd_leito
          ,sit_leito.leito ds_resumo --andra
          ,DS_UNID_INT
          ,CASE WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.hr_inicio_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.hr_inicio_higieniza IS NOT NULL AND solic_limpeza.dt_hr_fim_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.dt_hr_ini_pos_higieniza IS NOT NULL AND solic_limpeza.dt_hr_fim_pos_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.dt_hr_ini_rouparia IS NOT NULL AND solic_limpeza.dt_hr_fim_rouparia IS NULL THEN 'HIGIENIZACAO'
                ELSE sit_leito.situacao END SITUACAO
         ,CASE WHEN sit_leito.situacao = 'MANUTENCAO' AND solic_limpeza.hr_inicio_higieniza IS NOT NULL THEN
              SUBSTR( (CAST(solic_limpeza.hr_inicio_higieniza  AS TIMESTAMP) - CAST( SYSDATE AS TIMESTAMP) ),12,8 )
              END TEMPO_MANUTENCAO

       
    FROM ( SELECT CD_LEITO, LEITO, SITUACAO, DS_UNID_INT, CD_UNIDADE
    FROM ( SELECT CD_LEITO
          ,DS_RESUMO LEITO
          ,Decode (tp_ocupacao,'O','OCUPADO',      -- Ocup. por paciente               
                               'V','VAGO',         -- Vago
                               'L','HIGIENIZACAO', -- Limpeza
                               'I','OCUPADO',      -- Ocup. por infecc?o
                               'R','RESERVADO',    -- Ocup. por reserva
                               'A','OCUPADO',      -- Acompanhante
                               'E','REFORMA',      -- Reforma
                               'M','MANUTENCAO',   -- manutençao                                     
                               'N','INTERDICAO',   -- interdição
                               'C','INTERDITADO INFECCAO',   -- Interditado por Infecc?o
                               'T','INTERD. TEMP.') SITUACAO -- Interditado Temporariamente
                                ,unid_int.ds_unid_int DS_UNID_INT
                                ,unid_int.cd_unid_int CD_UNIDADE

    FROM leito, unid_int
    where leito.cd_unid_int = unid_int.cd_unid_int 
   -- AND   LEITO.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
   --AND   LEITO.SN_EXTRA = 'N'    
    AND   LEITO.TP_OCUPACAO NOT IN('E','N','C', 'O','A','I')      -- SELECT * FROM LEITO WHERE CD_LEITO IN (906 ,1006 )
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'                 
    ) )sit_leito,solic_limpeza  )       

UNION ALL 

SELECT DISTINCT   
      SITUACAO,
      CD_LEITO,
      DS_RESUMO,
      NULL DS_UNID_INT,
      0 CD_ATENDIMENTO,
      NULL NM_PACIENTE,
      NULL DATA1,
      NULL DATA2,
      NULL STATUS_COR,
      0 qtd_presc,
      0 feito,
      NULL STATUS_PRESCRICAO,
      0 qtd_pend_presc,
      NULL  ITEM_MED,
      NULL MEDICAMENTO,
      NULL LABORATORIO_STATUS,
      0 QTD_EXAMES_LAB,
      0 QTD_EXAMES_RESULT_LAB,
      0 QTD_PEND_LAB,
      NULL IMAGEM_STATUS,
      0 QTD_EX_IMAG,
      0 QTD_RESULTADO_IMAG,
      0 QTD_PEND_IMAG,
      NULL  TEMPO_MANUTENCAO 


FROM (
SELECT CASE WHEN tipo = 'ALTA_MEDICA' THEN 'ALTA_MEDICA' END SITUACAO,
       cd_leito,
       ds_resumo
FROM ( 
 SELECT 'ALTA_MEDICA' TIPO,
       l.cd_leito,
       ds_resumo  
 FROM  ATENDIME A
      ,LEITO  L     
                
WHERE a.CD_LEITO = L.CD_LEITO  
 -- AND l.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades  
  AND a.dt_alta IS NULL 
  AND l.tp_situacao = 'A'     
  AND trunc(a.dt_alta_medica)=TRUNC(SYSDATE))) 

UNION ALL 

SELECT  DISTINCT   
      SITUACAO,
      CD_LEITO,
      DS_RESUMO,
      NULL DS_UNID_INT,
      0 CD_ATENDIMENTO,
      NULL NM_PACIENTE,
      NULL DATA1,
      NULL DATA2,
      NULL STATUS_COR,
      0 qtd_presc,
      0 feito,
      NULL STATUS_PRESCRICAO,
      0 qtd_pend_presc,
      NULL  ITEM_MED,
      NULL MEDICAMENTO,
      NULL LABORATORIO_STATUS,
      0 QTD_EXAMES_LAB,
      0 QTD_EXAMES_RESULT_LAB,
      0 QTD_PEND_LAB,
      NULL IMAGEM_STATUS,
      0 QTD_EX_IMAG,
      0 QTD_RESULTADO_IMAG,
      0 QTD_PEND_IMAG,
      NULL  TEMPO_MANUTENCAO 

FROM (
SELECT CASE WHEN tipo = 'ALTA_HOSPITALAR' THEN 'ALTA_HOSPITALAR' END SITUACAO,
       cd_leito,
       ds_resumo 
FROM ( 
SELECT 'ALTA_HOSPITALAR' TIPO,
       l.cd_leito,
       ds_RESUMO

 FROM  ATENDIME A
      ,LEITO  L    
WHERE a.CD_LEITO = L.CD_LEITO  
 -- AND l.cd_unid_int  IN ( 45,  38,  3,5, 25, 7,  26,  27,  31, 34, 16, 30,37,28,23,39,44,29,36 ) -- unidades
  AND l.tp_situacao = 'A'
  AND L.TP_OCUPACAO IN ('O','I')
  AND A.DT_ALTA_MEDICA IS NOT NULL
  AND A.DT_ALTA IS NULL      
  AND trunc(a.dt_alta)=TRUNC(SYSDATE)                           
  ) )  
) WHERE DS_RESUMO NOT IN ( 'UTI 1006', 'UTI 906')
   
ORDER BY 1,3 ASC ,2