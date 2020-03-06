unit runit6;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  TForm6 = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

uses rUnit1;

{$R *.DFM}

procedure TForm6.RadioButton1Click(Sender: TObject);
begin
    form1.scene.current_zone:=1;
    form1.viewport.invalidateGl;
end;

procedure TForm6.RadioButton2Click(Sender: TObject);
begin
    form1.scene.current_zone:=2;
    form1.viewport.invalidateGl;
end;

procedure TForm6.RadioButton3Click(Sender: TObject);
begin
    form1.scene.current_zone:=3;
    form1.viewport.invalidateGl;
end;

procedure TForm6.RadioButton4Click(Sender: TObject);
begin
    form1.scene.current_zone:=4;
    form1.viewport.invalidateGl;
end;

procedure TForm6.RadioButton5Click(Sender: TObject);
begin
    form1.scene.current_zone:=5;
    form1.viewport.invalidateGl;
end;

end.
