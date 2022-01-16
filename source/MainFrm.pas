unit MainFrm;

interface
uses
  RegularExpressions,
  RegularExpressionsCore,
  System.Classes,
  Vcl.ActnList,
  Vcl.ComCtrls, 
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.Mask,
  Vcl.StdCtrls,
  Vcl.ToolWin,

  IdBaseComponent,
  IdComponent,
  IdCustomTCPServer,
  IdIPMCastBase,
  IdIPMCastClient,
  IdMappedPortTCP,
  IdSocketHandle,
  JvExControls,
  JvExMask,
  JvExStdCtrls,
  JvGroupBox,
  JvGroupHeader,
  JvSpin,
  OtlComm,
  OtlCommon,
  OtlEventMonitor,
  OtlTask,
  OtlTaskControl,
  VirtualTrees,

  MinecraftServers,
  UPnPWorker;


const
  MSG_EXTERNALADDRESS_SUCCESS = 1;
  MSG_EXTERNALADDRESS_FAIL = 2;
  MSG_EXTERNALADDRESS_LOG = 3;


type
  TByteArray = TArray<System.Byte>;
  TForwardMethod = (fmUPnP, fmProxy);


  TMainForm = class(TForm)
    btnAbout: TButton;
    btnApplyPort: TButton;
    btnClose: TButton;
    cbAutoOpen: TCheckBox;
    edtExternalAddress: TEdit;
    ghLog: TJvGroupHeader;
    ghMinecraft: TJvGroupHeader;
    ghPortForwarding: TJvGroupHeader;
    ghSettings: TJvGroupHeader;
    ilsDevices: TImageList;
    ilsToolbar: TImageList;
    imgArrow: TImage;
    lblConnect: TLabel;
    lblExternalAddress: TLabel;
    lblExternalPort: TLabel;
    lblMethod: TLabel;
    mappedPort: TIdMappedPortTCP;
    mmoLog: TMemo;
    multiCastClient: TIdIPMCastClient;
    pnlButtons: TPanel;
    pnlSettings: TPanel;
    rbProxy: TRadioButton;
    rbUPnP: TRadioButton;
    seExternalPort: TJvSpinEdit;
    tbMinecraft: TToolBar;
    tbOpen: TToolButton;
    tmrWorldCleanup: TTimer;
    vstDevices: TVirtualStringTree;
    vstMinecraft: TVirtualStringTree;
    btnLog: TButton;
    pnlDevices: TPanel;
    pnlLog: TPanel;

    procedure btnApplyPortClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
    procedure cbAutoOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure multiCastClientIPMCastRead(Sender: TObject; const AData: TByteArray; ABinding: TIdSocketHandle);
    procedure rbForwardMethodClick(Sender: TObject);
    procedure seExternalPortChange(Sender: TObject);
    procedure tbOpenClick(Sender: TObject);
    procedure tmrWorldCleanupTimer(Sender: TObject);
    procedure vstDevicesCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstDevicesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstMinecraftFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure vstMinecraftGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
  private
    FMonitor: TOmniEventMonitor;
    FExternalAddressTask: IOmniTaskControl;
    FExternalAddress: string;
    FExternalPort: Integer;
    FServerDataPattern: TPerlRegEx;
    FMinecraftServers: TMinecraftServers;
    FOpenServerID: Integer;
    FOpenServerMethod: TForwardMethod;
    FDevices: TUPnPDevices;

    procedure ParseServerData(const AData: AnsiString; ADest: TStrings);
    procedure AddServer(const ASender, AAddress, ADescription: string);
    procedure InvalidateServer(AServer: TMinecraftServer);
    procedure FindNodeByData(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);

    procedure TaskMessage(const ATask: IOmniTaskControl; const AMsg: TOmniMessage);

    procedure GetExternalAddress(const ATask: IOmniTask);
    procedure UpdateExternalAddress;

    procedure RefreshDevices;
    procedure OpenServer(AServer: TMinecraftServer);
    procedure OpenServerUPnP(AServer: TMinecraftServer);
    procedure OpenServerProxy(AServer: TMinecraftServer);

    procedure CloseServer(AServer: TMinecraftServer; AMethod: TForwardMethod);
    procedure CloseServerUPnP(AServer: TMinecraftServer);
    procedure CloseServerProxy(AServer: TMinecraftServer);

    procedure AddDevice(ADevice: TUPnPDevice);
    procedure RemoveDevice(const ADeviceURN: string);

    procedure SetServerState(AServerID: Integer; AState: TMinecraftServerState);

    procedure Log(const ATask: string; const AMessage: string);
    procedure LogFmt(const ATask: string; const AMessage: string; const AParams: array of const);

    function GetExpanded(APanel: TControl): Boolean;
    procedure SetExpanded(APanel: TControl; AExpanded: Boolean);
    procedure SetLogExpanded(AExpanded: Boolean);
  protected
    property MinecraftServers: TMinecraftServers read FMinecraftServers;
    property Devices: TUPnPDevices read FDevices;
    property OpenServerID: Integer read FOpenServerID;
    property OpenServerMethod: TForwardMethod read FOpenServerMethod;
  end;


