SELECT
  mvto_estoque.cd_mvto_estoque solicitacao,
 dbamv.vdic_horarios_agenda_scma.cod_atendimento,
 dbamv.vdic_horarios_agenda_scma.nm_paciente,
 dbamv.vdic_horarios_agenda_scma.data_nascimento,
 produto.ds_produto  item
 ,Nvl(sum(itmvto_estoque.qt_movimentacao - Nvl(itmvto_estoque.qt_recebido,0)),0) qtd
 FROM mvto_estoque, itmvto_estoque, dbamv.vdic_horarios_agenda_scma, produto
 WHERE cd_atendimento IN (
                 SELECT distinct cod_atendimento
                 FROM dbamv.vdic_horarios_agenda_scma
                 WHERE cod_setor IN (121,122)
                 AND Trunc(data_agenda) BETWEEN SYSDATE AND SYSDATE
                 AND cod_atendimento IS NOT NULL)
 AND mvto_estoque.cd_mvto_estoque =  itmvto_estoque.cd_mvto_estoque
 AND dbamv.vdic_horarios_agenda_scma.cod_atendimento = mvto_estoque.cd_atendimento
 AND itmvto_estoque.cd_produto       = produto.ds_produto
 AND itmvto_estoque.cd_produto = 756
 AND tp_mvto_estoque = 'P'
  GROUP BY 
    mvto_estoque.cd_mvto_estoque
   ,dbamv.vdic_horarios_agenda_scma.cod_atendimento
   ,dbamv.vdic_horarios_agenda_scma.nm_paciente
   ,dbamv.vdic_horarios_agenda_scma.data_nascimento
   ,produto.ds_produto
