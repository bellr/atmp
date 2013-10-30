<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
$error = false;
$error_did = true;
if(!empty($_POST['enter'])) {
	$_SESSION['login'] = $_POST['login'];
	$_SESSION['pass'] = md5($_POST['pass']);
	header("Location: index.aspx");
}
if($_SESSION['login'] == $admin && $_SESSION['pass'] == $pass) $errortag = true;

if($_GET['oper'] == 'del') {
	$db->del_dem($_GET['did']);
	$db->del_idpay($_GET['did']);
	$error = true;
	$errormsg = "<b>Заказ с номером ".$_GET['did']." удален</b>";
}

if (!empty($_POST['change_status'])) {
$db->orders_edit($_POST['status'],$_GET['did']);
}

if (!empty($_POST['search_orders'])) {$did = $_POST['did']; $error_did = false;}
if (!empty($_GET['did'])) {$did = $_GET['did']; $error_did = false; }
if (!$error_did)  $info = $db->sel_orders($did);

if (!empty($_POST['check_receipt'])) {
	$check_receipt = $db->check_receipt($did,$_POST['n_receipt']);
	if(empty($check_receipt)) $db->edit_receipt($did,$_POST['n_receipt']);
	else echo "<center class=red>Данная транзакция уже проводилась с заказом №{$check_receipt[0][did]}</center>";
}

