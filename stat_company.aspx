<?
session_start();
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$errortag = false;
if(!empty($_POST['enter'])) {
	$_SESSION['login'] = md5($_POST['login']);
	$_SESSION['pass'] = md5($_POST['pass']);
	header("Location: index.aspx");
}
if($_SESSION['login'] == $admin && $_SESSION['pass'] == $pass) {

$errortag = true;
if(!empty($_POST['edit_remuneration'])) {$db->edit_remuneration($_POST['percent'],$_POST['company']);}
$data = date("Y-m-d");
$mass_day = array("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31");
$mass_mount = array("(01) Январь","(02) Февраль","(03) Март","(04) Апрель","(05) Май","(06) Июнь","(07) Июль","(08) Август","(09) Сентябрь","(10) Октябрь","(11) Ноябрь","(12) Декабрь",);
$data_mas = explode("-",$data);

}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Статистика заказов</Title>
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
		<input type="hidden" name="pass" /><br />
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
		<td>
<div align="left">
	<form action="stat_company.aspx?company=<?echo $_GET['company']?>" method="post" style="display: inline;">
<b>Показать статистику с :</b>

			<select name="day_n">
<?
	if(!empty($_POST['day_n'])) $day_sel = $_POST['day_n'];
	else $day_sel = $data_mas[2];
	foreach($mass_day as $ar) {
		if($day_sel == $ar)echo "<option value=\"{$ar}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$ar}\">{$ar}</option>";
	}
?>
	</select></span>
	<select name="mount_n">
<?
	$c=1;
	if(!empty($_POST['mount_n'])) $mount_sel = $_POST['mount_n'];
	else $mount_sel = $data_mas[1];
	foreach($mass_mount as $ar) {
		if($mount_sel == $c) echo "<option value=\"{$c}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$c}\">{$ar}</option>";
	$c++;
	}
?>
	</select></span>
	<select name="year_n">
	<option value="2009">2009</option>
	<option value="2010">2010</option>
	<option value="2011">2011</option>
	<option value="2012">2012</option>
	<option value="2013" selected="selected">2013</option>
	</select>
<b>&nbsp;&nbsp;по :&nbsp;&nbsp;</b>
			<select name="day_k">
<?
	if(!empty($_POST['day_k'])) $day_sel = $_POST['day_k'];
	else $day_sel = $data_mas[2];
	foreach($mass_day as $ar) {
		if($day_sel == $ar)echo "<option value=\"{$ar}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$ar}\">{$ar}</option>";
	}
?>
	</select></span>
	<select name="mount_k">
<?
	$c=1;

	if(!empty($_POST['mount_k'])) $mount_sel = $_POST['mount_k'];
	else $mount_sel = $data_mas[1];
	foreach($mass_mount as $ar) {
		if($mount_sel == $c) echo "<option value=\"{$c}\" selected=\"selected\">{$ar}</option>";
		else echo "<option value=\"{$c}\">{$ar}</option>";
	$c++;
	}
?>
	</select></span>
	<select name="year_k">
	<option value="2009">2009</option>
	<option value="2010">2010</option>
	<option value="2011">2011</option>
	<option value="2012">2012</option>
	<option value="2013" selected="selected">2013</option>
	</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

	<input type="submit" name="sel_mount" value="Показать" style="width:100px; "onmouseover="this.style.backgroundColor='#E8E8FF';" onmouseout="this.style.backgroundColor='#f3f7ff';" id="cursor">&nbsp;
</form>
</div>
<br />
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td>№ заказа</td>
		<td>Заказ</td>
		<td>Сумма</td>
		<td>E-mail</td>
		<td>Дата</td>
		<td>Партнер</td>
		<td>Бонус</td>
	</tr>
<?
$data_n = $_POST['year_n']."-".$_POST['mount_n']."-".$_POST['day_n'];
$data_k = $_POST['year_k']."-".$_POST['mount_k']."-".$_POST['day_k'];
if($data_n == "--") $data_n = $data;
if($data_k == "--") $data_k = $data;
$unachieved_demand = $db->report($_GET['company']."|",$data_n,$data_k);

if(!empty($unachieved_demand)) {
	$summa = 0;
	foreach($unachieved_demand as $arr) {
		$sel_com = $db->info_company_pay($_GET['company']);

echo "<tr bgcolor=\"#ffffff\" align=\"center\">
		<td><a href=\"http://atm.pinshop.by/orders.aspx?did={$arr[did]}\">{$arr[did]}</a></td>
		<td>";
			$dem = explode("|",$arr[order_arr]);
		foreach($dem as $array) {
			if(!empty($array)) {
			$ar = explode(":",$array);
			$info_cards = $db->sel_card($ar[1]);
echo "<div style=\"margin:2px;\">{$info_cards[0]['name_card']}&nbsp;&nbsp;&nbsp;&nbsp;<b>".$ar[0]." шт.</b></div>";

			}
		}
		echo "</td>
		<td>{$arr[summa]} {$arr[oplata]}</td>
		<td>{$arr[email]}</td>
		<td>{$arr[data_pay]} {$arr[time_pay]}</td>
		<td><a href=\"http://atm.pinshop.by/user_partner.aspx?id={$arr['partner_id']}\">{$arr['partner_id']}</a></td>
		<td><a href=\"http://atm.pinshop.by/user_bonus.aspx?id={$arr['bonus_id']}\">{$arr['bonus_id']}</a></td>
	</tr>";
$summa = $summa + $arr[2];
	}
$prib = $summa * $sel_com[0]['remuneration']/100;
}
?>


</table>
<br /><br />

<br />
<b>Всего продано на сумму :</b> <? echo edit_balance($summa);?> BYR<br />
<b>К возврату :</b> <? echo edit_balance($summa-$prib);?> BYR<br />
<b>Прибыль :</b> <? echo edit_balance($prib); ?> BYR<br />
<a href="otchet_company.aspx?data_n=<? echo $data_n; ?>&data_k=<? echo $data_k; ?>&company=<? echo $_GET['company']; ?>" target="_blank">Отчет</a>
</td>

	</tr>
</table>
<? } ?>
</body></html>