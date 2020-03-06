unit rUnit5;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm5 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses rUnit1;

{$R *.DFM}

procedure TForm5.FormCreate(Sender: TObject);
begin
   form5.memo1.lines.loadfromfile(apath+'readme.txt');
end;

end.
