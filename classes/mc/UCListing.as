class classes.mc.UCListing extends MovieClip
{
   var btnGoSearch;
   var ddMenuCar;
   var ddMenuCarListener;
   var ddMenuEngine;
   var ddMenuEngineListener;
   var listArr;
   var listXML;
   var menuCar;
   var menuEngine;
   var scrollPane;
   var searchCarID;
   var searchEngineID;
   static var _mc;
   var page = 1;
   var msg = "";
   function UCListing()
   {
      super();
      classes.mc.UCListing._mc = this;
      this.searchCarID = _global.sectionClassifiedMC.searchCarID;
      this.searchEngineID = _global.sectionClassifiedMC.searchEngineID;
      this.page = _global.sectionClassifiedMC.searchPage;
      trace("UCListing.page: " + this.page);
      this.scrollPane = this.attachMovie("scrollingPaneGroup","scrollPane",1,{_x:12,_y:51});
      this.scrollPane.scrollerObj.setSizeMask(406,340);
      this.scrollPane.scrollerObj.resetScroller(340,396);
      this.menuCar = this.createEmptyMovieClip("menuCar",this.getNextHighestDepth());
      this.menuCar._x = 69;
      this.menuCar._y = 10;
      this.ddMenuCar = new classes.ui.SweetDropdown2b(this.menuCar,"ddBase130","Arial","Arial",256,0,false,undefined,18);
      this.ddMenuCarListener = new Object();
      this.ddMenuCarListener.onItemChanged = function(o)
      {
         trace(o.value);
         classes.mc.UCListing._mc.searchCarID = Number(o.value);
      };
      this.ddMenuCar.addListener(this.ddMenuCarListener);
      var _loc5_ = new Array();
      _loc5_.push({label:"All Car Models",value:0});
      var _loc4_ = 0;
      while(_loc4_ < _global.carsXML.firstChild.childNodes.length)
      {
         _loc5_.push({label:_global.carsXML.firstChild.childNodes[_loc4_].attributes.c,value:_global.carsXML.firstChild.childNodes[_loc4_].attributes.id});
         _loc4_ = _loc4_ + 1;
      }
      _loc4_ = 0;
      while(_loc4_ < _loc5_.length)
      {
         this.ddMenuCar.addItem(_loc5_[_loc4_]);
         _loc4_ = _loc4_ + 1;
      }
      this.ddMenuCar.renderItems();
      this.ddMenuCar.setDefaultText(this.ddMenuCar.getLabelFromValue(String(this.searchCarID)));
      this.menuEngine = this.createEmptyMovieClip("menuEngine",this.getNextHighestDepth());
      this.menuEngine._x = 254;
      this.menuEngine._y = 10;
      this.ddMenuEngine = new classes.ui.SweetDropdown2b(this.menuEngine,"ddBase130","Arial","Arial",74,0,false,undefined,18);
      this.ddMenuEngineListener = new Object();
      this.ddMenuEngineListener.onItemChanged = function(o)
      {
         trace(o.value);
         classes.mc.UCListing._mc.searchEngineID = Number(o.value);
      };
      this.ddMenuEngine.addListener(this.ddMenuEngineListener);
      var _loc6_ = new Array();
      _loc6_.push({label:"All Engine Types",value:0});
      _loc6_.push({label:"Natural",value:1});
      _loc6_.push({label:"Turbocharged",value:2});
      _loc6_.push({label:"Supercharged",value:3});
      _loc4_ = 0;
      while(_loc4_ < _loc6_.length)
      {
         this.ddMenuEngine.addItem(_loc6_[_loc4_]);
         _loc4_ = _loc4_ + 1;
      }
      this.ddMenuEngine.renderItems();
      this.ddMenuEngine.setDefaultText(this.ddMenuEngine.getLabelFromValue(String(this.searchEngineID)));
      this.btnGoSearch.onRelease = function()
      {
         _global.sectionClassifiedMC.searchCarID = this._parent.searchCarID;
         _global.sectionClassifiedMC.searchEngineID = this._parent.searchEngineID;
         _global.sectionClassifiedMC.searchPage = 1;
         _global.sectionClassifiedMC.gotoAndPlay("browse");
      };
   }
   static function listingStatusName(sid)
   {
      switch(sid)
      {
         case 1:
            return "Listed";
         case 2:
            return "Expired";
         case 3:
            return "Sold";
         case 4:
            return "Traded";
         case 5:
            return "Retracted";
         case 6:
            return "Pending Sale";
         default:
            return "";
      }
   }
   function buildList(d)
   {
      var _loc6_ = 14;
      this.listXML = new XML();
      this.listXML.ignoreWhite = true;
      this.listXML.parseXML(d);
      this.listArr = new Array();
      var _loc5_ = this.listXML.firstChild.childNodes.length;
      if(!_loc5_)
      {
         this.msg = "No cars found that match your search criteria.";
      }
      var _loc4_ = 0;
      var _loc3_;
      var _loc2_;
      while(_loc4_ < _loc5_)
      {
         _loc3_ = this.listXML.firstChild.childNodes[_loc4_].attributes;
         _loc2_ = this.scrollPane.contentMC.attachMovie("ucListingItem","item" + _loc4_,_loc4_);
         _loc2_.id = Number(_loc3_.i);
         _loc2_.listingID = _loc3_.i;
         _loc2_.price = "$" + classes.NumFuncs.commaFormat(Number(_loc3_.p));
         _loc2_.carengine = classes.Lookup.carModelName(Number(_loc3_.ci)) + " (" + classes.Lookup.engineType(Number(_loc3_.eti)) + ")";
         _loc2_.seller = _loc3_.u;
         if(!Number(classes.GlobalData.attr.mb))
         {
            _loc2_.hp = " - / - ";
         }
         else
         {
            _loc2_.hp = _loc3_.hp + "/" + _loc3_.tq;
         }
         _loc2_.trade = _loc3_.t != 1 ? "No" : "Yes";
         _loc2_._y = _loc4_ * _loc6_;
         this.listArr.push(_loc2_);
         _loc4_ = _loc4_ + 1;
      }
      this.scrollPane.scrollerObj.refreshScroller();
      this.createPaging();
   }
   function createPaging()
   {
      var _loc2_ = Number(this.listXML.firstChild.attributes.p);
      trace("createPaging - page[" + this.page + "] pages[" + _loc2_ + "]");
      var _loc3_ = new controls.SlideScroller();
      _loc3_.init(classes.mc.UCListing._mc.slideScroller,classes.mc.UCListing._mc.page,_loc2_,classes.mc.UCListing._mc.slideScroller.mvBack,classes.mc.UCListing._mc.slideScroller.mvNext,classes.mc.UCListing._mc.slideScroller.pageBack,classes.mc.UCListing._mc.slideScroller.pageNext,60,0,285,30,classes.SectionClassified._mc.goSearchPage);
   }
   function setAllSelect(id)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.listArr.length)
      {
         this.listArr[_loc2_].setSelect(id);
         _loc2_ = _loc2_ + 1;
      }
   }
}
