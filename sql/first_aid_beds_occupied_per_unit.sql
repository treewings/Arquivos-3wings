 SELECT P_1.UNIDADE,
 SUM(P_1.QTD)QTD
 FROM

 (select distinct
         'REAVALIACAO',
       DECODE(u3.ds_unid_int,
                      'OBSERVACAO PRONTO ATENDIMENTO','REAVALIACAO',u3.ds_unid_int)UNIDADE,
        count (a.cd_atendimento) qtd
 from atendime a,
      leito l3,
      unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where  a.cd_leito = l3.cd_leito (+)
 and  l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND not exists
                (select 'X'
                  from vdic_pw_resposta_documento pv
                    where pv.Cd_Paciente = a.cd_paciente
                      and pv.Cd_Documento = 36
                      and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
                      and pv.Tp_Status in ('FECHADO','ASSINADO'))
 group by u3.ds_unid_int

 UNION ALL

  select distinct
         'SOLICITADO INTERNACAO',
       DECODE(u3.ds_unid_int,'OBSERVACAO PRONTO ATENDIMENTO','SOLICITADO INTERNACAO',u3.ds_unid_int)UNIDADE,
        count (a.cd_atendimento) qtd
 from atendime a,
      leito l3,
      unid_int u3
 --where trunc (a.dt_atendimento) between sysdate-1 and sysdate
 where  a.cd_leito = l3.cd_leito (+)
 and  l3.cd_unid_int = u3.cd_unid_int (+)
 and u3.cd_unid_int IN (19,21,22,23,30)
 and a.dt_alta is null
 AND  exists
                (select 'X'
                  from vdic_pw_resposta_documento pv
                    where pv.Cd_Paciente = a.cd_paciente
                      and pv.Cd_Documento = 36
                      and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
                      and pv.Tp_Status in ('FECHADO','ASSINADO'))
 group by u3.ds_unid_int

 UNION ALL

 SELECT DISTINCT NULL,
 'REAVALIACAO' UNIDADE,
 count (pm.cd_atendimento) QTD
 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa

 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and not exists
                (select 'X'
                  from vdic_pw_resposta_documento pv
                    where pv.Cd_Paciente = aa.cd_paciente
                      and pv.Cd_Documento = 36
                      and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
                      and pv.Tp_Status in ('FECHADO','ASSINADO'))


 union all

 SELECT DISTINCT NULL,
 'SOLICITADO INTERNACAO' UNIDADE,
 count (pm.cd_atendimento) QTD
 FROM ITPRE_MED IT,
 PRE_MED PM,
 atendime aa

 WHERE IT.CD_PRE_MED = PM.CD_PRE_MED
 AND PM.CD_ATENDIMENTO = Aa.CD_ATENDIMENTO
 AND IT.CD_TIP_PRESC IN (4437,4445,3118,829,3218,2385)
 AND PM.TP_PRE_MED = 'M'
 AND AA.TP_ATENDIMENTO = 'U'
 and (aA.Dt_Atendimento > Trunc(SysDate - 1) Or(aA.Dt_Atendimento = Trunc(SysDate - 1) And To_Char(aA.Hr_Atendimento, 'hh24:mi:ss') >
 To_Char(sysdate - 1, 'hh24:mi:ss')))
 and NVL(aA.dt_alta, TRUNC(SYSDATE + 1000)) = TRUNC(SYSDATE + 1000)
 and aA.dt_alta is null
 and aA.cd_leito is null
 and exists
                (select 'X'
                  from vdic_pw_resposta_documento pv
                    where pv.Cd_Paciente = aa.cd_paciente
                      and pv.Cd_Documento = 36
                      and trunc (pv.Dh_Fechamento) = to_date(sysdate,'dd/mm/rrrr')
                      and pv.Tp_Status in ('FECHADO','ASSINADO'))

 ORDER BY 2 DESC
 )P_1

 GROUP BY P_1.UNIDADE