implementation
uses
  Messages,
  Registry,
  StrUtils,
  SysUtils,
  Windows,

  IdException,
  IdHTTP,

  X2UtStrings;


const
  IP_API_URL = 'http://api.x2software.net/ipv4';

  KEY_MOTD = 'MOTD';
  KEY_ADDRESS = 'AD';
  ANY_IP = '0.0.0.0';

  COL_WORLD_DESCRIPTION = 0;
  COL_WORLD_ADDRESS = 1;
  COL_WORLD_STATUS = 2;

  COL_DEVICE_NAME = 0;
  COL_DEVICE_STATUS = 1;

  SERVER_TIMEOUT = 15 * 1000;

  KEY_SETTINGS = '\Software\X2Software\MinecraftO2I';
  VALUE_EXTERNALPORT = 'ExternalPort';
  VALUE_FORWARDMETHOD = 'ForwardMethod';
  VALUE_AUTOOPEN = 'AutoOpen';

  PORT_DEFAULT = 25564;

  BOOLEAN_YESNO: array[Boolean] of String = ('no', 'yes');

  LOG_SHOW = 'Show log »';
  LOG_HIDE = 'Hide log «';


type
  PMinecraftServer = ^TMinecraftServer;
  PUPnPDevice = ^TUPnPDevice;
  

{$R *.dfm}


{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
var
  settings: TRegistry;

begin
  FMonitor := TOmniEventMonitor.Create(nil);
  FMonitor.OnTaskMessage := TaskMessage;

  FDevices := TUPnPDevices.Create;
  FMinecraftServers := TMinecraftServers.Create;

  vstDevices.NodeDataSize := SizeOf(TUPnPDevice);
  vstMinecraft.NodeDataSize := SizeOf(TMinecraftServer);

  FOpenServerID := -1;
  FExternalAddress := '';
  FExternalPort := PORT_DEFAULT;

  settings := TRegistry.Create(KEY_READ);
  try
    settings.RootKey := HKEY_CURRENT_USER;

    if settings.OpenKeyReadOnly(KEY_SETTINGS) then
    try
      if settings.ValueExists(VALUE_EXTERNALPORT) then
      begin
        FExternalPort := settings.ReadInteger(VALUE_EXTERNALPORT);
        if (FExternalPort < 1) or (FExternalPort > 65535) then
          FExternalPort := PORT_DEFAULT;
      end;

      if settings.ValueExists(VALUE_FORWARDMETHOD) then
      begin
        if TForwardMethod(settings.ReadInteger(VALUE_FORWARDMETHOD)) = fmProxy then
          rbProxy.Checked := True
        else
          rbUPnP.Checked := True;
      end;

      if settings.ValueExists(VALUE_AUTOOPEN) then
        cbAutoOpen.Checked := settings.ReadBool(VALUE_AUTOOPEN);
    finally
      settings.CloseKey;
    end;
  finally
    FreeAndNil(settings);
  end;

  seExternalPort.Value := FExternalPort;
  SetLogExpanded(False);
  SetExpanded(pnlDevices, rbUPnP.Checked);

  Log('UI', 'Determining external IP address');
  FExternalAddressTask := CreateTask(GetExternalAddress);
  FExternalAddressTask.MonitorWith(FMonitor);
  FExternalAddressTask.Run;

  RefreshDevices;

  Log('UI', 'Starting ICMP multicast server (group: ' + multiCastClient.MulticastGroup + ')');
  multiCastClient.OnIPMCastRead := multiCastClientIPMCastRead;
  multiCastClient.Active := True;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMonitor);

  mappedPort.Active := False;

  Log('UI', 'Stopping ICMP multicast server');
  multiCastClient.Active := False;

  FreeAndNil(FServerDataPattern);
  FreeAndNil(FMinecraftServers);
  FreeAndNil(FDevices);
