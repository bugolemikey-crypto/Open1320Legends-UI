class classes.ui.TextSelectDropDown extends classes.ui.SweetDropdown2b2
{
   var __itemHeight;
   var baseMovie;
   var itemCount;
   var itemOpened;
   var mask;
   var menu;
   var scrollCollMC;
   var scrollMC;
   var selectedTextField;
   var _textChangeListeners = new Array();
   function TextSelectDropDown(p, baseGraphicToLoad, baseFontToLoad, itemFontToLoad, scrollHeight, scrollOffset, autoSelect, itemWidth, itemHeight)
   {
      super(p,baseGraphicToLoad,baseFontToLoad,itemFontToLoad,scrollHeight,scrollOffset,autoSelect,itemWidth,itemHeight);
   }
   function init()
   {
      trace("TextSelectDropDown:init");
      super.init();
      this.baseMovie.baseGraphic.onRelease = null;
      this.selectedTextField.type = "input";
      this.selectedTextField.selectable = true;
      var _loc3_ = new Object();
      _loc3_.menu = this;
      _loc3_.onChanged = function(textfield_txt)
      {
         trace("the value of " + textfield_txt._name + " was changed. New value is: " + textfield_txt.text);
         trace("hey!");
         trace(this);
         trace(this.menu);
         this.menu.broadcastTextChangeEvent(textfield_txt.text);
      };
      this.selectedTextField.addListener(_loc3_);
   }
   function buildScroller()
   {
      super.buildScroller();
      trace("scrollMC._y: " + this.scrollMC._y);
   }
   function createItemBlock(theIndex, itemText, showScroller)
   {
      trace("itemBlock: " + this.itemBlock);
      trace("itemHeight: " + this.__itemHeight);
      super.createItemBlock(theIndex,itemText,showScroller);
   }
   function openItems()
   {
      this.itemOpened = true;
      this.mask.itemHeight = this.__itemHeight;
      this.mask.itemCount = this.itemCount;
      this.mask._height = this.__itemHeight * this.itemCount;
      if(this.mask._height > this.__scrollHeight)
      {
         this.mask._height = this.__scrollHeight;
      }
      trace("TextSelectDropDown::openItems");
      trace(this.scrollMC._height);
      trace(this.mask._height);
      trace(this.mask._yscale);
      trace(this.mask._y);
      trace("item height");
      trace(this.__itemHeight);
      trace("scroll height");
      trace(this.scrollCollMC.item_0._height);
      trace(this.scrollMC._height);
      trace(this.scrollMC._yscale);
      trace("ib scale: ");
      trace(this.scrollCollMC.item_0._yscale);
      trace(this.scrollCollMC._yscale);
      trace(this.__itemHeight);
   }
   function closeItems()
   {
      trace("SweetDropdown2b::CloseItems");
      this.itemOpened = false;
      this.mask._height = 0;
   }
   function addTextChangeListener(o)
   {
      trace("addTextChangeListener");
      trace(o);
      this._textChangeListeners.push(o);
   }
   function broadcastTextChangeEvent(theText)
   {
      trace("hey2!");
      trace("broadcastTextChangeEvent");
      var _loc2_ = 0;
      while(_loc2_ < this._textChangeListeners.length)
      {
         trace("sending message!");
         trace(this._textChangeListeners[_loc2_]);
         this._textChangeListeners[_loc2_].onTextChanged(theText);
         _loc2_ = _loc2_ + 1;
      }
   }
   function enableInput(enabled)
   {
      if(enabled == true)
      {
         this.selectedTextField.type = "input";
      }
      else
      {
         this.selectedTextField.type = "dynamic";
      }
   }
   function getText()
   {
      return this.selectedTextField.text;
   }
   function destroy()
   {
      trace("TextSelectDropDown::Destroy");
      super.destroy();
      this._textChangeListeners.splice(0);
      trace("_textChangeListeners.length " + this._textChangeListeners.length);
   }
}
