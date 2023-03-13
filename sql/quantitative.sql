
select * from
(
select unid_int.cd_unid_int,
       total_vagos.ds_unid_int unidade,
       nvl(total_vagos.total_vago,0) VAGO,
       nvl(total_ocupado_pacientes.total_ocupado_paciente,0) OCUPADO,
       nvl(total_ocupado_infeccao.total_ocupado_infec,0) OCUPADO_INFEC,
       nvl(total_interditado_infeccao.total_interditado_infec,0) INTERDITADO_INFEC,
       nvl(total_interd_tempo.total_interd_tempo,0) INTERDITADO_TEMP,
       nvl(total_interdicao.total_interd,0) INTERDICAO,
       nvl(total_limpeza.total_limp,0) LIMPEZA,
       nvl(total_manutencao.total_manu,0) MANUTENCAO
       
from unid_int,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_vago 
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'V'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_vagos
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_ocupado_paciente 
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'O'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_ocupado_pacientes
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_ocupado_infec   
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'I'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_ocupado_infeccao
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_interditado_infec  
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'C'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_interditado_infeccao
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_interd_tempo 
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'T'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_interd_tempo
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_interd
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'N'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_interdicao
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_limp
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'L'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_limpeza
,
(
select  unid_int.cd_unid_int
       ,unid_int.ds_unid_int
       ,count (leito.cd_leito) total_manu  
from   leito
       ,unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'M'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is null
and   unid_int.ds_unid_int not like '%HD%'
group by unid_int.cd_unid_int
        ,unid_int.ds_unid_int
) total_manutencao
where unid_int.cd_unid_int = total_ocupado_pacientes.cd_unid_int    (+)
and   unid_int.cd_unid_int = total_vagos.cd_unid_int                (+)
and   unid_int.cd_unid_int = total_ocupado_infeccao.cd_unid_int     (+)
and   unid_int.cd_unid_int = total_interditado_infeccao.cd_unid_int (+)
and   unid_int.cd_unid_int = total_interd_tempo.cd_unid_int         (+)
and   unid_int.cd_unid_int = total_interdicao.cd_unid_int           (+) 
and   unid_int.cd_unid_int = total_limpeza.cd_unid_int              (+)
and   unid_int.cd_unid_int = total_manutencao.cd_unid_int           (+)

)
where unidade is not null
order by 1
-----------------------------------
--VALIDACAO
/*
select * from leito, unid_int
where leito.cd_unid_int = unid_int.cd_unid_int
and   leito.tp_ocupacao = 'I' --LEITOS OCUPADOR POR INFEC.
and   leito.cd_unid_int not in (5,22,19,1,21)
and   unid_int.ds_unid_int not like '%HD%'
*/