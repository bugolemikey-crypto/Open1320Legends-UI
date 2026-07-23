class classes.Viewer extends MovieClip
{
   var badgeArray;
   var btnMinimize;
   var btnSearchRacers;
   var btnSearchTeams;
   var btnWinDrag;
   var carID;
   var clrOverlay;
   var currentXNum;
   var goldPlate;
   var icnSearchResults;
   var idx;
   var membersArr;
   var myClr;
   var onEnterFrame;
   var reloadTeamInfo;
   var ro1;
   var ro2;
   var rptMisconductBubble;
   var scrollerContent;
   var scrollerObj;
   var sectionNum;
   var tID;
   var tabDown;
   var teamInfo;
   var tog_addbuddy;
   var tog_email;
   var tog_im;
   var tog_reportMisconduct;
   var trophyRoom;
   var tx;
   var txtResultCount;
   var txtStats;
   var ty;
   var uCred;
   var uID;
   var uName;
   var uTID;
   var uTname;
   var userInfo;
   static var _MC;
   static var __MC;
   static var curSearchPage;
   static var showingSearchType;
   static var totalSearchPages;
   static var viewBuddiesXML;
   static var viewCarsXML;
   static var viewRemarksXML;
   static var viewTeamXML;
   static var viewXML;
   var txtSearch = "";
   var txtPagingNav = "";
   var searchTerm = "";
   var x3 = 597;
   var x4 = 705;
   function Viewer()
   {
      super();
      classes.Viewer.__MC = this;
      classes.Viewer._MC = this;
      this.cacheAsBitmap = true;
      this.myClr = new Color(this.clrOverlay);
      this.paintOverlay("090b0c");
      if(this.tabDown.modernAccent == undefined)
      {
         this.tabDown.createEmptyMovieClip("modernAccent",this.tabDown.getNextHighestDepth());
         classes.Drawing.rect(this.tabDown.modernAccent,this.tabDown._width,3,16726051,100,0,this.tabDown._height - 3);
      }
      if(this.snavDown.modernAccent == undefined)
      {
         this.snavDown.createEmptyMovieClip("modernAccent",this.snavDown.getNextHighestDepth());
         classes.Drawing.rect(this.snavDown.modernAccent,3,this.snavDown._height,16726051,100,0,0);
      }
      this.ro1._visible = false;
      this.ro2._visible = false;
      this.profileElementsVisibility(false);
      this.initSearchPage();
      var _loc4_ = 1;
      this.btnWinDrag.onPress = function()
      {
         classes.Viewer._MC.swapDepths(classes.Viewer._MC._parent.getNextHighestDepth());
         classes.Viewer._MC.startDrag(false);
      };
      this.btnWinDrag.onRelease = this.btnWinDrag.onReleaseOutside = function()
      {
         classes.Viewer._MC.stopDrag();
      };
      this.btnWinDrag.useHandCursor = false;
      this.btnMinimize.onRelease = function()
      {
         classes.Control.dockViewer();
      };
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 112;
         this.scrollerContent._y = 192;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,646,241,null,307,761,131);
      }
      if(this.uID)
      {
         classes.Lookup.addCallback("getUser",this,this.CB_getUser,String(this.uID));
         _root.getUser(this.uID);
      }
      else if(this.tID)
      {
         this.goSection(3);
      }
      else
      {
         this.goSearch();
      }
   }
   function CB_getUser(d)
   {
      trace("CB_getUser");
      classes.Viewer.__MC.initUser(d);
   }
   function profileElementsVisibility(vis)
   {
      this.tog_im._visible = vis;
      this.tog_email._visible = vis;
      this.tog_addbuddy._visible = vis;
      this.tog_reportMisconduct._visible = vis;
      this.tabDown._visible = vis;
      this.ro1._visible = vis;
      this.ro2._visible = vis;
   }
   function initUser(d)
   {
      classes.Viewer.viewXML = new XML(d);
      this.uID = classes.Viewer.viewXML.firstChild.firstChild.attributes.i;
      this.uTID = Number(classes.Viewer.viewXML.firstChild.firstChild.attributes.ti);
      this.uTname = classes.Viewer.viewXML.firstChild.firstChild.attributes.tn;
      this.uName = classes.Viewer.viewXML.firstChild.firstChild.attributes.u;
      this.uCred = classes.Viewer.viewXML.firstChild.firstChild.attributes.sc;
      if(Number(classes.Viewer.viewXML.firstChild.firstChild.attributes.w) > -1)
      {
         this.txtStats = "Wins: " + classes.Viewer.viewXML.firstChild.firstChild.attributes.w + "    Losses: " + classes.Viewer.viewXML.firstChild.firstChild.attributes.l;
      }
      else
      {
         this.txtStats = "win/loss stats available with membership";
      }
      if(classes.Viewer.viewXML.firstChild.firstChild.attributes.bg.length)
      {
         this.paintOverlay(classes.Viewer.viewXML.firstChild.firstChild.attributes.bg);
      }
      var _loc3_;
      if(this.userInfo.uID != this.uID)
      {
         this.userInfo.removeMovieClip();
         _loc3_ = this.attachMovie("userInfo","userInfo",this.getNextHighestDepth(),{_x:28,_y:89,uID:this.uID,uName:this.uName,tID:this.uTID,tName:this.uTname,uCred:this.uCred,showBadgesXML:new XML(classes.Viewer.viewXML.firstChild.firstChild.toString())});
         _loc3_.cacheAsBitmap = true;
      }
      var _loc2_ = 1;
      while(_loc2_ <= 2)
      {
         classes.Effects.roBump(classes.Viewer.__MC["ro" + _loc2_]);
         classes.Viewer.__MC["ro" + _loc2_].idx = _loc2_;
         classes.Viewer.__MC["ro" + _loc2_]._visible = true;
         classes.Viewer.__MC["ro" + _loc2_].onRelease = function()
         {
            if(classes.Control.serverAvail())
            {
               this._parent.goSection(this.idx);
            }
         };
         _loc2_ = _loc2_ + 1;
      }
      this.initProfileButtons();
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 112;
         this.scrollerContent._y = 192;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,646,241,null,307,761,131);
      }
      this.goSection(this.sectionNum);
   }
   function initProfileButtons()
   {
      this.tog_im._visible = true;
      this.tog_email._visible = true;
      this.tog_addbuddy._visible = true;
      this.tog_reportMisconduct._visible = true;
      this.rptMisconductBubble._visible = false;
      classes.Effects.roBounce(this.tog_im);
      classes.Effects.roBounce(this.tog_email);
      classes.Effects.roBounce(this.tog_addbuddy);
      classes.Effects.roBounce(this.tog_reportMisconduct);
      this.tog_im.onRelease = function()
      {
         classes.Control.focusNim(this._parent.uID);
      };
      this.tog_email.onRelease = function()
      {
         classes.Control.focusEmail(this._parent.uName);
      };
      this.tog_addbuddy.onRelease = function()
      {
         _root.inquiryNimUser(this._parent.uName,this._parent.uID);
      };
      this.tog_reportMisconduct.onRelease = function()
      {
         var _loc2_ = classes.SupportCenter.USER_TYPE;
         var _loc3_ = classes.SupportCenter.USER;
         if(classes.GlobalData.role == 1 || classes.GlobalData.role == 8)
         {
            _loc3_ = classes.SupportCenter.MOD;
            _loc2_ = classes.SupportCenter.SENIOR_MOD_TYPE;
         }
         else if(classes.GlobalData.role == 2)
         {
            _loc3_ = classes.SupportCenter.MOD;
            _loc2_ = classes.SupportCenter.MOD_TYPE;
         }
         if(_loc3_ == classes.SupportCenter.MOD)
         {
            trace("viewer, selected id: " + this._parent.uID);
            classes.Control.focusModTools(_loc2_,classes.data.SupportCenterData.USER_DETAILS,this._parent.uName,this._parent.uID);
         }
         else
         {
            classes.Control.focusSupportCenter(_loc2_,classes.data.SupportCenterData.REPORT_MISCONDUCT,this._parent.uName);
         }
      };
   }
   function clearUser()
   {
      trace("clearUser");
      this.paintOverlay();
      this.userInfo.removeMovieClip();
      this.teamInfo.removeMovieClip();
      for(var _loc2_ in this.scrollerContent)
      {
         this.scrollerContent[_loc2_].removeMovieClip();
      }
      classes.Viewer.__MC.scrollerObj.setScrollToTop();
   }
   function goSection(idx)
   {
      trace("goSection: " + idx);
      this.txtSearch = "";
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      this.reloadTeamInfo = true;
      this.scrollerContent.clear();
      this.scrollerContent._x = 112;
      this.scrollerContent._y = 192;
      this.scrollerObj.resetMask(this.scrollerContent._x,this.scrollerContent._y,646,241);
      if(idx != 3 && idx != 4)
      {
         this.teamInfo.removeMovieClip();
         delete this.teamInfo;
         if(idx == 1 || idx == 2)
         {
            classes.Viewer.__MC.tabDown._visible = true;
            classes.Viewer.__MC.tabDown.tx = classes.Viewer.__MC["ro" + idx]._x;
            classes.Viewer.__MC.tabDown.onEnterFrame = function()
            {
               this._x += (this.tx - this._x) / 3;
               if(Math.abs(this.tx - this._x) < 0.1)
               {
                  delete this.onEnterFrame;
               }
            };
         }
      }
      else
      {
         if(idx == 3)
         {
            this.teamInfo.removeMovieClip();
            trace("__MC.tabDown._x");
            trace(classes.Viewer.__MC.tabDown._x);
            this.currentXNum = this.x3;
            if(classes.Viewer.__MC.tabDown._x != this.x4)
            {
               classes.Viewer.__MC.tabDown._x = this.x3;
            }
            else
            {
               this.reloadTeamInfo = false;
            }
         }
         else
         {
            this.currentXNum = this.x4;
         }
         classes.Viewer.__MC.tabDown._visible = true;
         classes.Viewer.__MC.tabDown.tx = this.currentXNum;
         classes.Viewer.__MC.tabDown.onEnterFrame = function()
         {
            this._x += (this.tx - this._x) / 3;
            if(Math.abs(this.tx - this._x) < 0.1)
            {
               trace("stuff: " + this._x);
               this._x = this.tx;
               delete this.onEnterFrame;
            }
         };
      }
      trace("tabDown._x");
      trace(classes.Viewer.__MC.tabDown._x);
      switch(idx)
      {
         case 0:
            classes.Control.serverUnlock();
            this.gotoAndStop(1);
            this.scrollerObj.setScrollToTop();
            break;
         case 1:
            this.gotoAndPlay("garage");
            this.scrollerObj.setScrollToTop();
            this.initProfileButtons();
            break;
         case 2:
            this.gotoAndPlay("profile");
            this.scrollerObj.setScrollToTop();
            this.initProfileButtons();
            break;
         case 3:
            this.goTeam();
            break;
         case 4:
            this.goTeamTrophies();
         default:
            return;
      }
   }
   function goProfilePage(idx)
   {
      classes.Viewer.__MC.selSnav = idx;
      classes.Viewer.__MC.snavDown.onEnterFrame = function()
      {
         this.ty = this._parent["snav" + idx]._y;
         this._y += (this.ty - this._y) / 3;
         if(Math.abs(this.ty - this._y) < 0.1)
         {
            this._y = this.ty;
            delete this.onEnterFrame;
         }
      };
      this.clearProfileContentAll();
      switch(idx)
      {
         case 1:
            trace("my buddies!");
            if(this.scrollerContent.remarkMC == undefined)
            {
               classes.Remark(this.scrollerContent.attachMovie("Remark","remarkMC",this.scrollerContent.getNextHighestDepth(),{_x:360,_y:8}));
               _root.getUserRemarks(this.uID);
            }
            _root.getUserBuddies(this.uID);
            break;
         case 2:
            this.gotoAndStop("trophies");
            trace(this.scrollerContent.remarkMC);
            this.trophyRoom = new classes.TrophyRoom();
            trace(classes.HomeProfile._MC);
            trace(classes.HomeProfile._MC._parent.userInfo);
            trace(this.userInfo);
            this.trophyRoom.init(classes.UserInfo(this.userInfo),this.scrollerObj,this.scrollerContent,4,2,false,false,37,-10);
            this.trophyRoom.badgeIntervalID = setInterval(this.trophyRoom,"drawBadges",100);
         default:
            return;
      }
   }
   function goSearch()
   {
      trace("goSearch");
      this.clearProfileContent();
      this.profileElementsVisibility(false);
      this.initSearchPage();
      this.gotoAndPlay("search");
   }
   function goTeam()
   {
      trace("goTeam");
      this.clearProfileContent();
      this.profileElementsVisibility(false);
      this.tabDown._visible = true;
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      this.scrollerContent._x = 74;
      classes.Viewer.__MC.scrollerObj.resetMask(this.scrollerContent._x,null,662);
      trace("goto team");
      this.gotoAndPlay("team"); //unpopped
      var _loc2_ = 3;
      while(_loc2_ <= 4)
      {
         trace("bumpers:");
         trace(classes.Viewer.__MC["ro" + _loc2_]);
         classes.Effects.roBump(classes.Viewer.__MC["ro" + _loc2_]);
         classes.Viewer.__MC["ro" + _loc2_].idx = _loc2_;
         classes.Viewer.__MC["ro" + _loc2_]._visible = true;
         classes.Viewer.__MC["ro" + _loc2_].onRelease = function()
         {
            trace("onRelease!");
            this._parent.goSection(this.idx);
         };
         _loc2_ = _loc2_ + 1;
      }
   }
   function goTeamTrophies()
   {
      trace("goTeamTrophies");
      this.gotoAndStop("teamTrophies"); //unpopped
      trace(this.teamInfo);
      this.teamInfo.swapDepths(this.getNextHighestDepth());
      var _loc3_ = 163;
      var _loc2_ = classes.Viewer.viewTeamXML.firstChild.firstChild.attributes;
      this.goldPlate.txtField.text = _loc2_.n;
      this.drawBadges(classes.Viewer.viewTeamXML);
   }
   function drawBadges(bxml)
   {
      this.badgeArray = new Array();
      var _loc4_;
      trace("bxml: ");
      trace(bxml);
      var _loc2_ = 0;
      while(_loc2_ < bxml.firstChild.firstChild.childNodes.length)
      {
         trace(bxml.firstChild.firstChild.childNodes[_loc2_].nodeName);
         if(bxml.firstChild.firstChild.childNodes[_loc2_].nodeName == "b")
         {
            trace("found badge!");
            _loc4_ = bxml.firstChild.firstChild.childNodes[_loc2_].attributes;
            this.badgeArray.push(_loc4_);
         }
         _loc2_ = _loc2_ + 1;
      }
      this.drawMyBadges(1);
   }
   function drawMyBadges(pg)
   {
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._y = 205;
         this.scrollerContent._x = 162;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,693,394,null,467,694,0);
      }
      this.scrollerContent._x = 131;
      this.scrollerContent._y = 176;
      this.scrollerObj.resetMask(this.scrollerContent._x,this.scrollerContent._y,646,500);
      trace(this.scrollerContent);
      pg = Number(pg);
      trace("drawMyBadges(" + pg + ")");
      this.scrollerObj.setScrollToTop();
      this.scrollerContent.badgesGroup.removeMovieClip();
      this.scrollerContent.createEmptyMovieClip("badgesGroup",this.scrollerContent.getNextHighestDepth());
      var _loc20_ = 157;
      var _loc19_ = 113;
      var _loc12_ = 4;
      var _loc23_ = 2;
      var _loc10_ = (pg - 1) * _loc12_ * _loc23_;
      var _loc21_ = Math.min(_loc12_ * _loc23_,this.badgeArray.length - _loc10_);
      var _loc14_;
      var _loc13_;
      var _loc3_ = 0;
      var _loc5_;
      var _loc8_;
      var _loc16_;
      var _loc4_;
      var _loc7_;
      var _loc6_;
      var _loc11_;
      var _loc9_;
      while(_loc3_ < _loc21_)
      {
         _loc14_ = _loc3_ % _loc12_ * _loc20_;
         _loc13_ = Math.floor(_loc3_ / _loc12_) * _loc19_;
         _loc5_ = Number(this.badgeArray[_loc3_ + _loc10_].i);
         _loc8_ = Number(this.badgeArray[_loc3_ + _loc10_].n);
         _loc16_ = Number(this.badgeArray[_loc3_ + _loc10_].v);
         this.scrollerContent.badgesGroup.attachMovie("_blank","badge" + _loc3_,this.scrollerContent.badgesGroup.getNextHighestDepth(),{_x:_loc14_,_y:_loc13_,id:_loc5_});
         _loc4_ = this.scrollerContent.badgesGroup["badge" + _loc3_];
         _loc4_.attachBitmap(_root.badgesHolder.arrBmpLarge[_loc5_],_loc4_.getNextHighestDepth());
         trace("badgeMovie: " + _loc4_);
         trace("badgeMovieParent: " + _loc4_._parent);
         trace("badgeMovieXY: " + _loc4_._x + " " + _loc4_._y);
         trace("badge bitmap: " + _root.badgesHolder.arrBmpLarge[_loc5_]);
         trace("badgeNumber: " + _loc5_);
         if(_loc8_ > 1)
         {
            _loc7_ = _loc4_.createTextField("count",2,75,5,24,20);
            _loc6_ = new TextFormat();
            _loc6_.font = "Arial";
            _loc6_.size = 10;
            _loc6_.color = 16777215;
            _loc6_.align = "right";
            _loc7_.embedFonts = true;
            _loc7_.autoSize = "right";
            _loc7_.setNewTextFormat(_loc6_);
            _loc7_.text = String(_loc8_);
         }
         _loc11_ = classes.Lookup.badgeAltText(_loc5_);
         _loc9_ = classes.Lookup.badgeAltDescription(_loc5_);
         trace("badgeDescription: " + _loc9_);
         classes.Help.addAltTag2(_loc4_,_loc11_,_loc9_);
         _loc3_ = _loc3_ + 1;
      }
      this.drawBadgePaging(pg);
   }
   function drawBadgePaging(curPage, setNum)
   {
      var badgesPerPage = 8;
      var pages = Math.ceil(this.badgeArray.length / badgesPerPage);
      this.scrollerContent.badgesGroup.pagingGroup.removeMovieClip();
      this.scrollerContent.badgesGroup.attachMovie("_blank","pagingGroup",this.scrollerContent.badgesGroup.getNextHighestDepth(),{_x:0,_y:242});
      with(this.scrollerContent.badgesGroup.pagingGroup)
      {
         var tf = new TextFormat();
         tf.font = "Arial";
         tf.size = 10.7;
         tf.bold = true;
         createEmptyMovieClip("fldPrev",getNextHighestDepth());
         fldPrev.createTextField("fld",fldPrev.getNextHighestDepth(),0,0,10,20);
         fldPrev.fld.selectable = false;
         fldPrev.fld.embedFonts = true;
         fldPrev.fld.autoSize = true;
         if(curPage != 1)
         {
            tf.color = 16777215;
            fldPrev.gotoPage = curPage - 1;
            fldPrev.onRelease = function()
            {
               classes.Viewer._MC.drawMyBadges(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         fldPrev.fld.setNewTextFormat(tf);
         fldPrev.fld.text = "Prev";
         createEmptyMovieClip("fldNext",getNextHighestDepth());
         fldNext._x = 175;
         fldNext.createTextField("fld",getNextHighestDepth(),0,0,10,20);
         fldNext.fld.selectable = false;
         fldNext.fld.embedFonts = true;
         fldNext.fld.autoSize = true;
         if(curPage != pages)
         {
            tf.color = 16777215;
            fldNext.gotoPage = curPage + 1;
            fldNext.onRelease = function()
            {
               classes.Viewer._MC.drawMyBadges(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         fldNext.fld.setNewTextFormat(tf);
         fldNext.fld.text = "Next";
         tf.color = 16777215;
         createTextField("fldPaging",getNextHighestDepth(),93,0,10,20);
         fldPaging.selectable = false;
         fldPaging.embedFonts = true;
         fldPaging.html = true;
         fldPaging.autoSize = "center";
         fldPaging.setNewTextFormat(tf);
         var j = 1;
         while(j <= pages)
         {
            if(j == curPage)
            {
               fldPaging.htmlText += j + " ";
            }
            else
            {
               fldPaging.htmlText += "<a href=\"asfunction:classes.Viewer._MC.drawMyBadges," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
      this.scrollerContent.badgesGroup.pagingGroup._x = 182;
   }
   function clearProfileContent()
   {
      for(var _loc2_ in this.scrollerContent)
      {
         if(_loc2_ != "remarkMC")
         {
            this.scrollerContent[_loc2_].removeMovieClip();
         }
      }
   }
   function clearProfileContentAll()
   {
      for(var _loc2_ in this.scrollerContent)
      {
         this.scrollerContent[_loc2_].removeMovieClip();
      }
   }
   function drawTeam(txml)
   {
      var _loc5_ = txml.firstChild.firstChild.attributes;
      var _loc7_ = this.attachMovie("teamInfo","teamInfo",this.getNextHighestDepth(),{_x:28,_y:89,tID:_loc5_.i,tName:_loc5_.n,tCred:_loc5_.sc,teamXML:classes.Viewer.viewTeamXML});
      _loc7_.cacheAsBitmap = true;
      var _loc6_ = txml.firstChild.firstChild.attributes;
      this.txtStats = "Wins: " + _loc6_.tw + "    " + "Losses: " + _loc6_.tl;
      this.paintOverlay(_loc5_.bg);
      var _loc4_ = {_x:23};
      _loc4_.txtCreateDate = _loc5_.de.substr(0,_loc5_.de.indexOf(" "));
      _loc4_.txtTeamFunds = "$" + _loc5_.tf;
      _loc4_.txtMsg = _loc5_.lc;
      var _loc2_ = 0;
      while(_loc2_ < txml.firstChild.firstChild.childNodes.length)
      {
         if(txml.firstChild.firstChild.childNodes[_loc2_].attributes.tr == 1)
         {
            _loc4_.leaderID = txml.firstChild.firstChild.childNodes[_loc2_].attributes.i;
            _loc4_.leaderName = txml.firstChild.firstChild.childNodes[_loc2_].attributes.un;
            _loc4_.leaderSC = txml.firstChild.firstChild.childNodes[_loc2_].attributes.sc;
            _loc4_.leaderET = txml.firstChild.firstChild.childNodes[_loc2_].attributes.et;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      _loc7_ = this.scrollerContent.attachMovie("viewerTeamInfo1","teamInfo1",this.scrollerContent.getNextHighestDepth(),_loc4_);
      _loc7_.cacheAsBitmap = true;
      this.drawTeamMembers(1);
      this.scrollerObj.setScrollToTop();
   }
   function drawTeamMembers(pg)
   {
      if(!pg)
      {
         pg = 1;
      }
      var txml = classes.Viewer.viewTeamXML;
      this.scrollerContent.membersGroup.removeMovieClip();
      this.scrollerContent.attachMovie("_blank","membersGroup",this.scrollerContent.getNextHighestDepth(),{_x:440});
      var xSpacing = 77;
      var ySpacing = 62;
      var cols = 3;
      var rows = 3;
      var countOffset = (pg - 1) * cols * rows;
      var tArr = new Array();
      var i = 0;
      while(i < txml.firstChild.firstChild.childNodes.length)
      {
         if(Number(txml.firstChild.firstChild.childNodes[i].attributes.tr) > 1)
         {
            tArr.push(txml.firstChild.firstChild.childNodes[i].attributes);
         }
         i++;
      }
      tArr.sortOn(["tr","sc","un"],[1,Array.DESCENDING,1]);
      this.membersArr = new Array();
      var j = 0;
      i = 0;
      while(i < tArr.length)
      {
         this.membersArr[j] = tArr[i];
         if(this.membersArr[j].tr != 4)
         {
            j += cols;
         }
         else
         {
            j += 1;
         }
         i++;
      }
      var lim = Math.min(cols * rows,this.membersArr.length - countOffset);
      var tf = new TextFormat();
      tf.font = "Arial";
      tf.size = 8;
      tf.color = 16777215;
      var isBig;
      var tItem;
      var tET;
      var xPos;
      var yPos = 0;
      i = 0;
      while(i < lim)
      {
         if(i && i % 3 == 0)
         {
            yPos += ySpacing;
         }
         isBig = Boolean(this.membersArr[i + countOffset].tr != 4);
         xPos = i % cols * xSpacing;
         if(this.membersArr[i + countOffset].tr == 2 && !this.scrollerContent.membersGroup.headCoLeader)
         {
            classes.Drawing.standardText(this.scrollerContent.membersGroup,"headCoLeader","Co-Leaders:",-10,yPos,80,"right");
            yPos += 10;
         }
         else if(this.membersArr[i + countOffset].tr == 3 && !this.scrollerContent.membersGroup.headDealer)
         {
            classes.Drawing.standardText(this.scrollerContent.membersGroup,"headDealer","Dealers:",-10,yPos,80,"right");
            yPos += 10;
         }
         else if(this.membersArr[i + countOffset].tr == 4 && !this.scrollerContent.membersGroup.headMembers)
         {
            classes.Drawing.standardText(this.scrollerContent.membersGroup,"headMembers","Members:",-10,yPos,80,"right");
            yPos += 10;
         }
         this.scrollerContent.membersGroup.attachMovie("_blank","member" + i,this.scrollerContent.membersGroup.getNextHighestDepth(),{_x:xPos,_y:yPos,id:this.membersArr[i + countOffset].i,un:this.membersArr[i + countOffset].un});
         if(isBig)
         {
            tItem = this.scrollerContent.membersGroup["member" + i].attachMovie("userInfo50","userInfo",1,{scale:50,uID:this.membersArr[i + countOffset].i,uName:this.membersArr[i + countOffset].un,uCred:this.membersArr[i + countOffset].sc});
            tET = Number(this.membersArr[i + countOffset].et);
            tItem.fldTitleET.text = "BEST AVG ET:";
            tItem.fldET.text = tET <= 0 ? "N/A" : classes.NumFuncs.zeroFill(Math.round(tET * 1000) / 1000,3);
            tItem.fldOwnership.text = this.membersArr[i + countOffset].po + "% owner : $" + this.membersArr[i + countOffset].fu;
            tItem.cacheAsBitmap = true;
            i += 3;
         }
         else
         {
            this.scrollerContent.membersGroup["member" + i].attachMovie("_blank","pic",1,{_xscale:50,_yscale:50});
            classes.Drawing.portrait(this.scrollerContent.membersGroup["member" + i].pic,this.scrollerContent.membersGroup["member" + i].id,1,0,0,2);
            with(this.scrollerContent.membersGroup["member" + i])
            {
               pic.onRelease = function()
               {
                  classes.Control.focusViewer(this._parent.id);
               };
               createTextField("uname",2,-2,_height + 1,_width + 20,30);
               uname.selectable = false;
               uname.embedFonts = true;
               uname.autoSize = true;
               uname.antiAliasType = "advanced";
               uname.setNewTextFormat(tf);
               uname.text = un;
            }
            i += 1;
         }
      }
      if(this.membersArr.length)
      {
         this.drawTeamMembersPaging(pg,yPos + ySpacing);
      }
   }
   function drawTeamMembersPaging(curPage, yPos)
   {
      var membersPerPage = 9;
      var pages = Math.ceil(this.membersArr.length / membersPerPage);
      yPos = Math.max(yPos,207);
      this.scrollerContent.membersGroup.pagingGroup.removeMovieClip();
      this.scrollerContent.membersGroup.attachMovie("_blank","pagingGroup",this.scrollerContent.membersGroup.getNextHighestDepth(),{_x:-50,_y:yPos});
      with(this.scrollerContent.membersGroup.pagingGroup)
      {
         var tf = new TextFormat();
         tf.font = "Arial";
         tf.size = 10.7;
         tf.bold = true;
         createEmptyMovieClip("fldPrev",getNextHighestDepth());
         if(curPage != 1)
         {
            tf.color = 16777215;
            fldPrev.gotoPage = Number(curPage) - 1;
            fldPrev.onRelease = function()
            {
               classes.Viewer.__MC.drawTeamMembers(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         classes.Drawing.standardText(fldPrev,"fld","Prev",0,0,100,"left",tf);
         createEmptyMovieClip("fldNext",getNextHighestDepth());
         fldNext._x = 245;
         if(curPage != pages)
         {
            tf.color = 16777215;
            fldNext.gotoPage = Number(curPage) + 1;
            fldNext.onRelease = function()
            {
               classes.Viewer.__MC.drawTeamMembers(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         classes.Drawing.standardText(fldNext,"fld","Next",0,0,100,"left",tf);
         tf.color = 16777215;
         classes.Drawing.standardText(_parent.pagingGroup,"fldPaging","",122,0,100,"center",tf);
         fldPaging.html = true;
         var j = 1;
         while(j <= pages)
         {
            if(j == curPage)
            {
               fldPaging.htmlText += j + " ";
            }
            else
            {
               fldPaging.htmlText += "<a href=\"asfunction:classes.Viewer.__MC.drawTeamMembers," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
   }
   function drawBuddies(pg)
   {
      pg = Number(pg);
      if(!pg)
      {
         pg = 1;
      }
      this.clearProfileContent();
      this.scrollerContent.attachMovie("_blank","buddiesGroup",this.scrollerContent.getNextHighestDepth(),{_x:40,_y:5});
      trace(this.scrollerContent.buddiesGroup);
      var xSpacing = 77;
      var ySpacing = 62;
      var cols = 4;
      var rows = 3;
      var countOffset = (pg - 1) * cols * rows;
      var lim = Math.min(cols * rows,classes.Viewer.viewBuddiesXML.firstChild.childNodes.length - countOffset);
      var xPos;
      var yPos;
      var i = 0;
      while(i < lim)
      {
         xPos = i % cols * xSpacing;
         yPos = Math.floor(i / cols) * ySpacing;
         this.scrollerContent.buddiesGroup.attachMovie("_blank","buddy" + i,this.scrollerContent.buddiesGroup.getNextHighestDepth(),{_x:xPos,_y:yPos,id:classes.Viewer.viewBuddiesXML.firstChild.childNodes[i + countOffset].attributes.i});
         this.scrollerContent.buddiesGroup["buddy" + i].attachMovie("_blank","pic",1,{_xscale:50,_yscale:50});
         classes.Drawing.portrait(this.scrollerContent.buddiesGroup["buddy" + i].pic,this.scrollerContent.buddiesGroup["buddy" + i].id,1,0,0,2);
         with(this.scrollerContent.buddiesGroup["buddy" + i])
         {
            pic.onRelease = function()
            {
               classes.Control.focusViewer(this._parent.id);
            };
            createTextField("uname",2,-2,_height + 1,_width + 20,30);
            uname.selectable = false;
            uname.embedFonts = true;
            uname.autoSize = true;
            uname.antiAliasType = "advanced";
            var tf = new TextFormat();
            tf.font = "Arial";
            tf.size = 8;
            tf.color = 16777215;
            uname.setNewTextFormat(tf);
            uname.text = classes.Viewer.viewBuddiesXML.firstChild.childNodes[i + countOffset].attributes.n;
         }
         i++;
      }
      this.drawBuddyPaging(pg);
   }
   function drawBuddyPaging(curPage, setNum)
   {
      var buddiesPerPage = 12;
      var pages = Math.ceil(classes.Viewer.viewBuddiesXML.firstChild.childNodes.length / buddiesPerPage);
      this.scrollerContent.buddiesGroup.pagingGroup.removeMovieClip();
      this.scrollerContent.buddiesGroup.attachMovie("_blank","pagingGroup",this.scrollerContent.buddiesGroup.getNextHighestDepth(),{_x:0,_y:190});
      with(this.scrollerContent.buddiesGroup.pagingGroup)
      {
         var tf = new TextFormat();
         tf.font = "Arial";
         tf.size = 10.7;
         tf.bold = true;
         createEmptyMovieClip("fldPrev",getNextHighestDepth());
         fldPrev.createTextField("fld",fldPrev.getNextHighestDepth(),0,0,10,20);
         fldPrev.fld.selectable = false;
         fldPrev.fld.embedFonts = true;
         fldPrev.fld.autoSize = true;
         if(curPage != 1)
         {
            tf.color = 16777215;
            fldPrev.gotoPage = Number(curPage) - 1;
            fldPrev.onRelease = function()
            {
               classes.Viewer.__MC.drawBuddies(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         fldPrev.fld.setNewTextFormat(tf);
         fldPrev.fld.text = "Prev";
         createEmptyMovieClip("fldNext",getNextHighestDepth());
         fldNext._x = 245;
         fldNext.createTextField("fld",getNextHighestDepth(),0,0,10,20);
         fldNext.fld.selectable = false;
         fldNext.fld.embedFonts = true;
         fldNext.fld.autoSize = true;
         if(curPage != pages)
         {
            tf.color = 16777215;
            fldNext.gotoPage = Number(curPage) + 1;
            fldNext.onRelease = function()
            {
               classes.Viewer.__MC.drawBuddies(this.gotoPage);
            };
         }
         else
         {
            tf.color = 10263708;
         }
         fldNext.fld.setNewTextFormat(tf);
         fldNext.fld.text = "Next";
         tf.color = 16777215;
         createTextField("fldPaging",getNextHighestDepth(),122,0,10,20);
         fldPaging.selectable = false;
         fldPaging.embedFonts = true;
         fldPaging.html = true;
         fldPaging.autoSize = "center";
         fldPaging.setNewTextFormat(tf);
         var j = 1;
         while(j <= pages)
         {
            if(j == curPage)
            {
               fldPaging.htmlText += j + " ";
            }
            else
            {
               fldPaging.htmlText += "<a href=\"asfunction:classes.Viewer.__MC.drawBuddies," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
   }
   function initSearchPage()
   {
      this.icnSearchResults._visible = false;
      this.btnSearchRacers.onRelease = function()
      {
         this._parent.presetSearch();
         this._parent.txtSearchTitle = "Search Results: Racers";
         classes.Lookup.addCallback("racerSearch",this._parent,this._parent.CB_searchRacers,"");
         _root.racerSearch(this._parent.searchTerm);
      };
      this.btnSearchTeams.onRelease = function()
      {
         this._parent.presetSearch();
         this._parent.txtSearchTitle = "Search Results: Teams";
         classes.Lookup.addCallback("teamSearch",this._parent,this._parent.CB_searchTeams,"");
         _root.teamSearch(this._parent.searchTerm);
      };
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 112;
         this.scrollerContent._y = 131;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,685,307,null,null,761,131);
      }
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      this.scrollerContent._x = 112;
      classes.Viewer.__MC.scrollerObj.resetMask(this.scrollerContent._x,null,685);
      this.searchMessage("Search for Racers or Teams above.");
   }
   function presetSearch()
   {
      delete this.tID;
      delete this.uID;
      delete this.carID;
      this.profileElementsVisibility(false);
      this.paintOverlay();
      this.gotoAndPlay("search");
      this.txtResultCount = "";
      this.txtPagingNav = "";
      this.searchTerm = this.txtSearch;
      this.icnSearchResults._visible = true;
      classes.ClipFuncs.removeAllClips(this);
   }
   function CB_searchTeams(d)
   {
      var _loc2_ = new XML(d);
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 112;
         this.scrollerContent._y = 131;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,685,307,null,null,761,131);
      }
      if(_loc2_.firstChild.childNodes.length)
      {
         this.displaySearchResults(_loc2_,"teams");
      }
      else
      {
         this.displaySearchEmpty();
      }
   }
   function CB_searchRacers(d)
   {
      var _loc2_ = new XML(d);
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 112;
         this.scrollerContent._y = 131;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,685,307,null,null,761,131);
      }
      if(_loc2_.firstChild.childNodes.length)
      {
         this.displaySearchResults(_loc2_,"racers");
      }
      else
      {
         this.displaySearchEmpty();
      }
   }
   static function searchJumpBack(step)
   {
      step = Number(step);
      var _loc2_ = Math.max(1,classes.Viewer.curSearchPage - step);
      if(classes.Viewer.showingSearchType == "racers")
      {
         classes.Lookup.addCallback("racerSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchRacers,"");
         _root.racerSearch(classes.Viewer._MC.searchTerm,_loc2_);
      }
      else if(classes.Viewer.showingSearchType == "teams")
      {
         classes.Lookup.addCallback("teamSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchTeams,"");
         _root.teamSearch(classes.Viewer._MC.searchTerm,_loc2_);
      }
   }
   static function searchJumpForward(step)
   {
      step = Number(step);
      trace("searchJumpForward: " + step);
      var _loc3_ = Math.min(classes.Viewer.totalSearchPages,classes.Viewer.curSearchPage + step);
      trace("npage: " + classes.Viewer.totalSearchPages + ", " + (classes.Viewer.curSearchPage + step));
      if(classes.Viewer.showingSearchType == "racers")
      {
         classes.Lookup.addCallback("racerSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchRacers,"");
         _root.racerSearch(classes.Viewer._MC.searchTerm,_loc3_);
      }
      else if(classes.Viewer.showingSearchType == "teams")
      {
         classes.Lookup.addCallback("teamSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchTeams,"");
         _root.teamSearch(classes.Viewer._MC.searchTerm,_loc3_);
      }
   }
   static function searchJumpTo(page)
   {
      page = Number(page);
      if(classes.Viewer.showingSearchType == "racers")
      {
         classes.Lookup.addCallback("racerSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchRacers,"");
         _root.racerSearch(classes.Viewer._MC.searchTerm,page);
      }
      else if(classes.Viewer.showingSearchType == "teams")
      {
         classes.Lookup.addCallback("teamSearch",classes.Viewer._MC,classes.Viewer._MC.CB_searchTeams,"");
         _root.teamSearch(classes.Viewer._MC.searchTerm,page);
      }
   }
   function displaySearchResults(pNode, searchType)
   {
      classes.Viewer.showingSearchType = searchType;
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      this.scrollerContent.clear();
      classes.Viewer._MC.scrollerObj.setScrollToTop();
      this.profileElementsVisibility(false);
      this.ro1._visible = false;
      this.ro2._visible = false;
      this.paintOverlay();
      var _loc9_ = Number(pNode.firstChild.attributes.c);
      var _loc7_ = Number(pNode.firstChild.childNodes.length);
      classes.Viewer.totalSearchPages = Math.ceil(_loc9_ / 20);
      classes.Viewer.curSearchPage = Number(pNode.firstChild.attributes.p);
      var _loc4_ = 30;
      this.txtResultCount = "Your search returned " + _loc9_;
      if(_loc9_ > 1)
      {
         this.txtResultCount += " matches";
      }
      else
      {
         this.txtResultCount += " match";
      }
      this.txtResultCount += " for \'" + this.searchTerm + "\'";
      this.txtPagingNav = "";
      if(classes.Viewer.curSearchPage > 1)
      {
         this.txtPagingNav += "<a href=\"asfunction:classes.Viewer.searchJumpTo,1\"> &lt;&lt; </a>";
         this.txtPagingNav += "<a href=\"asfunction:classes.Viewer.searchJumpBack,1\"> &lt; </a>";
      }
      var _loc6_ = Math.max(1,classes.Viewer.curSearchPage - 10);
      var _loc8_ = Math.min(classes.Viewer.curSearchPage + 10,classes.Viewer.totalSearchPages);
      var _loc2_ = _loc6_;
      while(_loc2_ <= _loc8_)
      {
         if(_loc2_ == classes.Viewer.curSearchPage)
         {
            this.txtPagingNav += "<font color=\"#96989a\"><b> " + _loc2_ + " </b></font>";
         }
         else
         {
            this.txtPagingNav += "<a href=\"asfunction:classes.Viewer.searchJumpTo," + _loc2_ + "\"> " + _loc2_ + " </a>";
         }
         _loc2_ = _loc2_ + 1;
      }
      if(classes.Viewer.curSearchPage < classes.Viewer.totalSearchPages)
      {
         this.txtPagingNav += "<a href=\"asfunction:classes.Viewer.searchJumpForward,1\"> &gt; </a>";
         this.txtPagingNav += "<a href=\"asfunction:classes.Viewer.searchJumpTo," + classes.Viewer.totalSearchPages + "\"> &gt;&gt; </a>";
      }
      trace(this.txtPagingNav);
      classes.Drawing.rect(this.scrollerContent,1,1,0,0);
      _loc2_ = 0;
      while(_loc2_ < _loc7_)
      {
         if(searchType == "teams")
         {
            classes.Drawing.teamListItem(this.scrollerContent,"item" + _loc2_,pNode.firstChild.childNodes[_loc2_].attributes.i,pNode.firstChild.childNodes[_loc2_].attributes.n,47,(_loc2_ + 1) * _loc4_,this.teamItemClick);
         }
         else if(searchType == "racers")
         {
            classes.Drawing.userListItem(this.scrollerContent,"item" + _loc2_,pNode.firstChild.childNodes[_loc2_].attributes.i,pNode.firstChild.childNodes[_loc2_].attributes.u,47,(_loc2_ + 1) * _loc4_,this.racerItemClick);
         }
         _loc2_ = _loc2_ + 1;
      }
      classes.Drawing.rect(this.scrollerContent,1,1,0,0,0,this.scrollerContent._height + 10);
      this.scrollerObj.refreshScroller();
   }
   function displaySearchEmpty()
   {
      this.txtResultCount = "No matches found for \'" + this.searchTerm + "\'";
      this.searchMessage("No matches found.");
   }
   function searchMessage(str)
   {
      trace("searchMessage");
      var _loc2_;
      if(this.scrollerContent.msg == undefined)
      {
         this.scrollerContent.createEmptyMovieClip("msg",this.scrollerContent.getNextHighestDepth());
         this.scrollerContent.msg.createTextField("fld",1,40,40,300,50);
         this.scrollerContent.msg.fld.embedFonts = true;
         this.scrollerContent.msg.fld._alpha = 80;
         _loc2_ = new TextFormat();
         _loc2_.font = "Arial";
         _loc2_.size = 14;
         _loc2_.color = 16777215;
         this.scrollerContent.msg.fld.setNewTextFormat(_loc2_);
      }
      this.scrollerContent.msg.fld.text = str;
   }
   function teamItemClick(tid)
   {
      trace("teamItemClick: " + tid);
      classes.Control.focusViewer(null,null,tid);
   }
   function racerItemClick(id)
   {
      trace("racerItemClick: " + id);
      classes.Control.focusViewer(id);
   }
   function hiSnav(idx)
   {
      classes.Viewer.__MC.snavHi.onEnterFrame = function()
      {
         this.ty = this._parent["snav" + idx]._y;
         this._y += (this.ty - this._y) / 3;
         if(Math.abs(this.ty - this._y) < 0.1)
         {
            this._y = this.ty;
            delete this.onEnterFrame;
         }
      };
   }
   function paintOverlay(clr)
   {
      this.myClr.setRGB(461066);
      this.clrOverlay._alpha = 100;
   }
   function giveRemark(uID, uName)
   {
      classes.Control.__ROOT.attachMovie("dialogGiveRemark","dialogGiveRemark",classes.Control.__ROOT.getNextHighestDepth(),{_x:183,_y:183,uID:uID,uName:uName});
   }
   function remarkError(errorText)
   {
      classes.Control.__ROOT.dialogGiveRemark.contentMC.txtError = errorText;
      classes.Control.__ROOT.dialogGiveRemark.contentMC.gotoAndPlay("error");
   }
   function destroyMe()
   {
      _global.viewerPos = new flash.geom.Point(classes.Viewer.__MC._x,classes.Viewer.__MC._y);
      this.removeMovieClip();
   }
}
