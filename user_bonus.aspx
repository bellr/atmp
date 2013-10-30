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

if(!empty($_GET['update_bonus'])) {
	if($_GET['st']) $status = 0;
	else $status = 1;
	$db->update_bonus($_GET['email'],$_GET['summa_demand'],$_GET['discount'],$status);}
if(!empty($_GET['del_bonus'])) {$db->del_bonus($_GET['email']);}


if(!empty($_GET['email'])) {$info_bonus = $db->info_bonus('email',$_GET['email']);}
if(!empty($_GET['id'])) {$info_bonus = $db->info_bonus('id',$_GET['id']);}
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
	<form action="user_bonus.aspx" method="get">
<tr>
	<td width="100%" colspan="2" class="black" align="center">
	<h3>Форма для поиска пользователя</h3>
	</td>
</tr>
<tr>
	<td width="50%" align="right">Введите E-Mail пользователя : </td>
	<td width="50%" align="left">
	<input type="text" name="email" value="<? echo $_GET['email']; ?>">
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
if(!empty($info_bonus)) {
?>
<center>Смотреть заявки созданные пользователем:
	<a href="stat.aspx?oper=dem_bonus&id=<? echo $info_bonus[0]["id"]; ?>">Смотреть</a>
<table width="40%" border="0" cellspacing="1" cellpadding="3"  bgcolor="#CCCCCC">
<form action="user_bonus.aspx" method="GET">
<input type="hidden" name="email" value="<? echo $info_bonus[0]["email"]; ?>">
	<tr bgcolor="#ffffff">
		<td width="30%">ID :</td>
		<td width="10%"><? echo $info_bonus[0]["id"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">E-Mail :</td>
		<td width="10%"><? echo $info_bonus[0]["email"]; ?><input type="hidden" name="email" value="<? echo $info_bonus[0]["email"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Накопленные средства :</td>
		<td width="10%"><input type="text" name="summa_demand" size="7" value="<? echo $info_bonus[0]["summa_demand"]; ?>"> BLR</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">Процент скидки :</td>
		<td width="10%"><input type="text" name="discount" size="7" value="<? echo $info_bonus[0]["discount"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%" align="right">ЗАБЛОКИРОВАН :</td>
		<td width="10%"><? echo "<input type=\"checkbox\" name=\"st\"";  if($info_bonus[0]["status"] == "0") echo " checked=1>"; ?></td>
	</tr>
<tr bgcolor="#ffffff" align="center">
	<td><input type="submit" name="del_bonus" value="УДАЛИТЬ"><br /></td>
	<td><input type="submit" name="update_bonus" value="Обновить"><br /></td>
</tr>
	</form>
</table>
</center>
		</td>
	</tr>
</table>
<? }
else {echo "<h2 align=center>Такого пользователя не существует</h2>";}
}?>
</body></html>