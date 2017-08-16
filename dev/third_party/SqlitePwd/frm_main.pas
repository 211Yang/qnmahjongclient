{************************************************************************}
{                                                                        }
{            ��Ԫ����frm_main.pas                                        }
{            ���ܣ�����WxSQLite�������API��SQLite���ܡ�������롢������ }
{                  ��Ĳ�����                                            }
{            ���ߣ�Pfeng ���������ͣ�www.pfeng.org��                     }
{            ���ڣ�2011.12.08                                            }
{                                                                        }
{************************************************************************}
unit frm_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, frxpngimage, ExtCtrls,Shellapi;

type
  TSQLiteDB = Pointer;  
  TSqlite3 = Pointer;
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    EDT_dbpath: TEdit;
    GroupBox2: TGroupBox;
    EDT_dbopwd: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EDT_dbnpwd: TEdit;
    EDT_dbnpwd2: TEdit;
    BTN_save: TButton;
    Label4: TLabel;
    BTN_open: TButton;
    StatusBar1: TStatusBar;
    Image1: TImage;
    procedure BTN_openClick(Sender: TObject);
    procedure BTN_saveClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  SQLiteDLL = 'sqlite3.dll';

var
  Form1: TForm1;
  function SQLite3_Open(filename: PAnsiChar; var db: TSQLiteDB): integer; cdecl; external SQLiteDLL name 'sqlite3_open';
  function sqlite3_key (
    pDb: Tsqlite3;          // Database handle  
    pKey: PAnsiChar;        // Database PassWord (UTF-8)  
    nKey: Integer           // Database sizeofpassword
  ): integer;  cdecl; external SQLiteDLL name 'sqlite3_key';
  function sqlite3_rekey (
    pDb: Tsqlite3;          // Database handle  
    pKey: PAnsiChar;        // Database PassWord (UTF-8)
    nKey: Integer           // Database sizeofpassword
  ):integer;  cdecl; external SQLiteDLL name 'sqlite3_rekey';
  function SQLite3_Close(db: TSQLiteDB): integer; cdecl; external SQLiteDLL name 'sqlite3_close';
implementation

{$R *.dfm}

function IsAllEnglishStr(const Str :string):Boolean;
var
 i: Integer;
begin
  {�ж��Ƿ�ȫ����Ӣ�Ļ�����}
  Result := True;
  for i:=0 to Length(Str)-1 do
  begin
    if ord(Str[i]) > 128 then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TranslateDBFile(Str: string):string;
begin
   {��SQLITE·������Ϊ���ֽڣ���˺���·����Ҫת��һ��}
  if IsAllEnglishStr(Str) then
    Result := Str
  else
    Result := Utf8Encode(Str);
end;

procedure TForm1.BTN_openClick(Sender: TObject);
begin
  {�����ݿ��ļ�}
  if OpenDialog1.Execute then
  begin
    EDT_dbpath.Text:=OpenDialog1.FileName;
  end;
end;

procedure TForm1.BTN_saveClick(Sender: TObject);
var
 flag: integer;
 db: TSQLiteDB;
begin
  {�޸�����}
  if not FileExists(Trim(EDT_dbpath.Text)) then
  begin
    Application.MessageBox('SQLite���ݿⲻ���ڣ�������ѡ��', '����', MB_OK +
      MB_ICONSTOP);
    Exit;
  end;
  if Trim(EDT_dbnpwd.Text) <> Trim(EDT_dbnpwd2.Text) then
  begin
    Application.MessageBox('���������벻һ�£����������ã�', '����', MB_OK +
      MB_ICONSTOP);
    Exit;
  end;
  if (Trim(EDT_dbopwd.Text) = '') and (Trim(EDT_dbnpwd.Text) = '') then
  begin
    //��ֹ��ԭʼ����������붼Ϊ��ʱ�Ĳ���������API����ֵ��Ϊ0������Ȥ�Ŀ��Բ���һ�£�
    Exit;
  end;
  SQLite3_Open(Pansichar(TranslateDBFile(Trim(EDT_dbpath.Text))),db);//�����ݿ�
  flag := SQLite3_key(db,Pansichar(Trim(EDT_dbopwd.Text)),Length(Trim(EDT_dbopwd.Text))); //��֤����
  if flag <> 0 then
  begin
    Application.MessageBox(Pansichar('���ݿ��ʼ������֤ʧ�ܣ�(SQLite3_key:'+inttostr(flag)+')'), '����', MB_OK +
      MB_ICONSTOP);
    Exit;
  end;
  flag := SQLite3_rekey(db,Pansichar(Trim(EDT_dbnpwd.Text)),Length(Trim(EDT_dbnpwd.Text))); //��������
  if flag <> 0 then
  begin
    Application.MessageBox(Pansichar('���ݿ������޸�ʧ�ܣ�(SQLite3_rekey:'+inttostr(flag)+')'), '����', MB_OK +
      MB_ICONSTOP);
    Exit;
  end;
  SQLite3_Close(db);//�ر����ݿ�
  Application.MessageBox('���ݿ�����Ӧ�óɹ���', '��ʾ', MB_OK +
      MB_ICONinformation);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  ShellExecute(Handle,'open','www.pfeng.org',nil,nil,SW_SHOWNORMAL)
end;

end.
