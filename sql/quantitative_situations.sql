-- NOVA QUERY PARA LISTAR OS STATUS DO PAINEL DE OCUPAÇAÕ GERAL (ANDRA)
-- deve se considerar como internados todos os leitos ocupados independente da undiade 
--situacoes = 'O','OCUPADO', 'V','VAGO','L','HIGIENIZACAO', 'I','OCUPADO', 'R','RESERVADO', 'A','OCUPADO','E','REFORMA',
-- 'M','MANUTENCAO','N','INTERDICAO', 'C','INTERDITADO INFECCAO', 'T','INTERD. TEMP.
-- considerar leitos operacionais como leitos dia =  (leitos operacionais + extras ocupados)

------------------------------------------------------------

SELECT TIPO
         ,QTD
    FROM (SELECT 
          'MANUTENCAO' TIPO
          ,Count (CD_LEITO) QTD
          ,DS_RESUMO            

    FROM leito
        ,unid_int
    WHERE leito.cd_unid_int = unid_int.cd_unid_int
      AND tp_ocupacao IN ('M')
      AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO
      AND LEITO.dt_desativacao is NULL
      AND UNID_INT.SN_ATIVO = 'S'
    )
UNION ALL 
             
   SELECT TIPO
         ,QTD
    FROM (SELECT 
          'RESERVA' TIPO
          ,Count (CD_LEITO) QTD
          ,DS_RESUMO            

    FROM leito
        ,unid_int
    where leito.cd_unid_int = unid_int.cd_unid_int
      AND tp_ocupacao IN ('R') 
      AND LEITO.SN_EXTRA = 'N'   
      AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO
      AND LEITO.dt_desativacao is NULL
      AND UNID_INT.SN_ATIVO = 'S'
    )
UNION ALL 

 SELECT TIPO
       ,QTD
 FROM (SELECT 
          'OCUPADO TOTAL' TIPO
          ,Count (CD_LEITO) QTD
          ,DS_RESUMO            

    FROM leito
        ,unid_int
    where leito.cd_unid_int = unid_int.cd_unid_int
    AND tp_ocupacao IN ('O','I','A')
    AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO
    AND LEITO.dt_desativacao is NULL
    AND UNID_INT.SN_ATIVO = 'S'
    )

UNION ALL


SELECT TIPO
       ,QTD
FROM (SELECT 
      'OCUPADO HD' TIPO
      ,Count (CD_LEITO) QTD
      ,DS_RESUMO            

FROM leito
    ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
  AND tp_ocupacao IN ('O','I','A')
  AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO 
  --AND UNID_INT.DS_UNID_INT LIKE '%HD%'  
  AND LEITO.dt_desativacao is NULL
  AND LEITO.CD_TIP_ACOM IN (22) --(HD - 22 )
  AND UNID_INT.SN_ATIVO = 'S' )

UNION ALL
 
SELECT TIPO
       ,QTD
FROM (SELECT 
      'VAGO HD' TIPO
      ,Count (CD_LEITO) QTD
      ,DS_RESUMO            

FROM leito
        ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
  AND tp_ocupacao IN ('V')
  AND LEITO.TP_OCUPACAO NOT IN('E','N','C','T')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO 
  AND UNID_INT.DS_UNID_INT LIKE '%HD%'
  AND LEITO.CD_TIP_ACOM IN (22) --(HD - 22 )  
  AND LEITO.dt_desativacao is NULL
  AND UNID_INT.SN_ATIVO = 'S' )

UNION ALL 
 
SELECT TIPO
       ,QTD
FROM (SELECT 
      'VAGO' TIPO
      ,Count (CD_LEITO) QTD
      ,DS_RESUMO            

FROM leito
        ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
  AND tp_ocupacao IN ('V')
  AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO 
  AND LEITO.SN_EXTRA = 'N'
  AND UNID_INT.DS_UNID_INT NOT LIKE '%HD%' 
  AND LEITO.dt_desativacao is NULL
  AND UNID_INT.SN_ATIVO = 'S')

UNION ALL  

SELECT TIPO
      ,QTD
FROM (SELECT 
      'HIGIENIZACAO' TIPO
      ,Count (CD_LEITO) QTD
      ,DS_RESUMO            

FROM leito
    ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
  AND tp_ocupacao IN ('L') 
  AND LEITO.SN_EXTRA = 'N'
  AND LEITO.TP_OCUPACAO NOT IN('E','N','C')-- E - REFORMA - N- INTERDICAO - C-INTERDITADO POR INFECÇAO
  AND LEITO.dt_desativacao is NULL
  AND UNID_INT.SN_ATIVO = 'S'  )

UNION ALL
 -- Montada de acordo com o painel de indicadores da presidencia
SELECT 'LEITO OPERACIONAL' TIPO -- LEITO DIA
       ,SUM(EXTRA + OPERACIONAL) QTD
FROM(
SELECT 'EXTRA'TIPO
       ,Sum (LEITOS_EXTRAS_OCUPADOS)EXTRA
       ,0 OPERACIONAL
FROM ((SELECT  
      COUNT(*) LEITOS_EXTRAS_OCUPADOS  
 FROM DBAMV.LEITO,
 DBAMV.UNID_INT
 WHERE LEITO.CD_UNID_INT = UNID_INT.CD_UNID_INT
 AND LEITO.DT_DESATIVACAO IS NULL
 AND LEITO.SN_EXTRA = 'S'
 AND LEITO.TP_OCUPACAO IN ('O', 'I', 'A')
 AND UNID_INT.CD_UNID_INT <> 21 -- OBSERVACAO PRONTO ATENDIMENTO
 GROUP BY UNID_INT.CD_UNID_INT,
 UNID_INT.DS_UNID_INT))    
 
 UNION ALL
 
 SELECT 'OPERACIONAL' TIPO
       ,0 EXTRA     
       ,SUM(LEITOS_OPERACIONAIS) OPERACIONAL

FROM(SELECT 
      CASE WHEN UNID_INT.CD_UNID_INT=23 OR UNID_INT.CD_UNID_INT=29 OR UNID_INT.CD_UNID_INT=30 THEN 0
      ELSE COUNT(*) END LEITOS_OPERACIONAIS

 FROM DBAMV.LEITO,
      DBAMV.UNID_INT
 WHERE LEITO.CD_UNID_INT = UNID_INT.CD_UNID_INT
 AND LEITO.DT_DESATIVACAO IS NULL
 AND LEITO.SN_EXTRA = 'N'
 AND LEITO.TP_OCUPACAO not in ('M','T','E')
 AND UNID_INT.CD_UNID_INT <> 1
 AND UNID_INT.DS_UNID_INT NOT LIKE '%HD%'
 GROUP BY UNID_INT.CD_UNID_INT,
 UNID_INT.DS_UNID_INT )
)

