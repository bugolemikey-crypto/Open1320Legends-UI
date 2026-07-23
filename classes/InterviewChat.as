class classes.InterviewChat
{
   static var chatWindow;
   static var clr;
   static var boxW = 300;
   static var boxH = 222;
   static var inBoxH = 43;
   static var inBoxLineWidth = 4;
   static var enteredText = "";
   function InterviewChat()
   {
   }
   static function createWindow(_mc, chatName)
   {
      if(_mc.bg != undefined)
      {
         return undefined;
      }
      classes.InterviewChat.chatWindow = _mc;
      classes.InterviewChat.clr = new Color(classes.InterviewChat.chatWindow);
      classes.InterviewChat.chatWindow.docked = true;
      classes.InterviewChat.drawTextHistory();
   }
   static function drawTextHistory()
   {
      var _loc2_ = 5;
      var _loc3_ = classes.InterviewChat.boxW - 20;
      var _loc1_ = classes.InterviewChat.chatWindow.tf._height;
      trace("chatWindow: " + classes.InterviewChat.chatWindow);
      trace("chatWindow.tf: " + classes.InterviewChat.chatWindow.tf);
      trace("chatWindow.tf.height: " + classes.InterviewChat.chatWindow.tf._height);
      trace("text field height: " + _loc1_);
      classes.InterviewChat.chatWindow.scroller = new controls.ScrollBar(classes.InterviewChat.chatWindow.tf,_loc1_ - 20,0,8);
   }
   static function addToHistory(classNum, username, msg)
   {
      var _loc3_ = 80;
      var _loc2_ = false;
      if(!classNum)
      {
         classNum = 5;
      }
      if(classes.InterviewChat.chatWindow.tf.scroll == classes.InterviewChat.chatWindow.tf.maxscroll)
      {
         _loc2_ = true;
      }
      var _loc1_ = classes.InterviewChat.chatWindow.tf.htmlText.split("<br/>");
      var _loc7_ = classes.InterviewChat.chatWindow.tf.scroll;
      var _loc6_ = classes.InterviewChat.chatWindow.tf.maxscroll;
      if(_loc1_.length > _loc3_)
      {
         _loc1_.splice(0,_loc1_.length - _loc3_ + 10);
         classes.InterviewChat.chatWindow.tf.htmlText = _loc1_.join("<br/>");
         classes.InterviewChat.chatWindow.tf.scroll = Math.max(0,_loc7_ - (_loc6_ - classes.InterviewChat.chatWindow.tf.maxscroll));
      }
      var _loc4_;
      _loc4_ = "<span class=\"e" + classNum + "\"><span class=\"eb\">" + username + ": </span>" + msg + "</span><br/><br/>";
      trace("chatWindow addStr: " + _loc4_);
      classes.InterviewChat.chatWindow.tf.htmlText += _loc4_;
      if(_loc2_)
      {
         classes.InterviewChat.chatWindow.tf.scroll = classes.InterviewChat.chatWindow.tf.maxscroll;
      }
      classes.InterviewChat.chatWindow.scroller.refreshScroller();
   }
   static function disableWindow()
   {
   }
   static function enableWindow()
   {
   }
   static function destroyWindow()
   {
      classes.InterviewChat.chatWindow.removeMovieClip();
   }
}
