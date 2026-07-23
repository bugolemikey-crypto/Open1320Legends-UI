class classes.LimitedAccessFunctions
{
   function LimitedAccessFunctions()
   {
   }
   static function checkForLimitedAccessAlert(checkThis)
   {
      if(_global.loginXML.firstChild.firstChild.attributes.act == 1)
      {
         classes.LimitedAccessFunctions.showLimitedAccessAlert(false,checkThis);
      }
      else
      {
         classes.LimitedAccessFunctions.showLimitedAccessAlert(true,checkThis);
      }
   }
   static function showLimitedAccessAlert(showAlert, alert)
   {
      trace("hiding myself!");
      alert._visible = showAlert;
      alert.enabled = showAlert;
      alert.useHandCursor = showAlert;
      alert.onRelease = classes.LimitedAccessFunctions.limitedAccessPushed;
   }
   static function limitedAccessPushed()
   {
      _root.abc.closeMe();
      _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogActivateAccountContentNew"});
   }
}
