unit UPnPWorker;

interface
uses
  Classes,
  ComObj,

  OtlComm,
  OtlTaskControl,

  UPNPLib_TLB;


const
  UPNP_ACTION_ADDPORTMAPPING = 101;
  UPNP_ACTION_DELETEPORTMAPPING = 102;

  UPNP_RESULT_ADDPORTMAPPING = 111;
  UPNP_RESULT_DELETEPORTMAPPING = 112;

  UPNP_CALLBACK_DEVICEADDED = 151;
  UPNP_CALLBACK_DEVICEREMOVED = 152;

  UPNP_CALLBACK_LOG = 200;


  UPNP_PARAM_RESULT = 'Result';
  UPNP_PARAM_DATA = 'Data';
  UPNP_PARAM_ACTION = 'Action';
  UPNP_PARAM_INTERNALIP = 'InternalIP';
  UPNP_PARAM_INTERNALPORT = 'InternalPort';
  UPNP_PARAM_EXTERNALPORT = 'ExternalPort';


type
  TUPnPDeviceState = (dsUnchanged, dsFalse, dsTrue);

  TUPnPDevice = class(TCollectionItem)
  private
    FDescription:       String;
    FFriendlyName:      String;
    FHasWANConnection:  Boolean;
    FPortMapped:        TUPnPDeviceState;
    FUDN:               String;
  public
    procedure Assign(Source: TPersistent); override;

    property Description:       String              read FDescription       write FDescription;
    property FriendlyName:      String              read FFriendlyName      write FFriendlyName;
    property HasWANConnection:  Boolean             read FHasWANConnection  write FHasWANConnection;
    property PortMapped:        TUPnPDeviceState    read FPortMapped        write FPortMapped;
    property UDN:               String              read FUDN               write FUDN;
  end;


  TUPnPDevices = class(TCollection)
  private
    function GetItem(Index: Integer): TUPnPDevice;
    procedure SetItem(Index: Integer; Value: TUPnPDevice);
  public
    constructor Create;

    function Add(const AUDN: String; out AExisting: Boolean): TUPnPDevice; overload;
    function Add(const AUDN: String): TUPnPDevice; overload;
    function Find(const AUDN: String): TUPnPDevice;

    property Items[Index: Integer]:  TUPnPDevice read GetItem write SetItem; default;
  end;


  { Not exported in UPnP.dll }
  IUPnPDeviceFinderCallback = interface(IUnknown)
    ['{415A984A-88B3-49F3-92AF-0508BEDF0D6C}']
    function DeviceAdded(lFindData: Integer; pDevice: IUPnPDevice): HRESULT; stdcall;
    function DeviceRemoved(lFindData: Integer; bstrUDN: Widestring): HRESULT; stdcall;
    function SearchComplete(lFindData: Integer): HRESULT; stdcall;
  end;


  TUPnPWorker = class(TOmniWorker, IUPnPDeviceFinderCallback)
  private
    FDeviceFinder: IUPnPDeviceFinder;
    FSearchHandle: Cardinal;

    FAction: Integer;
    FInternalIP: string;
    FInternalPort: Integer;
    FExternalPort: Integer;
  protected
    function Initialize: Boolean; override;
    procedure Cleanup; override;

    procedure SearchForDevices;
    procedure FindWANConnection(ADeviceIntf: IUPnPDevice; ADevice: TUPnPDevice);
    function PortMappingExists(const ADeviceName: string; AService: IUPnPService): Boolean;

    procedure SendResult(AMsgID: Integer; AResult: Boolean);

    procedure Log(const AMessage: string);
    procedure LogFmt(const AMessage: string; const AParams: array of const);
    procedure LogInvokeActionError(AException: EOleSysError; const AMessage: string; AResponse: OleVariant);
  protected
    { IUPnPDeviceFinderCallback }
    function DeviceAdded(lFindData: Integer; pDevice: IUPnPDevice): HRESULT; stdcall;
    function DeviceRemoved(lFindData: Integer; bstrUDN: Widestring): HRESULT; stdcall;
    function SearchComplete(lFindData: Integer): HRESULT; stdcall;
  end;


implementation
uses
  ActiveX,
  SysUtils,
  Variants,
  Windows,

  OtlCommon,

  EnumInterface;


const
  SchemaURNDeviceRoot         = 'upnp:rootdevice';
  SchemaURNServiceWANPPP      = 'urn:schemas-upnp-org:service:WANPPPConnection:1';
  SchemaURNServiceWANIP       = 'urn:schemas-upnp-org:service:WANIPConnection:1';

  WANPortMappingDescription   = 'Minecraft Open to Internet';
  WANActionAddPortMapping     = 'AddPortMapping';
  WANActionDeletePortMapping  = 'DeletePortMapping';
  WANActionGetPortMapping     = 'GetGenericPortMappingEntry';
  WANProtocolTCP              = 'TCP';


