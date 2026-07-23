class classes.SpecialText
{
   function SpecialText()
   {
   }
   static function convertSmilies(istr)
   {
      var _loc2_ = 12;
      var _loc1_ = istr.split("\r").join("");
      _loc1_ = _loc1_.split("\n").join("");
      _loc1_ = classes.StringFuncs.readCdata(_loc1_);
      _loc1_ = _loc1_.split(";)").join("|;-)|");
      _loc1_ = _loc1_.split(";P").join("|;-P|");
      _loc1_ = _loc1_.split("://").join("|:-//|");
      _loc1_ = _loc1_.split(":)").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\' COLOR=\'#DEA701\'>\b&nbsp;A<FONT COLOR=\'#F2D300\'>C<FONT COLOR=\'#FEEE00\'>D<FONT COLOR=\'#FFF9AE\'>B<FONT COLOR=\'#330000\'>zIJ&nbsp;</FONT></FONT></FONT></FONT></FONT>");
      _loc1_ = _loc1_.split(":P").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zI¶</FONT><FONT COLOR=\'#FF0000\'>•&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":|").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zI4&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":/").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zI+&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":\\").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zI+&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":(").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zIK&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":O").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FBEB03\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#080806\'>z</FONT><FONT COLOR=\'#FDFDFC\'>u</FONT><FONT COLOR=\'#0E0303\'>t`ø&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":o").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FBEB03\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#080806\'>z</FONT><FONT COLOR=\'#FDFDFC\'>u</FONT><FONT COLOR=\'#0E0303\'>t`ø&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split(":D").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>z</FONT><FONT COLOR=\'#0C0901\'>I</FONT><FONT COLOR=\'#0C0902\'>O</FONT><FONT COLOR=\'#FCFCFC\'>P&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split("|:-//|").join("://");
      _loc1_ = _loc1_.split("|;-)|").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>z</FONT><FONT COLOR=\'#080401\'>N</FONT><FONT COLOR=\'#080402\'>J&nbsp;</FONT></FONT>");
      _loc1_ = _loc1_.split("|;-P|").join("<FONT FACE=\'Flash Smiley\' SIZE=\'" + _loc2_ + "\'><FONT COLOR=\'#DEA701\'>\b&nbsp;A</FONT><FONT COLOR=\'#F2D300\'>C</FONT><FONT COLOR=\'#FEEE00\'>D</FONT><FONT COLOR=\'#FFF9AE\'>B</FONT><FONT COLOR=\'#330000\'>zN¶</FONT><FONT COLOR=\'#FF0000\'>•&nbsp;</FONT></FONT>");
      return "<FONT FACE=\'AliasCond\' SIZE=\'8\'>" + _loc1_ + "</FONT>";
   }
   static function convertFromSmilies(istr)
   {
      var _loc1_ = istr.split("ACDBzIJ").join(":)");
      _loc1_ = _loc1_.split("ACDBzIOP").join(":D");
      _loc1_ = _loc1_.split("ACDBzI4").join(":|");
      _loc1_ = _loc1_.split("ACDBzI+").join(":\\");
      _loc1_ = _loc1_.split("ACDBzIK").join(":(");
      _loc1_ = _loc1_.split("ACDBzI").join(":P");
      _loc1_ = _loc1_.split("ACDBzut`").join(":O");
      _loc1_ = _loc1_.split("ACDBzNJ").join(";)");
      _loc1_ = _loc1_.split("ACDBzN").join(";P");
      return _loc1_;
   }
}
