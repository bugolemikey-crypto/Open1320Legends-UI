class classes.Chat
{
   static var chatWindow;
   static var clr;
   static var boxW = 300;
   static var boxH = 222;
   static var inBoxH = 43;
   static var inBoxLineWidth = 4;
   static var enteredText = "";
   function Chat()
   {
   }
   static function createWindow(_mc, chatName)
   {
      if(_mc.bg != undefined)
      {
         return undefined;
      }
      classes.Chat.chatWindow = _mc;
      if(!chatName)
      {
         chatName = "";
      }
      classes.Chat.clr = new Color(classes.Chat.chatWindow);
      classes.Chat.chatWindow.docked = true;
      classes.Chat.chatWindow.createEmptyMovieClip("bg",classes.Chat.chatWindow.getNextHighestDepth());
      classes.Drawing.newBaseWindow(classes.Chat.chatWindow.bg,classes.Chat.boxW + 14,classes.Chat.boxH + 24);
      var _loc2_ = classes.Chat.chatWindow.bg.createEmptyMovieClip("box",classes.Chat.chatWindow.getNextHighestDepth());
      _loc2_._x = 8;
      _loc2_._y = 15;
      classes.Drawing.insetBox(_loc2_,classes.Chat.boxW,classes.Chat.boxH,0);
      classes.Drawing.applyInsetBoxFilters(_loc2_);
      _loc2_.cacheAsBitmap = true;
      classes.Chat.drawTextHistory();
      classes.Chat.drawInbox();
      classes.Drawing.standardText(classes.Chat.chatWindow.bg,"headerRoomName",chatName,6,-1,100);
      _global.newRoomName = "";
   }
   static function drawTextHistory()
   {
      var cRad = 5;
      var tfw = classes.Chat.boxW - 20;
      var tfh = classes.Chat.boxH - classes.Chat.inBoxH - classes.Chat.inBoxLineWidth - 20;
      if(classes.Chat.chatWindow.tf == undefined)
      {
         classes.Chat.chatWindow.createTextField("tf",classes.Chat.chatWindow.getNextHighestDepth(),classes.Chat.chatWindow.bg.box._x + 10,classes.Chat.chatWindow.bg.box._y + 10,tfw,tfh + 10);
         with(classes.Chat.chatWindow)
         {
            tf.embedFonts = true;
            tf.antiAliasType = "advanced";
            tf.html = true;
            tf.wordWrap = true;
            tf.multiline = true;
            tf.styleSheet = _global.n2CSS;
            var txt = "";
            tf.htmlText = txt;
         }
         classes.Chat.chatWindow.scroller = new controls.ScrollBar(classes.Chat.chatWindow.tf,tfh + 28,null,classes.Chat.chatWindow.bg.box._y);
      }
   }
   static function drawInbox()
   {
      if(classes.Chat.chatWindow.tfInboxLine == undefined)
      {
         classes.Chat.chatWindow.createEmptyMovieClip("tfInboxLine",classes.Chat.chatWindow.getNextHighestDepth());
         classes.Chat.chatWindow.tfInboxLine._x = classes.Chat.chatWindow.bg.box._x;
         classes.Chat.chatWindow.tfInboxLine._y = classes.Chat.chatWindow.bg.box._y + classes.Chat.chatWindow.bg.box._height - 40;
         classes.Drawing.rect(classes.Chat.chatWindow.tfInboxLine,classes.Chat.boxW,classes.Chat.inBoxLineWidth,11386329);
      }
      if(classes.Chat.chatWindow.tfInbox == undefined)
      {
         classes.Chat.chatWindow.createTextField("tfInbox",classes.Chat.chatWindow.getNextHighestDepth(),classes.Chat.chatWindow.tf._x,classes.Chat.chatWindow.tfInboxLine._y + classes.Chat.inBoxLineWidth,classes.Chat.chatWindow.tf._width - 36,classes.Chat.inBoxH);
         with(classes.Chat.chatWindow)
         {
            tfInbox.type = "input";
            tfInbox.embedFonts = true;
            tfInbox.antiAliasType = "advanced";
            tfInbox.wordWrap = true;
            tfInbox.multiline = true;
            var tfrm = new TextFormat();
            tfrm.font = "AliasCond";
            tfrm.size = 8;
            tfInbox.maxChars = 80;
            tfInbox.restrict = classes.Lookup.keyboardRestrictChars;
            tfInbox.setTextFormat(tfrm);
            tfInbox.setNewTextFormat(tfrm);
            var tRawText = "";
            var kListener = new Object();
            kListener.onKeyUp = function()
            {
               var _loc2_ = tfInbox.text;
               if(Key.getCode() == 13)
               {
                  tfInbox.text = "";
                  if(classes.Chat.enteredText.length > 0)
                  {
                     _root.chatSend(classes.Chat.enteredText);
                     classes.Chat.enteredText = "";
                  }
               }
               else
               {
                  classes.Chat.enteredText = _loc2_;
               }
            };
            tfInbox.onSetFocus = function()
            {
               Key.addListener(kListener);
            };
            tfInbox.onKillFocus = function()
            {
               Key.removeListener(kListener);
            };
         }
         classes.Chat.chatWindow.attachMovie("btnChatSubmit","btnSubmit",classes.Chat.chatWindow.getNextHighestDepth());
         classes.Chat.chatWindow.btnSubmit._x = classes.Chat.boxW - 25;
         classes.Chat.chatWindow.btnSubmit._y = classes.Chat.chatWindow.tfInboxLine._y + 10;
         classes.Chat.chatWindow.btnSubmit.onRelease = function()
         {
            classes.Chat.chatWindow.tfInbox.text = "";
            if(classes.Chat.enteredText.length)
            {
               _root.chatSend(classes.Chat.enteredText);
               classes.Chat.enteredText = "";
            }
         };
      }
   }
   static function addToHistory(classNum, username, msg)
   {
      var _loc4_ = 80;
      var _loc3_ = false;
      if(!classNum)
      {
         classNum = 5;
      }
      if(classes.Chat.chatWindow.tf.scroll == classes.Chat.chatWindow.tf.maxscroll)
      {
         _loc3_ = true;
      }
      var _loc1_ = classes.Chat.chatWindow.tf.htmlText.split("<br/>");
      var _loc9_ = classes.Chat.chatWindow.tf.scroll;
      var _loc7_ = classes.Chat.chatWindow.tf.maxscroll;
      if(_loc1_.length > _loc4_)
      {
         _loc1_.splice(0,_loc1_.length - _loc4_ + 10);
         classes.Chat.chatWindow.tf.htmlText = _loc1_.join("<br/>");
         classes.Chat.chatWindow.tf.scroll = Math.max(0,_loc9_ - (_loc7_ - classes.Chat.chatWindow.tf.maxscroll));
      }
      var _loc5_;
      if(classNum > 10)
      {
         _loc5_ = "<span class=\"e" + classNum + "\"><span class=\"e10b\">" + username + ": </span>" + msg + "</span><br/>";
      }
      else
      {
         _loc5_ = "<span class=\"e" + classNum + "\"><span class=\"eb\">" + username + ": </span>" + msg + "</span><br/>";
      }
      classes.Chat.chatWindow.tf.htmlText += _loc5_;
      if(_loc3_)
      {
         classes.Chat.chatWindow.tf.scroll = classes.Chat.chatWindow.tf.maxscroll;
      }
      classes.Chat.chatWindow.scroller.refreshScroller();
      classes.Race.checkChatMessage(username,msg);
   }
   static function disableWindow()
   {
      classes.Chat.clr.setTransform({rb:-90,gb:-90,bb:-90});
      classes.Chat.chatWindow.tfInbox._visible = false;
   }
   static function enableWindow()
   {
      classes.Chat.clr.setTransform({rb:0,gb:0,bb:0});
      classes.Chat.chatWindow.tfInbox._visible = true;
   }
   static function destroyWindow()
   {
      classes.Chat.chatWindow.removeMovieClip();
   }
}
