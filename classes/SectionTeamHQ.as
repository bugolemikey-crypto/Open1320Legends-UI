class classes.SectionTeamHQ extends classes.SectionClip
{
   var _parent;
   var _y;
   var badgeArray;
   var btnDeposit;
   var btnDisburse;
   var btnQuitTeam;
   var btnWithdraw;
   var cacheAsBitmap;
   var clrOverlay;
   var createEmptyMovieClip;
   var getNextHighestDepth;
   var gotoAndPlay;
   var image_bitmap;
   var img_mc;
   var myClr;
   var onEnterFrame;
   var scrollerContent;
   var scrollerObj;
   var selSnav;
   var selfNode;
   var snavDown;
   var snavHi;
   var stop;
   var teamArr;
   var teamFundsDisplay;
   var txtFunds;
   var txtOwnership;
   var ty;
   static var _MC;
   static var depositObj;
   static var disburseObj;
   static var genericObj;
   static var withdrawalObj;
   function SectionTeamHQ()
   {
      super();
      classes.SectionTeamHQ._MC = this;
      this.cacheAsBitmap = true;
      this.myClr = new Color(this.clrOverlay);
   }
   function goPage(idx)
   {
      this.selSnav = idx;
      this.hiSnav(idx);
      this.snavDown.onEnterFrame = function()
      {
         this.ty = this._parent["snav" + idx]._y;
         this._y += (this.ty - this._y) / 3;
         if(Math.abs(this.ty - this._y) < 0.1)
         {
            this._y = this.ty;
            delete this.onEnterFrame;
         }
      };
      classes.ClipFuncs.removeAllClips(this);
      switch(idx)
      {
         case 1:
            this.gotoAndPlay("main");
            break;
         case 2:
            this.gotoAndPlay("members");
            break;
         case 3:
            this.gotoAndPlay("applications");
            break;
         case 4:
            this.gotoAndPlay("funds");
            break;
         case 5:
            this.gotoAndPlay("trophies");
         default:
            return;
      }
   }
   function drawFunds(txml, rxml)
   {
      this.teamFundsDisplay.txt = "$" + classes.NumFuncs.commaFormat(Number(txml.attributes.tf));
      var _loc3_ = 0;
      while(_loc3_ < txml.childNodes.length)
      {
         if(txml.childNodes[_loc3_].attributes.i == classes.GlobalData.id)
         {
            this.selfNode = txml.childNodes[_loc3_];
            if(this.selfNode.attributes.tr == 1 || this.selfNode.attributes.tr == 2)
            {
               this.txtOwnership = "";
               this.btnWithdraw._visible = false;
               classes.SectionTeamHQ.disburseObj = {contentName:"dialogFundsDisburseContent",teamFunds:txml.attributes.tf};
               this.btnDisburse.onRelease = function()
               {
                  _root.abc.closeMe();
                  _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),classes.SectionTeamHQ.disburseObj);
               };
            }
            else
            {
               this.txtOwnership = this.selfNode.attributes.po + "% ownership : $" + this.selfNode.attributes.fu;
               this.btnDisburse._visible = false;
               classes.SectionTeamHQ.withdrawalObj = {contentName:"dialogFundsWithdrawContent",teamFunds:txml.attributes.tf,myTeamFunds:this.selfNode.attributes.fu,myPO:this.selfNode.attributes.po};
               this.btnWithdraw.onRelease = function()
               {
                  _root.abc.closeMe();
                  _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),classes.SectionTeamHQ.withdrawalObj);
               };
            }
            classes.SectionTeamHQ.depositObj = {contentName:"dialogFundsDepositContent",teamFunds:txml.attributes.tf,myTeamFunds:this.selfNode.attributes.fu,myPO:this.selfNode.attributes.po};
            if(this.selfNode.attributes.tr == 1 || this.selfNode.attributes.tr == 2)
            {
               classes.SectionTeamHQ.depositObj.isLeader = true;
            }
            this.btnDeposit.onRelease = function()
            {
               _root.abc.closeMe();
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),classes.SectionTeamHQ.depositObj);
            };
            break;
         }
         _loc3_ = _loc3_ + 1;
      }
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
      }
      this.scrollerContent._x = 125;
      this.scrollerContent._y = 284;
      this.scrollerObj.destroy();
      this.scrollerObj = new controls.ScrollPane(this.scrollerContent,662,308,null,466,790,125);
      _loc3_ = 0;
      var _loc6_;
      var _loc7_;
      while(_loc3_ < rxml.childNodes.length)
      {
         _loc6_ = {_x:0,_y:_loc3_ * 21,date:rxml.childNodes[_loc3_].attributes.d,description:classes.Lookup.transactionName(Number(rxml.childNodes[_loc3_].attributes.t)),uName:rxml.childNodes[_loc3_].attributes.u};
         _loc7_ = rxml.childNodes[_loc3_].attributes.t;
         if(_loc7_ == 3 || _loc7_ == 4 || _loc7_ == 6)
         {
            _loc6_.deposit = "+$" + rxml.childNodes[_loc3_].attributes.a;
         }
         else
         {
            _loc6_.withdrawal = "-$" + Math.abs(rxml.childNodes[_loc3_].attributes.a);
         }
         this.scrollerContent.attachMovie("teamFundsLineItem","teamFundsLineItemMC" + _loc3_,this.scrollerContent.getNextHighestDepth(),_loc6_);
         _loc3_ = _loc3_ + 1;
      }
      this.scrollerObj.refreshScroller();
      this.stop();
   }
   function drawApplications(txml, leaderMsg)
   {
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 140;
         this.scrollerContent._y = 176;
      }
      this.scrollerObj = new controls.ScrollPane(this.scrollerContent,647,416,null,466,790,125);
      var _loc6_ = 42;
      var _loc12_ = new TextFormat();
      _loc12_.font = "ArialBmp9";
      _loc12_.size = 9;
      _loc12_.color = 16777215;
      var _loc4_;
      var _loc5_;
      var _loc3_ = 0;
      while(_loc3_ < txml.childNodes.length)
      {
         _loc4_ = txml.childNodes[_loc3_].attributes;
         if(_loc4_.s != "Declined")
         {
            this.scrollerContent.attachMovie("userInfo50","applicant" + _loc3_,this.scrollerContent.getNextHighestDepth(),{_y:_loc6_,scale:50,uID:_loc4_.i,uName:_loc4_.u,uCred:_loc4_.sc});
            this.scrollerContent["applicant" + _loc3_].fldTitleET.text = "BEST AVG ET:";
            this.scrollerContent["applicant" + _loc3_].fldET.text = _loc4_.et <= 0 ? "N/A" : classes.NumFuncs.zeroFill(Math.round(_loc4_.et * 1000) / 1000,3);
            this.scrollerContent.attachMovie("applicantOptions","options" + _loc3_,this.scrollerContent.getNextHighestDepth(),{uID:_loc4_.i,_x:91,_y:_loc6_ + 42});
            classes.Drawing.rect(this.scrollerContent,2,40,0,0,0,_loc6_ + 42 + 21);
            if(_loc4_.s == "Accepted")
            {
               this.scrollerContent["options" + _loc3_].gotoAndStop(2);
            }
            else if(_global.loginXML.firstChild.firstChild.attributes.tr != 1 && _global.loginXML.firstChild.firstChild.attributes.tr != 2)
            {
               this.scrollerContent["options" + _loc3_]._visible = false;
            }
            this.scrollerContent.createTextField("comment" + _loc3_,this.scrollerContent.getNextHighestDepth(),219,_loc6_ + 4,160,70);
            _loc5_ = this.scrollerContent["comment" + _loc3_];
            _loc5_.embedFonts = true;
            _loc5_.multiline = true;
            _loc5_.selectable = false;
            _loc5_.wordWrap = true;
            _loc5_.setNewTextFormat(_loc12_);
            _loc5_.text = _loc4_.n;
            _loc6_ += 83;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.scrollerContent.attachMovie("leaderMessage","leaderMessage",this.scrollerContent.getNextHighestDepth(),{_x:435,_y:190});
      this.scrollerContent.leaderMessage.fld.text = unescape(leaderMsg);
      this.scrollerObj.refreshScroller();
   }
   function drawMembers(txml)
   {
      var _loc4_ = 0;
      while(_loc4_ < txml.childNodes.length)
      {
         if(txml.childNodes[_loc4_].nodeName == "tm" && txml.childNodes[_loc4_].attributes.i == classes.GlobalData.id)
         {
            this.selfNode = txml.childNodes[_loc4_];
            classes.SectionTeamHQ.genericObj = {contentName:"dialogTeamQuitContent",myTeamFunds:this.selfNode.attributes.fu,myPO:this.selfNode.attributes.po};
            this.btnQuitTeam.onRelease = function()
            {
               _root.abc.closeMe();
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),classes.SectionTeamHQ.genericObj);
            };
            break;
         }
         _loc4_ = _loc4_ + 1;
      }
      this.teamArr = new Array();
      var _loc12_;
      _loc4_ = 0;
      while(_loc4_ < txml.childNodes.length)
      {
         if(txml.childNodes[_loc4_].nodeName == "tm")
         {
            _loc12_ = txml.childNodes[_loc4_].attributes;
            this.teamArr.push(_loc12_);
         }
         _loc4_ = _loc4_ + 1;
      }
      if(this.scrollerContent == undefined)
      {
         this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
         this.scrollerContent._x = 140;
         this.scrollerContent._y = 176;
         this.scrollerObj = new controls.ScrollPane(this.scrollerContent,647,416,null,466,790,125);
      }
      var _loc5_ = this.scrollerContent.createEmptyMovieClip("officers",this.scrollerContent.getNextHighestDepth());
      var _loc7_ = 0;
      var _loc11_ = new TextFormat();
      _loc11_.font = "Arial";
      _loc11_.bold = true;
      _loc11_.size = 11.5;
      _loc11_.color = 16777215;
      _loc4_ = 0;
      while(_loc4_ < this.teamArr.length)
      {
         if(this.teamArr[_loc4_].tr == 1)
         {
            _loc5_.createTextField("headLeader",_loc5_.getNextHighestDepth(),0,0,300,40);
            _loc5_.headLeader.embedFonts = true;
            _loc5_.headLeader._alpha = 80;
            _loc5_.headLeader.selectable = false;
            _loc5_.headLeader.setNewTextFormat(_loc11_);
            _loc5_.headLeader.text = "Team Leader:";
            _loc5_.attachMovie("userInfo50","teamLeader",_loc5_.getNextHighestDepth(),{scale:50,uID:this.teamArr[_loc4_].i,uName:this.teamArr[_loc4_].un,uCred:this.teamArr[_loc4_].sc});
            _loc5_.teamLeader.fldTitleET.text = "BEST AVG ET:";
            _loc5_.teamLeader.fldET.text = this.teamArr[_loc4_].et <= 0 ? "N/A" : classes.NumFuncs.zeroFill(Math.round(this.teamArr[_loc4_].et * 1000) / 1000,3);
            _loc5_.teamLeader.fldOwnership.text = !Number(this.teamArr[_loc4_].po) ? "" : this.teamArr[_loc4_].po + "% owner: $" + this.teamArr[_loc4_].fu;
            _loc5_.teamLeader._x = 23;
            _loc5_.teamLeader._y = 20;
            if(_global.loginXML.firstChild.firstChild.attributes.tr == 1)
            {
               _loc5_.attachMovie("btnLeaderStepDown","btnLeaderStepDown",_loc5_.getNextHighestDepth());
               _loc5_.btnLeaderStepDown._x = 90;
               _loc5_.btnLeaderStepDown._y = _loc7_;
               _loc5_.btnLeaderStepDown.onRelease = function()
               {
                  _root.abc.closeMe();
                  _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamLeaderStepDownContent"});
               };
            }
            _loc7_ += 100;
            break;
         }
         _loc4_ = _loc4_ + 1;
      }
      var _loc19_;
      var _loc20_;
      if(_loc5_.headCoLeaders == undefined)
      {
         _loc19_ = _loc5_.createTextField("headCoLeaders",_loc5_.getNextHighestDepth(),0,0,300,40);
         _loc19_.embedFonts = true;
         _loc19_.selectable = false;
         _loc19_._alpha = 80;
         _loc19_._y = _loc7_;
         _loc19_.setNewTextFormat(_loc11_);
         _loc19_.text = "Team Co-Leaders:";
         if(_global.loginXML.firstChild.firstChild.attributes.tr == 1)
         {
            _loc20_ = _loc5_.attachMovie("btnModifyMember","btnModifyCoLeader",_loc5_.getNextHighestDepth());
            _loc20_._x = 112;
            _loc20_._y = _loc7_;
            _loc20_.onRelease = function()
            {
               _root.abc.closeMe();
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamRoleContent",filterByType:2});
            };
         }
         _loc7_ += 18;
      }
      var _loc9_ = 0;
      _loc4_ = 0;
      var _loc6_;
      while(_loc4_ < this.teamArr.length)
      {
         if(this.teamArr[_loc4_].tr == 2)
         {
            _loc9_ = _loc9_ + 1;
            _loc6_ = _loc5_.attachMovie("userInfo50","teamCoLeader" + _loc9_,_loc5_.getNextHighestDepth(),{scale:50,uID:this.teamArr[_loc4_].i,uName:this.teamArr[_loc4_].un,uCred:this.teamArr[_loc4_].sc});
            _loc6_.fldTitleET.text = "BEST AVG ET:";
            _loc6_.fldET.text = this.teamArr[_loc4_].et <= 0 ? "N/A" : classes.NumFuncs.zeroFill(Math.round(this.teamArr[_loc4_].et * 1000) / 1000,3);
            _loc6_.fldOwnership.text = !Number(this.teamArr[_loc4_].po) ? "" : this.teamArr[_loc4_].po + "% owner: $" + this.teamArr[_loc4_].fu;
            _loc6_._x = 23;
            _loc6_._y = _loc7_;
            _loc7_ += 78;
         }
         _loc4_ = _loc4_ + 1;
      }
      if(_loc9_ == 0)
      {
         _loc5_.headCoLeaders.text += "  (None)";
         _loc5_.btnModifyCoLeader._visible = false;
         _loc7_ += 14;
      }
      if(_loc5_.headDealers == undefined)
      {
         _loc5_.createTextField("headDealers",_loc5_.getNextHighestDepth(),0,0,300,40);
         _loc5_.headDealers.embedFonts = true;
         _loc5_.headDealers.selectable = false;
         _loc5_.headDealers._alpha = 80;
         _loc5_.headDealers._y = _loc7_;
         _loc5_.headDealers.setNewTextFormat(_loc11_);
         _loc5_.headDealers.text = "Team Dealers:";
         if(_global.loginXML.firstChild.firstChild.attributes.tr == 1 || _global.loginXML.firstChild.firstChild.attributes.tr == 2)
         {
            _loc20_ = _loc5_.attachMovie("btnModifyMember","btnModifyDealer",_loc5_.getNextHighestDepth());
            _loc20_._x = 112;
            _loc20_._y = _loc7_;
            _loc20_.onRelease = function()
            {
               _root.abc.closeMe();
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamRoleContent",filterByType:3});
            };
         }
         _loc7_ += 18;
      }
      var _loc10_ = 0;
      _loc4_ = 0;
      while(_loc4_ < this.teamArr.length)
      {
         if(this.teamArr[_loc4_].tr == 3)
         {
            _loc10_ = _loc10_ + 1;
            _loc6_ = _loc5_.attachMovie("userInfo50","teamDealer" + _loc10_,_loc5_.getNextHighestDepth(),{scale:50,uID:this.teamArr[_loc4_].i,uName:this.teamArr[_loc4_].un,uCred:this.teamArr[_loc4_].sc});
            _loc6_.fldTitleET.text = "BEST AVG ET:";
            _loc6_.fldET.text = this.teamArr[_loc4_].et <= 0 ? "N/A" : classes.NumFuncs.zeroFill(Math.round(this.teamArr[_loc4_].et * 1000) / 1000,3);
            _loc6_.fldOwnership.text = Number(this.teamArr[_loc4_].po) <= 0 ? "" : this.teamArr[_loc4_].po + "% owner: $" + this.teamArr[_loc4_].fu;
            if(Number(this.teamArr[_loc4_].mbp) > -1)
            {
               _loc6_.fldDealerPerc.text = "Allowed to bet: " + this.teamArr[_loc4_].mbp + "%";
            }
            _loc6_._x = 23;
            _loc6_._y = _loc7_;
            _loc7_ += 76;
         }
         _loc4_ = _loc4_ + 1;
      }
      if(_loc10_ == 0)
      {
         _loc5_.headDealers.text += "  (None)";
         _loc5_.btnModifyDealer._visible = false;
      }
      this.drawRegularsPage();
      this.scrollerObj.refreshScroller();
   }
   function drawRegularsPage(pg)
   {
      if(!pg)
      {
         pg = 1;
      }
      this.clearRegulars();
      var tf = new TextFormat();
      tf.font = "Arial";
      tf.bold = true;
      tf.color = 16777215;
      tf.size = 11.5;
      if(this.scrollerContent.regularsGroup == undefined)
      {
         this.scrollerContent.createEmptyMovieClip("regularsGroup",this.getNextHighestDepth());
         this.scrollerContent.regularsGroup._x = 304;
         this.scrollerContent.regularsGroup._y = 24;
         this.scrollerContent.regularsGroup.createTextField("headRegulars",this.scrollerContent.regularsGroup.getNextHighestDepth(),-22,-24,300,40);
         this.scrollerContent.regularsGroup.headRegulars.embedFonts = true;
         this.scrollerContent.regularsGroup.headRegulars.selectable = false;
         this.scrollerContent.regularsGroup.headRegulars._alpha = 80;
         this.scrollerContent.regularsGroup.headRegulars.setNewTextFormat(tf);
         this.scrollerContent.regularsGroup.headRegulars.text = "Team Members:";
         if(_global.loginXML.firstChild.firstChild.attributes.tr == 1 || _global.loginXML.firstChild.firstChild.attributes.tr == 2)
         {
            var tbtn = this.scrollerContent.regularsGroup.attachMovie("btnModifyMember","btnModifyMember",this.scrollerContent.regularsGroup.getNextHighestDepth());
            tbtn._x = 82;
            tbtn._y = -24;
            tbtn.onRelease = function()
            {
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamRoleContent",filterByType:4});
            };
            var tbtn = this.scrollerContent.regularsGroup.attachMovie("btnRemoveMember","btnRemoveMember",this.scrollerContent.regularsGroup.getNextHighestDepth());
            tbtn._x = 214;
            tbtn._y = -24;
            tbtn.onRelease = function()
            {
               _root.abc.closeMe();
               _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogTeamRemoveContent"});
            };
         }
      }
      var xSpacing = 77;
      var ySpacing = 104;
      var cols = 4;
      var rows = 3;
      var countOffset = (pg - 1) * cols * rows;
      var xPos;
      var yPos;
      var regularsArr = new Array();
      var i = 0;
      while(i < this.teamArr.length)
      {
         if(this.teamArr[i].tr == 4)
         {
            regularsArr.push(this.teamArr[i]);
         }
         i++;
      }
      var lim = Math.min(cols * rows,regularsArr.length - countOffset);
      var i = 0;
      while(i < lim)
      {
         xPos = i % cols * xSpacing;
         yPos = Math.floor(i / cols) * ySpacing;
         this.scrollerContent.regularsGroup.attachMovie("_blank","buddy" + i,this.scrollerContent.regularsGroup.getNextHighestDepth(),{_x:xPos,_y:yPos,id:regularsArr[i + countOffset].i});
         this.scrollerContent.regularsGroup["buddy" + i].attachMovie("_blank","pic",1,{_xscale:50,_yscale:50});
         classes.Drawing.portrait(this.scrollerContent.regularsGroup["buddy" + i].pic,this.scrollerContent.regularsGroup["buddy" + i].id,1,0,0,2);
         with(this.scrollerContent.regularsGroup["buddy" + i])
         {
            pic.onRelease = function()
            {
               classes.Control.focusViewer(this._parent.id);
            };
            createTextField("uname",2,-2,41,_width + 20,30);
            uname.embedFonts = true;
            uname.autoSize = true;
            tf.size = 9;
            uname.setNewTextFormat(tf);
            createTextField("financials",3,-2,53,_width + 20,50);
            financials.embedFonts = true;
            financials.selectable = false;
            financials.autoSize = true;
            financials.multiline = true;
            financials._alpha = 80;
            tf.size = 10;
            financials.setNewTextFormat(tf);
         }
         this.scrollerContent.regularsGroup["buddy" + i].uname.text = regularsArr[i + countOffset].un;
         if(Number(regularsArr[i + countOffset].po) > 0)
         {
            this.scrollerContent.regularsGroup["buddy" + i].financials.text = regularsArr[i + countOffset].po + "% owner\r" + "$" + regularsArr[i + countOffset].fu;
         }
         i++;
      }
      this.drawRegularsPaging(pg,regularsArr.length);
   }
   function drawRegularsPaging(curPage, totalCount)
   {
      var buddiesPerPage = 12;
      var pages = Math.ceil(totalCount / buddiesPerPage);
      this.scrollerContent.regularsGroup.pagingGroup.removeMovieClip();
      this.scrollerContent.regularsGroup.attachMovie("_blank","pagingGroup",this.scrollerContent.regularsGroup.getNextHighestDepth(),{_x:0,_y:306});
      with(this.scrollerContent.regularsGroup.pagingGroup)
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
               classes.SectionTeamHQ._MC.drawRegularsPage(this.gotoPage);
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
         if(curPage != pages && pages != 0)
         {
            tf.color = 16777215;
            fldNext.gotoPage = curPage + 1;
            fldNext.onRelease = function()
            {
               classes.SectionTeamHQ._MC.drawRegularsPage(this.gotoPage);
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
               fldPaging.htmlText += "<a href=\"asfunction:classes.SectionTeamHQ._MC.drawRegularsPage," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
   }
   function clearRegulars()
   {
      for(var _loc2_ in this.scrollerContent.regularsGroup)
      {
         if(typeof this.scrollerContent.regularsGroup[_loc2_] == "movieclip" && this.scrollerContent.regularsGroup[_loc2_] != this.scrollerContent.regularsGroup.pagingGroup)
         {
            this.scrollerContent.regularsGroup[_loc2_].removeMovieClip();
            delete this.scrollerContent.regularsGroup[_loc2_];
         }
      }
   }
   function setFundsField(amt)
   {
      if(amt > 1000000)
      {
         this.txtFunds = "Funds: $" + classes.NumFuncs.commaFormat(amt);
      }
      else
      {
         this.txtFunds = "Funds: $" + amt;
      }
   }
   function hiSnav(idx)
   {
      this.snavHi.onEnterFrame = function()
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
   function getGridColorPoint(clr)
   {
      var _loc6_;
      var _loc7_ = 12;
      var _loc4_;
      var _loc3_;
      var _loc9_;
      var _loc5_ = 0;
      var _loc2_;
      while(_loc5_ < 16)
      {
         _loc2_ = 0;
         while(_loc2_ < 7)
         {
            _loc4_ = 1 + _loc5_ * _loc7_;
            _loc3_ = 1 + _loc2_ * _loc7_;
            _loc6_ = this.image_bitmap.getPixel(_loc4_,_loc3_);
            if(_loc6_ == clr)
            {
               _loc9_ = new flash.geom.Point(_loc4_ - 1,_loc3_ - 1);
               break;
            }
            _loc2_ = _loc2_ + 1;
         }
         if(_loc6_ == clr)
         {
            break;
         }
         _loc5_ = _loc5_ + 1;
      }
      return _loc9_;
   }
   function setGridColorHilite(pp)
   {
      if(pp != undefined)
      {
         this.img_mc.hilite._x = pp.x;
         this.img_mc.hilite._y = pp.y;
         this.img_mc.hilite._visible = true;
      }
      else
      {
         this.img_mc.hilite._visible = false;
      }
   }
   function paintOverlay(clr)
   {
      this.myClr.setRGB(Number("0x" + clr));
      this.clrOverlay._alpha = 80;
   }
   function drawBadges(bxml)
   {
      this.badgeArray = new Array();
      var _loc4_;
      var _loc2_ = 0;
      while(_loc2_ < bxml.childNodes.length)
      {
         if(bxml.childNodes[_loc2_].nodeName == "b")
         {
            _loc4_ = bxml.childNodes[_loc2_].attributes;
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
      pg = Number(pg);
      trace("drawMyBadges(" + pg + ")");
      this.scrollerObj.setScrollToTop();
      this.scrollerContent.badgesGroup.removeMovieClip();
      this.scrollerContent.createEmptyMovieClip("badgesGroup",this.scrollerContent.getNextHighestDepth());
      var _loc20_ = 157;
      var _loc19_ = 113;
      var _loc12_ = 4;
      var _loc23_ = 3;
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
      var badgesPerPage = 12;
      var pages = Math.ceil(this.badgeArray.length / badgesPerPage);
      this.scrollerContent.badgesGroup.pagingGroup.removeMovieClip();
      this.scrollerContent.badgesGroup.attachMovie("_blank","pagingGroup",this.scrollerContent.badgesGroup.getNextHighestDepth(),{_x:0,_y:375});
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
               classes.SectionTeamHQ._MC.drawMyBadges(this.gotoPage);
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
               classes.SectionTeamHQ._MC.drawMyBadges(this.gotoPage);
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
               fldPaging.htmlText += "<a href=\"asfunction:classes.SectionTeamHQ._MC.drawMyBadges," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
      this.scrollerContent.badgesGroup.pagingGroup._x = 178;
   }
}
