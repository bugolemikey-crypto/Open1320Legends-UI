class classes.RestrictionsAlertBox extends classes.BaseBox
{
   var contentMC;
   function RestrictionsAlertBox()
   {
      super();
      trace("Restrictions alert box constructor");
   }
   function setValue(alertTitle, alertMessage, alertIcon, team)
   {
      trace("RestrictionsAlertBox.setValue");
      this.contentMC.alertIconMC.gotoAndStop(alertIcon);
      this.contentMC.alertTitle.text = alertTitle;
      this.contentMC.alertMessage.html = false;
      this.contentMC.alertMessage.text = alertMessage;
      this.contentMC.mvRestrictionsMember.btnRemoveRestrictions.onRelease = function()
      {
         trace("btnRemoveRestrictions pushed!");
         if(team)
         {
            _root.openURL(_global.teamCreationURL);
         }
         else
         {
            _root.openURL(_global.fundsBettingURL);
         }
      };
   }
}
