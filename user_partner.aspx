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
		<td>
<table width="100%" border="0" cellspacing="1" cellpadding="4">
	<form action="partner.aspx" method="POST">
<tr>
	<td width="100%" colspan="2" class="black" align="center">
	<h3>Форма для поиска пользователя</h3>
	</td>
</tr>
<tr>
	<td width="50%" align="right">Введите E-Mail пользователя : </td>
	<td width="50%" align="left">
	<input type="text" name="email" value="<? echo $_POST['email']; ?>">
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
	<input type="submit" name="search_partner" value="Поиск"><br /><br />
	</td>
</tr>
	</form>
</table>
<?
if(!empty($sel_partner)) {
?>
<center>Смотреть заявки привлеченные партнером:
	<a href="partner_dem.aspx?oper=exch&id=<? echo $sel_partner[0]["id"]; ?>">Обмен</a>
	<a href="partner_dem.aspx?oper=pay&id=<? echo $sel_partner[0]["id"]; ?>">Платежи</a>
	<a href="partner_dem.aspx?oper=cash&id=<? echo $sel_partner[0]["id"]; ?>">Пополнение</a><br /></center>
<table width="40%" border="0" cellspacing="1" cellpadding="3"  bgcolor="#CCCCCC">
<form action="partner.aspx" method="POST">
	<tr bgcolor="#ffffff">
		<td width="30%">ID :</td>
		<td width="10%"><? echo $sel_partner[0]["id"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">E-Mail :</td>
		<td width="10%"><? echo $sel_partner[0]["email"]; ?><input type="hidden" name="email" value="<? echo $sel_partner[0]["email"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Имя :</td>
		<td width="10%"><input type="text" name="username" value="<? echo $sel_partner[0]["username"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Сайт :</td>
		<td width="10%"><input type="text" name="host" value="<? echo $sel_partner[0]["host"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Текущий баланс :</td>
		<td width="10%"><input type="text" name="balance" value="<? echo $sel_partner[0]["balance"]; ?>"> $</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Накопленные средства :</td>
		<td width="10%"><? echo $sel_partner[0]["summa_bal"]; ?>$</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Сумма поступивших средств через программу :</td>
		<td width="10%"><? echo $sel_partner[0]["summ_oper"]; ?>$</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Процент вознаграждения :</td>
		<td width="10%"><input type="text" name="percent" value="<? echo $sel_partner[0]["percent"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Количество переходов с сайта :</td>
		<td width="10%"><? echo $sel_partner[0]["refer"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Количество завершенных операций :</td>
		<td width="10%"><? echo $sel_partner[0]["count_oper"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%" align="right">ЗАБЛОКИРОВАН :</td>
		<td width="10%"><? echo "<input type=\"checkbox\" name=\"st\""; if($sel_partner[0]["status"] == 0) echo " checked=1>"; ?></td>
	</tr>
<tr bgcolor="#ffffff" align="center">
	<td>
	<input type="submit" name="update_partner" value="Обновить"><br />
	</td>
	<td>
	<input type="submit" name="del_partner" value="УДАЛИТЬ"><br />
	</td>
</tr>
	</form>
</table>
		</td>
	</tr>
</table>
<? }
}?>
</body></html>