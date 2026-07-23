class classes.SectionHome extends classes.SectionClip
{
   var _parent;
   var _x;
   var _y;
   var cacheAsBitmap;
   var clrOverlay;
   var gotoAndPlay;
   var idx;
   var myClr;
   var onEnterFrame;
   var tx;
   var ty;
   static var _MC;
   static var __MC;
   function SectionHome()
   {
      super();
      classes.SectionHome.__MC = this;
      classes.SectionHome._MC = this;
      this.cacheAsBitmap = true;
      var _loc5_ = 1;
      var _loc4_ = 1;
      while(_loc4_ <= 3)
      {
         classes.Effects.roBump(classes.SectionHome._MC["ro" + _loc4_]);
         classes.SectionHome._MC["ro" + _loc4_].idx = _loc4_;
         classes.SectionHome._MC["ro" + _loc4_].onRelease = function()
         {
            this._parent.goSection(this.idx);
         };
         _loc4_ = _loc4_ + 1;
      }
      this.myClr = new Color(this.clrOverlay);
      if(Number("0x" + _global.loginXML.firstChild.firstChild.attributes.bg))
      {
         this.paintOverlay(_global.loginXML.firstChild.firstChild.attributes.bg);
      }
      this.goSection(2);
   }
   function goSection(idx)
   {
      trace("goSection: " + idx);
      this.updateUserValues();
      for(var _loc2_ in classes.SectionHome._MC.scrollerContent)
      {
         classes.SectionHome._MC.scrollerContent[_loc2_].removeMovieClip();
      }
      classes.SectionHome._MC.tabDown.tx = classes.SectionHome._MC["ro" + idx]._x;
      classes.SectionHome._MC.tabDown.onEnterFrame = function()
      {
         this._x += (this.tx - this._x) / 3;
         if(Math.abs(this.tx - this._x) < 0.1)
         {
            delete this.onEnterFrame;
         }
      };
      switch(idx)
      {
         case 1:
            this.gotoAndPlay("garage");
            break;
         case 2:
            this.gotoAndPlay("profile");
            break;
         case 3:
            this.gotoAndPlay("account");
         default:
            return;
      }
   }
   function clearProfileContent()
   {
      for(var _loc1_ in classes.SectionHome._MC.scrollerContent)
      {
         if(_loc1_ != "remarkMC")
         {
            classes.SectionHome._MC.scrollerContent[_loc1_].removeMovieClip();
         }
      }
   }
   function updateUserValues()
   {
      classes.SectionHome._MC.txtFunds = "Funds: $" + classes.NumFuncs.commaFormat(_global.loginXML.firstChild.firstChild.attributes.m);
      classes.SectionHome._MC.txtPoints = "Points: " + classes.NumFuncs.commaFormat(_global.loginXML.firstChild.firstChild.attributes.p);
   }
   function hiSnav(idx)
   {
      classes.SectionHome._MC.snavHi.onEnterFrame = function()
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
   function selectSnav(idx)
   {
      classes.SectionHome._MC.selSnav = idx;
      classes.SectionHome._MC.snavDown.onEnterFrame = function()
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
   static function showMove(locationID)
   {
      if(locationID > Number(classes.GlobalData.attr.lid))
      {
         _root.abc.closeMe();
         _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogMoveUpContent",lid:locationID});
      }
      else
      {
         _root.abc.closeMe();
         _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogMoveDownContent",lid:locationID});
      }
   }
}
