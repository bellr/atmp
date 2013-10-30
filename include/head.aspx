<?
$support_count = $db->support_count();
$book_count = $db->count_all('id','book');

?>
<table width=100% cellpadding="0">
	<tr>
		<td width=20%><a href="support.aspx?st=0">Служба поддержки</a> <b>(<? echo $support_count[0]['stotal']; ?>)</b><br /><a href="support.aspx?st=1">Прочитанные</a></td>
		<td align="center" width=20%><a href="orders.aspx">Поиск заказа</a><br /><a href="http://atm.pinshop.by/history_pay.aspx" target="_blank">История кошелька</a>
		<a href="index.aspx">Статистика кеш</a></td>
		<td align="center" width=20%><a href="book.aspx">Книга отзывов и предложений</a> <b>(<? echo $book_count[0]['stotal']; ?>)</b></td>
		<td align="center" width=20%><a href="stat.aspx">Статистика</a><br />
		<a href="stat_rk.aspx">Статистика РК</a></td>
		<td width=20%><a href="info_partner.aspx">Все партнеры</a> || <a href="user_partner.aspx">Найти User`a</a><br />
		<a href="info_bonus.aspx">Накопительная система</a> || <a href="user_bonus.aspx">Найти User`a</a></td>
	</tr>
</table>