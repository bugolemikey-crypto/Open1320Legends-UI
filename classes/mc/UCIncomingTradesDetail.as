class classes.mc.UCIncomingTradesDetail extends MovieClip
{
   var btnAccept;
   var btnClose;
   var btnDecline;
   var btnViewListingM;
   var btnViewListingO;
   var mcarLogo;
   var mcarView;
   var nodeData;
   var ocarLogo;
   var ocarView;
   static var _mc;
   var oengine = "";
   var oprice = "";
   var seller = "";
   var mengine = "";
   var mprice = "";
   function UCIncomingTradesDetail()
   {
      super();
      trace("UCIncomingTradesDetail");
      classes.mc.UCIncomingTradesDetail._mc = this;
      if(this.nodeData == undefined)
      {
         trace("undefined!!!");
         return;
      }
      this.btnDecline.onRelease = function()
      {
         trace("decline trade");
         _root.respondTrade(Number(this._parent.nodeData.childNodes[1].attributes.i),Number(this._parent.nodeData.childNodes[0].attributes.i),0);
      };
      this.btnAccept.onRelease = function()
      {
         trace("accept trade");
         var _loc3_ = "By accepting this trade, you agree to pay the following:\r\r";
         var _loc6_ = Number(classes.GlobalData.attr.mb != 1 ? _global.usedCarXML.firstChild.attributes.t : _global.usedCarXML.firstChild.attributes.mt);
         var _loc4_ = Number(this._parent.nodeData.childNodes[0].attributes["if"]);
         var _loc5_ = Number(this._parent.nodeData.childNodes[1].attributes["if"]);
         _loc3_ += "$" + _loc6_ + " - secure trade fee\r";
         if(_loc4_)
         {
            _loc3_ += "$" + _loc4_ + " - impound fee (your car is currently impounded)\r";
         }
         if(_loc5_)
         {
            _loc3_ += "$" + _loc5_ + " - impound fee (the car you want is currently impounded)\r";
         }
         _loc3_ += "\rClick OK to pay all fees and make this trade.";
         if(_loc4_)
         {
            _loc3_ += "  NOTE: Make sure you have an available parking space, or the car you receive will be impounded.";
         }
         classes.Control.genericDialog(_loc3_,classes.mc.UCIncomingTradesDetail._mc.acceptCurrentTrade);
         classes.Control.dialogAlert("Make the Trade",_loc3_,classes.mc.UCIncomingTradesDetail._mc.acceptCurrentTrade,"key");
      };
      this.btnClose.onRelease = function()
      {
         trace(this._parent.nodeData.childNodes[0].attributes.i);
         classes.SectionClassified._mc.goIncomingTrades(Number(this._parent.nodeData.childNodes[0].attributes.i));
      };
      this.btnViewListingO.onRelease = function()
      {
         classes.SectionClassified._mc.goDetail(Number(this._parent.nodeData.childNodes[1].attributes.i),this._parent.nodeData);
      };
      this.btnViewListingM.onRelease = function()
      {
         classes.SectionClassified._mc.goMyListingsDetail(Number(this._parent.nodeData.childNodes[0].attributes.i),1,this._parent.nodeData);
      };
      this.build();
   }
   function build()
   {
      trace("build");
      this.ocarLogo = this.createEmptyMovieClip("ocarLogo",this.getNextHighestDepth());
      this.ocarLogo._x = 18;
      this.ocarLogo._y = 52;
      this.ocarLogo._xscale = this.ocarLogo._yscale = 50;
      this.ocarLogo.loadMovie("cache/car/logo_" + this.nodeData.childNodes[1].attributes.ci + ".swf");
      this.oprice = "$" + classes.NumFuncs.commaFormat(Number(this.nodeData.childNodes[1].attributes.p));
      this.oengine = classes.Lookup.engineType(Number(this.nodeData.childNodes[1].attributes.eti),true);
      this.seller = this.nodeData.childNodes[1].attributes.u;
      this.ocarView = this.createEmptyMovieClip("ocarView",this.getNextHighestDepth());
      this.ocarView._x = 96;
      this.ocarView._y = 62;
      this.mcarLogo = this.createEmptyMovieClip("mcarLogo",this.getNextHighestDepth());
      this.mcarLogo._x = 18;
      this.mcarLogo._y = 219;
      this.mcarLogo._xscale = this.mcarLogo._yscale = 50;
      this.mcarLogo.loadMovie("cache/car/logo_" + this.nodeData.childNodes[0].attributes.ci + ".swf");
      this.mprice = "$" + classes.NumFuncs.commaFormat(Number(this.nodeData.childNodes[0].attributes.p));
      this.mengine = classes.Lookup.engineType(Number(this.nodeData.childNodes[0].attributes.eti),true);
      this.mcarView = this.createEmptyMovieClip("mcarView",this.getNextHighestDepth());
      this.mcarView._x = 96;
      this.mcarView._y = 229;
      classes.Lookup.addCallback("raceGetTwoRacersCars",this,this.CB_getTwoRacersCars,Number(this.nodeData.childNodes[0].attributes.aci) + "," + Number(this.nodeData.childNodes[1].attributes.aci));
      _root.raceGetTwoRacersCars(Number(this.nodeData.childNodes[0].attributes.aci),Number(this.nodeData.childNodes[1].attributes.aci));
   }
   function acceptCurrentTrade()
   {
      _root.respondTrade(Number(classes.mc.UCIncomingTradesDetail._mc.nodeData.childNodes[1].attributes.i),Number(classes.mc.UCIncomingTradesDetail._mc.nodeData.childNodes[0].attributes.i),1);
   }
   function CB_getTwoRacersCars(txml)
   {
      classes.Drawing.carView(this.ocarView,new XML(String(txml.firstChild.childNodes[1])),25);
      classes.Drawing.carView(this.mcarView,new XML(String(txml.firstChild.childNodes[0])),25);
   }
}
