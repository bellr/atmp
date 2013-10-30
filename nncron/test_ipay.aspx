<?

define('PROJECT','HOME');
define('VS_DEBUG',true);
require_once(dirname($_SERVER['DOCUMENT_ROOT'])."/core/vs.php");



require("customsql.inc.aspx");
$db = new CustomSQL($DBName);

$db->raschet_partner(0,1000,1);

exit;

$xmlres = simplexml_load_string(str_replace('\"','"',$_POST['XML']));
$sign = strtoupper(md5('1@-+=//\fasdJJ'.str_replace('\"','"',$_POST['XML'])));
$ar = getallheaders();

	if($ar['ServiceProvider-Signature'] == 'SALT+MD5: '.$sign) {
switch($xmlres->RequestType):

case ("ServiceInfo") :

$demand_info = $db->order_iPay($xmlres->PersonalAccount,'n');
if($demand_info[0]["status"] != "p") {
if(!empty($demand_info)) {

$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <ServiceInfo>
    <Amount>
      <Debt>'.$demand_info[0]["summa"].'</Debt>
    </Amount>
  </ServiceInfo>
</ServiceProvider_Response>';
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' находится в процессе оплаты!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
	break;

case ("TransactionStart") :

$demand_info = $db->order_iPay($xmlres->PersonalAccount,'n');
$db->demand_edit('p',$xmlres->PersonalAccount);
$db->add_id_pay($xmlres->TransactionStart->TransactionId,$xmlres->PersonalAccount);
$id_pay = $db->sel_idpay($xmlres->PersonalAccount);

if($demand_info[0]["status"] != "p") {
	if(!empty($demand_info)) {

if($xmlres->TransactionStart->TransactionId = $demand_info[0]['summa']) {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionStart>
    <ServiceProvider_TrxId>'.$id_pay[0]["id_pay"].'</ServiceProvider_TrxId>
  </TransactionStart>
</ServiceProvider_Response>';
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Неверная сумма заказа!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
}
else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' находится в процессе оплаты!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
}
break;

case ("TransactionResult") :

$demand_info = $db->order_iPay($xmlres->PersonalAccount,'p');
	if(!empty($demand_info)) {
		if(empty($xmlres->TransactionResult->ErrorText)) {

//функция извлечения пин-кодов и изменения статуса заявки
	$result_order = $db->open_kod($demand_info[0]['order_arr'],$xmlres->PersonalAccount);
	if($demand_info[0]['send_mail'] == "1") {$db->creat_mail($_POST['did'],$result_order,$demand_info[0]['order_arr'],$demand_info[0]['company'],$demand_info[0]['email']);}
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
   <Info>
 	 <InfoLine>Заказ номер '.$xmlres->PersonalAccount.' успешно оплачен.</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
		else {
	//$db->demand_add_coment(iconv("utf-8","windows-1251",$xmlres->TransactionResult->ErrorText),$xmlres->PersonalAccount);
	$db->demand_edit('n',$xmlres->PersonalAccount);

$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
  <TransactionResult>
    <Info>
      <InfoLine>ВНИМАНИЕ! Заказ отменен!</InfoLine>
    </Info>
  </TransactionResult>
</ServiceProvider_Response>';
		}
	}
	else {
$xml = '<?xml version="1.0" encoding="windows-1251" ?>
<ServiceProvider_Response>
 <Error>
    <ErrorLine>Заказ номер '.$xmlres->PersonalAccount.' не существует (просрочен) или уже оплачен!</ErrorLine>
  </Error>
</ServiceProvider_Response>';
	}
break;
endswitch;

$sign_ipay = strtoupper(md5('1@-+=//\fasdJJ'.$xml));
header("ServiceProvider-Signature: SALT+MD5: {$sign_ipay}");
echo $xml;
	}
?>
