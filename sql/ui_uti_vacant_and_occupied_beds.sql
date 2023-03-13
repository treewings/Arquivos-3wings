--     Leitos vagos e ocupados
--     Corre??o (Ivaldo)
--    (07/06/2022 15:07): Feito inclus?o do filtro na query por tipo de acomoda??o para que seja autonoma quando for criado um novo leito ou unidade de interna??o.
-- Utilizado para o Filtro de UI os seguintes tipo de acomoda??o
   --- 1 - APARTAMENTO               
   --- 21 - APARTAMENTO ISOLAMENTO    
   --- 22 - DAY CLINIC APARTAMENTO 
-- Utilizado para o Filtro de UTI os seguintes tipo de acomoda??o
  --- 20 - UTI - PEDIATRIA                
  --- 24 - UTI - PEDIATRIA ISOLAMENTO
  ---25 - UTI CRONICO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT

---------------- LEITOS OCUPADOS

Nvl (
(
SELECT
Count(*) QTD_LEITOS_OCUPADOS

FROM ( SELECT
          'OCUPADO UI' TIPO
          ,CD_LEITO
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
   --and unid_int.tp_unid_int = 'U'
   AND   leito.cd_tip_acom IN (1,21,22)
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO not in ('T','C','V')
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'
    )

),0 ) LEITOS_OCUPADOS_UI,

Nvl(
(SELECT
Count(*) QTD_LEITOS_OCUPADOS

FROM ( SELECT
          'OCUPADO UTI' TIPO
          ,CD_LEITO
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

    --and unid_int.tp_unid_int = 'I'
    AND   leito.cd_tip_acom IN (20,24,25)
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO IN ('O','I','R')
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'

   )
 ),0 ) LEITOS_OCUPADOS_UTI ,


------------------- LEITOS_VAGOS

Nvl(
(
SELECT
Count(*) QTD_LEITOS_VAGOS

FROM ( SELECT
           'VAGO UI' TIPO
          ,CD_LEITO
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

    --and   unid_int.tp_unid_int = 'U'
    AND   leito.cd_tip_acom IN (1,21,22)
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO = 'V'
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'
    )
) ,0 ) LEITOS_VAGOS_UI,


Nvl (
(
SELECT
Count(*) QTD_LEITOS_VAGOS

FROM ( SELECT
           'VAGO UTI' TIPO
          ,CD_LEITO
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
    AND   leito.cd_tip_acom IN (20,24,25)
    --AND   LEITO.cd_unid_int  IN (45,38,3,25,7,26,31,34,16,30) -- unidades UTI
    --and   unid_int.tp_unid_int = 'I'
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO = 'V'
    AND   leito.tp_situacao = 'A'
    and   LEITO.dt_desativacao is NULL
    AND   unid_int.sn_ativo = 'S'

   )
) ,0) LEITOS_VAGOS_UTI

FROM DUAL
