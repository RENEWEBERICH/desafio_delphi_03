unit View.frmProdutores;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, Vcl.Mask,
  Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Datasnap.DBClient, Datasnap.Provider, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmProdutores = class(TForm)
    pTopo: TPanel;
    lblTitulo: TLabel;
    bbFechar: TBitBtn;
    Panel1: TPanel;
    qyLista: TFDQuery;
    dspLista: TDataSetProvider;
    cdsLista: TClientDataSet;
    dsLista: TDataSource;
    pcLista: TPageControl;
    tsLista: TTabSheet;
    dbgLista: TDBGrid;
    Panel2: TPanel;
    edtLista: TEdit;
    bbEditar: TBitBtn;
    bbExcluir: TBitBtn;
    bbIncluir: TBitBtn;
    tsCadastro: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtID: TDBEdit;
    Panel3: TPanel;
    bbGravar: TBitBtn;
    bbCancelar: TBitBtn;
    edtNome: TDBEdit;
    edtCPF_CNPJ: TDBEdit;
    cdsListaID: TIntegerField;
    cdsListaNOME: TStringField;
    cdsListaCPF_CNPJ: TStringField;
    Label4: TLabel;
    qyLimite: TFDQuery;
    dspLimite: TDataSetProvider;
    cdsLimite: TClientDataSet;
    dsLimite: TDataSource;
    dbgLimite: TDBGrid;
    dsDistribuidor: TDataSource;
    qyDistribuidor: TFDQuery;
    cdsLimiteID: TIntegerField;
    cdsLimitePRODUTORID: TIntegerField;
    cdsLimiteDISTRIBUIDORID: TIntegerField;
    cdsLimiteLIMITE: TFMTBCDField;
    cdsLimiteDISTRIBUIDOR: TStringField;
    bbLimiteRefresh: TBitBtn;
    procedure bbFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure bbCancelarClick(Sender: TObject);
    procedure bbGravarClick(Sender: TObject);
    procedure bbIncluirClick(Sender: TObject);
    procedure bbExcluirClick(Sender: TObject);
    procedure bbEditarClick(Sender: TObject);
    procedure dbgListaDblClick(Sender: TObject);
    procedure dbgListaKeyPress(Sender: TObject; var Key: Char);
    procedure edtListaEnter(Sender: TObject);
    procedure edtListaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtListaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pcListaChange(Sender: TObject);
    procedure pcListaDrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure dbgLimiteExit(Sender: TObject);
    procedure bbLimiteRefreshClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProdutores: TfrmProdutores;

implementation
uses UDM;

{$R *.dfm}

procedure TfrmProdutores.bbCancelarClick(Sender: TObject);
begin
    if cdsLista.State in [dsedit,dsinsert] then
    begin
        cdsLista.Cancel;
        cdsLista.Refresh;
    end;
    pcLista.TabIndex:=0;
end;

procedure TfrmProdutores.bbEditarClick(Sender: TObject);
begin
    if pcLista.TabIndex = 0 then
    begin
        if dbgLista.Fields[0].Text <> '' then
        begin
            cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
            cdsLista.Edit;
            pcLista.TabIndex:=1;

            cdsLimite.Refresh;
        end;
    end;
end;

procedure TfrmProdutores.bbExcluirClick(Sender: TObject);
begin
    if pcLista.TabIndex = 0 then
    begin
        if dbgLista.Fields[0].Text <> '' then
        begin
            cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
            cdsLista.Delete;
            cdsLista.ApplyUpdates(0);
        end;
    end else begin
        pcLista.TabIndex:=0
    end;
end;

procedure TfrmProdutores.bbFecharClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmProdutores.bbGravarClick(Sender: TObject);
var
    sql : string;
begin
    if cdsLista.State in [dsedit,dsinsert] then
    begin
        cdsLista.Post;
        cdsLista.ApplyUpdates(0);
        cdsLista.Refresh;

        sql := 'INSERT INTO produtor_limite(DISTRIBUIDORID, PRODUTORID, LIMITE) ' +
               'SELECT ID AS DISTRIBUIDORID, ' + IntToStr(edtID.Field.Value) + ' AS PRODUTORID, 0 AS LIMITE ' +
               'FROM DISTRIBUIDOR '+
               'WHERE NOT ID IN (SELECT DISTRIBUIDORID FROM  produtor_limite WHERE PRODUTORID = ' + IntToStr(edtID.Field.Value) + ')';

        with DM.script do
        begin
            SQLScripts.Clear;
            SQLScripts.Add;
            with SQLScripts[0].SQL do begin
              Add(sql);
            end;
            //ValidateAll;
            ExecuteAll;
        end;
        cdsLimite.Refresh;
    end;
    if cdsLimite.State in [dsedit,dsinsert] then
    begin
        cdsLimite.Post;
        cdsLimite.ApplyUpdates(0);
        cdsLimite.Refresh;
    end;

    if pcLista.TabIndex <> 0 then
    begin
        pcLista.TabIndex:=0
    end;
