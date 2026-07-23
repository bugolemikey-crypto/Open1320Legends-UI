function setLoginChrome(on)
{
   var _loc2_ = _parent.overlay;
   if(_loc2_ == undefined)
   {
      return undefined;
   }
   _loc2_.mapBtn._visible = on;
}
function showFBOnly(show)
{
   if(show == true)
   {
      btnFBConnect._x = 36;
      btnFBConnect._y = 493;
      btnWhatsFacebook._visible = false;
      btnForgotPW._visible = false;
      mvFbText._visible = true;
      fbOnlyBG._visible = true;
   }
   else
   {
      btnFBConnect._x = 36;
      btnFBConnect._y = 493;
      btnWhatsFacebook._visible = false;
      btnForgotPW._x = 650;
      btnForgotPW._y = 535;
      btnForgotPW._xscale = 100;
      btnForgotPW._yscale = 100;
      btnForgotPW._alpha = 0;
      btnForgotPW._visible = true;
      mvFbText._visible = false;
      fbOnlyBG._visible = false;
   }
}
function tryLogin()
{
   if(facebookLogin == false)
   {
      if(!username.length)
      {
         classes.Control.dialogAlert("Racer Name Required","Please enter your username under Racer Name.");
      }
      else if(!pass.length)
      {
         classes.Control.dialogAlert("Password Required","Please enter your password.");
      }
      else
      {
         setLoginChrome(true);
         play();
      }
   }
   else
   {
      setLoginChrome(true);
      play();
   }
}
function tryLoginWithFB()
{
   if(!fbUsername.length)
   {
      classes.Control.dialogAlert("Racer Name Required","Please enter your username under Racer Name.");
   }
   else if(!fbPass.length && facebookLogin == false)
   {
      classes.Control.dialogAlert("Password Required","Please enter your password.");
   }
   else
   {
      setLoginChrome(true);
      play();
   }
}
function activateSuccess(m)
{
   _root.alertMC = classes.AlertBox(_root.attachMovie("alertBox","alertMC",_root.getNextHighestDepth()));
   _root.alertMC.setValue("Success!",m,"success");
   _root.alertMC.addButton("OK");
   var _loc4_ = new Object();
   _loc4_.owner = this;
   _loc4_.onRelease = function(theButton, keepBoxOpen)
   {
      switch(theButton.btnLabel.text)
      {
         case "OK":
            break;
         case "Login":
            this.owner.username = this.owner.memberU;
            this.owner.pass = this.owner.memberPW;
            this.owner.tryLogin();
      }
      if(!keepBoxOpen)
      {
         false;
         theButton._parent._parent.closeMe();
      }
   };
   _root.alertMC.addListener(_loc4_);
}
function fbTokenSuccess()
{
   facebookPollCount = 0;
   classes.Frame.serverLights(true);
   facebookPollInterval = setInterval(this,"getSession",5000);
   gotoAndStop(2);
   trace(facebookPollInterval);
}
function getSession()
{
   clearInterval(facebookPollInterval);
   _root.fbGetSession();
}
function getSessionCB(s)
{
   if(s == 1)
   {
      trace("1!");
      trace("interval ID from get session: " + facebookPollInterval);
   }
   else if(s == -15)
   {
      trace("-1!");
      facebookPollCount++;
      if(facebookPollCount > 24)
      {
         trace("poll count over 24!");
         classes.Frame.serverLights(false);
         _root.displayAlert("warning","Discord Error ","There was an error getting approval from discord, please try again ");
         facebookLinkPage = false;
         _root.clearFB();
         gotoAndStop(1);
      }
      else
      {
         facebookPollInterval = setInterval(this,"getSession",5000);
      }
   }
   else
   {
      classes.Frame.serverLights(false);
      trace("-2!");
      trace("interval ID from get session: " + facebookPollInterval);
      gotoAndStop("facebookLink");
      setLoginChrome(true);
      play();
   }
}
var facebookPollInterval;
var facebookPollCount = 0;
setLoginChrome(false);
