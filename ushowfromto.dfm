object showfromto: Tshowfromto
  Left = 200
  Top = 112
  BorderStyle = bsToolWindow
  Caption = 'Enter range rooms to render'
  ClientHeight = 121
  ClientWidth = 257
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object SpinEdit1: TSpinEdit
    Left = 55
    Top = 26
    Width = 57
    Height = 22
    MaxValue = 255
    MinValue = 1
    TabOrder = 0
    Value = 1
  end
  object SpinEdit2: TSpinEdit
    Left = 143
    Top = 26
    Width = 51
    Height = 22
    MaxValue = 255
    MinValue = 1
    TabOrder = 1
    Value = 255
  end
  object Button1: TButton
    Left = 39
    Top = 74
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 143
    Top = 74
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
