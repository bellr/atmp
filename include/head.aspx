<?
$support_count = $db->support_count();
$book_count = $db->count_all('id','book');

?>
<table width=100% cellpadding="0">
	<tr>
		<td width=20%><a href="support.aspx?st=0">������ ���������</a> <b>(<? echo $support_count[0]['stotal']; ?>)</b><br /><a href="support.aspx?st=1">�����������</a></td>
		<td align="center" width=20%><a href="orders.aspx">����� ������</a><br /><a href="http://atm.pinshop.by/history_pay.aspx" target="_blank">������� ��������</a>
		<a href="index.aspx">���������� ���</a></td>
		<td align="center" width=20%><a href="book.aspx">����� ������� � �����������</a> <b>(<? echo $book_count[0]['stotal']; ?>)</b></td>
		<td align="center" width=20%><a href="stat.aspx">����������</a><br />
		<a href="stat_rk.aspx">���������� ��</a></td>
		<td width=20%><a href="info_partner.aspx">��� ��������</a> || <a href="user_partner.aspx">����� User`a</a><br />
		<a href="info_bonus.aspx">������������� �������</a> || <a href="user_bonus.aspx">����� User`a</a></td>
	</tr>
</table>