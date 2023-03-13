---- vagas por andar
--  Correção (Ivaldo)
--- (07/06/2022 16:26): Inclusão da Coluna de RESERVAS_UI_AM setando o valor como 0 ate que seja definido o fluxo de como vai ser cantabilizado.
-- Ajuste na query do PS_UI_HJ para ficar exatamente como o painel de solicitação de internação.

SELECT *
FROM (
/*----------------------- HOJE ---------------------------*/
/*--------------------------------------------------------*/
select RESERVAS_UI_HJ
     ,0 RESERVAS_UI_AM
	   ,PS_UI_HJ      
	   ,UPP_UI_HJ     
from (
select res.qtd_vagas_reservadas		AS RESERVAS_UI_HJ 
      ,PS_UTI.QTD_NECESSIDADE_VAGA	AS PS_UI_HJ       
      ,upp_ui.total_upp_ui			AS UPP_UI_HJ      
from(--------- reservados  
SELECT 0 qtd_vagas_reservadas FROM dual )res,
---------------------------------------------
------- PS UTI
(SELECT
Count(CD_ATENDIMENTO) QTD_NECESSIDADE_VAGA

FROM (
select
--xx.*,
 xx.cd_atendimento,
 --att.cd_atendimento_new,
 case when vaga.uti = 'false'
 then 'UI'
 else 'UTI'
 end necessidade_vagas_em,
 case when xx.cd_atendimento = att.cd_atendimento_new
 then'INTERNAO SOLICITADA'
 else 'INTERNAO ATENDIDA'
 end status

 from

 -----------------

 ( select a.cd_atendimento,
 a.cd_paciente,
 p.nm_paciente,
 --fn_idade_tascom(p.dt_nascimento, 'a A m M d D', a.dt_atendimento)idade,
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
 and trunc (pdc.dh_fechamento) = trunc(sysdate)
 and aa.tp_atendimento = 'U') documento
 where a.cd_paciente = p.cd_paciente
 and a.cd_convenio = co.cd_convenio
 and a.cd_atendimento = documento.cd_atendimento) xx,


 -----------------------

 (select max(ax.cd_atendimento) cd_atendimento_new,
 ax.cd_paciente
 from dbamv.atendime ax
 where ax.tp_atendimento in ('I', 'U')
 group by ax.cd_paciente ) att,

 ------------------------

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


 ---------------------------

 where xx.cd_paciente = att.cd_paciente
 and xx.cd_atendimento = vaga.cd_atendimento
 ORDER BY HR_SOLICITACAO DESC

 )

WHERE
necessidade_vagas_em = 'UI'
AND status = 'INTERNAO SOLICITADA' ) PS_UTI,
------------------------------------------
----- UPP-UI
(select count(atendime.cd_atendimento) total_upp_ui
from atendime
where atendime.cd_leito in (select cd_leito
							from leito
    						    ,unid_int
							where leito.cd_unid_int = unid_int.cd_unid_int
  							and unid_int.cd_unid_int = 23
  							and leito.tp_situacao = 'A')
and atendime.dt_alta is null
and atendime.hr_atendimento between trunc(sysdate-1) and trunc(sysdate+1)-(1/24/60/60)
) upp_ui
)
) HJ