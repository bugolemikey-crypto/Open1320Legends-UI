class classes.DialogBox extends MovieClip
{
   var _listener;
   var bgMC;
   var blurBmp;
   var btnArray;
   var contentMC;
   var contentName;
   var xIncrement = -100;
   var xStart = 317;
   var yStart = 7;
   var dontShowTint = false;
   function DialogBox()
   {
      super();
      trace("DialogBox");
      var oWidth = 800;
      var oHeight = 600;
      this.contentMC = this.attachMovie(this.contentName,"contentMC",this.getNextHighestDepth());
      this.btnArray = new Array();
      if(this.dontShowTint == true)
      {
         trace("widths");
         trace(this.contentMC._width);
         trace(Stage.width);
         this.contentMC._x = (Stage.width - this.contentMC._width) / 2;
         this.contentMC._y = (Stage.height - this.contentMC._height) / 2;
         trace("contentMC: ");
         trace(this.contentMC._x);
         trace(this.contentMC._y);
      }
      else
      {
         var myRect = new flash.geom.Rectangle(0,0,Stage.width,Stage.height);
         this.bgMC.onRelease = function()
         {
         };
         this.bgMC.createEmptyMovieClip("tint",this.bgMC.getNextHighestDepth());
         with(this.bgMC.tint)
         {
            beginFill(2019071,40);
            lineTo(myRect.width,0);
            lineTo(myRect.width,myRect.height);
            lineTo(0,myRect.height);
            lineTo(0,0);
            endFill();
         }
         this._x = (oWidth - Stage.width) / 2;
         this._y = (oHeight - Stage.height) / 2;
         trace("centering base box");
         this.contentMC._x = (this.bgMC._width - this.contentMC._width) / 2;
         this.contentMC._y = (this.bgMC._height - this.contentMC._height) / 2;
      }
      this._visible = true;
   }
   function addButton(l, disableClose)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.btnArray.length)
      {
         this.btnArray[_loc2_]._x += this.xIncrement;
         _loc2_ = _loc2_ + 1;
      }
      var _loc3_ = this.contentMC.attachMovie("BaseBoxButton","btntmp" + this.btnArray.length,this.contentMC.getNextHighestDepth(),{_x:this.xStart,_y:this.yStart});
      _loc3_.btnLabel.text = l;
      if(disableClose)
      {
         _loc3_.onRelease = function()
         {
            this._parent._parent._listener.onRelease(this,true);
         };
      }
      else
      {
         _loc3_.onRelease = function()
         {
            this._parent._parent._listener.onRelease(this,false);
            this._parent._parent.closeMe();
         };
      }
      this.btnArray.push(_loc3_);
   }
   function addDisabledButton(l)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.btnArray.length)
      {
         this.btnArray[_loc2_]._x += this.xIncrement;
         _loc2_ = _loc2_ + 1;
      }
      var _loc3_ = this.contentMC.attachMovie("BaseBoxButton","btntmp" + this.btnArray.length,this.contentMC.getNextHighestDepth(),{_x:this.xStart,_y:this.yStart});
      _loc3_.btnLabel.text = l;
      _loc3_.btnLabel._alpha = 30;
      this.btnArray.push(_loc3_);
   }
   function removeButtons()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.btnArray.length)
      {
         this.btnArray[_loc2_].removeMovieClip();
         _loc2_ = _loc2_ + 1;
      }
      this.btnArray = new Array();
      delete this._listener;
   }
   function clearButtons()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.btnArray.length)
      {
         this.btnArray[_loc2_].removeMovieClip();
         _loc2_ = _loc2_ + 1;
      }
      this.btnArray = new Array();
   }
   function addListener(o)
   {
      trace("DialogBox::addListener");
      this._listener = o;
   }
   function closeMe()
   {
      trace("BaseBox.closeMe");
      delete this._listener;
      this.blurBmp.dispose();
      clearInterval(this.contentMC.timer.countSI);
      this.removeMovieClip();
   }
   function drawboxLine()
   {
      this.contentMC.boxLine.clear();
      var _loc2_;
      if(this.btnArray.length == 0)
      {
         this.contentMC.boxLine.beginFill(0,100);
         this.contentMC.boxLine.lineStyle(1,0,100);
         this.contentMC.boxLine.moveTo(0,0);
         this.contentMC.boxLine.lineTo(this.contentMC._width,0);
         this.contentMC.boxLine.endFill();
      }
      else
      {
         this.contentMC.boxLine.beginFill(0,100);
         this.contentMC.boxLine.lineStyle(1,0,100);
         this.contentMC.boxLine.moveTo(0,0);
         _loc2_ = 0;
         while(_loc2_ < this.btnArray.length)
         {
            this.contentMC.boxLine.lineTo(this.btnArray[_loc2_]._x,0);
            this.contentMC.boxLine.moveTo(this.btnArray[_loc2_]._x + this.btnArray[_loc2_]._width,0);
            _loc2_ = _loc2_ + 1;
         }
         this.contentMC.boxLine.lineTo(this.contentMC._width - 1,0);
         this.contentMC.boxLine.endFill();
         this.contentMC.boxLine.beginFill(16777215,100);
         this.contentMC.boxLine.lineStyle(1,16777215,100);
         this.contentMC.boxLine.moveTo(0,1);
         _loc2_ = 0;
         while(_loc2_ < this.btnArray.length)
         {
            this.contentMC.boxLine.lineTo(this.btnArray[_loc2_]._x,1);
            this.contentMC.boxLine.moveTo(this.btnArray[_loc2_]._x + this.btnArray[_loc2_]._width,1);
            _loc2_ = _loc2_ + 1;
         }
         this.contentMC.boxLine.lineTo(this.contentMC._width - 1,1);
         this.contentMC.boxLine.endFill();
      }
   }
   function addTimer(secs, onTimeOut, intID)
   {
      trace(this.contentMC.timer);
      this.contentMC.timer.cc = secs;
      this.contentMC.timer.digits.txt = this.contentMC.timer.cc;
      this.contentMC.timer._visible = true;
      this.contentMC.timer.count = function(_me)
      {
         trace("timeout count " + _me.cc);
         _me.cc = _me.cc - 1;
         _me.digits.txt = _me.cc;
         trace("intID: " + intID);
         if(_me.cc == undefined)
         {
            clearInterval(intID);
         }
         else if(_me.cc <= 0)
         {
            trace("clearing interval: " + _me.countSI);
            clearInterval(_me.countSI);
            onTimeOut();
         }
      };
      this.contentMC.timer.countSI = setInterval(this.contentMC.timer.count,1000,this.contentMC.timer);
      intID = this.contentMC.timer.countSI;
   }
}
