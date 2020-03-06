program rview;

uses
  Forms,
  rUnit1 in 'RUNIT1.PAS' {Form1},
  rUnit2 in 'RUNIT2.PAS' {Form2},
  runit3 in 'RUNIT3.PAS' {Form3},
  Runit4 in 'RUNIT4.PAS' {form4},
  rUnit5 in 'rUnit5.pas' {Form5},
  runit6 in 'runit6.pas' {Form6},
  rUnit7 in 'rUnit7.pas' {Form7},
  Unit8 in 'Unit8.pas' {Fpanel2},
  Unit9 in 'Unit9.pas' {fanimated},
  rUnit8 in 'rUnit8.pas' {Form10},
  ushowfromto in 'ushowfromto.pas' {showfromto};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(Tform4, form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TFpanel2, Fpanel2);
  Application.CreateForm(Tfanimated, fanimated);
  Application.CreateForm(TForm10, Form10);
  Application.CreateForm(Tshowfromto, showfromto);
  Application.Run;
end.
