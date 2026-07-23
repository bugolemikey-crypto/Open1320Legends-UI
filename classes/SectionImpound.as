class classes.SectionImpound extends MovieClip
{
   var carPicker;
   var cid;
   var infoBar;
   var noneText;
   var ptrxml;
   var selCar;
   var selCarXML;
   static var _MC;
   static var impoundedXML;
   function SectionImpound()
   {
      super();
      classes.SectionImpound._MC = this;
      this.noneText._visible = false;
      this.infoBar._visible = false;
      classes.Lookup.addCallback("getAllImCars",this,this.CB_getAllImCars,"");
      _root.getAllImCars();
   }
   function CB_getAllImCars(d)
   {
      classes.SectionImpound.impoundedXML = new XML(d);
      var _loc2_ = 0;
      while(_loc2_ < classes.SectionImpound.impoundedXML.firstChild.childNodes.length)
      {
         classes.SectionImpound.impoundedXML.firstChild.childNodes[_loc2_].attributes.ii = "1";
         _loc2_ = _loc2_ + 1;
      }
      if(classes.SectionImpound.impoundedXML.firstChild.childNodes.length)
      {
         this.carPicker = this.attachMovie("carPicker","carPicker",this.getNextHighestDepth(),{_x:0,_y:144,displayWidth:798});
         this.carPicker.init(classes.SectionImpound.impoundedXML,this.onCarSelect);
         this.onCarSelect(0);
      }
      else
      {
         this.noneText._visible = true;
      }
   }
   function onCarSelect(idx)
   {
      this.selCarXML = new XML(classes.SectionImpound.impoundedXML.firstChild.childNodes[idx].toString());
      this.selCar = Number(this.selCarXML.firstChild.attributes.i);
      trace("onCarSelect: " + this.selCar);
      classes.Drawing.carView(classes.SectionImpound._MC.carHolder,this.selCarXML,100,"front");
      classes.Drawing.plateView(classes.SectionImpound._MC.plateHolder,Number(this.selCarXML.firstChild.attributes.pi),this.selCarXML.firstChild.attributes.pn,42,true);
      classes.Drawing.carLogo(classes.SectionImpound._MC.logoHolder,Number(this.selCarXML.firstChild.attributes.ci));
      classes.SectionImpound._MC.infoBar._visible = true;
      classes.SectionImpound._MC.infoBar.txtFee = "$" + _global.impoundXML.firstChild.attributes.p;
      classes.SectionImpound._MC.infoBar.txtDayFee = "$" + _global.impoundXML.firstChild.attributes.pd;
      classes.SectionImpound._MC.infoBar.txtDays = this.selCarXML.firstChild.attributes.di;
      classes.SectionImpound._MC.infoBar.txtCost = "$" + this.selCarXML.firstChild.attributes.tf;
      classes.SectionImpound._MC.infoBar.btnRelease.enabled = true;
      classes.SectionImpound._MC.infoBar.btnRelease.cid = this.selCar;
      classes.SectionImpound._MC.infoBar.btnRelease.ptrxml = this.selCarXML;
      classes.SectionImpound._MC.infoBar.btnRelease.onRelease = function()
      {
         _root.getCarOutOfImpound(this.cid);
         this.enabled = false;
      };
      classes.SectionImpound._MC.infoBar.btnSell.cid = this.selCar;
      classes.SectionImpound._MC.infoBar.btnSell.ptrxml = this.selCarXML;
      classes.SectionImpound._MC.infoBar.btnSell.onRelease = function()
      {
         var _loc4_ = {carXML:this.ptrxml};
         trace("btnSell: " + this.cid);
         _loc4_.impounded = true;
         _loc4_.cb = function(tObj)
         {
            trace("dialogBtnOK callback");
            var _loc3_ = tObj.s;
            var _loc4_ = tObj.b;
            if(_loc3_ == 1)
            {
               classes.GlobalData.updateInfo("m",_loc4_);
               classes.GlobalData.removeCar(_global.sellCarObj.cid);
               _root.displayAlert("funds","Sell Car Succeeded","You have successfully sold your car.");
               classes.Frame.__MC.goMainSection("impound");
            }
            else if(_loc3_ == -4)
            {
               _root.displayAlert("warning","Test Drive Car","Sorry, you cannot sell a test drive car.");
            }
            else
            {
               _root.displayAlert("warning","Sell Car Failed","Sorry, for some reason your attempt to sell your car could not go through. Please try again later.");
            }
            _global.sellCarObj.cid = 0;
         };
         classes.Control.dialogContainer("dialogSellCarContent",_loc4_);
      };
   }
}
