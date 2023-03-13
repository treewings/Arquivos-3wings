SELECT a.cd_atendimento
      ,l.ds_leito
      ,p.nm_paciente
      ,p.dt_nascimento
      ,dbamv.fn_idade(p.dt_nascimento, 'a A', sysdate) idade
      ,fnc_tscm_dev(a.cd_atendimento, 'ISO')  isolamento
      ,fnc_tscm_dev(a.cd_atendimento, 'A') alergia
      ,dbamv.fnc_mvpep_retorna_sinal_vital(a.cd_atendimento,'P') peso
      ,fnc_tscm_dev(a.cd_atendimento, 'SAE') SAE
      ,Nvl(fnc_tscm_dev(a.cd_atendimento, 'P'),'NTP') prescricao
      ,fnc_tscm_dev(a.cd_atendimento, 'D') dieta
      ,fnc_tscm_dev(a.cd_atendimento, 'ESP') especialidade
      ,fnc_tscm_dev(a.cd_atendimento, 'LAB') QTD_EXAME_LAB
      ,fnc_tscm_dev(a.cd_atendimento, 'LABR') QTD_LAB_RESULTADO
      ,fnc_tscm_dev(a.cd_atendimento, 'EXA') QTD_EX_IMAG
      ,fnc_tscm_dev(a.cd_atendimento, 'EXAR') RESULTADO_IMAGEM
      ,fnc_tscm_dev(a.cd_atendimento,'DISN','Dispositivo_incluido_1',244) dispositivo
      ,fnc_tscm_dev(a.cd_atendimento,'DIS','Lista_dispositivo_inserida_1',357) curativo
      ,fnc_tscm_dev(a.cd_atendimento, 'NP') nao_padronizado
      ,fnc_tscm_dev(a.cd_atendimento, 'PWESR') PEWS
      ,fnc_tscm_dev(a.cd_atendimento, 'PWEST') DTPEWS
      ,fnc_tscm_dev(a.cd_atendimento, 'PRO') PROCEDIMENTO
      ,fnc_tscm_dev(a.cd_atendimento, 'PRODT') PRODT
      ,u.cd_unid_int as cd_unid_int
      ,u.ds_unid_int as ds_unid_int
      ,a.dt_alta_medica
  FROM dbamv.paciente p
       ,dbamv.atendime a
       ,dbamv.leito    l
       ,dbamv.unid_int u

WHERE p.cd_paciente   = a.cd_paciente
AND   a.cd_leito      = l.cd_leito
AND   l.cd_unid_int   = u.cd_unid_int
AND   u.tp_unid_int = 'I'
AND   u.sn_ativo = 'S'
AND   a.dt_alta       IS NULL

order by l.ds_leito asc
