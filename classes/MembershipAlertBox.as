class classes.MembershipAlertBox extends classes.BaseBox
{
   var contentMC;
   function MembershipAlertBox()
   {
      super();
      trace("Membership alert box constructor");
   }
   function setValue(alertTitle, alertMessage, alertIcon)
   {
      trace("membershipAlertBox.setValue");
      this.contentMC.alertIconMC.gotoAndStop(alertIcon);
      this.contentMC.alertTitle.text = alertTitle;
      this.contentMC.alertMessage.html = false;
      this.contentMC.alertMessage.text = alertMessage;
      this.contentMC.btnGetMembership.onRelease = function()
      {
         trace("btnGetMembership pushed!");
         _root.openMembershipURL();
      };
   }
}
