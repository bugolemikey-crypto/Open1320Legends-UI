class classes.ui.UserSearchDropDown2
{
   var _cbMovie;
   var _intervalID;
   var _searchResultsEnabled;
   var _searchText;
   var cbMovie;
   var classType;
   var dd;
   var dropDownMenu;
   var dropDownMenuListener;
   var dropDownMenuTextListener;
   var menu;
   function UserSearchDropDown2(p, baseGraphicToLoad, baseFontToLoad, itemFontToLoad, scrollHeight, scrollOffset, autoSelect, itemWidth, itemHeight, cbMovie, a_classType)
   {
      this.classType = a_classType;
      this.enableSearchResults(true);
      this._cbMovie = cbMovie;
      this.dropDownMenu = new classes.ui.TextSelectDropDown2(p,baseGraphicToLoad,baseFontToLoad,itemFontToLoad,scrollHeight,scrollOffset,autoSelect,itemWidth,itemHeight);
      this.dropDownMenu.closeItems();
      this.dropDownMenuListener = new Object();
      this.dropDownMenuListener.cbMovie = this._cbMovie;
      this.dropDownMenuListener.dd = this;
      this.dropDownMenuListener.onItemChanged = function(o)
      {
         trace("item changed!");
         trace(o.value);
         this.dd.currentSelected = o;
         trace(this.dd.currentSelected);
         this.cbMovie.nomineeSelected(o.value);
      };
      this.dropDownMenu.addListener(this.dropDownMenuListener);
      this.dropDownMenuTextListener = new Object();
      this.dropDownMenuTextListener.menu = this;
      this.dropDownMenuTextListener.cbMovie = this._cbMovie;
      this.dropDownMenuTextListener.onTextChanged = function(searchString)
      {
         trace(searchString);
         trace("onTextChanged!!! Yeah!!");
         this.menu.currentSelected = null;
         this.cbMovie.textEnteredInSearchBox();
         this.menu._searchText = searchString;
         if(!this._intervalID)
         {
            this._intervalID = setInterval(this.menu,"checkForTextChange",5000);
         }
      };
      this.dropDownMenu.addTextChangeListener(this.dropDownMenuTextListener);
   }
   function checkForTextChange()
   {
      var _loc3_;
      if(this._searchText.length > 0)
      {
         trace("searching for " + this._searchText);
         classes.Lookup.addCallback("racerSearchNoPage",this,this.CB_searchRacers,"");
         _root.racerSearchNoPage(this._searchText);
         this._searchText = "";
      }
      else
      {
         _loc3_ = this.dropDownMenu.getText();
         if(_loc3_.length == 0)
         {
            this.dropDownMenu.closeItems();
         }
      }
   }
   function set x(x)
   {
      this.dropDownMenu.x = x;
   }
   function set y(y)
   {
      this.dropDownMenu.y = y;
   }
   function CB_searchRacers(d)
   {
      trace("CB_searchRacers b4");
      trace(this._searchResultsEnabled);
      var _loc2_;
      if(this._searchResultsEnabled == true)
      {
         trace("CB_searchRacers");
         trace(d);
         _loc2_ = new XML(d);
         trace(_loc2_);
         trace(_loc2_.firstChild);
         trace(_loc2_.firstChild.childNodes[0]);
         this.dropDownMenu.closeItems();
         this.displaySearchResults(_loc2_);
      }
   }
   function displaySearchResults(txml)
   {
      trace("display search results");
      this.dropDownMenu.repopulateDropdown();
      trace("count: " + txml.firstChild.attributes.c);
      var _loc8_ = Number(txml.firstChild.childNodes.length);
      trace("count: " + _loc8_);
      var _loc4_ = new Array();
      var _loc2_ = 0;
      while(_loc2_ < _loc8_)
      {
         _loc4_.push({label:txml.firstChild.childNodes[_loc2_].attributes.u,value:txml.firstChild.childNodes[_loc2_].attributes.i});
         _loc2_ = _loc2_ + 1;
      }
      var _loc3_ = 0;
      while(_loc3_ < _loc4_.length)
      {
         trace("adding item!");
         this.dropDownMenu.addItem(_loc4_[_loc3_]);
         _loc3_ = _loc3_ + 1;
      }
      this.dropDownMenu.renderItems();
      this.dropDownMenu.itemCount = _loc8_;
      this.dropDownMenu.openItems();
   }
   function setVisible(v)
   {
      this.dropDownMenu.setVisible(v);
   }
   function enableInput(enabled)
   {
      this.dropDownMenu.enableInput(enabled);
   }
   function enableSearchResults(enabled)
   {
      this._searchResultsEnabled = enabled;
   }
   function destroy()
   {
      this.dropDownMenu.remove();
      this.dropDownMenu.destroy();
      clearInterval(this._intervalID);
   }
}