end;

procedure TfrmProdutores.bbIncluirClick(Sender: TObject);
begin
    if not(cdsLista.State in [dsedit,dsinsert]) then
    begin
        cdsLista.Insert;
        edtID.Field.Value := 0;
        edtNome.Field.Value := 'Novo';
        edtCPF_CNPJ.Field.Value := '0';
    end;

    if pcLista.TabIndex <> 1 then
    begin
        pcLista.TabIndex:=1
    end;
end;

procedure TfrmProdutores.bbLimiteRefreshClick(Sender: TObject);
var
    sql : string;
begin
    if edtID.Field.Value=0 then
    begin
        cdsLista.Post;
        cdsLista.ApplyUpdates(0);
        cdsLista.Refresh;
    end;

    if not (cdsLista.State in [dsinsert]) then
    begin

        sql := 'INSERT INTO produtor_limite(DISTRIBUIDORID, PRODUTORID, LIMITE) ' +
               'SELECT ID AS DISTRIBUIDORID, ' + IntToStr(edtID.Field.Value) + ' AS PRODUTORID, 0 AS LIMITE ' +
               'FROM DISTRIBUIDOR '+
               'WHERE NOT ID IN (SELECT DISTRIBUIDORID FROM  produtor_limite WHERE PRODUTORID = ' + IntToStr(edtID.Field.Value) + ')';

        with DM.script do
        begin
            SQLScripts.Clear;
            SQLScripts.Add;
            with SQLScripts[0].SQL do begin
              Add(sql);
            end;
            //ValidateAll;
            ExecuteAll;
        end;

        cdsLimite.ApplyUpdates(0);
        cdsLimite.Refresh;
    end;
end;

procedure TfrmProdutores.dbgListaDblClick(Sender: TObject);
begin
    if dbgLista.Fields[0].Text <> '' then
    begin
        cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
        cdsLista.Edit;
        pcLista.TabIndex:=1;
    end;
end;

procedure TfrmProdutores.dbgListaKeyPress(Sender: TObject; var Key: Char);
begin
   if (key in ['a'..'z']) or (key in ['A'..'Z']) or (Key in ['1','2','3','4','5','6','7','8','9','0']) then
   begin
      edtLista.Text := key;
      edtLista.SetFocus;
   end;
end;

procedure TfrmProdutores.dbgLimiteExit(Sender: TObject);
begin
    if cdsLimite.State in [dsedit,dsinsert] then
    begin
        cdsLimite.Post;
        cdsLimite.ApplyUpdates(0);
        cdsLimite.Refresh;
    end;
end;

procedure TfrmProdutores.edtListaEnter(Sender: TObject);
begin
    edtLista.Selstart:= Length(edtLista.text);
end;

