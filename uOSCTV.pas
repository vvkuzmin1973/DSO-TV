unit uOSCTV;

interface

uses Windows, Classes,SysUtils, Forms, MMSystem, uOSCReader,Math, Dialogs;

type TRowEvent = procedure (var RowDataToFill : Pointer; RowNumber : Integer; var MaxX : DWORD; var RowVolts : PDoubleArray) of object;
type TSynhroPulse = (spNone, spHSYN, spVSYN);
type TOSCTVstatus = (osSetup,osProcessData, osWaitFirstFrame, osWaitNewFrame, osWaitEndRow, osWaitStartRowOrFrame);
type TOnDebug  = procedure (NewOSCTVstatus : TOSCTVstatus; DebugStr : String) of object;

type TOSCTV = class
  private
    FOnNewFrame: TNotifyEvent;
    FOnNewRow: TRowEvent;
    fOSCReader : TOSCReader;
    fStatus    : TOSCTVstatus;
    fBytesPerMicroSec  : Integer;
    fCurrentPosInBytes : Int64;
    fBytesInColor : Integer;
    lastPossynhroNewFrameVoltage : Int64;
    lastTimeSynhroPulse : Int64;
    timeTolastTimeSynhroPulse : Int64;
    synhroTimes : Integer;
    VSYNcount : integer;
    xPos : Integer;
    RowNum : Integer;
    FOnDebug: TOnDebug;
    synhroVoltageLevel : Double;
    lastPulseData  : Double;
    aRowData : PByteArray;
    MaxX : Dword;
    lastRowsValues : PDoubleArray;
    BuffProcess : integer;
 


    function  CurrentPosInMicroSec : Int64;


    function IsSynhroPulse (PulseData : Double):TSynhroPulse;

    procedure ChangeStat (aNewStat : TOSCTVstatus);
    procedure SetOnNewFrame(const Value: TNotifyEvent);
    procedure SetOnNewRow(Value : TRowEvent);
    procedure SetOnDebug(const Value: TOnDebug);


  public

  IsEvenFrame : Boolean;
  DebugVoltage : Double;
  MinVoltageLevel : Double;
  MaxVoltageLevel : Double;
  ColorVoltageGain : Double;
  ColorVoltageDelta : Double;
  DebugStr : string;
  function  VoltToColor(Volt : Double) : Byte;
  function  StatusAsString(OSCTVstatus : TOSCTVstatus) : String;
  procedure OnReadData (aData : PDoubleArray; aSize : DWORD) ;
  property  OnNewFrame : TNotifyEvent read FOnNewFrame write SetOnNewFrame;
  property  OnNewRow   : TRowEvent read FOnNewRow write SetOnNewRow;
  property  PositionInBytes : Int64 read fCurrentPosInBytes;
  property  PositionInMicroSec : Int64 read CurrentPosInMicroSec;
  property  OSCReader : TOSCReader read fOSCReader;
  property  OnDebug : TOnDebug read FOnDebug write SetOnDebug;
  property  Status :  TOSCTVstatus read fStatus;
  constructor Create (OSCReader : TOSCReader);

end;

implementation

{ uOSCTV }



procedure TOSCTV.ChangeStat(aNewStat: TOSCTVstatus);
begin
 // if Assigned(OnDebug) then
//  OnDebug(aNewStat);
  fStatus := aNewStat;
end;

constructor TOSCTV.Create(OSCReader: TOSCReader);
begin
  fOSCReader := OSCReader;
  fOSCReader.OnReadData := OnReadData;
  fStatus := osSetup;
  fBytesPerMicroSec := fOSCReader.SampleRate div 1000000;
  fCurrentPosInBytes:=0;
  fBytesInColor:=3;
  MinVoltageLevel:=0;
  MaxVoltageLevel:=0;
  lastTimeSynhroPulse      :=$FFFFFFFF;
  timeTolastTimeSynhroPulse:=0;
  synhroVoltageLevel:=-30;
  aRowData:=0;
  ColorVoltageGain :=3;
  ColorVoltageDelta := 3;
  lastRowsValues:=nil;
end;

function TOSCTV.CurrentPosInMicroSec: Int64;
begin
  result:=fCurrentPosInBytes div fBytesPerMicroSec;
end;

function TOSCTV.IsSynhroPulse(PulseData: Double): TSynhroPulse;
begin
  result:=spNone;
  if dword(fStatus)<=0 then Exit;

  if (lastPulseData <= synhroVoltageLevel) then
  Inc(synhroTimes);

  if       (synhroTimes div fBytesPerMicroSec > 15)
      and (lastPulseData > synhroVoltageLevel+0.1 ) then   // Pulse > 3us
  begin
   inc (VSYNcount);
    if (VSYNcount > 18) then
    begin
    if Assigned(OnDebug) then
     OnDebug(fStatus, format('VSYN %d %d',[timeTolastTimeSynhroPulse,synhroTimes]));
     result:=spVSYN;
     synhroTimes:=0;
     VSYNcount:=0;
    end;
  end;

  if     (synhroTimes div fBytesPerMicroSec > 3)
    and  (synhroTimes div fBytesPerMicroSec < 15)
      and (lastPulseData > synhroVoltageLevel+0.1 ) then   // Pulse > 3us
  begin
   if Assigned(OnDebug) then
    OnDebug(fStatus, format('HSYN %d %d',[timeTolastTimeSynhroPulse,synhroTimes]));
    result:=spHSYN;
    synhroTimes:=0;
  end;

  lastPulseData:=PulseData;
