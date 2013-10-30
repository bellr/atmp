<?php
require("customsql.inc.aspx");
$db = new CustomSQL($DBName);
$mass_sum = array("0.5" => "80000", "1" => "160000","1.5" => "320000","2" => "544000","2.5" => "800000","3" => "1088000");
//$c=0;
foreach($mass_sum as $id =>$ar) {
$bonus = $db->bonus($ar,$id-0.5);
	foreach($bonus as $a) $db->bonus_edit($bonus[0]['id'],$bonus[0]['discount']+0.5);
}
?>
