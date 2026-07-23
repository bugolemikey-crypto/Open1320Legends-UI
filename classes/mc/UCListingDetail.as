class classes.mc.UCListingDetail extends MovieClip
{
   var btnBuyCar;
   var btnClose;
   var btnDamage;
   var btnOfferTrade;
   var btnViewParts;
   var carLogo;
   var carPlate;
   var carView;
   var id;
   var incomingTradeNodeData;
   var isPrivate;
   var outgoingTradeNodeData;
   var txml;
   static var _mc;
   var price = "";
   var impound = "";
   var engine = "";
   var seller = "";
   var listingStatus = "";
   var hp = "";
   var torque = "";
   var tradeCode = "";
   var damage = "";
   var privateListing = "";
   function UCListingDetail()
   {
      super();
      trace("UCListingDetail");
      trace(this.id);
      classes.mc.UCListingDetail._mc = this;
      this.btnDamage._visible = false;
      this.btnViewParts._visible = false;
      this.btnBuyCar._visible = false;
      this.btnOfferTrade._visible = false;
      if(!this.id)
      {
         return;
      }
      _root.getClassifiedDetail(this.id);
      this.btnClose.onRelease = function()
      {
         if(this._parent.incomingTradeNodeData != undefined)
         {
            classes.SectionClassified._mc.goIncomingTradesDetail(this._parent.incomingTradeNodeData);
         }
         else if(this._parent.outgoingTradeNodeData != undefined)
         {
            classes.SectionClassified._mc.goTradesDetail(this._parent.outgoingTradeNodeData);
         }
         else
         {
            classes.SectionClassified._mc.closeDetail();
         }
      };
      this.btnViewParts.onRelease = function()
      {
         this._parent.showPartsList();
      };
      this.btnBuyCar.onRelease = function()
      {
         var _loc2_ = new Object();
         _loc2_.classifiedID = this._parent.id;
         _loc2_.price = this._parent.price;
         _loc2_.impound = this._parent.impound;
         _loc2_.isPrivate = this._parent.isPrivate;
         _loc2_.carXML = new XML(String(this._parent.txml.firstChild.firstChild));
         classes.Control.dialogContainer("dialogBuyUsedCarContent",_loc2_);
      };
      this.btnDamage.onRelease = function()
      {
         classes.Repair.showDamageList(this._parent.txml.firstChild.childNodes[1]);
      };
      this.btnOfferTrade.onRelease = function()
      {
         classes.Control.dialogContainer("dialogOfferTradeContent",{targetClassifiedID:this._parent.id});
      };
   }
   function build(d)
   {
      this.txml = new XML();
      this.txml.ignoreWhite = true;
      this.txml.parseXML(d);
      var _loc3_ = this.txml.firstChild.attributes;
      if(_loc3_.i != this.id)
      {
         return undefined;
      }
      this.carLogo = this.createEmptyMovieClip("carLogo",this.getNextHighestDepth());
      this.carLogo._x = 16;
      this.carLogo._y = 14;
      this.carLogo._xscale = this.carLogo._yscale = 50;
      this.carLogo.loadMovie("cache/car/logo_" + _loc3_.ci + ".swf");
      this.price = "$" + classes.NumFuncs.commaFormat(Number(_loc3_.p));
      if(Number(this.txml.firstChild.firstChild.attributes.ii))
      {
         this.impound = "+ $" + this.txml.firstChild.firstChild.attributes["if"] + " impound fees";
      }
      this.engine = classes.Lookup.engineType(Number(_loc3_.eti),true);
      this.listingStatus = classes.mc.UCListing.listingStatusName(Number(_loc3_.s));
      this.seller = _loc3_.u;
      if(classes.GlobalData.attr.mb != 1)
      {
         this.hp = "(members only)";
         this.torque = "(members only)";
      }
      else
      {
         this.hp = _loc3_.hp;
         this.torque = _loc3_.tq;
      }
      this.tradeCode = _loc3_.i;
      this.isPrivate = _loc3_.pv != 1 ? false : true;
      this.privateListing = _loc3_.pv != 1 ? "No" : "Yes";
      var _loc4_;
      var _loc2_;
      var _loc5_;
      if(_loc3_.s == 1)
      {
         _loc4_ = 0;
         _loc2_ = 0;
         while(_loc2_ < this.txml.firstChild.childNodes[1].childNodes.length)
         {
            _loc4_ += Number(this.txml.firstChild.childNodes[1].childNodes[_loc2_].attributes.d);
            _loc2_ = _loc2_ + 1;
         }
         if(_loc4_ > 0)
         {
            this.btnDamage._visible = true;
         }
         else
         {
            this.damage = "None";
         }
         _loc5_ = new XML(String(this.txml.firstChild.firstChild));
         this.carPlate = this.createEmptyMovieClip("carPlate",this.getNextHighestDepth());
         this.carPlate._x = 22;
         this.carPlate._y = 256;
         trace("plate: " + _loc5_.firstChild.attributes.pn);
         classes.Drawing.plateView(this.carPlate,Number(_loc5_.firstChild.attributes.pi),_loc5_.firstChild.attributes.pn,30,true);
         this.carView = this.createEmptyMovieClip("carView",this.getNextHighestDepth());
         this.carView._x = -26;
         this.carView._y = 246;
         classes.Drawing.carView(this.carView,_loc5_,50);
         this.btnViewParts._visible = true;
         this.btnBuyCar._visible = true;
         if(_loc3_.t == 1 && this.incomingTradeNodeData == undefined && this.outgoingTradeNodeData == undefined)
         {
            this.btnOfferTrade._visible = true;
         }
      }
      else
      {
         this.impound = "";
         this.damage = "not available";
      }
   }
   function showPartsList()
   {
      var _loc3_ = "";
      var _loc2_ = 0;
      while(_loc2_ < this.txml.firstChild.firstChild.childNodes.length)
      {
         _loc3_ += this.txml.firstChild.firstChild.childNodes[_loc2_].attributes.n + "\r";
         _loc2_ = _loc2_ + 1;
      }
      classes.Control.dialogTextBlob("Installed Parts",_loc3_,"shop");
   }
}
