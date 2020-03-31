-- cria nova tabela com os dados do arquivo cremesp
create table tasy.w_gndi_tabela_cremesp
(
     Codigo         number(10),
     Nome           varchar2(60),
     Situacao       char(1),
     UF             char(2)
)
   organization external
(
  type oracle_loader
  default directory PHILIPS_DATA_PUMP_DIR
  access parameters
   (
    records delimited by newline
    skip 1
    fields terminated by '|' 
    lrtrim
    missing field values are null
       (
          Codigo                 ,
          Nome                   ,
          Situacao               ,
          DUMMY_1                ,
          DUMMY_2                ,
          DUMMY_3                ,
          DUMMY_4                ,
          DUMMY_5
        )
     )
      location ('CREMESP.TXT')
)
reject limit unlimited;
