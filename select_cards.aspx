<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
$sestag = false;
if($_SESSION['login'] == $admin || $_SESSION['pass'] == $pass) $sestag = true;

if(!empty($_POST['edit'])) {
	if($_POST['st_bonus']) $st_bonus = 1;
	else $st_bonus = 0;
$db->edit_card($_GET['id'],$_POST['name_card'],$_POST['name_desc'],$_POST['count'],$_POST['price'],$st_bonus,$_POST['price_wmz']);
}
//Добавление пин-кодов в базу
if(!empty($_POST['add_card'])) {

	for($i=1;$i<=20;$i++) {
		if(!empty($_POST['login'.$i]) || !empty($_POST['pass'.$i])) {	$db->add_pinkod($_POST['name_card'],$_POST['login'.$i],$_POST['pass'.$i],$_POST['serial'.$i]);
		}
		else {break;}
	}
	$sel_count_card = $db->sel_count_card($_POST['name_card']);
	$db->update_count($_POST['name_card'],$sel_count_card[0]['count']+$i-1);
}
//Добавление пин-кодов в базу из файла
if(!empty($_POST['add_card_file'])) {

$lines = file($_FILES['in_file']['tmp_name']);
	$count=0;

switch ($_POST['type_import']) :
	case ("login_pass") :
		foreach($lines as $line) {
			if(!empty($line)) {
				$lp = explode('||',$line);
				$db->add_pinkod($_POST['name_card'],$lp[0],$lp[1],$lp[2]);
				$count++;
			}
		}
	break;
	case ("pass") :
		foreach($lines as $line) {
			if(!empty($line)) {
				$lp = explode('||',$line);
				$db->add_pinkod($_POST['name_card'],'',$lp[0],$lp[1]);
				$count++;
			}
		}
	break;
endswitch;

		$sel_count_card = $db->sel_count_card($_POST['name_card']);
		$db->update_count($_POST['name_card'],$sel_count_card[0]['count']+$count);
}

if($_GET['oper'] == 'check_count') {
$count_base = $db->count_out($_GET['name_card']);
$c = $_GET['c'];
$stotal = $count_base[0]['stotal'];
}
if($stotal != $c) {
	$errortag = true;
	$error_mes = "<hr /><div class=\"red\">Количество выбранной карты (<u>{$_GET['name_card']}</u>) с базой пин-кодов не совпадает</div>
	В базе пин-кодов - {$stotal} шт.<br />
	В базе карт количество - {$c} шт.<hr />";
}

