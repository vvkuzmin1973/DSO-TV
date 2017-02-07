object Form1: TForm1
  Left = 290
  Top = 129
  Width = 1022
  Height = 555
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TImage
    Left = 172
    Top = 89
    Width = 834
    Height = 427
    Align = alClient
    OnMouseMove = img1MouseMove
  end
  object spl1: TSplitter
    Left = 169
    Top = 89
    Height = 427
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1006
    Height = 89
    Align = alTop
    TabOrder = 0
    object lbl1: TLabel
      Left = 784
      Top = 16
      Width = 16
      Height = 13
      Caption = 'lbl1'
    end
    object lbl2: TLabel
      Left = 784
      Top = 40
      Width = 16
      Height = 13
      Caption = 'lbl2'
    end
    object rg1: TRadioGroup
      Left = 408
      Top = 8
      Width = 89
      Height = 65
      Caption = 'TV source in'
      ItemIndex = 1
      Items.Strings = (
        'OSC'
        'File')
      TabOrder = 7
    end
    object lst1: TListBox
      Left = 8
      Top = 16
      Width = 129
      Height = 57
      ItemHeight = 13
      TabOrder = 0
    end
    object btn1: TButton
      Left = 144
      Top = 16
      Width = 75
      Height = 25
      Caption = 'read file'
      TabOrder = 1
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 232
      Top = 16
      Width = 75
      Height = 25
      Caption = 'read device'
      TabOrder = 2
      OnClick = btn2Click
    end
    object btn3: TButton
      Left = 232
      Top = 48
      Width = 75
      Height = 25
      Caption = 'stop device'
      TabOrder = 3
      OnClick = btn3Click
    end
    object btn4: TButton
      Left = 320
      Top = 16
      Width = 75
      Height = 25
      Caption = 'read TV'
      TabOrder = 4
      OnClick = btn4Click
    end
    object btn5: TButton
      Left = 144
      Top = 48
      Width = 75
      Height = 25
      Caption = 'stop file'
      TabOrder = 5
      OnClick = btn5Click
    end
    object btn6: TButton
      Left = 320
      Top = 48
      Width = 75
      Height = 25
      Caption = 'stop TV'
      TabOrder = 6
      OnClick = btn6Click
    end
    object tbGain: TTrackBar
      Left = 520
      Top = 8
      Width = 249
      Height = 49
      Max = 50
      Min = 1
      Position = 30
      TabOrder = 8
      OnChange = tbDeltaChange
    end
    object tbDelta: TTrackBar
      Left = 520
      Top = 40
      Width = 249
      Height = 45
      Max = 50
      Min = 1
      Position = 30
      TabOrder = 9
      OnChange = tbDeltaChange
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 89
    Width = 169
    Height = 427
    Align = alLeft
    Caption = 'pnl2'
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 167
      Height = 425
      Align = alClient
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object odmain: TOpenDialog
    Filter = '*.osc|*.osc'
    Left = 112
    Top = 128
  end
end
