class classes.mc.UCMyTradesSentDetail extends MovieClip
{
   var btnCancel;
   var btnClose;
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
   function UCMyTradesSentDetail()
   {
      super();
      trace("UCMyTradesSentDetail");
      classes.mc.UCMyTradesSentDetail._mc = this;
      if(this.nodeData == undefined)
      {
         trace("undefined!!!");
         return;
      }
      this.btnClose.onRelease = function()
      {
         classes.SectionClassified._mc.closeDetail();
      };
      this.btnCancel.onRelease = function()
      {
         trace("cancel trade");
         _root.cancelTrade(Number(this._parent.nodeData.childNodes[0].attributes.i),Number(this._parent.nodeData.childNodes[1].attributes.i));
      };
      this.btnViewListingO.onRelease = function()
      {
         classes.SectionClassified._mc.goDetail(Number(this._parent.nodeData.childNodes[1].attributes.i),undefined,this._parent.nodeData);
      };
      this.btnViewListingM.onRelease = function()
      {
         classes.SectionClassified._mc.goMyListingsDetail(Number(this._parent.nodeData.childNodes[0].attributes.i),1,undefined,this._parent.nodeData);
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
   function CB_getTwoRacersCars(txml)
   {
      trace("CB_getTwoRacersCars::::");
      trace(txml);
      classes.Drawing.carView(this.ocarView,new XML(String(txml.firstChild.childNodes[1])),25);
      classes.Drawing.carView(this.mcarView,new XML(String(txml.firstChild.childNodes[0])),25);
   }
}
