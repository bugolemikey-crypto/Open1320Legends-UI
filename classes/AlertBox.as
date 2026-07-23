class classes.AlertBox extends classes.BaseBox
{
   var contentMC;
   function AlertBox()
   {
      super();
   }
   function setValue(alertTitle, alertMessage, alertIcon)
   {
      trace("icon: " + alertIcon);
      this.contentMC.alertIconMC.gotoAndStop(alertIcon);
      this.contentMC.alertTitle.text = alertTitle;
      this.contentMC.alertMessage.html = false;
      this.contentMC.alertMessage.text = alertMessage;
   }
}
