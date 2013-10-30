<?
function check_payment($ex_input,$purse_in,$in_val,$desc_pay,$did,$sel_idpay) {
//путь изменить
include("xml/conf.php");
include("xml/wmxiparser.php");

//$db = new CustomSQL($DBName);
$db_exchange = new CustomSQL_exchange($DBName_exchange);
$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);

$parser = new WMXIParser();
	if ($ex_input == "WMZ" || $ex_input == "WMR" || $ex_input == "WME" || $ex_input == "WMG" || $ex_input == "WMU" || $ex_input == "WMY" || $ex_input == "WMB") { $wmt_purse = $ex_input; $ex_input = "WMT";}

switch ($ex_input) :

	case ("WMT") :

$exch_balance = $db_exchange->exch_balance($wmt_purse);
$balance_in = $exch_balance[0]["balance"];

if ($balance_in >= $in_val) {

	$response = $wmxi->X2(
			intval($sel_idpay),    # номер перевода в системе учета отправителя; любое целое число без знака, должно быть уникальным
			$exch_balance[0]["purse"],          # номер кошелька с которого выполняется перевод (отправитель)
			$purse_in,         # номер кошелька, но который выполняется перевод (получатель)
			floatval($in_val),  # число с плавающей точкой без незначащих символов
			'0',    # целое от 0 до 255 символов; 0 - без протекции
			'',       # произвольная строка от 0 до 255 символов; пробелы в начале или конце не допускаются
			trim($desc_pay),        # произвольная строка от 0 до 255 символов; пробелы в начале или конце не допускаются
			'0'    # целое число > 0; если 0 - перевод не по счету
		);
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
echo "Ошибка ".$kod_error;
echo "<br />".$purse_in;

		if ($kod_error == "0") {
			$bal_in = $balance_in - $in_val * 1.008;
			$db_exchange->demand_update_bal($bal_in,$wmt_purse);
			$db_exchange->demand_edit('y',$did);
		}
		else {
			$db_exchange->demand_add_coment('В связи с техническими неполадками, заявка была совершена некорректно. Сообщите администрации. ERROR='.$kod_error,$did); exit();}
			}
			else {
				$db_exchange->demand_add_coment('Баланс обмениваемой валюты уменьшился в процессе обмена. Сообщите администрации.',$did);
				exit();
			}
	break;
	case ("RBK Money") :
$exch_balance = $db_exchange->exch_balance($ex_input);
$balance_in = $exch_balance[0]["balance"];
$in_val_com = $in_val * 1.005;
if ($balance_in >= $in_val_com) {
	$bal_in = $balance_in - $in_val * 1.005;
	$db_exchange->demand_update_bal($bal_in,$ex_input);
	//$db_exchange->demand_edit('yn',$did);
}
	break;
	case ("EasyPay") :
$exch_balance = $db_exchange->exch_balance($ex_input);
$balance_in = $exch_balance[0]["balance"];
$in_val_com = $in_val * 1.02;
if ($balance_in >= $in_val_com) {
//отправка данных платежа на телефон через смс
require("/home/wmrb/data/www/wm-rb.net/mailer/class.phpmailer.aspx");
	$mail = new PHPMailer();
	$mail->IsSMTP();
	$mail->Host = $mail_host;
	$mail->SMTPAuth = true;
	$mail->Username = $mail_user;
	$mail->Password = $mail_pass;
	$mail->From = 'support@wm-rb.net';
	$mail->FromName = "atomly";
	$mail->AddAddress('1176044@sms.velcom.by');
	$mail->WordWrap = 2024;
	$mail->IsHTML(false);
	$mail->Subject = "1221";
	$mail->Body = $purse_in."#".$in_val."#3020";
	$mail->Send();
	$bal_in = $balance_in - $in_val_com;
	$db_exchange->demand_update_bal($bal_in,$ex_input);
	//$db_exchange->demand_edit('yn',$did);
}
	break;
	case ("YaDengi") :
$exch_balance = $db_exchange->exch_balance($ex_input);
$balance_in = $exch_balance[0]["balance"];
if ($balance_in >= $in_val) {
	$bal_in = $balance_in - $in_val;
	$db_exchange->demand_update_bal($bal_in,$ex_input);
	//$db_exchange->demand_edit('yn',$did);
}
	break;
	case ("Z-PAYMENT") :
