class classes.mc.TourneyEventList extends MovieClip
{
   var fldDay;
   var fldTime;
   var hwidth;
   var listNodes;
   var loadcc;
   var onEnterFrame;
   var scrollGroup;
   var tcc;
   static var _mc;
   static var listArr;
   static var xRightBound;
   function TourneyEventList()
   {
      super();
      classes.mc.TourneyEventList._mc = this;
   }
   function init(listXML)
   {
      this.listNodes = listXML.firstChild.childNodes;
      classes.mc.TourneyEventList.listArr = new Array();
      var _loc7_;
      var _loc6_;
      var _loc3_ = 0;
      var _loc5_;
      var _loc2_ = 0;
      var _loc4_;
      while(_loc2_ < this.listNodes.length)
      {
         _loc4_ = new Date(Number(this.listNodes[_loc2_].attributes.d) * 1000);
         _loc6_ = _loc4_.getUTCMonth();
         if(_loc6_ != _loc7_)
         {
            _loc7_ = _loc6_;
            if(_loc3_ > 0)
            {
               this.scrollGroup.sgroup0.duplicateMovieClip("sgroup" + _loc3_,_loc3_);
            }
            _loc5_ = this.scrollGroup["sgroup" + _loc3_];
            if(_loc3_ > 0)
            {
               _loc5_._x = this._width + 10;
            }
            _loc3_ = _loc3_ + 1;
         }
         classes.mc.TourneyEventList.addEvent(_loc5_,_loc4_,this.listNodes[_loc2_].attributes,classes.StringFuncs.readCdata(String(this.listNodes[_loc2_].firstChild.firstChild)),classes.StringFuncs.readCdata(String(this.listNodes[_loc2_].childNodes[1].firstChild)));
         _loc2_ = _loc2_ + 1;
      }
      _loc5_.fold._visible = false;
      this.startListLoader();
   }
   static function addEvent(sgroup, d, detailObj, entryReq, descr)
   {
      var _loc9_ = 170;
      var hwidth = 140;
      var _loc10_ = Number(detailObj.i);
      var _loc5_ = Number(detailObj.s);
      if(sgroup.cc)
      {
         sgroup.item0.duplicateMovieClip("item" + sgroup.cc,sgroup.cc);
      }
      else
      {
         sgroup.cc = 0;
      }
      var _loc2_ = sgroup["item" + sgroup.cc];
      classes.mc.TourneyEventList.listArr.push(_loc2_);
      _loc2_._x = sgroup.cc * _loc9_;
      _loc2_.detailObj = detailObj;
      _loc2_.descr = descr;
      _loc2_.entryReq = entryReq;
      _loc2_.hwidth = hwidth;
      _loc2_.fldDay.text = classes.NumFuncs.dayName(d.getUTCDay()).toUpperCase() + d.getUTCDate();
      _loc2_.fldDay._visible = false;
      var _loc6_ = classes.NumFuncs.getHoursAmPm(d.getUTCHours());
      _loc2_.fldTime.text = _loc6_.hours + ":" + classes.NumFuncs.get2Mins(d.getUTCMinutes()) + " " + _loc6_.ampm + " PT";
      _loc2_.fldTime._visible = false;
      var _loc7_;
      if(_loc5_ == 1)
      {
         _loc2_.onEnterFrame = function()
         {
            this.fldDay._xscale = 100 * this.hwidth / this.fldDay._width;
            this.fldTime._xscale = 100 * this.hwidth / this.fldTime._width;
            this.fldDay._visible = true;
            this.fldTime._visible = true;
            delete this.onEnterFrame;
         };
      }
      else
      {
         _loc2_.line._visible = false;
         if(_loc5_ == 0)
         {
            _loc2_.fldStatus.text = "CLOSED";
         }
         else if(_loc5_ == 2)
         {
            _loc2_.fldStatus.text = "QUALIFYING";
            _loc7_ = new TextFormat();
            _loc7_.color = 44329;
            _loc2_.fldStatus.setTextFormat(_loc7_);
         }
      }
      sgroup.fold._x = sgroup._width + 30;
      classes.mc.TourneyEventList.xRightBound = sgroup._x + sgroup._width;
      sgroup.monthMask._width = sgroup.fold._x - 12;
      if(Number(d) > 0)
      {
         sgroup.fldMonth.text += " " + classes.NumFuncs.monthName(d.getUTCMonth()).toUpperCase() + "  " + classes.NumFuncs.monthName(d.getUTCMonth()).toUpperCase() + " ";
      }
      sgroup.cc = sgroup.cc + 1;
   }
   function startListLoader()
   {
      if(!this.listNodes.length)
      {
         this._visible = false;
         return undefined;
      }
      this.loadcc = 0;
      this.tcc = 0;
      this.onEnterFrame = function()
      {
         var _loc2_;
         if(this.loadcc < this.listNodes.length && this.loadcc < 5)
         {
            if(this.tcc % 5 == 0)
            {
               classes.mc.TourneyEventList.listArr[this.loadcc].tog.loadin.loadMovie("cache/tournaments/eli_" + this.listNodes[this.loadcc].attributes.it + ".swf");
               this.loadcc = this.loadcc + 1;
            }
            this.tcc = this.tcc + 1;
         }
         else
         {
            if(this.loadcc < this.listNodes.length)
            {
               this.loadcc = this.loadcc;
               while(this.loadcc < this.listNodes.length)
               {
                  classes.mc.TourneyEventList.listArr[this.loadcc].tog.loadin.loadMovie("cache/tournaments/eli_" + this.listNodes[this.loadcc].attributes.it + ".swf");
                  this.loadcc = this.loadcc + 1;
               }
            }
            _loc2_ = 0;
            while(_loc2_ < classes.mc.TourneyEventList.listArr.length)
            {
               classes.mc.TourneyEventList.listArr[_loc2_].tog.idx = _loc2_;
               _loc2_ = _loc2_ + 1;
            }
            this.setScrollerControl();
         }
      };
   }
   function setScrollerControl()
   {
      if(classes.mc.TourneyEventList.xRightBound <= 800)
      {
         delete this.onEnterFrame;
         return undefined;
      }
      this.onEnterFrame = function()
      {
         if(this._xmouse > 0 && this._xmouse < 800 && this._ymouse > 0 && this._ymouse < 270)
         {
            this.scrollGroup.tx = (- this._xmouse / 800) * (classes.mc.TourneyEventList.xRightBound - 800);
            this.scrollGroup._x += (this.scrollGroup.tx - this.scrollGroup._x) / 3;
         }
      };
   }
   static function selectEvent(idx)
   {
      var _loc1_ = 0;
      while(_loc1_ < classes.mc.TourneyEventList.listArr.length)
      {
         if(_loc1_ == idx)
         {
            classes.mc.TourneyEventList.listArr[_loc1_].tog.gotoAndPlay("fadeIn");
         }
         else if(classes.mc.TourneyEventList.listArr[_loc1_].tog.fadedIn)
         {
            classes.mc.TourneyEventList.listArr[_loc1_].tog.gotoAndPlay("fadeOut");
         }
         _loc1_ = _loc1_ + 1;
      }
      var _loc3_ = classes.mc.TourneyEventList._mc.listNodes[idx].attributes;
      classes.mc.TourneyEventList._mc._parent.setDetail(_loc3_,classes.mc.TourneyEventList.listArr[idx].fldTime.text,classes.mc.TourneyEventList.listArr[idx].entryReq,classes.mc.TourneyEventList.listArr[idx].descr);
   }
}
