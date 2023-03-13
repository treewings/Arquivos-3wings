SELECT Count (CD_LEITO) QTD_LEITOS
FROM(
SELECT CD_LEITO,
       DS_LEITO
FROM leito
 WHERE tp_situacao = 'A'
     )