end;

procedure TOSCTV.OnReadData(aData: PDoubleArray; aSize: DWORD);
var
  i : Integer;
  aIsSynhroPulse : TSynhroPulse;
begin
    Inc(BuffProcess);
    DebugStr:= IntToStr(BuffProcess);
    //inherited;//(OnReadData) then  OnReadData (aData; aSize);
   
    i:=0;
    aRowData:=nil;
   while (i < aSize) do
   begin

     DebugVoltage:=aData[i];
     if (MinVoltageLevel > aData[i]) then MinVoltageLevel := aData[i];
     if (MaxVoltageLevel < aData[i]) then MaxVoltageLevel := aData[i];


    aIsSynhroPulse:= IsSynhroPulse (aData[i]);

    if (dword(aIsSynhroPulse) > 0) then
      lastTimeSynhroPulse      :=CurrentPosInMicroSec;

    timeTolastTimeSynhroPulse:=CurrentPosInMicroSec - lastTimeSynhroPulse;

    case  fStatus  of
      osSetup          :  begin
                            if CurrentPosInMicroSec > 500 then // wait 500us
                            begin
                            synhroVoltageLevel:=MinVoltageLevel+0.15;
                             ChangeStat(osProcessData);
                            end;

                          end;
      osProcessData    :  case  aIsSynhroPulse of
                          spNone : begin
                                    if (Assigned(aRowData)) and (xPos < MaxX)  then
                                    begin
                                     aRowData[xPos]:=VoltToColor(aData[i]);
                                      if lastRowsValues<>nil then
                                      lastRowsValues[xPos]:=aData[i];
                                     Inc(xPos);
                                     end;
                                   
                                  end;
                          spVSYN : begin
                                    if Assigned(OnNewFrame) then
                                     OnNewFrame(Self);

                                     IsEvenFrame:=not IsEvenFrame;

                                     if IsEvenFrame then
                                     RowNum:=0 else
                                     RowNum:=1;
                                     MaxX:=xPos;

                                     if Assigned(OnNewRow) then
                                     begin
                                       OnNewRow(Pointer(aRowData), RowNum, MaxX,lastRowsValues);
                                     end;
                                      xPos:=0;
                                    end;
                          spHSYN : begin
                                     RowNum:=RowNum+2;

                                     MaxX:=xPos;

                                     if Assigned(OnNewRow) then
                                     begin
                                       OnNewRow(Pointer(aRowData), RowNum,MaxX,lastRowsValues);
                                     end;

                                     xPos:=0;
                                    end;
                          end;          

    end;
     Inc(fCurrentPosInBytes);
     Inc(i);
    end;

end;

procedure TOSCTV.SetOnDebug(const Value: TOnDebug);
begin
  FOnDebug := Value;
end;

procedure TOSCTV.SetOnNewFrame(const Value: TNotifyEvent);
begin
  FOnNewFrame := Value;
end;

procedure TOSCTV.SetOnNewRow(Value : TRowEvent);
begin
  FOnNewRow := Value;
end;

function TOSCTV.StatusAsString(OSCTVstatus: TOSCTVstatus): String;
begin
  case OSCTVstatus of
  osWaitFirstFrame : result:='osWaitFirstFrame';
  osWaitNewFrame: result:='osWaitNewFrame';
  osWaitEndRow: result:='osWaitEndRow';
  osWaitStartRowOrFrame : result:='osWaitStartRowOrFrame';
  end;
end;

function TOSCTV.VoltToColor(Volt: Double): Byte;
var
  delta, rs : double;
begin                     // MinVoltageLevel

  delta:= (MaxVoltageLevel + Abs(MinVoltageLevel))/ ColorVoltageDelta;
  Volt := Abs(MinVoltageLevel -Volt) - delta;
  if Volt < 0 then Volt:=0;
  Volt:=Volt*ColorVoltageGain;
  {
  DebugStr:=Format('Range: %.3f;',[MaxVoltageLevel + Abs(MinVoltageLevel)]);
  DebugStr:=Format('%sDelta: %.3f;',[DebugStr,delta]);
  DebugStr:=Format('%sVolt: %.3f',[DebugStr,Volt]);

  }
  rs:=255 * Volt / (MaxVoltageLevel + Abs(MinVoltageLevel));
  if rs>255 then rs:=255;
  if rs<0 then rs:=0;
  Result:=Ceil(rs)

end;

end.
