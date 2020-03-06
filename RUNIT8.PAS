unit rUnit8;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gauges, StdCtrls;

type
  TForm10 = class(TForm)
    Memo1: TMemo;
    Gauge1: TGauge;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form10: TForm10;

implementation

uses rUnit1;

{$R *.DFM}

procedure TForm10.FormCreate(Sender: TObject);
begin
    runit1.load_states;
end;

end.
