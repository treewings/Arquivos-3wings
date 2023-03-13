------ vagas solicitadas nos ultimos 5 dias (geovanna)

SELECT
HR_SOLICITACAO,
Count(INTERNACAO_EM) INTERNACAO_EM,
CASE WHEN HR_SOLICITACAO = To_Char(SYSDATE, 'DD/MM/RRRR') THEN 'HOJE'  END DIA

FROM(
SELECT
To_Char(xx.hr_solicitacao,'DD/MM/RRRR') hr_solicitacao,
 case when vaga.uti = 'false'
 then 'UI'
 else 'UTI'
 end internacao_em

 from

 ( select a.cd_atendimento,
 a.cd_paciente,
 p.nm_paciente,
 fn_idade_tascom(p.dt_nascimento, 'a A m M d D', a.dt_atendimento)idade,
 documento.dh_fechamento hr_solicitacao,
 co.nm_convenio
 from dbamv.atendime a,
 dbamv.paciente p,
 dbamv.convenio co,
 (select distinct pdc.cd_atendimento,
 pdc.dh_fechamento
 from dbamv.pw_documento_clinico pdc,
 dbamv.pw_editor_clinico pec,
 dbamv.atendime aa
 where pdc.cd_documento_clinico = pec.cd_documento_clinico
 and pdc.cd_atendimento = aa.cd_atendimento
 and pec.cd_documento = 36
 and tp_status in ('FECHADO','ASSINADO')
-- and trunc (pdc.dh_fechamento) >= sysdate-2
 and aa.tp_atendimento = 'U') documento
 where a.cd_paciente = p.cd_paciente
 and a.cd_convenio = co.cd_convenio
 and a.cd_atendimento = documento.cd_atendimento) xx,


 (select max(ax.cd_atendimento) cd_atendimento_new,
 ax.cd_paciente
 from dbamv.atendime ax
 where ax.tp_atendimento in ('I', 'U')
 group by ax.cd_paciente ) att,
 (select dbms_lob.substr(erc.lo_valor, 5,1) UTI,
 dbms_lob.substr(erc2.lo_valor, 5,1) UI,
 pdc.cd_atendimento
 from dbamv.pw_documento_clinico pdc,
 dbamv.pw_editor_clinico pec,
 dbamv.editor_campo ec,
 dbamv.editor_registro_campo erc,
 dbamv.editor_campo ec2,
 dbamv.editor_registro_campo erc2
 where pdc.cd_documento_clinico = pec.cd_documento_clinico
 and erc.cd_registro = pec.cd_editor_registro
 and erc.cd_campo = ec.cd_campo
 and erc2.cd_registro = pec.cd_editor_registro
 and erc2.cd_campo = ec2.cd_campo
 and pec.cd_documento = 36
 and pdc.tp_status in ('FECHADO','ASSINADO')
 and ec.ds_identificador in ('solicitacao_vaga_1')
 and ec2.ds_identificador in ('solicitacao_vaga_2_1')) vaga

 where xx.cd_paciente = att.cd_paciente
 and xx.cd_atendimento = vaga.cd_atendimento
 and hr_solicitacao >= SYSDATE - 5
 ORDER BY HR_SOLICITACAO DESC
)

GROUP BY HR_SOLICITACAO
ORDER BY HR_SOLICITACAO desc