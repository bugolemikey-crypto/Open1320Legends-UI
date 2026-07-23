class classes.HomeAccount extends MovieClip
{
   var scrollerContent;
   var scrollerObj;
   var txtHeader;
   static var _MC;
   function HomeAccount()
   {
      super();
      trace("HomeAccount Constructor");
      classes.HomeAccount._MC = this;
      this.scrollerContent = this.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
      this.scrollerContent._y = 73;
      this.scrollerObj = new controls.ScrollPane(this.scrollerContent,693,394,null,467,694,0);
      trace("facebook connected in HomeAccount: " + classes.GlobalData.facebookConnected);
      this.goAccountPage(1);
   }
   function goAccountPage(idx)
   {
      this._parent.selectSnav(idx);
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      switch(idx)
      {
         case 1:
            this.gotoAndPlay("security");
            this.txtHeader = "Security";
         case 2:
            this.gotoAndPlay("membership");
            this.txtHeader = "Membership";
         case 3:
            this.gotoAndPlay("email");
            this.txtHeader = "Email Setup";
         case 4:
            this.gotoAndPlay("points");
            this.txtHeader = "Points";
         case 5:
            trace("home account twitter login");
            this.txtHeader = "Twitter";
            _root.twitterLogin("","","checkstatus");
            this.gotoAndPlay("twitter");
         default:
            return;
      }
   }
   function drawMyPlaces()
   {
      trace("drawMyPlaces");
      this.scrollerContent.attachMovie("_blank","placesGroup",this.scrollerContent.getNextHighestDepth(),{_x:23,_y:0});
      var _loc13_ = _global.locationXML.firstChild.childNodes.length - 1;
      var _loc8_ = Number(_global.loginXML.firstChild.firstChild.attributes.lid);
      var _loc11_ = false;
      var _loc4_;
      var _loc5_;
      var _loc9_;
      var _loc6_;
      var _loc10_;
      var _loc7_;
      var _loc3_;
      if(!isNaN(_loc13_))
      {
         _loc4_ = _loc13_;
         while(_loc4_ >= 0)
         {
            _loc5_ = Number(_global.locationXML.firstChild.childNodes[_loc4_].attributes.lid);
            _loc9_ = Number(_global.locationXML.firstChild.childNodes[_loc4_].attributes.f);
            _loc6_ = Number(_global.locationXML.firstChild.childNodes[_loc4_].attributes.r);
            _loc10_ = Number(_global.locationXML.firstChild.childNodes[_loc4_].attributes.ps);
            _loc7_ = this.scrollerContent.placesGroup["placesInfo" + (_loc4_ + 1)]._y;
            if(_loc11_)
            {
               _loc7_ += 133;
            }
            else
            {
               _loc7_ += 66;
            }
            _loc3_ = this.scrollerContent.placesGroup.attachMovie("placesInfo","placesInfo" + _loc4_,this.scrollerContent.placesGroup.getNextHighestDepth(),{_y:_loc7_});
            if(_loc5_ == _loc8_)
            {
               classes.Drawing.rect(_loc3_,349,133,0,20,0,0,4);
               if(_loc5_ != 100)
               {
                  _loc3_.txtRentDue = "Your rent collection is on every Friday at 5:00PM PST.\rRent payment: $" + classes.NumFuncs.commaFormat(_loc6_);
               }
               else
               {
                  _loc3_.txtRentDue = "Rent payment: $" + classes.NumFuncs.commaFormat(_loc6_);
               }
            }
            else
            {
               _loc3_.createEmptyMovieClip("rect",_loc3_.getNextHighestDepth());
               classes.Drawing.rect(_loc3_.rect,349,66,0,0,0,0,0);
               _loc3_.lid = _loc5_;
               if(_loc5_ < _loc8_ || _loc5_ == _loc8_ + 100)
               {
                  _loc3_.rect.onRelease = function()
                  {
                     trace("moving dialog: " + this._parent.lid);
                     classes.SectionHome.showMove(this._parent.lid);
                  };
               }
            }
            _loc3_.txtName = _global.locationXML.firstChild.childNodes[_loc4_].attributes.ln;
            _loc3_.txtInfo = !_loc9_ ? "No" : "$" + classes.NumFuncs.commaFormat(_loc9_);
            _loc3_.txtInfo += " move-in fee.\r";
            _loc3_.txtInfo += !_loc6_ ? "No weekly payment" : "$" + classes.NumFuncs.commaFormat(_loc6_) + " weekly payment";
            _loc3_.txtInfo += "\n" + _loc10_ + " parking spaces";
            _loc3_.icon.gotoAndStop(_loc5_ / 100);
            _loc11_ = _loc5_ == _loc8_;
            _loc4_ = _loc4_ - 1;
         }
      }
   }
   function drawTeamStatus()
   {
      classes.ClipFuncs.removeAllClips(this.scrollerContent);
      this.scrollerObj.setScrollToTop();
      this.scrollerContent.attachMovie("homeTeamStatus","teamStatus",this.scrollerContent.getNextHighestDepth());
   }
   function drawMyBuddies(pg)
   {
      pg = Number(pg);
      trace("drawMyBuddies(" + pg + ")");
      this.scrollerContent.buddiesGroup.removeMovieClip();
      this.scrollerContent.createEmptyMovieClip("buddiesGroup",this.scrollerContent.getNextHighestDepth());
      this.scrollerContent.buddiesGroup._x = 50;
      this.scrollerContent.buddiesGroup._y = 5;
      var xSpacing = 77;
      var ySpacing = 84;
      var cols = 4;
      var rows = 3;
      var countOffset = (pg - 1) * cols * rows;
      var lim = Math.min(cols * rows,_global.buddylist_xml.firstChild.childNodes.length - countOffset);
      var xPos;
      var yPos;
      var i = 0;
      while(i < lim)
      {
         xPos = i % cols * xSpacing;
         yPos = Math.floor(i / cols) * ySpacing;
         this.scrollerContent.buddiesGroup.attachMovie("_blank","buddy" + i,this.scrollerContent.buddiesGroup.getNextHighestDepth(),{_x:xPos,_y:yPos,id:_global.buddylist_xml.firstChild.childNodes[i + countOffset].attributes.id});
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
            uname.text = _global.buddylist_xml.firstChild.childNodes[i + countOffset].attributes.n;
         }
         i++;
      }
   }
}