if(!empty($_POST['edit_pay'])) {
if($_POST['WebMoney_pay']) $WebMoney = 1;
else $WebMoney = 0;
if($_POST['WM_bill_pay']) $WM_bill = 1;
else $WM_bill = 0;
if($_POST['WM_direct_pay']) $WM_direct = 1;
else $WM_direct = 0;
if($_POST['WMZ_pay']) $WMZ = 1;
else $WMZ = 0;
if($_POST['EasyPay_pay']) $EasyPay = 1;
else $EasyPay = 0;
if($_POST['WebPay_pay']) $WebPay = 1;
else $WebPay = 0;
if($_POST['iPay_pay']) $iPay = 1;
else $iPay = 0;
if($_POST['iFree_pay']) $iFree = 1;
else $iFree = 0;
if($_POST['rezerv_purse']) $rezerv_purse = 1;
else $rezerv_purse = 0;
$db->edit_pay($_GET['company'],$WebMoney,$WM_bill,$WM_direct,$WMZ,$EasyPay,$WebPay,$iPay,$iFree,$rezerv_purse);
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Просмотр/редактирование карт</Title>
<link rel="stylesheet" href="http://atm.pinshop.by/include/style.css" type="text/css">
<script type="text/javascript">
<!--
function show_hide(d,name_card){
var id=document.getElementById(d);
if(id) id.style.display=id.style.display=='none'?'block':'none';
document.formEddPin.name_card.value = name_card;
}
//-->
</script>
</head>
<body>
<div style="POSITION: absolute; display: none; padding: 5px; right:0px;BORDER: black 1px solid; BACKGROUND: white;" id="add_card">
<form name="formEddPin" method="post" action="select_cards.aspx?company=<? echo $_GET['company']; ?>" enctype="multipart/form-data">
<input type="hidden" name="MAX_FILE_SIZE" value="30000">
Что добавляем? <input type="radio" checked="1" name="type_import" value="login_pass" /> Логин/пароль
<input type="radio" value="pass" name="type_import" /> Пин-коды
<br />
<!-- Имя импортируемого файла<input type="text" name="in_file" value=".txt" /> -->
Имя импортируемого файла<input type="file" name="in_file" size=50 />
<input type="submit" name="add_card_file" value="Импорт" /><br />
<hr />
<b>Добавление кодов для карты : </b><input type="text" size=50 name="name_card" style="width:120px;" /><br />
<?
for($i=1;$i<=20;$i++) {

echo "
Логин : <input type=\"text\" size=50 name=\"login{$i}\" style=\"margin: 5px; width:100px;\" />&nbsp;&nbsp;&nbsp;&nbsp;
Пароль : <input type=\"text\" size=50 name=\"pass{$i}\" style=\"margin: 5px; width:100px;\" />
Серийный № : <input type=\"text\" size=50 name=\"serial{$i}\" style=\"margin: 5px; width:100px;\" /><br />";
}
echo "<input type=\"submit\" name=\"add_card\" value=\"Добавить Пин-коды\" style=\"margin: 5px;\" /></div></form>";
if(!$sestag) {
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
?>
<? include('include/head.aspx'); ?>
<table width=100% bgColor="#ebebeb" cellpadding="5">
	<tr bgColor="#ffffff">
		<td width="200" valign="top">
<? include('include/top.aspx'); ?>
</td>
		<td>
<?
$pay = $db->info_company_pay($_GET['company']);
$info_card = $db->info_card($_GET['company']);

echo "<u>Способы оплаты</u><br />
<form method=\"post\" name=edit_pay action=\"select_cards.aspx?company=".$_GET['company']."\">

<table width=100% border=\"0\" bgColor=\"#ebebeb\" cellpadding=\"5\"  cellspacing=\"1\">
	<tr bgColor=\"#ffffff\">
		<td>
<b>WebMoney : </b><input type=\"checkbox\" name=\"WebMoney_pay\""; if($pay[0]['WebMoney'] == 1) echo " checked=1";
echo ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<b>WebMoney WMZ: </b><input type=\"checkbox\" name=\"WMZ_pay\""; if($pay[0]['WMZ'] == 1) echo " checked=1";
echo "></td>
		<td>
<b>EasyPay : </b><input type=\"checkbox\" name=\"EasyPay_pay\""; if($pay[0]['EasyPay'] == 1) echo " checked=1";
echo ">
		</td>
		<td>
<b>WebPay : </b><input type=\"checkbox\" name=\"WebPay_pay\""; if($pay[0]['WebPay'] == 1) echo " checked=1";
echo ">
		</td>
		<td>
<b>iPay : </b><input type=\"checkbox\" name=\"iPay_pay\""; if($pay[0]['iPay'] == 1) echo " checked=1";
echo ">
		</td>
	</tr>
	<tr bgColor=\"#ffffff\">
		<td><b>WM(выписка) : </b><input type=\"checkbox\" name=\"WM_bill_pay\""; if($pay[0]['WM_bill'] == 1) echo " checked=1";
echo ">
&nbsp;&nbsp;&nbsp;&nbsp;<b>WM(прямой+выписка) : </b><input type=\"checkbox\" name=\"WM_direct_pay\""; if($pay[0]['WM_direct'] == 1) echo " checked=1"; echo "></td>
		<td><b>iFree : </b><input type=\"checkbox\" name=\"iFree_pay\""; if($pay[0]['iFree'] == 1) echo " checked=1";
echo "></td>
		<td></td>
		<td></td>
	</tr>
	<tr bgColor=\"#ffffff\">
		<td><b>WM(резерв) : </b><input type=\"checkbox\" name=\"rezerv_purse\""; if($pay[0]['rezerv_purse'] == 1) echo " checked=1";
echo "></td>
		<td></td>
		<td><input type=\"submit\" name=\"edit_pay\" value=Обновить /></td>
		<td></td>
	</tr>
</table>


		</form><br />";

if($errortag) echo $error_mes;

foreach($info_card as $arr) {
	$article_goods=sprintf("%03d",$arr['id']);
echo "<form method=\"post\" action=\"select_cards.aspx?id={$arr[0]}&company={$arr[1]}&card={$arr['2']}\">
<div style=\"margin-bottom: 15px;\">
<b><span class=\"text\">Название карты</span></b>&nbsp;&nbsp;&nbsp;
<a href=\"#\" class=\"q\"><img src=\"http://pinshop.by/img/minikarta.gif\" width=\"40\" height=\"25\" alt=\"Посмотреть карту\"><div><img src=\"http://pinshop.by/img/card/{$arr['2']}.gif\" width=\"{$arr['6']}\" height=\"{$arr['7']}\"></div></a>&nbsp;&nbsp;&nbsp;
Скидка <input type=\"checkbox\" name=\"st_bonus\""; if($arr['9'] == 1) echo " checked=1";
echo ">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Код товара в системе iFree <input type=\"text\" size=5 name=\"article_goods\" value='{$article_goods}'  /><br />
<br />
<input type=\"text\" size=100 name=\"name_card\" value='"; echo $arr[3]; echo "' /><br />
<b><span class=\"text\">Описание</span></b> <br />
<textarea name=\"name_desc\" rows=\"2\" cols=\"100\">{$arr[4]}</textarea><br />
<b><span class=\"text\">Количество в наличии</span></b>&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"select_cards.aspx?oper=check_count&c={$arr[5]}&name_card={$arr['2']}&company=".$_GET['company']."\">Проверить</a>
Цена : <input type=\"text\" size=5 name=\"price\" value=\"{$arr[8]}\" /> Руб.
&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"text\" size=5 name=\"price_wmz\" value=\"{$arr[price_wmz]}\" /> $
<br />
<input type=\"text\" size=2 name=\"count\" value=\"{$arr[5]}\" /><br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"submit\" name=\"edit\" />&nbsp;&nbsp;&nbsp;
<a href=\"javascript:show_hide('add_card','".$arr[2]."')\">Добавить пин-код</a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"active_cards.aspx?card={$arr[2]}\">Показать активные карты</a>
</div>
</form>
<hr />";
}
?>
		</td>
	</tr>
</table>
<? } ?>
</body></html>