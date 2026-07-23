class classes.TrophyRoom
{
   var _allowSetVisibility;
   var _intervalCount;
   var _pagingFunction;
   var _usePaging;
   var _userInfo;
   var _xTrophyPos;
   var _xmouse;
   var _yTrophyPos;
   var _ymouse;
   var badgeIntervalID;
   var badgeShow;
   var cols;
   var id;
   var rows;
   var scrollerContent;
   var scrollerObj;
   var userInfo;
   function TrophyRoom()
   {
   }
   function init(userInfo, a_scrollObj, a_scrollerContent, a_cols, a_rows, usePaging, allowSetVisibility, xTrophyPos, yTrophyPos, pagingFunction)
   {
      this._userInfo = userInfo;
      this.scrollerContent = a_scrollerContent;
      this.scrollerObj = a_scrollObj;
      this.cols = a_cols;
      this.rows = a_rows;
      this._usePaging = usePaging;
      this._allowSetVisibility = allowSetVisibility;
      this._xTrophyPos = xTrophyPos;
      this._yTrophyPos = yTrophyPos;
      this._pagingFunction = pagingFunction;
      this._intervalCount = 0;
      trace("init: ");
      trace(this.cols);
      trace(this.rows);
   }
   function drawBadges()
   {
      trace("drawBadges!");
      trace(this.cols);
      trace(this.rows);
      this._intervalCount = this._intervalCount + 1;
      clearInterval(this.badgeIntervalID);
      trace("badgeIntervalID: " + this.badgeIntervalID);
      trace("after clear interval");
      trace(this._userInfo);
      trace(this._userInfo.badgesReceived);
      if(this._intervalCount < 100)
      {
         if(this._userInfo.badgesReceived == true)
         {
            trace("drawing badges");
            this.drawMyBadges(1);
         }
         else
         {
            trace("setting interval again");
            this.badgeIntervalID = setInterval(this,"drawBadges",100);
         }
      }
   }
   function drawMyBadges(pg)
   {
      pg = Number(pg);
      trace("drawMyBadges(" + pg + ")");
      this.scrollerObj.setScrollToTop();
      this.scrollerContent.badgesGroup.removeMovieClip();
      this.scrollerContent.createEmptyMovieClip("badgesGroup",this.scrollerContent.getNextHighestDepth());
      this.scrollerContent.badgesGroup._x = this._xTrophyPos;
      this.scrollerContent.badgesGroup._y = this._yTrophyPos;
      var _loc21_ = 150;
      var _loc19_;
      var _loc23_ = this._userInfo.showBadgesXML.firstChild.childNodes.length;
      var _loc24_ = new Array();
      if(this._allowSetVisibility == true)
      {
         _loc19_ = 170;
      }
      else
      {
         _loc19_ = 150;
      }
      if(this._usePaging == false)
      {
         trace("numberOfBadges: " + _loc23_);
         this.rows = Math.ceil(_loc23_ / this.cols);
      }
      var _loc12_ = (pg - 1) * this.cols * this.rows;
      var _loc20_ = Math.min(this.cols * this.rows,this._userInfo.showBadgesXML.firstChild.childNodes.length - _loc12_);
      var _loc16_;
      var _loc15_;
      trace("lim: " + _loc20_);
      trace("cols: " + this.cols);
      trace("rows: " + this.rows);
      var _loc4_ = 0;
      var _loc7_;
      var _loc10_;
      var _loc14_;
      var _loc3_;
      var _loc8_;
      var _loc6_;
      var _loc13_;
      var _loc11_;
      while(_loc4_ < _loc20_)
      {
         _loc16_ = _loc4_ % this.cols * _loc21_;
         _loc15_ = Math.floor(_loc4_ / this.cols) * _loc19_;
         _loc7_ = Number(this._userInfo.showBadgesXML.firstChild.childNodes[_loc4_ + _loc12_].attributes.i);
         _loc10_ = Number(this._userInfo.showBadgesXML.firstChild.childNodes[_loc4_ + _loc12_].attributes.n);
         _loc14_ = Number(this._userInfo.showBadgesXML.firstChild.childNodes[_loc4_ + _loc12_].attributes.v);
         this.scrollerContent.badgesGroup.attachMovie("_blank","badge" + _loc4_,this.scrollerContent.badgesGroup.getNextHighestDepth(),{_x:_loc16_,_y:_loc15_,id:_loc7_});
         _loc3_ = this.scrollerContent.badgesGroup["badge" + _loc4_];
         _loc3_.attachBitmap(_root.badgesHolder.arrBmpLarge[_loc7_],_loc3_.getNextHighestDepth());
         _loc3_.userInfo = this._userInfo;
         if(this._allowSetVisibility == true)
         {
            _loc3_.attachMovie("badgeShow","badgeShow",_loc3_.getNextHighestDepth(),{_x:45,_y:145});
            if(_loc14_ == "1")
            {
               _loc3_.badgeShow.box.gotoAndStop(2);
            }
            else
            {
               _loc3_.badgeShow.box.gotoAndStop(1);
            }
            trace("badgeShow: " + _loc3_.badgeShow);
            _loc3_.onRelease = function()
            {
               trace("badgeShow release");
               var _loc3_ = this.badgeShow.getBounds(this);
               var _loc4_ = new flash.geom.Rectangle(_loc3_.xMin,_loc3_.yMin,_loc3_.xMax - _loc3_.xMin,_loc3_.yMax - _loc3_.yMin);
               trace(_loc4_);
               trace(this._xmouse);
               trace(this._ymouse);
               if(_loc4_.contains(this._xmouse,this._ymouse))
               {
                  trace("badgeMovie userInfo: " + this.userInfo);
                  if(this.badgeShow.box._currentFrame == 1)
                  {
                     trace("goto and stop 2");
                     this.badgeShow.box.gotoAndStop(2);
                     trace("badgeNum: " + this.id);
                     this.userInfo.showBadge(true,String(this.id));
                     _root.setBadgeVisible(String(this.id),true);
                  }
                  else
                  {
                     trace("goto and stop 1");
                     this.badgeShow.box.gotoAndStop(1);
                     this.userInfo.showBadge(false,String(this.id));
                     _root.setBadgeVisible(String(this.id),false);
                  }
               }
            };
         }
         trace("badgeMovie: " + _loc3_);
         trace("badgeMovieParent: " + _loc3_._parent);
         trace("badgeMovieXY: " + _loc3_._x + " " + _loc3_._y);
         trace("badgeNumber: " + _loc7_);
         if(_loc10_ > 1)
         {
            _loc8_ = _loc3_.createTextField("count",2,100,115,24,20);
            _loc6_ = new TextFormat();
            _loc6_.font = "Arial";
            _loc6_.size = 10;
            _loc6_.color = 16777215;
            _loc6_.align = "right";
            _loc8_.embedFonts = true;
            _loc8_.autoSize = "right";
            _loc8_.setNewTextFormat(_loc6_);
            _loc8_.text = String(_loc10_);
         }
         _loc13_ = classes.Lookup.badgeAltText(_loc7_);
         _loc11_ = classes.Lookup.badgeAltDescription(_loc7_);
         trace("badgeDescription: " + _loc11_);
         classes.Help.addAltTag2(_loc3_,_loc13_,_loc11_);
         _loc4_ = _loc4_ + 1;
      }
      if(this._usePaging == true)
      {
         this.drawBadgePaging(pg);
      }
      else
      {
         this.scrollerObj.refreshScroller();
      }
   }
   function drawBadgePaging(curPage, setNum)
   {
      var badgesPerPage = 8;
      var pages = Math.ceil(this._userInfo.showBadgesXML.firstChild.childNodes.length / badgesPerPage);
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
            fldPrev.trophyRoom = this;
            fldPrev.onRelease = function()
            {
               trace(this.trophyRoom);
               this.trophyRoom.drawMyBadges(this.gotoPage);
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
            fldNext.gotoPage = curPage + 1;
            fldNext.trophyRoom = this;
            fldNext.onRelease = function()
            {
               trace("fldNext release");
               trace(this);
               trace(this.trophyRoom);
               this.trophyRoom.drawMyBadges(this.gotoPage);
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
               trace("creating click link, instance num: " + this);
               fldPaging.htmlText += "<a href=\"asfunction:classes.HomeProfile._MC.drawTheBadges," + j + "\"><u>" + j + "</u></a> ";
            }
            j++;
         }
      }
      this.scrollerContent.badgesGroup.pagingGroup._x = 300 - this.scrollerContent.badgesGroup.pagingGroup._width / 2;
      trace("pagingGroup.x: " + this.scrollerContent.badgesGroup.pagingGroup._x);
      trace("pagingGroup.width: " + this.scrollerContent.badgesGroup.pagingGroup._width);
   }
}
