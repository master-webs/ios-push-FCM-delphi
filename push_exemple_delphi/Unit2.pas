unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation,
  System.PushNotification, FMX.Edit
  {$IFDEF ANDROID},fmx.PushNotification.android {$ENDIF}{$IFDEF IOS},FMX.PushNotification.iOS{$ENDIF};

type
  TForm2 = class(TForm)
    ToolBar1: TToolBar;
    Memo1: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
     procedure OnReceiveNotificationEvent(Sender: TObject; const ANotification : TPushServiceNotification);
    procedure OnServiceConnectionChange(Sender: TObject; AChange : TPushService.TChanges);
    procedure Button1Click(Sender: TObject);
   private
    { Private declarations }
  public
    { Public declarations }
    APushService : TPushService;
    AServiceConnection : TPushServiceConnection;
  end;

var
  Form2: TForm2;

implementation
uses global;
{$R *.fmx}
procedure TForm2.Button1Click(Sender: TObject);
var
  ADeviceID, AdeviceToken, push_key: String;
begin
 {$IFDEF ANDROID}
    // Для Android
    APushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.GCM);
    APushService.AppProps[TPushService.TAppPropNames.GCMAppID] := 'FCM ID';

  {$ENDIF}{$IFDEF IOS}
    // Для iOS
    APushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.APS);
  {$ENDIF}

AServiceConnection := TPushServiceConnection.Create(APushService);
AServiceConnection.Active := True;
AServiceConnection.OnChange := OnServiceConnectionChange;
AServiceConnection.OnReceiveNotification := OnReceiveNotificationEvent;

ADeviceID := APushService.DeviceIDValue[TPushService.TDeviceIDNames.DeviceID];
AdeviceToken := APushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
push_key:=Edit1.Text;
Memo1.Lines.Add('ADeviceID: '+ADeviceID);
Memo1.Lines.Add('AdeviceToken: '+AdeviceToken);
Memo1.Lines.Add('push_key: '+push_key);
    if (ADeviceID <> '') AND (ADeviceToken <> '') then
    begin
     RegisterDevice(ADeviceID, ADeviceToken, push_key);
    end;

end;
 /// Устройства не всегда успевают получить токен,
/// поэтому при изменении состояния опять проверяем токен
procedure TForm2.OnServiceConnectionChange(Sender: TObject;
  AChange : TPushService.TChanges);
var
  ADeviceID, AdeviceToken, push_key: String;
begin
    // При измении состояния компонента
ADeviceID := APushService.DeviceIDValue[TPushService.TDeviceIDNames.DeviceID];
AdeviceToken := APushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];
push_key:=Edit1.Text;

    if (ADeviceID <> '') AND (ADeviceToken <> '') then
    begin
 RegisterDevice(ADeviceID, ADeviceToken, push_key);
 end;
end;
/// Процедура вывода сообщение при получении Push уведомления от сервера
procedure TForm2.OnReceiveNotificationEvent(Sender: TObject;
  const ANotification : TPushServiceNotification);
var
  MessageText : string;
begin
  // Получаем текст сообщения в зависимости ль платформы
  {$ifdef ANDROID}
    MessageText := ANotification.DataObject.GetValue('message').Value;
  {$else}
    MessageText := ANotification.DataObject.GetValue('alert').Value;
  {$endif};

  // Выводим сообщение
  ShowNotification(MessageText, 0);
end;
end.
