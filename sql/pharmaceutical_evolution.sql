SELECT
    cd_atendimento,
    cd_paciente,
    Nome_Paciente,
    dt_nascimento,
    ds_leito,
    dh_criacao,
    dh_fechamento,
    DATA_ATUAL,
    HORAS_ATUAL,
    hr_atendimento

FROM (
SELECT
 PW_DOCUMENTO_CLINICO.cd_documento_clinico
,PW_DOCUMENTO_CLINICO.dh_criacao
,Case when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RNA%'
                 then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                 || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                  when SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) ||')' LIKE '%RN%'
                then SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 2 ) -1 ))
                || ' ('||OBTER_INICIAIS(NM_PACIENTE) || ')'

                else SUBSTR(NM_PACIENTE, 1 , (INSTR(NM_PACIENTE, ' ' , 1 , 1 ) -1 ))
                || '('||OBTER_INICIAIS(NM_PACIENTE) ||')' end Nome_Paciente
,To_Char(PACIENTE.DT_NASCIMENTO, 'DD/MM/RRRR') DT_NASCIMENTO
,LEITO.DS_LEITO
,PW_DOCUMENTO_CLINICO.DH_FECHAMENTO
,PW_DOCUMENTO_CLINICO.cd_paciente
,PW_DOCUMENTO_CLINICO.cd_atendimento
,To_Char(sysdate, 'DD/MM/RRRR') DATA_ATUAL
,To_Char(sysdate, 'HH24:MI') HORAS_ATUAL
,To_Char(ATENDIME.hr_atendimento, 'DD/MM/RRRR') hr_atendimento



FROM

 PW_DOCUMENTO_CLINICO
,Pw_Editor_Clinico
,PACIENTE
,ATENDIME
,LEITO

WHERE

    PW_DOCUMENTO_CLINICO.CD_DOCUMENTO_CLINICO = Pw_Editor_Clinico.CD_DOCUMENTO_CLINICO
AND PW_DOCUMENTO_CLINICO.CD_ATENDIMENTO = ATENDIME.CD_ATENDIMENTO
AND ATENDIME.CD_LEITO  = LEITO.CD_LEITO
AND PW_DOCUMENTO_CLINICO.cd_paciente = PACIENTE.CD_PACIENTE
AND Pw_Editor_Clinico.CD_DOCUMENTO = 100
AND PW_DOCUMENTO_CLINICO.TP_STATUS NOT IN ('ASSINADO', 'FECHADO','CANCELADO')

AND DH_CRIACAO >= SYSDATE-1

)
WHERE

HORAS_ATUAL BETWEEN '15:00' AND '23:59'

