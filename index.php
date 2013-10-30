<?php
$mtime1 = explode(" ", microtime());
$starttime = $mtime1[1] + $mtime1[0];

define('PROJECT','ATM');
define('PROJECT_ROOT',dirname(__FILE__));
define('VS_DEBUG',true);

require_once(dirname(PROJECT_ROOT)."/core/vs.php");

/*if(Session::get('login') == $admin && $_SESSION['pass'] == $pass) {

}*/

Vitalis::Router();

$mtime2 = explode(" ", microtime());
$endtime = $mtime2[1] + $mtime2[0];
$totaltime = ($endtime - $starttime);
$totaltime = number_format($totaltime, 7);

vsLog::add($totaltime,'totaltime');
/*echo "<b>Время загрузки: ".$totaltime." сек.<b>";*/

