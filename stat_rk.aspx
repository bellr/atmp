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
if(!empty($_POST['company'])) {

	$db->add_company($_POST['site'],$_POST['desc'],$data_pay);

}
	if(!empty($_GET['upd_id'])) $db->upd_count_mest($_GET['upd_id']);
	if(!empty($_GET['del_st']))	$db->del_st($_GET['del_st']);
$rk = $db->sel_rk();
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
<?if(!empty($_GET['stat_ip'])) {
	 $st = $db->sel_st_rk($_GET['stat_ip']);
echo "<a href='stat_rk.aspx?del_st={$_GET['stat_ip']}'>Удалить статистику этой компании</a>";
?>
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td>IP</td>
		<td>PROXY</td>
		<td>Дата</td>
	</tr>
<?
if(!empty($st)) {
	foreach ($st as $ar) {
	echo "<tr bgColor='#ffffff' align='center'>
		<td>{$ar[0]}</td>
		<td>{$ar[1]}</td>
		<td>{$ar[2]}</td>
	</tr>";
	}
}?>
</table>

<?}?>
<br /><br />
<div align="left">
	<form action="stat_rk.aspx" method="post" style="display: inline;">
	Рекламная площадка : <input type="text" name="site" />
Описание компании : <textarea name="desc" rows="3" cols="50"></textarea>
	<input type="submit" name="company" value="Добавить" style="width:100px;">
</form>
</div>
<br />
<table width="100%" bgColor="#ebebeb"  border="0" cellspacing="1" cellpadding="0">
	<tr bgColor="#f8f8ff" align="center">
		<td>ID</td>
		<td>Ссылка</td>
		<td>Домен</td>
		<td>Описание</td>
		<td>Переходы</td>
		<td>Дата</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
<?
if(!empty($rk)) {
	foreach($rk as $arr) {
		if($arr['5'] == '0') $tag = "<font color=\"#FF0000\"><b>NO</b></font>";
		if($arr['5'] == '1') $tag = "<font color=\"#008000\"><b>OK</b></font>";
echo "<tr bgcolor=\"#ffffff\" align=\"center\">
		<td><a href=\"http://atm.pinshop.by/orders.aspx?did={$arr[0]}\">{$arr[0]}</a></td>
		<td>http://pinshop.by/?{$arr[0]}</td>
		<td>{$arr[1]}</td>
		<td>{$arr[2]}</td>
		<td>{$arr[4]}</td>
		<td>{$arr[3]}</td>
		<td><a href=\"stat_rk.aspx?upd_id={$arr[0]}\">Обновить</a></td>
		<td><a href=\"stat_rk.aspx?stat_ip={$arr[0]}\">Статистика</a></td>

	</tr>";
	}
 }
 ?>
</td>

	</tr>
</table>
<? } ?>
</body></html>