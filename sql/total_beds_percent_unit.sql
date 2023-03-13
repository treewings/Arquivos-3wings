-- o calculo do % está sendo feito considerando o tipo de acomodaçao
--situacoes --'O','OCUPADO', 'V','VAGO','L','HIGIENIZACAO', 'I','OCUPADO', 'R','RESERVADO', 'A','OCUPADO','E','REFORMA',
-- 'M','MANUTENCAO','N','INTERDICAO', 'C','INTERDITADO INFECCAO', 'T','INTERD. TEMP.
-- CD_TIP_ACOM IN (1,20,24,25, 22) --(APARTAMENTO - 1,21 /  UTI - 20,24,25  /HD - 22 ) 

-- % POR UTI
SELECT 'UTI' TIPO
       ,nvl(trunc((LOC.LEITO/(LTOTAL.LEITOT/100))),0)||'%' OCUPACAO   
FROM
(SELECT COUNT(L.CD_LEITO) LEITO
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  AND L.TP_OCUPACAO IN ('O','I','A') 
  AND l.tp_situacao = 'A'
  AND U.SN_ATIVO = 'S'
  AND l.CD_TIP_ACOM IN ( 20,24,25) --(  UTI - 20,24,25 )   
  AND dt_desativacao IS NULL -- inserido 05/07 andra
  AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra

) LOC,

(SELECT COUNT(L.CD_LEITO) LEITOT
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  --AND L.SN_EXTRA = 'N'
  AND l.tp_situacao = 'A'
  AND U.SN_ATIVO = 'S'
  AND l.CD_TIP_ACOM IN ( 20,24,25) --(  UTI - 20,24,25 )
  AND dt_desativacao IS NULL -- inserido 05/07 andra
  AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra    
) LTOTAL

UNION 
-- % POR APARTAMENTO
SELECT 'APARTAMENTO' TIPO
       ,nvl(trunc((LOC.LEITO/(LTOTAL.LEITOT/100))),0)||'%' OCUPACAO
  
FROM
(SELECT COUNT(L.CD_LEITO) LEITO
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  AND L.TP_OCUPACAO IN ('O','I','A') 
  AND l.tp_situacao = 'A'
  AND U.SN_ATIVO = 'S'
  AND l.CD_TIP_ACOM IN (1, 21) --(APARTAMENTO - 1  )21 APARTAMENTO ISOLAMENTO
  AND L.DS_RESUMO LIKE '%AP %' 
  AND dt_desativacao IS NULL -- inserido 05/07 andra
  AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra
  
) LOC,

(SELECT COUNT(L.CD_LEITO) LEITOT
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  --AND L.SN_EXTRA = 'N'
  AND l.tp_situacao = 'A'
  AND l.CD_TIP_ACOM IN (1, 21) --(APARTAMENTO - 1  ) 
  AND U.SN_ATIVO = 'S'
  AND L.DS_RESUMO LIKE '%AP %'
  AND dt_desativacao IS NULL -- inserido 05/07 andra
  AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra
       
) LTOTAL


UNION    
 
-- % POR HD
SELECT 'HD' TIPO
       ,nvl(trunc((LOC.LEITO/(LTOTAL.LEITOT/100))),0)||'%' OCUPACAO
 
 FROM
(SELECT COUNT(L.CD_LEITO) LEITO
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  AND L.TP_OCUPACAO IN ('O','I','A')
  AND l.tp_situacao = 'A'
  AND l.CD_TIP_ACOM IN (22) --(HD - 22 ) 
  AND U.SN_ATIVO = 'S'
  AND dt_desativacao IS NULL -- inserido 05/07 andra
  AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra
                                                         
) LOC,

(SELECT COUNT(L.CD_LEITO) LEITOT
FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
  AND U.TP_UNID_INT = 'I'
  AND l.tp_situacao = 'A'
  AND l.CD_TIP_ACOM IN (22) --(HD - 22 ) 
  AND U.SN_ATIVO = 'S'
  AND dt_desativacao IS NULL -- inserido 05/07 andra
AND L.TP_OCUPACAO NOT IN ('T') -- inserido 05/07 andra
) LTOTAL

