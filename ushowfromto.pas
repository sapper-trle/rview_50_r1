unit ushowfromto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  Tshowfromto = class(TForm)
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  showfromto: Tshowfromto;

implementation

{$R *.dfm}

procedure Tshowfromto.Button1Click(Sender: TObject);
begin
   modalresult:=mrok;
end;

procedure Tshowfromto.Button2Click(Sender: TObject);
begin
   modalresult:=mrcancel;
end;

end.
