class controls.ScrollPane extends MovieClip
{
   var _BASE;
   var _downArrowMC;
   var _mv;
   var _mvmask;
   var _scrollBodyMC;
   var _scrollerMC;
   var _speed;
   var _upArrowMC;
   var onEnterFrame;
   var owner;
   function ScrollPane(mv, maskWidth, maskHeight, speed, hgt, xPos, yPos, depth)
   {
      super();
      this._mv = mv;
      trace("movie: " + this._mv);
      if(!maskWidth)
      {
         maskWidth = this._mv._width;
      }
      this._mvmask = this._mv._parent.createEmptyMovieClip(this._mv._name + "Mask",this._mv._parent.getNextHighestDepth());
      this._mvmask._x = this._mv._x;
      this._mvmask._y = this._mv._y;
      this._mvmask.beginFill(16777215,50);
      this._mvmask.moveTo(0,0);
      this._mvmask.lineTo(maskWidth,0);
      this._mvmask.lineTo(maskWidth,maskHeight);
      this._mvmask.lineTo(0,maskHeight);
      this._mvmask.lineTo(0,0);
      this._mvmask.endFill();
      this._mv.setMask(this._mvmask);
      if(speed == undefined)
      {
         speed = 10;
      }
      if(hgt == undefined)
      {
         hgt = this._mvmask._height;
      }
      if(xPos == undefined)
      {
         xPos = this._mvmask._x + this._mvmask._width;
      }
      if(yPos == undefined)
      {
         yPos = this._mvmask._y;
      }
      if(depth == undefined)
      {
         depth = this._mvmask._parent.getNextHighestDepth();
      }
      this.init(speed,hgt,xPos,yPos,depth);
   }
   function init(speed, hgt, xPos, yPos, depth)
   {
      trace("init");
      this._speed = speed;
      if(this._mv._parent._mvmask.getDepth() == depth)
      {
         this._mv._parent._mvmask.swapDepths(this._mv._parent.getNextHighestDepth());
      }
      this._BASE = this._mv._parent.createEmptyMovieClip(this._mv._name + "ScrollBar",depth);
      trace("BASE");
      trace(this._BASE);
      this._BASE._x = xPos;
      this._BASE._y = yPos;
      trace(this._BASE._x);
      trace(this._BASE._y);
      this._upArrowMC = this._BASE.attachMovie("scrollbarUpArrow","_upArrowMC",this._BASE.getNextHighestDepth());
      this._upArrowMC.owner = this;
      this._downArrowMC = this._BASE.attachMovie("scrollbarDownArrow","_downArrowMC",this._BASE.getNextHighestDepth());
      this._downArrowMC._y = hgt - this._downArrowMC._height;
      this._downArrowMC.owner = this;
      this._scrollBodyMC = this._BASE.attachMovie("scrollbarBody","_scrollBodyMC",this._BASE.getNextHighestDepth());
      this._scrollBodyMC._y = this._upArrowMC._height;
      this._scrollBodyMC.owner = this;
      this._scrollBodyMC.middle._height = hgt - this._upArrowMC._height - this._downArrowMC._height;
      this._scrollBodyMC.bottomCap._y = this._scrollBodyMC.middle._height - this._scrollBodyMC.bottomCap._height;
      this._scrollerMC = this._BASE.attachMovie("scrollbarScroller","_scrollerMC",this._BASE.getNextHighestDepth());
      this._scrollerMC._y = this._upArrowMC._height;
      this._scrollerMC.owner = this;
      trace(this._BASE._height);
      this._upArrowMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            var _loc2_ = this.owner._mv._y + this.owner._speed;
            if(_loc2_ > this.owner._mvmask._y)
            {
               _loc2_ = this.owner._mvmask._y;
            }
            this.owner._mv._y = _loc2_;
            this.owner.updateScroller();
         };
      };
      this._downArrowMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            var _loc2_ = this.owner._mv._y - this.owner._speed;
            if(_loc2_ < - (this.owner._mv._height - this.owner._mvmask._height - this.owner._mvmask._y))
            {
               _loc2_ = - (this.owner._mv._height - this.owner._mvmask._height - this.owner._mvmask._y);
            }
            this.owner._mv._y = _loc2_;
            this.owner.updateScroller();
         };
      };
      this._upArrowMC.onRelease = this._upArrowMC.onReleaseOutside = this._downArrowMC.onRelease = this._downArrowMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
      this._scrollerMC.onPress = function()
      {
         this.startDrag(false,this._x,this._parent._upArrowMC._height,this._x,this._parent._upArrowMC._height + this._parent._scrollBodyMC._height - this._height + 1);
         this.onEnterFrame = function()
         {
            var _loc2_ = (this._y - this._parent._upArrowMC._height) / (this._parent._scrollBodyMC._height - this._height);
            this.owner._mv._y = this.owner._mvmask._y - _loc2_ * (this.owner._mv._height - this.owner._mvmask._height);
         };
      };
      this._scrollerMC.onRelease = this._scrollerMC.onReleaseOutside = function()
      {
         this.stopDrag();
         delete this.onEnterFrame;
      };
      this._scrollBodyMC.onPress = function()
      {
         var _loc2_;
         if(this._ymouse < this._parent._scrollerMC._y)
         {
            _loc2_ = this.owner._mv._y + this.owner._mvmask._height;
            if(_loc2_ > this.owner._mvmask._y)
            {
               _loc2_ = this.owner._mvmask._y;
            }
            this.owner._mv._y = _loc2_;
            this.owner.updateScroller();
         }
         else
         {
            _loc2_ = this.owner._mv._y - this.owner._mvmask._height;
            if(_loc2_ < - (this.owner._mv._height - this.owner._mvmask._height - this.owner._mvmask._y))
            {
               _loc2_ = - (this.owner._mv._height - this.owner._mvmask._height - this.owner._mvmask._y);
            }
            this.owner._mv._y = _loc2_;
            this.owner.updateScroller();
         }
      };
      this.refreshScroller();
   }
   function refreshScroller()
   {
      trace(this._mv._height);
      trace(this._mvmask._height);
      if(this._mv._height > this._mvmask._height)
      {
         trace("visible");
         trace(this._BASE._y);
         this._BASE._visible = true;
         this.resizeScroller();
      }
      else
      {
         trace("invisible");
         this._BASE._visible = false;
         this._mv._y = this._mvmask._y;
      }
   }
   function destroy()
   {
      this._mvmask.removeMovieClip();
      this._BASE.removeMovieClip();
   }
   function setSizeMask(newWidth, newHeight)
   {
      if(!newWidth)
      {
         newWidth = this._mvmask._width;
      }
      if(!newHeight)
      {
         newHeight = this._mvmask._height;
      }
      this._mvmask._width = newWidth;
      this._mvmask._height = newHeight;
   }
   function resetMask(newX, newY, newW, newH)
   {
      if(newX != undefined)
      {
         this._mvmask._x = newX;
      }
      if(newY != undefined)
      {
         this._mvmask._y = newY;
      }
      if(newW != undefined)
      {
         this._mvmask._width = newW;
      }
      if(newH != undefined)
      {
         this._mvmask._height = newH;
      }
   }
   function resetScroller(newHeight, newX, newY)
   {
      if(!newHeight)
      {
         newHeight = this._BASE._height;
      }
      if(newX == undefined)
      {
         newX = this._BASE._x;
      }
      if(!newY == undefined)
      {
         newY = this._BASE._y;
      }
      with(this._BASE)
      {
         _x = newX;
         _y = newY;
         _downArrowMC._y = newHeight - _downArrowMC._height;
         _scrollBodyMC._y = _upArrowMC._height;
         _scrollBodyMC.middle._height = newHeight - _upArrowMC._height - _downArrowMC._height;
         _scrollBodyMC.bottomCap._y = _scrollBodyMC.middle._height - _scrollBodyMC.bottomCap._height;
      }
      this.refreshScroller();
   }
   function setScrollToTop()
   {
      trace("setScrollToTop");
      this._mv._y = this._mvmask._y;
      this.refreshScroller();
   }
   function get scrollDistance()
   {
      return this._mv._y - this._mvmask._y;
   }
   function resizeScroller()
   {
      this._scrollerMC.middle._height = this._scrollBodyMC._height * this._mvmask._height / this._mv._height;
      if(this._scrollerMC.middle._height > this._scrollBodyMC._height)
      {
         this._scrollerMC.middle._height = this._scrollBodyMC._height;
      }
      this._scrollerMC.bottomCap._y = this._scrollerMC.middle._height - this._scrollerMC.bottomCap._height;
      this.updateScroller();
   }
   function updateScroller()
   {
      var _loc2_ = (this._mvmask._y - this._mv._y) / (this._mv._height - this._mvmask._height);
      if(_loc2_ > 1)
      {
         _loc2_ = 1;
      }
      else if(_loc2_ < 0)
      {
         _loc2_ = 0;
      }
      this._scrollerMC._y = this._upArrowMC._height + _loc2_ * (this._scrollBodyMC._height - this._scrollerMC._height);
   }
}
