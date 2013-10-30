<?
header("Content-Type: text/html; charset=win-1251");
require('customsql.inc.aspx');
$db = new CustomSQL($DBName);
$ar_tarif = array("5000","10000","15000","20000","25000","30000","35000","40000","45000","50000","55000","60000","65000","70000","75000","80000","85000","90000","95000","100000","110000","120000","130000","140000","150000","160000","170000","180000","190000","200000","210000","220000","230000","240000","250000","260000","270000","280000","290000","300000","310000","320000","330000","340000","350000");


$data_start = date( "Y-m-d",mktime(0,0,0,date("m")-1,date("d"),date("Y")) );
$data_end = date( "Y-m-d",mktime(0,0,0,date("m"),date("d")-1,date("Y")) );

$ss = 0;
foreach($ar_tarif as $art) {
	$info = $db->selReportiFree($art,$data_start,$data_end);
	$s=0; $c=0;
	foreach($info as $ar) {$s = $s+$ar[summa];$c++;}
	if($c>0) {$ss = $ss+$s; $str .= "<tr><td>{$art}</td><td>{$c}</td></tr>";}
}
require($home_dir."include/smtp-func.aspx");
$str = "Statistics for period with {$data_start} on {$data_end}.<br /><br /><table cellpadding=\"5\" cellspacing=\"1\" border=1><tr><td>Tarrifs commerce</td><td>Amount</td></tr>{$str}</table><br /><br />Whole on amount - ".$ss." BYR";
smtpmail("l.shishko@i-free.com","Статистика от ИП Лущаков",$str,"Виталий");
sleep(3);
smtpmail("atomly@mail.ru","Статистика от ИП Лущаков",$str,"Виталий");

?>

