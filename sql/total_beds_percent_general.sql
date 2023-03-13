-- total_beds_percent_general.sql
-- atualizado pra pegar da view conforme solicitado em 18/10/2022

SELECT cd_unid_int
       ,ds_unid_int
       ,toh_on_line 
       ,leitos_dia
       ,leitos_operacionais
       ,leitos_extras_ocupados
       ,leitos_bloqueados
       ,leitos_instalados
       ,leitos_ocupados
 FROM DBAMV.VDIC_HIS_RESUMO_UNID_PRESID
 WHERE cd_unid_int = 'TOTAL'