const
  UPNP_E_ROOT_ELEMENT_EXPECTED      = $0200;
  UPNP_E_DEVICE_ELEMENT_EXPECTED    = $0201;
  UPNP_E_SERVICE_ELEMENT_EXPECTED   = $0202;
  UPNP_E_SERVICE_NODE_INCOMPLETE    = $0203;
  UPNP_E_DEVICE_NODE_INCOMPLETE     = $0204;
  UPNP_E_ICON_ELEMENT_EXPECTED      = $0205;
  UPNP_E_ICON_NODE_INCOMPLETE       = $0206;
  UPNP_E_INVALID_ACTION             = $0207;
  UPNP_E_INVALID_ARGUMENTS          = $0208;
  UPNP_E_OUT_OF_SYNC                = $0209;
  UPNP_E_ACTION_REQUEST_FAILED      = $0210;
  UPNP_E_TRANSPORT_ERROR            = $0211;
  UPNP_E_VARIABLE_VALUE_UNKNOWN     = $0212;
  UPNP_E_INVALID_VARIABLE           = $0213;
  UPNP_E_DEVICE_ERROR               = $0214;
  UPNP_E_PROTOCOL_ERROR             = $0215;
  UPNP_E_ERROR_PROCESSING_RESPONSE  = $0216;
  UPNP_E_DEVICE_TIMEOUT             = $0217;
  UPNP_E_INVALID_DOCUMENT           = $0500;
  UPNP_E_EVENT_SUBSCRIPTION_FAILED  = $0501;


{ TUPnPDevice }
procedure TUPnPDevice.Assign(Source: TPersistent);
begin
  if Source is TUPnPDevice then
    with TUPnPDevice(Source) do
    begin
      Self.Description := Description;
      Self.FriendlyName := FriendlyName;
      Self.HasWANConnection := HasWANConnection;

      if PortMapped <> dsUnchanged then
        Self.PortMapped := PortMapped;

      Self.UDN := UDN;
    end
  else
    inherited;
end;


{ TUPnPDevices }
constructor TUPnPDevices.Create;
begin
  inherited Create(TUPnPDevice);
end;


function TUPnPDevices.Add(const AUDN: String; out AExisting: Boolean): TUPnPDevice;
begin
  Result    := Find(AUDN);
  AExisting := Assigned(Result);

  if not AExisting then
  begin
    Result := TUPnPDevice(inherited Add);
    Result.UDN := AUDN;
    Result.PortMapped := dsFalse;
  end;
end;


function TUPnPDevices.Add(const AUDN: String): TUPnPDevice;
var
  existing: Boolean;

begin
  Result := Add(AUDN, existing);
end;


function TUPnPDevices.Find(const AUDN: String): TUPnPDevice;
var
  itemIndex: Integer;

begin
  Result := nil;

  for itemIndex := 0 to Pred(Count) do
    if Items[itemIndex].UDN = AUDN then
    begin
      Result := Items[itemIndex];
      Break;
    end;
end;


function TUPnPDevices.GetItem(Index: Integer): TUPnPDevice;
begin
  Result := TUPnPDevice(inherited GetItem(Index));
end;


procedure TUPnPDevices.SetItem(Index: Integer; Value: TUPnPDevice);
begin
  inherited SetItem(Index, Value);
end;


{ TUPnPWorker }
function TUPnPWorker.Initialize: Boolean;
begin
  OleCheck(CoInitialize(nil));

  Log('Creating UPnPDeviceFinder instance');
  if CoCreateInstance(CLASS_UPnPDeviceFinder, nil, CLSCTX_INPROC_SERVER or
                      CLSCTX_LOCAL_SERVER, IUPnpDeviceFinder, FDeviceFinder) <> S_OK then
  begin
    Task.Comm.Send(UPNP_CALLBACK_LOG, 'Failed to create UPnPDeviceFinder');
    Result := False;
    Exit;
  end;

  FAction := Task.Param.ByName(UPNP_PARAM_ACTION, 0).AsInteger;
  FExternalPort := Task.Param.ByName(UPNP_PARAM_EXTERNALPORT, 0).AsInteger;
  FInternalPort := Task.Param.ByName(UPNP_PARAM_INTERNALPORT, 0).AsInteger;
  FInternalIP := Task.Param.ByName(UPNP_PARAM_INTERNALIP, '').AsString;

  SearchForDevices;
  Result := True;
end;


procedure TUPnPWorker.Cleanup;
begin
  if Assigned(FDeviceFinder) and (FSearchHandle <> 0) then
    FDeviceFinder.CancelAsyncFind(FSearchHandle);
end;


procedure TUPnPWorker.Log(const AMessage: string);
begin
  Task.Comm.Send(UPNP_CALLBACK_LOG, AMessage);
