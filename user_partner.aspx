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
<Title>�������</Title>
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
		<td>
<table width="100%" border="0" cellspacing="1" cellpadding="4">
	<form action="partner.aspx" method="POST">
<tr>
	<td width="100%" colspan="2" class="black" align="center">
	<h3>����� ��� ������ ������������</h3>
	</td>
</tr>
<tr>
	<td width="50%" align="right">������� E-Mail ������������ : </td>
	<td width="50%" align="left">
	<input type="text" name="email" value="<? echo $_POST['email']; ?>">
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
	<input type="submit" name="search_partner" value="�����"><br /><br />
	</td>
</tr>
	</form>
</table>
<?
if(!empty($sel_partner)) {
?>
<center>�������� ������ ������������ ���������:
	<a href="partner_dem.aspx?oper=exch&id=<? echo $sel_partner[0]["id"]; ?>">�����</a>
	<a href="partner_dem.aspx?oper=pay&id=<? echo $sel_partner[0]["id"]; ?>">�������</a>
	<a href="partner_dem.aspx?oper=cash&id=<? echo $sel_partner[0]["id"]; ?>">����������</a><br /></center>
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
		<td width="30%">��� :</td>
		<td width="10%"><input type="text" name="username" value="<? echo $sel_partner[0]["username"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">���� :</td>
		<td width="10%"><input type="text" name="host" value="<? echo $sel_partner[0]["host"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">������� ������ :</td>
		<td width="10%"><input type="text" name="balance" value="<? echo $sel_partner[0]["balance"]; ?>"> $</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">����������� �������� :</td>
		<td width="10%"><? echo $sel_partner[0]["summa_bal"]; ?>$</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">����� ����������� ������� ����� ��������� :</td>
		<td width="10%"><? echo $sel_partner[0]["summ_oper"]; ?>$</td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">������� �������������� :</td>
		<td width="10%"><input type="text" name="percent" value="<? echo $sel_partner[0]["percent"]; ?>"></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">���������� ��������� � ����� :</td>
		<td width="10%"><? echo $sel_partner[0]["refer"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%">���������� ����������� �������� :</td>
		<td width="10%"><? echo $sel_partner[0]["count_oper"]; ?></td>
	</tr>
	<tr bgcolor="#ffffff">
		<td width="30%" align="right">������������ :</td>
		<td width="10%"><? echo "<input type=\"checkbox\" name=\"st\""; if($sel_partner[0]["status"] == 0) echo " checked=1>"; ?></td>
	</tr>
<tr bgcolor="#ffffff" align="center">
	<td>
	<input type="submit" name="update_partner" value="��������"><br />
	</td>
	<td>
	<input type="submit" name="del_partner" value="�������"><br />
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