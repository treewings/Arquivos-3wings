SELECT  
CASE WHEN cirurgia_aviso.cd_especialid = 47 THEN 'FETAL/PARTO'
     WHEN cirurgia_aviso.cd_especialid = 9  THEN 'CARDIOLOGIA'
     WHEN cirurgia_aviso.cd_especialid = 27 THEN 'NEUROCIRURGIA'
     WHEN cirurgia_aviso.cd_especialid IN (44,33) THEN 'ORTOPEDIA/COLUNA'
     WHEN cirurgia_aviso.cd_especialid IN(28,96,27) AND cirurgia.ds_cirurgia LIKE '%QUIMIOTERAPIA%'THEN 'QUIMIOTERAPIA'

END TIPO,
age_cir.dt_inicio_age_cir  Data_cirurgia,
aviso_cirurgia.cd_atendimento,
aviso_cirurgia.cd_aviso_cirurgia,
cirurgia_aviso.cd_cirurgia_aviso,
cirurgia_aviso.cd_cirurgia,
cirurgia.ds_cirurgia,
cirurgia_aviso.cd_especialid
--CIRURGIA.TP_CIRURGIA
--esp_med.cd_prestador,
--esp_med.sn_especial_principal
from
aviso_cirurgia,
cirurgia,
cirurgia_aviso,
age_cir,
esp_med,
PRESTADOR_AVISO

WHERE

    cirurgia_aviso.cd_cirurgia =  cirurgia.cd_cirurgia
AND cirurgia_aviso.cd_aviso_cirurgia =  prestador_aviso.cd_aviso_cirurgia
AND cirurgia_aviso.cd_cirurgia  = prestador_aviso.cd_cirurgia
AND cirurgia_aviso.cd_cirurgia_aviso = prestador_aviso.cd_cirurgia_aviso
AND aviso_cirurgia.cd_aviso_cirurgia = cirurgia_aviso.cd_aviso_cirurgia
AND age_cir.cd_aviso_cirurgia     = aviso_cirurgia.cd_aviso_cirurgia
AND prestador_aviso.cd_prestador  = esp_med.cd_prestador 
AND esp_med.sn_especial_principal = 'S'
AND prestador_aviso.cd_ati_med = '01'
and cirurgia_aviso.cd_especialid in (27,9,47,44,28,96,33)
AND cirurgia_aviso.sn_principal = 'S'
AND (cirurgia.tp_cirurgia = 'G' OR cirurgia_aviso.cd_cirurgia = 2395) -- CIRURGIA DE GRANDE PORTE / inclusão de logica para atender a cigirargia 2395
AND Trunc(age_cir.dt_inicio_age_cir) BETWEEN Trunc(SYSDATE) AND Trunc(SYSDATE +1)
ORDER BY 2 DESC
