class controls.ScrollBar extends MovieClip
{
   var _BASE;
   var _downArrowMC;
   var _scrollBodyMC;
   var _scrollerMC;
   var _txt;
   var _upArrowMC;
   var onEnterFrame;
   var owner;
   var _scrollerPressed = false;
   function ScrollBar(txt, hgt, xPos, yPos, depth)
   {
      super();
      this._txt = txt;
      if(hgt == undefined)
      {
         hgt = this._txt._height;
      }
      if(xPos == undefined)
      {
         xPos = this._txt._x + this._txt._width;
      }
      if(yPos == undefined)
      {
         yPos = this._txt._y;
      }
      if(depth == undefined)
      {
         depth = this._txt._parent.getNextHighestDepth();
      }
      this.init(hgt,xPos,yPos,depth);
   }
   function init(hgt, xPos, yPos, depth)
   {
      this._BASE = this._txt._parent.createEmptyMovieClip(this._txt._name + "ScrollBar",depth);
      this._BASE._x = xPos;
      this._BASE._y = yPos;
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
      trace("scroller body height");
      trace(this._scrollBodyMC._height);
      this._upArrowMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            if(this.owner._txt.scroll > 1)
            {
               this.owner._txt.scroll--;
            }
            else
            {
               delete this.onEnterFrame;
            }
         };
      };
      this._downArrowMC.onPress = function()
      {
         trace(this.owner._txt.maxscroll);
         trace(this.owner._txt.scroll);
         this.onEnterFrame = function()
         {
            if(this.owner._txt.scroll < this.owner._txt.maxscroll)
            {
               this.owner._txt.scroll++;
            }
            else
            {
               delete this.onEnterFrame;
            }
         };
      };
      this._upArrowMC.onRelease = this._upArrowMC.onReleaseOutside = this._downArrowMC.onRelease = this._downArrowMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
      this._scrollerMC.onPress = function()
      {
         this.owner._scrollerPressed = true;
         this.startDrag(false,this._x,this._parent._upArrowMC._height,this._x,this._parent._upArrowMC._height + this._parent._scrollBodyMC._height - this._height + 1);
         this.onEnterFrame = function()
         {
            var _loc2_ = (this._y - this._parent._upArrowMC._height) / (this._parent._scrollBodyMC._height - this._height);
            this.owner._txt.scroll = 1 + _loc2_ * (this.owner._txt.maxscroll - 1);
         };
      };
      this._scrollerMC.onRelease = this._scrollerMC.onReleaseOutside = function()
      {
         this.stopDrag();
         delete this.onEnterFrame;
         this.owner._scrollerPressed = false;
      };
      this._scrollBodyMC.onPress = function()
      {
         if(this._ymouse < this._parent._scrollerMC._y)
         {
            this.owner._txt.scroll -= this.owner._txt.bottomScroll - this.owner._txt.scroll;
         }
         else
         {
            this.owner._txt.scroll += this.owner._txt.bottomScroll - this.owner._txt.scroll;
         }
      };
      this._txt.owner = this;
      this._txt.onScroller = function(t)
      {
         if(!this.owner._scrollerPressed)
         {
            this.owner.updateScroller();
         }
      };
      this.refreshScroller();
   }
   function refreshScroller()
   {
      if(this._txt.maxscroll > 1)
      {
         this._BASE._visible = true;
         this.resizeScroller();
      }
      else
      {
         this._BASE._visible = false;
      }
   }
   function destroy()
   {
      this._BASE.removeMovieClip();
   }
   function resetScroller(newHeight, newX, newY)
   {
      trace("resetScroller: " + newHeight);
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
   function resizeScroller()
   {
      trace("scroller body height");
      trace(this._scrollBodyMC._height);
      if(this._txt.maxscroll <= 1)
      {
         trace("max scroll <= 1");
         this._scrollerMC.middle._height = this._scrollBodyMC._height;
         trace(this._scrollerMC.middle._height);
      }
      else
      {
         trace("max scroll > 1");
         this._scrollerMC.middle._height = this._scrollBodyMC._height * this._scrollBodyMC._height / this._txt.textHeight;
         trace(this._scrollerMC.middle._height);
      }
      this._scrollerMC.bottomCap._y = this._scrollerMC.middle._height - this._scrollerMC.bottomCap._height;
      this.updateScroller();
   }
   function updateScroller()
   {
      var _loc2_ = (this._txt.scroll - 1) / (this._txt.maxscroll - 1);
      this._scrollerMC._y = this._upArrowMC._height + _loc2_ * (this._scrollBodyMC._height - this._scrollerMC._height);
   }
}
