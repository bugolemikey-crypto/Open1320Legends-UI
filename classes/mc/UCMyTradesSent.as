class classes.mc.UCMyTradesSent extends MovieClip
{
   var btnPropose;
   var listArr;
   var listXML;
   var msg;
   var scrollPane;
   static var _mc;
   function UCMyTradesSent()
   {
      super();
      classes.mc.UCMyTradesSent._mc = this;
      this.scrollPane = this.attachMovie("scrollingPaneGroup","scrollPane",1,{_x:12,_y:51});
      this.scrollPane.scrollerObj.setSizeMask(406,106);
      this.scrollPane.scrollerObj.resetScroller(106,396);
      this.btnPropose.onRelease = function()
      {
         classes.Control.dialogContainer("dialogOfferTradeContent");
      };
   }
   static function tradeStatusName(sid)
   {
      switch(sid)
      {
         case 1:
            return "Pending";
         case 2:
            return "Accepted";
         case 3:
            return "Declined";
         case 4:
            return "Sold";
         case 5:
            return "Traded";
         case 6:
            return "Expired";
         case 7:
            return "Retracted";
         default:
            return "";
      }
   }
   function buildList(d)
   {
      var _loc7_ = 14;
      this.listXML = new XML();
      this.listXML.ignoreWhite = true;
      this.listXML.parseXML(d);
      this.listArr = new Array();
      var _loc6_ = this.listXML.firstChild.childNodes.length;
      if(!_loc6_)
      {
         this.msg = "You have not sent any trade offers.";
      }
      var _loc4_ = 0;
      var _loc3_;
      var _loc5_;
      var _loc2_;
      while(_loc4_ < _loc6_)
      {
         trace(_loc4_);
         _loc3_ = this.listXML.firstChild.childNodes[_loc4_];
         _loc5_ = this.listXML.firstChild.childNodes[_loc4_].attributes;
         _loc2_ = this.scrollPane.contentMC.attachMovie("ucMyTradesSentItem","item" + _loc4_,_loc4_);
         _loc2_.id = _loc3_.childNodes[0].attributes.aci + "_" + _loc3_.childNodes[1].attributes.aci;
         _loc2_.to = _loc3_.childNodes[1].attributes.u;
         _loc2_.mcarengine = classes.Lookup.carModelName(Number(_loc3_.childNodes[0].attributes.ci)) + " (" + classes.Lookup.engineType(Number(_loc3_.childNodes[0].attributes.eti)) + ")";
         _loc2_.ocarengine = classes.Lookup.carModelName(Number(_loc3_.childNodes[1].attributes.ci)) + " (" + classes.Lookup.engineType(Number(_loc3_.childNodes[1].attributes.eti)) + ")";
         _loc2_.status = classes.mc.UCMyTradesSent.tradeStatusName(Number(_loc5_.s));
         if(_loc2_.status == "Pending")
         {
            _loc2_.tfmt = new TextFormat();
            _loc2_.tfmt.color = 52224;
            _loc2_.fldStatus.setTextFormat(_loc2_.tfmt);
         }
         _loc2_._y = _loc4_ * _loc7_;
         _loc2_.nodeData = _loc3_;
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