end;


procedure TUPnPWorker.LogFmt(const AMessage: string; const AParams: array of const);
begin
  Log(Format(AMessage, AParams));
end;


procedure TUPnPWorker.LogInvokeActionError(AException: EOleSysError; const AMessage: string; AResponse: OleVariant);
var
  errorMsg: string;

begin
  case HResultCode(AException.ErrorCode) of
    UPNP_E_ACTION_REQUEST_FAILED:     errorMsg := 'The device had an internal error; the request could not be executed.';
    UPNP_E_DEVICE_ERROR:              errorMsg := 'An unknown error occurred.';
    UPNP_E_DEVICE_TIMEOUT:            errorMsg := 'The device has not responded within the 30 second time-out period.';
    UPNP_E_ERROR_PROCESSING_RESPONSE: errorMsg := 'The device has sent a response that cannot be processed; for example, the response was corrupted.';
    UPNP_E_INVALID_ACTION:            errorMsg := 'The action is not supported by the device.';
    UPNP_E_INVALID_ARGUMENTS:         errorMsg := 'One or more of the arguments passed in vInActionArgs is invalid.';
    UPNP_E_PROTOCOL_ERROR:            errorMsg := 'An error occurred at the UPnP control-protocol level.';
    UPNP_E_TRANSPORT_ERROR:           errorMsg := 'An HTTP error occurred.';
  else
    errorMsg := 'Unknown error code: ' + IntToStr(HResultCode(AException.ErrorCode)) + '.';
  end;

  if not VarIsNull(AResponse) then
    errorMsg := errorMsg + ' Device returned: ' + AResponse;

  Log(AMessage + ' (' + errorMsg + ')');
end;


procedure TUPnPWorker.SearchForDevices;
begin
  if FSearchHandle = 0 then
  begin
    Log('Searching for UPnP devices');

    FSearchHandle := FDeviceFinder.CreateAsyncFind(SchemaURNDeviceRoot, 0, Self);
    FDeviceFinder.StartAsyncFind(FSearchHandle);
  end;
end;


function TUPnPWorker.DeviceAdded(lFindData: Integer; pDevice: IUPnPDevice): HRESULT;
var
  device: TUPnPDevice;

begin
  device := TUPnPDevice.Create(nil);
  device.Description := pDevice.Description;
  device.FriendlyName := pDevice.FriendlyName;
  device.UDN := pDevice.UniqueDeviceName;
  device.HasWANConnection := False;

  Log(device.FriendlyName + ': found, testing for WAN connection');
  FindWANConnection(pDevice, device);
  if not device.HasWANConnection then
    Log(device.FriendlyName + ': no WAN connection found');

  Task.Comm.Send(UPNP_CALLBACK_DEVICEADDED, device);
  Result := S_OK;
end;


function TUPnPWorker.DeviceRemoved(lFindData: Integer; bstrUDN: Widestring): HRESULT;
begin
  Task.Comm.Send(UPNP_CALLBACK_DEVICEREMOVED, bstrUDN);
  Result := S_OK;
end;


function TUPnPWorker.SearchComplete(lFindData: Integer): HRESULT;
begin
  { The search actually goes on! }
//  FSearchHandle := 0;
  Result := S_OK;
end;


procedure TUPnPWorker.FindWANConnection(ADeviceIntf: IUPnPDevice; ADevice: TUPnPDevice);
var
  services:       TInterfaceList;
  serviceIndex:   Integer;
  service:        IUPnPService;
  inValue:        OleVariant;
  outValue:       OleVariant;
  devices:        TInterfaceList;
  deviceIndex:    Integer;
  response:       OleVariant;

