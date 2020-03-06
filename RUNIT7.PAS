unit rUnit7;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,opengl12;

type
  TForm7 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Edit1: TEdit;
    Label8: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox3: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation
uses runit1;
{$R *.DFM}

procedure TForm7.Button1Click(Sender: TObject);
var
f:textFile;
begin
    assignfile(f,apath+'config.opt');
    rewrite(f);
    writeln(f,edit1.text);
    writeln(f,edit2.text);
    if checkbox1.checked then writeln(f,0) else writeln(f,1);

    if radiobutton1.Checked then writeln(f,32);
    if radiobutton2.Checked then writeln(f,24);
    if radiobutton3.Checked then writeln(f,16);
    closefile(f);
    close;
end;

procedure TForm7.Button2Click(Sender: TObject);
begin
    close;
end;

procedure TForm7.FormActivate(Sender: TObject);
begin
    if runit1.opengl_loaded then
    begin
        form1.viewport.setcurrent;
         label4.caption:=glgetstring(gl_vendor);
         label5.caption:=glgetstring(gl_render);
         label6.caption:=glgetstring(gl_version);
        wglMakeCurrent(0,0);
     end;
    edit1.text:=runit1.glfilename;
    edit2.text:=runit1.glufilename;

    if runit1.tm=0 then checkbox1.checked:=true else checkbox1.checked:=false;
    if runit1.bs=32 then radiobutton1.Checked:=true;
    if runit1.bs=24 then radiobutton2.Checked:=true;
    if runit1.bs=16 then radiobutton3.Checked:=true;


end;

end.
