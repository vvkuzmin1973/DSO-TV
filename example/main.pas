unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uOSCReader,uOSCTV, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    img1: TImage;
    pnl1: TPanel;
    lst1: TListBox;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    rg1: TRadioGroup;
    odmain: TOpenDialog;
    pnl2: TPanel;
    Memo1: TMemo;
    lbl1: TLabel;
    tbGain: TTrackBar;
    tbDelta: TTrackBar;
    spl1: TSplitter;
    lbl2: TLabel;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure tbDeltaChange(Sender: TObject);
    procedure img1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    cnt : Integer;
    procedure OnReadData(aData: PDoubleArray; aDataSize: DWORD);
  public
    { Public declarations }
    OSCReaderDevice : TOSCReaderDevice;
    OSCReaderFile : TOSCReaderFile;
    OSCTV : TOSCTV;
    FrameDoubleArray : array of PDoubleArray;
    MaxRow : Integer;
    procedure OnNewFrame (sender : TObject);
    procedure OnDebug (NewOSCTVstatus : TOSCTVstatus; DebugStr : String);

    procedure OnNewRow (var RowDataToFill : Pointer; RowNumber : Integer; var MaxX : Dword; var RowVolts : PDoubleArray);
    procedure OnFileReadData (aData : PDoubleArray; aDataSize : DWORD);
    procedure OnDeviceReadData (aData : PDoubleArray; aDataSize : DWORD);
    procedure OnTVReadData (aData : PDoubleArray; aDataSize : DWORD);

    procedure CreateOSCReaderFile;
    procedure CreateOSCReaderDevice;
  end;

var
  Form1: TForm1;
  HPal: HPALETTE = 0;

implementation

{$R *.dfm}
function BW: HPALETTE;
var 
DC: HDC; 
BI: PBitMapInfo; 
Pal: PLogPalette; 
i: Integer;
ResIdHandle: THandle; 
ResDataHandle: THandle; 
Bitmap: HBitmap; 
C: HWnd; 
OldPalette, Palette: HPalette; 

begin
Bitmap:= 0; Palette:=0;

      GetMem(Pal, SizeOf(TLogPalette) + 256 * SizeOf(TPaletteEntry));
      for i:= 0 to 255 do
      with Pal^.palPalEntry[I] do
      begin
        {
        case i of
        0..32    : begin peRed  := 0;  peGreen:= 0; peBlue := 0; end;
        33..64   : begin peRed  := 0;  peGreen:= 0; peBlue := 255; end;
        65..96   : begin peRed  := 255;  peGreen:= 0; peBlue := 0; end;
        97..128  : begin peRed  := 255;  peGreen:= 0; peBlue := 255; end;
        129..160 : begin peRed  := 0;  peGreen:= 255; peBlue := 0; end;
        161..192 : begin peRed  := 0;  peGreen:= 255; peBlue := 255; end;
        193..224 : begin peRed  := 255;  peGreen:= 255; peBlue := 0; end;
        225..256 : begin peRed  := 255;  peGreen:= 255; peBlue := 255; end;
        end;
        }

        peRed  := i;
        peGreen:= i;
        peBlue := i;
        peFlags:= 0;
            peFlags:= 0;
      end;
  Pal^.palNumEntries:= 256;
  Pal^.palVersion := $300;
  Palette:= CreatePalette(Pal^);
  result:=Palette;
//  FreeMem(Pal, SizeOf(TLogPalette) + 256 * SizeOf(TPaletteEntry));
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
    CreateOSCReaderFile;
    OSCReaderFile.OnReadData:= OnFileReadData;
    OSCReaderFile.StartCapture;
end;

procedure TForm1.OnReadData(aData: PDoubleArray; aDataSize: DWORD);
begin

end;

procedure TForm1.btn2Click(Sender: TObject);
begin
    CreateOSCReaderDevice;
    OSCReaderDevice.OnReadData:= OnDeviceReadData;
    OSCReaderDevice.StartCapture;
end;

procedure TForm1.OnDeviceReadData(aData: PDoubleArray; aDataSize: DWORD);
begin
     Inc(cnt);
     Memo1.Lines.Add(Format('%d Read file data len:%d',[cnt,aDataSize]));
end;

procedure TForm1.OnFileReadData(aData: PDoubleArray; aDataSize: DWORD);
var
  i:integer;
  TStr : TStringList;
begin
     Inc(cnt);
     Memo1.Lines.Add(Format('%d Read file data len:%d',[cnt,aDataSize]));
       TStr := TStringList.Create;
     for i:=0 to aDataSize-1 do
     begin
      TStr.Add(Format('%.7f',[aData[i]]));
     end;
      TStr.SaveToFile(ChangeFileExt(ParamStr(0),'.voltages'));
      TStr.Free;
end;

procedure TForm1.btn3Click(Sender: TObject);
begin
  OSCReaderDevice.StopCapture;
end;

