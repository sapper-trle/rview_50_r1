object Ftexture_panel: TFtexture_panel
  Left = 503
  Top = 1
  Width = 290
  Height = 571
  Caption = 'Ftexture_panel'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox3: TGroupBox
    Left = 28
    Top = 401
    Width = 237
    Height = 135
    Caption = 'Textures Selected'
    TabOrder = 0
    object Image1: TImage
      Left = 20
      Top = 20
      Width = 90
      Height = 80
      Hint = 'Left Click a face to put this texture'
      AutoSize = True
    end
    object Image2: TImage
      Left = 124
      Top = 20
      Width = 90
      Height = 80
      Hint = 'Righ click a fece to put this texture'
      AutoSize = True
      ParentShowHint = False
      ShowHint = False
    end
    object TLabel
      Left = 44
      Top = 102
      Width = 3
      Height = 13
    end
    object SpinEdit1: TSpinEdit
      Left = 39
      Top = 105
      Width = 55
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = -1
    end
    object SpinEdit2: TSpinEdit
      Left = 144
      Top = 105
      Width = 55
      Height = 22
      MaxValue = 0
      MinValue = -1
      TabOrder = 1
      Value = -1
    end
  end
end
