unit texture_panel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls;

type
  TFtexture_panel = class(TForm)
    GroupBox3: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Ftexture_panel: TFtexture_panel;

implementation

{$R *.dfm}

procedure TFtexture_panel.SpinEdit1Change(Sender: TObject);
begin
{       if openedfile='' then exit;
       form3.image1.picture.Bitmap:=tr_get_texture(form3.spinedit1.value,tx,true);
       form1.text1:=form3.spinedit1.value;
}       
end;

procedure TFtexture_panel.SpinEdit2Change(Sender: TObject);
begin
{       if openedfile='' then exit;
       form3.image2.picture.Bitmap:=tr_get_texture(form3.spinedit2.value,tx,true);
       form1.text2:=form3.spinedit2.value;
}
end;

procedure TFtexture_panel.Image1Click(Sender: TObject);
begin
{   image2.picture.bitmap:=image1.picture.bitmap;
   form1.text2:=form1.text1;
   form3.spinedit2.value:=form1.text2;
 }
end;

procedure TFtexture_panel.Image2Click(Sender: TObject);
begin
{   image1.picture.bitmap:=image2.picture.bitmap;
   form1.text1:=form1.text2;
   form3.spinedit1.value:=form1.text1;
}
end;

end.
