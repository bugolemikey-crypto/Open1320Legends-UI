class classes.Console
{
   var _visible;
   var clearFlash;
   var dragging;
   var hi;
   var hitTest;
   var id;
   var srcMC;
   var startDrag;
   var stopDrag;
   static var _BASE;
   static var _NIM;
   static var buddyRequestContext;
   static var si;
   static var onlineText = "online";
   static var offlineText = "offline";
   static var leftM = 20;
   static var topM = 64;
   static var btmM = 21;
   static var defaultWidth = 420;
   static var defaultHeight = 560;
   static var buddyHeaderH = 52;
   static var panelNum = 2;
   static var nimBuddyID = 0;
   static var nimBuddyName = "";
   static var buddyDragID = 0;
   static var enteredText = "";
   function Console(target)
   {
      function refreshConverse(_subject)
      {
         trace("refreshConverse: " + _subject.id);
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
               if(tb1.txt_buddyloc == undefined)
               {
                  tb1.createTextField("txt_buddyloc",tb1.getNextHighestDepth(),22,60,_loc2_ - 22 - 106,40);
                  txt_buddyloc.embedFonts = true;
                  txt_buddyloc.selectable = false;
                  txt_buddyloc.multiline = true;
                  txt_buddyloc.wordWrap = true;
                  txt_buddyloc.autoSize = true;
                  var tfmt = new TextFormat();
                  tfmt.font = "AliasCond";
                  tfmt.size = 8;
                  tfmt.leading = -1;
                  tfmt.color = 16777215;
                  txt_buddyloc.setNewTextFormat(tfmt);
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
                  var tfmt = new TextFormat();
                  tfmt.font = "Arial";
                  tfmt.color = 15790320;
                  tfmt.size = 13;
                  tfmt.bold = true;
                  txt_buddyname.setNewTextFormat(tfmt);
                  txt_buddyname._width = _loc2_ - 27;
                  txt_buddyname.text = classes.Lookup.buddyName(_subject.id);
               }
            }
            var cRad = 5;
            var _loc7_ = boxW - 16;
            var _loc8_ = boxH - inBoxH - inBoxLineWidth;
            if(_subject.tf == undefined)
            {
               _subject.createTextField("tf",_subject.getNextHighestDepth(),tb1._x,tb1._y + fBoxH + midGap,_loc7_,_loc8_);
               tf.embedFonts = true;
               tf.antiAliasType = "advanced";
               tf.html = true;
               tf.wordWrap = true;
               tf.multiline = true;
               var tfrm = new TextFormat();
               tfrm.font = "AliasCond";
               tfrm.size = 8;
               tfrm.leading = 2;
               var txt = "";
               tf.setNewTextFormat(tfrm);
               tf.styleSheet = _global.n2CSS;
               tf._y = 273;
               tf._width = _loc7_;
               tf.htmlText = txt;
               if(_subject.scroller == undefined)
               {
                  _subject.scroller = new controls.ScrollBar(_subject.tf,_loc8_,leftM + boxW - 10,tf._y);
               }
            }
            tf._height = _loc8_;
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
            _subject.scroller.resetScroller(_loc8_);
            if(_subject.tfInbox == undefined)
            {
               _subject.createTextField("tfInbox",_subject.getNextHighestDepth(),tf._x,tf._y + tf._height + inBoxLineWidth,boxW,inBoxH);
               tfInbox.type = "input";
               tfInbox.maxChars = 200;
               tfInbox.embedFonts = true;
               tfInbox.antiAliasType = "advanced";
               tfInbox.wordWrap = true;
               tfInbox.multiline = true;
               var tfrm = new TextFormat();
               tfrm.font = "AliasCond";
               tfrm.size = 8;
               tfInbox.text = "";
               tfInbox.setTextFormat(tfrm);
               tfInbox.setNewTextFormat(tfrm);
               var kListener = new Object();
               kListener.onKeyUp = function()
               {
                  var _loc6_ = tfInbox.text;
                  var _loc4_;
                  var _loc5_;
                  var _loc3_;
                  if(Key.getCode() == 13)
                  {
                     tfInbox.text = "";
                     _loc4_ = new Date();
                     _loc5_ = _loc4_.getHours() + ":" + classes.NumFuncs.get2Mins(_loc4_.getMinutes());
                     if(classes.Console.enteredText.length > 0)
                     {
                        _loc3_ = classes.data.Validate.cleanMessage(classes.Console.enteredText);
                        _loc3_ = classes.data.Profanity.filterString(_loc3_);
                        _loc3_ = classes.SpecialText.convertFromSmilies(_loc3_);
                        classes.Console.updateConverse(_subject.id,"<span class=\"e" + classes.GlobalData.role + "\"><span class=\"nim_self\">[" + _loc5_ + "] " + _global.username + ": " + classes.StringFuncs.escapeHTML(classes.data.Profanity.filterString(_loc3_)) + "</span></span>");
                        _root.sendNim(_subject.id,_loc3_);
                     }
                     classes.Console.enteredText = "";
                  }
                  else
                  {
                     classes.Console.enteredText = _loc6_;
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
            if(classes.Console.panelNum == 1)
            {
               if(_subject.inbxLine == undefined)
               {
                  _subject.createEmptyMovieClip("inbxLine",_subject.getNextHighestDepth());
               }
               var glowFilter = new flash.filters.GlowFilter(0,1,20,20,1,2,true);
               var tbFilters = [];
               tbFilters[0] = glowFilter;
               tb1.filters = tbFilters;
               classes.Drawing.applyInsetBoxFilters(tb2);
            }
            var tbz = _subject.inbxLine;
            tbz.clear();
            tbz._x = leftM;
            tbz._y = _subject.tfInbox._y - inBoxLineWidth;
            tbz.lineStyle(undefined,0,100);
            tbz.beginFill(16726051);
            tbz.lineTo(boxW,0);
            tbz.lineTo(boxW,inBoxLineWidth);
            tbz.lineTo(0,inBoxLineWidth);
            tbz.endFill();
            if(_loc3_.attributes.b == 1)
            {
               classes.Console._NIM.univGroup.tog_block._visible = false;
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
               _subject.btnClipUnblockUser._x = tbz._x;
               _subject.btnClipUnblockUser._y = tbz._y + tbz._height;
            }
            else
            {
               classes.Console._NIM.univGroup.tog_block._visible = true;
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
         classes.Effects.roBounce(classes.Console._NIM.univGroup.tog_addbuddy);
         classes.Console._NIM.univGroup.tog_addbuddy._alpha = 100;
      }
      function disableAddBuddyBtn()
      {
         delete classes.Console._NIM.univGroup.tog_addbuddy.onRelease;
         classes.Effects.clearRO(classes.Console._NIM.univGroup.tog_addbuddy);
         classes.Console._NIM.univGroup.tog_addbuddy._alpha = 50;
      }
      function drawBuddyList(_context, listW, listH)
      {
         function reorderBuddyList()
         {
            var _loc3_ = new Array();
            var _loc5_ = _global.buddylist_xml.firstChild.childNodes.length;
            var _loc2_ = 0;
            while(_loc2_ < _loc5_)
            {
               _loc3_.push({id:_global.buddylist_xml.firstChild.childNodes[_loc2_].attributes.id,s:_global.buddylist_xml.firstChild.childNodes[_loc2_].attributes.s,n:_global.buddylist_xml.firstChild.childNodes[_loc2_].attributes.n,b:_global.buddylist_xml.firstChild.childNodes[_loc2_].attributes.b,ul:_global.buddylist_xml.firstChild.childNodes[_loc2_].attributes.ul});
               _loc2_ = _loc2_ + 1;
            }
            _loc3_.sortOn(["s","n"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            _loc5_ = _loc3_.length;
            var _loc11_ = _context.listBuddies.listItem0._y;
            _loc2_ = 0;
            var _loc4_;
            while(_loc2_ < _loc5_)
            {
               _loc4_ = _loc2_ <= 0 ? 0 : _loc2_ * _context.listBuddies["listItem" + _loc3_[_loc2_ - 1].id]._height;
               _context.listBuddies["listItem" + _loc3_[_loc2_].id]._y = _loc11_ + _loc4_;
               classes.Console.setBuddyStatus(_context.listBuddies["listItem" + _loc3_[_loc2_].id],_loc3_[_loc2_].s,_loc3_[_loc2_].ul,_loc3_[_loc2_].b);
               _loc2_ = _loc2_ + 1;
            }
            _context._parent.vScrollPolicy = "auto";
         }
         function createBuddyItem(_context, xnode, cWidth, cHeight)
         {
            var tid = xnode.attributes.id;
            _context.createEmptyMovieClip("listItem" + tid,_context.getNextHighestDepth());
            _context["listItem" + tid].id = tid;
            _context["listItem" + tid].uName = xnode.attributes.n;
            with(_context["listItem" + tid])
            {
               var boxH = cHeight;
               var boxW = cWidth;
               var timeBoxW = 30;
               var textMargin = 18;
               var textMargin = 28;
               var imgToLoad = "";
               _context["listItem" + tid].createEmptyMovieClip("hilite",_context["listItem" + tid].getNextHighestDepth());
               var rightOffset = 12;
               classes.Drawing.rect(hilite,boxW - rightOffset,boxH,16777215,0,- boxW);
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
               if(_context["listItem" + tid].pic == undefined)
               {
                  _context["listItem" + tid].createEmptyMovieClip("pic",_context["listItem" + tid].getNextHighestDepth());
               }
               pic._xscale = 58;
               pic._yscale = 58;
               if(xnode.attributes.s > 0)
               {
                  imgToLoad = xnode.attributes.p;
               }
               classes.Drawing.portrait(_context["listItem" + tid].pic,Number(xnode.attributes.id),2,0,0,2);
               pic._x = - boxW + 12;
               pic._y = 8;
               _x = cWidth;
               if(_context["listItem" + tid].infoClip == undefined)
               {
                  _context["listItem" + tid].createEmptyMovieClip("infoClip",_context["listItem" + tid].getNextHighestDepth());
               }
               with(infoClip)
               {
                  _y = 8;
                  _x = - boxW + 80;
                  beginFill(855567,100);
                  lineTo(boxW - 76,0);
                  lineTo(boxW - 102,52);
                  lineTo(0,52);
                  lineTo(0,0);
                  endFill();
                  var infoW = boxW - 102;
                  var fillType = "linear";
                  var colors = [3538671,3538671];
                  var alphas = [85,0];
                  var ratios = [0,255];
                  var matrix = new flash.geom.Matrix();
                  matrix.createGradientBox(infoW,52,0,0,0);
                  beginGradientFill(fillType,colors,alphas,ratios,matrix);
                  moveTo(0,0);
                  lineTo(infoW,0);
                  lineTo(infoW,2);
                  lineTo(0,2);
                  lineTo(0,0);
                  endFill();
                  moveTo(0,49);
                  beginGradientFill(fillType,colors,alphas,ratios,matrix);
                  lineTo(infoW,49);
                  lineTo(infoW,51);
                  lineTo(0,51);
                  lineTo(0,49);
                  endFill();
                  var colors = [855567,855567];
                  moveTo(0,16);
                  beginGradientFill(fillType,colors,alphas,ratios,matrix);
                  lineTo(infoW,16);
                  lineTo(infoW,49);
                  lineTo(0,49);
                  lineTo(0,16);
                  endFill();
                  infoClip.createTextField("name_txt",1,0,5,infoW,22);
                  name_txt.embedFonts = true;
                  name_txt.selectable = false;
                  name_txt.antiAliasType = "advanced";
                  name_txt.gridFitType = "pixel";
                  var tfrm = new TextFormat();
                  tfrm.font = "Arial";
                  tfrm.size = 13;
                  tfrm.bold = true;
                  tfrm.align = "left";
                  tfrm.color = 15790320;
                  name_txt.setNewTextFormat(tfrm);
                  name_txt.text = xnode.attributes.n;
                  infoClip.createTextField("loc_txt",2,0,28,infoW,20);
                  loc_txt.embedFonts = true;
                  loc_txt.selectable = false;
                  loc_txt.wordWrap = true;
                  loc_txt.multiline = true;
                  var tfrm = new TextFormat();
                  tfrm.font = "AliasCond";
                  tfrm.size = 10;
                  tfrm.leading = 0;
                  tfrm.color = 16777215;
                  loc_txt.setNewTextFormat(tfrm);
                  if(xnode.attributes.l.length)
                  {
                     infoClip.attachMovie("icon_arrow_jumpto","jumpIcon",infoClip.getNextHighestDepth());
                     jumpIcon._x = infoW - 12;
                     jumpIcon._y = 20;
                     loc_txt.text = classes.Lookup.locationName(xnode.attributes.l) + " race track";
                  }
                  else
                  {
                     loc_txt._x = 0;
                     tfrm.color = 8618883;
                     tfrm.align = "left";
                     loc_txt.setNewTextFormat(tfrm);
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
               classes.Console.setBuddyStatus(_context["listItem" + tid],xnode.attributes.s,xnode.attributes.ul);
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
               var _loc3_ = 0;
               var _loc2_;
               while(_loc3_ < _global.buddylist_xml.firstChild.childNodes.length)
               {
                  _loc2_ = _global.buddylist_xml.firstChild.childNodes[_loc3_];
                  if(listBuddies["listItem" + _loc2_.attributes.id] == undefined)
                  {
                     createBuddyItem(listBuddies,_loc2_,adjW,itemH);
                  }
                  else
                  {
                     classes.Console.setBuddyStatus(listBuddies["listItem" + _loc2_.attributes.id],_loc2_.attributes.s,_loc2_.attributes.ul);
                  }
                  _loc3_ = _loc3_ + 1;
               }
               reorderBuddyList();
            };
            if(_context.listBuddies == undefined)
            {
               _context.createEmptyMovieClip("listBuddies",_context.getNextHighestDepth());
               buildList();
            }
            else
            {
               var itemCount = 0;
               for(every in _context.listBuddies)
               {
                  if(every.indexOf("listItem") > -1)
                  {
                     itemCount++;
                  }
               }
               if(_context._parent._parent._parent.forceFlag == 1 || itemCount == 1 || itemCount < _global.buddylist_xml.firstChild.childNodes.length)
               {
                  buildList();
               }
            }
         }
      }
      classes.Console._BASE = target;
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
      var iww = classes.Console.defaultWidth;
      var ihh = classes.Console.defaultHeight;
      var boxH;
      var boxW;
      var boxBH;
      pnl.createEmptyMovieClip("bgGrad",pnl.getNextHighestDepth());
      classes.Drawing.newConsoleWindow(pnl.bgGrad,iww,ihh);
      var nimWindowColor = new Color(pnl.bgGrad);
      nimWindowColor.setRGB(460809);
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
         pnl.glare_top._alpha = 12;
      }
      if(pnl.glare_mid == undefined)
      {
         pnl.attachMovie("glare_mid","glare_mid",pnl.getNextHighestDepth());
         pnl.glare_mid._alpha = 8;
         pnl.glare_mid._y = pnl.glare_top._y + pnl.glare_top._height;
      }
      if(pnl.glare_btm == undefined)
      {
         pnl.attachMovie("glare_btm","glare_btm",pnl.getNextHighestDepth());
         pnl.glare_btm._alpha = 12;
      }
      pnl.attachMovie("togMinimize","togMinimize",pnl.getNextHighestDepth());
      pnl.togMinimize._x = iww - 31;
      pnl.togMinimize._y = 6;
      pnl.togMinimize.onRelease = function()
      {
         classes.Control.dockNim();
      };
      pnl.createEmptyMovieClip("lines",pnl.getNextHighestDepth());
      pnl.createEmptyMovieClip("linesMask",pnl.getNextHighestDepth());
      pnl.createEmptyMovieClip("lines2",pnl.getNextHighestDepth());
      pnl.lines._y = 31;
      pnl.linesMask._y = pnl.lines._y - 1;
      pnl.lines.setMask(pnl.linesMask);
      classes.Drawing.topLines(pnl.lines,pnl.linesMask,iww);
      var nimTopLineColor = new Color(pnl.lines);
      nimTopLineColor.setRGB(16726051);
      pnl.lines2._y = 167;
      classes.Drawing.midLines(pnl.lines2,iww);
      var nimMidLineColor = new Color(pnl.lines2);
      nimMidLineColor.setRGB(16726051);
      pnl.attachMovie("tog_pm","tog_pm",pnl.getNextHighestDepth());
      pnl.tog_pm._x = 15;
      pnl.tog_pm._y = 5;
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
      pnl.tog_blist._x = pnl.tog_pm._x + pnl.tog_pm._width;
      pnl.tog_blist._y = pnl.tog_pm._y;
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
      trace("show facebook invite button?: " + classes.GlobalData.facebookConnected);
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
         pnl.nim.univGroup.attachMovie("nim_head","nim_head",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.nim_head._x = 32;
         pnl.nim.univGroup.nim_head._y = 84;
         pnl.nim.univGroup.attachMovie("tog_profile","tog_profile",pnl.nim.univGroup.getNextHighestDepth());
         tog_profile._x = pnl.bgGrad._width - 168;
         pnl.nim.univGroup.attachMovie("tog_email","tog_email",pnl.nim.univGroup.getNextHighestDepth());
         tog_email._x = tog_profile._x + tog_profile._width + 10;
         pnl.nim.univGroup.attachMovie("tog_addbuddy","tog_addbuddy",pnl.nim.univGroup.getNextHighestDepth());
         tog_addbuddy._x = tog_email._x + tog_email._width + 10;
         pnl.nim.univGroup.attachMovie("tog_block","tog_block",pnl.nim.univGroup.getNextHighestDepth());
         pnl.nim.univGroup.attachMovie("tog_buddy_close","tog_buddy_close",pnl.nim.univGroup.getNextHighestDepth());
         tog_profile._y = 243;
         tog_email._y = tog_profile._y;
         tog_challenge._y = tog_profile._y;
         tog_addbuddy._y = tog_profile._y;
         tog_block._y = tog_profile._y;
         tog_block._x = pnl.bgGrad._width - 54;
         tog_buddy_close._x = pnl.bgGrad._width - 42;
         tog_buddy_close._y = 112;
         classes.Effects.roBounce(tog_profile);
         classes.Effects.roBounce(tog_email);
         classes.Effects.roBounce(tog_challenge);
         classes.Effects.roBounce(tog_block);
         classes.Effects.roBump(tog_buddy_close);
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
            trace("TODO challenge");
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
         this.startDrag(false,crn.ix,crn.iy,crn.ix,800);
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
         trace("refreshMe");
         classes.SelectionController.checkFocus();
         if(forceRedraw)
         {
            pnl.forceFlag = forceRedraw;
         }
         var fy = 1 + (crn._y - crn.iy) / (crn.iy + crn._height);
         if(fy >= 1)
         {
            pnl.bgGrad._height = crn._y + crn._height - pnl.bgGrad._y;
         }
         pnl.glare_mid._yscale = Math.abs(pnl.bgGrad._height - (pnl.glare_top._height + pnl.glare_btm._height));
         pnl.glare_btm._y = pnl.glare_mid._y + pnl.glare_mid._height;
         boxH = pnl.bgGrad._height - fBoxY - fBoxH - midGap - btmM;
         boxW = pnl.bgGrad._width - 40;
         boxBH = pnl.bgGrad._height - topM - btmM;
         if(!classes.Console.nimBuddyID)
         {
            trace("]]]] no selected convo");
            classes.Console.nimBuddyID = classes.Console.getFirstIndicatorID();
         }
         if(classes.Console.nimBuddyID > 0)
         {
            trace("]]]] there is now a selected convo");
            if(pnl.nim.conversationGroup["conversation" + classes.Console.nimBuddyID] == undefined)
            {
               classes.Console.newConverse(classes.Console.nimBuddyID);
            }
            else
            {
               classes.Console.focusConverse(classes.Console.nimBuddyID);
            }
         }
         var converseCount = 0;
         for(var converse in pnl.nim.conversationGroup)
         {
            if(converse.indexOf("conversation") > -1)
            {
               converseCount++;
               if(pnl.nim.conversationGroup[converse].id == classes.Console.nimBuddyID)
               {
                  refreshConverse(pnl.nim.conversationGroup[converse]);
               }
            }
         }
         if(converseCount > 0)
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
         }
         classes.Drawing.insetBoxBuddies(pnl.tbB,boxW,boxBH,buddyHeaderH,1119253,2106921,461066,16726051);
         if(pnl.tbB.tab_nim_buddies == undefined)
         {
            pnl.tbB.attachMovie("tab_nim_buddies","tab_nim_buddies",pnl.tbB.getNextHighestDepth());
            pnl.tbB.tab_nim_buddies._x = 18;
            pnl.tbB.tab_nim_buddies._y = 12;
            pnl.tbB.tab_nim_buddies.clr = new Color(pnl.tbB.tab_nim_buddies);
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
            pnl.tbB.tab_nim_requests.clr = new Color(pnl.tbB.tab_nim_requests);
            pnl.tbB.tab_nim_requests.onRelease = function()
            {
               pnl.tbB.showRequests = true;
               _root.getNimIncomingRequests();
            };
         }
         if(!pnl.tbB.showRequests)
         {
            pnl.tbB.scrollerReq._visible = false;
            pnl.tbB.blist_trashcan._visible = true;
            pnl.tbB.scroller._visible = true;
            pnl.tbB.tab_nim_buddies.clr.setRGB(16726051);
            pnl.tbB.tab_nim_requests.clr.setRGB(8618883);
            if(pnl.tbB.blist_trashcan == undefined)
            {
               pnl.tbB.attachMovie("blist_trashcan","blist_trashcan",pnl.tbB.getNextHighestDepth());
               pnl.tbB.blist_trashcan._x = boxW - 36;
               pnl.tbB.blist_trashcan._y = 14;
            }
            if(pnl.tbB.scroller == undefined)
            {
               pnl.tbB.createEmptyMovieClip("scroller",pnl.tbB.getNextHighestDepth());
               pnl.tbB.scroller.createEmptyMovieClip("scrollerContent",pnl.tbB.scroller.getNextHighestDepth());
               pnl.tbB.scroller.scrollerObj = new controls.ScrollPane(pnl.tbB.scroller.scrollerContent,boxW,boxBH - buddyHeaderH);
               pnl.tbB.scroller._y = buddyHeaderH;
            }
            with(pnl.tbB)
            {
               scroller.scrollerObj.setSizeMask(boxW,boxBH - buddyHeaderH);
               drawBuddyList(scroller.scrollerContent,boxW,boxBH - buddyHeaderH);
               var minContentY = scroller.scrollerObj._mvmask._y + scroller.scrollerObj._mvmask._height - scroller.scrollerContent._height;
               if(scroller.scrollerContent._height > scroller.scrollerObj._mvmask._height && scroller.scrollerContent._y < minContentY)
               {
                  scroller.scrollerContent._y = minContentY;
               }
               scroller.scrollerObj.resetScroller(boxBH - buddyHeaderH,boxW - 10);
            }
         }
         else
         {
            pnl.tbB.clear();
            classes.Drawing.insetBoxBuddies(pnl.tbB,boxW,boxBH,buddyHeaderH,1119253,2106921,461066,16726051,73,77);
            pnl.tbB.blist_trashcan._visible = false;
            pnl.tbB.scroller._visible = false;
            pnl.tbB.scrollerReq._visible = true;
            pnl.tbB.tab_nim_buddies.clr.setRGB(8618883);
            pnl.tbB.tab_nim_requests.clr.setRGB(16726051);
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
         pnl.cornerHandle._x = crn._x;
         pnl.cornerHandle._y = crn._y;
         classes.SelectionController.restoreFocus();
      };
      pnl.refreshMe();
      classes.Control.dockNim();
      classes.Frame._MC.overlay.tabNim._visible = false;
   }
   static function drawBuddyRequestList(listW, listH)
   {
      trace("drawBuddyRequestList");
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
      var _context = classes.Console.buddyRequestContext.listBuddies;
      var tid = xnode.attributes.i;
      if(_context["listItem" + tid] != undefined)
      {
         _context["listItem" + tid]._y = yPos;
         return undefined;
      }
      _context.createEmptyMovieClip("listItem" + tid,_context.getNextHighestDepth());
      _context["listItem" + tid].id = tid;
      with(_context["listItem" + tid])
      {
         var boxH = cHeight;
         var boxW = cWidth;
         var timeBoxW = 30;
         var textMargin = 18;
         var textMargin = 28;
         var imgToLoad = "";
         _context["listItem" + tid].createEmptyMovieClip("hilite",_context["listItem" + tid].getNextHighestDepth());
         with(hilite)
         {
            beginFill(16777215,0);
            lineTo(- boxW,0);
            lineTo(- boxW,boxH);
            lineTo(0,boxH);
            lineTo(0,0);
            endFill();
         }
         if(_context["listItem" + tid].pic == undefined)
         {
            _context["listItem" + tid].createEmptyMovieClip("pic",_context["listItem" + tid].getNextHighestDepth());
         }
         pic._xscale = 50;
         pic._yscale = 50;
         classes.Drawing.portrait(_context["listItem" + tid].pic,Number(xnode.attributes.i),2,0,0,2);
         pic._x = - pic._width - 10;
         pic._y = 2;
         _context["listItem" + tid].pic.onRelease = function()
         {
            classes.Control.focusViewer(this._parent.id);
         };
         _x = cWidth;
         if(_context["listItem" + tid].infoClip == undefined)
         {
            _context["listItem" + tid].createEmptyMovieClip("infoClip",_context["listItem" + tid].getNextHighestDepth());
         }
         with(infoClip)
         {
            _y = 6;
            _x = pic.getBounds(_context["listItem" + tid]).xMin;
            beginFill(16777215);
            lineTo(-90,0);
            curveTo(-97,3,-100,11);
            lineTo(0,11);
            lineTo(0,0);
            endFill();
            var infoW = 150;
            var fillType = "linear";
            var colors = [11451343,11451343];
            var alphas = [100,0];
            var ratios = [0,255];
            var matrix = new flash.geom.Matrix();
            matrix.createGradientBox(- infoW,infoW,0,0,0);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            moveTo(0,11);
            lineTo(- infoW,11);
            lineTo(- infoW,12);
            lineTo(0,12);
            lineTo(0,11);
            endFill();
            moveTo(0,34);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            lineTo(- infoW,34);
            lineTo(- infoW,35);
            lineTo(0,35);
            lineTo(0,34);
            endFill();
            var colors = [8955345,8955345];
            moveTo(0,12);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            lineTo(- infoW,12);
            lineTo(- infoW,34);
            lineTo(0,34);
            lineTo(0,12);
            endFill();
            infoClip.createTextField("name_txt",1,-93,0,85,20);
            name_txt.embedFonts = true;
            name_txt.selectable = false;
            name_txt.antiAliasType = "advanced";
            name_txt.gridFitType = "pixel";
            var tfrm = new TextFormat();
            tfrm.font = "Arial";
            tfrm.size = 9;
            tfmt.bold = true;
            tfrm.align = "right";
            tfrm.color = 5990005;
            name_txt.setNewTextFormat(tfrm);
            name_txt.text = xnode.attributes.n;
            infoClip.attachMovie("buddy_request_choices","choices",infoClip.getNextHighestDepth(),{_x:-130,_y:13});
            choices.accept.onRelease = function()
            {
               i = 0;
               while(i < _global.incomingRequestsXML.firstChild.childNodes.length)
               {
                  if(_global.incomingRequestsXML.firstChild.childNodes[i].attributes.i == _parent.id)
                  {
                     trace("removing from xml: " + _parent.id);
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
                     trace("removing from xml: " + _parent.id);
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
      var _context = classes.Console.buddyRequestContext.listBuddies;
      var tid = xnode.attributes.i;
      if(_context["listItemOut" + tid] != undefined)
      {
         _context["listItemOut" + tid]._y = yPos;
         return undefined;
      }
      _context.createEmptyMovieClip("listItemOut" + tid,_context.getNextHighestDepth());
      _context["listItemOut" + tid].id = tid;
      with(_context["listItemOut" + tid])
      {
         var boxH = cHeight;
         var boxW = cWidth;
         var timeBoxW = 30;
         var textMargin = 18;
         var textMargin = 28;
         var imgToLoad = "";
         _context["listItemOut" + tid].createEmptyMovieClip("hilite",_context["listItemOut" + tid].getNextHighestDepth());
         classes.Drawing.rect(hilite,boxW,boxH,16777215,0,- boxW);
         if(_context["listItemOut" + tid].pic == undefined)
         {
            _context["listItemOut" + tid].createEmptyMovieClip("pic",_context["listItemOut" + tid].getNextHighestDepth());
         }
         pic._xscale = 50;
         pic._yscale = 50;
         classes.Drawing.portrait(_context["listItemOut" + tid].pic,Number(xnode.attributes.i),2,0,0,2);
         pic._x = - pic._width - 10;
         pic._y = 2;
         _x = cWidth;
         if(_context["listItemOut" + tid].infoClip == undefined)
         {
            _context["listItemOut" + tid].createEmptyMovieClip("infoClip",_context["listItemOut" + tid].getNextHighestDepth());
         }
         with(infoClip)
         {
            _y = 6;
            _x = pic.getBounds(_context["listItemOut" + tid]).xMin;
            beginFill(16777215);
            lineTo(-90,0);
            curveTo(-97,3,-100,11);
            lineTo(0,11);
            lineTo(0,0);
            endFill();
            var infoW = 150;
            var fillType = "linear";
            var colors = [11451343,11451343];
            var alphas = [100,0];
            var ratios = [0,255];
            var matrix = new flash.geom.Matrix();
            matrix.createGradientBox(- infoW,infoW,0,0,0);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            moveTo(0,11);
            lineTo(- infoW,11);
            lineTo(- infoW,12);
            lineTo(0,12);
            lineTo(0,11);
            endFill();
            moveTo(0,34);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            lineTo(- infoW,34);
            lineTo(- infoW,35);
            lineTo(0,35);
            lineTo(0,34);
            endFill();
            var colors = [8955345,8955345];
            moveTo(0,12);
            beginGradientFill(fillType,colors,alphas,ratios,matrix);
            lineTo(- infoW,12);
            lineTo(- infoW,34);
            lineTo(0,34);
            lineTo(0,12);
            endFill();
            infoClip.createTextField("name_txt",1,-93,0,85,20);
            name_txt.embedFonts = true;
            name_txt.selectable = false;
            name_txt.antiAliasType = "advanced";
            name_txt.gridFitType = "pixel";
            var tfrm = new TextFormat();
            tfrm.font = "Arial";
            tfrm.size = 9;
            tfmt.bold = true;
            tfrm.align = "right";
            tfrm.color = 5990005;
            name_txt.setNewTextFormat(tfrm);
            name_txt.text = xnode.attributes.n;
            infoClip.createTextField("status_txt",2,-122,14,114,24);
            status_txt.embedFonts = true;
            status_txt.selectable = false;
            classes.Console.setOutgoingItemStatusDisplay(tid,Number(xnode.attributes.s));
         }
         _y = yPos;
         _context["listItemOut" + tid].onRelease = function()
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
      var _loc2_ = 0;
      while(_loc2_ < _global.outgoingRequestsXML.firstChild.childNodes.length)
      {
         if(_global.outgoingRequestsXML.firstChild.childNodes[_loc2_].attributes.i == id)
         {
            _global.outgoingRequestsXML.firstChild.childNodes[_loc2_].removeNode();
            if(classes.Console._BASE.panel.tbB.scrollerReq._visible)
            {
               trace("redrawing buddy requests since it is currently showing");
               classes.Console.redrawBuddyRequestList();
            }
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function changeOutgoingItemStatus(id, s)
   {
      var _loc2_ = 0;
      while(_loc2_ < _global.outgoingRequestsXML.firstChild.childNodes.length)
      {
         if(_global.outgoingRequestsXML.firstChild.childNodes[_loc2_].attributes.i == id)
         {
            _global.outgoingRequestsXML.firstChild.childNodes[_loc2_].attributes.s = s;
            trace("found xml item.  s=0");
            classes.Console.setOutgoingItemStatusDisplay(id,s);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   static function setOutgoingItemStatusDisplay(id, s)
   {
      trace("setOutgoingItemStatusDisplay: " + id + ", " + s);
      var _loc2_ = classes.Console.buddyRequestContext.listBuddies["listItemOut" + id].infoClip;
      var _loc1_ = new TextFormat();
      _loc1_.font = "Arial";
      _loc1_.size = 12;
      _loc1_.bold = true;
      _loc1_.align = "right";
      switch(s)
      {
         case 0:
            _loc1_.color = 12189696;
            _loc2_.status_txt.text = "DECLINED";
            break;
         case 1:
            _loc1_.color = 16777215;
            _loc2_.status_txt.text = "ACCEPTED";
            break;
         case 2:
            _loc1_.color = 16777215;
            _loc2_.status_txt.text = "PENDING";
            break;
         default:
            _loc1_.color = 16777215;
            _loc2_.status_txt.text = "UNKNOWN STATUS";
      }
      _loc2_.status_txt.setTextFormat(_loc1_);
   }
   static function redrawBuddyRequestList()
   {
      trace("redrawBuddyList");
      var _loc2_ = classes.Console.defaultWidth - 2 * classes.Console.leftM;
      var _loc1_ = classes.Console._BASE.panel.bgGrad._height - classes.Console.topM - classes.Console.btmM - classes.Console.buddyHeaderH;
      classes.Console.drawBuddyRequestList(_loc2_,_loc1_);
   }
   static function changePanel(newPanelNum)
   {
      function goSpin()
      {
         if(classes.Console.si)
         {
            clearInterval(classes.Console.si);
            classes.Console.si = 0;
            curPanel._visible = true;
            context.edge.removeMovieClip();
            delete context.edge;
            context.grab.removeMovieClip();
            delete context.grab;
            context.gradFlip.removeMovieClip();
            delete context.gradFlip;
            curPanel.tog_pm.clearFlash();
         }
         else
         {
            curPanel.bouncePeak = -16;
            curPanel.bounceAmt = 0;
            curPanel.bounceVel = -20;
            classes.Console.si = setInterval(spinDots,20);
         }
      }
      function spinDots()
      {
         with(curPanel)
         {
            thetaStep = 18;
            theta += thetaStep;
            if(theta >= 90)
            {
               theta = -90;
               with(curPanel)
               {
                  refreshMe();
                  bmpPanel.dispose();
                  bmpPanel = new flash.display.BitmapData(curPanel.bgGrad._width,curPanel.bgGrad._height,true,0);
                  bmpPanel.draw(curPanel);
                  di = new classes.DistordImageB(context.grab,bmpPanel,4,4);
               }
            }
            if(theta == 0)
            {
               if(ptheta == 0)
               {
                  if(!bounceAmt)
                  {
                     bounceAmt = bouncePeak;
                  }
                  bounceVel += (- bounceAmt) / 3;
                  bounceVel *= 0.5;
                  if(!(Math.abs(bounceVel) > 0.4 || Math.abs(bounceAmt) > 0.4))
                  {
                     bounceVel = 0;
                     bounceAmt = 0;
                     goSpin();
                     return undefined;
                  }
                  bounceAmt += bounceVel;
               }
               ptheta = 0;
            }
            else
            {
               ptheta = 6.283185307179586 * theta / 360;
            }
            var zoomAmt = 300;
            var spinW = curPanel.bgGrad._width;
            var spinH = curPanel.bgGrad._height;
            var leftX = center.x - Math.cos(ptheta) * spinW / 2;
            var rightX = center.x + Math.cos(ptheta) * spinW / 2;
            var topY = center.y - spinH / 2;
            var btmY = center.y + spinH / 2;
            var frontZ = Math.sin(ptheta) * spinW / 2 + Math.abs(Math.sin(ptheta) * zoomAmt + bounceAmt);
            var backZ = Math.sin(ptheta) * (- spinW) / 2 + Math.abs(Math.sin(ptheta) * zoomAmt + bounceAmt);
            var cp1 = {x:leftX,y:topY,z:backZ};
            var cp2 = {x:rightX,y:topY,z:frontZ};
            var cp3 = {x:rightX,y:btmY,z:frontZ};
            var cp4 = {x:leftX,y:btmY,z:backZ};
            var vp = {x:center.x,y:center.y,z:-1000};
            var pt1 = classes.threeD.cPtToPoint(cp1,vp);
            var pt2 = classes.threeD.cPtToPoint(cp2,vp);
            var pt3 = classes.threeD.cPtToPoint(cp3,vp);
            var pt4 = classes.threeD.cPtToPoint(cp4,vp);
            p2._x = pt2.x;
            p2._y = pt2.y;
            p3._y = pt3.y;
            p1._x = pt1.x;
            p1._y = pt1.y;
            p4._y = pt4.y;
            p3._x = p2._x;
            p4._x = p1._x;
            var x0 = p1._x - curPanel._x;
            var y0 = p1._y - curPanel._y;
            var x1 = p2._x - curPanel._x;
            var y1 = p2._y - curPanel._y;
            var x2 = p3._x - curPanel._x;
            var y2 = p3._y - curPanel._y;
            var x3 = p4._x - curPanel._x;
            var y3 = p4._y - curPanel._y;
         }
         di.setTransform(x0,y0,x1,y1,x2,y2,x3,y3);
         var g1 = new flash.geom.Point(x0,y0);
         var g2 = new flash.geom.Point(x1,y1);
         var g3 = new flash.geom.Point(x2,y2);
         var g4 = new flash.geom.Point(x3,y3);
         if(!context.gradFlip)
         {
            context.createEmptyMovieClip("gradFlip",context.getNextHighestDepth());
         }
         if(context.gradFlip.getDepth() > context.grab.getDepth())
         {
            context.gradFlip.swapDepths(context.grab);
         }
         context.gradFlip._x = curPanel._x;
         context.gradFlip._y = curPanel._y;
         context.gradFlip._xscale = curPanel._xscale;
         context.gradFlip._yscale = curPanel._yscale;
         classes.Drawing.rotateConsoleWindow(context.gradFlip,curPanel.bgGrad._width,curPanel.bgGrad._height,g1,g2,g3,g4,theta);
         curPanel._visible = false;
         with(curPanel)
         {
            if(theta == 0)
            {
               theta = - thetaStep;
            }
         }
      }
      var context = classes.Console._BASE;
      var curPanel = classes.Console._BASE.panel;
      curPanel.bgGrad._focusrect = false;
      _root.focusManager.setFocus(curPanel.bgGrad);
      curPanel.tog_pm.clearFlash();
      curPanel.refreshMe();
      classes.Console.panelNum = newPanelNum;
      if(classes.Console.panelNum == 1)
      {
         curPanel.tog_pm.hi._visible = true;
         curPanel.tog_blist.hi._visible = false;
      }
      if(classes.Console.panelNum == 2)
      {
         curPanel.tog_pm.hi._visible = false;
         curPanel.tog_blist.hi._visible = true;
      }
      var bmpPanel = new flash.display.BitmapData(curPanel.bgGrad._width,curPanel.bgGrad._height,true,0);
      bmpPanel.draw(curPanel);
      context.createEmptyMovieClip("grab",context.getNextHighestDepth());
      context.grab._x = curPanel._x;
      context.grab._y = curPanel._y;
      if(context.p1 == undefined)
      {
         var i = 1;
         while(i <= 4)
         {
            context.createEmptyMovieClip("p" + i,context.getNextHighestDepth());
            i++;
         }
      }
      var di = new classes.DistordImageB(context.grab,bmpPanel,4,4);
      goSpin();
      with(curPanel)
      {
         var theta = 0;
         p1._x = curPanel._x;
         p1._y = curPanel._y;
         p2._x = p1._x + curPanel.bgGrad._width;
         p2._y = p1._y;
         p3._x = p2._x;
         p3._y = p1._y + curPanel.bgGrad._height;
         p4._x = p1._x;
         p4._y = p3._y;
         var center = new flash.geom.Point((p2._x + p1._x) / 2,(p4._y + p1._y) / 2);
      }
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
      var bmp = new flash.display.BitmapData(25,21,false,16777215);
      classes.Console._BASE.buddyDrag._alpha = 50;
      classes.Console._BASE.buddyDrag.grab.attachBitmap(bmp,1);
      var _loc3_ = new flash.geom.Matrix();
      _loc3_.scale(0.25,0.25);
      bmp.draw(buddyMC.pic,_loc3_);
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
      trace("addToBuddyList: " + id + ", " + userName + ", " + userStatus + ", " + blocked + ", " + userRole);
      var _loc2_;
      if(classes.Lookup.buddyNum(id) < 0)
      {
         trace("not found so add to list");
         _loc2_ = _global.buddylist_xml.createElement("I");
         _loc2_.attributes.id = id;
         _loc2_.attributes.n = userName;
         _loc2_.attributes.s = userStatus;
         _loc2_.attributes.b = blocked;
         _loc2_.attributes.ul = userLocation;
         if(userRole == undefined)
         {
            userRole = 3;
         }
         _loc2_.attributes.r = userRole;
         _global.buddylist_xml.firstChild.appendChild(_loc2_);
      }
   }
   static function removeFromBuddyList(id)
   {
      trace("removing " + id);
      var _loc2_ = classes.Lookup.buddyNum(id);
      if(_loc2_ >= 0)
      {
         _global.buddylist_xml.firstChild.childNodes[_loc2_].removeNode();
         classes.Console._BASE.panel.tbB.scroller.scrollerContent.listBuddies["listItem" + id].removeMovieClip();
         classes.Console.stopBuddyDrag();
         classes.Console._BASE.panel.refreshMe();
      }
   }
   static function blockUser(id)
   {
      trace("blocking " + id);
      var _loc3_ = classes.Lookup.buddyNum(id);
      if(_loc3_ >= 0)
      {
         _global.buddylist_xml.firstChild.childNodes[_loc3_].attributes.b = 1;
         classes.Console._BASE.panel.refreshMe();
      }
      _root.blockNimUser(id);
   }
   static function setBuddyStatus(_subject, s, ul, b)
   {
      if(s == "0")
      {
         _subject._alpha = 68;
         _subject.infoClip.loc_txt.text = classes.Console.offlineText;
      }
      else
      {
         _subject._alpha = 100;
         classes.Console.showOnlineStatus(_subject.infoClip.loc_txt,ul);
      }
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
   static function updateIndicatorScroll()
   {
      var _loc1_ = 0;
      for(var _loc2_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc2_.indexOf("indicator") > -1)
         {
            _loc1_ = _loc1_ + 1;
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
      var _loc3_ = classes.Console._NIM.indicatorGroup._width;
      classes.Console._NIM.indicatorGroup.attachMovie("indicator","indicator" + userID,classes.Console._NIM.indicatorGroup.getNextHighestDepth(),{id:userID});
      classes.Console._NIM.indicatorGroup["indicator" + userID]._x = _loc3_;
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
      var _loc3_ = new Array();
      var _loc2_;
      for(var _loc5_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc5_.indexOf("indicator") > -1)
         {
            _loc2_ = new Object();
            _loc2_.id = classes.Console._NIM.indicatorGroup[_loc5_].id;
            _loc2_.x = classes.Console._NIM.indicatorGroup[_loc5_]._x;
            _loc3_.push(_loc2_);
         }
      }
      _loc3_.sortOn("x");
      var _loc4_ = _loc3_.length;
      var _loc1_ = 0;
      while(_loc1_ < _loc4_)
      {
         classes.Console._NIM.indicatorGroup["indicator" + _loc3_[_loc1_].id]._x = _loc1_ * classes.Console._NIM.indicatorGroup["indicator" + _loc3_[_loc1_].id]._width;
         _loc1_ = _loc1_ + 1;
      }
      classes.Console._NIM.indicatorGroup.clear();
      classes.Drawing.rect(classes.Console._NIM.indicatorGroup,classes.Console._NIM.indicatorGroup._width,classes.Console._NIM.indicatorGroup._height,0,0);
      classes.Console.updateIndicatorScroll();
   }
   static function getFirstIndicatorID()
   {
      trace("getFirstIndicatorID");
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
               return;
            case 2:
               red._visible = true;
               return;
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
               return;
            default:
               light._visible = true;
               return;
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
   static function findConverse(userID)
   {
      return classes.Console._NIM.conversationGroup["conversation" + userID];
   }
   static function focusConverse(userID)
   {
      trace("focusConverse");
      for(var _loc1_ in classes.Console._NIM.conversationGroup)
      {
         classes.Console._NIM.conversationGroup[_loc1_]._visible = false;
      }
      if(userID > 0)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID]._visible = true;
         classes.Console.nimBuddyName = classes.Console._NIM.conversationGroup["conversation" + userID].uname;
      }
   }
   static function updateConverse(userID, msg, s)
   {
      var _loc2_;
      var _loc3_ = classes.Console._NIM.conversationGroup["conversation" + userID];
      if(classes.Console._NIM.conversationGroup["conversation" + userID].tf.scroll == classes.Console._NIM.conversationGroup["conversation" + userID].tf.maxscroll)
      {
         _loc2_ = true;
      }
      if(classes.Console._NIM.conversationGroup["conversation" + userID].txt == undefined)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].txt = "";
      }
      trace("buddyID: " + classes.Lookup.buddyNum(userID));
      if(Number(classes.Lookup.buddyNum(userID)) > 0 && Number(classes.Lookup.getBuddyNode(userID).attributes.s) <= 0)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].txt += "<br/><font color=\"#FF0000\">****This user is unavailable****</font>";
      }
      else if(Number(classes.Lookup.buddyNum(userID)) < 0)
      {
         trace("updating onlineText");
         trace("buddy loc stuff: " + classes.Console._NIM.conversationGroup["conversation" + userID]);
         trace("buddy loc stuff: " + classes.Console._NIM.conversationGroup["conversation" + userID].tb1);
         trace("buddy loc stuff: " + classes.Console._NIM.conversationGroup["conversation" + userID].tb1.txt_buddyloc);
         classes.Console.showOnlineStatus(classes.Console._NIM.conversationGroup["conversation" + userID].tb1.txt_buddyloc,classes.Lookup.getBuddyNode(userID).attributes.ul);
      }
      classes.Console._NIM.conversationGroup["conversation" + userID].txt += "<br/>" + classes.SpecialText.convertSmilies(classes.data.Profanity.filterString(msg));
      classes.Console._NIM.conversationGroup["conversation" + userID].tf.htmlText = classes.Console._NIM.conversationGroup["conversation" + userID].txt;
      if(_loc2_)
      {
         classes.Console._NIM.conversationGroup["conversation" + userID].tf.scroll = classes.Console._NIM.conversationGroup["conversation" + userID].tf.maxscroll;
      }
      classes.Console._NIM.conversationGroup["conversation" + userID].scroller.refreshScroller();
   }
   static function newConverse(userID)
   {
      trace("newConverse: " + userID);
      classes.Console._NIM.conversationGroup.attachMovie("_blank","conversation" + userID,classes.Console._NIM.conversationGroup.getNextHighestDepth(),{id:userID,uname:classes.Lookup.buddyName(userID)});
      classes.Console.addIndicator(userID);
      classes.Console._BASE.panel.refreshMe();
   }
   static function removeConverse(userID)
   {
      classes.Console._NIM.conversationGroup["conversation" + userID].removeMovieClip();
      delete classes.Console._NIM.conversationGroup["conversation" + userID];
      var _loc7_ = classes.Console._NIM.indicatorGroup["indicator" + userID]._x;
      var _loc3_ = new Array();
      var _loc1_;
      for(var _loc8_ in classes.Console._NIM.indicatorGroup)
      {
         if(_loc8_.indexOf("indicator") > -1)
         {
            _loc1_ = new Object();
            _loc1_.id = classes.Console._NIM.indicatorGroup[_loc8_].id;
            _loc1_.x = classes.Console._NIM.indicatorGroup[_loc8_]._x;
            if(_loc1_.id != userID)
            {
               _loc3_.push(_loc1_);
            }
         }
      }
      var _loc4_;
      var _loc6_;
      var _loc2_;
      if(!_loc3_.length)
      {
         classes.Console.nimBuddyID = 0;
      }
      else
      {
         _loc3_.sortOn("x");
         _loc4_ = 0;
         _loc6_ = _loc3_.length;
         _loc2_ = 0;
         while(_loc2_ < _loc6_)
         {
            if(_loc3_[_loc2_].x > _loc7_)
            {
               _loc4_ = _loc3_[_loc2_].id;
               break;
            }
            _loc2_ = _loc2_ + 1;
         }
         if(_loc4_)
         {
            classes.Console.nimBuddyID = _loc4_;
         }
         else
         {
            classes.Console.nimBuddyID = _loc3_[_loc6_ - 1].id;
         }
      }
      classes.Console.removeIndicator(userID);
      classes.Console.focusConverse(classes.Console.nimBuddyID);
      classes.Console._BASE.panel.refreshMe();
   }
   static function goRequestsPanel()
   {
      classes.Console._BASE.panel.refreshMe();
   }
   static function hideFacebookInviteButton()
   {
      trace("hide facebook invite button");
      trace(classes.Console._BASE.pnl.tog_noInvite);
      classes.Console._BASE.panel.tog_noInvite._visible = false;
      classes.Console._BASE.panel.tog_noInvite.onRelease = null;
   }
}
