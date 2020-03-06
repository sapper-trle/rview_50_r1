unit Unit9;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,runit1,trunit2;

type
  Tfanimated = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    CheckBox1: TCheckBox;
    Button6: TButton;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fanimated: Tfanimated;
  cur_frame:integer;
  tempo:tbitmap;

implementation

uses runit3, Runit4;

{$R *.DFM}

procedure Tfanimated.Timer1Timer(Sender: TObject);
var
m:integer;
frame:integer;
des:integer;
x1,y1,x2,y2,x3,y3:integer;

begin
    if listbox1.items.count=0 then exit; //si hay texturas animadas
    if (fanimated.active) and ( at[listbox1.ItemIndex+1]<>0) then
    begin
        m:=listbox1.ItemIndex+1;
        frame:=runit1.at_data[m,cur_frame];
        //--get frame
          des:=l.textures[frame].tile*256;

          x1:=l.textures[frame].x1;
          y1:=des+l.textures[frame].y1;
          x2:=l.textures[frame].x3;
          y2:=des+l.textures[frame].y3;

          if x2=x1 then begin x2:=l.textures[frame].x2;end;
          if y2=y1 then y2:=des+l.textures[frame].y2;

          if x2<x1 then begin x3:=x1;x1:=x2;x2:=x3;end;
          if y2<y1 then begin y3:=y1;y1:=y2;y2:=y3;end;

          tempo.width:=(x2-x1+1); tempo.height:=(y2-y1+1);
          tempo.canvas.CopyRect(rect(0,0,tempo.width,tempo.height), tx.textures.Canvas, rect(x1,y1, x2,y2));
          image1.picture.Bitmap:=tempo;
        //-----------
        cur_frame:=cur_frame+1;
        if cur_frame>runit1.at[m] then cur_frame:=1;
    end;//si hay frames.


end;

procedure Tfanimated.ListBox1Click(Sender: TObject);
begin
    cur_frame:=1;
end;

procedure Tfanimated.FormCreate(Sender: TObject);
begin
   tempo:=tbitmap.create;
   tempo.PixelFormat:=pf15bit;
// runit1.load_states;   
end;

procedure Tfanimated.CheckBox1Click(Sender: TObject);
begin
    if checkbox1.checked then
     begin
       image1.stretch:=false;
       image1.autosize:=true;
     end
     else
     begin
       image1.stretch:=true;
       image1.autosize:=false;
       image1.width:=151;
       image1.height:=140;

     end;
end;

procedure Tfanimated.Button6Click(Sender: TObject);
begin
    close;
end;

procedure Tfanimated.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
curtex:integer;
begin

    if listbox1.items.count=0 then exit; //si hay texturas animadas
    curtex:=runit1.at_data[listbox1.ItemIndex+1,1];

    if (ssleft in shift) then
    begin
        form4.image5.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text1:=curtex;
        form4.spinedit1.value:=curtex;
     end
    else
     begin
        form4.image6.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text2:=curtex;
        form4.spinedit2.value:=curtex;
     end;

end;

end.
