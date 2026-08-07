   var _alpha;
   var _visible;
   var bid;
   var clearFlash;
   var dragging;
   var hi;
   var hitTest;
   var hot;
   var id;
   var idx;
   var srcMC;
   var startDrag;
   var stopDrag;
   var text;
   var textColor;
   static var _BASE;
   static var _NIM;
   static var buddyListContext;
   static var buddyRequestContext;
   static var refreshConverseFn;
   static var reorderBuddies;
   static var listVisW = 0;
   static var listVisH = 0;
   static var onlineText = "online";
   static var offlineText = "offline";
   static var leftM = 20;
   static var topM = 64;
   static var btmM = 21;
   static var defaultWidth = 370;
   static var defaultHeight = 500;
   static var buddyHeaderH = 78;
   static var buddyFilter = "";
   static var panelNum = 2;
   static var nimBuddyID = 0;
   static var nimBuddyName = "";
   static var profileCardBox;
   static var profileCardPanel;
   static var profileCardUID;
   static var profileCardCars;
   static var profileCardCarIndex;
   static var buddyDragID = 0;
   static var enteredText = "";
   function Console(target)
   {
      function refreshConverse(_subject)
      {
         var _loc2_ = 199;
         if(_subject.tb1 == undefined)
         {
            _subject.createEmptyMovieClip("tb1",_subject.getNextHighestDepth());
         }
         _subject.tb1._x = 27;
         _subject.tb1._y = fBoxY;
         classes.Drawing.insetBox(_subject.tb1,_loc2_,fBoxH,20,1119253,2106921,461066,16726051);
         with(_subject)
         {
            var _loc3_ = classes.Lookup.getBuddyNode(_subject.id);
            with(tb1)
            {
               var _loc4_ = new Object();
               _loc4_.loc = "";
               _loc4_.s = !_loc3_ ? 0 : _loc3_.attributes.s;
               _loc4_.ul = !_loc3_ ? "" : _loc3_.attributes.ul;
               moveTo(0,20);
               beginFill(1119253);
               lineTo(_loc2_,20);
               lineTo(_loc2_,51);
               lineTo(0,51);
               lineTo(0,20);
               endFill();
            }
            if(tb1.photo == undefined)
            {
               classes.Drawing.portrait(tb1,Number(_subject.id),1,0,45,1);
            }
            tb1.photo._x = _loc2_ - 102;
            with(tb1)
            {
               if(!tb1.icon_buddy1)
               {
                  tb1.attachMovie("icon_buddy1","icon_buddy1",tb1.getNextHighestDepth());
                  icon_buddy1._x = 7;
                  icon_buddy1._y = 26;
               }
               var _loc5_;
               if(tb1.txt_buddyloc == undefined)
               {
                  tb1.createTextField("txt_buddyloc",tb1.getNextHighestDepth(),22,60,_loc2_ - 22 - 106,40);
                  txt_buddyloc.embedFonts = true;
                  txt_buddyloc.selectable = false;
                  txt_buddyloc.multiline = true;
                  txt_buddyloc.wordWrap = true;
                  txt_buddyloc.autoSize = true;
                  _loc5_ = new TextFormat();
                  _loc5_.font = "AliasCond";
                  _loc5_.size = 8;
                  _loc5_.leading = -1;
                  _loc5_.color = 16777215;
                  txt_buddyloc.setNewTextFormat(_loc5_);
               }
               tb1.photo.pic._alpha = 100;
               if(_loc4_.loc.length)
               {
                  txt_buddyloc.text = "I\'m in " + classes.Lookup.locationName(_loc4_.loc) + " race track";
               }
               else if(Number(_loc4_.s))
               {
                  classes.Console.showOnlineStatus(txt_buddyloc,_loc4_.ul);
               }
               else
               {
                  txt_buddyloc.text = classes.Console.offlineText;
                  tb1.photo.pic._alpha = 50;
               }
               txt_buddyloc._width = _loc2_ - 22 - 106;
               if(tb1.avFrame == undefined)
               {
                  tb1.createEmptyMovieClip("avFrame",tb1.getNextHighestDepth());
               }
               var _loc6_ = !Number(_loc4_.s) ? 12596266 : 2938573;
               var _loc7_ = tb1.photo._x;
               var _loc8_ = tb1.photo._y;
               var _loc9_ = tb1.photo._width;
               var _loc10_ = tb1.photo._height;
               with(tb1.avFrame)
               {
                  clear();
                  lineStyle(1,_loc6_,85);
                  moveTo(_loc7_ - 3,_loc8_ - 3);
                  lineTo(_loc7_ + _loc9_ + 2,_loc8_ - 3);
                  lineTo(_loc7_ + _loc9_ + 2,_loc8_ + _loc10_ + 2);
                  lineTo(_loc7_ - 3,_loc8_ + _loc10_ + 2);
                  lineTo(_loc7_ - 3,_loc8_ - 3);
                  beginFill(_loc6_,100);
                  moveTo(_loc7_ - 7,_loc8_ - 3);
                  lineTo(_loc7_ - 4,_loc8_ - 3);
                  lineTo(_loc7_ - 4,_loc8_ + _loc10_ + 2);
                  lineTo(_loc7_ - 7,_loc8_ + _loc10_ + 2);
                  endFill();
               }
               if(Number(_loc4_.s))
               {
                  if(!tb1.icon_jumpto)
                  {
                     tb1.attachMovie("icon_arrow_jumpto","icon_jumpto",tb1.getNextHighestDepth());
                     icon_jumpto._x = 9;
                     icon_jumpto._y = 61;
                  }
               }
               if(tb1.txt_buddyname == undefined)
               {
                  tb1.createTextField("txt_buddyname",tb1.getNextHighestDepth(),27,27,_loc2_ - 27,20);
                  txt_buddyname.embedFonts = true;
                  txt_buddyname.selectable = false;
                  _loc5_ = new TextFormat();
                  _loc5_.font = "Arial";
                  _loc5_.color = 15790320;
                  _loc5_.size = 13;
                  _loc5_.bold = true;
                  txt_buddyname.setNewTextFormat(_loc5_);
                  txt_buddyname._width = _loc2_ - 27;
                  txt_buddyname.text = classes.Lookup.buddyName(_subject.id);
               }
            }
            var _loc11_ = 5;
            var _loc12_ = boxW - 16;
            var _loc13_ = boxH - inBoxH - inBoxLineWidth;
            var _loc14_;
            var _loc15_;
            if(_subject.tf == undefined)
            {
               _subject.createTextField("tf",_subject.getNextHighestDepth(),tb1._x,tb1._y + fBoxH + midGap,_loc12_,_loc13_);
               tf.embedFonts = true;
               tf.antiAliasType = "advanced";
               tf.html = true;
               tf.wordWrap = true;
               tf.multiline = true;
               _loc14_ = new TextFormat();
               _loc14_.font = "AliasCond";
               _loc14_.size = 8;
               _loc14_.leading = 2;
               _loc15_ = "";
               tf.setNewTextFormat(_loc14_);
               tf.styleSheet = _global.n2CSS;
               tf._y = 273;
               tf._width = _loc12_;
               tf.htmlText = _loc15_;
               if(_subject.scroller == undefined)
               {
                  _subject.scroller = new controls.ScrollBar(_subject.tf,_loc13_,leftM + boxW - 10,tf._y);
                  neonScroller(_subject.tfScrollBar);
               }
            }
            tf._height = _loc13_;
            tfInbox._width = tf._width;
            if(_subject.tb2 == undefined)
            {
               _subject.createEmptyMovieClip("tb2",_subject.getNextHighestDepth());
            }
            if(tb2.getDepth() > tf.getDepth())
            {
               tb2.swapDepths(tf);
            }
            tb2._x = leftM;
            tb2._y = tf._y;
            classes.Drawing.insetBox(tb2,boxW,boxH,8,1119253,2106921,461066,16726051);
            _subject.scroller.resetScroller(_loc13_);
            if(_subject.tfInbox == undefined)
            {
               _subject.createTextField("tfInbox",_subject.getNextHighestDepth(),tf._x,tf._y + tf._height + inBoxLineWidth,boxW,inBoxH);
               tfInbox.type = "input";
               tfInbox.maxChars = 200;
               tfInbox.embedFonts = true;
               tfInbox.antiAliasType = "advanced";
               tfInbox.wordWrap = true;
               tfInbox.multiline = true;
               _loc14_ = new TextFormat();
               _loc14_.font = "AliasCond";
               _loc14_.size = 8;
               _loc14_.color = 16777215;
               tfInbox.text = "";
               tfInbox.setTextFormat(_loc14_);
               tfInbox.setNewTextFormat(_loc14_);
               tfInbox.textColor = 16777215;
               var kListener = new Object();
               kListener.onKeyUp = function()
               {
                  var _loc3_ = tfInbox.text;
                  var _loc4_;
                  var _loc5_;
                  var _loc6_;
                  if(Key.getCode() == 13)
                  {
                     tfInbox.text = "";
                     _loc4_ = new Date();
                     _loc5_ = _loc4_.getHours() + ":" + classes.NumFuncs.get2Mins(_loc4_.getMinutes());
                     if(classes.Console.enteredText.length > 0)
                     {
                        _loc6_ = classes.data.Validate.cleanMessage(classes.Console.enteredText);
                        _loc6_ = classes.data.Profanity.filterString(_loc6_);
                        _loc6_ = classes.SpecialText.convertFromSmilies(_loc6_);
                        classes.Console.updateConverse(_subject.id,"<span class=\"e" + classes.GlobalData.role + "\"><span class=\"nim_self\">[" + _loc5_ + "] " + _global.username + ": " + classes.StringFuncs.escapeHTML(classes.data.Profanity.filterString(_loc6_)) + "</span></span>");
                        _root.sendNim(_subject.id,_loc6_);
                     }
                     classes.Console.enteredText = "";
                  }
                  else
                  {
                     classes.Console.enteredText = _loc3_;
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
            tfInbox._y = tf._y + tf._height + inBoxLineWidth;
            var _loc16_;
            var _loc17_;
            if(classes.Console.panelNum == 1)
            {
               if(_subject.inbxLine == undefined)
               {
                  _subject.createEmptyMovieClip("inbxLine",_subject.getNextHighestDepth());
               }
               _loc16_ = new flash.filters.GlowFilter(0,1,20,20,1,2,true);
               _loc17_ = [];
               _loc17_[0] = _loc16_;
               tb1.filters = _loc17_;
               classes.Drawing.applyInsetBoxFilters(tb2);
            }
            var _loc18_ = _subject.inbxLine;
            _loc18_.clear();
            _loc18_._x = leftM;
            _loc18_._y = _subject.tfInbox._y - inBoxLineWidth;
            _loc18_.lineStyle(undefined,0,100);
            _loc18_.beginFill(16726051);
            _loc18_.lineTo(boxW,0);
            _loc18_.lineTo(boxW,inBoxLineWidth);
            _loc18_.lineTo(0,inBoxLineWidth);
            _loc18_.endFill();
            if(_loc3_.attributes.b == 1)
            {
               classes.Console._NIM.univGroup.tog_block._visible = false;
               drawActBtns();
               if(!_subject.blockedUserLarge)
               {
                  _subject.attachMovie("blockedUserLarge","blockedUserLarge",_subject.getNextHighestDepth(),{_x:tf._x + 52,_y:tf._y + 37});
                  tfInbox.text = "";
                  tfInbox.selectable = false;
                  _subject.attachMovie("btnClipUnblockUser","btnClipUnblockUser",_subject.getNextHighestDepth());
                  _subject.btnClipUnblockUser.btn.onRelease = function()
                  {
                     _root.unblockNimUser(classes.Console.nimBuddyID);
                  };
               }
               _subject.btnClipUnblockUser._x = _loc18_._x;
               _subject.btnClipUnblockUser._y = _loc18_._y + _loc18_._height;
            }
            else
            {
               classes.Console._NIM.univGroup.tog_block._visible = true;
               drawActBtns();
               _subject.blockedUserLarge.removeMovieClip();
               _subject.btnClipUnblockUser.removeMovieClip();
               _subject.tfInbox.selectable = true;
            }
            if(classes.Lookup.buddyNum(_loc3_.attributes.id) > -1)
            {
               disableAddBuddyBtn();
            }
            else
            {
               enableAddBuddyBtn();
            }
         }
      }
      function enableAddBuddyBtn()
      {
         classes.Console._NIM.univGroup.tog_addbuddy.onRelease = function()
         {
            _root.inquiryNimUser(classes.Console.nimBuddyName,classes.Console.nimBuddyID);
         };
         classes.Console._NIM.univGroup.addOff = false;
         drawActBtns();
      }
      function disableAddBuddyBtn()
      {
         delete classes.Console._NIM.univGroup.tog_addbuddy.onRelease;
         classes.Console._NIM.univGroup.addOff = true;
         drawActBtns();
      }
      function hookActBtn(_b)
      {
         _b._alpha = 0;
         _b.onRollOver = function()
         {
            this.hot = true;
            drawActBtns();
         };
         _b.onRollOut = function()
         {
            this.hot = false;
            drawActBtns();
         };
         _b.onDragOut = _b.onRollOut;
      }
      function drawActBtns()
      {
         var _loc1_ = classes.Console._NIM.univGroup;
         var _loc2_ = _loc1_.actPlates;
         if(_loc2_ == undefined)
         {
            return;
         }
         _loc2_.clear();
         var _loc3_ = [62,50,64,50];
         var _loc4_ = [_loc1_.tog_profile,_loc1_.tog_email,_loc1_.tog_addbuddy,_loc1_.tog_block];
         var _loc5_;
         var _loc6_;
         var _loc7_;
         var _loc8_;
         if(_loc2_.lbl0 == undefined)
         {
            _loc5_ = new TextFormat();
            _loc5_.font = "Arial";
            _loc5_.size = 10;
            _loc5_.bold = true;
            _loc5_.italic = true;
            _loc5_.align = "center";
            _loc5_.letterSpacing = 1;
            _loc6_ = ["PROFILE","EMAIL","+ BUDDY","BLOCK"];
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               _loc8_ = _loc2_.createTextField("lbl" + _loc7_,_loc7_ + 1,0,0,10,18);
               _loc8_ = _loc2_["lbl" + _loc7_];
               _loc8_.selectable = false;
               _loc8_.embedFonts = false;
               _loc8_.setNewTextFormat(_loc5_);
               _loc8_.text = _loc6_[_loc7_];
               _loc7_ += 1;
            }
         }
         var _loc9_ = pnl.bgGrad._width - 16;
         var _loc10_ = 243;
         var _loc11_ = 22;
         var _loc12_ = _loc9_ - (!_loc4_[3]._visible ? 0 : _loc3_[3] + 12) - (_loc3_[0] + _loc3_[1] + _loc3_[2] + 12);
         var _loc13_ = 0;
         var _loc14_;
         var _loc15_;
         var _loc16_;
         var _loc17_;
         var _loc18_;
         var _loc19_;
         while(_loc13_ < 4)
         {
            _loc14_ = _loc4_[_loc13_];
            _loc15_ = _loc3_[_loc13_];
            _loc16_ = _loc13_ != 3 ? _loc12_ : _loc9_ - _loc15_;
            if(_loc13_ != 3)
            {
               _loc12_ += _loc15_ + 6;
            }
            _loc17_ = _loc2_["lbl" + _loc13_];
            if(!_loc14_._visible)
            {
               _loc17_._visible = false;
            }
            else
            {
               _loc17_._visible = true;
               _loc14_._x = _loc16_;
               _loc14_._y = _loc10_;
               _loc14_._width = _loc15_;
               _loc14_._height = _loc11_;
               _loc18_ = _loc13_ != 2 ? false : _loc1_.addOff == true;
               _loc19_ = _loc14_.hot == true && !_loc18_;
               actPlate(_loc2_,_loc16_,_loc10_,_loc15_,_loc11_,_loc19_,_loc13_ == 3,!_loc18_ ? 100 : 40);
               _loc17_._x = _loc16_;
               _loc17_._width = _loc15_;
               _loc17_._y = _loc10_ + 3;
               _loc17_._alpha = !_loc18_ ? 100 : 40;
               _loc17_.textColor = _loc13_ != 3 ? (!_loc19_ ? 13949666 : 16777215) : (!_loc19_ ? 15024698 : 16777215);
            }
            _loc13_ += 1;
         }
         var _loc20_ = _loc1_.tog_buddy_close;
         _loc20_._x = _loc9_ - 20;
         _loc20_._y = 112;
         _loc20_._width = 20;
         _loc20_._height = 20;
         actPlate(_loc2_,_loc20_._x,_loc20_._y,20,20,_loc20_.hot == true,true,100);
         _loc2_.lineStyle(2,_loc20_.hot != true ? 15025711 : 16777215,100);
         _loc2_.moveTo(_loc20_._x + 7,_loc20_._y + 7);
         _loc2_.lineTo(_loc20_._x + 13,_loc20_._y + 13);
         _loc2_.moveTo(_loc20_._x + 13,_loc20_._y + 7);
         _loc2_.lineTo(_loc20_._x + 7,_loc20_._y + 13);
         _loc2_.lineStyle(undefined,0,100);
      }
      function actPlate(_ap, _x0, _y0, _w, _h, _on, _red, _al)
      {
         var _loc9_ = _y0 + _h;
         var _loc10_ = 4;
         var _loc11_ = !_red ? 16726051 : 15025711;
         _ap.lineStyle(1,!_on ? (!_red ? 4342351 : 7873060) : _loc11_,!_on ? 80 : 100);
         _ap.beginGradientFill("linear",[!_on ? 2434861 : 3684409,!_on ? 986899 : 1445907],[_al,_al],[0,255],{matrixType:"box",x:_x0,y:_y0,w:_w,h:_h,r:1.5707963267949});
         actPath(_ap,_x0,_y0,_w,_h,_loc10_);
         _ap.endFill();
         _ap.lineStyle(undefined,0,100);
         if(_on)
         {
            _ap.beginGradientFill("linear",[_loc11_,_loc11_],[0,58],[92,255],{matrixType:"box",x:_x0,y:_y0,w:_w,h:_h,r:1.5707963267949});
            actPath(_ap,_x0,_y0,_w,_h,_loc10_);
            _ap.endFill();
            _ap.beginGradientFill("linear",[_loc11_,_loc11_],[42,0],[0,255],{matrixType:"box",x:_x0,y:_loc9_,w:_w,h:8,r:1.5707963267949});
            actPath(_ap,_x0 - 2,_loc9_,_w + 2,8,_loc10_ - 2);
            _ap.endFill();
         }
         _ap.beginFill(_loc11_,!_on ? 26 : 100);
         _ap.moveTo(_x0 + 1,_loc9_ - 2);
         _ap.lineTo(_x0 + _w - _loc10_ - 1,_loc9_ - 2);
         _ap.lineTo(_x0 + _w - _loc10_ - 1,_loc9_ - 1);
         _ap.lineTo(_x0 + 1,_loc9_ - 1);
         _ap.endFill();
      }
      function neonScroller(_sb)
      {
         if(_sb == undefined)
         {
            return;
         }
         var _loc2_ = new Color(_sb._scrollBodyMC);
         _loc2_.setTransform({ra:22,rb:12,ga:22,gb:13,ba:22,bb:16,aa:100,ab:0});
         _loc2_ = new Color(_sb._upArrowMC);
         _loc2_.setTransform({ra:26,rb:16,ga:26,gb:17,ba:26,bb:21,aa:100,ab:0});
         _loc2_ = new Color(_sb._downArrowMC);
         _loc2_.setTransform({ra:26,rb:16,ga:26,gb:17,ba:26,bb:21,aa:100,ab:0});
         // the thumb carries the accent; the track and arrows stay carbon so
         // the red reads as position rather than decoration
         _loc2_ = new Color(_sb._scrollerMC);
         _loc2_.setTransform({ra:46,rb:150,ga:14,gb:22,ba:12,bb:18,aa:100,ab:0});
      }
      function actPath(_ap, _x0, _y0, _w, _h, _sk)
      {
         _ap.moveTo(_x0 + _sk,_y0);
         _ap.lineTo(_x0 + _w,_y0);
         _ap.lineTo(_x0 + _w - _sk,_y0 + _h);
         _ap.lineTo(_x0,_y0 + _h);
         _ap.lineTo(_x0 + _sk,_y0);
      }
      function drawBuddyList(_context, listW, listH)
      {
         function reorderBuddyList()
         {
            function makeSectionHeader(nm, txt, yy, col)
            {
               _context.listBuddies[nm].removeMovieClip();
               _context.listBuddies.createTextField(nm,_context.listBuddies.getNextHighestDepth(),18,yy,220,18);
               var _loc5_ = _context.listBuddies[nm];
               _loc5_.embedFonts = false;
               _loc5_.selectable = false;
               var _loc6_ = new TextFormat();
               _loc6_.font = "Arial";
               _loc6_.size = 11;
               _loc6_.bold = true;
               _loc6_.letterSpacing = 1;
               _loc6_.color = col;
               _loc5_.setNewTextFormat(_loc6_);
               _loc5_.text = txt;
               var _loc7_ = nm + "Hatch";
               _context.listBuddies[_loc7_].removeMovieClip();
               _context.listBuddies.createEmptyMovieClip(_loc7_,_context.listBuddies.getNextHighestDepth());
               var _loc8_ = _context.listBuddies[_loc7_];
               classes.Console.statusDot(_loc8_,8,yy + 9,3,col);
               var _loc9_ = adjW - 52;
               var _loc10_ = 0;
               while(_loc10_ < 4)
               {
                  _loc8_.beginFill(col,28 + _loc10_ * 20);
                  _loc8_.moveTo(_loc9_ + _loc10_ * 10,yy + 13);
                  _loc8_.lineTo(_loc9_ + _loc10_ * 10 + 5,yy + 13);
                  _loc8_.lineTo(_loc9_ + _loc10_ * 10 + 10,yy + 3);
                  _loc8_.lineTo(_loc9_ + _loc10_ * 10 + 5,yy + 3);
                  _loc8_.endFill();
                  _loc10_ += 1;
               }
            }
            var _loc2_ = new Array();
            var _loc3_ = _global.buddylist_xml.firstChild.childNodes.length;
            var _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_.push({id:_global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.id,s:_global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.s,n:_global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.n,b:_global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.b,ul:_global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.ul});
               _loc4_ += 1;
            }
            _loc2_.sortOn(["s","n"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            _loc3_ = _loc2_.length;
            var _loc5_ = classes.Console.buddyFilter;
            var _loc6_ = 0;
            var _loc7_ = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(_loc5_.length == 0 || _loc2_[_loc4_].n.toLowerCase().indexOf(_loc5_) >= 0)
               {
                  if(_loc2_[_loc4_].s > 0)
                  {
                     _loc6_ += 1;
                  }
                  else
                  {
                     _loc7_ += 1;
                  }
               }
               _loc4_ += 1;
            }
            var _loc8_ = 22;
            var _loc9_ = _context.listBuddies.listItem0._y;
            var _loc10_ = false;
            var _loc11_ = false;
            _loc4_ = 0;
            var _loc12_;
            var _loc13_;
            while(_loc4_ < _loc3_)
            {
               _loc12_ = _context.listBuddies["listItem" + _loc2_[_loc4_].id];
               _loc13_ = _loc5_.length == 0 || _loc2_[_loc4_].n.toLowerCase().indexOf(_loc5_) >= 0;
               if(!_loc13_)
               {
                  _loc12_._visible = false;
                  _loc4_ += 1;
               }
               else
               {
                  _loc12_._visible = true;
                  if(_loc2_[_loc4_].s > 0 && !_loc10_ && _loc6_ > 0)
                  {
                     makeSectionHeader("hdrOnline","ONLINE · " + _loc6_,_loc9_,3396301);
                     _loc9_ += _loc8_;
                     _loc10_ = true;
                  }
                  if(_loc2_[_loc4_].s == 0 && !_loc11_ && _loc7_ > 0)
                  {
                     _loc9_ += 6;
                     makeSectionHeader("hdrOffline","OFFLINE · " + _loc7_,_loc9_,9080204);
                     _loc9_ += _loc8_;
                     _loc11_ = true;
                  }
                  _loc12_._y = _loc9_;
                  classes.Console.setBuddyStatus(_loc12_,_loc2_[_loc4_].s,_loc2_[_loc4_].ul,_loc2_[_loc4_].b);
                  _loc9_ += _loc12_._height;
                  _loc4_ += 1;
               }
            }
            _context._parent.vScrollPolicy = "auto";
         }
         function createBuddyItem(_context, xnode, cWidth, cHeight)
         {
            var _loc5_ = xnode.attributes.id;
            _context.createEmptyMovieClip("listItem" + _loc5_,_context.getNextHighestDepth());
            _context["listItem" + _loc5_].id = _loc5_;
            _context["listItem" + _loc5_].uName = xnode.attributes.n;
            with(_context["listItem" + _loc5_])
            {
               var _loc6_ = cHeight;
               var _loc7_ = cWidth;
               var _loc8_ = 30;
               var _loc9_ = 18;
               _loc9_ = 28;
               var _loc10_ = "";
               // the card sits under everything, so it is created before the
               // hit target; a drawn clip with no handlers does not eat clicks
               _context["listItem" + _loc5_].cardW = _loc7_;
               _context["listItem" + _loc5_].createEmptyMovieClip("cardPlate",_context["listItem" + _loc5_].getNextHighestDepth());
               classes.Console.drawBuddyCard(_context["listItem" + _loc5_].cardPlate,_loc7_,xnode.attributes.s > 0);
               _context["listItem" + _loc5_].createEmptyMovieClip("hilite",_context["listItem" + _loc5_].getNextHighestDepth());
               var _loc11_ = 12;
               classes.Drawing.rect(hilite,_loc7_ - _loc11_,_loc6_,16777215,0,- _loc7_);
               hilite.onRelease = function()
               {
                  if(classes.Console._BASE.buddyDrag.srcMC != this._parent || !classes.Console._BASE.buddyDrag.dragging)
                  {
                     classes.Console.buddyItemClick(this);
                  }
                  classes.Console._BASE.buddyDrag.removeMovieClip();
               };
               hilite.onPress = function()
               {
                  classes.Console.startBuddyDrag(this._parent);
               };
               hilite.onReleaseOutside = function()
               {
                  if(classes.Console._BASE.buddyDrag.hitTest(classes.Console._BASE.panel.tbB.blist_trashcan))
                  {
                     _root.deleteNimUser(classes.Console.buddyDragID);
                  }
                  classes.Console.stopBuddyDrag();
               };
               if(_context["listItem" + _loc5_].pic == undefined)
               {
                  _context["listItem" + _loc5_].createEmptyMovieClip("pic",_context["listItem" + _loc5_].getNextHighestDepth());
               }
               pic._xscale = 58;
               pic._yscale = 58;
               if(xnode.attributes.s > 0)
               {
                  _loc10_ = xnode.attributes.p;
               }
               classes.Drawing.portrait(_context["listItem" + _loc5_].pic,Number(xnode.attributes.id),2,0,0,2);
               pic._x = - _loc7_ + 12;
               pic._y = 8;
               _context["listItem" + _loc5_].createEmptyMovieClip("accentBar",_context["listItem" + _loc5_].getNextHighestDepth());
               var _loc12_ = xnode.attributes.s > 0 ? 2938573 : 12596266;
               with(_context["listItem" + _loc5_].accentBar)
               {
                  beginFill(_loc12_,100);
                  classes.Console.roundRect(_context["listItem" + _loc5_].accentBar,- _loc7_ + 7,9,4,44,2);
                  endFill();
                  lineStyle(1,_loc12_,70);
                  classes.Console.roundRect(_context["listItem" + _loc5_].accentBar,- _loc7_ + 15,7,55,48,4);
                  lineStyle(undefined,0,100);
               }
               _x = cWidth;
               if(_context["listItem" + _loc5_].infoClip == undefined)
               {
                  _context["listItem" + _loc5_].createEmptyMovieClip("infoClip",_context["listItem" + _loc5_].getNextHighestDepth());
               }
               with(infoClip)
               {
                  _y = 8;
                  _x = - _loc7_ + 80;
                  // The legacy skin drew its own slab and edge gradients here.
                  // The card underneath is the surface now, so the name and
                  // status sit directly on it and nothing paints over it.
                  // Stop the text short of the menu button. The row is 46px of
                  // button plus its gutter, so a field run to _loc13_ clipped
                  // longer names mid-glyph underneath it.
                  var _loc13_ = _loc7_ - 102;
                  var _loc20_ = _loc13_ - 40;
                  infoClip.createTextField("name_txt",1,0,5,_loc20_,22);
                  name_txt.embedFonts = false;
                  name_txt.selectable = false;
                  name_txt.antiAliasType = "advanced";
                  name_txt.gridFitType = "pixel";
                  var _loc19_ = new TextFormat();
                  _loc19_.font = "Arial";
                  _loc19_.size = 13;
                  _loc19_.bold = true;
                  _loc19_.italic = true;
                  _loc19_.align = "left";
                  _loc19_.color = 15790320;
                  name_txt.setNewTextFormat(_loc19_);
                  name_txt.text = xnode.attributes.n;
                  infoClip.createTextField("loc_txt",2,14,28,_loc20_ - 14,20);
                  infoClip.createEmptyMovieClip("dotClip",3);
                  classes.Console.statusDot(infoClip.dotClip,5,37,4,
                     xnode.attributes.s > 0 ? 2938573 : 12596266);
                  loc_txt.embedFonts = true;
                  loc_txt.selectable = false;
                  loc_txt.wordWrap = true;
                  loc_txt.multiline = true;
                  _loc19_ = new TextFormat();
                  _loc19_.font = "AliasCond";
                  _loc19_.size = 10;
                  _loc19_.leading = 0;
                  _loc19_.color = 16777215;
                  loc_txt.setNewTextFormat(_loc19_);
                  if(xnode.attributes.l.length)
                  {
                     infoClip.attachMovie("icon_arrow_jumpto","jumpIcon",infoClip.getNextHighestDepth());
                     jumpIcon._x = _loc20_ - 12;
                     jumpIcon._y = 20;
                     loc_txt.text = classes.Lookup.locationName(xnode.attributes.l) + " race track";
                  }
                  else
                  {
                     loc_txt._x = 14;
                     _loc19_.color = 8618883;
                     _loc19_.align = "left";
                     loc_txt.setNewTextFormat(_loc19_);
                     if(xnode.attributes.s == 0)
                     {
                        loc_txt.text = classes.Console.offlineText;
                     }
                     else
                     {
                        showOnlineStatus(loc_txt,xnode.attributes.ul);
                     }
                  }
               }
               _context["listItem" + _loc5_].createEmptyMovieClip("menuBtn",_context["listItem" + _loc5_].getNextHighestDepth());
               with(_context["listItem" + _loc5_].menuBtn)
               {
                  lineStyle(1,5790296,70);
                  beginFill(2369580,100);
                  classes.Console.roundRect(_context["listItem" + _loc5_].menuBtn,-46,13,30,32,5);
                  endFill();
                  lineStyle(2,13750737,100);
                  moveTo(-39,23);
                  lineTo(-23,23);
                  moveTo(-39,29);
                  lineTo(-23,29);
                  moveTo(-39,35);
                  lineTo(-23,35);
               }
               _context["listItem" + _loc5_].menuBtn.onRelease = function()
               {
                  classes.Console.showBuddyMenu(this._parent);
               };
               _context["listItem" + _loc5_].menuBtn.onRollOver = function()
               {
                  this._alpha = 70;
               };
               _context["listItem" + _loc5_].menuBtn.onRollOut = function()
               {
                  this._alpha = 100;
               };
               classes.Console.setBuddyStatus(_context["listItem" + _loc5_],xnode.attributes.s,xnode.attributes.ul);
            }
         }
         var adjW = listW - 10;
         var itemH = 74;
         if(_global.buddylist_xml == undefined)
         {
            _global.buddylist_xml = new XML("<buddies></buddies>");
         }
         with(_context)
         {
            buildList = function()
            {
               if(listBuddies.listItem0 == undefined)
               {
                  listBuddies.createEmptyMovieClip("listItem0",listBuddies.getNextHighestDepth());
                  classes.Drawing.rect(listBuddies.listItem0,100,6,16711680,0,-100);
               }
               var _loc2_ = 0;
               var _loc3_;
               while(_loc2_ < _global.buddylist_xml.firstChild.childNodes.length)
               {
                  _loc3_ = _global.buddylist_xml.firstChild.childNodes[_loc2_];
                  if(listBuddies["listItem" + _loc3_.attributes.id] == undefined)
                  {
                     createBuddyItem(listBuddies,_loc3_,adjW,itemH);
                  }
                  else
                  {
                     classes.Console.setBuddyStatus(listBuddies["listItem" + _loc3_.attributes.id],_loc3_.attributes.s,_loc3_.attributes.ul);
                  }
                  _loc2_ += 1;
               }
               reorderBuddyList();
            };
            classes.Console.buddyListContext = _context;
            classes.Console.reorderBuddies = reorderBuddyList;
            var _loc4_;
            if(_context.listBuddies == undefined)
            {
               _context.createEmptyMovieClip("listBuddies",_context.getNextHighestDepth());
               buildList();
            }
            else
            {
               _loc4_ = 0;
               for(every in _context.listBuddies)
               {
                  if(every.indexOf("listItem") > -1)
                  {
                     _loc4_ += 1;
                  }
               }
               if(_context._parent._parent._parent.forceFlag == 1 || _loc4_ == 1 || _loc4_ < _global.buddylist_xml.firstChild.childNodes.length)
               {
                  buildList();
               }
            }
         }
      }
      classes.Console._BASE = target;
      classes.Console.refreshConverseFn = refreshConverse;
      var leftM = classes.Console.leftM;
      var topM = classes.Console.topM;
      var btmM = classes.Console.btmM;
      var buddyHeaderH = classes.Console.buddyHeaderH;
      var midGap = 48;
      var fBoxY = 92;
      var fBoxH = 118;
      var inBoxH = 62;
      var inBoxLineWidth = 4;
      target.createEmptyMovieClip("panel",target.getNextHighestDepth());
      var pnl = target.panel;
      pnl._x = 50;
      pnl._y = 50;
      pnl.cacheAsBitmap = true;
      var _loc1_ = classes.Console.defaultWidth;
      var _loc2_ = classes.Console.defaultHeight;
      var boxH;
      var boxW;
      var boxBH;
      pnl.createEmptyMovieClip("bgGrad",pnl.getNextHighestDepth());
      classes.Drawing.newConsoleWindow(pnl.bgGrad,_loc1_,_loc2_);
      var _loc3_ = new Color(pnl.bgGrad);
      _loc3_.setRGB(460809);
      pnl.bgGrad.onPress = function()
      {
         pnl.swapDepths(target.getNextHighestDepth());
      };
      pnl.createEmptyMovieClip("dragBar",pnl.getNextHighestDepth());
      classes.Drawing.rect(pnl.dragBar,classes.Console.defaultWidth,72,0,0,0,0,8);
      pnl.dragBar.onPress = function()
      {
         pnl.swapDepths(target.getNextHighestDepth());
         pnl.startDrag(false);
      };
      pnl.dragBar.onRelease = function()
      {
         pnl.stopDrag();
      };
      pnl.dragBar.onReleaseOutside = pnl.dragBar.onRelease;
      pnl.dragBar.useHandCursor = false;
      if(pnl.glare_corner == undefined)
      {
         pnl.attachMovie("glare_corner","glare_corner",pnl.getNextHighestDepth());
      }
      if(pnl.glare_top == undefined)
      {
         pnl.attachMovie("glare_top","glare_top",pnl.getNextHighestDepth());
         pnl.glare_top._alpha = 0;
      }
      if(pnl.glare_mid == undefined)
      {
         pnl.attachMovie("glare_mid","glare_mid",pnl.getNextHighestDepth());
         pnl.glare_mid._alpha = 0;
         pnl.glare_mid._y = pnl.glare_top._y + pnl.glare_top._height;
      }
      if(pnl.glare_btm == undefined)
      {
         pnl.attachMovie("glare_btm","glare_btm",pnl.getNextHighestDepth());
         pnl.glare_btm._alpha = 0;
      }
      pnl.attachMovie("togMinimize","togMinimize",pnl.getNextHighestDepth());
      pnl.togMinimize._x = _loc1_ - 58;
      pnl.togMinimize._y = 6;
      pnl.togMinimize.onRelease = function()
      {
         classes.Control.dockNim();
      };
      pnl.createEmptyMovieClip("togClose",pnl.getNextHighestDepth());
      var _loc4_ = pnl.togClose;
      _loc4_._x = _loc1_ - 31;
      _loc4_._y = 6;
      _loc4_.lineStyle(1,9241873,100);
      _loc4_.beginFill(14690338,100);
      _loc4_.moveTo(2,0);
      _loc4_.lineTo(18,0);
      _loc4_.curveTo(20,0,20,2);
      _loc4_.lineTo(20,18);
      _loc4_.curveTo(20,20,18,20);
      _loc4_.lineTo(2,20);
      _loc4_.curveTo(0,20,0,18);
      _loc4_.lineTo(0,2);
      _loc4_.curveTo(0,0,2,0);
      _loc4_.endFill();
      _loc4_.lineStyle(2,16777215,100);
      _loc4_.moveTo(6,6);
      _loc4_.lineTo(14,14);
      _loc4_.moveTo(14,6);
      _loc4_.lineTo(6,14);
      _loc4_.onRelease = function()
      {
         classes.Control.dockNim();
      };
      _loc4_.onRollOver = function()
      {
         this._alpha = 78;
      };
      _loc4_.onRollOut = function()
      {
         this._alpha = 100;
      };
      pnl.createEmptyMovieClip("lines",pnl.getNextHighestDepth());
      pnl.createEmptyMovieClip("linesMask",pnl.getNextHighestDepth());
      pnl.createEmptyMovieClip("lines2",pnl.getNextHighestDepth());
      pnl.lines._y = 31;
      pnl.linesMask._y = pnl.lines._y - 1;
      pnl.lines.setMask(pnl.linesMask);
      classes.Drawing.topLines(pnl.lines,pnl.linesMask,_loc1_);
      var _loc5_ = new Color(pnl.lines);
      _loc5_.setRGB(16726051);
      pnl.lines2._y = 167;
      classes.Drawing.midLines(pnl.lines2,_loc1_);
      var _loc6_ = new Color(pnl.lines2);
      _loc6_.setRGB(16726051);
      pnl.createEmptyMovieClip("topTabs",pnl.getNextHighestDepth());
      var drawTopTabs = function(actIdx)
      {
         var _loc2_ = pnl.topTabs;
         _loc2_.clear();
         var _loc3_;
         if(_loc2_.lblI == undefined)
         {
            _loc3_ = new TextFormat();
            _loc3_.font = "Arial";
            _loc3_.size = 11;
            _loc3_.bold = true;
            _loc3_.align = "center";
            _loc3_.letterSpacing = 1;
            _loc2_.createTextField("lblI",1,0,0,10,18);
            _loc2_.createTextField("lblL",2,0,0,10,18);
            _loc2_.lblI.selectable = false;
            _loc2_.lblL.selectable = false;
            _loc2_.lblI.embedFonts = false;
            _loc2_.lblL.embedFonts = false;
            _loc2_.lblI.setNewTextFormat(_loc3_);
            _loc2_.lblL.setNewTextFormat(_loc3_);
            _loc2_.lblI.text = "IM";
            _loc2_.lblL.text = "BUDDY LIST";
         }
         var _loc4_ = 0;
         var _loc5_;
         var _loc6_;
         var _loc7_;
         var _loc8_;
         var _loc9_;
         var _loc10_;
         var _loc11_;
         var _loc12_;
         while(_loc4_ < 2)
         {
            _loc5_ = _loc4_ != 0 ? pnl.tog_blist : pnl.tog_pm;
            _loc6_ = _loc4_ + 1 == actIdx;
            _loc7_ = _loc5_._x;
            _loc8_ = _loc7_ + _loc5_._width;
            _loc9_ = _loc5_._y;
            _loc10_ = _loc9_ + _loc5_._height;
            _loc11_ = 6;
            _loc2_.beginFill(!_loc6_ ? 1381652 : 2500141,100);
            _loc2_.moveTo(_loc7_,_loc10_);
            _loc2_.lineTo(_loc7_,_loc9_ + _loc11_);
            _loc2_.lineTo(_loc7_ + _loc11_,_loc9_);
            _loc2_.lineTo(_loc8_ - _loc11_,_loc9_);
            _loc2_.lineTo(_loc8_,_loc9_ + _loc11_);
            _loc2_.lineTo(_loc8_,_loc10_);
            _loc2_.endFill();
            if(_loc6_)
            {
               _loc2_.beginFill(16726051,100);
               _loc2_.moveTo(_loc7_,_loc9_ + _loc11_);
               _loc2_.lineTo(_loc7_ + _loc11_,_loc9_);
               _loc2_.lineTo(_loc8_ - _loc11_,_loc9_);
               _loc2_.lineTo(_loc8_,_loc9_ + _loc11_);
               _loc2_.lineTo(_loc8_,_loc9_ + _loc11_ + 2);
               _loc2_.lineTo(_loc8_ - _loc11_ - 1,_loc9_ + 2);
               _loc2_.lineTo(_loc7_ + _loc11_ + 1,_loc9_ + 2);
               _loc2_.lineTo(_loc7_,_loc9_ + _loc11_ + 2);
               _loc2_.endFill();
               _loc2_.beginFill(15024698,100);
               _loc2_.moveTo(_loc7_,_loc10_ - 2);
               _loc2_.lineTo(_loc8_,_loc10_ - 2);
               _loc2_.lineTo(_loc8_,_loc10_);
               _loc2_.lineTo(_loc7_,_loc10_);
               _loc2_.endFill();
            }
            _loc12_ = _loc4_ != 0 ? _loc2_.lblL : _loc2_.lblI;
            _loc12_._x = _loc7_;
            _loc12_._width = _loc8_ - _loc7_;
            _loc12_._y = _loc9_ + (_loc10_ - _loc9_ - 16) / 2;
            _loc12_.textColor = !_loc6_ ? 9081500 : 15921906;
            _loc4_ += 1;
         }
         var _loc13_;
         var _loc14_;
         if(pnl.imAlert && actIdx != 1)
         {
            _loc13_ = pnl.tog_pm._x + pnl.tog_pm._width - 11;
            _loc14_ = pnl.tog_pm._y + 5;
            _loc2_.beginFill(16726051,100);
            _loc2_.moveTo(_loc13_,_loc14_);
            _loc2_.lineTo(_loc13_ + 6,_loc14_);
            _loc2_.lineTo(_loc13_ + 6,_loc14_ + 6);
            _loc2_.lineTo(_loc13_,_loc14_ + 6);
            _loc2_.endFill();
         }
      };
      pnl.createEmptyMovieClip("wordmark",pnl.getNextHighestDepth());
      var _wm = pnl.wordmark;
      _wm._x = 14;
      _wm._y = 6;
      _wm.beginFill(16726051,100);
      _wm.moveTo(4,3);
      _wm.lineTo(11,3);
      _wm.lineTo(7,19);
      _wm.lineTo(0,19);
      _wm.endFill();
      _wm.beginFill(15024698,100);
      _wm.moveTo(13,3);
      _wm.lineTo(17,3);
      _wm.lineTo(13,19);
      _wm.lineTo(9,19);
      _wm.endFill();
      _wm.createTextField("txt",1,21,1,54,20);
      _wm.txt.selectable = false;
      _wm.txt.embedFonts = false;
      var _wmf = new TextFormat();
      _wmf.font = "Arial";
      _wmf.size = 15;
      _wmf.bold = true;
      _wmf.italic = true;
      _wmf.letterSpacing = 2;
      _wmf.color = 15921906;
      _wm.txt.setNewTextFormat(_wmf);
      _wm.txt.text = "NIM";

      pnl.attachMovie("tog_pm","tog_pm",pnl.getNextHighestDepth());
      pnl.tog_pm._x = 88;
      pnl.tog_pm._y = 5;
      // The legacy symbols' bounds are far larger than the labels they drew,
      // so plates sized from them spilled out over the game header. Size the
      // symbols explicitly instead: the drawn plate and the (invisible) hit
      // area then agree, because drawTopTabs reads these back.
      pnl.tog_pm._width = 74;
      pnl.tog_pm._height = 22;
      pnl.tog_pm._alpha = 0;
      pnl.tog_pm.indicateNewMessage = function()
      {
         pnl.imAlert = true;
         drawTopTabs(classes.Console.panelNum);
      };
      pnl.tog_pm.clearFlash = function()
      {
         pnl.imAlert = false;
         drawTopTabs(classes.Console.panelNum);
      };
      pnl.tog_pm.onRelease = function()
      {
         this.clearFlash();
         pnl.swapDepths(target.getNextHighestDepth());
         if(classes.Console.panelNum != 1)
         {
            classes.Console.changePanel(1);
         }
      };
      pnl.tog_pm.onRollOver = function()
      {
         this.hi._visible = true;
      };
      pnl.tog_pm.onRollOut = function()
      {
         if(classes.Console.panelNum != 1)
         {
            this.hi._visible = false;
         }
      };
      pnl.tog_pm.onDragOver = pnl.tog_pm.onRollOver;
      pnl.tog_pm.onDragOut = pnl.tog_pm.onRollOut;
      pnl.attachMovie("tog_blist","tog_blist",pnl.getNextHighestDepth());
      pnl.tog_blist._x = pnl.tog_pm._x + pnl.tog_pm._width + 6;
      pnl.tog_blist._y = pnl.tog_pm._y;
      pnl.tog_blist._width = 112;
      pnl.tog_blist._height = 22;
      pnl.tog_blist._alpha = 0;
      pnl.tog_blist.onRelease = function()
      {
         pnl.swapDepths(target.getNextHighestDepth());
         if(classes.Console.panelNum != 2)
         {
            classes.Console.changePanel(2);
         }
      };
      pnl.tog_blist.onRollOver = function()
      {
         this.hi._visible = true;
      };
      pnl.tog_blist.onRollOut = function()
      {
         if(classes.Console.panelNum != 2)
         {
            this.hi._visible = false;
         }
      };
      pnl.tog_blist.onDragOver = pnl.tog_blist.onRollOver;
      pnl.tog_blist.onDragOut = pnl.tog_blist.onRollOut;
      pnl.tog_pm.onRollOut();
      pnl.tog_pm.glow._visible = false;
      pnl.tog_blist.onRollOver();
      if(classes.GlobalData.facebookConnected == true)
      {
         pnl.attachMovie("tog_noInvite","tog_noInvite",pnl.getNextHighestDepth());
         pnl.tog_noInvite._x = pnl.tog_blist._x + 77.5;
         pnl.tog_noInvite._y = pnl.tog_blist._y + (pnl.tog_blist._height - pnl.tog_noInvite._height) / 2;
         pnl.tog_noInvite.onRelease = function()
         {
            _root.openFBInviteURL();
         };
         classes.Help.addAltTag(pnl.tog_noInvite,"              ");
      }
      pnl.createEmptyMovieClip("nim",pnl.getNextHighestDepth());
      classes.Console._NIM = pnl.nim;
      pnl.nim.attachMovie("chat_win","chat_win",pnl.nim.getNextHighestDepth(),{_x:11,_y:56});
      pnl.nim.createEmptyMovieClip("conversationGroup",pnl.nim.getNextHighestDepth());
      pnl.nim.createEmptyMovieClip("indicatorGroup",pnl.nim.getNextHighestDepth());
      pnl.nim.indicatorGroup._x = leftM + 54;
      pnl.nim.indicatorGroup._y = 82;
      pnl.nim.createEmptyMovieClip("indicatorMask",pnl.nim.getNextHighestDepth());
      pnl.nim.indicatorMask._x = leftM + 54;
      pnl.nim.indicatorMask._y = 80;
      classes.Drawing.rect(pnl.nim.indicatorMask,290,40);
      pnl.nim.indicatorGroup.setMask(pnl.nim.indicatorMask);
      pnl.nim.attachMovie("indicatorArrows","indicatorArrows",pnl.nim.getNextHighestDepth(),{_x:pnl.nim.indicatorMask._x,_y:pnl.nim.indicatorMask._y,_visible:false});
      pnl.nim.createEmptyMovieClip("univGroup",pnl.nim.getNextHighestDepth());
      with(pnl.nim.univGroup)
      {
         pnl.nim.univGroup.createEmptyMovieClip("actPlates",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("nim_head","nim_head",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.nim_head._x = 32;
         pnl.nim.univGroup.nim_head._y = 84;
         pnl.nim.univGroup.attachMovie("tog_profile","tog_profile",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("tog_email","tog_email",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("tog_addbuddy","tog_addbuddy",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("tog_block","tog_block",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("tog_buddy_close","tog_buddy_close",pnl.nim.univGroup.getNextHighestDepth());
         hookActBtn(tog_profile);
         hookActBtn(tog_email);
         hookActBtn(tog_addbuddy);
         hookActBtn(tog_block);
         hookActBtn(tog_buddy_close);
         drawActBtns();
         enableAddBudddyBtn();
         tog_email.onRelease = function()
         {
            classes.Control.focusEmail(_global.buddylist_xml.firstChild.childNodes[classes.Lookup.buddyNum(classes.Console.nimBuddyID)].attributes.n);
         };
         tog_profile.onRelease = function()
         {
            classes.Control.focusViewer(classes.Console.nimBuddyID);
         };
         tog_challenge.onRelease = function()
         {
         };
         tog_block.onRelease = function()
         {
            classes.Console.blockUser(classes.Console.nimBuddyID);
         };
         tog_buddy_close.onRelease = function()
         {
            classes.Console.removeConverse(classes.Console.nimBuddyID);
         };
      }
      classes.Drawing.addCornerResizer(pnl,"cornerHandle");
      var crn = pnl.corner;
      crn.ix = crn._x;
      crn.iy = crn._y;
      var mouseListener = new Object();
      crn.onPress = function()
      {
         this.startDrag(false,crn.ix * 0.62,crn.iy * 0.62,900,900);
         mouseListener.onMouseMove = function()
         {
            pnl.refreshMe();
         };
         Mouse.addListener(mouseListener);
      };
      crn.onRelease = function()
      {
         this.stopDrag();
         Mouse.removeListener(mouseListener);
         pnl.refreshMe();
      };
      crn.onReleaseOutside = crn.onRelease;
      pnl.refreshMe = function(forceRedraw)
      {
         classes.SelectionController.checkFocus();
         if(forceRedraw)
         {
            pnl.forceFlag = forceRedraw;
         }
         pnl.bgGrad._height = crn._y + crn._height - pnl.bgGrad._y;
         pnl.bgGrad._width = crn._x + crn._width - pnl.bgGrad._x;
         pnl.dragBar._width = pnl.bgGrad._width;
         pnl.togMinimize._x = pnl.bgGrad._width - 58;
         pnl.togClose._x = pnl.bgGrad._width - 31;
         pnl.glare_top._width = pnl.bgGrad._width;
         pnl.glare_mid._width = pnl.bgGrad._width;
         pnl.glare_btm._width = pnl.bgGrad._width;
         pnl.glare_mid._yscale = Math.abs(pnl.bgGrad._height - (pnl.glare_top._height + pnl.glare_btm._height));
         pnl.glare_btm._y = pnl.glare_mid._y + pnl.glare_mid._height;
         boxH = pnl.bgGrad._height - fBoxY - fBoxH - midGap - btmM;
         boxW = pnl.bgGrad._width - 40;
         boxBH = pnl.bgGrad._height - topM - btmM;
         classes.Drawing.topLines(pnl.lines,pnl.linesMask,pnl.bgGrad._width);
         classes.Drawing.midLines(pnl.lines2,pnl.bgGrad._width);
         if(!classes.Console.nimBuddyID)
         {
            classes.Console.nimBuddyID = classes.Console.getFirstIndicatorID();
         }
         if(classes.Console.nimBuddyID > 0)
         {
            if(pnl.nim.conversationGroup["conversation" + classes.Console.nimBuddyID] == undefined)
            {
               classes.Console.newConverse(classes.Console.nimBuddyID);
            }
            else
            {
               classes.Console.focusConverse(classes.Console.nimBuddyID);
            }
         }
         var _loc2_ = 0;
         for(var _loc3_ in pnl.nim.conversationGroup)
         {
            if(_loc3_.indexOf("conversation") > -1)
            {
               _loc2_ += 1;
               if(pnl.nim.conversationGroup[_loc3_].id == classes.Console.nimBuddyID)
               {
                  refreshConverse(pnl.nim.conversationGroup[_loc3_]);
               }
            }
         }
         if(_loc2_ > 0)
         {
            pnl.nim.univGroup._visible = true;
         }
         else
         {
            pnl.nim.univGroup._visible = false;
         }
         classes.Console.setCurrentIndicator();
         if(pnl.tbB == undefined)
         {
            pnl.createEmptyMovieClip("tbB",pnl.getNextHighestDepth());
            pnl.tbB._x = leftM;
            pnl.tbB._y = topM;
            pnl.tbB.createEmptyMovieClip("tabPlate",pnl.tbB.getNextHighestDepth());
         }
         classes.Drawing.insetBoxBuddies(pnl.tbB,boxW,boxBH,buddyHeaderH,1119253,2106921,461066,16726051);
         drawTabs = function(actIdx)
         {
            var _loc2_ = pnl.tbB.tabPlate;
            _loc2_.clear();
            var _loc3_;
            if(_loc2_.lblB == undefined)
            {
               _loc3_ = new TextFormat();
               _loc3_.font = "Arial";
               _loc3_.size = 11;
               _loc3_.bold = true;
               _loc3_.align = "center";
               _loc3_.letterSpacing = 1;
               _loc2_.createTextField("lblB",1,10,15,130,18);
               _loc2_.createTextField("lblR",2,150,15,130,18);
               _loc2_.lblB.selectable = false;
               _loc2_.lblR.selectable = false;
               _loc2_.lblB.embedFonts = false;
               _loc2_.lblR.embedFonts = false;
               _loc2_.lblB.setNewTextFormat(_loc3_);
               _loc2_.lblR.setNewTextFormat(_loc3_);
               _loc2_.lblB.text = "BUDDIES";
               _loc2_.lblR.text = "REQUESTS";
            }
            var _loc4_ = (boxW - 26) / 2;
            var _loc5_ = 0;
            var _loc6_;
            var _loc7_;
            var _loc8_;
            var _loc9_;
            var _loc10_;
            var _loc11_;
            var _loc12_;
            var _loc13_;
            while(_loc5_ < 2)
            {
               _loc6_ = _loc5_ == actIdx;
               _loc7_ = _loc5_ != 0 ? 16 + _loc4_ : 10;
               _loc8_ = _loc7_ + _loc4_;
               _loc9_ = 4;
               _loc10_ = 40;
               _loc11_ = 11;
               _loc12_ = _loc5_ != 0 ? pnl.tbB.tab_nim_requests : pnl.tbB.tab_nim_buddies;
               if(_loc12_ != undefined)
               {
                  _loc12_._x = _loc7_;
                  _loc12_._y = _loc9_;
                  _loc12_._width = _loc4_;
                  _loc12_._height = _loc10_ - _loc9_;
               }
               _loc13_ = _loc5_ != 0 ? _loc2_.lblR : _loc2_.lblB;
               _loc13_._x = _loc7_;
               _loc13_._width = _loc4_;
               _loc2_.beginFill(!_loc6_ ? 1381652 : 2500141,100);
               _loc2_.moveTo(_loc7_,_loc10_);
               _loc2_.lineTo(_loc7_,_loc9_ + _loc11_);
               _loc2_.curveTo(_loc7_,_loc9_,_loc7_ + _loc11_,_loc9_);
               _loc2_.lineTo(_loc8_ - _loc11_,_loc9_);
               _loc2_.curveTo(_loc8_,_loc9_,_loc8_,_loc9_ + _loc11_);
               _loc2_.lineTo(_loc8_,_loc10_);
               _loc2_.endFill();
               if(_loc6_)
               {
                  _loc2_.beginFill(16726051,100);
                  _loc2_.moveTo(_loc7_,_loc9_ + _loc11_);
                  _loc2_.curveTo(_loc7_,_loc9_,_loc7_ + _loc11_,_loc9_);
                  _loc2_.lineTo(_loc8_ - _loc11_,_loc9_);
                  _loc2_.curveTo(_loc8_,_loc9_,_loc8_,_loc9_ + _loc11_);
                  _loc2_.lineTo(_loc8_,_loc9_ + _loc11_ + 3);
                  _loc2_.curveTo(_loc8_ - 1,_loc9_ + 3,_loc8_ - _loc11_ - 1,_loc9_ + 3);
                  _loc2_.lineTo(_loc7_ + _loc11_ + 1,_loc9_ + 3);
                  _loc2_.curveTo(_loc7_ + 1,_loc9_ + 3,_loc7_,_loc9_ + _loc11_ + 3);
                  _loc2_.endFill();
                  _loc2_.beginFill(15024698,100);
                  _loc2_.moveTo(_loc7_,_loc10_ - 2);
                  _loc2_.lineTo(_loc8_,_loc10_ - 2);
                  _loc2_.lineTo(_loc8_,_loc10_);
                  _loc2_.lineTo(_loc7_,_loc10_);
                  _loc2_.endFill();
               }
               _loc5_ += 1;
            }
            _loc2_.lblB.textColor = actIdx != 0 ? 9081500 : 15921906;
            _loc2_.lblR.textColor = actIdx != 1 ? 9081500 : 15921906;
         };
         if(pnl.tbB.tab_nim_buddies == undefined)
         {
            pnl.tbB.attachMovie("tab_nim_buddies","tab_nim_buddies",pnl.tbB.getNextHighestDepth());
            pnl.tbB.tab_nim_buddies._x = 18;
            pnl.tbB.tab_nim_buddies._y = 12;
            pnl.tbB.tab_nim_buddies._alpha = 0;
            pnl.tbB.tab_nim_buddies.onRelease = function()
            {
               pnl.tbB.showRequests = false;
               pnl.refreshMe();
            };
         }
         if(pnl.tbB.tab_nim_requests == undefined)
         {
            pnl.tbB.attachMovie("tab_nim_requests","tab_nim_requests",pnl.tbB.getNextHighestDepth());
            pnl.tbB.tab_nim_requests._x = 158;
            pnl.tbB.tab_nim_requests._y = 12;
            pnl.tbB.tab_nim_requests._alpha = 0;
            pnl.tbB.tab_nim_requests.onRelease = function()
            {
               pnl.tbB.showRequests = true;
               _root.getNimIncomingRequests();
            };
         }
         var _loc4_;
         var _loc5_;
         var _loc6_;
         if(!pnl.tbB.showRequests)
         {
            pnl.tbB.scrollerReq._visible = false;
            pnl.tbB.blist_trashcan._visible = true;
            pnl.tbB.scroller._visible = true;
            drawTabs(0);
            if(pnl.tbB.blist_trashcan == undefined)
            {
               pnl.tbB.attachMovie("blist_trashcan","blist_trashcan",pnl.tbB.getNextHighestDepth());
            }
            pnl.tbB.blist_trashcan._width = 26;
            pnl.tbB.blist_trashcan._height = 26;
            pnl.tbB.blist_trashcan._x = boxW - 42;
            pnl.tbB.blist_trashcan._y = 46;
            if(pnl.tbB.scroller == undefined)
            {
               pnl.tbB.createEmptyMovieClip("scroller",pnl.tbB.getNextHighestDepth());
               pnl.tbB.scroller.createEmptyMovieClip("scrollerContent",pnl.tbB.scroller.getNextHighestDepth());
               pnl.tbB.scroller.scrollerObj = new controls.ScrollPane(pnl.tbB.scroller.scrollerContent,boxW,boxBH - buddyHeaderH);
               pnl.tbB.scroller._y = buddyHeaderH;
               neonScroller(pnl.tbB.scroller.scrollerContentScrollBar);
            }
            _loc4_ = boxW - 66;
            if(pnl.tbB.searchBox != undefined)
            {
               pnl.tbB.searchWrap.clear();
               classes.Drawing.rect(pnl.tbB.searchWrap,_loc4_,22,1315357,100,0,0,8,1,3810602,100);
               pnl.tbB.searchBox._width = _loc4_ - 16;
            }
            if(pnl.tbB.searchBox == undefined)
            {
               pnl.tbB.createEmptyMovieClip("searchWrap",pnl.tbB.getNextHighestDepth());
               pnl.tbB.searchWrap._x = 16;
               pnl.tbB.searchWrap._y = 48;
               classes.Drawing.rect(pnl.tbB.searchWrap,_loc4_,22,1315357,100,0,0,8,1,3810602,100);
               pnl.tbB.createTextField("searchBox",pnl.tbB.getNextHighestDepth(),24,50,_loc4_ - 16,18);
               _loc5_ = pnl.tbB.searchBox;
               _loc5_.type = "input";
               _loc5_.embedFonts = false;
               _loc5_.selectable = true;
               _loc6_ = new TextFormat();
               _loc6_.font = "Arial";
               _loc6_.size = 11;
               _loc5_.setNewTextFormat(_loc6_);
               _loc5_.text = "Search friends...";
               _loc5_.textColor = 7107724;
               _loc5_.onSetFocus = function()
               {
                  if(this.text == "Search friends...")
                  {
                     this.text = "";
                     this.textColor = 14212050;
                  }
               };
               _loc5_.onKillFocus = function()
               {
                  if(this.text.length == 0)
                  {
                     this.text = "Search friends...";
                     this.textColor = 7107724;
                     classes.Console.buddyFilter = "";
                  }
               };
               _loc5_.onChanged = function()
               {
                  classes.Console.buddyFilter = this.text == "Search friends..." ? "" : this.text.toLowerCase();
                  classes.Console.refreshSearch();
               };
            }
            with(pnl.tbB)
            {
               classes.Console.listVisW = boxW;
               classes.Console.listVisH = boxBH - buddyHeaderH;
               scroller.scrollerObj.setSizeMask(boxW,boxBH - buddyHeaderH);
               drawBuddyList(scroller.scrollerContent,boxW,boxBH - buddyHeaderH);
               var _loc7_ = scroller.scrollerObj._mvmask._y + scroller.scrollerObj._mvmask._height - scroller.scrollerContent._height;
               if(scroller.scrollerContent._height > scroller.scrollerObj._mvmask._height && scroller.scrollerContent._y < _loc7_)
               {
                  scroller.scrollerContent._y = _loc7_;
               }
               scroller.scrollerObj.resetScroller(boxBH - buddyHeaderH,boxW - 10);
               // ScrollPane builds _BASE and its parts inside resetScroller, so
               // the tint applied at construction time had nothing to colour
               // yet - that is why this bar stayed legacy grey. Re-apply here.
               neonScroller(scroller.scrollerContentScrollBar);
            }
         }
         else
         {
            pnl.tbB.clear();
            classes.Drawing.insetBoxBuddies(pnl.tbB,boxW,boxBH,buddyHeaderH,1119253,2106921,461066,16726051,73,77);
            pnl.tbB.blist_trashcan._visible = false;
            pnl.tbB.scroller._visible = false;
            pnl.tbB.scrollerReq._visible = true;
            drawTabs(1);
            if(pnl.tbB.scrollerReq == undefined)
            {
               pnl.tbB.createEmptyMovieClip("scrollerReq",pnl.tbB.getNextHighestDepth());
               pnl.tbB.scrollerReq.createEmptyMovieClip("scrollerContent",pnl.tbB.scroller.getNextHighestDepth());
               pnl.tbB.scrollerReq.scrollerObj = new controls.ScrollPane(pnl.tbB.scrollerReq.scrollerContent,boxW,boxBH - buddyHeaderH);
               pnl.tbB.scrollerReq._y = buddyHeaderH;
               classes.Console.buddyRequestContext = pnl.tbB.scrollerReq.scrollerContent;
            }
            with(pnl.tbB)
            {
               scrollerReq.scrollerObj.setSizeMask(boxW,boxBH - buddyHeaderH);
               classes.Console.drawBuddyRequestList(boxW,boxBH - buddyHeaderH);
               scrollerReq.scrollerObj.resetScroller(boxBH - buddyHeaderH,boxW - 10);
            }
         }
         classes.Drawing.applyInsetBoxFilters(pnl.tbB);
         if(classes.Console.panelNum == 1)
         {
            pnl.nim._visible = true;
            pnl.tbB._visible = false;
         }
         else
         {
            pnl.nim._visible = false;
            pnl.tbB._visible = true;
         }
         drawTopTabs(classes.Console.panelNum);
         drawActBtns();
         pnl.cornerHandle._x = crn._x;
         pnl.cornerHandle._y = crn._y;
         classes.SelectionController.restoreFocus();
      };
      pnl.refreshMe();
      target.updateNimUser = function(id, userStatus, chatRoomName)
      {
         if(classes.Console.refreshBuddy(id,userStatus,chatRoomName))
         {
            return;
         }
         var _loc5_ = classes.Lookup.buddyNum(id);
         if(_loc5_ >= 0)
         {
            _global.buddylist_xml.firstChild.childNodes[_loc5_].attributes.s = userStatus;
            _global.buddylist_xml.firstChild.childNodes[_loc5_].attributes.ul = chatRoomName;
            pnl.refreshMe(1);
         }
      };
      classes.Control.dockNim();
      classes.Frame._MC.overlay.tabNim._visible = false;
   }
   static function changePanel(newPanelNum)
   {
      classes.Console.panelNum = newPanelNum;
      var _loc2_ = classes.Console._BASE.panel;
      _loc2_.refreshMe();
   }
   static function goRequestsPanel()
   {
      classes.Console._BASE.panel.refreshMe();
   }
   static function hideFacebookInviteButton()
   {
      classes.Console._BASE.panel.tog_noInvite._visible = false;
      classes.Console._BASE.panel.tog_noInvite.onRelease = null;
   }
   static function relistScroller()
   {
      var _ctx = classes.Console.buddyListContext;
      _ctx._parent.scrollerObj.resetScroller(classes.Console.listVisH,classes.Console.listVisW - 10);
   }
   static function refreshSearch()
   {
      var _ctx = classes.Console.buddyListContext;
      if(_ctx == undefined || _ctx.listBuddies == undefined)
      {
         classes.Console._BASE.panel.refreshMe();
         return undefined;
      }
      classes.Console.reorderBuddies();
      classes.Console.relistScroller();
   }
   static function refreshBuddy(id, s, ul)
   {
      var _loc5_ = classes.Lookup.buddyNum(id);
      if(_loc5_ < 0)
      {
         return false;
      }
      var _loc6_ = _global.buddylist_xml.firstChild.childNodes[_loc5_];
      _loc6_.attributes.s = s;
      _loc6_.attributes.ul = ul;
      var _loc7_ = classes.Console.buddyListContext;
      if(_loc7_ == undefined || _loc7_.listBuddies == undefined)
      {
         return false;
      }
      var _loc8_ = _loc7_.listBuddies["listItem" + id];
      if(_loc8_ == undefined)
      {
         return false;
      }
      classes.Console.setBuddyStatus(_loc8_,s,ul,_loc6_.attributes.b);
      classes.Console.reorderBuddies();
      classes.Console.relistScroller();
      return true;
   }
   static function startBuddyDrag(buddyMC)
   {
      classes.Console.buddyDragID = buddyMC.id;
      if(classes.Console._BASE.buddyDrag == undefined)
      {
         classes.Console._BASE.createEmptyMovieClip("buddyDrag",classes.Console._BASE.getNextHighestDepth());
         classes.Console._BASE.buddyDrag.createEmptyMovieClip("grab",classes.Console._BASE.getNextHighestDepth());
         classes.Console._BASE.buddyDrag.grab._x -= 12;
         classes.Console._BASE.buddyDrag.grab._y -= 10;
      }
      classes.Console._BASE.buddyDrag._visible = false;
      classes.Console._BASE.buddyDrag.dragging = false;
      classes.Console._BASE.buddyDrag.srcMC = buddyMC;
      classes.Console._BASE.buddyDrag._x = _root._xmouse;
      classes.Console._BASE.buddyDrag._y = _root._ymouse;
      bmp.dispose();
      var _loc3_ = new flash.display.BitmapData(25,21,false,16777215);
      classes.Console._BASE.buddyDrag._alpha = 50;
      classes.Console._BASE.buddyDrag.grab.attachBitmap(_loc3_,1);
      var _loc4_ = new flash.geom.Matrix();
      _loc4_.scale(0.25,0.25);
      _loc3_.draw(buddyMC.pic,_loc4_);
      classes.Console._BASE.buddyDrag.startDrag(true);
      classes.Console._BASE.buddyDrag.onEnterFrame = function()
      {
         if(!this.hitTest(classes.Console._BASE.panel))
         {
            classes.Console._BASE.panel.tbB.blist_trashcan.gotoAndStop(1);
            classes.Console.stopBuddyDrag();
         }
         else if(this.hitTest(this.srcMC))
         {
            this._visible = false;
         }
         else if(this.hitTest(classes.Console._BASE.panel.tbB.blist_trashcan))
         {
            this._visible = true;
            classes.Console._BASE.panel.tbB.blist_trashcan.gotoAndStop(2);
         }
         else
         {
            this._visible = true;
            this.dragging = true;
            classes.Console._BASE.panel.tbB.blist_trashcan.gotoAndStop(1);
         }
      };
   }
   static function stopBuddyDrag()
   {
      classes.Console.buddyDragID = 0;
      classes.Console._BASE.buddyDrag.removeMovieClip();
      classes.Console._BASE.panel.tbB.blist_trashcan.gotoAndStop(1);
   }
   static function buddyItemClick(itemHot)
   {
      classes.Console.nimBuddyID = itemHot._parent.id;
      classes.Console.nimBuddyName = itemHot._parent.uName;
      classes.Console.changePanel(1);
   }
   static function addToBuddyList(id, userName, userStatus, blocked, userRole, userLocation)
   {
      var _loc8_;
      if(classes.Lookup.buddyNum(id) < 0)
      {
         _loc8_ = _global.buddylist_xml.createElement("I");
         _loc8_.attributes.id = id;
         _loc8_.attributes.n = userName;
         _loc8_.attributes.s = userStatus;
         _loc8_.attributes.b = blocked;
         _loc8_.attributes.ul = userLocation;
         if(userRole == undefined)
         {
            userRole = 3;
         }
         _loc8_.attributes.r = userRole;
         _global.buddylist_xml.firstChild.appendChild(_loc8_);
      }
   }
   static function removeFromBuddyList(id)
   {
      var _loc3_ = classes.Lookup.buddyNum(id);
      if(_loc3_ >= 0)
      {
         _global.buddylist_xml.firstChild.childNodes[_loc3_].removeNode();
         classes.Console._BASE.panel.tbB.scroller.scrollerContent.listBuddies["listItem" + id].removeMovieClip();
         classes.Console.stopBuddyDrag();
         classes.Console._BASE.panel.refreshMe();
      }
   }
   static function blockUser(id)
   {
      var _loc4_ = classes.Lookup.buddyNum(id);
      if(_loc4_ >= 0)
      {
         _global.buddylist_xml.firstChild.childNodes[_loc4_].attributes.b = 1;
         classes.Console._BASE.panel.refreshMe();
      }
      _root.blockNimUser(id);
   }
   static function statusDot(_mc, _cx, _cy, _r, _col)
   {
      _mc.clear();
      _mc.beginFill(_col,100);
      _mc.moveTo(_cx + _r,_cy);
      _mc.curveTo(_cx + _r,_cy + _r,_cx,_cy + _r);
      _mc.curveTo(_cx - _r,_cy + _r,_cx - _r,_cy);
      _mc.curveTo(_cx - _r,_cy - _r,_cx,_cy - _r);
      _mc.curveTo(_cx + _r,_cy - _r,_cx + _r,_cy);
      _mc.endFill();
   }
   static function roundRect(_mc, _x, _y, _w, _h, _r)
   {
      _mc.moveTo(_x + _r,_y);
      _mc.lineTo(_x + _w - _r,_y);
      _mc.curveTo(_x + _w,_y,_x + _w,_y + _r);
      _mc.lineTo(_x + _w,_y + _h - _r);
      _mc.curveTo(_x + _w,_y + _h,_x + _w - _r,_y + _h);
      _mc.lineTo(_x + _r,_y + _h);
      _mc.curveTo(_x,_y + _h,_x,_y + _h - _r);
      _mc.lineTo(_x,_y + _r);
      _mc.curveTo(_x,_y,_x + _r,_y);
   }
   static function drawBuddyCard(_mc, _w, _online)
   {
      if(_mc == undefined || !_w)
      {
         return undefined;
      }
      var _loc4_ = - _w + 4;
      var _loc5_ = -6;
      var _loc6_ = 4;
      var _loc7_ = 62;
      var _loc8_ = _loc5_ - _loc4_;
      var _loc9_ = _loc7_ - _loc6_;
      _mc.clear();
      // Rounded, not chamfered: the two-corner cut read as a hard parallelogram
      // and was most of why the list looked blocky. Border alpha is low so the
      // card separates from the panel without drawing a box around itself.
      _mc.lineStyle(1,!_online ? 3026998 : 4080208,!_online ? 46 : 62);
      _mc.beginGradientFill("linear",[2237479,1447707],[100,100],[0,255],{matrixType:"box",x:_loc4_,y:_loc6_,w:_loc8_,h:_loc9_,r:1.5707963267949});
      classes.Console.roundRect(_mc,_loc4_,_loc6_,_loc8_,_loc9_,7);
      _mc.endFill();
      // a single soft highlight just inside the top edge, so the plate reads
      // as lit from above rather than as a flat swatch
      _mc.lineStyle(1,4277582,!_online ? 16 : 24);
      _mc.moveTo(_loc4_ + 8,_loc6_ + 1);
      _mc.lineTo(_loc5_ - 8,_loc6_ + 1);
      _mc.lineStyle(undefined,0,100);
   }
   static function setBuddyStatus(_subject, s, ul, b)
   {
      var _loc5_ = Number(s) > 0;
      if(s == "0")
      {
         _subject._alpha = 80;
         _subject.infoClip.loc_txt.text = classes.Console.offlineText;
      }
      else
      {
         _subject._alpha = 100;
         classes.Console.showOnlineStatus(_subject.infoClip.loc_txt,ul);
      }
      classes.Console.drawBuddyCard(_subject.cardPlate,_subject.cardW,_loc5_);
      classes.Console.statusDot(_subject.infoClip.dotClip,5,37,4,
         !_loc5_ ? 12596266 : 2938573);
      if(b == 1)
      {
         if(!_subject.bugBlockedUser)
         {
            _subject.attachMovie("bugBlockedUser","bugBlockedUser",_subject.getNextHighestDepth(),{_x:-20,_y:29});
         }
      }
      else if(b == 0)
      {
         _subject.bugBlockedUser.removeMovieClip();
      }
   }
   static function showOnlineStatus(statusText, roomName)
   {
      if(roomName != "-")
      {
         statusText.text = roomName;
      }
      else
      {
         statusText.text = classes.Console.onlineText;
      }
   }
   static function drawBuddyRequestList(listW, listH)
   {
      var _context = classes.Console.buddyRequestContext;
      var adjW = listW - 10;
      var itemH = 46;
      with(_context)
      {
         buildList = function()
         {
            for(var each in listBuddies)
            {
               if(eval("each").substr(0,11) == "listItemOut")
               {
                  var found = false;
                  var i = 0;
                  while(i < _global.outgoingRequestsXML.firstChild.childNodes.length)
                  {
                     if(listBuddies[eval("each")].id == _global.outgoingRequestsXML.firstChild.childNodes[i].attributes.i)
                     {
                        found = true;
                        break;
                     }
                     i++;
                  }
                  if(!found)
                  {
                     listBuddies[eval("each")].removeMovieClip();
                  }
               }
               else if(eval("each").substr(0,8) == "listItem" && eval("each") != "listItem0")
               {
                  var found = false;
                  var i = 0;
                  while(i < _global.incomingRequestsXML.firstChild.childNodes.length)
                  {
                     if(listBuddies[eval("each")].id == _global.incomingRequestsXML.firstChild.childNodes[i].attributes.i)
                     {
                        found = true;
                        break;
                     }
                     i++;
                  }
                  if(!found)
                  {
                     listBuddies[eval("each")].removeMovieClip();
                  }
               }
            }
            listBuddies.inReqNone.removeMovieClip();
            listBuddies.outReqNone.removeMovieClip();
            if(listBuddies.listItem0 == undefined)
            {
               listBuddies.createEmptyMovieClip("listItem0",listBuddies.getNextHighestDepth());
               with(listBuddies.listItem0)
               {
                  beginFill(16711680,0);
                  lineTo(-100,0);
                  lineTo(-100,itemH);
                  lineTo(0,itemH);
                  lineTo(0,0);
                  endFill();
               }
            }
            if(listBuddies.nim_head_incoming_requests == undefined)
            {
               listBuddies.attachMovie("nim_head_incoming_requests","nim_head_incoming_requests",listBuddies.getNextHighestDepth());
            }
            if(_global.incomingRequestsXML.firstChild.childNodes.length)
            {
               var baseY = listBuddies.nim_head_incoming_requests._y + listBuddies.nim_head_incoming_requests._height;
               var tarr = new Array();
               var i = 0;
               while(i < _global.incomingRequestsXML.firstChild.childNodes.length)
               {
                  tarr.push({n:_global.incomingRequestsXML.firstChild.childNodes[i].attributes.n,tnode:_global.incomingRequestsXML.firstChild.childNodes[i]});
                  i++;
               }
               tarr.sortOn("n",Array.CASEINSENSITIVE);
               var i = 0;
               while(i < tarr.length)
               {
                  classes.Console.createIncomingRequestItem(tarr[i].tnode,adjW,itemH,baseY + i * itemH);
                  i++;
               }
            }
            else
            {
               listBuddies.attachMovie("buddyReqNone","inReqNone",listBuddies.getNextHighestDepth(),{_y:listBuddies.nim_head_incoming_requests.getBounds().yMax + 10});
            }
            if(listBuddies.nim_head_outgoing_requests == undefined)
            {
               listBuddies.attachMovie("nim_head_outgoing_requests","nim_head_outgoing_requests",listBuddies.getNextHighestDepth());
            }
            listBuddies.nim_head_outgoing_requests._y = !_global.incomingRequestsXML.firstChild.childNodes.length ? listBuddies.inReqNone._y + 40 : listBuddies.nim_head_incoming_requests.getBounds().yMax + itemH * _global.incomingRequestsXML.firstChild.childNodes.length + 25;
            if(_global.outgoingRequestsXML.firstChild.childNodes.length)
            {
               var baseY = listBuddies.nim_head_outgoing_requests._y + listBuddies.nim_head_outgoing_requests._height;
               var i = 0;
               while(i < _global.outgoingRequestsXML.firstChild.childNodes.length)
               {
                  var tnode = _global.outgoingRequestsXML.firstChild.childNodes[i];
                  classes.Console.createOutgoingRequestItem(tnode,adjW,itemH,baseY + i * itemH);
                  i++;
               }
            }
            else
            {
               listBuddies.attachMovie("buddyReqNone","outReqNone",listBuddies.getNextHighestDepth(),{_y:listBuddies._height + 10});
            }
         };
         if(_context.listBuddies == undefined)
         {
            _context.createEmptyMovieClip("listBuddies",_context.getNextHighestDepth());
         }
         buildList();
      }
   }
   static function createIncomingRequestItem(xnode, cWidth, cHeight, yPos)
   {
      var _loc5_ = classes.Console.buddyRequestContext.listBuddies;
      var _loc6_ = xnode.attributes.i;
      if(_loc5_["listItem" + _loc6_] != undefined)
      {
         _loc5_["listItem" + _loc6_]._y = yPos;
         return undefined;
      }
      _loc5_.createEmptyMovieClip("listItem" + _loc6_,_loc5_.getNextHighestDepth());
      _loc5_["listItem" + _loc6_].id = _loc6_;
      with(_loc5_["listItem" + _loc6_])
      {
         var _loc7_ = cHeight;
         var _loc8_ = cWidth;
         var _loc9_ = 30;
         var _loc10_ = 18;
         _loc10_ = 28;
         var _loc11_ = "";
         _loc5_["listItem" + _loc6_].createEmptyMovieClip("hilite",_loc5_["listItem" + _loc6_].getNextHighestDepth());
         with(hilite)
         {
            beginFill(16777215,0);
            lineTo(- _loc8_,0);
            lineTo(- _loc8_,_loc7_);
            lineTo(0,_loc7_);
            lineTo(0,0);
            endFill();
         }
         if(_loc5_["listItem" + _loc6_].pic == undefined)
         {
            _loc5_["listItem" + _loc6_].createEmptyMovieClip("pic",_loc5_["listItem" + _loc6_].getNextHighestDepth());
         }
         pic._xscale = 50;
         pic._yscale = 50;
         classes.Drawing.portrait(_loc5_["listItem" + _loc6_].pic,Number(xnode.attributes.i),2,0,0,2);
         pic._x = - pic._width - 10;
         pic._y = 2;
         _loc5_["listItem" + _loc6_].pic.onRelease = function()
         {
            classes.Control.focusViewer(this._parent.id);
         };
         _x = cWidth;
         if(_loc5_["listItem" + _loc6_].infoClip == undefined)
         {
            _loc5_["listItem" + _loc6_].createEmptyMovieClip("infoClip",_loc5_["listItem" + _loc6_].getNextHighestDepth());
         }
         with(infoClip)
         {
            _y = 6;
            _x = pic.getBounds(_loc5_["listItem" + _loc6_]).xMin;
            beginFill(2106921);
            lineTo(-90,0);
            curveTo(-97,3,-100,11);
            lineTo(0,11);
            lineTo(0,0);
            endFill();
            var _loc12_ = 150;
            var _loc13_ = "linear";
            var _loc14_ = [1316634,2106921];
            var _loc15_ = [100,0];
            var _loc16_ = [0,255];
            var _loc17_ = new flash.geom.Matrix();
            _loc17_.createGradientBox(- _loc12_,_loc12_,0,0,0);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            moveTo(0,11);
            lineTo(- _loc12_,11);
            lineTo(- _loc12_,12);
            lineTo(0,12);
            lineTo(0,11);
            endFill();
            moveTo(0,34);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            lineTo(- _loc12_,34);
            lineTo(- _loc12_,35);
            lineTo(0,35);
            lineTo(0,34);
            endFill();
            _loc14_ = [8955345,8955345];
            moveTo(0,12);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            lineTo(- _loc12_,12);
            lineTo(- _loc12_,34);
            lineTo(0,34);
            lineTo(0,12);
            endFill();
            infoClip.createTextField("name_txt",1,-93,0,85,20);
            name_txt.embedFonts = true;
            name_txt.selectable = false;
            name_txt.antiAliasType = "advanced";
            name_txt.gridFitType = "pixel";
            var _loc18_ = new TextFormat();
            _loc18_.font = "Arial";
            _loc18_.size = 9;
            tfmt.bold = true;
            _loc18_.align = "right";
            _loc18_.color = 13160666;
            name_txt.setNewTextFormat(_loc18_);
            name_txt.text = xnode.attributes.n;
            infoClip.attachMovie("buddy_request_choices","choices",infoClip.getNextHighestDepth(),{_x:-130,_y:13});
            choices.accept.onRelease = function()
            {
               i = 0;
               while(i < _global.incomingRequestsXML.firstChild.childNodes.length)
               {
                  if(_global.incomingRequestsXML.firstChild.childNodes[i].attributes.i == _parent.id)
                  {
                     _global.incomingRequestsXML.firstChild.childNodes[i].removeNode();
                     break;
                  }
                  i++;
               }
               _root.allowNimUser(_parent.id,1);
            };
            choices.decline.onRelease = function()
            {
               i = 0;
               while(i < _global.incomingRequestsXML.firstChild.childNodes.length)
               {
                  if(_global.incomingRequestsXML.firstChild.childNodes[i].attributes.i == _parent.id)
                  {
                     _global.incomingRequestsXML.firstChild.childNodes[i].removeNode();
                     break;
                  }
                  i++;
               }
               _root.allowNimUser(_parent.id,0);
               classes.Console.redrawBuddyRequestList();
            };
         }
         _y = yPos;
      }
   }
   static function createOutgoingRequestItem(xnode, cWidth, cHeight, yPos)
   {
      var _loc5_ = classes.Console.buddyRequestContext.listBuddies;
      var _loc6_ = xnode.attributes.i;
      if(_loc5_["listItemOut" + _loc6_] != undefined)
      {
         _loc5_["listItemOut" + _loc6_]._y = yPos;
         return undefined;
      }
      _loc5_.createEmptyMovieClip("listItemOut" + _loc6_,_loc5_.getNextHighestDepth());
      _loc5_["listItemOut" + _loc6_].id = _loc6_;
      with(_loc5_["listItemOut" + _loc6_])
      {
         var _loc7_ = cHeight;
         var _loc8_ = cWidth;
         var _loc9_ = 30;
         var _loc10_ = 18;
         _loc10_ = 28;
         var _loc11_ = "";
         _loc5_["listItemOut" + _loc6_].createEmptyMovieClip("hilite",_loc5_["listItemOut" + _loc6_].getNextHighestDepth());
         classes.Drawing.rect(hilite,_loc8_,_loc7_,16777215,0,- _loc8_);
         if(_loc5_["listItemOut" + _loc6_].pic == undefined)
         {
            _loc5_["listItemOut" + _loc6_].createEmptyMovieClip("pic",_loc5_["listItemOut" + _loc6_].getNextHighestDepth());
         }
         pic._xscale = 50;
         pic._yscale = 50;
         classes.Drawing.portrait(_loc5_["listItemOut" + _loc6_].pic,Number(xnode.attributes.i),2,0,0,2);
         pic._x = - pic._width - 10;
         pic._y = 2;
         _x = cWidth;
         if(_loc5_["listItemOut" + _loc6_].infoClip == undefined)
         {
            _loc5_["listItemOut" + _loc6_].createEmptyMovieClip("infoClip",_loc5_["listItemOut" + _loc6_].getNextHighestDepth());
         }
         with(infoClip)
         {
            _y = 6;
            _x = pic.getBounds(_loc5_["listItemOut" + _loc6_]).xMin;
            beginFill(2106921);
            lineTo(-90,0);
            curveTo(-97,3,-100,11);
            lineTo(0,11);
            lineTo(0,0);
            endFill();
            var _loc12_ = 150;
            var _loc13_ = "linear";
            var _loc14_ = [1316634,2106921];
            var _loc15_ = [100,0];
            var _loc16_ = [0,255];
            var _loc17_ = new flash.geom.Matrix();
            _loc17_.createGradientBox(- _loc12_,_loc12_,0,0,0);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            moveTo(0,11);
            lineTo(- _loc12_,11);
            lineTo(- _loc12_,12);
            lineTo(0,12);
            lineTo(0,11);
            endFill();
            moveTo(0,34);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            lineTo(- _loc12_,34);
            lineTo(- _loc12_,35);
            lineTo(0,35);
            lineTo(0,34);
            endFill();
            _loc14_ = [8955345,8955345];
            moveTo(0,12);
            beginGradientFill(_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            lineTo(- _loc12_,12);
            lineTo(- _loc12_,34);
            lineTo(0,34);
            lineTo(0,12);
            endFill();
            infoClip.createTextField("name_txt",1,-93,0,85,20);
            name_txt.embedFonts = true;
            name_txt.selectable = false;
            name_txt.antiAliasType = "advanced";
            name_txt.gridFitType = "pixel";
            var _loc18_ = new TextFormat();
            _loc18_.font = "Arial";
            _loc18_.size = 9;
            tfmt.bold = true;
            _loc18_.align = "right";
            _loc18_.color = 13160666;
            name_txt.setNewTextFormat(_loc18_);
            name_txt.text = xnode.attributes.n;
            infoClip.createTextField("status_txt",2,-122,14,114,24);
            status_txt.embedFonts = true;
            status_txt.selectable = false;
            classes.Console.setOutgoingItemStatusDisplay(_loc6_,Number(xnode.attributes.s));
         }
         _y = yPos;
         _loc5_["listItemOut" + _loc6_].onRelease = function()
         {
            i = 0;
            while(i < _global.outgoingRequestsXML.firstChild.childNodes.length)
            {
               if(_global.outgoingRequestsXML.firstChild.childNodes[i].attributes.i == this.id)
               {
                  if(Number(_global.outgoingRequestsXML.firstChild.childNodes[i].attributes.s) == 2)
                  {
                     _root.deleteNimInquiredUser(this.id);
                  }
                  else
                  {
                     _root.inquiryNimOK(this.id);
                  }
                  _global.outgoingRequestsXML.firstChild.childNodes[i].removeNode();
                  break;
               }
               i++;
            }
            classes.Console.redrawBuddyRequestList();
         };
      }
   }
   static function removeOutgoingItem(id)
   {
      var _loc3_ = 0;
      while(_loc3_ < _global.outgoingRequestsXML.firstChild.childNodes.length)
      {
         if(_global.outgoingRequestsXML.firstChild.childNodes[_loc3_].attributes.i == id)
         {
            _global.outgoingRequestsXML.firstChild.childNodes[_loc3_].removeNode();
            if(classes.Console._BASE.panel.tbB.scrollerReq._visible)
            {
               classes.Console.redrawBuddyRequestList();
            }
            break;
         }
         _loc3_ += 1;
      }
   }
   static function changeOutgoingItemStatus(id, s)
   {
      var _loc4_ = 0;
      while(_loc4_ < _global.outgoingRequestsXML.firstChild.childNodes.length)
      {
         if(_global.outgoingRequestsXML.firstChild.childNodes[_loc4_].attributes.i == id)
         {
            _global.outgoingRequestsXML.firstChild.childNodes[_loc4_].attributes.s = s;
            classes.Console.setOutgoingItemStatusDisplay(id,s);
            break;
         }
         _loc4_ += 1;
      }
   }
   static function setOutgoingItemStatusDisplay(id, s)
   {
      var _loc3_ = classes.Console.buddyRequestContext.listBuddies["listItemOut" + id].infoClip;
      var _loc4_ = new TextFormat();
      _loc4_.font = "Arial";
      _loc4_.size = 12;
      _loc4_.bold = true;
      _loc4_.align = "right";
      switch(s)
      {
         case 0:
            _loc4_.color = 12189696;
            _loc3_.status_txt.text = "DECLINED";
            break;
         case 1:
            _loc4_.color = 16777215;
            _loc3_.status_txt.text = "ACCEPTED";
            break;
         case 2:
            _loc4_.color = 16777215;
            _loc3_.status_txt.text = "PENDING";
            break;
         default:
            _loc4_.color = 16777215;
            _loc3_.status_txt.text = "UNKNOWN STATUS";
      }
      _loc3_.status_txt.setTextFormat(_loc4_);
   }
   static function redrawBuddyRequestList()
   {
      var _loc2_ = classes.Console.defaultWidth - 2 * classes.Console.leftM;
      var _loc1_ = classes.Console._BASE.panel.bgGrad._height - classes.Console.topM - classes.Console.btmM - classes.Console.buddyHeaderH;
      classes.Console.drawBuddyRequestList(_loc2_,_loc1_);
   }
   static function showBuddyMenu(item)
   {
      var _loc2_ = classes.Console._BASE;
      _loc2_.buddyMenu.removeMovieClip();
      _loc2_.createEmptyMovieClip("buddyMenu",_loc2_.getNextHighestDepth());
      var _loc3_ = _loc2_.buddyMenu;
      var _loc4_ = {x:0,y:0};
      item.menuBtn.localToGlobal(_loc4_);
      var _loc5_ = ["Message","Profile","Jump To","Invite","Block","Remove"];
      var _loc6_ = 128;
      var _loc7_ = 22;
      var _loc8_ = _loc5_.length * _loc7_ + 8;
      _loc3_._x = _loc4_.x - _loc6_ + 30;
      _loc3_._y = _loc4_.y;
      if(_loc3_._y + _loc8_ > 520)
      {
         _loc3_._y = _loc4_.y - _loc8_ + 30;
      }
      _loc3_.lineStyle(1,3810602,100);
      _loc3_.beginFill(1315357,97);
      _loc3_.moveTo(0,0);
      _loc3_.lineTo(_loc6_,0);
      _loc3_.lineTo(_loc6_,_loc8_);
      _loc3_.lineTo(0,_loc8_);
      _loc3_.lineTo(0,0);
      _loc3_.endFill();
      _loc3_.beginFill(14690338,100);
      _loc3_.moveTo(0,0);
      _loc3_.lineTo(_loc6_,0);
      _loc3_.lineTo(_loc6_,2);
      _loc3_.lineTo(0,2);
      _loc3_.endFill();
      var _loc9_ = 0;
      var _loc10_;
      var _loc11_;
      while(_loc9_ < _loc5_.length)
      {
         _loc10_ = _loc3_.createEmptyMovieClip("mi" + _loc9_,_loc3_.getNextHighestDepth());
         _loc10_._y = 4 + _loc9_ * _loc7_;
         _loc10_.idx = _loc9_;
         _loc10_.bid = item.id;
         _loc10_.createEmptyMovieClip("hi",_loc10_.getNextHighestDepth());
         _loc10_.hi.beginFill(14690338,26);
         _loc10_.hi.moveTo(0,0);
         _loc10_.hi.lineTo(_loc6_,0);
         _loc10_.hi.lineTo(_loc6_,_loc7_);
         _loc10_.hi.lineTo(0,_loc7_);
         _loc10_.hi.endFill();
         _loc10_.hi._visible = false;
         _loc10_.beginFill(16777215,0);
         _loc10_.moveTo(0,0);
         _loc10_.lineTo(_loc6_,0);
         _loc10_.lineTo(_loc6_,_loc7_);
         _loc10_.lineTo(0,_loc7_);
         _loc10_.endFill();
         _loc10_.createTextField("t",1,12,3,_loc6_ - 16,18);
         _loc10_.t.embedFonts = false;
         _loc10_.t.selectable = false;
         _loc11_ = new TextFormat();
         _loc11_.font = "Arial";
         _loc11_.size = 11;
         _loc11_.bold = true;
         _loc11_.color = _loc9_ >= 4 ? 14705242 : 14212050;
         _loc10_.t.setNewTextFormat(_loc11_);
         _loc10_.t.text = _loc5_[_loc9_];
         _loc10_.onRollOver = function()
         {
            this.hi._visible = true;
         };
         _loc10_.onRollOut = function()
         {
            this.hi._visible = false;
         };
         _loc10_.onReleaseOutside = _loc10_.onRollOut;
         _loc10_.onRelease = function()
         {
            classes.Console.buddyMenuAction(this.idx,this.bid);
            classes.Console._BASE.buddyMenu.removeMovieClip();
         };
         _loc9_ += 1;
      }
   }
   static function buddyMenuAction(idx, id)
   {
      if(idx == 0)
      {
         classes.Control.focusNim(id);
      }
      else if(idx == 1)
      {
         classes.Control.focusViewer(id);
      }
      else if(idx == 4)
      {
         classes.Console.blockUser(id);
      }
      else if(idx == 5)
      {
         _root.deleteNimUser(id);
      }
   }
   static function refreshIndicators()
   {
      classes.Console.updateIndicatorScroll();
      classes.Console.setCurrentIndicator();
   }
   static function updateIndicatorScroll()
   {
      var _loc1_ = 0;
      for(var _loc2_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc2_.indexOf("indicator") > -1)
         {
            _loc1_ += 1;
         }
      }
      var _loc3_;
      if(_loc1_ > 9)
      {
         classes.Console._NIM.indicatorArrows._visible = true;
         _loc3_ = classes.Console._NIM.indicatorMask._x + classes.Console._NIM.indicatorMask._width - classes.Console._NIM.indicatorGroup._width;
         if(classes.Console._NIM.indicatorGroup._x < _loc3_)
         {
            classes.Console._NIM.indicatorGroup._x = _loc3_;
         }
      }
      else
      {
         classes.Console._NIM.indicatorArrows._visible = false;
         classes.Console._NIM.indicatorGroup._x = classes.Console._NIM.indicatorMask._x;
      }
   }
   static function addIndicator(userID)
   {
      var _loc2_ = classes.Console._NIM.indicatorGroup._width;
      classes.Console._NIM.indicatorGroup.attachMovie("indicator","indicator" + userID,classes.Console._NIM.indicatorGroup.getNextHighestDepth(),{id:userID});
      classes.Console._NIM.indicatorGroup["indicator" + userID]._x = _loc2_;
      classes.Console._NIM.indicatorGroup["indicator" + userID].onRelease = function()
      {
         classes.Console.nimBuddyID = this.id;
         classes.Console._BASE.panel.refreshMe();
      };
      classes.Console.updateIndicator(userID,Number(classes.Lookup.getBuddyNode(userID).attributes.s));
      classes.Console.setCurrentIndicator();
      classes.Console.updateIndicatorScroll();
   }
   static function removeIndicator(userID)
   {
      classes.Console._NIM.indicatorGroup["indicator" + userID].removeMovieClip();
      delete classes.Console._NIM.indicatorGroup["indicator" + userID];
      var _loc2_ = new Array();
      var _loc3_;
      for(var _loc4_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc4_.indexOf("indicator") > -1)
         {
            _loc3_ = new Object();
            _loc3_.id = classes.Console._NIM.indicatorGroup[_loc4_].id;
            _loc3_.x = classes.Console._NIM.indicatorGroup[_loc4_]._x;
            _loc2_.push(_loc3_);
         }
      }
      _loc2_.sortOn("x");
      var _loc5_ = _loc2_.length;
      var _loc6_ = 0;
      while(_loc6_ < _loc5_)
      {
         classes.Console._NIM.indicatorGroup["indicator" + _loc2_[_loc6_].id]._x = _loc6_ * classes.Console._NIM.indicatorGroup["indicator" + _loc2_[_loc6_].id]._width;
         _loc6_ += 1;
      }
      classes.Console._NIM.indicatorGroup.clear();
      classes.Drawing.rect(classes.Console._NIM.indicatorGroup,classes.Console._NIM.indicatorGroup._width,classes.Console._NIM.indicatorGroup._height,0,0);
      classes.Console.updateIndicatorScroll();
   }
   static function getFirstIndicatorID()
   {
      var _loc2_ = new Array();
      var _loc1_;
      for(var _loc3_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc3_.indexOf("indicator") > -1)
         {
            _loc1_ = new Object();
            _loc1_.id = classes.Console._NIM.indicatorGroup[_loc3_].id;
            _loc1_.x = classes.Console._NIM.indicatorGroup[_loc3_]._x;
            _loc2_.push(_loc1_);
         }
      }
      _loc2_.sortOn("x",Array.NUMERIC);
      var _loc4_ = _loc2_[0].id;
      if(_loc4_ > 0)
      {
         return _loc2_[0].id;
      }
      return 0;
   }
   static function updateIndicator(userID, statusCode)
   {
      with(classes.Console._NIM.indicatorGroup["indicator" + userID])
      {
         clearStatus();
         switch(statusCode)
         {
            case 1:
               blue._visible = true;
               return undefined;
            case 2:
               red._visible = true;
               return undefined;
            case 3:
               if(classes.Console.panelNum != 1)
               {
                  classes.Console._BASE.panel.tog_pm.indicateNewMessage();
               }
               else if(!_root.panel._visible)
               {
                  classes.Console._BASE.panel.tog_pm.indicateNewMessage();
               }
               if(userID != classes.Console.nimBuddyID)
               {
                  indicateNewMessage();
               }
               else
               {
                  blue._visible = true;
               }
               return undefined;
            default:
               light._visible = true;
               return undefined;
         }
      }
   }
   static function setCurrentIndicator()
   {
      for(var _loc1_ in classes.Console._NIM.indicatorGroup)
      {
         classes.Console._NIM.indicatorGroup[_loc1_].pointer._visible = false;
         if(classes.Console._NIM.indicatorGroup[_loc1_].blue._visible)
         {
            classes.Console.updateIndicator(classes.Console._NIM.indicatorGroup[_loc1_].id);
         }
      }
      classes.Console._NIM.indicatorGroup["indicator" + classes.Console.nimBuddyID].pointer._visible = true;
      if(classes.Console.nimBuddyID)
      {
         classes.Console.updateIndicator(classes.Console.nimBuddyID,1);
      }
   }
   static function refreshConversation(userID)
   {
      var _loc2_ = classes.Console.findConverse(userID);
      if(_loc2_ == undefined)
      {
         return false;
      }
      classes.Console.refreshConverseFn(_loc2_);
      return true;
   }
   static function findConverse(userID)
   {
      return classes.Console._NIM.conversationGroup["conversation" + userID];
   }
   static function focusConverse(userID)
   {
      for(var _loc2_ in classes.Console._NIM.conversationGroup)
      {
         classes.Console._NIM.conversationGroup[_loc2_]._visible = false;
      }
      if(userID > 0)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID]._visible = true;
         classes.Console.nimBuddyName = classes.Console._NIM.conversationGroup["conversation" + userID].uname;
      }
   }
   static function updateConverse(userID, msg, s)
   {
      var _loc4_;
      var _loc5_ = classes.Console._NIM.conversationGroup["conversation" + userID];
      if(classes.Console._NIM.conversationGroup["conversation" + userID].tf.scroll == classes.Console._NIM.conversationGroup["conversation" + userID].tf.maxscroll)
      {
         _loc4_ = true;
      }
      if(classes.Console._NIM.conversationGroup["conversation" + userID].txt == undefined)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].txt = "";
      }
      if(Number(classes.Lookup.buddyNum(userID)) > 0 && Number(classes.Lookup.getBuddyNode(userID).attributes.s) <= 0)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].txt += "<br/><font color=\"#FF0000\">****This user is unavailable****</font>";
      }
      else if(Number(classes.Lookup.buddyNum(userID)) < 0)
      {
         classes.Console.showOnlineStatus(classes.Console._NIM.conversationGroup["conversation" + userID].tb1.txt_buddyloc,classes.Lookup.getBuddyNode(userID).attributes.ul);
      }
      classes.Console._NIM.conversationGroup["conversation" + userID].txt += "<br/>" + classes.SpecialText.convertSmilies(classes.data.Profanity.filterString(msg));
      classes.Console._NIM.conversationGroup["conversation" + userID].tf.htmlText = classes.Console._NIM.conversationGroup["conversation" + userID].txt;
      if(_loc4_)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].tf.scroll = classes.Console._NIM.conversationGroup["conversation" + userID].tf.maxscroll;
      }
      classes.Console._NIM.conversationGroup["conversation" + userID].scroller.refreshScroller();
   }
   static function newConverse(userID)
   {
      classes.Console._NIM.conversationGroup.attachMovie("_blank","conversation" + userID,classes.Console._NIM.conversationGroup.getNextHighestDepth(),{id:userID,uname:classes.Lookup.buddyName(userID)});
      classes.Console.addIndicator(userID);
      classes.Console._BASE.panel.refreshMe();
   }
   static function removeConverse(userID)
   {
      classes.Console._NIM.conversationGroup["conversation" + userID].removeMovieClip();
      delete classes.Console._NIM.conversationGroup["conversation" + userID];
      var _loc2_ = classes.Console._NIM.indicatorGroup["indicator" + userID]._x;
      var _loc3_ = new Array();
      var _loc4_;
      for(var _loc5_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc5_.indexOf("indicator") > -1)
         {
            _loc4_ = new Object();
            _loc4_.id = classes.Console._NIM.indicatorGroup[_loc5_].id;
            _loc4_.x = classes.Console._NIM.indicatorGroup[_loc5_]._x;
            if(_loc4_.id != userID)
            {
               _loc3_.push(_loc4_);
            }
         }
      }
      var _loc6_;
      var _loc7_;
      var _loc8_;
      if(!_loc3_.length)
      {
         classes.Console.nimBuddyID = 0;
      }
      else
      {
         _loc3_.sortOn("x");
         _loc6_ = 0;
         _loc7_ = _loc3_.length;
         _loc8_ = 0;
         while(_loc8_ < _loc7_)
         {
            if(_loc3_[_loc8_].x > _loc2_)
            {
               _loc6_ = _loc3_[_loc8_].id;
               break;
            }
            _loc8_ += 1;
         }
         if(_loc6_)
         {
            classes.Console.nimBuddyID = _loc6_;
         }
         else
         {
            classes.Console.nimBuddyID = _loc3_[_loc7_ - 1].id;
         }
      }
      classes.Console.removeIndicator(userID);
      classes.Console.focusConverse(classes.Console.nimBuddyID);
      classes.Console._BASE.panel.refreshMe();
   }
   static function openProfileCard(uID, uName)
   {
      if(!uID)
      {
         return undefined;
      }
      if(classes.Console.profileCardUID == uID && classes.Console.profileCardBox)
      {
         classes.Console.profileCardBox.swapDepths(_root.getNextHighestDepth());
         if(classes.Console.profileCardPanel)
         {
            classes.Console.profileCardPanel.swapDepths(_root.getNextHighestDepth());
         }
         return undefined;
      }
      classes.Console.closeProfileCard();
      classes.Console.profileCardUID = uID;
      classes.Console.profileCardBox = classes.AlertBox(_root.attachMovie("alertBox","profileCard",_root.getNextHighestDepth()));
      classes.Console.profileCardBox.setValue(uName ? uName : "Loading...","Loading profile...","info");
      classes.Console.profileCardBox.addButton("Close");
      var closeListener = new Object();
      closeListener.onRelease = function()
      {
         classes.Console.closeProfileCard();
      };
      classes.Console.profileCardBox.addListener(closeListener);
      classes.Lookup.addCallback("getUser",classes.Console,classes.Console.CB_profileCardGetUser,String(uID));
      _root.getUser(uID);
   }
   static function CB_profileCardGetUser(d)
   {
      var _loc2_;
      var _loc3_;
      var panel;
      var badgeArr;
      var i;
      if(!classes.Console.profileCardBox)
      {
         return undefined;
      }
      _loc2_ = new XML(d);
      _loc3_ = _loc2_.firstChild.firstChild;
      var uID = _loc3_.attributes.i;
      var uName = _loc3_.attributes.u;
      var uCred = _loc3_.attributes.sc;
      var statsText;
      if(Number(_loc3_.attributes.w) > -1)
      {
         statsText = "Rank: " + _loc3_.attributes.scr + "\nWins: " + _loc3_.attributes.w + "    Losses: " + _loc3_.attributes.l;
      }
      else
      {
         statsText = "Rank: " + _loc3_.attributes.scr + "\nwin/loss stats available with membership";
      }
      classes.Console.profileCardBox.setValue(uName,statsText,"info");
      if(classes.Console.profileCardPanel)
      {
         classes.Console.profileCardPanel.removeMovieClip();
      }
      panel = _root.createEmptyMovieClip("profileCardPanel",_root.getNextHighestDepth());
      var boxX = classes.Console.profileCardBox._x + classes.Console.profileCardBox.contentMC._x;
      var boxY = classes.Console.profileCardBox._y + classes.Console.profileCardBox.contentMC._y;
      panel._x = boxX + (classes.Console.profileCardBox.contentMC._width - 420) / 2;
      panel._y = boxY + classes.Console.profileCardBox.contentMC._height + 10;
      classes.Console.profileCardPanel = panel;
      panel.cacheAsBitmap = true;
      classes.Drawing.insetBox(panel,420,230,26,1119253,592652,1381913,0);
      classes.Drawing.portrait(panel,uID,2,16,40,2);
      panel.createEmptyMovieClip("badges",panel.getNextHighestDepth());
      panel.badges._x = 140;
      panel.badges._y = 44;
      if(_root.badgesHolder)
      {
         badgeArr = new Array();
         i = 0;
         while(i < _loc3_.childNodes.length)
         {
            if(_loc3_.childNodes[i].attributes.v == "1")
            {
               badgeArr.push(_loc3_.childNodes[i].attributes);
            }
            i = i + 1;
         }
         classes.Badges.drawBadges(panel.badges,badgeArr,260,false);
      }
      panel.createEmptyMovieClip("carClip",panel.getNextHighestDepth());
      panel.carClip._x = 330;
      panel.carClip._y = 150;
      classes.Console.profileCardCars = undefined;
      classes.Console.profileCardCarIndex = 0;
      classes.Lookup.addCallback("getOtherUserCars",classes.Console,classes.Console.CB_profileCardGetCars,String(uID));
      _root.getOtherUserCars(uID);
   }
   static function CB_profileCardGetCars(txml)
   {
      if(!classes.Console.profileCardPanel)
      {
         return undefined;
      }
      classes.Console.profileCardCars = txml;
      classes.Console.profileCardCarIndex = 0;
      classes.Console.showProfileCardCar();
   }
   static function showProfileCardCar()
   {
      var panel = classes.Console.profileCardPanel;
      var cars = classes.Console.profileCardCars;
      if(!panel || !cars || !cars.firstChild || !cars.firstChild.childNodes.length)
      {
         return undefined;
      }
      var idx = classes.Console.profileCardCarIndex;
      var carNode = cars.firstChild.childNodes[idx];
      classes.Drawing.carView(panel.carClip,new XML(carNode.toString()),10);
      if(panel.carPrev == undefined && cars.firstChild.childNodes.length > 1)
      {
         panel.createEmptyMovieClip("carPrev",panel.getNextHighestDepth());
         with(panel.carPrev)
         {
            beginFill(16777215,70);
            moveTo(0,0);
            lineTo(10,-8);
            lineTo(10,8);
            lineTo(0,0);
            endFill();
         }
         panel.carPrev._x = 260;
         panel.carPrev._y = 150;
         panel.carPrev.onRelease = function()
         {
            var n = classes.Console.profileCardCars.firstChild.childNodes.length;
            classes.Console.profileCardCarIndex = (classes.Console.profileCardCarIndex + n - 1) % n;
            classes.Console.showProfileCardCar();
         };
         panel.createEmptyMovieClip("carNext",panel.getNextHighestDepth());
         with(panel.carNext)
         {
            beginFill(16777215,70);
            moveTo(0,0);
            lineTo(-10,-8);
            lineTo(-10,8);
            lineTo(0,0);
            endFill();
         }
         panel.carNext._x = 400;
         panel.carNext._y = 150;
         panel.carNext.onRelease = function()
         {
            var n = classes.Console.profileCardCars.firstChild.childNodes.length;
            classes.Console.profileCardCarIndex = (classes.Console.profileCardCarIndex + 1) % n;
            classes.Console.showProfileCardCar();
         };
      }
   }
   static function closeProfileCard()
   {
      if(classes.Console.profileCardBox)
      {
         classes.Console.profileCardBox.closeMe();
      }
      if(classes.Console.profileCardPanel)
      {
         classes.Console.profileCardPanel.removeMovieClip();
      }
      classes.Console.profileCardBox = undefined;
      classes.Console.profileCardPanel = undefined;
      classes.Console.profileCardUID = undefined;
      classes.Console.profileCardCars = undefined;
      classes.Console.profileCardCarIndex = undefined;
   }
