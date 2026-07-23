class classes.mc.UCMyListings extends MovieClip
{
   var btnPost;
   var listArr;
   var listXML;
   var msg;
   var scrollPane;
   static var _mc;
   function UCMyListings()
   {
      super();
      classes.mc.UCMyListings._mc = this;
      this.scrollPane = this.attachMovie("scrollingPaneGroup","scrollPane",1,{_x:12,_y:51});
      this.scrollPane.scrollerObj.setSizeMask(406,204);
      this.scrollPane.scrollerObj.resetScroller(204,396);
      this.btnPost.onRelease = function()
      {
         classes.Control.dialogContainer("dialogSellUsedCarContent");
      };
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
         this.msg = "You have not posted any cars for sale.";
      }
      var _loc4_ = 0;
      var _loc3_;
      var _loc2_;
      while(_loc4_ < _loc5_)
      {
         _loc3_ = this.listXML.firstChild.childNodes[_loc4_].attributes;
         _loc2_ = this.scrollPane.contentMC.attachMovie("ucMyListingsItem","item" + _loc4_,_loc4_);
         _loc2_.id = Number(_loc3_.i);
         _loc2_.s = Number(_loc3_.s);
         _loc2_.status = classes.mc.UCListing.listingStatusName(Number(_loc3_.s));
         if(_loc2_.status == "Listed")
         {
            _loc2_.tfmt = new TextFormat();
            _loc2_.tfmt.color = 52224;
            _loc2_.fldStatus.setTextFormat(_loc2_.tfmt);
         }
         _loc2_.price = "$" + classes.NumFuncs.commaFormat(Number(_loc3_.p));
         _loc2_.carengine = classes.Lookup.carModelName(Number(_loc3_.ci)) + " (" + classes.Lookup.engineType(Number(_loc3_.eti)) + ")";
         _loc2_.expiry = _loc3_.ex;
         _loc2_.priv = _loc3_.pv != 1 ? "No" : "Yes";
         if(_loc3_.t == 1)
         {
            if(Number(_loc3_.pt) > 0)
            {
               _loc2_.trade = _loc3_.pt;
               _loc2_.tfmtTrade = new TextFormat();
               _loc2_.tfmtTrade.color = 16777011;
               _loc2_.fldTrade.setTextFormat(_loc2_.tfmtTrade);
            }
            else
            {
               _loc2_.trade = "Yes";
            }
         }
         else
         {
            _loc2_.trade = "No";
         }
         _loc2_._y = _loc4_ * _loc6_;
         this.listArr.push(_loc2_);
         _loc4_ = _loc4_ + 1;
      }
      this.scrollPane.scrollerObj.refreshScroller();
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