end;


procedure TMainForm.multiCastClientIPMCastRead(Sender: TObject; const AData: TByteArray; ABinding: TIdSocketHandle);
var
  textData: AnsiString;
  serverData: TStringList;

begin
  SetLength(textData, Length(AData));
  Move(AData[0], textData[1], Length(AData));

  serverData := TStringList.Create;
  try
    ParseServerData(textData, serverData);

    if (serverData.IndexOfName(KEY_MOTD) > -1) and
       (serverData.IndexOfName(KEY_ADDRESS) > -1) then
      AddServer(ABinding.PeerIP, serverData.Values[KEY_ADDRESS], serverData.Values[KEY_MOTD]);
  finally
    FreeAndNil(serverData);
  end;
end;


procedure TMainForm.ParseServerData(const AData: AnsiString; ADest: TStrings);
var
  key: string;
  value: string;

begin
  if not Assigned(FServerDataPattern) then
  begin
    FServerDataPattern := TPerlRegEx.Create;
    FServerDataPattern.RegEx := '\[(.+?)\](.*?)\[/\1\]';
    FServerDataPattern.Compile;
  end;

  FServerDataPattern.Subject := AnsiToUtf8(string(AData));
  if FServerDataPattern.Match then
  repeat
    key := UTF8ToString(FServerDataPattern.Groups[1]);
    value := UTF8ToString(FServerDataPattern.Groups[2]);

    ADest.Values[key] := value;
  until not FServerDataPattern.MatchAgain;
end;


procedure TMainForm.AddServer(const ASender, AAddress, ADescription: string);
var
  server: TMinecraftServer;
  existing: Boolean;
  node: PVirtualNode;
  nodeData: PMinecraftServer;
  address: string;
  port: string;
  separatorPos: Integer;
  anyIP: Boolean;
  noIP: Boolean;
  portNumber: Integer;
  fullAddress: string;

begin
  vstMinecraft.BeginUpdate;
  try
    anyIP := False;
    noIP := False;

    address := '';
    port := AAddress;

    separatorPos := Pos(':', port);
    if separatorPos > 0 then
    begin
      address := port;
      Delete(port, 1, separatorPos);
      SetLength(address, Pred(separatorPos));

      { Minecraft 1.4 broadcasts 0.0.0.0 as the IP }
      if (address = ANY_IP) then
      begin
        anyIP := True;
        address := ASender;
      end;
    end else if TryStrToInt(port, portNumber) then
    begin
      { Minecraft 1.6 broadcasts only the port }
      noIP := True;
      address := ASender;
    end else
    begin
      { Backwards compatibility }
      address := port;
      port := '';
    end;

    fullAddress := address + IfThen(Length(port) > 0, ':' + port, '');
    server := MinecraftServers.Add(fullAddress, ADescription, existing);

    if not existing then
    begin
      Log('UI', 'Found new LAN world: ' + ADescription + ' (address: ' + AAddress + ')');

      if anyIP then
        LogFmt('UI', 'Minecraft reports accepting on any IP address (0.0.0.0), using sender (%s)', [ASender]);

      if noIP then
        LogFmt('UI', 'Minecraft reports only the port, using sender for address (%s)', [ASender]);

      node := vstMinecraft.AddChild(nil);
      nodeData := vstMinecraft.GetNodeData(node);
      nodeData^ := server;

      if cbAutoOpen.Checked and (OpenServerID = -1) then
      begin
        Log('UI', 'Automatically opening to the internet');
        OpenServer(server);
      end;
    end else
      InvalidateServer(server);

    tmrWorldCleanup.Enabled := (MinecraftServers.Count > 0);
  finally
    vstMinecraft.EndUpdate;
  end;
