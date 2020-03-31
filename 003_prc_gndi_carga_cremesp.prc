create or replace procedure tasy.prc_gndi_carga_cremesp (
          ftp_server_p          varchar2,
          ftp_directory_p       varchar2,
          ftp_file_p            varchar2,
          ftp_user_p            varchar2,
          ftp_password_p        varchar2,
          db_directory_p        varchar2
)
as
/*
 ==============================================================================================================
 PROCEDURE - Importação Registros CREMESP via arquivo TXT                                       |   Versão 1.0
 ==============================================================================================================
 Obj. executa a copia do arquivo via FTP e carrega em uma tabela temporária
 ==============================================================================================================
 Alterações                                                              | Autor                  | Data
 --------------------------------------------------------------------------------------------------------------
 Criação                                                                 | Gamito                 | 16/12/2019
 ==============================================================================================================
*/
--ini vars
type idx_rec_t is record(
     codigo    number(10),
     nome      varchar(60),
     situacao  varchar2(1));
type tb_idx is table of idx_rec_t index by pls_integer;
ftp_conn_v         utl_tcp.connection;
idx_t              tb_idx;
--fim vars
begin
  
  -- ftp conecta e copia arquivo
  begin
    ftp_conn_v := ftp.login(p_host    => ftp_server_p,
                            p_port    => 21,
                            p_user    => ftp_user_p,
                            p_pass    => ftp_password_p);
                            
    ftp.ascii(ftp_conn_v);
    
    ftp.get(p_conn      => ftp_conn_v,
            p_from_file => '/' || ftp_directory_p || '/' || ftp_file_p,
            p_to_dir    => db_directory_p,
            p_to_file   => 'CREMESP.TXT');
            
    ftp.logout(ftp_conn_v);
    
    dbms_output.put_line('##COPIA REALIZADA');
    
  end;
  
  -- insere em tabela de carga: w_gndi_carga_cremesp
  begin
    
    select codigo, 
           nome, 
           situacao
    bulk collect into idx_t
    from w_gndi_tabela_cremesp;
    
    dbms_output.put_line('##TABELA GRAVADA EM MEMÓRIA');
    
    forall i in idx_t.first .. idx_t.last
    
      insert into w_gndi_carga_cremesp
             (
             nr_crm,
             nm_pessoa_fisica,
             ie_situacao
             )
      values 
             (
             idx_t(i).codigo,
             idx_t(i).nome,
             idx_t(i).situacao
			 );
             commit;
  dbms_output.put_line('##TABELA INSERIDA');
             
  end;

end prc_gndi_carga_cremesp;
/
