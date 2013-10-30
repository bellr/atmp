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
}
//echo md5('atomly');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<Title>Главная</Title>
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
		<input type="password" name="pass" /><br />
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
Карты "Белтелеком"
<?
$svego=0;
$info_card = $db->info_card_kesh('beltelecom');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Карты 'ByFly Белтелеком'";
$info_card = $db->info_card_kesh('byfly');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Wi-Fi Белтелеком";
$info_card = $db->info_card_kesh('byfly_wifi');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />life:)";
$info_card = $db->info_card_kesh('life');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Velcom";
$info_card = $db->info_card_kesh('velcom');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Velcom PRIVET";
$info_card = $db->info_card_kesh('velcom_privet');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Simtravel";
$info_card = $db->info_card_kesh('simtravel');
foreach($info_card as $arr) {
$summa = $arr[2]*$arr[1];
echo "<div class=\"menu\" align=\"left\"><b>{$arr[0]}</b> - {$arr[2]} шт. на сумму <b>".edit_balance($summa)."</b> рублей</div>";
$svego = $svego + $summa;
}
echo "<br />Всего на сумму - <b>".edit_balance($svego)."</b> рублей";
 ?>
		</td>
	</tr>
</table>
<? } ?>
</body></html>