end;


procedure TMainForm.InvalidateServer(AServer: TMinecraftServer);
var
  node: PVirtualNode;

begin
  node := vstMinecraft.IterateSubtree(nil, FindNodeByData, AServer);
  if Assigned(node) then
    vstMinecraft.InvalidateNode(node);
end;


procedure TMainForm.FindNodeByData(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
type
  PObject = ^TObject;

begin
  if PObject(Sender.GetNodeData(Node))^ = Data then
    Abort := True;
end;


procedure TMainForm.TaskMessage(const ATask: IOmniTaskControl; const AMsg: TOmniMessage);
var
  params: TOmniValueContainer;

begin
  case AMsg.MsgID of
    MSG_EXTERNALADDRESS_SUCCESS:
      begin
        FExternalAddress := AMsg.MsgData.AsString;
        Log('UI', 'Received external IP address: ' + FExternalAddress);
        UpdateExternalAddress;
      end;

    MSG_EXTERNALADDRESS_FAIL:
      begin
        Log('UI', 'Unable to determine external IP address');
        edtExternalAddress.Text := 'sorry, could not determine your external IP address :(';
      end;

    MSG_EXTERNALADDRESS_LOG:
      Log('External address worker', AMsg.MsgData.AsString);

    UPNP_CALLBACK_DEVICEADDED:
      AddDevice(AMsg.MsgData);

    UPNP_CALLBACK_DEVICEREMOVED:
      RemoveDevice(AMsg.MsgData);

    UPNP_RESULT_ADDPORTMAPPING:
      begin
        params := AMsg.MsgData.AsArray;

        if params.ByName(UPNP_PARAM_RESULT, False).AsBoolean then
          SetServerState(params.ByName(UPNP_PARAM_DATA, 0).AsInteger, mssOpen)
        else
          SetServerState(params.ByName(UPNP_PARAM_DATA, 0).AsInteger, mssClosed);
      end;

    UPNP_RESULT_DELETEPORTMAPPING:
      begin
        params := AMsg.MsgData.AsArray;
        SetServerState(params.ByName(UPNP_PARAM_DATA, 0).AsInteger, mssClosed);
      end;

    UPNP_CALLBACK_LOG:
      Log('UPnP worker', AMsg.MsgData.AsString);
  end;
end;


procedure TMainForm.GetExternalAddress(const ATask: IOmniTask);
var
  httpClient: TIdHTTP;
  response: string;

begin
  { For the screenshot... }
//  ATask.Comm.Send(MSG_EXTERNALADDRESS_SUCCESS, '50.16.203.217');
//  exit;

  httpClient := TIdHTTP.Create(nil);
  try
    try
      response := Trim(httpClient.Get(IP_API_URL));

      { Simple sanity check, should be enough }
      if TRegEx.IsMatch(response, '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') then
        ATask.Comm.Send(MSG_EXTERNALADDRESS_SUCCESS, response)
      else
        ATask.Comm.Send(MSG_EXTERNALADDRESS_LOG, 'Invalid response from ' + IP_API_URL + ': ' + response);
    except
      on E:EIdException do
        ATask.Comm.Send(MSG_EXTERNALADDRESS_FAIL);
    end;
  finally
    FreeAndNil(httpClient);
  end;
end;


procedure TMainForm.UpdateExternalAddress;
begin
  if Length(FExternalAddress) > 0 then
  begin
    edtExternalAddress.Font.Color := clWindowText;
    edtExternalAddress.Alignment := taLeftJustify;

    edtExternalAddress.Text := FExternalAddress + ':' + IntToStr(seExternalPort.AsInteger);
  end;
end;


procedure TMainForm.RefreshDevices;
begin
  Log('UI', 'Refreshing UPnP compatible devices list');
  CreateTask(TUPnPWorker.Create(), 'RefreshDevices')
    .MonitorWith(FMonitor)
    .MsgWait()
    .Run;
end;


procedure TMainForm.OpenServer(AServer: TMinecraftServer);
var
  newOpenServerMethod: TForwardMethod;
  server: TMinecraftServer;

begin
  if rbProxy.Checked then
    newOpenServerMethod := fmProxy
  else
    newOpenServerMethod := fmUPnP;

  if (OpenServerID = AServer.ID) and (newOpenServerMethod = FOpenServerMethod) then
    exit;


  if OpenServerID > -1 then
  begin
    server := MinecraftServers.FindItemID(OpenServerID);
    if Assigned(server) then
      CloseServer(server, FOpenServerMethod);
  end;


  case newOpenServerMethod of
    fmUPnP:   OpenServerUPnP(AServer);
    fmProxy:  OpenServerProxy(AServer);
  end;

  FOpenServerID := AServer.ID;
  FOpenServerMethod := newOpenServerMethod;
end;


procedure TMainForm.OpenServerUPnP(AServer: TMinecraftServer);
begin
  LogFmt('UI', 'Attempting to open port: %s:%d -> %s:%d', [FExternalAddress, FExternalPort, AServer.IP, AServer.Port]);
  CreateTask(TUPnPWorker.Create(), 'OpenServer')
    .MonitorWith(FMonitor)
    .MsgWait()
    .SetParameter(UPNP_PARAM_DATA, AServer.ID)
    .SetParameter(UPNP_PARAM_ACTION, UPNP_ACTION_ADDPORTMAPPING)
    .SetParameter(UPNP_PARAM_INTERNALIP, AServer.IP)
    .SetParameter(UPNP_PARAM_INTERNALPORT, AServer.Port)
    .SetParameter(UPNP_PARAM_EXTERNALPORT, FExternalPort)
    .Run;

  AServer.State := mssOpening;
  InvalidateServer(AServer);
end;


procedure TMainForm.OpenServerProxy(AServer: TMinecraftServer);
begin
  if mappedPort.Active then
    LogFmt('Proxy', 'Changing proxy to destination: %s:%d', [AServer.IP, AServer.Port])
  else
  begin
    mappedPort.DefaultPort := FExternalPort;
    LogFmt('Proxy', 'Opening proxy on port %d to destination: %s:%d', [FExternalPort, AServer.IP, AServer.Port]);
  end;

  try
    mappedPort.MappedHost := AServer.IP;
    mappedPort.MappedPort := AServer.Port;
    mappedPort.Active := True;

    AServer.State := mssOpen;
    InvalidateServer(AServer);
  except
    on E:Exception do
      LogFmt('Proxy', 'Could not open proxy: %s', [E.Message]);
  end;
end;


procedure TMainForm.CloseServer(AServer: TMinecraftServer; AMethod: TForwardMethod);
begin
  case AMethod of
    fmUPnP:   CloseServerUPnP(AServer);
    fmProxy:  CloseServerProxy(AServer);
  end;
end;


procedure TMainForm.CloseServerUPnP(AServer: TMinecraftServer);
begin
  LogFmt('UI', 'Closing port: %s:%d', [AServer.IP, AServer.Port]);
  CreateTask(TUPnPWorker.Create(), 'CloseServer')
    .MonitorWith(FMonitor)
    .MsgWait()
    .SetParameter(UPNP_PARAM_DATA, AServer.ID)
    .SetParameter(UPNP_PARAM_ACTION, UPNP_ACTION_DELETEPORTMAPPING)
    .Run;
end;


procedure TMainForm.CloseServerProxy(AServer: TMinecraftServer);
begin
  AServer.State := mssClosed;
  InvalidateServer(AServer);
end;


procedure TMainForm.AddDevice(ADevice: TUPnPDevice);
var
  device: TUPnPDevice;
  node: PVirtualNode;
  nodeData: PUPnPDevice;

begin
  vstDevices.BeginUpdate;
  try
    device := Devices.Find(ADevice.UDN);
    if Assigned(device) then
    begin
      device.Assign(ADevice);
      ADevice.Free;

      node := vstDevices.IterateSubtree(nil, FindNodeByData, ADevice);
      if Assigned(node) then
        vstDevices.InvalidateNode(node);
    end else
    begin
      ADevice.Collection := Devices;

      node := vstDevices.AddChild(nil);
      nodeData := vstDevices.GetNodeData(node);
      nodeData^ := ADevice;
    end;
  finally
    vstDevices.EndUpdate;
  end;
end;


procedure TMainForm.RemoveDevice(const ADeviceURN: string);
var
  device: TUPnPDevice;
  node: PVirtualNode;

begin
  device := Devices.Find(ADeviceURN);
  if Assigned(device) then
  begin
    vstDevices.BeginUpdate;
    try
      node := vstDevices.IterateSubtree(nil, FindNodeByData, device);
      if Assigned(node) then
        vstDevices.DeleteNode(node);
    finally
      vstDevices.EndUpdate;
    end;

    FreeAndNil(device);
  end;
end;


procedure TMainForm.SetServerState(AServerID: Integer; AState: TMinecraftServerState);
var
  server: TMinecraftServer;

begin
  server := MinecraftServers.FindItemID(AServerID);
  if Assigned(server) then
  begin
    server.State := AState;
    InvalidateServer(server);
  end;
end;


procedure TMainForm.Log(const ATask, AMessage: string);
begin
  mmoLog.Lines.Add('[' + ATask + '] ' + AMessage);
  mmoLog.SelStart := mmoLog.GetTextLen;
end;


procedure TMainForm.LogFmt(const ATask, AMessage: string; const AParams: array of const);
begin
  Log(ATask, Format(AMessage, AParams));
end;


function TMainForm.GetExpanded(APanel: TControl): Boolean;
begin
  Result := (APanel.Height > 1);
end;


procedure TMainForm.SetExpanded(APanel: TControl; AExpanded: Boolean);
var
  panelHeight: Integer;

begin
  if GetExpanded(APanel) = AExpanded then
    exit;

  DisableAlign;
  try
    if AExpanded then
    begin
      Self.Height := Self.Height + APanel.Tag;
      APanel.Height := APanel.Tag;
    end else
    begin
      panelHeight := APanel.Margins.ControlHeight;

      APanel.Tag := panelHeight;
      APanel.Height := 1;

      Self.Height := Self.Height - panelHeight;
    end;
  finally
    EnableAlign;
  end;
end;


procedure TMainForm.SetLogExpanded(AExpanded: Boolean);
begin
  SetExpanded(pnlLog, AExpanded);

  if AExpanded then
    btnLog.Caption := LOG_HIDE
  else
    btnLog.Caption := LOG_SHOW;
end;


procedure TMainForm.seExternalPortChange(Sender: TObject);
begin
  btnApplyPort.Enabled := (seExternalPort.AsInteger <> FExternalPort);
end;


procedure TMainForm.btnApplyPortClick(Sender: TObject);
var
  settings: TRegistry;

begin
  FExternalPort := seExternalPort.AsInteger;

  settings := TRegistry.Create;
  try
    settings.RootKey := HKEY_CURRENT_USER;

    if settings.OpenKey(KEY_SETTINGS, True) then
    try
      settings.WriteInteger(VALUE_EXTERNALPORT, FExternalPort);
    finally
      settings.CloseKey;
    end;
  finally
    FreeAndNil(settings);
  end;

  // ToDo update UPnP mapping

  UpdateExternalAddress;
end;


procedure TMainForm.btnLogClick(Sender: TObject);
begin
  SetLogExpanded(not GetExpanded(pnlLog));
end;


procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.cbAutoOpenClick(Sender: TObject);
var
  settings: TRegistry;

begin
  settings := TRegistry.Create;
  try
    settings.RootKey := HKEY_CURRENT_USER;

    if settings.OpenKey(KEY_SETTINGS, True) then
    try
      settings.WriteBool(VALUE_AUTOOPEN, cbAutoOpen.Checked);
    finally
      settings.CloseKey;
    end;
  finally
    FreeAndNil(settings);
  end;
end;


procedure TMainForm.rbForwardMethodClick(Sender: TObject);
var
  settings: TRegistry;

begin
  SetExpanded(pnlDevices, rbUPnP.Checked);

  if rbProxy.Checked then
    lblExternalPort.Caption := 'Proxy port:'
  else
    lblExternalPort.Caption := 'External port:';

  settings := TRegistry.Create;
  try
    settings.RootKey := HKEY_CURRENT_USER;

    if settings.OpenKey(KEY_SETTINGS, True) then
    try
      if rbProxy.Checked then
        settings.WriteInteger(VALUE_FORWARDMETHOD, Ord(fmProxy))
      else
        settings.WriteInteger(VALUE_FORWARDMETHOD, Ord(fmUPnP));
    finally
      settings.CloseKey;
    end;
  finally
    FreeAndNil(settings);
  end;
end;


procedure TMainForm.vstDevicesCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
                                           Column: TColumnIndex; var Result: Integer);
