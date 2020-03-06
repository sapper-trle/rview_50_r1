unit Unit8;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,trunit2;

type
  TFpanel2 = class(TForm)
    ScrollBox1: TScrollBox;
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Fpanel2: TFpanel2;

implementation

uses rUnit1, runit3, Runit4;

{$R *.DFM}

procedure TFpanel2.Button1Click(Sender: TObject);
begin
    close;
end;

procedure TFpanel2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
pagina:integer;
mx,my:integer;
k,i:integer;
x1,y1,x2,y2,x3,y3:integer;
begin
   mx:=x;
   pagina:=trunc(int(y/256));
   my:=y-(pagina*256);

   //si right click, find texture
    i:=-1;
    for k:=0 to l.num_textures-1 do
    begin
        if l.Textures[k].tile=pagina then
        begin
            //sacar las coordenadas de la textura.
           x1:=l.Textures[k].x1;
           y1:=l.Textures[k].y1;
           x2:=l.Textures[k].x3;
           y2:=l.Textures[k].y3;

           if x2=x1 then x2:=l.textures[k].x2;
           if y2=y1 then y2:=l.textures[k].y2;

           if x2<x1 then begin x3:=x1;x1:=x2;x2:=x3;end;
           if y2<y1 then begin y3:=y1;y1:=y2;y2:=y3;end;

           if ((mx>=x1) and (mx<=x2)) and ((my>=y1) and (my<=y2)) then
            begin
               i:=k;
               break;
            end;//end si en area
        end; //end si en pagina
    end;//all textures

    if i>=0 then
    if (ssleft in shift) then
    begin //primary texture
        form4.image5.picture.Bitmap:=tr_get_texture(i,tx);
        form1.text1:=i;
        form4.spinedit1.value:=i;
    end
    else
    begin
        form4.image6.picture.Bitmap:=tr_get_texture(i,tx);
        form1.text2:=i;
        form4.spinedit2.value:=i;
    end;//secoundary texture.


end;

end.
