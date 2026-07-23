class classes.mc.UCMyListingsDetail extends MovieClip
{
   var btnCancel;
   var btnClose;
   var btnDamage;
   var btnTradeOffers;
   var bu;
   var carLogo;
   var carPlate;
   var carView;
   var id;
   var s;
   var txml;
   static var _mc;
   var price = "";
   var impound = "";
   var engine = "";
   var listingStatus = "";
   var seller = "";
   var hp = "";
   var torque = "";
   var tradeCode = "";
   var damage = "";
   var privateListing = "";
   function UCMyListingsDetail()
   {
      super();
      trace("UCMyListingsDetail");
      trace(this.id);
      classes.mc.UCMyListingsDetail._mc = this;
      this.btnDamage._visible = false;
      this.btnTradeOffers._visible = false;
      this.btnCancel._visible = false;
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
      this.btnTradeOffers.onRelease = function()
      {
         classes.SectionClassified.classifiedStatus = this._parent.s;
         classes.SectionClassified._mc.goIncomingTrades(this._parent.id);
      };
      this.btnCancel.onRelease = function()
      {
         trace("cancel listing");
         _root.cancelClassified(this._parent.id);
      };
      this.btnDamage.onRelease = function()
      {
         classes.Repair.showDamageList(this._parent.txml.firstChild.childNodes[1]);
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
      this.listingStatus = classes.mc.UCListing.listingStatusName(this.s);
      if(this.listingStatus == "Sold" || this.listingStatus == "Traded")
      {
         if(this.bu.length)
         {
            this.listingStatus += " to " + this.bu;
         }
      }
      else if(this.listingStatus == "Listed")
      {
         this.listingStatus = "expires " + _loc3_.ex;
      }
      this.seller = _loc3_.u;
      if("35".indexOf(String(classes.GlobalData.role)) > -1)
      {
         this.hp = "(must be member)";
         this.torque = "(must be member)";
      }
      else
      {
         this.hp = _loc3_.hp;
         this.torque = _loc3_.tq;
      }
      this.tradeCode = _loc3_.i;
      this.privateListing = _loc3_.pv != 1 ? "No" : "Yes";
      var _loc4_;
      var _loc2_;
      var _loc5_;
      if(this.s == 1)
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
         if(_loc3_.t == 1)
         {
            this.btnTradeOffers._visible = true;
            if(!Number(_loc3_.pt))
            {
               this.btnTradeOffers._alpha = 40;
               this.btnTradeOffers.enabled = false;
            }
         }
         this.btnCancel._visible = true;
         _loc5_ = new XML(String(this.txml.firstChild.firstChild));
         this.carPlate = this.createEmptyMovieClip("carPlate",this.getNextHighestDepth());
         this.carPlate._x = 22;
         this.carPlate._y = 256;
         classes.Drawing.plateView(this.carPlate,Number(_loc5_.firstChild.attributes.pi),_loc5_.firstChild.attributes.pn,30,true);
         this.carView = this.createEmptyMovieClip("carView",this.getNextHighestDepth());
         this.carView._x = -26;
         this.carView._y = 246;
         classes.Drawing.carView(this.carView,_loc5_,50);
      }
      else
      {
         this.impound = "";
         this.damage = "not available";
      }
   }
}