var
  nodeData1: PUPnPDevice;
  nodeData2: PUPnPDevice;

begin
  nodeData1 := Sender.GetNodeData(Node1);
  nodeData2 := Sender.GetNodeData(Node2);

  Result := CompareText(nodeData1^.FriendlyName, nodeData2^.FriendlyName);
end;


procedure TMainForm.vstDevicesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                      TextType: TVSTTextType; var CellText: string);
var
  nodeData: PUPnPDevice;

begin
  nodeData := Sender.GetNodeData(Node);

  case Column of
    COL_DEVICE_NAME:
      CellText := nodeData^.FriendlyName;

    COL_DEVICE_STATUS:
      if nodeData^.HasWANConnection then
      begin
        if nodeData^.PortMapped = dsTrue then
          CellText := 'Open'
        else
          CellText := 'Closed';
      end else
        CellText := 'Not supported';
  end;

end;


procedure TMainForm.vstMinecraftFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  tbOpen.Enabled := Assigned(Node);
end;


procedure TMainForm.vstMinecraftGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
                                        TextType: TVSTTextType; var CellText: string);
var
  nodeData: PMinecraftServer;
  
begin
  nodeData := Sender.GetNodeData(Node);

  case Column of
    COL_WORLD_DESCRIPTION:  CellText := nodeData^.Description;
    COL_WORLD_ADDRESS:      CellText := nodeData^.Address;
    COL_WORLD_STATUS:
      case nodeData^.State of
        mssClosed:  CellText := 'LAN only';
        mssClosing: CellText := 'Closing...';
        mssOpening: CellText := 'Opening...';
        mssOpen:    CellText := 'Open';
      end;
  end;
