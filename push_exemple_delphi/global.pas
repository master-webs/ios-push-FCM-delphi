unit global;

interface

uses
  System.Classes, SysUtils, System.Notification,System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;

///  <summary>
///  Процедура регистрации устройства.
///  </summary>
///  <param name="DeviceID">
///  ID регистрируемого устройства
///  </param>
///  <param name="DeviceToken">
///  Токен регистрируемого устройства
///  </param>
procedure RegisterDevice(DeviceID : string; DeviceToken : string; push_key : string);


///  <summary>
///  Процедура вывода сообщения из приложения.
///  </summary>
///  <param name="MessageText">
///  Текст выводимого сообщения
///  </param>
///  <param name="BadgeNumber">
///  Число выводимое на иконку приложения
///  </param>
procedure ShowNotification(MessageText : string; BadgeNumber : integer);

const
  // Доменное имя сайта 
  DOMAIN: string = 'http://exemple/';

implementation


procedure RegisterDevice(DeviceID : string; DeviceToken : string; push_key : string);
var
  client: THTTPClient;
  response: IHTTPResponse;
  postdata: TStringList;
begin
 TThread.Synchronize(TThread.CurrentThread, procedure
  begin
       // Создаём подключение
    client := THTTPClient.Create;
  try

    // Указываем данные для отправки
    postdata := TStringList.Create;
    postdata.Add('deviceid=' + DeviceID);
    postdata.Add('token=' + DeviceToken);
    postdata.Add('push_key=' + push_key);
    {$ifdef ANDROID}
      postdata.Add('platform=android');
    {$else}
      postdata.Add('platform=ios');
    {$endif}

    // Отправляем запрос
	client.post(DOMAIN + 'register.php', postdata);
  finally
    // Отключаемся и освобождаем память
    client.Free;
  end;
    end);
end;



procedure ShowNotification(MessageText : string; BadgeNumber : integer);
var
  NotificationC: TNotificationCenter;
  Notification: TNotification;
begin

  // Создаём центр уведомлений и уведомление для отправки
  NotificationC := TNotificationCenter.Create(nil);
  Notification := NotificationC.CreateNotification;

  try
    // Если центр уведомлений поддерживается системой
      // Устанавливаем текст сообщения
      Notification.Name := MessageText;
      Notification.AlertBody := MessageText;
      Notification.Title := MessageText;
      // Включаем звук при выводе сообщение
      Notification.EnableSound := true;
      // Устанавливаем цифру на иконке приложения
      Notification.Number := BadgeNumber;
      NotificationC.ApplicationIconBadgeNumber := BadgeNumber;
      // Выводим сообщение из приложения
      NotificationC.PresentNotification(Notification);
  finally
    // Очищаем переменные
    Notification.DisposeOf;
    NotificationC.Free;
    NotificationC.DisposeOf;
  end;
end;

end.
