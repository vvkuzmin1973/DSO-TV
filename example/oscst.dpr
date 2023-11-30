program oscst;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  main in 'main.pas' {Form1},
  uOSCReader in '..\uOSCReader.pas',
  uOSCTV in '..\uOSCTV.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