if(!empty($_POST['send_kod'])) {
	if($info[0]['type_oper'] == 'buy_pin') {
		$result_order = $db->open_kod($info[0]['order_arr'],$did);
		$info = $db->sel_orders($did);
		if($info[0]['send_mail'] == "1") {
			require($home_dir."include/smtp-func.aspx");
			$mail_ini = $db->creat_mail($did,$result_order,$info[0]['order_arr'],$info[0]['company']);
			$ar_mail = explode('|',$mail_ini);
			smtpmail($info[0]['email'],$ar_mail[0],$ar_mail[1],$ar_mail[2]);
		}

	$pin_kod = "";
	require($home_dir."include/smtp-func.aspx");
	$arr_card = explode("|",$_POST['order_err']);
	foreach($arr_card as $arr) {
		if(!empty($arr)){
		$sel_pin = $db->sel_pin($arr);
		$name_card = $db->sel_card($arr);
if(empty($sel_pin[0][1])) {
	$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
				<b>Пин-код : </b>{$sel_pin[0][2]}<br />";
	}
	else {
switch ($_POST["company"]) :
	case ("niks") :
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
						<b>Логин : </b>niks\\{$sel_pin[0][1]}&nbsp;<b>Пароль : </b>{$sel_pin[0][2]}<br />";
	break;
	case ("byfly") :
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
								<b>Код активации : </b>{$sel_pin[0][1]}&nbsp;<b>Пин-код : </b>{$sel_pin[0][2]}<br />";
	break;
	default:
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
								<b>Логин : </b>{$sel_pin[0][1]}&nbsp;<b>Пароль : </b>{$sel_pin[0][2]}<br />";
	break;
endswitch;
	}
		$db->update_status('0',$sel_pin[0]['0']);
		$db->update_count_m($arr);
		}
	}
	$from_name = "Support. Team, PinShop.by";
	$subject = "Отправка карт по запросу";
	$body = "<div style=\"FONT-SIZE: 12px; FONT-FAMILY: Verdana; COLOR: #676767; LINE-HEIGHT: 18px;\"><center>Здравствуйте.</center><br />
Ввиду сложившихся обстоятельств Вами не были получены все коды к картам.<br />
Ниже находяться коды к картам, которые Вы не получили.<br /><br />
{$pin_kod}<br />
<br />--<br />
С уважением,<br />
Администрация PinShop.by<br />
<a href='http://pinshop.by'>Интернет-магазин пин-кодов</a><br />
Mail: <a href='mailto:$robot'>$robot</a><br />
ICQ: $icq
</div>";

$s_mail = smtpmail($_POST['email'],$subject,$body,$from_name);
$s_mail = smtpmail('atomly@mail.ru',$subject,$body,$from_name);

$db->orders_edit('y',$_POST['did']);


	}
	if($info[0]['type_oper'] == 'buy_emoney') {
			$i = explode('|',$type_oper[0]["order_arr"]);
			$info_cur = explode(':',$i[0]);
			$balance = $db->sel_bal($info_cur[1]);
				$update_bal = $balance[0]['balance'] - $summa_trasfer;
				$db->upd_bal($update_bal,$info_cur[1]);
			$summa_trasfer = $info_cur[0] * (1 + $balance[0]['com_seti']);
				if($balance[0]['balance'] >= $summa_trasfer) {
					//функция перевода денежных средств

$summa_wmb = explode(':',$demand_info[0]['order_arr']);
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
$response = $wmxi->X2(intval($xmlres->TransactionResult->ServiceProvider_TrxId),$balance[0]['purse'],$demand_info[0]['purse'],floatval($info_cur[0]),'0','','Чек №'.$xmlres->TransactionResult->ServiceProvider_TrxId.': Распространение эл. денег (Номер кошелька: '.$demand_info[0]['purse'].', Сумма: '.$summa_wmb[0].' WMB)','0');
		$structure = $parser->Parse($response, DOC_ENCODING);
		$transformed = $parser->Reindex($structure, true);
		$kod_error = htmlspecialchars(@$transformed["w3s.response"]["retval"], ENT_QUOTES);
		$desc_er = htmlspecialchars(@$transformed["w3s.response"]["retdesc"], ENT_QUOTES);
				}

	}
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Просмотр данных по заказу №<?echo $did;?></Title>
<link rel="stylesheet" href="http://atm.pinshop.by/include/style.css" type="text/css">
</head>
<body>
<?
if(!$errortag) {
?>
<table width=100% height=100%>
<tr>
<td align="center">
	<form method="post" action="/">
	Логин :
		<input type="text" name="login" /><br />
		Пароль :
		<input type="text" name="pass" /><br />
		<input type="submit" name="enter" value="Вход" />

	</form>

	</td></tr>
</table>
<?
}
else {
 include('include/head.aspx'); ?>
<table width=100% bgColor="#ebebeb" cellpadding="5">
	<tr bgColor="#ffffff">
		<td width="200" valign="top">
<? include('include/top.aspx'); ?>
</td>
		<td align="center">
<table width=70% cellpadding="3">
<tr>
<td colspan=2>
<?
if($s_mail) echo "<div id=\"report\">Пользователю отправлено письмо с кодами :<br />
<blockquote>{$pin_kod}</blockquote></div>";
else "Ошибка отправки : $s_mail";
 ?>

</td>
</tr/>
	<form action="orders.aspx" method="POST">
<tr>
	<td width="100%" colspan="2" class="black" align="center">
	<h3>Поиск заказов</h3>
	</td>
</tr>
<tr>
	<td width="50%" align="right">Введите номер заказа : </td>
	<td width="50%" align="left">
	<input type="text" name="did" value="<? echo $did; ?>">
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
	<input type="submit" name="search_orders" value="Поиск"><br /><br />
	</td>
</tr>
	</form>
<?
	 	 if($error) echo $errormsg."<br /><br /><br /><br />";
if (!empty($info)) {
$id_pay = $db->sel_ip($did);
echo "
	<tr>
		<td width=\"100%\" colspan=2 align=\"left\"><b>Партнер :</b> {$info[0]["partner_id"]} &nbsp;
		<b>Бонусная программа :</b> {$info[0]["bonus_id"]}</td>
	</tr>
	<tr>
		<td width=\"100%\" colspan=2 align=\"left\"><b>IP :</b> {$id_pay[0]["addr_remote"]}    <b>PROXY :</b> {$id_pay[0]["proxy"]}<br />
		<b>№ транзакции :</b> {$id_pay[0]["id_pay"]} <b>№ транзакции в системе мерчанта :</b> {$id_pay[0]["id_more_pay"]}
		</td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>Номер заказа :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$did}</i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"http://atm.pinshop.by/orders.aspx?oper=del&did={$did}\">Удалить заказ</a></td>
	</tr>
<!-- 	<tr>
		<td width=\"50%\" align=\"right\"><b>Способ оплаты :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["oplata"]}</i></td>
	</tr> -->
	<tr>
		<td width=\"50%\" align=\"right\"><b>Счет отправителя :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["purse"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>Компания :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["company"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>Сумма заказа :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["summa"]} {$info[0]["oplata"]}</i></td>
	</tr>
	<tr>
		<td width=\"100%\" colspan=\"2\" align=\"left\"><b>Заказ :</b>";
		$order = explode('|',$info[0]['order_arr']);
	if($info[0]['type_oper'] == 'buy_pin') {
		$id_cards = explode('|',$info[0]['id_cards']);
		$log_pass_arr = explode('|',$info[0]['5']);
		$c_pin = 0;
		foreach($order as $ar_order) {

			if(!empty($ar_order)) {
				$orders = explode(':',$ar_order);
				$info_cards = $db->sel_card($orders[1]);
				if (!empty($info_cards)) {echo "<div align=\"left\" style=\"float:right;\"></div>
				<div style=\"margin-top:5px;\"><u>{$info_cards[0]['name_card']}</u>&nbsp;&nbsp;&nbsp;&nbsp;<b>".$orders[0]." шт.</b>
				</div>";
				for($i=0; $i<$orders[0]; $i++) {
					$id = explode(':',$id_cards[$c_pin]);
					$serial_no = $db->serial_no($id[1]);
					$log_pass = explode(':',$log_pass_arr[$c_pin]);
if($log_pass[0] == 'Не найден' || empty($log_pass[0])) $er .= $orders[1]."|";
					echo "<div id=\"vivod_pin\" style=\"float:left;margin-left:10px;margin-right:10;\"><b>ID:</b> {$id[1]} | <b>Логин : </b>{$log_pass[0]}&nbsp;&nbsp;</div><div id=\"vivod_pin\"><b>Пароль : </b>{$log_pass[1]} &nbsp;&nbsp; <b>Серийный номер :</b> {$serial_no[0]['serial']}</div>";
					$c_pin++;
				}
				}
		}
		}
	}
	if($info[0]['type_oper'] == 'buy_emoney') {
		$orders = explode(':',$order[0]);
echo "Покупка эл. денег в количестве {$orders[0]} {$orders[1]}";
	}
echo "</td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>E-Mail :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["email"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>Дата :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["data_pay"]} {$info[0]["time_pay"]}</i></td>
	</tr>
	<form method=\"post\" action=\"orders.aspx?did=$did\">";
	if (!empty($info[0]['coment'])) {
	echo "<tr>
		<td align=\"right\"><b><u>Комментарий</u> :</b></td>
		<td><i>{$info[0]['coment']}</i></td>
	</tr>";
	}
	if ($info[0]['oplata'] == 'cash') {
	echo "<tr>
		<td align=\"right\"><b>№ квитанции :</b></td>
		<td><input type=\"text\" name=\"n_receipt\" value=\"\">  <input type=\"submit\" name=\"check_receipt\" value=\"Проверить\"/></td>
	</tr>";
	}
	echo "<tr>
	<td width=\"50%\" align=\"right\"><b>Статус : </b></td>
	<td width=\"50%\" align=\"left\">";
	if ($info[0]["status"] == "n") {echo "<font color=\"#FF0000\"><b>Не оплачена</b></font>";}
	if ($info[0]["status"] == "p") {echo "<font color=\"#0000FF\"><b>В процессе оплаты</b></font>";}
	if ($info[0]["status"] == "pz") {echo "<font color=\"#0000FF\"><b>В процессе(залог)</b></font>";}
	if ($info[0]["status"] == "yn") {echo "<font color=\"#0000FF\"><b>Оплачена</b></font>";}
	if ($info[0]["status"] == "y" || $info[0]["status"] == "yz") {echo "<font color=\"#008000\"><b>Выполнена</b></font>";}
	if ($info[0]["status"] == "er") {echo "<font color=\"#CC0000\"><b>Ошибка</b></font>";}echo "

	<select name=\"status\">
		<option value=\"none\" selected=\"selected\">Выбрать</option>
		<option value=\"n\">Не оплачена</option>
		<option value=\"yn\">Оплачена</option>
		<option value=\"p\">В процессе</option>
		<option value=\"pz\">В процессе(залог)</option>
		<option value=\"yz\">Выполнена(залог)</option>
		<option value=\"y\">Выполнена</option>
		<option value=\"er\">Ошибка</option>
	</select>

	<input type=\"submit\" name=\"change_status\" value=\"Изменить\"/><br /><br />";
	 if($info[0]["status"] != 'y') {
	echo "<tr>
	<td width=\"100%\" align=\"center\" colspan=2>
	<input type=\"hidden\" name=\"did\" value=\"{$did}\">
	<input type=\"hidden\" name=\"type_oper\" value=\"{$info[0]['type_oper']}\">
	<input type=\"hidden\" name=\"company\" value=\"{$info[0]["company"]}\">
	<input type=\"hidden\" name=\"email\" value=\"{$info[0]["email"]}\">
	<input type=\"hidden\" name=\"order_err\" value=\"{$er}\">
	<input type=\"submit\" name=\"send_kod\" value=\"Выполнить\"/></td>
</tr>
	";
	 }

 }
?>
</table>
</td>
	</tr>
</table>
<? } ?>
</body></html>