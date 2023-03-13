    
SELECT esp 
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,total_vago
      ,total_RESERVADO
      ,TOTAL_LIMPEZA
      ,TOTAL_OCUPADO
      ,TOTAL_MANUTENCAO
      ,Nvl (Nvl (total_vago,0) + Nvl (total_RESERVADO,0) + Nvl (TOTAL_LIMPEZA,0)+ Nvl (TOTAL_OCUPADO,0) + Nvl (TOTAL_MANUTENCAO,0)  ,0) TOTAL
      
FROM (

--------------- vago -----------------------------------

SELECT NULL AS esp
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,total_vago
      ,0 total_RESERVADO
      ,0 TOTAL_LIMPEZA
      ,0 TOTAL_OCUPADO
      ,0 TOTAL_MANUTENCAO
FROM (
select leito.cd_tip_acom
        ,LEITO.cd_unid_int
        ,ds_unid_int    
        ,t.ds_tip_acom    
        ,count (leito.cd_leito) total_vago 

from   leito
       ,unid_int
     -- ,atendime
     -- ,especialid e
       ,tip_acom  t

       
where leito.cd_tip_acom = t.cd_tip_acom
AND   leito.cd_unid_int = unid_int.cd_unid_int
AND   leito.tp_ocupacao = 'V'
and   unid_int.cd_unid_int not in (22,19,1,21)-- considerando unidade 5 hd
and   leito.dt_desativacao is NULL
AND   leito.CD_TIP_ACOM IN ( 1,20,24,25,22)
AND   leito.dt_desativacao is NULL
AND   LEITO.SN_EXTRA = 'N'
AND   UNID_INT.SN_ATIVO = 'S'


GROUP BY  leito.cd_tip_acom  ,ds_tip_acom, LEITO.cd_unid_int,ds_unid_int
 
)
  
UNION 

------------------ reservado -----------------------------

SELECT esp 
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,0 total_vago
      ,total_RESERVA
      ,0 TOTAL_LIMPEZA
      ,0 TOTAL_OCUPADO
      ,0 TOTAL_MANUTENCAO

FROM (      
SELECT  e.ds_especialid esp
       ,e.ds_especialid
       ,leito.cd_tip_acom
       ,LEITO.cd_unid_int
       ,ds_unid_int
       ,t.ds_tip_acom
       ,Count (leito.cd_leito) Total_reserva
 FROM   
 atendime
,leito
,res_lei
,especialid e
,tip_acom  t
,unid_int

WHERE atendime.cd_especialid = e.cd_especialid
AND atendime.cd_atendimento = res_lei.cd_atendimento
AND leito.cd_leito = res_lei.cd_leito
AND leito.cd_tip_acom = t.cd_tip_acom
AND   leito.cd_unid_int = unid_int.cd_unid_int
--AND atendime.dt_alta IS NULL 
and leito.dt_desativacao is NULL
and leito.tp_ocupacao = 'R'
AND leito.CD_TIP_ACOM IN ( 1,20,24,25,22) --(APARTAMENTO - 1 /  UTI - 20,24,25  /HD - 22 ) 
AND LEITO.SN_EXTRA = 'N'
AND UNID_INT.SN_ATIVO = 'S'


GROUP BY atendime.cd_especialid ,leito.cd_tip_acom, ds_especialid,ds_tip_acom, LEITO.cd_unid_int,ds_unid_int 
ORDER BY 2)  






UNION 

--------------------- limpeza -------------------------------

SELECT NULL AS esp 
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,0 total_vago
      ,0 total_RESERVADO
      ,TOTAL_LIMPEZA
      ,0 TOTAL_OCUPADO
      ,0 TOTAL_MANUTENCAO
FROM (

select leito.cd_tip_acom
        ,LEITO.cd_unid_int
        ,ds_unid_int    
        ,t.ds_tip_acom    
        ,count (leito.cd_leito) total_LIMPEZA

from   leito
       ,unid_int       
       ,tip_acom  t       
       
where leito.cd_tip_acom = t.cd_tip_acom
AND   leito.cd_unid_int = unid_int.cd_unid_int
AND   leito.tp_ocupacao = 'L'
and   unid_int.cd_unid_int not in (5,22,19,1,21)
and   leito.dt_desativacao is NULL
AND   leito.CD_TIP_ACOM IN ( 1,20,24,25,22)
AND   leito.dt_desativacao is NULL
AND   LEITO.SN_EXTRA = 'N'
AND   UNID_INT.SN_ATIVO = 'S'


GROUP BY  leito.cd_tip_acom  ,ds_tip_acom, LEITO.cd_unid_int,ds_unid_int 
 )

 UNION 

---------------------- ocupado -----------------------
 SELECT esp 
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,0 total_vago
      ,0 total_RESERVADO
      ,0 TOTAL_LIMPEZA
      ,TOTAL_OCUPADO
      ,0 TOTAL_MANUTENCAO
FROM (
                                   
 select atendime.cd_especialid 
        ,ds_especialid  esp
        ,leito.cd_tip_acom
        ,LEITO.cd_unid_int
        ,ds_unid_int    
        ,t.ds_tip_acom    
        ,count (leito.cd_leito) total_OCUPADO 


from   leito
       ,unid_int
       ,atendime
       ,especialid e
       ,tip_acom  t      
       
where leito.cd_tip_acom = t.cd_tip_acom
AND   leito.cd_unid_int = unid_int.cd_unid_int
AND   leito.cd_leito    = atendime.cd_leito
AND   atendime.cd_especialid = e.cd_especialid
AND   leito.tp_ocupacao IN ('O','I','A')
--and   unid_int.cd_unid_int not in (5,22,19,1,21)  -- retirado o filtro pq de acordo com a reuniao pra ocupados tem q considerar todos os leitos
and   leito.dt_desativacao is NULL
--AND   leito.CD_TIP_ACOM IN ( 1,20,24,25,22)
AND   leito.dt_desativacao is NULL
AND   atendime.dt_alta IS NULL 
AND   UNID_INT.SN_ATIVO = 'S'   

GROUP BY  leito.cd_tip_acom  ,ds_tip_acom, LEITO.cd_unid_int,atendime.cd_especialid ,ds_especialid,ds_unid_int




)
UNION 

------------------------ manutencao -------------------------------

 SELECT NULL AS esp 
      ,cd_tip_acom
      ,cd_unid_int
      ,ds_unid_int
      ,ds_tip_acom
      ,0 total_vago
      ,0 total_RESERVADO
      ,0 TOTAL_LIMPEZA
      ,0 TOTAL_OCUPADO
      ,TOTAL_MANUTENCAO
FROM (

 SELECT leito.cd_tip_acom
        ,LEITO.cd_unid_int
        ,ds_unid_int   
        ,t.ds_tip_acom
        ,count (leito.cd_leito) total_manutencao 
 FROM leito
     ,tip_acom  t
     ,unid_int

               
  WHERE LEITO.cd_tip_acom = T.cd_tip_acom
  AND   leito.cd_unid_int = unid_int.cd_unid_int
  AND TP_OCUPACAO = 'M'
  AND   LEITO.SN_EXTRA = 'N'
  AND   leito.CD_TIP_ACOM IN ( 1,20,24,25,22)
  AND  leito.dt_desativacao is NULL
  AND UNID_INT.SN_ATIVO = 'S'
 GROUP BY leito.cd_tip_acom ,LEITO.cd_unid_int ,t.ds_tip_acom ,ds_unid_int

) )
