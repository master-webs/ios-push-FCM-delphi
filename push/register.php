<?php 
	function new_token_ios ($tokens)
	{
		$url = 'https://iid.googleapis.com/iid/v1:batchImport';
		$fields =array(
		     'application'=>'package_name',
			 'sandbox'=>false,
			 'apns_tokens' =>array($tokens) 
			);
		$headers = array(
			'Authorization:key = api_key',
			'Content-Type: application/json'
			);
	   $ch = curl_init();
       curl_setopt($ch, CURLOPT_URL, $url);
       curl_setopt($ch, CURLOPT_POST, true);
       curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
       curl_setopt ($ch, CURLOPT_SSL_VERIFYHOST, 0);  
       curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
       curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
       $result = curl_exec($ch);           
       if ($result === FALSE) {
           die('Curl failed: ' . curl_error($ch));
       }
       curl_close($ch);
	   	$res=json_decode($result, TRUE);
       return $res['results'][0]['registration_token'];
	   
	}
	
	if (isset($_POST["token"])) {
		
		   $_uv_Token=$_POST["token"];
		   $push_key=$_POST["push_key"];
		   $platform=$_POST["platform"];
		   $data=date("Y-m-d H:i:s");
		   $deviceid=$_POST["deviceid"];
		   if ($_POST["platform"]=='ios'){ // есть устройство IOS получаем новый токен FCM
		   $_uv_Token= new_token_ios($_uv_Token);   
		   }
		   $conn = mysqli_connect("localhost","root","","push") or die("Error connecting");
		   $q="INSERT INTO users (deviceID, Token, phone, data, platform) VALUES ('$deviceid', '$_uv_Token','$push_key','$data','$platform' ) "
              ." ON DUPLICATE KEY UPDATE deviceID ='$deviceid' ,Token = '$_uv_Token',phone = '$push_key',data = '$data',platform = '$platform';";
              
      mysqli_query($conn,$q) or die(mysqli_error($conn));
      mysqli_close($conn);
	}
 ?>