procedure TfrmProdutores.edtListaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   try
      if (key = VK_DOWN) and (dbgLista.FieldCount > 1) then
      begin
         dbgLista.SetFocus;
         dbgLista.SelectedIndex := dbgLista.SelectedIndex + 1;
      end;
      if key = VK_UP then
         dbgLista.SetFocus;

      If ( Chr(Key) = #13) Then
      begin
          if (copy(edtLista.Text,1,1) = '1') or (copy(edtLista.Text,1,1) = '2') or
          (copy(edtLista.Text,1,1) = '3') or (copy(edtLista.Text,1,1) = '4') or
          (copy(edtLista.Text,1,1) = '5') or (copy(edtLista.Text,1,1) = '6') or
          (copy(edtLista.Text,1,1) = '7') or (copy(edtLista.Text,1,1) = '8') or
          (copy(edtLista.Text,1,1) = '9') or (copy(edtLista.Text,1,1) = '0') then
          begin
              qyLista.Close;
              qyLista.SQL.Clear;
              qyLista.SQL.Add('SELECT * FROM PRODUTOR WHERE ID = ' + (edtLista.Text) + ' ');
              qyLista.Open;
              cdslista.Refresh;
              if cdslista.RecordCount >= 1 then
              begin
                  if dbgLista.Fields[0].Text <> '' then
                  begin
                      cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
                      cdsLista.Edit;
                      pcLista.TabIndex:=1;
                  end;
              end
              else
              begin
                  Application.MessageBox('Produtor n�o cadastrado.', 'Agro', MB_ICONQUESTION);
                  edtLista.Text := '';
                  edtLista.SetFocus;
              end;
          end
          else
          begin
              if dbgLista.Fields[0].Text <> '' then
              begin
                  if dbgLista.Fields[0].Text <> '' then
                  begin
                      cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
                      cdsLista.Edit;
                      pcLista.TabIndex:=1;
                  end;
              end;
          end;
      end;
   except
      on e :Exception do
      Application.MessageBox(pchar('Erro ao executar a consulta.' + #13 + e.Message), 'Agro', MB_OK + MB_ICONERROR);
   end;
end;

procedure TfrmProdutores.edtListaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if not ( (copy(edtLista.Text,1,1) = '1') or (copy(edtLista.Text,1,1) = '2') or (copy(edtLista.Text,1,1) = '3') or (copy(edtLista.Text,1,1) = '4') or (copy(edtLista.Text,1,1) = '5') or (copy(edtLista.Text,1,1) = '6') or (copy(edtLista.Text,1,1) = '7') or (copy(edtLista.Text,1,1) = '8') or (copy(edtLista.Text,1,1) = '9') or (copy(edtLista.Text,1,1) = '0')) then
    begin
        edtLista.MaxLength := 40;
        qyLista.Close;
        qyLista.SQL.Clear;
        qyLista.SQL.Add('SELECT * FROM PRODUTOR WHERE UPPER(NOME) LIKE ' + QuotedStr(UpperCase( '%' + edtLista.Text + '%')));
        qyLista.Open;
        cdsLista.Refresh;
    end else
    begin
        edtLista.MaxLength := 6;
    end;
end;

procedure TfrmProdutores.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if cdsLista.State in [dsedit,dsinsert] then
    begin
        cdsLista.Cancel
    end;
    frmProdutores.Release;
end;

procedure TfrmProdutores.FormCreate(Sender: TObject);
begin

    if Dm.Conexao.Connected then
    begin
        pcLista.TabIndex := 0;
    end else begin
        Close;
    end;
end;

procedure TfrmProdutores.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

    If ( Chr(Key) = #27) Then
    begin
        if pcLista.TabIndex = 0 then
        begin
            if edtLista.Text='' then
            begin
                Close
            end else
            begin
                edtLista.Text := ''
            end;
        end else begin
            if cdsLista.State in [dsedit,dsinsert] then
            begin
                cdsLista.Cancel
            end;
            pcLista.TabIndex:=0;
        end;
    end;

    If ( Chr(Key) = #45) Then
    begin
        bbIncluirClick(Sender)
    end;

    If ( Chr(Key) = #46) Then
    begin
        if pcLista.TabIndex = 0 then bbExcluirClick(Sender);
    end;

    If ( Chr(Key) = #113) Then         //F2
    begin
        if pcLista.TabIndex = 0 then
        begin
            if dbgLista.Fields[0].Text <> '' then
            begin
                cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
                cdsLista.Edit;
                pcLista.TabIndex:=1;
            end;
        end;
    end;

    If ( Chr(Key) = #119) Then        //F8
    begin
        if pcLista.TabIndex = 1 then bbGravarClick(Sender)
    end;
end;

procedure TfrmProdutores.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if Key = #13 then
    begin
        Key := #0;
        Perform(Wm_NextDlgCtl,0,0);
    end;
end;

procedure TfrmProdutores.FormShow(Sender: TObject);
begin
   try

      //Produtor
      cdsLista.Active := False;
      qyLista.Close;
      qyLista.SQL.Clear;
      qyLista.SQL.Add('SELECT * FROM PRODUTOR');
      qyLista.Open;
      qyLista.Active := True;
      cdsLista.Active := True;

      //Distribuidor
      qyDistribuidor.Close;
      qyDistribuidor.Open;
      qyDistribuidor.Active := True;

      //Limites
      cdsLimite.Active := False;
      qyLimite.Close;
      qyLimite.Open;
      qyLimite.Active := True;
      cdsLimite.Active := True;


   except
      on e :Exception do
      Application.MessageBox('Erro ao listar os dados.', 'Agro', MB_OK + MB_ICONERROR);
   end;
   EDTLISTA.SetFocus;
end;

procedure TfrmProdutores.pcListaChange(Sender: TObject);
begin
    if pcLista.TabIndex in[1] then
    begin
        if dbgLista.Fields[0].Text <> ''  then
        begin
            if not(cdsLista.State in [dsinsert,dsEdit]) then
            begin
                cdsLista.Locate('ID',dbgLista.FieldS[0].Text,[loPartialKey]);
                cdsLista.Edit;
            end;
        end;
    end else begin
        if (cdsLista.State in [dsinsert,dsEdit]) then
        begin
            cdsLista.Cancel
        end;
    end;
end;

procedure TfrmProdutores.pcListaDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
begin
    Control.Canvas.Font.Color:=clDefault;
    Control.Canvas.brush.Color:=clWhite;
    Control.Canvas.TextOut(Rect.left+10, Rect.top+3, pcLista.Pages[TabIndex].Caption);
    pcLista.Pages[TabIndex].Brush.Color := clWhite;
    pcLista.Pages[TabIndex].Repaint;
end;

end.
