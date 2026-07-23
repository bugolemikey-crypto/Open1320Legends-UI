class classes.mc.UCIncomingTrades extends MovieClip
{
   var btnClose;
   var cid;
   var listArr;
   var listXML;
   var scrollPane;
   static var _mc;
   function UCIncomingTrades()
   {
      super();
      classes.mc.UCIncomingTrades._mc = this;
      if(!this.cid)
      {
         return;
      }
      this.btnClose.onRelease = function()
      {
         classes.SectionClassified._mc.goMyListingsDetail(this._parent.cid,classes.SectionClassified.classifiedStatus);
      };
      this.scrollPane = this.attachMovie("scrollingPaneGroup","scrollPane",1,{_x:12,_y:51});
      this.scrollPane.scrollerObj.setSizeMask(228,339);
      this.scrollPane.scrollerObj.resetScroller(339,218);
      _root.pendingTrades(this.cid);
   }
   function buildList(d)
   {
      var _loc6_ = 14;
      this.listXML = new XML();
      this.listXML.ignoreWhite = true;
      this.listXML.parseXML(d);
      this.listArr = new Array();
      var _loc7_ = this.listXML.firstChild.childNodes.length;
      trace("incoming trades buildList");
      var _loc2_ = 0;
      var _loc4_;
      var _loc5_;
      var _loc3_;
      while(_loc2_ < _loc7_)
      {
         trace(_loc2_);
         _loc4_ = this.listXML.firstChild.childNodes[_loc2_];
         _loc5_ = this.listXML.firstChild.childNodes[_loc2_].attributes;
         _loc3_ = this.scrollPane.contentMC.attachMovie("ucIncomingTradesItem","item" + _loc2_,_loc2_);
         _loc3_.id = _loc4_.childNodes[0].attributes.aci + "_" + _loc4_.childNodes[1].attributes.aci;
         _loc3_.from = _loc4_.childNodes[1].attributes.u;
         _loc3_.ocarengine = classes.Lookup.carModelName(Number(_loc4_.childNodes[1].attributes.ci)) + " (" + classes.Lookup.engineType(Number(_loc4_.childNodes[1].attributes.eti)) + ")";
         _loc3_.status = _loc5_.s;
         _loc3_._y = _loc2_ * _loc6_;
         _loc3_.nodeData = _loc4_;
         this.listArr.push(_loc3_);
         _loc2_ = _loc2_ + 1;
      }
      this.scrollPane.scrollerObj.refreshScroller();
   }
}