procedure TForm1.OnNewFrame(sender: TObject);
begin
  Inc(cnt);
  img1.Repaint;
 // Memo1.Lines.Add(Format('NewFrame %d; %d',[cnt,OSCTV.PositionInMicroSec]));
end;

procedure TForm1.OnNewRow(var RowDataToFill: Pointer; RowNumber: Integer; var MaxX: dword;var  RowVolts : PDoubleArray);
begin
  if  RowNumber < img1.Picture.Bitmap.Height then
  RowDataToFill:=img1.Picture.Bitmap.ScanLine[RowNumber];
  MaxX:=1500;
  RowVolts:=nil;
 {
  if FrameDoubleArray[RowNumber] = nil then
   GetMem(FrameDoubleArray[RowNumber],SizeOf(Double)*MaxX);

  RowVolts := FrameDoubleArray[RowNumber];
 }

 


 // Memo1.Lines.Add(Format('%.8dR %.7f %d ',[OSCTV.PositionInMicroSec, OSCTV.DebugVoltage, MaxX]));
 // img1.Picture.Bitmap.Width div 2;

 // lbl1.Caption:=format('Min: %.3f; Max: %.3f',[OSCTV.MinVoltageLevel, OSCTV.MaxVoltageLevel]);

//  img1.Repaint;
  Application.ProcessMessages;
{
  if MaxRow <  RowNumber then
  begin
   Memo1.Lines.Add(Format('New max row in %d usec; %d',[OSCTV.PositionInMicroSec, RowNumber]));
   MaxRow:=RowNumber;
  end;
 }
end;

procedure TForm1.btn4Click(Sender: TObject);
begin
  img1.Picture.Bitmap.Create;
  img1.Picture.Bitmap.Width:=img1.Width*10;
  img1.Picture.Bitmap.Height:=img1.Height*5;
  img1.Picture.Bitmap.PixelFormat:=pf8bit;
  img1.Picture.Bitmap.Palette:=BW;
  SetLength(FrameDoubleArray, img1.Picture.Bitmap.Height);


  case rg1.ItemIndex of
  0 : begin
        CreateOSCReaderDevice;
        OSCTV := TOSCTV.Create(OSCReaderDevice);
      end;
  1 : begin
        CreateOSCReaderFile;
        OSCTV := TOSCTV.Create(OSCReaderFile);
      end;
  end;

    OSCTV.OnDebug:=OnDebug;
 //   OSCTV.OnReadData:=OnTVReadData;
    OSCTV.OnNewFrame:=OnNewFrame;
    OSCTV.OnNewRow:=OnNewRow;
    OSCTV.OSCReader.StartCapture;
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
  OSCReaderFile.StopCapture;
end;

procedure TForm1.btn6Click(Sender: TObject);
begin
  case rg1.ItemIndex of
  0 : begin
       OSCReaderDevice.StopCapture;
  end;
  1 : begin
       OSCReaderFile.StopCapture;
  end;
 end;
end;

procedure TForm1.CreateOSCReaderDevice;
begin
    OSCReaderDevice := TOSCReaderDevice.Create(0);
    lst1.Items.Text:=OSCReaderDevice.SampleAvaibleList.Text;
end;

procedure TForm1.CreateOSCReaderFile;
begin
    odmain.FileName:='C:\Multi VirAnalyzer\Recorder\2-8+19-5-34.osc';
    if not odmain.Execute then Exit;

    OSCReaderFile := TOSCReaderFile.Create(odmain.FileName);
    Memo1.Lines.Add(Format('SampleRate:%d',[OSCReaderFile.SampleRate]));
end;

procedure TForm1.OnDebug(NewOSCTVstatus :TOSCTVstatus; DebugStr : String);
begin
 //  Application.ProcessMessages;
  //lbl1.Caption:=OSCTV.DebugStr;
 //Memo1.Lines.Add(Format('D%.8d %.7f %s %s',    [OSCTV.PositionInMicroSec, OSCTV.DebugVoltage,OSCTV.StatusAsString(NewOSCTVstatus), DebugStr ]));
 //lbl1.Caption:=format('Min: %.3f; Max: %.3f',[OSCTV.MinVoltageLevel, OSCTV.MaxVoltageLevel]);
end;

procedure TForm1.tbDeltaChange(Sender: TObject);
var
  d : Double;
begin
   if not Assigned(OSCTV) then Exit;

   d:=tbGain.Position;  OSCTV.ColorVoltageGain:= d / 10;
   d:=tbDelta.Position;  OSCTV.ColorVoltageDelta:= d / 10;

end;

procedure TForm1.img1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
{
 if High(FrameDoubleArray) > y then
  if @FrameDoubleArray[y] <> nil then
   if @FrameDoubleArray[y][x] <> nil then
 lbl2.Caption:=Format('%.4f V (%d) %s',[FrameDoubleArray[y][x], OSCTV.VoltToColor(FrameDoubleArray[y][x]),OSCTV.DebugStr ]);
 }
end;

procedure TForm1.OnTVReadData(aData: PDoubleArray; aDataSize: DWORD);
begin

end;

end.