$exch_balance = $db_exchange->exch_balance($ex_input);
$balance_in = $exch_balance[0]["balance"];
$in_val_com = $in_val;
if ($balance_in >= $in_val_com) {
//отправка данных платежа на телефон через смс

require("/home/wmrb/data/www/wm-rb.net/mailer/class.phpmailer.aspx");
	$mail = new PHPMailer();
	$mail->IsSMTP();
	$mail->Host = $mail_host;
	$mail->SMTPAuth = true;
	$mail->Username = $mail_user;
	$mail->Password = $mail_pass;
	$mail->From = 'support@wm-rb.net';
	$mail->FromName = "atomly";
	$mail->AddAddress('1176044@sms.velcom.by');
	$mail->WordWrap = 2024;
	$mail->IsHTML(false);
	$mail->Subject = "1221";
	$mail->Body = "Z-PAYMENT -> ".$in_val;
	$mail->Send();

	$bal_in = $balance_in - $in_val_com;
	$db_exchange->demand_update_bal($bal_in,$ex_input);
	//$db_exchange->demand_edit('yn',$did);
}
	break;
	default:
endswitch;
}


//функция обновления баланса после оплаты по услугам
function check_pay_uslugi($did,$output,$name_uslugi,$in_val,$out_val,$pole1) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//пополнение баланса
	$db_pay_desk->demand_edit('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $out_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//изменение баланса валюты которой происходит оплата
	$exch_balance = $db_pay_desk->sel_card_bal('prior');

if ($exch_balance[0]["balance"] >= $in_val) {
	$balance_in = $exch_balance[0]["balance"] - $in_val * 1.008;
	$db_pay_desk->update_bal_card($balance_in,'prior');
//отправка данных платежа на телефон через смс
require("/home/wmrb/data/www/wm-rb.net/mailer/class.phpmailer.aspx");
	$mail = new PHPMailer();
	$mail->IsSMTP();
	$mail->Host = $mail_host;
	$mail->SMTPAuth = true;
	$mail->Username = $mail_user;
	$mail->Password = $mail_pass;
	$mail->From = 'support@wm-rb.net';
	$mail->FromName = "atomly";
	$mail->AddAddress('1176044@sms.velcom.by');
	$mail->WordWrap = 2024;
	$mail->IsHTML(false);
	$mail->Subject = "1212";
	$mail->Body = "oplata 1620 dk7733 ".$name_uslugi." ".$pole1." ".$in_val;
	$mail->Send();
echo "YES";
}
else {
	$db_pay_desk->demand_add_coment('Баланс обмениваемой валюты уменьшился в процессе обмена. Сообщите администрации.',$did);
	$db_pay_desk->demand_edit('er',$did);
}
return  $error;
}

//функция обновления баланса после оплаты пополнения карт
function output_NAL($did,$output,$out_val,$in_val,$name_card) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//пополнение баланса
	$db_pay_desk->dem_edit_output('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $in_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//изменение баланса валюты которой происходит оплата
	$exch_bal_card = $db_pay_desk->sel_card_bal($name_card);

if ($exch_bal_card[0]['balance'] >= $in_val) {
	$balance_in = $exch_bal_card[0]['balance'] - $out_val * (1 + $exch_bal_card[0]['com_card']);
	$db_pay_desk->update_bal_card($balance_in,$name_card);
}
else {
	$db_pay_desk->dem_coment_output('Баланс обмениваемой валюты уменьшился в процессе обмена. Сообщите администрации.',$did);
	$db_pay_desk->dem_edit_output('er',$did);
	$error = true;
}
return  $error;
}

//функция для работы с магазинами
function shop($did,$output,$out_val,$in_val,$name_card) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//пополнение баланса
	$db_pay_desk->dem_edit_output('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $in_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//изменение баланса валюты которой происходит оплата
	$exch_bal_card = $db_pay_desk->sel_card_bal($name_card);

if ($exch_bal_card[0]['balance'] >= $in_val) {
	$balance_in = $exch_bal_card[0]['balance'] - $out_val * (1 + $exch_bal_card[0]['com_card']);
	$db_pay_desk->update_bal_card($balance_in,$name_card);
}
else {
	$db_pay_desk->dem_coment_output('Баланс обмениваемой валюты уменьшился в процессе обмена. Сообщите администрации.',$did);
	$error = true;
}
return  $error;
}
?>