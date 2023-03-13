 /*
   NOME: RAFAEL RAMOS , DATA:12/07/2022

   Legenda sobre situação dos leitos: O - Ocup. por paciente, V - Vago, L - Em Limpeza, I - Ocup. por infecção, R - Ocup. por reserva, A - Acompanhante, E - Reforma, M - Manutenção, N - Interdição, C - Interditado por Infecção, T - Interditado Temporariamente;
   
   Obs: REALIZADO AJUSTE PARA O TIPO DE LEITO 'R' NÃO CONSIDERAR COMO OCUPADO; 

*/

SELECT LTOTAL.CD_UNID_INT , LTOTAL.DS_UNID_INT, nvl(ROUND((LOC.LEITO/(LTOTAL.LEITOT/100))),0)||'%' PERCENTAGEM_OCUPACAO FROM
(SELECT COUNT(L.CD_LEITO) LEITO, U.DS_UNID_INT, L.CD_UNID_INT FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
AND   U.TP_UNID_INT = 'I'
AND   L.TP_OCUPACAO IN ('O','I','A')
AND   L.SN_EXTRA = 'N'
AND  l.tp_situacao = 'A'
AND  L.cd_unid_int not in (22,19,1,21)
GROUP BY  U.DS_UNID_INT , L.CD_UNID_INT ) LOC,

(SELECT COUNT(L.CD_LEITO) LEITOT, U.DS_UNID_INT, L.CD_UNID_INT FROM  LEITO L , UNID_INT U
WHERE L.CD_UNID_INT = U.CD_UNID_INT
AND   U.TP_UNID_INT = 'I'
AND   L.SN_EXTRA = 'N'
AND l.tp_situacao = 'A'
AND  L.cd_unid_int not in (22,19,1,21) 
GROUP BY  U.DS_UNID_INT , L.CD_UNID_INT) LTOTAL
WHERE LOC.CD_UNID_INT (+) = LTOTAL.CD_UNID_INT
order by 2



