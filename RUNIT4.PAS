unit Runit4;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  trunit2,fexgraph, ExtCtrls, Menus, StdCtrls, Spin;

type
  Tform4 = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    ScrollBox2: TScrollBox;
    Image2: TImage;
    ScrollBox3: TScrollBox;
    ScrollBox4: TScrollBox;
    Image3: TImage;
    Image4: TImage;
    ScrollBox5: TScrollBox;
    Image5: TImage;
    Image6: TImage;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image6Click(Sender: TObject);
  private
    { Private declarations }
  public
  procedure loadtextures(var L:ttrlevel);
    { Public declarations }
  end;

var
  form4: Tform4;
  a,a2,a3,a4:tpanel_texture;
  anc,alt:byte;
  fname:string;
  ancho1,ancho2,ancho3,ancho4,
  alto1,alto2,alto3,alto4:integer;
  curtex:word;


implementation
uses runit1, runit3;
{$R *.DFM}

procedure tform4.loadtextures(var L:ttrlevel);
begin

tr_panel_textures(ancho1,alto1,4,L,a);
tr_panel_textures(ancho2,alto2,1,L,a2);
tr_panel_textures(ancho3,alto3,1,L,a3);
tr_panel_textures(ancho4,alto4,1,L,a4);

form4.image1.picture.graphic:=a.textures;
form4.scrollbox1.VertScrollBar.Increment:=a.height+(a.height div 2);
//...................................................................

form4.image2.picture.graphic:=a2.textures;
form4.scrollbox2.VertScrollBar.Increment:=a2.height+(a2.height div 2);
//...................................................................

form4.image3.picture.graphic:=a3.textures;
form4.scrollbox3.VertScrollBar.Increment:=a3.height+(a3.height div 2);
//...................................................................

form4.image4.picture.graphic:=a4.textures;
form4.scrollbox4.VertScrollBar.Increment:=a4.height+(a4.height div 2);

end; //end open phd.}

procedure Tform4.FormCreate(Sender: TObject);
begin

   ancho1:=64;
   alto1 :=64;

   ancho2:=64;
   alto2 :=48;

   ancho3:=64;
   alto3 :=32;

   ancho4:=64;
   alto4 :=16;

end;

procedure Tform4.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
i:integer;
begin
  i:=tr_panel_getindex(x,y,a);
  i:=a.index[i];
  form4.caption:='Texture id# '+inttostr(i);
  curtex:=i;
end;

procedure Tform4.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
i:integer;
begin
  i:=tr_panel_getindex(x,y,a2);
  i:=a2.index[i];
  form4.caption:='Texture Id# '+inttostr(i);
  curtex:=i;
end;

procedure Tform4.Image3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
i:integer;
begin
  i:=tr_panel_getindex(x,y,a3);
  i:=a3.index[i];
  form4.caption:='Texture Id# '+inttostr(i);
  curtex:=i;
end;

procedure Tform4.Image4MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
i:integer;
begin

  i:=tr_panel_getindex(x,y,a4);
  i:=a4.index[i];
  form4.caption:='Texture Id# '+inttostr(i);
  curtex:=i;

end;

procedure Tform4.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
    if (ssleft in shift) then
    begin
        image5.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text1:=curtex;
        spinedit1.value:=curtex;
     end
    else
     begin
        image6.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text2:=curtex;
        spinedit2.value:=curtex;
     end;

end;

procedure Tform4.SpinEdit1Change(Sender: TObject);
begin
        curtex:=spinedit1.value;
        image5.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text1:=curtex;

end;

procedure Tform4.SpinEdit2Change(Sender: TObject);
begin
        curtex:=spinedit2.value;
        image6.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text2:=curtex;
end;

procedure Tform4.Image5Click(Sender: TObject);
begin
        curtex:=spinedit1.value;
        image6.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text2:=curtex;
        spinedit2.Value:=curtex;
end;

procedure Tform4.Image6Click(Sender: TObject);
begin
        curtex:=spinedit2.value;
        image5.picture.Bitmap:=tr_get_texture(curtex,tx);
        form1.text1:=curtex;
        spinedit1.Value:=curtex;

end;

end.
