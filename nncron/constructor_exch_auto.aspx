<?
function check_payment($ex_input,$purse_in,$in_val,$desc_pay,$did,$sel_idpay) {
//���� ��������
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
			intval($sel_idpay),    # ����� �������� � ������� ����� �����������; ����� ����� ����� ��� �����, ������ ���� ����������
			$exch_balance[0]["purse"],          # ����� �������� � �������� ����������� ������� (�����������)
			$purse_in,         # ����� ��������, �� ������� ����������� ������� (����������)
			floatval($in_val),  # ����� � ��������� ������ ��� ���������� ��������
			'0',    # ����� �� 0 �� 255 ��������; 0 - ��� ���������
			'',       # ������������ ������ �� 0 �� 255 ��������; ������� � ������ ��� ����� �� �����������
			trim($desc_pay),        # ������������ ������ �� 0 �� 255 ��������; ������� � ������ ��� ����� �� �����������
			'0'    # ����� ����� > 0; ���� 0 - ������� �� �� �����
		);
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
echo "������ ".$kod_error;
echo "<br />".$purse_in;

		if ($kod_error == "0") {
			$bal_in = $balance_in - $in_val * 1.008;
			$db_exchange->demand_update_bal($bal_in,$wmt_purse);
			$db_exchange->demand_edit('y',$did);
		}
		else {
			$db_exchange->demand_add_coment('� ����� � ������������ �����������, ������ ���� ��������� �����������. �������� �������������. ERROR='.$kod_error,$did); exit();}
			}
			else {
				$db_exchange->demand_add_coment('������ ������������ ������ ���������� � �������� ������. �������� �������������.',$did);
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
//�������� ������ ������� �� ������� ����� ���
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
//�������� ������ ������� �� ������� ����� ���

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


//������� ���������� ������� ����� ������ �� �������
function check_pay_uslugi($did,$output,$name_uslugi,$in_val,$out_val,$pole1) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//���������� �������
	$db_pay_desk->demand_edit('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $out_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//��������� ������� ������ ������� ���������� ������
	$exch_balance = $db_pay_desk->sel_card_bal('prior');

if ($exch_balance[0]["balance"] >= $in_val) {
	$balance_in = $exch_balance[0]["balance"] - $in_val * 1.008;
	$db_pay_desk->update_bal_card($balance_in,'prior');
//�������� ������ ������� �� ������� ����� ���
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
	$db_pay_desk->demand_add_coment('������ ������������ ������ ���������� � �������� ������. �������� �������������.',$did);
	$db_pay_desk->demand_edit('er',$did);
}
return  $error;
}

//������� ���������� ������� ����� ������ ���������� ����
function output_NAL($did,$output,$out_val,$in_val,$name_card) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//���������� �������
	$db_pay_desk->dem_edit_output('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $in_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//��������� ������� ������ ������� ���������� ������
	$exch_bal_card = $db_pay_desk->sel_card_bal($name_card);

if ($exch_bal_card[0]['balance'] >= $in_val) {
	$balance_in = $exch_bal_card[0]['balance'] - $out_val * (1 + $exch_bal_card[0]['com_card']);
	$db_pay_desk->update_bal_card($balance_in,$name_card);
}
else {
	$db_pay_desk->dem_coment_output('������ ������������ ������ ���������� � �������� ������. �������� �������������.',$did);
	$db_pay_desk->dem_edit_output('er',$did);
	$error = true;
}
return  $error;
}

//������� ��� ������ � ����������
function shop($did,$output,$out_val,$in_val,$name_card) {

	//$db = new CustomSQL($DBName);
	$db_exchange = new CustomSQL_exchange($DBName_exchange);
	$db_pay_desk = new CustomSQL_pay_desk($DBName_pay_desk);
//���������� �������
	$db_pay_desk->dem_edit_output('yn',$did);
	$exch_balance = $db_exchange->exch_balance($output);
	$bal_in = $exch_balance[0]['balance'] + $in_val;
	$db_exchange->demand_update_bal($bal_in,$output);
//��������� ������� ������ ������� ���������� ������
	$exch_bal_card = $db_pay_desk->sel_card_bal($name_card);

if ($exch_bal_card[0]['balance'] >= $in_val) {
	$balance_in = $exch_bal_card[0]['balance'] - $out_val * (1 + $exch_bal_card[0]['com_card']);
	$db_pay_desk->update_bal_card($balance_in,$name_card);
}
else {
	$db_pay_desk->dem_coment_output('������ ������������ ������ ���������� � �������� ������. �������� �������������.',$did);
	$error = true;
}
return  $error;
}
?>