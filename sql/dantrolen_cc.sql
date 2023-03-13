SELECT
    Nvl(sum(itmvto_estoque.qt_movimentacao - Nvl(itmvto_estoque.qt_recebido,0)),0) qtd
   ,produto.cd_produto AS cd_tip_presc
   ,paciente.nm_paciente
   ,paciente.dt_nascimento
   ,produto.ds_produto AS ds_tip_presc
   ,atendime.cd_atendimento 
 FROM mvto_estoque, itmvto_estoque, atendime, paciente, produto  
 WHERE cd_aviso_cirurgia IN ( 
        SELECT  
           aviso_cirurgia.cd_aviso_cirurgia
         from
            aviso_cirurgia,
            cirurgia,
            cirurgia_aviso,
            age_cir
         WHERE
            cirurgia_aviso.cd_cirurgia =  cirurgia.cd_cirurgia
            AND aviso_cirurgia.cd_aviso_cirurgia = cirurgia_aviso.cd_aviso_cirurgia
            AND age_cir.cd_aviso_cirurgia     = aviso_cirurgia.cd_aviso_cirurgia
            AND age_cir.dt_inicio_age_cir BETWEEN SYSDATE AND SYSDATE +1
              )
 AND mvto_estoque.cd_mvto_estoque =  itmvto_estoque.cd_mvto_estoque
 AND mvto_estoque.cd_atendimento  =  atendime.cd_atendimento
 AND atendime.cd_paciente         =  paciente.cd_paciente
 AND  itmvto_estoque.cd_produto   = produto.cd_produto
 AND itmvto_estoque.cd_produto IN (754,756,35142,35143)
 AND  mvto_estoque.tp_mvto_estoque = 'P'

 GROUP BY 
  produto.cd_produto
 ,produto.ds_produto
 ,paciente.nm_paciente
 ,paciente.dt_nascimento
 ,atendime.cd_atendimento