end;


procedure TMainForm.tbOpenClick(Sender: TObject);
var
  node: PVirtualNode;
  nodeData: PMinecraftServer;

begin
  node := vstMinecraft.FocusedNode;
  if not Assigned(node) then
    exit;

  nodeData := vstMinecraft.GetNodeData(node);
  OpenServer(nodeData^);
end;


procedure TMainForm.tmrWorldCleanupTimer(Sender: TObject);
var
  serverIndex: Integer;
  currentTime: Cardinal;
  server: TMinecraftServer;
  node: PVirtualNode;
  
begin
  vstMinecraft.BeginUpdate;
  try
    currentTime := GetTickCount;
    
    for serverIndex := Pred(MinecraftServers.Count) downto 0 do
    begin
      server := MinecraftServers[serverIndex];
      
      if (currentTime - server.LastSeen) > SERVER_TIMEOUT then
      begin
        node := vstMinecraft.IterateSubtree(nil, FindNodeByData, server);
        if Assigned(node) then
          vstMinecraft.DeleteNode(node);

        if server.ID = OpenServerID then
        begin
          CloseServer(server, OpenServerMethod);
          FOpenServerID := -1;
        end;

        MinecraftServers.Delete(serverIndex);
      end;
    end;

    tmrWorldCleanup.Enabled := (MinecraftServers.Count > 0);
  finally
    vstMinecraft.EndUpdate;
  end;
end;

end.
