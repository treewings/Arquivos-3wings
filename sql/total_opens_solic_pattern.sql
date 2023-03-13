SELECT CASE WHEN SITUACAO = 'ABERTA' THEN Sum(SOLIC_ABERTAS)  END  TOTAL_SOLIC_ABERTAS_MES_ATUAL FROM (

SELECT 
       situacao
       ,semana
       ,qt_solicitacao
       ,CASE WHEN SEMANA IN (1,2,3,4,5) AND SITUACAO = 'ABERTA' THEN Sum(qt_solicitacao) END SOLIC_ABERTAS


FROM 

(SELECT  situacao
       ,semana
       ,Count (situacao) qt_solicitacao
                                     
       
 FROM (
 
SELECT DISTINCT             
         S.CD_SOL_COM CD_SOL_COM                
        ,S.DT_SOL_COM DT_SOL_COM 
        ,O.DT_AUTORIZACAO   
        ,CASE   WHEN S.TP_SITUACAO = 'U' THEN 'AUTORIZADO'
                WHEN S.TP_SITUACAO = 'N' THEN 'LANCAMENTO'                           
                WHEN S.TP_SITUACAO = 'S' THEN 'SOLICITADA' 
                WHEN S.TP_SITUACAO = 'F' THEN 'FECHADA'                           
                WHEN S.TP_SITUACAO = 'C' THEN 'CANCELADA' 
                WHEN S.TP_SITUACAO = 'L' THEN 'LICITACAO' 
                WHEN S.TP_SITUACAO = 'P' THEN 'PARC ATENDIDA'  
                WHEN S.TP_SITUACAO = 'A' THEN 'ABERTA' 
                WHEN S.TP_SITUACAO = 'S' THEN 'SOLICITADA'
                WHEN S.TP_SITUACAO = 'P' THEN 'PRODUTO'                             
          ELSE 'SERVICO' END situacao 
          ,to_char(S.DT_SOL_COM ,'W')  semana            
                                                                     
FROM  DBAMV.SOL_COM S
     ,DBAMV.ORD_COM O  
     ,DBAMV.ITSOL_COM I
     ,DBAMV.PRODUTO P  
     --,DBAMV.ENT_PRO E
        
WHERE S.CD_SOL_COM = O.CD_SOL_COM (+)                                                       
  AND S.CD_SOL_COM = I.CD_SOL_COM (+)                                                  
  AND I.CD_PRODUTO = P.CD_PRODUTO (+)                                                     
  AND TRUNC (S.DT_SOL_COM) BETWEEN  trunc(SYSDATE,'MM') AND trunc(LAST_DAY(SYSDATE)) 
  AND P.SN_PADRONIZADO = 'S'  -- padrao
  AND S.TP_SOL_COM = 'P' -- PRODUTO
  AND S.TP_SITUACAO NOT IN ('C') 
  ORDER BY S.DT_SOL_COM

 ) 
 GROUP BY  
           situacao
          ,semana 
 ORDER BY 2           
)
 WHERE SITUACAO = 'ABERTA'
 
 GROUP BY  situacao
           ,semana
           ,qt_solicitacao
           
)  GROUP BY SITUACAO