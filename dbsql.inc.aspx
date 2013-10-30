<?php

//include("const.inc.aspx");
$DBHost = "localhost";
$DBName = "pinshop_main";
$DBUser = "main";
$DBPassword = "16201986";

//йкюяя дкъ пюанрш я цкюбмни аюгни
Class DBSQL
{

   function DBSQL($DBName)
   {
      global $DBHost,$DBUser,$DBPassword;
      $conn=@mysql_connect($DBHost,$DBUser,$DBPassword);
	@mysql_select_db($DBName,$conn);
	mysql_query("SET CHARACTER SET CP1251",$conn);
	  $this->CONN = $conn;
      return true;
   }

   function select($sql="")
   {
      if (empty($sql)) return false;
      if (empty($this->CONN)) return false;
      $conn = $this->CONN;
      $results = mysql_query($sql,$conn);
      if ((!$results) or (empty($results)))
      {
         return false;
      }
      $count = 0;
      $data = array();
      while ($row = mysql_fetch_array($results)) {
         $data[$count] = $row;
         $count++;
      }
      mysql_free_result($results);
      return $data;
   }


   function insert($sql="")
   {
      if (empty($sql)) return false;
      if (empty($this->CONN)) return false;

      $conn = $this->CONN;
      $results = mysql_query($sql,$conn);
      if (!$results) return false;
      $results = mysql_insert_id();
      return $results;
   }


   function update($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }


   function delete($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }

   function createtable($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }

   function droptable($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }

   function createindex($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }

   function dropindex($sql="")
   {
      if(empty($sql)) return false;
      if(empty($this->CONN)) return false;

      $conn = $this->CONN;
      $result = mysql_query($sql,$conn);
      return $result;
   }

}


?>