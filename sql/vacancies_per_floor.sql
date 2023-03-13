---- vagas por andar
--  Corre??o (Ivaldo)
--- (07/06/2022 15:28): Feito inclus?o do filtro na query por tipo de acomoda??o para que seja um espelho da query  ui_uti_vacant_and_occupied_beds.
-- Utilizado para o Filtro de UI os seguintes tipo de acomoda??o
   --- 1 - APARTAMENTO               
   --- 21 - APARTAMENTO ISOLAMENTO    
   --- 22 - DAY CLINIC APARTAMENTO 
-- Utilizado para o Filtro de UTI os seguintes tipo de acomoda??o
  --- 20 - UTI - PEDIATRIA                
  --- 24 - UTI - PEDIATRIA ISOLAMENTO
  --- 25 - UTI CRONICO
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
Count(*) QTD_UNID,
DS_UNID_INT

FROM(

SELECT
           CD_LEITO
          ,DS_RESUMO LEITO
          ,Decode (tp_ocupacao,'O','OCUPADO',      -- Ocup. por paciente
                               'V','VAGO',         -- Vago
                               'L','HIGIENIZACAO', -- Limpeza
                               'I','OCUPADO',      -- Ocup. por infecc?o
                               'R','RESERVADO',    -- Ocup. por reserva
                               'A','OCUPADO',      -- Acompanhante
                               'E','REFORMA',      -- Reforma
                               'M','MANUTENCAO',   -- manutenao
                               'N','INTERDICAO',   -- interdio
                               'C','INTERDITADO INFECCAO',   -- Interditado por Infecc?o
                               'T','INTERD. TEMP.') SITUACAO -- Interditado Temporariamente
                                ,unid_int.ds_unid_int DS_UNID_INT
                                ,unid_int.cd_unid_int CD_UNIDADE

    FROM leito, unid_int
    where leito.cd_unid_int = unid_int.cd_unid_int
    AND   LEITO.cd_unid_int not IN  (5) -- unidades UI
  --  AND   LEITO.cd_unid_int  IN (45,38,3,25,7,26,31,34,16,30,37,28,23,8,9,10,11,12,13,40,15)
    AND   leito.cd_tip_acom IN (1,21,22,20,24,25)
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO = 'V'
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'

)
GROUP BY DS_UNID_INT
