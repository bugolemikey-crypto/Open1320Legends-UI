class classes.Email
{
   static var __context;
   static var __inboxList;
   static var viewedEmail;
   static var viewedEmailID;
   static var composeNum = 0;
   static var emailNum = 0;
   static var selectedEmails = [];
   function Email(_context, toUser)
   {
      classes.Email.__context = _context;
      with(_context)
      {
         var iww = 784;
         var ihh = 397;
         var marginSide = 15;
         var marginTop = 41;
         var marginBtm = 28;
         var minFactor = 0.75;
         _context.createEmptyMovieClip("email",_context.getNextHighestDepth());
         _context.email.createEmptyMovieClip("bgGrad",_context.email.getNextHighestDepth());
         classes.Drawing.newBaseWindow(email.bgGrad,iww,ihh,false);
         _context.email.createEmptyMovieClip("nav",_context.email.getNextHighestDepth());
         with(email)
         {
            var bumper = 30;
            nav._x = marginSide;
            nav.attachMovie("tog_new","tog_new",nav.getNextHighestDepth());
            nav.attachMovie("tog_reply","tog_reply",nav.getNextHighestDepth());
            nav.attachMovie("tog_fw","tog_fw",nav.getNextHighestDepth());
            nav.attachMovie("tog_del","tog_del",nav.getNextHighestDepth());
            nav.tog_new._x = Math.floor(nav.tog_new._width / 2);
            nav.tog_reply._x = nav.tog_new._x + Math.floor(nav.tog_new._width / 2 + nav.tog_reply._width / 2) + bumper;
            nav.tog_fw._x = nav.tog_reply._x + Math.floor(nav.tog_reply._width / 2 + nav.tog_fw._width / 2) + bumper;
            nav.tog_del._x = nav.tog_fw._x + Math.floor(nav.tog_fw._width / 2 + nav.tog_del._width / 2) + bumper;
            nav._y = 6 + Math.floor(nav.tog_new._height / 2);
            classes.Email.enableContextBtns(false);
            with(nav)
            {
               classes.Effects.roBounce(tog_new);
               classes.Effects.roBounce(tog_reply);
               classes.Effects.roBounce(tog_fw);
               classes.Effects.roBounce(tog_del);
               tog_new.onRelease = function()
               {
                  this.onRollOut();
                  classes.Email.compose(_context,{to_user:"",subj:""});
               };
               tog_reply.onRelease = function()
               {
                  this.onRollOut();
                  var _loc3_ = "";
                  var _loc2_ = "";
                  if(classes.Email.viewedEmail.firstChild.attributes.fu.length)
                  {
                     _loc3_ = classes.Email.viewedEmail.firstChild.attributes.fu;
                  }
                  if(classes.Email.viewedEmail.firstChild.attributes.s.length)
                  {
                     if(classes.Email.viewedEmail.firstChild.attributes.s.substr(0,4).toUpperCase() != "RE: ")
                     {
                        _loc2_ += "RE: ";
                     }
                     _loc2_ += classes.StringFuncs.unSpecialChars(classes.Email.viewedEmail.firstChild.attributes.s);
                  }
                  classes.Email.compose(_context,{to_user:_loc3_,subj:_loc2_});
               };
               tog_fw.onRelease = function()
               {
                  this.onRollOut();
                  var _loc2_ = "";
                  var _loc3_ = "";
                  if(classes.Email.viewedEmail.firstChild.attributes.s.length)
                  {
                     _loc2_ = "FW: " + classes.StringFuncs.unSpecialChars(classes.Email.viewedEmail.firstChild.attributes.s);
                  }
                  if(classes.Email.viewedEmail.firstChild.firstChild.toString().length)
                  {
                     _loc3_ = "\r\r[Original Message]: \r" + classes.StringFuncs.unSpecialChars(classes.Email.viewedEmail.firstChild.firstChild.toString());
                  }
                  classes.Email.compose(_context,{to_user:"",subj:_loc2_,msg:_loc3_});
               };
               tog_del.onRelease = function()
               {
                  this.onRollOut();
                  classes.Email.deleteEmail(classes.Email.viewedEmailID);
               };
            }
         }
         email.attachMovie("togMinimize","togMinimize",email.getNextHighestDepth());
         email.togMinimize.btn.onRelease = function()
         {
            classes.Control.dockEmail();
         };
         classes.Drawing.addCornerResizer(email,"cornerHandle");
         var crn = email.corner;
         crn.ix = crn._x;
         crn.iy = crn._y;
         var mouseListener = new Object();
         crn.onPress = function()
         {
            this.startDrag(false,crn.ix * minFactor,crn.iy * minFactor,1000,800);
            mouseListener.onMouseMove = function()
            {
               email.refreshMe();
            };
            Mouse.addListener(mouseListener);
         };
         crn.onRelease = function()
         {
            this.stopDrag();
            Mouse.removeListener(mouseListener);
            email.refreshMe();
         };
         crn.onReleaseOutside = crn.onRelease;
         email.refreshMe = function()
         {
            var fx = 1 + (crn._x - crn.ix) / (crn.ix + crn._width);
            var fy = 1 + (crn._y - crn.iy) / (crn.iy + crn._height);
            if(fx >= minFactor)
            {
               email.bgGrad._width = crn._x + crn._width - email.bgGrad._x;
            }
            if(fy >= minFactor)
            {
               email.bgGrad._height = crn._y + crn._height - email.bgGrad._y;
            }
            if(email.togMinimize.getDepth() < email.nav.getDepth())
            {
               email.togMinimize.swapDepths(nav);
            }
            email.togMinimize._x = email.bgGrad._width - email.togMinimize._width - 6;
            email.togMinimize._y = 3;
            if(email.tb1 == undefined)
            {
               email.createEmptyMovieClip("tb1",email.getNextHighestDepth());
            }
            email.tb1._x = marginSide;
            email.tb1._y = marginTop;
            var boxW = email.bgGrad._width - 2 * marginSide;
            var boxH = email.bgGrad._height - marginTop - marginBtm;
            var headH = 78;
            var sepLineWidth = 4;
            var sortingHeadTop = 43;
            classes.Drawing.insetBox(email.tb1,boxW,boxH,headH,8556969);
            var sepLineX = Math.round(email.tb1._width / 3);
            var cRad = 5;
            with(email.tb1)
            {
               moveTo(0,cRad);
               beginFill(11123413);
               curveTo(0,0,cRad,0);
               lineTo(sepLineX,0);
               lineTo(sepLineX,63);
               lineTo(0,63);
               lineTo(0,cRad);
               endFill();
               moveTo(0,37);
               lineTo(sepLineX,37);
               beginFill(16777215);
               lineTo(sepLineX,headH);
               lineTo(0,headH);
               lineTo(0,37);
               endFill();
               if(email.tb1.tog_inbox == undefined)
               {
                  email.tb1.attachMovie("tog_inbox","tog_inbox",email.tb1.getNextHighestDepth());
                  tog_inbox.hot.onRelease = function()
                  {
                     activateTab(tog_inbox);
                  };
               }
               tog_inbox._x = 21;
               tog_inbox._y = 5;
               if(scroller == undefined)
               {
                  email.tb1.createEmptyMovieClip("scroller",email.tb1.getNextHighestDepth());
                  email.tb1.scroller.createEmptyMovieClip("scrollerContent",email.tb1.scroller.getNextHighestDepth());
                  email.tb1.scroller.scrollerObj = new controls.ScrollPane(email.tb1.scroller.scrollerContent,sepLineX - 1,boxH - 65 - 1);
               }
               scroller._x = 1;
               scroller._y = 65;
               scroller.scrollerObj.setSizeMask(sepLineX - 1,boxH - 65 - 1);
               scroller.scrollerObj.resetScroller(boxH - 65 - 1,sepLineX - 11);
               var sortW = sepLineX - 1;
               moveTo(0,sortingHeadTop);
               beginFill(13687014);
               lineTo(sortW,sortingHeadTop);
               lineTo(sortW,sortingHeadTop + 1);
               lineTo(0,sortingHeadTop + 1);
               lineTo(0,sortingHeadTop);
               endFill();
               moveTo(0,sortingHeadTop + 1);
               beginFill(10662348);
               lineTo(sortW,sortingHeadTop + 1);
               lineTo(sortW,sortingHeadTop + 19);
               lineTo(0,sortingHeadTop + 19);
               lineTo(0,sortingHeadTop + 1);
               endFill();
               moveTo(0,sortingHeadTop + 19);
               beginFill(10461604);
               lineTo(sortW,sortingHeadTop + 19);
               lineTo(sortW,sortingHeadTop + 20);
               lineTo(0,sortingHeadTop + 20);
               lineTo(0,sortingHeadTop + 19);
               endFill();
            }
            if(email.tb1.inbxLine == undefined)
            {
               email.tb1.createEmptyMovieClip("inbxLine",email.tb1.getNextHighestDepth());
            }
            var tbz = email.tb1.inbxLine;
            with(tbz)
            {
               clear();
               _x = sepLineX;
               lineStyle(undefined,0,100);
               beginFill(16777215);
               lineTo(sepLineWidth + 2,0);
               lineTo(sepLineWidth + 2,boxH);
               lineTo(0,boxH);
               lineTo(0,0);
               endFill();
               moveTo(1,0);
               beginFill(11386329);
               lineTo(1 + sepLineWidth,0);
               lineTo(1 + sepLineWidth,boxH);
               lineTo(1,boxH);
               lineTo(1,0);
               endFill();
            }
            email.tb1.viewTextWidth = boxW - email.tb1.inbxLine._x - email.tb1.inbxLine._width;
            email.tb1.viewTextHeight = boxH - headH;
            email.tb1.headH = headH;
            classes.Email.drawInbox(email.tb1.scroller.scrollerContent,sepLineX,boxH - sortingHeadTop - 20 - 3);
            scroller.scrollerObj.refreshScroller();
            classes.Drawing.applyInsetBoxFilters(email.tb1);
            email.cornerHandle._x = crn._x;
            email.cornerHandle._y = crn._y;
            classes.Drawing.applyMainShad(email.bgGrad);
         };
         email.refreshMe();
         with(email.tb1)
         {
            activateTab = function(newtab)
            {
               var _loc2_ = [tog_inbox,tog_sent];
               var _loc1_ = 0;
               while(_loc1_ < _loc2_.length)
               {
                  if(_loc2_[_loc1_] == newtab)
                  {
                     _loc2_[_loc1_].hi._visible = true;
                     _loc2_[_loc1_].hot._visible = false;
                  }
                  else
                  {
                     _loc2_[_loc1_].hot._visible = true;
                     _loc2_[_loc1_].hi._visible = false;
                  }
                  _loc1_ = _loc1_ + 1;
               }
            };
            activateTab(tog_inbox);
         }
         classes.Drawing.applyMainShad(email);
         email.bgGrad.onPress = function()
         {
            email.swapDepths(classes.Email.__context.getNextHighestDepth());
            email.startDrag(false);
         };
         email.bgGrad.onRelease = function()
         {
            email.stopDrag();
         };
         email.bgGrad.onReleaseOutside = email.bgGrad.onRelease;
         email.bgGrad.useHandCursor = false;
         setupInbox(email);
      }
      if(toUser.length)
      {
         classes.Email.compose(_context,{to_user:toUser,subj:""});
      }
   }
   static function compose(_context, initObj)
   {
      classes.Email.composeEmail(_context,initObj);
   }
   static function composeEmail(_context, initObj)
   {
      with(_context)
      {
         var iww = 600;
         var ihh = 350;
         var marginSide = 15;
         var marginTop = 38;
         var marginBtm = 28;
         var headH = 78;
         var minFactor = 0.5;
         classes.Email.composeNum++;
         var tcompose = _context.createEmptyMovieClip("compose" + classes.Email.composeNum,_context.getNextHighestDepth());
         tcompose.composeNum = classes.Email.composeNum;
         tcompose._x = 60 + classes.Email.composeNum % 8 * 20;
         tcompose._y = 60 + classes.Email.composeNum % 8 * 15;
         tcompose.createEmptyMovieClip("bgGrad",tcompose.getNextHighestDepth());
         classes.Drawing.newBaseWindow(tcompose.bgGrad,iww,ihh,false);
         tcompose.bgGrad.onPress = function()
         {
            tcompose.swapDepths(_context.getNextHighestDepth());
            tcompose.startDrag(false);
         };
         tcompose.bgGrad.onRelease = function()
         {
            tcompose.stopDrag();
         };
         tcompose.bgGrad.onReleaseOutside = tcompose.bgGrad.onRelease;
         for(item in initObj)
         {
            tcompose[item] = initObj[item];
         }
         tcompose.bgGrad.useHandCursor = false;
         with(tcompose)
         {
            tcompose.createEmptyMovieClip("nav",tcompose.getNextHighestDepth());
            var bumper = 30;
            nav._x = marginSide;
            nav.attachMovie("tog_send","tog_send",nav.getNextHighestDepth());
            nav.attachMovie("tog_closewin","tog_closewin",nav.getNextHighestDepth());
            nav.tog_send._x = Math.floor(nav.tog_send._width / 2);
            nav.tog_send._y = 6 + Math.floor(nav.tog_send._height / 2);
            nav.tog_closewin._x = iww - 38;
            nav.tog_closewin._y = 5;
            with(nav)
            {
               classes.Effects.roBounce(tog_send);
               tog_send.onRelease = function()
               {
                  if(this._parent._parent.to_user.length)
                  {
                     _root.sendEmail(this._parent._parent.to_user,this._parent._parent.subj,this._parent._parent.msg,this._parent._parent.composeNum);
                  }
                  else
                  {
                     _root.displayAlert("warning","E-mail Can Not Be Sent","\'To:\' can not be blank.  Please enter the receiver\'s user name in the \'To:\' field.");
                  }
               };
               tog_closewin.onRelease = function()
               {
                  this._parent._parent.removeMovieClip();
               };
            }
         }
         classes.Drawing.addCornerResizer(tcompose,"cornerHandle");
         var crn = tcompose.corner;
         crn.ix = crn._x;
         crn.iy = crn._y;
         var mouseListener = new Object();
         crn.onPress = function()
         {
            this.startDrag(false,crn.ix * minFactor,crn.iy * minFactor,1000,800);
            mouseListener.onMouseMove = function()
            {
               tcompose.refreshMe();
            };
            Mouse.addListener(mouseListener);
         };
         crn.onRelease = function()
         {
            this.stopDrag();
            Mouse.removeListener(mouseListener);
            tcompose.refreshMe();
         };
         crn.onReleaseOutside = crn.onRelease;
         setComposeScroller = function(scrollerContext, xx, hh)
         {
            with(scrollerContext)
            {
               scroller.scrollerObj.resetScroller(hh,xx);
               if(txt_msg.maxscroll > 1)
               {
                  scroller._visible = true;
               }
               else
               {
                  scroller._visible = false;
               }
            }
         };
         tcompose.refreshMe = function()
         {
            var fx = 1 + (crn._x - crn.ix) / (crn.ix + crn._width);
            var fy = 1 + (crn._y - crn.iy) / (crn.iy + crn._height);
            if(fx >= minFactor)
            {
               tcompose.bgGrad._width = crn._x + crn._width - tcompose.bgGrad._x;
            }
            if(fy >= minFactor)
            {
               tcompose.bgGrad._height = crn._y + crn._height - tcompose.bgGrad._y;
            }
            tcompose.nav.tog_closewin._x = tcompose.bgGrad._width - 38;
            if(tcompose.tb1 == undefined)
            {
               tcompose.createEmptyMovieClip("tb1",tcompose.getNextHighestDepth());
            }
            tcompose.tb1._x = marginSide;
            tcompose.tb1._y = marginTop;
            var boxW = tcompose.bgGrad._width - 2 * marginSide;
            var boxH = tcompose.bgGrad._height - marginTop - marginBtm;
            classes.Drawing.insetBox(tcompose.tb1,boxW,boxH,headH,11123413);
            with(tcompose.tb1)
            {
               var leftOffset = 80;
               var cRad = 9;
               var tBoxH = 17;
               var minWidth = iww * minFactor - 2 * marginSide - leftOffset;
               var addrWidth = Math.max(minWidth,Math.round(0.6 * (boxW - leftOffset)));
               var topOffset = 24;
               moveTo(leftOffset,topOffset + cRad);
               beginFill(16777215);
               curveTo(leftOffset,topOffset,leftOffset + cRad,topOffset);
               lineTo(leftOffset + addrWidth - cRad,topOffset);
               curveTo(leftOffset + addrWidth,topOffset,leftOffset + addrWidth,topOffset + cRad);
               lineTo(leftOffset + addrWidth,topOffset + tBoxH - cRad);
               curveTo(leftOffset + addrWidth,topOffset + tBoxH,leftOffset + addrWidth - cRad,topOffset + tBoxH);
               lineTo(leftOffset + cRad,topOffset + tBoxH);
               curveTo(leftOffset,topOffset + tBoxH,leftOffset,topOffset + tBoxH - cRad);
               lineTo(leftOffset,topOffset + cRad);
               endFill();
               if(txt_to == undefined)
               {
                  createTextField("txt_to",11,leftOffset + cRad,topOffset - 1,addrWidth - 2 * cRad,tBoxH);
                  txt_to.embedFonts = true;
                  txt_to.type = "input";
                  txt_to.tabIndex = 1;
                  txt_to.maxChars = 20;
                  var tfrm = new TextFormat();
                  tfrm.font = "ArialBmp12";
                  tfrm.size = 12;
                  tfrm.color = 0;
                  txt_to.setNewTextFormat(tfrm);
                  txt_to.variable = "_parent.to_user";
               }
               topOffset = 48;
               moveTo(leftOffset,topOffset + cRad);
               beginFill(16777215);
               curveTo(leftOffset,topOffset,leftOffset + cRad,topOffset);
               lineTo(leftOffset + addrWidth - cRad,topOffset);
               curveTo(leftOffset + addrWidth,topOffset,leftOffset + addrWidth,topOffset + cRad);
               lineTo(leftOffset + addrWidth,topOffset + tBoxH - cRad);
               curveTo(leftOffset + addrWidth,topOffset + tBoxH,leftOffset + addrWidth - cRad,topOffset + tBoxH);
               lineTo(leftOffset + cRad,topOffset + tBoxH);
               curveTo(leftOffset,topOffset + tBoxH,leftOffset,topOffset + tBoxH - cRad);
               lineTo(leftOffset,topOffset + cRad);
               endFill();
               if(txt_subj == undefined)
               {
                  createTextField("txt_subj",12,leftOffset + cRad,topOffset - 1,addrWidth - 2 * cRad,tBoxH);
                  txt_subj.embedFonts = true;
                  txt_subj.type = "input";
                  txt_subj.tabIndex = 2;
                  txt_subj.maxChars = 250;
                  txt_subj.restrict = classes.Lookup.keyboardRestrictChars;
                  var tfrm = new TextFormat();
                  tfrm.font = "ArialBmp12";
                  tfrm.size = 12;
                  tfrm.color = 0;
                  txt_subj.setNewTextFormat(tfrm);
                  txt_subj.variable = "_parent.subj";
               }
               txt_to._width = addrWidth - 2 * cRad;
               txt_subj._width = addrWidth - 2 * cRad;
               if(txt_msg == undefined)
               {
                  createTextField("txt_msg",13,32,90,boxW - 64,boxH - 90 - 15);
                  txt_msg.embedFonts = true;
                  txt_msg.type = "input";
                  txt_msg.multiline = true;
                  txt_msg.wordWrap = true;
                  txt_msg.tabIndex = 3;
                  txt_subj.maxChars = 5000;
                  txt_msg.restrict = classes.Lookup.keyboardRestrictChars;
                  var tfrm = new TextFormat();
                  tfrm.font = "ArialBmp12";
                  tfrm.size = 12;
                  tfrm.color = 0;
                  txt_msg.setNewTextFormat(tfrm);
                  txt_msg.variable = "_parent.msg";
                  tcompose.tb1.createEmptyMovieClip("scroller",tcompose.tb1.getNextHighestDepth());
                  scroller.scrollerObj = new controls.ScrollBar(txt_msg,boxH - 65,0,78);
                  scroller._x = boxW - 10;
                  scroller._visible = false;
                  txt_msg.onChanged = function()
                  {
                     var _loc1_ = tcompose.bgGrad._width - 2 * marginSide - 10;
                     setComposeScroller(tcompose.tb1,_loc1_,scroller._height);
                  };
               }
               setComposeScroller(tcompose.tb1,boxW - 10,boxH - 78);
               txt_msg._width = boxW - 64;
               txt_msg._height = boxH - 90 - 15;
            }
            classes.Drawing.applyInsetBoxFilters(tcompose.tb1);
            tcompose.cornerHandle._x = crn._x;
            tcompose.cornerHandle._y = crn._y;
            classes.Drawing.applyMainShad(tcompose);
         };
         tcompose.refreshMe();
         with(tcompose)
         {
            tcompose.attachMovie("icon_buddy","icon_buddy",tcompose.getNextHighestDepth());
            icon_buddy._x = tb1._x + 23;
            icon_buddy._y = tb1._y + 23;
            tcompose.createEmptyMovieClip("head_names",tcompose.getNextHighestDepth());
            head_names.createTextField("txt_head",1,0,0,78,56);
            head_names._x = tb1._x;
            head_names._y = icon_buddy._y;
            head_names.swapDepths(icon_buddy);
            with(head_names)
            {
               txt_head.embedFonts = true;
               txt_head.wordWrap = true;
               txt_head.multiline = true;
               var tfrm = new TextFormat();
               tfrm.font = "Arial";
               tfrm.bold = true;
               tfrm.size = 13;
               tfrm.leading = 10;
               tfrm.align = "right";
               tfrm.color = 16777215;
               txt_head.text = "To:\rSubject:";
               txt_head.setTextFormat(tfrm);
            }
         }
      }
   }
   static function enableContextBtns(enable)
   {
      with(classes.Email.__context.email.nav)
      {
         tog_reply._visible = enable;
         tog_fw._visible = enable;
         tog_del._visible = enable;
      }
   }
   static function redrawInbox()
   {
      trace("redrawInbox");
      var _loc1_ = classes.Email.__context.email.tb1.scroller.scrollerContent;
      var _loc3_ = Math.round(classes.Email.__context.email.tb1._width / 3);
      var _loc4_ = classes.Email.__context.email.bgGrad._height - 41 - 28;
      var _loc2_ = _loc4_ - 43 - 20 - 3;
      classes.Email.drawInbox(_loc1_,_loc3_,_loc2_);
   }
   static function drawInbox(_context, inboxW, inboxH)
   {
      var adjW = inboxW;
      classes.Email.emailNum = 0;
      with(_context)
      {
         if(_context.inbox == undefined)
         {
            _context.createEmptyMovieClip("inbox",_context.getNextHighestDepth());
            _context.inbox.cacheAsBitmap = true;
            classes.Email.__inboxList = _context.inbox;
         }
         for(every in _context.inbox)
         {
            if(every.indexOf("eitem") > -1)
            {
               _context.inbox[every].removeMovieClip();
               delete _context.inbox[every];
            }
         }
         var itemH = 43;
         if(itemH * _global.inbox_xml.firstChild.childNodes.length > inboxH)
         {
            adjW -= 10;
         }
         var i = 0;
         while(i < _global.inbox_xml.firstChild.childNodes.length)
         {
            var tnode = _global.inbox_xml.firstChild.childNodes[i];
            classes.Email.createEmailItem(inbox,tnode,adjW,itemH);
            if(tnode.attributes.i == classes.Email.selectedEmails[0])
            {
               if(tnode.attributes.i != classes.Email.viewedEmailID)
               {
                  classes.Email.getEmail(classes.Email.selectedEmails[0]);
               }
               else
               {
                  classes.Email.viewMail(classes.Email.viewedEmail);
               }
            }
            i++;
         }
         var j = 0;
         while(j < classes.Email.selectedEmails.length)
         {
            classes.Email.selectMail(classes.Email.selectedEmails[j]);
            j++;
         }
      }
      _context._parent.scrollerObj.refreshScroller();
   }
   static function createEmailItem(_context, xnode, cWidth, cHeight)
   {
      classes.Email.emailNum++;
      var top = _context._height;
      _context.createEmptyMovieClip("eitem" + classes.Email.emailNum,_context.getNextHighestDepth());
      _context["eitem" + classes.Email.emailNum].id = xnode.attributes.i;
      _context["eitem" + classes.Email.emailNum].num = classes.Email.emailNum;
      with(_context["eitem" + classes.Email.emailNum])
      {
         var hfrom = xnode.attributes.fu;
         var htime = xnode.attributes.d;
         var boxH = cHeight - 1;
         var boxW = cWidth;
         var timeBoxW = 30;
         var textMargin = 40;
         _context["eitem" + classes.Email.emailNum].createEmptyMovieClip("hilite",_context["eitem" + classes.Email.emailNum].getNextHighestDepth());
         with(hilite)
         {
            beginFill(16777215);
            lineTo(boxW,0);
            lineTo(boxW,boxH);
            lineTo(0,boxH);
            lineTo(0,0);
            endFill();
         }
         _context["eitem" + classes.Email.emailNum].createEmptyMovieClip("line",_context["eitem" + classes.Email.emailNum].getNextHighestDepth());
         line._y = boxH;
         with(line)
         {
            beginFill(11386329);
            lineTo(boxW,0);
            lineTo(boxW,1);
            lineTo(0,1);
            lineTo(0,0);
            endFill();
         }
         _context["eitem" + classes.Email.emailNum].createEmptyMovieClip("textLayer",_context["eitem" + classes.Email.emailNum].getNextHighestDepth());
         with(textLayer)
         {
            var tfrm = new TextFormat();
            textLayer.createTextField("fld_subj",2,textMargin,16,boxW - textMargin - 10,20);
            fld_subj.embedFonts = true;
            fld_subj.selectable = false;
            fld_subj.html = true;
            tfrm.size = 11;
            tfrm.font = "ArialBmp11";
            tfrm.kerning = true;
            fld_subj.setNewTextFormat(tfrm);
            fld_subj.text = classes.StringFuncs.unSpecialChars(xnode.attributes.s);
            if(fld_subj.maxhscroll > 0)
            {
               textLayer.createTextField("fld_ellipsis",3,fld_subj._x + fld_subj._width,fld_subj._y,20,20);
               fld_ellipsis.embedFonts = true;
               fld_ellipsis.selectable = false;
               fld_ellipsis.setNewTextFormat(tfrm);
               fld_ellipsis.text = "...";
            }
            textLayer.createTextField("fld_ts",4,boxW - timeBoxW,0,timeBoxW,30);
            fld_ts.embedFonts = true;
            fld_ts.selectable = false;
            fld_ts.autoSize = "right";
            tfrm.size = 12;
            tfrm.align = "right";
            tfrm.kerning = true;
            if(xnode.attributes.n == "1")
            {
               tfrm.font = "ArialBmp12B";
            }
            else
            {
               tfrm.font = "ArialBmp12";
            }
            fld_ts.setNewTextFormat(tfrm);
            fld_ts.htmlText = classes.Email.convertTimestamp(htime);
            textLayer.createTextField("fld_from",1,textMargin,0,boxW - textMargin - fld_ts._width,20);
            fld_from.embedFonts = true;
            fld_from.selectable = false;
            tfrm.align = "left";
            tfrm.size = 12;
            tfrm.color = 0;
            tfrm.kerning = true;
            if(xnode.attributes.n == "1")
            {
               tfrm.font = "ArialBmp12B";
            }
            else
            {
               tfrm.font = "ArialBmp12";
            }
            fld_from.setNewTextFormat(tfrm);
            fld_from.text = hfrom;
         }
         _context["eitem" + classes.Email.emailNum].attachMovie("email_icon","s_icon",_context["eitem" + classes.Email.emailNum].getNextHighestDepth());
         s_icon._x = 22;
         if(xnode.attributes.n == "1")
         {
            s_icon.read._visible = false;
            s_icon.unread._visible = true;
         }
         else
         {
            s_icon.read._visible = true;
            s_icon.unread._visible = false;
            _context["eitem" + classes.Email.emailNum].attachMovie("email_icon_read","s_icon",_context["eitem" + classes.Email.emailNum].getNextHighestDepth());
         }
         hilite.onRelease = function()
         {
            classes.Email.selectMail(id);
            classes.Email.getEmail(id);
         };
         _y = top;
      }
   }
   static function selectMail(xid)
   {
      var _listClip = classes.Email.__inboxList;
      var idNum = 0;
      classes.Email.selectedEmails[0] = xid;
      var ctWhite = new flash.geom.ColorTransform();
      ctWhite.rgb = 16777215;
      var ctBlack = new flash.geom.ColorTransform();
      ctBlack.rgb = 0;
      var ctHi = new flash.geom.ColorTransform();
      ctHi.rgb = 8375551;
      for(var each in _listClip)
      {
         if(eval("each").indexOf("eitem") > -1)
         {
            var trans = new flash.geom.Transform(_listClip[eval("each")].hilite);
            trans.colorTransform = ctWhite;
            var trans2 = new flash.geom.Transform(_listClip[eval("each")].textLayer);
            trans2.colorTransform = ctBlack;
            if(_listClip[eval("each")].id == xid)
            {
               idNum = _listClip[eval("each")].num;
            }
         }
      }
      with(_listClip["eitem" + idNum])
      {
         var tfmt = new TextFormat();
         tfmt.font = "ArialBmp12";
         textLayer.fld_from.setTextFormat(tfmt);
         textLayer.fld_ts.setTextFormat(tfmt);
         tfmt.font = "ArialBmp11";
         textLayer.fld_subj.setTextFormat(tfmt);
         var trans = new flash.geom.Transform(hilite);
         trans.colorTransform = ctHi;
         var trans2 = new flash.geom.Transform(textLayer);
         trans2.colorTransform = ctWhite;
         s_icon.unread._visible = false;
         s_icon.read._visible = true;
      }
   }
   static function getEmail(id)
   {
      if(id != classes.Email.viewedEmailID)
      {
         classes.Email.clearEmail();
         classes.Email.showRetrieveMsg();
         classes.Email.viewedEmailID = id;
         _root.getEmail(id);
      }
   }
   static function clearEmail()
   {
      with(classes.Email.__context.email.tb1.mailView)
      {
         fromLine.text = "";
         subjLine.text = "";
         msgArea.text = "";
         fld_scamWarn.removeTextField();
         delete fld_scamWarn;
         photo.removeMovieClip();
      }
   }
   static function showRetrieveMsg()
   {
      classes.Email.__context.email.tb1.mailView.msgArea.text = "\r\rRetrieving E-mail...";
   }
   static function viewMail(vnode)
   {
      classes.Email.viewedEmail = vnode;
      classes.Email.enableContextBtns(true);
      var tid = vnode.firstChild.attributes.i;
      var i = 0;
      while(i < _global.inbox_xml.firstChild.childNodes.length)
      {
         var cNode = _global.inbox_xml.firstChild.childNodes[i];
         if(cNode.attributes.i == tid)
         {
            if(cNode.attributes.n == 1)
            {
               _root.markEmailRead(tid);
               cNode.attributes.n = 0;
               classes.GlobalData.updateInfo("im","count");
            }
         }
         i++;
      }
      if(classes.Email.__context.email.tb1.mailView == undefined)
      {
         classes.Email.__context.email.tb1.createEmptyMovieClip("mailView",classes.Email.__context.email.tb1.getNextHighestDepth());
      }
      with(classes.Email.__context.email.tb1.mailView)
      {
         _x = _parent.inbxLine._x + _parent.inbxLine._width;
         _y = _parent.inbxLine._y;
         var viewAreaW = _parent._parent.bgGrad._width - 30 - _x;
         var leftSpace = 125;
         if(fld_scamWarn == undefined)
         {
            createTextField("fld_scamWarn",getNextHighestDepth(),leftSpace,4,248,50);
            fld_scamWarn.embedFonts = true;
            fld_scamWarn.selectable = false;
            fld_scamWarn.multiline = true;
            fld_scamWarn.wordWrap = true;
            var tfrm = new TextFormat();
            tfrm.size = 10;
            tfrm.font = "Arial";
            tfrm.kerning = true;
            tfrm.color = 16776960;
            fld_scamWarn.setNewTextFormat(tfrm);
            fld_scamWarn.text = "Nitto will never ask for your personal information, passwords or credit card numbers in the game.";
         }
         if(fromLine == undefined)
         {
            createTextField("fromLine",getNextHighestDepth(),leftSpace,38,viewAreaW - leftSpace,40);
            fromLine.embedFonts = true;
            var tfmt = new TextFormat();
            tfmt.font = "Arial";
            tfmt.size = 12;
            tfmt.color = 16777215;
            fromLine.setNewTextFormat(tfmt);
         }
         fromLine._width = viewAreaW - leftSpace;
         fromLine.text = "From: " + classes.StringFuncs.unSpecialChars(vnode.firstChild.attributes.fu);
         if(subjLine == undefined)
         {
            createTextField("subjLine",getNextHighestDepth(),leftSpace,55,viewAreaW - leftSpace,40);
            subjLine.embedFonts = true;
            var tfmt = new TextFormat();
            tfmt.font = "Arial";
            tfmt.bold = true;
            tfmt.size = 13;
            tfmt.color = 16777215;
            subjLine.setNewTextFormat(tfmt);
         }
         subjLine._width = viewAreaW - leftSpace;
         subjLine.text = classes.StringFuncs.unSpecialChars(vnode.firstChild.attributes.s);
         if(msgArea == undefined)
         {
            createTextField("msgArea",getNextHighestDepth(),15,90,viewAreaW - 30,_parent.inbxLine._height - 90 - 15);
            msgArea.multiline = true;
            msgArea.wordWrap = true;
            var tfmt = new TextFormat();
            tfmt.font = "Arial";
            tfmt.size = 12;
            tfmt.color = 0;
            msgArea.setNewTextFormat(tfmt);
            if(scroller == undefined)
            {
               createEmptyMovieClip("scroller",getNextHighestDepth());
               scroller.scrollerObj = new controls.ScrollBar(msgArea,_parent.viewTextHeight,_parent.viewTextWidth - 10,_parent.headH);
               scroller._visible = false;
            }
         }
         msgArea._width = viewAreaW - 30;
         msgArea._height = _parent.inbxLine._height - 90 - 15;
         msgArea.text = classes.StringFuncs.unSpecialChars(vnode.firstChild.firstChild.nodeValue);
         scroller.scrollerObj.resetScroller(_parent.viewTextHeight,_parent.viewTextWidth - 10,_parent.headH);
         setTimeout(classes.Drawing.portrait,100,_parent.mailView,vnode.firstChild.attributes.fi,1,10,7,1,true);
      }
   }
   static function convertTimestamp(ts)
   {
      var _loc4_ = "";
      var _loc6_ = ts.split(" ");
      var _loc3_ = _loc6_[0].split("/");
      var _loc2_ = _loc6_[1].split(":");
      if(_loc6_[2] == "PM" && _loc2_[0] != 12)
      {
         _loc2_[0] = Number(_loc2_[0]) + 12;
      }
      var _loc1_ = new Date(Number(_loc3_[2]),Number(_loc3_[0]) - 1,Number(_loc3_[1]),Number(_loc2_[0]),Number(_loc2_[1]),Number(_loc2_[2]));
      var _loc5_ = new Date();
      if(_loc1_.getFullYear() + _loc1_.getMonth() + _loc1_.getDate() != _loc5_.getFullYear() + _loc5_.getMonth() + _loc5_.getDate())
      {
         _loc4_ += _loc1_.getMonth() + 1 + "/" + _loc1_.getDate() + "/" + _loc1_.getFullYear().toString().substr(2,2) + " ";
      }
      var _loc7_ = classes.NumFuncs.getHoursAmPm(_loc1_.getHours());
      _loc4_ += _loc7_.hours + ":" + classes.NumFuncs.get2Mins(_loc1_.getMinutes()) + _loc7_.ampm;
      return _loc4_;
   }
   static function deleteEmail(id)
   {
      var _loc4_ = _global.inbox_xml.firstChild.childNodes.length;
      var _loc5_;
      var _loc7_;
      var _loc3_ = 0;
      while(_loc3_ < _loc4_)
      {
         if(_global.inbox_xml.firstChild.childNodes[_loc3_].attributes.i == id)
         {
            _global.inbox_xml.firstChild.childNodes[_loc3_].removeNode();
            _loc5_ = _loc3_;
            classes.Email.redrawInbox();
            break;
         }
         _loc3_ = _loc3_ + 1;
      }
      _loc4_ = _global.inbox_xml.firstChild.childNodes.length;
      if(_loc5_ >= _loc4_)
      {
         _loc5_ = _loc4_ - 1;
      }
      _loc7_ = _global.inbox_xml.firstChild.childNodes[_loc5_].attributes.i;
      classes.Email.selectedEmails[0] = undefined;
      classes.Email.clearEmail();
      _root.deleteEmail(id);
   }
}
