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
	$errormsg = "<b>����� � ������� ".$_GET['did']." ������</b>";
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
	else echo "<center class=red>������ ���������� ��� ����������� � ������� �{$check_receipt[0][did]}</center>";
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
				<b>���-��� : </b>{$sel_pin[0][2]}<br />";
	}
	else {
switch ($_POST["company"]) :
	case ("niks") :
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
						<b>����� : </b>niks\\{$sel_pin[0][1]}&nbsp;<b>������ : </b>{$sel_pin[0][2]}<br />";
	break;
	case ("byfly") :
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
								<b>��� ��������� : </b>{$sel_pin[0][1]}&nbsp;<b>���-��� : </b>{$sel_pin[0][2]}<br />";
	break;
	default:
					$pin_kod .= "<u>{$name_card[0]['name_card']}</u><br />
								<b>����� : </b>{$sel_pin[0][1]}&nbsp;<b>������ : </b>{$sel_pin[0][2]}<br />";
	break;
endswitch;
	}
		$db->update_status('0',$sel_pin[0]['0']);
		$db->update_count_m($arr);
		}
	}
	$from_name = "Support. Team, PinShop.by";
	$subject = "�������� ���� �� �������";
	$body = "<div style=\"FONT-SIZE: 12px; FONT-FAMILY: Verdana; COLOR: #676767; LINE-HEIGHT: 18px;\"><center>������������.</center><br />
����� ����������� ������������� ���� �� ���� �������� ��� ���� � ������.<br />
���� ���������� ���� � ������, ������� �� �� ��������.<br /><br />
{$pin_kod}<br />
<br />--<br />
� ���������,<br />
������������� PinShop.by<br />
<a href='http://pinshop.by'>��������-������� ���-�����</a><br />
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
					//������� �������� �������� �������

$summa_wmb = explode(':',$demand_info[0]['order_arr']);
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/conf.php");
include("/home/bellr/data/www/atm.pinshop.by/nncron/xml/wmxiparser.php");
$parser = new WMXIParser();
$response = $wmxi->X2(intval($xmlres->TransactionResult->ServiceProvider_TrxId),$balance[0]['purse'],$demand_info[0]['purse'],floatval($info_cur[0]),'0','','��� �'.$xmlres->TransactionResult->ServiceProvider_TrxId.': ��������������� ��. ����� (����� ��������: '.$demand_info[0]['purse'].', �����: '.$summa_wmb[0].' WMB)','0');
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
<Title>�������� ������ �� ������ �<?echo $did;?></Title>
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
	����� :
		<input type="text" name="login" /><br />
		������ :
		<input type="text" name="pass" /><br />
		<input type="submit" name="enter" value="����" />

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
if($s_mail) echo "<div id=\"report\">������������ ���������� ������ � ������ :<br />
<blockquote>{$pin_kod}</blockquote></div>";
else "������ �������� : $s_mail";
 ?>

</td>
</tr/>
	<form action="orders.aspx" method="POST">
<tr>
	<td width="100%" colspan="2" class="black" align="center">
	<h3>����� �������</h3>
	</td>
</tr>
<tr>
	<td width="50%" align="right">������� ����� ������ : </td>
	<td width="50%" align="left">
	<input type="text" name="did" value="<? echo $did; ?>">
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
	<input type="submit" name="search_orders" value="�����"><br /><br />
	</td>
</tr>
	</form>
<?
	 	 if($error) echo $errormsg."<br /><br /><br /><br />";
if (!empty($info)) {
$id_pay = $db->sel_ip($did);
echo "
	<tr>
		<td width=\"100%\" colspan=2 align=\"left\"><b>������� :</b> {$info[0]["partner_id"]} &nbsp;
		<b>�������� ��������� :</b> {$info[0]["bonus_id"]}</td>
	</tr>
	<tr>
		<td width=\"100%\" colspan=2 align=\"left\"><b>IP :</b> {$id_pay[0]["addr_remote"]}    <b>PROXY :</b> {$id_pay[0]["proxy"]}<br />
		<b>� ���������� :</b> {$id_pay[0]["id_pay"]} <b>� ���������� � ������� �������� :</b> {$id_pay[0]["id_more_pay"]}
		</td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>����� ������ :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$did}</i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"http://atm.pinshop.by/orders.aspx?oper=del&did={$did}\">������� �����</a></td>
	</tr>
