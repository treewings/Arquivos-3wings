-- O - Ocup. por paciente / V - Vago / L - Em Limpeza / I - Ocup. por infecc?o / R - Ocup. por reserva / 
-- A - Acompanhante / E - Reforma / M - Manutenc?o / N - Interdic?o / C - Interditado por Infecc?o / T - Interditado Temporariamente 
-- ATUALIZADO EM 02/05/2022 incluído unidade de internaçao HD 7 ( não constar apenas na % de taxa de ocupação)
SELECT DISTINCT tab1.cd_leito
          ,tab1.leito
          ,CASE WHEN tab1.cd_leito = tab2.cd_leito THEN tab2.situacao
                WHEN tab1.situacao = 'INFECCAO' AND tab1.cd_leito = tab3.cd_leito THEN 'OCUPADO'
                WHEN tab1.cd_leito = tab4.cd_leito AND tab4.tp_situacao = 'I' THEN 'OCUPADO'
          ELSE tab1.situacao END situacao
          ,tab1.UNIDADE
          ,tab1.CD_UNIDADE
    FROM
    (
    SELECT CD_LEITO
          ,LEITO
          ,SITUACAO
          ,CD_ATENDIMENTO
          ,UNIDADE
          ,CD_UNIDADE
    FROM (
    SELECT DISTINCT sit_leito.cd_leito
          ,sit_leito.leito
          ,CASE WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.hr_inicio_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.hr_inicio_higieniza IS NOT NULL AND solic_limpeza.dt_hr_fim_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.dt_hr_ini_pos_higieniza IS NOT NULL AND solic_limpeza.dt_hr_fim_pos_higieniza IS NULL THEN 'HIGIENIZACAO'
                WHEN sit_leito.situacao = 'EM LIMPEZA' AND solic_limpeza.dt_hr_ini_rouparia IS NOT NULL AND solic_limpeza.dt_hr_fim_rouparia IS NULL THEN 'HIGIENIZACAO'
                ELSE sit_leito.situacao END SITUACAO
          ,NULL CD_ATENDIMENTO
          ,sit_leito.UNIDADE
          ,sit_leito.CD_UNIDADE
    FROM (
    SELECT CD_LEITO, LEITO, SITUACAO, UNIDADE, CD_UNIDADE
    FROM (
    SELECT CD_LEITO
          ,DS_RESUMO LEITO
          ,Decode (tp_ocupacao,'O','OCUPADO',      -- Ocup. por paciente
                               'V','VAGO',         -- Vago
                               'L','HIGIENIZACAO', -- Limpeza
                               'I','OCUPADO',      -- Ocup. por infecc?o
                               'R','RESERVADO',    -- Ocup. por reserva
                               'A','OCUPADO',      -- Acompanhante
                               'E','REFORMA',      -- Reforma
                               'M','MANUTENCAO',   -- manutençao                                     
                               'N','INTERDICAO',   -- interdição
                               'C','INTERDITADO INFECCAO',   -- Interditado por Infecc?o
                               'T','INTERD. TEMP.') SITUACAO -- Interditado Temporariamente
                                ,unid_int.ds_unid_int UNIDADE
                                ,unid_int.cd_unid_int CD_UNIDADE

    FROM leito, unid_int
    where leito.cd_unid_int = unid_int.cd_unid_int
  --  and   LEITO.cd_unid_int not in (5,22,19,1,21)
    AND   LEITO.cd_unid_int not in (22,19,1,21) -- retirado a restrição da unid 5 conforme pedido em email no dia 20/04 
    AND   LEITO.SN_EXTRA = 'N'
    AND   LEITO.TP_OCUPACAO NOT IN('E','N','C')
    and   LEITO.dt_desativacao is NULL
    )
    )sit_leito,solic_limpeza
    WHERE sit_leito.cd_leito = solic_limpeza.cd_leito (+)
    ORDER BY 1
    )


    UNION-----------------------------------------------------------------------


    SELECT CD_LEITO
          ,LEITO
          ,SITUACAO
          ,CD_ATENDIMENTO
          ,UNIDADE
          ,CD_UNIDADE
    FROM (
    SELECT
     LEITO.CD_LEITO
    ,LEITO.DS_RESUMO leito
    , CASE WHEN atendime.hr_alta_medica IS NOT NULL THEN 'ALTA MEDICA'
      ELSE NULL END situacao
    ,ATENDE.CD_ATENDIMENTO
    ,UNID_INT.DS_UNID_INT UNIDADE
    ,UNID_INT.CD_UNID_INT CD_UNIDADE

    FROM

    LEITO,
    UNID_INT
    ,(SELECT * FROM (

    SELECT

     ATENDIME.CD_ATENDIMENTO
    ,ATENDIME.CD_PACIENTE
    ,PACIENTE.NM_PACIENTE
    ,ATENDIME.CD_LEITO
    ,ATENDIME.HR_ATENDIMENTO
    ,Dense_Rank () OVER(PARTITION BY CD_LEITO ORDER BY HR_ATENDIMENTO DESC) ORDEM

    FROM

     ATENDIME
    ,PACIENTE


    WHERE

        ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE

    AND ATENDIME.TP_ATENDIMENTO = 'I'

    ORDER BY ATENDIME.CD_LEITO

    )

    WHERE

    ORDEM = 1

    ORDER BY HR_ATENDIMENTO DESC, CD_LEITO
    ) ATENDE,atendime

    WHERE

        LEITO.CD_LEITO = ATENDE.CD_LEITO
    AND atende.cd_atendimento = atendime.cd_atendimento
    AND LEITO.CD_UNID_INT = UNID_INT.CD_UNID_INT
    AND atendime.hr_alta_medica IS NOT null
    AND TP_OCUPACAO = 'O'
    AND UNID_INT.TP_UNID_INT = 'I'
    AND ATENDIME.DT_ALTA IS NULL
    AND LEITO.cd_unid_int not in (22,19,1,21) -- retirado a restrição da unid 5 conforme pedido em email no dia 20/04
    AND   dt_desativacao is NULL
    ORDER BY 1
    )
    )tab1
    ------tab2(Alta Medica)-------
    ,(
    SELECT
     LEITO.CD_LEITO
    ,LEITO.DS_RESUMO leito
    , CASE WHEN atendime.hr_alta_medica IS NOT NULL THEN 'ALTA MEDICA'
      ELSE NULL  END situacao
    ,ATENDE.CD_ATENDIMENTO

    FROM

    LEITO
    ,(SELECT * FROM (

    SELECT

     ATENDIME.CD_ATENDIMENTO
    ,ATENDIME.CD_PACIENTE
    ,PACIENTE.NM_PACIENTE
    ,ATENDIME.CD_LEITO
    ,ATENDIME.HR_ATENDIMENTO
    ,Dense_Rank () OVER(PARTITION BY CD_LEITO ORDER BY HR_ATENDIMENTO DESC) ORDEM

    FROM

     ATENDIME
    ,PACIENTE


    WHERE

        ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE

    AND ATENDIME.TP_ATENDIMENTO = 'I'

    ORDER BY ATENDIME.CD_LEITO

    )

    WHERE

    ORDEM = 1

    ORDER BY HR_ATENDIMENTO DESC, CD_LEITO
    ) ATENDE,atendime

    WHERE

        LEITO.CD_LEITO = ATENDE.CD_LEITO
    AND atende.cd_atendimento  = atendime.cd_atendimento
    AND atendime.hr_alta_medica IS NOT null
    AND TP_OCUPACAO = 'O'
    AND ATENDIME.DT_ALTA IS NULL
    AND cd_unid_int not in (22,19,1,21) -- retirado a restrição da unid 5 conforme pedido em email no dia 20/04
    AND   dt_desativacao is NULL
    ORDER BY LEITO.CD_LEITO
    )tab2
    ------tab3(Infec. Alta Medica)-------
    ,(
    SELECT
     LEITO.CD_LEITO
    ,LEITO.DS_RESUMO leito
    , CASE WHEN atendime.hr_alta_medica IS NOT NULL THEN 'OCUPADO'
      ELSE LEITO.TP_OCUPACAO END situacao
    ,ATENDE.CD_ATENDIMENTO

    FROM

    LEITO
    ,(SELECT * FROM (

    SELECT

     ATENDIME.CD_ATENDIMENTO
    ,ATENDIME.CD_PACIENTE
    ,PACIENTE.NM_PACIENTE
    ,ATENDIME.CD_LEITO
    ,ATENDIME.HR_ATENDIMENTO
    ,Dense_Rank () OVER(PARTITION BY CD_LEITO ORDER BY HR_ATENDIMENTO DESC) ORDEM

    FROM

     ATENDIME
    ,PACIENTE


    WHERE

        ATENDIME.CD_PACIENTE = PACIENTE.CD_PACIENTE

    AND ATENDIME.TP_ATENDIMENTO = 'I'

    ORDER BY ATENDIME.CD_LEITO

    )

    WHERE

    ORDEM = 1

    ORDER BY HR_ATENDIMENTO DESC, CD_LEITO
    ) ATENDE,atendime

    WHERE

        LEITO.CD_LEITO = ATENDE.CD_LEITO
    AND atende.cd_atendimento = atendime.cd_atendimento
    AND atendime.hr_alta_medica IS NOT null
    AND TP_OCUPACAO = 'I'
    AND   cd_unid_int not in (22,19,1,21) -- retirado a restrição da unid 5 conforme pedido em email no dia 20/04
    AND   dt_desativacao is NULL
    ORDER BY LEITO.CD_LEITO
    )tab3,
    ------ (tab4. INF. ISOLAMENTO) -------
    (
    SELECT cd_atendimento
          ,cd_leito
          ,tp_situacao
    FROM reg_iso
    WHERE cd_reg_iso IN (SELECT cd_reg_iso
    FROM (
    SELECT cd_atendimento, Max(cd_reg_iso) cd_reg_iso
    FROM reg_iso
    GROUP BY cd_atendimento))

    )tab4,
    ------ (tab5. ALTA HOSPITALAR) -------
    (
    SELECT
   'ALTA HOSPITALAR' SITUACAO
   ,LEITO.CD_LEITO

    FROM
        ATENDIME,
        LEITO

    WHERE
        ATENDIME.CD_LEITO = LEITO.CD_LEITO
    AND LEITO.TP_OCUPACAO IN ('O','I')
    AND ATENDIME.DT_ALTA_MEDICA IS NOT NULL
    AND ATENDIME.DT_ALTA IS NULL
    )tab5
    WHERE tab1.cd_leito = tab2.cd_leito (+)
    AND   tab1.cd_leito = tab3.cd_leito (+)
    AND   tab1.cd_leito = tab4.cd_leito (+)
    AND   tab1.cd_leito = tab5.cd_leito (+)


    ORDER BY UNIDADE, LEITO
