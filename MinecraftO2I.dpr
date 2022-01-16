program MinecraftO2I;

uses
  Vcl.Forms,
  MainFrm in 'source\MainFrm.pas' {MainForm},
  UPnPWorker in 'source\UPnPWorker.pas',
  MinecraftServers in 'source\MinecraftServers.pas',
  UPNPLib_TLB in 'source\UPNPLib_TLB.pas',
  EnumInterface in 'source\EnumInterface.pas';

{$R *.res}

var
  MainForm: TMainForm;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Minecraft Open to Internet';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
