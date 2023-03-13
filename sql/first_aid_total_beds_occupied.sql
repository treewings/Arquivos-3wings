SELECT SUM(TOTAL_LEITOS_OCUPADOS) TOTAL
FROM

 (SELECT
 COUNT(A.CD_ATENDIMENTO) TOTAL_LEITOS_OCUPADOS
 FROM LEITO L,
 ATENDIME A

 WHERE L.CD_LEITO = A.CD_LEITO
 AND L.TP_OCUPACAO IN ('O','I')

AND L.CD_UNID_INT IN (19,21,22,23,30)
 AND A.DT_ALTA IS NULL

union all

SELECT DISTINCT count (pm.cd_atendimento) TOTAL_LEITOS_OCUPADOS
                      FROM ITPRE_MED IT,
                           PRE_MED PM,
                           atendime aa

                    WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
                    AND   PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
                    AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
                    AND  PM.TP_PRE_MED = 'M'
                    AND  AA.TP_ATENDIMENTO = 'U'
                    and  (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
                    To_Char(sysdate - 1, 'hh24:mi:ss')))
                    and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
                    and aA.dt_alta is null
                    and aA.cd_leito is null)