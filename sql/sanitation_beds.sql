-- query para listar qtde de Leitos aguardando inicio de Higienizaçao    -sanitation_beds
--                   qtde de Leitos aguardando fim de higienização
--                   total de Leitos higienizados no dia 

/*A Taxa TM Liberação não deve ser considerado leitos extras, 
 UNIDADE JARDINS e nem os HDs, Reforçando que não deve carregar os leitos do PS. 
  (Painel Ocupação Geral)
alterado para pegar o tempo da hora da alta medica 
*/

SELECT leito
      ,cd_leito
      ,ds_leito
      ,ds_RESUMO
      ,TP_MOV
      ,tp_ocupacao
      ,hr_alta_medica
      ,inicio
      ,fim
      ,temp tempo                       
      
FROM (
SELECT leito
      ,cd_leito
      ,ds_leito
      ,ds_RESUMO
      ,TP_MOV
      ,tp_ocupacao
      ,hr_alta_medica
      ,inicio
      ,fim
      ,tempo  
,CASE WHEN hr_alta_medica IS NULL THEN tempo ELSE tempo2 END temp

FROM (
SELECT leito
      ,cd_leito
      ,ds_leito
      ,ds_RESUMO
      ,TP_MOV
      ,tp_ocupacao
      ,hr_alta_medica
      ,inicio
      ,fim
      ,tempo
      ,SUBSTR( (CAST(fim AS TIMESTAMP) - CAST(hr_alta_medica  AS TIMESTAMP) ),12,8 )  tempo2   

FROM (
SELECT  DISTINCT 
 'HIGIENIZADO DIA' LEITO
      ,l.cd_leito
      ,l.ds_leito
      ,l.ds_RESUMO
      ,m.TP_MOV
      ,l.tp_ocupacao   
      , hr_alta_medica
      ,hr_mov_int inicio
      ,hr_lib_mov fim 
       ,SUBSTR( (CAST(hr_lib_mov AS TIMESTAMP) - CAST(hr_mov_int  AS TIMESTAMP) ),12,8 )  tempo                                               
 FROM mov_int m
     ,leito l
     ,DBAMV.UNID_INT  U
     ,(SELECT hr_alta_medica, CD_LEITO FROM atendime WHERE  Trunc (hr_alta_medica) between Trunc (SYSDATE) AND  (SYSDATE) 

      ) alta_medica 

         WHERE l.cd_leito = m.cd_leito
           AND L.CD_UNID_INT = U.CD_UNID_INT
           AND L.CD_LEITO = alta_medica.CD_LEITO 
           AND m.TP_MOV = 'L'
          -- AND l.tp_ocupacao = 'V'      
           AND  Trunc (hr_LIB_MOV) between Trunc (SYSDATE) AND Trunc (SYSDATE) 
           AND hr_lib_mov IS NOT NULL 
           AND l.tp_ocupacao NOT IN ('T') -- LEITOS INTERDITADOS TEMPORARIAMENTE -- ANDRA
           AND L.SN_EXTRA = 'N'   -- incluido por Andra a pedido do cliente
           AND L.CD_UNID_INT NOT IN (5,22,19,1,21,32,41,39,44,29,36) -- unidades jardim / PS /HD
           AND DS_UNID_INT NOT LIKE '%HD%' -- INCLUIDO A PEDIDO DO CLIENTE  

  )) )

 UNION ALL 
----------------- AGUARDANDO INCIO DA HIGIENIZAÇÃO   
   
   SELECT 'AGUARDANDO INICIO HIGIENIZACAO' LEITO
      ,l.cd_leito
      ,l.ds_leito
      ,l.ds_RESUMO
      ,m.TP_MOV
      ,l.tp_ocupacao 
      ,hr_alta_medica 
      ,hr_mov_int inicio
      ,hr_lib_mov fim                                
     ,SUBSTR( (CAST(SYSDATE  AS TIMESTAMP) - CAST(hr_alta_medica  AS TIMESTAMP) ),12,8 )  tempo
    

   FROM ATENDIME A,
        LEITO L,
        MOV_INT M
  WHERE M.CD_LEITO = L.CD_LEITO
    AND A.CD_LEITO = M.CD_LEITO
    AND A.CD_ATENDIMENTO = M.CD_ATENDIMENTO
    AND A.TP_ATENDIMENTO  = 'I'
    AND M.TP_MOV = 'I'
    AND L.TP_OCUPACAO = 'L'                                                
    AND To_Char(hr_alta_medica,'DD/MM/RRRR') = To_Char(SYSDATE,'DD/MM/RRRR')
    AND  l.tp_ocupacao NOT IN ('T') -- LEITOS INTERDITADOS TEMPORARIAMENTE -- ANDRA
    AND L.SN_EXTRA = 'N'   -- incluido por Andra a pedido do cliente
    AND L.CD_UNID_INT NOT IN (5,22,19,1,21,32,41,39,44,29,36) -- unidades jardim / PS e HD


   

UNION ALL 
-------------------AGUARDANDO FIM DA HIGIENIZAÇÃO ----------

SELECT 
 'AGUARDANDO FIM DA HIGIENIZACAO' LEITO
      ,l.cd_leito
      ,l.ds_leito
      ,l.ds_RESUMO  
      ,m.TP_MOV
      ,l.tp_ocupacao  
      , hr_alta_medica
      ,hr_mov_int inicio
      ,hr_lib_mov fim                                            
      ,SUBSTR( (CAST(SYSDATE AS TIMESTAMP) - CAST(hr_mov_INT AS TIMESTAMP) ),12,8 )  tempo     
 FROM mov_int m
     ,leito l
     ,DBAMV.UNID_INT  U
     ,(SELECT hr_alta_medica, CD_LEITO FROM atendime WHERE  Trunc (hr_alta_medica) between Trunc (SYSDATE) AND  (SYSDATE) 

      ) alta_medica  
                                                              
         WHERE l.cd_leito = m.cd_leito
           AND L.CD_UNID_INT = U.CD_UNID_INT
           AND L.CD_LEITO = alta_medica.CD_LEITO
           AND m.TP_MOV = 'L'
           AND l.tp_ocupacao NOT IN 'O'                                       
           AND  Trunc (hr_mov_int) between Trunc (SYSDATE) AND Trunc (SYSDATE)
           AND hr_lib_mov IS NULL 
           AND  l.tp_ocupacao NOT IN ('T') -- LEITOS INTERDITADOS TEMPORARIAMENTE -- ANDRA
           AND L.SN_EXTRA = 'N'   -- incluido por Andra a pedido do cliente
           AND L.CD_UNID_INT NOT IN (5,22,19,1,21,32,41,39,44,29,36) -- unidades jardim a pedido do cliente e PS
           AND DS_UNID_INT NOT LIKE '%HD%' -- INCLUIDO A PEDIDO DO CLIENTE

--ORDER BY cd_leito