<!-- 	<tr>
		<td width=\"50%\" align=\"right\"><b>������ ������ :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["oplata"]}</i></td>
	</tr> -->
	<tr>
		<td width=\"50%\" align=\"right\"><b>���� ����������� :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["purse"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>�������� :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["company"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>����� ������ :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["summa"]} {$info[0]["oplata"]}</i></td>
	</tr>
	<tr>
		<td width=\"100%\" colspan=\"2\" align=\"left\"><b>����� :</b>";
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
				<div style=\"margin-top:5px;\"><u>{$info_cards[0]['name_card']}</u>&nbsp;&nbsp;&nbsp;&nbsp;<b>".$orders[0]." ��.</b>
				</div>";
				for($i=0; $i<$orders[0]; $i++) {
					$id = explode(':',$id_cards[$c_pin]);
					$serial_no = $db->serial_no($id[1]);
					$log_pass = explode(':',$log_pass_arr[$c_pin]);
if($log_pass[0] == '�� ������' || empty($log_pass[0])) $er .= $orders[1]."|";
					echo "<div id=\"vivod_pin\" style=\"float:left;margin-left:10px;margin-right:10;\"><b>ID:</b> {$id[1]} | <b>����� : </b>{$log_pass[0]}&nbsp;&nbsp;</div><div id=\"vivod_pin\"><b>������ : </b>{$log_pass[1]} &nbsp;&nbsp; <b>�������� ����� :</b> {$serial_no[0]['serial']}</div>";
					$c_pin++;
				}
				}
		}
		}
	}
	if($info[0]['type_oper'] == 'buy_emoney') {
		$orders = explode(':',$order[0]);
echo "������� ��. ����� � ���������� {$orders[0]} {$orders[1]}";
	}
echo "</td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>E-Mail :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["email"]}</i></td>
	</tr>
	<tr>
		<td width=\"50%\" align=\"right\"><b>���� :</b> </td>
		<td width=\"50%\" align=\"left\"><i>{$info[0]["data_pay"]} {$info[0]["time_pay"]}</i></td>
	</tr>
	<form method=\"post\" action=\"orders.aspx?did=$did\">";
	if (!empty($info[0]['coment'])) {
	echo "<tr>
		<td align=\"right\"><b><u>�����������</u> :</b></td>
		<td><i>{$info[0]['coment']}</i></td>
	</tr>";
	}
	if ($info[0]['oplata'] == 'cash') {
	echo "<tr>
		<td align=\"right\"><b>� ��������� :</b></td>
		<td><input type=\"text\" name=\"n_receipt\" value=\"\">  <input type=\"submit\" name=\"check_receipt\" value=\"���������\"/></td>
	</tr>";
	}
	echo "<tr>
	<td width=\"50%\" align=\"right\"><b>������ : </b></td>
	<td width=\"50%\" align=\"left\">";
	if ($info[0]["status"] == "n") {echo "<font color=\"#FF0000\"><b>�� ��������</b></font>";}
	if ($info[0]["status"] == "p") {echo "<font color=\"#0000FF\"><b>� �������� ������</b></font>";}
	if ($info[0]["status"] == "pz") {echo "<font color=\"#0000FF\"><b>� ��������(�����)</b></font>";}
	if ($info[0]["status"] == "yn") {echo "<font color=\"#0000FF\"><b>��������</b></font>";}
	if ($info[0]["status"] == "y" || $info[0]["status"] == "yz") {echo "<font color=\"#008000\"><b>���������</b></font>";}
	if ($info[0]["status"] == "er") {echo "<font color=\"#CC0000\"><b>������</b></font>";}echo "

	<select name=\"status\">
		<option value=\"none\" selected=\"selected\">�������</option>
		<option value=\"n\">�� ��������</option>
		<option value=\"yn\">��������</option>
		<option value=\"p\">� ��������</option>
		<option value=\"pz\">� ��������(�����)</option>
		<option value=\"yz\">���������(�����)</option>
		<option value=\"y\">���������</option>
		<option value=\"er\">������</option>
	</select>

	<input type=\"submit\" name=\"change_status\" value=\"��������\"/><br /><br />";
	 if($info[0]["status"] != 'y') {
	echo "<tr>
	<td width=\"100%\" align=\"center\" colspan=2>
	<input type=\"hidden\" name=\"did\" value=\"{$did}\">
	<input type=\"hidden\" name=\"type_oper\" value=\"{$info[0]['type_oper']}\">
	<input type=\"hidden\" name=\"company\" value=\"{$info[0]["company"]}\">
	<input type=\"hidden\" name=\"email\" value=\"{$info[0]["email"]}\">
	<input type=\"hidden\" name=\"order_err\" value=\"{$er}\">
	<input type=\"submit\" name=\"send_kod\" value=\"���������\"/></td>
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