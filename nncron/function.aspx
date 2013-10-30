<?
function SendSmsAnswer($prjID,$serviceNumber,$abonentId,$smsText,$now,$sk,$uniqueMessageID,$needDeliveryNotification,$id_pay,$did) {
	global $db;
	$md5key = strtoupper(md5($prjID.'sms'.$serviceNumber.$abonentId.$smsText.$now.$sk));
	$providerProperties = urlencode(base64_encode("<dictionary><item name='UniqueMessageID'>".$uniqueMessageID."</item></dictionary>"));
$url = "http://infoflows.partnersystem.i-free.ru/Send.aspx?prjId={$prjID}&serviceNumber={$serviceNumber}&abonentId={$abonentId}&type=sms&smsText=".urlencode($smsText)."&now={$now}&md5key={$md5key}&providerProperties={$providerProperties}&needDeliveryNotification={$needDeliveryNotification}&partnerMessageId={$id_pay}";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_NOBODY, false);
$answer = curl_exec($ch);

//$answer = "<Response status='0' errorCode=' 513' ><Exception>message</Exception></Response>"; //для теста
$answer = '<?xml version="1.0" encoding="utf-8" ?>'.$answer;

$xmlres = simplexml_load_string($answer);
if($xmlres['status'] == 0) {$db->demand_edit('er',$did);
$db->demand_add_coment('ERROR: '.$xmlres->Exception,$did);}
		$fd = fopen("log_ifree.log","a");
		fputs($fd, "Answer - ".$answer."\n".$url."\n");
                fflush($fd);
		fclose($fd);
}
//отправка сообщения об ошибке
function SendSmsBadAnswer($prjID,$serviceNumber,$abonentId,$smsText,$now,$sk,$uniqueMessageID,$needDeliveryNotification) {
	global $db;
	$md5key = strtoupper(md5($prjID.'sms'.$serviceNumber.$abonentId.$smsText.$now.$sk));
	$providerProperties = urlencode(base64_encode("<dictionary><item name='UniqueMessageID'>".$uniqueMessageID."</item></dictionary>"));
$url = "http://infoflows.partnersystem.i-free.ru/Send.aspx?prjId={$prjID}&serviceNumber={$serviceNumber}&abonentId={$abonentId}&type=sms&smsText=".urlencode($smsText)."&now={$now}&md5key={$md5key}&providerProperties={$providerProperties}&needDeliveryNotification={$needDeliveryNotification}";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_NOBODY, false);
$answer = curl_exec($ch);
		$fd = fopen("log_ifree.log","a");
		fputs($fd, "Bad answer - ".$answer."\n".$url."\n");
                fflush($fd);
		fclose($fd);
}
function SendSmsFriend($prjID,$serviceNumber,$subscriber,$smsText,$now,$sk,$uniqueMessageID,$needDeliveryNotification) {
	global $db;
	$md5key = strtoupper(md5($prjID.'sms'.$serviceNumber.$subscriber.$smsText.$now.$sk));
	$providerProperties = urlencode(base64_encode("<dictionary><item name='UniqueMessageID'>".$uniqueMessageID."</item></dictionary>"));
$url = "http://infoflows.partnersystem.i-free.ru/Send.aspx?prjId={$prjID}&serviceNumber={$serviceNumber}&subscriber={$subscriber}&type=sms&smsText=".urlencode($smsText)."&now={$now}&md5key={$md5key}&providerProperties={$providerProperties}&needDeliveryNotification={$needDeliveryNotification}&partnerMessageId={$id_pay}";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_NOBODY, false);
$answer = curl_exec($ch);

$answer = '<?xml version="1.0" encoding="utf-8" ?>'.$answer;

$xmlres = simplexml_load_string($answer);
if($xmlres['status'] == 0) {$db->demand_edit('er',$did);
$db->demand_add_coment('ERROR: '.$xmlres->Exception,$did);}
		$fd = fopen("log_ifree.log","a");
		fputs($fd, "Answer friend - ".$answer."\n".$url."\n");
                fflush($fd);
		fclose($fd);
}
?>