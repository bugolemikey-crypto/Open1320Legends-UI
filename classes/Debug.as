class classes.Debug
{
   function Debug()
   {
   }
   static function writeLn(msg)
   {
      _root.debug += msg + "\n";
      _root.fldDebug.scroll = _root.fldDebug.maxscroll;
   }
}
