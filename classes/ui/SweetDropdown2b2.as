class classes.ui.SweetDropdown2b2
{
   var __autoSelect;
   var __baseGraphicHeight;
   var __itemHeight;
   var __itemWidth;
   var __selectedItemIndex;
   var _height;
   var _parent;
   var _width;
   var _xmouse;
   var _ymouse;
   var _yscale;
   var baseFont;
   var baseMovie;
   var beginFill;
   var clear;
   var endFill;
   var itemFont;
   var itemOpened;
   var lastItem;
   var lineTo;
   var linkageID;
   var mask;
   var moveTo;
   var onEnterFrame;
   var owner;
   var parentClip;
   var scrollBarMC;
   var scrollCollMC;
   var scrollDownMC;
   var scrollMC;
   var scrollUpMC;
   var scrollerMC;
   var selectedTextField;
   var __itemBorderColor = 10066329;
   var __itemBaseColor = 16777215;
   var __itemRollOverColor = 14671839;
   var __scrollOffset = -20;
   var __scrollWidth = 10;
   var __scrollHeight = 100;
   var __scrollArrowHeight = 7;
   var __scrollBarWidth = 2;
   var __scrollerWidth = 5;
   var __scrollerTravel = 0;
   var __numItems = 0;
   var __itemArray = new Array();
   var __selectedItemText = "";
   var selectedItemGraphic = "";
   var __listeners = new Array();
   var __clickable = true;
   var itemBlock = 0;
   static var dropdownCollection = new Array();
   function SweetDropdown2b2(p, baseGraphicToLoad, baseFontToLoad, itemFontToLoad, scrollHeight, scrollOffset, autoSelect, itemWidth, itemHeight)
   {
      this.__autoSelect = autoSelect;
      this.baseFont = baseFontToLoad;
      this.itemFont = itemFontToLoad;
      this.parentClip = p;
      this.linkageID = baseGraphicToLoad;
      if(scrollHeight)
      {
         this.__scrollHeight = scrollHeight;
      }
      if(scrollOffset)
      {
         this.__scrollOffset = scrollOffset;
      }
      if(itemWidth)
      {
         this.__itemWidth = itemWidth;
      }
      if(itemHeight)
      {
         this.__itemHeight = itemHeight;
      }
      classes.ui.SweetDropdown2b2.pruneDropdownCollection();
      classes.ui.SweetDropdown2b2.dropdownCollection.push(this);
      this.init();
      trace("dropdownCollection...");
      trace(classes.ui.SweetDropdown2b2.dropdownCollection);
   }
   function set clickable(c)
   {
      this.__clickable = c;
      this.baseMovie.baseGraphic.arrow_mc._visible = c;
   }
   static function pruneDropdownCollection()
   {
      trace("pruneDropdownCollection");
      for(var _loc1_ in classes.ui.SweetDropdown2b2.dropdownCollection)
      {
         trace(classes.ui.SweetDropdown2b2.dropdownCollection[_loc1_].baseMovie.toString());
         if(classes.ui.SweetDropdown2b2.dropdownCollection[_loc1_].baseMovie.toString() == undefined)
         {
            trace("destroyed");
            classes.ui.SweetDropdown2b2.dropdownCollection[_loc1_].destroy();
         }
      }
   }
   function init()
   {
      this.__itemArray = new Array();
      this.__listeners = new Array();
      this.itemOpened = false;
      this.itemBlock = 0;
      var _loc3_ = this.parentClip.getNextHighestDepth();
      this.baseMovie = this.parentClip.createEmptyMovieClip("baseMovie" + _loc3_,_loc3_);
      this.baseMovie.attachMovie(this.linkageID,"baseGraphic",this.baseMovie.getNextHighestDepth());
      this.baseMovie.owner = this;
      this.baseMovie.baseGraphic._alpha = 100;
      this.__baseGraphicHeight = this.baseMovie.baseGraphic._height;
      if(!this.__itemWidth)
      {
         this.__itemWidth = this.baseMovie._width - this.__scrollWidth;
      }
      if(!this.__itemHeight)
      {
         this.__itemHeight = this.__baseGraphicHeight;
      }
      this.baseMovie.createTextField("selectedText",this.baseMovie.getNextHighestDepth(),8,4,this.__itemWidth - 20,this.__baseGraphicHeight);
      this.selectedTextField = this.baseMovie.selectedText;
      this.selectedTextField.wordWrap = true;
      this.selectedTextField.multiline = true;
      var _loc2_ = new TextFormat();
      _loc2_.color = 5395026;
      _loc2_.bold = true;
      _loc2_.size = 12;
      _loc2_.font = this.baseFont;
      this.baseMovie.selectedText.embedFonts = true;
      this.baseMovie.selectedText.antiAliasType = "advanced";
      this.baseMovie.selectedText.setNewTextFormat(_loc2_);
      this.baseMovie.selectedText.text = "";
      this.baseMovie.selectedText.selectable = false;
      this.baseMovie.baseGraphic.owner = this;
      this.baseMovie.baseGraphic.onRelease = function()
      {
         if(this.owner.__clickable)
         {
            if(this.owner.itemOpened)
            {
               this.owner.closeItems();
            }
            else
            {
               this.owner.openItems();
               this.owner.closeOtherDropdowns(this.owner);
            }
         }
      };
      this.buildScroller();
   }
   function buildScroller()
   {
      this.scrollMC = this.baseMovie.createEmptyMovieClip("scrollMC",this.baseMovie.getNextHighestDepth());
      this.scrollMC.owner = this;
      this.scrollMC._y = this.__scrollOffset;
      this.scrollMC.beginFill(this.__itemBaseColor,100);
      this.scrollMC.moveTo(0,0);
      this.scrollMC.lineTo(this.__itemWidth + this.__scrollWidth,0);
      this.scrollMC.lineTo(this.__itemWidth + this.__scrollWidth,this.__scrollHeight);
      this.scrollMC.lineTo(0,this.__scrollHeight);
      this.scrollMC.lineTo(0,0);
      this.scrollMC.endFill();
      this.mask = this.baseMovie.createEmptyMovieClip("mask",this.baseMovie.getNextHighestDepth());
      this.mask._y = this.__scrollOffset;
      this.mask.clear();
      this.mask.beginFill(0,100);
      this.mask.moveTo(0,0);
      this.mask.lineTo(this.__itemWidth + this.__scrollWidth,0);
      this.mask.lineTo(this.__itemWidth + this.__scrollWidth,this.__scrollHeight);
      this.mask.lineTo(0,this.__scrollHeight);
      this.mask.lineTo(0,0);
      this.mask.endFill();
      this.mask._visible = false;
      this.scrollMC.setMask(this.mask);
      this.scrollCollMC = this.scrollMC.createEmptyMovieClip("scrollCollMC",this.scrollMC.getNextHighestDepth());
      this.scrollUpMC = this.scrollMC.createEmptyMovieClip("scrollUpMC",this.scrollMC.getNextHighestDepth());
      this.scrollUpMC.beginFill(this.__itemBorderColor,100);
      this.scrollUpMC.moveTo(1,this.__scrollArrowHeight);
      this.scrollUpMC.lineTo(this.__scrollWidth,this.__scrollArrowHeight);
      this.scrollUpMC.lineTo((1 + this.__scrollWidth) / 2,0);
      this.scrollUpMC.moveTo(1,this.__scrollArrowHeight);
      this.scrollUpMC.endFill();
      this.scrollUpMC._x = this.__itemWidth;
      this.scrollUpMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            var _loc2_ = this._parent.scrollerMC._y - this._parent._parent.mask._height / 50;
            this._parent._parent.owner.updateScroller(_loc2_);
         };
      };
      this.scrollUpMC.onRelease = this.scrollUpMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
      this.scrollDownMC = this.scrollMC.createEmptyMovieClip("scrollDownMC",this.scrollMC.getNextHighestDepth());
      this.scrollDownMC.beginFill(this.__itemBorderColor,100);
      this.scrollDownMC.moveTo(1,0);
      this.scrollDownMC.lineTo(this.__scrollWidth,0);
      this.scrollDownMC.lineTo((1 + this.__scrollWidth) / 2,this.__scrollArrowHeight);
      this.scrollDownMC.lineTo(1,0);
      this.scrollDownMC.endFill();
      this.scrollDownMC._y = this.__scrollHeight - this.__scrollArrowHeight;
      this.scrollDownMC._x = this.__itemWidth;
      this.scrollDownMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            var _loc2_ = this._parent.scrollerMC._y + this._parent._parent.mask._height / 50;
            this._parent._parent.owner.updateScroller(_loc2_);
         };
      };
      this.scrollDownMC.onRelease = this.scrollDownMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
      this.scrollBarMC = this.scrollMC.createEmptyMovieClip("scrollBarMC",this.scrollMC.getNextHighestDepth());
      this.scrollBarMC.beginFill(this.__itemBaseColor,100);
      this.scrollBarMC.moveTo(0,0);
      this.scrollBarMC.lineTo(this.__scrollBarWidth,0);
      this.scrollBarMC.lineTo(this.__scrollBarWidth,this.__scrollHeight - 2 * (this.__scrollArrowHeight + 2));
      this.scrollBarMC.lineTo(0,this.__scrollHeight - 2 * (this.__scrollArrowHeight + 2));
      this.scrollBarMC.lineTo(0,0);
      this.scrollBarMC.endFill();
      this.scrollBarMC._x = Math.ceil(this.__itemWidth + (this.__scrollWidth - this.__scrollBarWidth) / 2);
      this.scrollBarMC._y = this.__scrollArrowHeight + 2;
      this.scrollerMC = this.scrollMC.createEmptyMovieClip("scrollerMC",this.scrollMC.getNextHighestDepth());
      this.scrollerMC.beginFill(this.__itemBorderColor,100);
      this.scrollerMC.moveTo(0,0);
      this.scrollerMC.lineTo(this.__scrollerWidth,0);
      this.scrollerMC.lineTo(this.__scrollerWidth,this.__scrollHeight - 2 * (this.__scrollArrowHeight + 2));
      this.scrollerMC.lineTo(0,this.__scrollHeight - 2 * (this.__scrollArrowHeight + 2));
      this.scrollerMC.lineTo(0,0);
      this.scrollerMC.endFill();
      this.scrollerMC._x = Math.ceil(this.__itemWidth + (this.__scrollWidth - this.__scrollerWidth) / 2);
      this.scrollerMC._y = this.__scrollArrowHeight + 2;
      this.scrollerMC.onPress = function()
      {
         this.onEnterFrame = function()
         {
            var _loc2_ = this._parent._ymouse - this._height / 2;
            this._parent._parent.owner.updateScroller(_loc2_);
         };
      };
      this.scrollerMC.onRelease = this.scrollerMC.onReleaseOutside = function()
      {
         delete this.onEnterFrame;
      };
   }
   function updateScroller(newY)
   {
      trace("updateScroller");
      if(newY < this.scrollBarMC._y)
      {
         newY = this.scrollBarMC._y;
      }
      else if(newY > this.__scrollerTravel)
      {
         newY = this.__scrollerTravel;
      }
      this.scrollerMC._y = newY;
      var _loc3_ = (newY - this.scrollBarMC._y) / (this.__scrollerTravel - this.scrollBarMC._y);
      this.scrollCollMC._y = (- _loc3_) * (this.itemBlock * this.__itemHeight - this.__scrollHeight);
   }
   function closeOtherDropdowns(sd)
   {
      for(var _loc2_ in classes.ui.SweetDropdown2b2.dropdownCollection)
      {
         if(classes.ui.SweetDropdown2b2.dropdownCollection[_loc2_] != sd)
         {
            classes.ui.SweetDropdown2b2.dropdownCollection[_loc2_].closeItems();
         }
      }
   }
   function addListener(o)
   {
      this.__listeners.push(o);
   }
   function broadcastItemChangeEvent()
   {
      var _loc3_;
      _loc3_ = this.__itemArray[this.__selectedItemIndex];
      var _loc2_ = 0;
      while(_loc2_ < this.__listeners.length)
      {
         this.__listeners[_loc2_].onItemChanged(_loc3_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function set numItems(n)
   {
      this.__numItems = n;
   }
   function set selectedItemText(t)
   {
      if(t != undefined)
      {
         this.__selectedItemText = t;
         this.selectedTextField.text = t;
         this.broadcastItemChangeEvent();
      }
   }
   function setDefaultText(defaultText)
   {
      trace("setDefaultText: " + defaultText);
      this.__selectedItemText = defaultText;
      this.selectedTextField.text = defaultText;
   }
   function repopulateDropdown()
   {
      for(var _loc2_ in this.scrollCollMC)
      {
         removeMovieClip(this.scrollCollMC[_loc2_]);
      }
      this.__itemArray = new Array();
      this.itemBlock = 0;
      this.closeItems();
   }
   function getLabelFromValue(val)
   {
      trace("getLabelFromValue: " + val);
      var _loc2_ = 0;
      while(_loc2_ < this.__itemArray.length)
      {
         if(this.__itemArray[_loc2_].value == val)
         {
            return this.__itemArray[_loc2_].label;
         }
         _loc2_ = _loc2_ + 1;
      }
      return "";
   }
   function addItem(o)
   {
      this.__itemArray.push(o);
   }
   function set x(x)
   {
      this.baseMovie._x = x;
   }
   function set y(y)
   {
      this.baseMovie._y = y;
   }
   function openItems()
   {
      this.itemOpened = true;
      this.mask.onEnterFrame = function()
      {
         this._yscale += (100 - this._yscale) / 1.5;
         if(this._yscale >= 80)
         {
            if(this._xmouse > this._width - 2 || this._xmouse < 0 || Number(this._ymouse + 19) > this._height || Number(this._ymouse + 19) < 0)
            {
               delete this.onEnterFrame;
               this._parent.owner.closeItems();
            }
         }
         if(this._yscale >= 100)
         {
            this._yscale = 100;
         }
      };
   }
   function closeItems()
   {
      this.itemOpened = false;
      this.mask.onEnterFrame = function()
      {
         this._yscale += (- this._yscale) / 1.5;
         if(this._yscale <= 0)
         {
            this._yscale = 0;
            delete this.onEnterFrame;
         }
      };
   }
   function renderItems()
   {
      var _loc3_;
      if(this.__itemArray.length * this.__itemHeight <= this.__scrollHeight)
      {
         _loc3_ = false;
      }
      else
      {
         _loc3_ = true;
      }
      var _loc2_ = 0;
      while(_loc2_ < this.__itemArray.length)
      {
         this.createItemBlock(_loc2_,this.__itemArray[_loc2_].label,_loc3_);
         _loc2_ = _loc2_ + 1;
      }
      if(this.__autoSelect)
      {
         this.__selectedItemIndex = 0;
         this.selectedItemText = this.__itemArray[0].label;
      }
      this.resetScroller(_loc3_);
   }
   function resetScroller(showScroller)
   {
      this.scrollCollMC._y = 0;
      var _loc2_;
      if(showScroller)
      {
         this.scrollerMC._visible = this.scrollUpMC._visible = this.scrollDownMC._visible = this.scrollBarMC._visible = true;
         this.scrollerMC._y = this.scrollBarMC._y;
         _loc2_ = this.__scrollHeight / (this.itemBlock * this.__itemHeight) * 100;
         if(_loc2_ > 100)
         {
            _loc2_ = 100;
         }
         this.scrollerMC._yscale = _loc2_;
         this.__scrollerTravel = this.scrollBarMC._y + this.scrollBarMC._height - this.scrollerMC._height;
      }
      else
      {
         this.scrollerMC._visible = this.scrollUpMC._visible = this.scrollDownMC._visible = this.scrollBarMC._visible = false;
      }
   }
   function toString()
   {
      return "SweetDropdown2b Obj:";
   }
   function createItemBlock(theIndex, itemText, showScroller)
   {
      var ib = this.scrollCollMC.createEmptyMovieClip("item_" + this.itemBlock,this.scrollCollMC.getNextHighestDepth());
      ib.myIndex = theIndex;
      ib.createEmptyMovieClip("back",ib.getNextHighestDepth());
      ib.createEmptyMovieClip("border",ib.getNextHighestDepth());
      ib._y = 0 + this.__itemHeight * this.itemBlock;
      this.lastItem = ib;
      ib._x = 0;
      ib.owner = this;
      if(showScroller)
      {
         ib.itemWidth = this.__itemWidth;
      }
      else
      {
         ib.itemWidth = this.__itemWidth + this.__scrollWidth;
      }
      ib.back.onRollOver = function()
      {
         trace("onRollOver!");
         this.clear();
         this.beginFill(this._parent.owner.__itemRollOverColor,100);
         this.moveTo(0,0);
         this.lineTo(this._parent.itemWidth,0);
         this.lineTo(this._parent.itemWidth,this._parent.owner.__itemHeight);
         this.lineTo(0,this._parent.owner.__itemHeight);
         this.lineTo(0,0);
         this.endFill();
      };
      ib.back.onRelease = function()
      {
         this._parent.owner.__selectedItemIndex = this._parent.myIndex;
         this._parent.owner.selectedItemText = this._parent.itemText.text;
         this._parent.owner.closeItems();
      };
      ib.back.onRollOut = ib.back.onReleaseOutside = function()
      {
         this.clear();
         this.beginFill(this._parent.owner.__itemBaseColor,100);
         this.moveTo(0,0);
         this.lineTo(this._parent.itemWidth,0);
         this.lineTo(this._parent.itemWidth,this._parent.owner.__itemHeight);
         this.lineTo(0,this._parent.owner.__itemHeight);
         this.lineTo(0,0);
         this.endFill();
      };
      with(ib.border)
      {
         lineStyle(0.5,_parent.owner.__itemBorderColor,100);
         moveTo(0,0);
         lineTo(_parent.itemWidth,0);
         lineTo(_parent.itemWidth,_parent.owner.__itemHeight);
         lineTo(0,_parent.owner.__itemHeight);
         lineTo(0,0);
      }
      ib.back.onRollOut();
      var tf = new TextFormat();
      tf.color = 5395026;
      tf.bold = true;
      tf.size = 12;
      tf.font = this.itemFont;
      ib.createTextField("itemText",ib.getNextHighestDepth(),5,2,150,19.6);
      ib.itemText.embedFonts = true;
      ib.itemText.antiAliasType = "advanced";
      ib.itemText.text = itemText;
      ib.itemText.selectable = false;
      ib.itemText.setTextFormat(tf);
      trace("item block height: " + ib._height);
      this.itemBlock++;
   }
   function setVisible(v)
   {
      this.baseMovie._visible = v;
   }
   function remove()
   {
      removeMovieClip(this.baseMovie);
   }
   function destroy()
   {
      var _loc3_ = classes.ui.SweetDropdown2b2.dropdownCollection.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         if(classes.ui.SweetDropdown2b2.dropdownCollection[_loc2_] == this)
         {
            classes.ui.SweetDropdown2b2.dropdownCollection.splice(_loc2_,1);
            _loc3_ = _loc3_ - 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      false;
      this.__listeners.splice(0);
   }
}