begin
  { Check device for WAN service }
  services  := TInterfaceList.Create;
  try
    if CollectInterfaces(ADeviceIntf.Services._NewEnum, services) then
    begin
      for serviceIndex := 0 to Pred(services.Count) do
      begin
        service := (services[serviceIndex] as IUPnPService);

        if (service.ServiceTypeIdentifier = SchemaURNServiceWANPPP) or
           (service.ServiceTypeIdentifier = SchemaURNServiceWANIP) then
        begin
          Log(ADevice.FriendlyName + ': found WAN connection');
          ADevice.HasWANConnection  := True;

          case FAction of
            UPNP_ACTION_ADDPORTMAPPING:
              begin
                if not PortMappingExists(ADevice.FriendlyName, service) then
                begin
                  Log(ADevice.FriendlyName + ': opening port');

                  { Add port mapping }
                  inValue   := VarArrayCreate([0, 7], varVariant);
                  outValue  := VarArrayCreate([0, 0], varVariant);

                  inValue[0]  := '';                        { NewRemoteHost }
                  inValue[1]  := FExternalPort;             { NewExternalPort }
                  inValue[2]  := WANProtocolTCP;            { NewProtocol }
                  inValue[3]  := FInternalPort;             { NewInternalPort }
                  inValue[4]  := FInternalIP;               { NewInternalClient }
                  inValue[5]  := True;                      { NewEnabled }
                  inValue[6]  := WANPortMappingDescription; { NewPortMappingDescription }
                  inValue[7]  := 0;                         { NewLeaseDuration }

                  response := Null;
                  try
                    response := service.InvokeAction(WANActionAddPortMapping, inValue, outValue);
                    Log(ADevice.FriendlyName + ': device reports no errors while opening port');
                    ADevice.PortMapped := dsTrue;

                    SendResult(UPNP_RESULT_ADDPORTMAPPING, True);
                  except
                    on E:EOleSysError do
                    begin
                      LogInvokeActionError(E, ADevice.FriendlyName + ': failed to open port', response);
                      ADevice.PortMapped := dsFalse;
                      SendResult(UPNP_RESULT_ADDPORTMAPPING, False);
                    end;
                  end;
                end else
                begin
                  Log(ADevice.FriendlyName + ': port already opened, skipping');
                  ADevice.PortMapped := dsTrue;

                  SendResult(UPNP_RESULT_ADDPORTMAPPING, True);
                end;
              end;

            UPNP_ACTION_DELETEPORTMAPPING:
              begin
                if PortMappingExists(ADevice.FriendlyName, service) then
                begin
                  Log(ADevice.FriendlyName + ': closing port');

                  { Delete port mapping }
                  inValue   := VarArrayCreate([0, 2], varVariant);
                  outValue  := VarArrayCreate([0, 0], varVariant);

                  inValue[0]  := '';              { NewRemoteHost }
                  inValue[1]  := FExternalPort;   { NewExternalPort }
                  inValue[2]  := WANProtocolTCP;  { NewProtocol }

                  response := Null;
                  try
                    response := service.InvokeAction(WANActionDeletePortMapping, inValue, outValue);
                    Log(ADevice.FriendlyName + ': device reports no errors while closing port');
                    ADevice.PortMapped := dsFalse;
                    SendResult(UPNP_RESULT_DELETEPORTMAPPING, True);
                  except
                    on E:EOleSysError do
                    begin
                      { HResultCode(E.ErrorCode) = 882 if the entry didn't exist }
                      LogInvokeActionError(E, ADevice.FriendlyName + ': failed to close port', response);
                      ADevice.PortMapped := dsFalse;
                      SendResult(UPNP_RESULT_DELETEPORTMAPPING, False);
                    end;
                  end;
                end else
                begin
                  Log(ADevice.FriendlyName + ': port already closed, skipping');
                  ADevice.PortMapped := dsFalse;
                  SendResult(UPNP_RESULT_DELETEPORTMAPPING, False);
                end;
              end;
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(services);
  end;

  { Enumerate child devices }
  if ADeviceIntf.Children.Count > 0 then
  begin
    devices := TInterfaceList.Create;
    try
      if CollectInterfaces(ADeviceIntf.Children._NewEnum, devices) then
      begin
        for deviceIndex := 0 to Pred(devices.Count) do
          FindWANConnection((devices[deviceIndex] as IUPnPDevice), ADevice);
      end;
    finally
      FreeAndNil(devices);
    end;
  end;
end;


function TUPnPWorker.PortMappingExists(const ADeviceName: string; AService: IUPnPService): Boolean;
var
  portMappingIndex: Integer;
  inValue:          OleVariant;
  outValue:         OleVariant;

begin
  Result := False;
  try
    Log(ADeviceName + ': checking if port is open');

    portMappingIndex  := 0;
    repeat
      inValue     := VarArrayCreate([0, 0], varVariant);
      inValue[0]  := portMappingIndex;
      outValue    := VarArrayCreate([0, 6], varVariant);

      try
        AService.InvokeAction(WANActionGetPortMapping, inValue, outValue);
      except
        on E:EOleSysError do
        begin
          Break;
        end;
      end;

      if outValue[1] = FExternalPort then
      begin
        Result  := (outValue[3] = FInternalPort) and
                   (outValue[4] = FInternalIP);
      end;

      Inc(portMappingIndex);
    until False;
  except
    on E:EOleSysError do
      Log(ADeviceName + ': failed to check if port is open');
  end;
end;


procedure TUPnPWorker.SendResult(AMsgID: Integer; AResult: Boolean);
var
  result: TOmniValue;

begin
  result := TOmniValue.CreateNamed([UPNP_PARAM_RESULT, AResult,
                                    UPNP_PARAM_DATA, Task.Param.ByName(UPNP_PARAM_DATA, 0).AsInteger]);

  Task.Comm.Send(UPNP_RESULT_ADDPORTMAPPING, result);
end;

end.
