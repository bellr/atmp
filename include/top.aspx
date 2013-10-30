	  <DIV id="bonus"
style="BORDER: white 0px solid; DISPLAY: none; LEFT: 180px; WIDTH: 40px; POSITION: absolute; TOP: 50px"
 align=center>

<FORM name="edit_percent" id="edit_percent"  action="http://atm.pinshop.by/" method="post">
<TABLE
style="BORDER: black 1px solid; BACKGROUND: white;"
cellSpacing="0" cellPadding="10" width="120" align="center" border="0">

  <TBODY>
  <TR>
    <TD vAlign="top" colSpan="2">
      <TABLE cellSpacing="0" cellPadding="2" width="100%" border="0">
        <TBODY>
        <TR>
          <TD onselectstart="return false;" colSpan="2"><IMG title="«акрыть"
            style="LEFT: 102px; CURSOR: pointer; POSITION: absolute; TOP: 10px"
            onclick="hidebonus()"; height=14 alt="&#215;" src="img/close.gif" width="16" border="0" alt="+">

            <span class="black"> омисси€</span><br /><span id="company"></span></TD>
        <TR>
          <TD><INPUT type="hidden" name="company" size="15" maxlength="52" value=""></TD>
        <TR>
          <TD><INPUT type="text" name="percent" size="3" maxlength="32" value="">%</TD>
        <TR>
          <TD align="center">
		  <INPUT name="edit_remuneration" type="submit" value="»зменить" style="width:80px; background-color:#f3f7ff;" onmouseover="this.style.backgroundColor='#E8E8FF';" onmouseout="this.style.backgroundColor='#f3f7ff';" id="cursor">
</TBODY></TABLE></TR></TBODY></TABLE></FORM></DIV>

<div id="razd" style="margin-left: 20px;"><h1>»нтернет-провайдеры</h1></div>
<?
$info_company = $db->info_company('internet');
foreach($info_company as $arr) {

echo "<div class=\"menu\" align=\"left\"><a href=\"stat_company.aspx?company={$arr['0']}\"><b>O</b></a> <a href=\"select_cards.aspx?company={$arr['0']}\"><b>Ы</b> {$arr['1']}</a> <a href=\"#\"  onclick=\"return showbonus('{$arr['0']}','{$arr['2']}');\">{$arr['2']}%</a> </div>";
}
?>
<div id="razd" style="margin-left: 20px;"><h1>ћобильные операторы</a></h1></div>
<?
$info_company = $db->info_company('mobile');
foreach($info_company as $arr) {
echo "<div class=\"menu\" align=\"left\"><a href=\"stat_company.aspx?company={$arr['0']}\"><b>O</b></a> <a href=\"select_cards.aspx?company={$arr['0']}\"><b>Ы</b> {$arr['1']}</a>  <a href=\"#\"  onclick=\"return showbonus('{$arr['0']}','{$arr['2']}');\">{$arr['2']}%</a></div>";
}
?>
<div id="razd" style="margin-left: 20px;"><h1>јукцион</a></h1></div>
<?
$info_company = $db->info_company('auction');
foreach($info_company as $arr) {
echo "<div class=\"menu\" align=\"left\"><a href=\"stat_company.aspx?company={$arr['0']}\"><b>O</b></a> <a href=\"select_cards.aspx?company={$arr['0']}\"><b>Ы</b> {$arr['1']}</a>  <a href=\"#\"  onclick=\"return showbonus('{$arr['0']}','{$arr['2']}');\">{$arr['2']}%</a></div>";
}
?>
<div id="razd" style="margin-left: 20px;"><h1>Ёл. валюты</a></h1></div>
<div class="menu" align="left"><a href="info_emoney.aspx?cur=WMB"><b>Ы</b> WMB</a></div>
<script language="JavaScript">
<!--
function showbonus(company,percent){
    document.getElementById('bonus').style.display = 'block';
	document.edit_percent.company.value = company;
	document.edit_percent.percent.value = percent;
	document.getElementById('company').innerHTML = company;
    return false;
}
function hidebonus(){
    document.getElementById('bonus').style.display = 'none';
    return false;
}
// -->
</script>