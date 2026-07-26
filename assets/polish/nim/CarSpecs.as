class classes.CarSpecs
{
   var bodyID;
   var brakeID;
   var bumperID;
   var decalArr;
   var globalClr;
   var hoodID;
   var rideHeight;
   var tireScale;
   var tireScaleFactor;
   var tiresID;
   var wheelFID;
   var wheelRID;
   var wheelScale;
   var wheelSize;
   function CarSpecs(pClr)
   {
      if(pClr)
      {
         this.globalClr = pClr;
      }
      else
      {
         this.globalClr = 0;
      }
      this.wheelFID = 1;
      this.wheelRID = 1;
      this.tiresID = 1;
      this.hoodID = 1;
      this.bumperID = 1;
      this.bodyID = 1;
      this.brakeID = 1;
      this.rideHeight = 8;
      this.tireScale = 90;
      this.tireScaleFactor = 1.1;
      this.wheelScale = 78;
      this.wheelSize = 16;
   }
   function modSpec(specName, val)
   {
      this[specName] = val;
   }
   function modAllColor(val)
   {
      for(var _loc3_ in this)
      {
         if(_loc3_.substr(_loc3_.length - 3,3) == "Clr")
         {
            this[_loc3_] = val;
         }
      }
   }
   function applyCarXML(carXML)
   {
      var _loc4_;
      var _loc2_;
      var _loc9_;
      if(carXML != undefined)
      {
         this.modSpec("globalClr",Number("0x" + carXML.firstChild.attributes.cc));
         this.modSpec("acctCarID",Number(carXML.firstChild.attributes.i));
         this.modSpec("plateID",carXML.firstChild.attributes.pi);
         this.modSpec("lic",carXML.firstChild.attributes.pn);
         this.decalArr = new Array();
         _loc2_ = 0;
         for(; _loc2_ < carXML.firstChild.childNodes.length; _loc2_ = _loc2_ + 1)
         {
            if(Number(carXML.firstChild.childNodes[_loc2_].attributes["in"]) != 1)
            {
               continue;
            }
            _loc4_ = classes.CarSpecs.getName(Number(carXML.firstChild.childNodes[_loc2_].attributes.ci));
            if(_loc4_)
            {
               this.modSpec(_loc4_ + "ID",Number(carXML.firstChild.childNodes[_loc2_].attributes.di));
               if(_loc4_ == "wheelF")
               {
                  this.modSpec("wheelRID",Number(carXML.firstChild.childNodes[_loc2_].attributes.di));
               }
               else if(_loc4_ == "body")
               {
                  this.modSpec("bodyOppID",Number(carXML.firstChild.childNodes[_loc2_].attributes.di));
               }
               if(carXML.firstChild.childNodes[_loc2_].attributes.cc.length > 1)
               {
                  this.modSpec(_loc4_ + "Clr",Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc));
                  if(_loc4_ == "wheelF")
                  {
                     this.modSpec("wheelRClr",Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc));
                  }
                  else if(_loc4_ == "body")
                  {
                     this.modSpec("bodyOppClr",Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc));
                  }
               }
            }
            switch(Number(carXML.firstChild.childNodes[_loc2_].attributes.ci))
            {
               case 160:
                  _loc9_ = true;
               case 148:
                  this.decalArr.push({part:"hood",order:1,isUGG:_loc9_,localPath:carXML.firstChild.childNodes[_loc2_].attributes.localPath,parentdi:Number(carXML.firstChild.childNodes[_loc2_].attributes.pdi),di:Number(carXML.firstChild.childNodes[_loc2_].attributes.di),partID:Number(carXML.firstChild.childNodes[_loc2_].attributes.i),catID:Number(carXML.firstChild.childNodes[_loc2_].attributes.ci),partClr:Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc)});
                  break;
               case 161:
                  _loc9_ = true;
               case 149:
                  this.decalArr.push({part:"side",order:2,isUGG:_loc9_,localPath:carXML.firstChild.childNodes[_loc2_].attributes.localPath,parentdi:Number(carXML.firstChild.childNodes[_loc2_].attributes.pdi),di:Number(carXML.firstChild.childNodes[_loc2_].attributes.di),partID:Number(carXML.firstChild.childNodes[_loc2_].attributes.i),catID:Number(carXML.firstChild.childNodes[_loc2_].attributes.ci),partClr:Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc)});
                  break;
               case 162:
                  _loc9_ = true;
               case 150:
                  this.decalArr.push({part:"front",order:3,isUGG:_loc9_,localPath:carXML.firstChild.childNodes[_loc2_].attributes.localPath,parentdi:Number(carXML.firstChild.childNodes[_loc2_].attributes.pdi),di:Number(carXML.firstChild.childNodes[_loc2_].attributes.di),partID:Number(carXML.firstChild.childNodes[_loc2_].attributes.i),catID:Number(carXML.firstChild.childNodes[_loc2_].attributes.ci),partClr:Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc)});
                  break;
               case 163:
                  _loc9_ = true;
               case 151:
                  this.decalArr.push({part:"back",order:4,isUGG:_loc9_,localPath:carXML.firstChild.childNodes[_loc2_].attributes.localPath,parentdi:Number(carXML.firstChild.childNodes[_loc2_].attributes.pdi),di:Number(carXML.firstChild.childNodes[_loc2_].attributes.di),partID:Number(carXML.firstChild.childNodes[_loc2_].attributes.i),catID:Number(carXML.firstChild.childNodes[_loc2_].attributes.ci),partClr:Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc)});
                  break;
               case 146:
                  this.decalArr.push({part:"full",order:5,localPath:carXML.firstChild.childNodes[_loc2_].attributes.localPath,parentdi:Number(carXML.firstChild.childNodes[_loc2_].attributes.pdi),di:Number(carXML.firstChild.childNodes[_loc2_].attributes.di),partID:Number(carXML.firstChild.childNodes[_loc2_].attributes.i),catID:Number(carXML.firstChild.childNodes[_loc2_].attributes.ci),partClr:Number("0x" + carXML.firstChild.childNodes[_loc2_].attributes.cc)});
            }
            switch(Number(carXML.firstChild.childNodes[_loc2_].attributes.ci))
            {
               case 13:
                  if(carXML.firstChild.childNodes[_loc2_].attributes.ps.length)
                  {
                     this.tireScaleFactor = 1 + Number(carXML.firstChild.childNodes[_loc2_].attributes.ps) / 100;
                  }
                  break;
               case 14:
                  if(Number(carXML.firstChild.childNodes[_loc2_].attributes.ps))
                  {
                     this.wheelSize = Math.max(14,Math.min(20,Number(carXML.firstChild.childNodes[_loc2_].attributes.ps)));
                  }
                  break;
               case 114:
                  this.rideHeight = Number(carXML.firstChild.childNodes[_loc2_].attributes.ps);
            }
         }
         this.decalArr.sortOn("order");
         this.setWheelAndTireScales();
      }
   }
   function setWheelAndTireScales()
   {
      this.wheelScale = 70 + (this.wheelSize - 14) * 24 / 6;
      this.tireScale = Math.min(100,this.wheelScale * this.tireScaleFactor);
   }
   function toString()
   {
      var _loc2_ = "";
      for(var _loc3_ in this)
      {
         if(_loc3_.substr(_loc3_.length - 2,2) == "ID")
         {
            _loc2_ += _loc3_ + ":" + this[_loc3_] + " _ ";
         }
      }
      return _loc2_;
   }
   static function isVisible(partCatID)
   {
      var _loc2_ = new Array(13,14,65,68,71,72,73,74,75,76,77,114,128,129,130,140,141,142,143,144,145,146,148,149,150,151,174);
      var _loc3_ = false;
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         if(_loc2_[_loc1_] == partCatID)
         {
            _loc3_ = true;
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   static function isPaintable(partCatID)
   {
      var _loc2_ = new Array(65,68,71,72,73,74,75,76,77,128,129,130,140,141,142,143,144,174);
      var _loc3_ = false;
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         if(_loc2_[_loc1_] == partCatID)
         {
            _loc3_ = true;
            break;
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc3_;
   }
   static function getName(id)
   {
      var _loc1_;
      switch(id)
      {
         case 13:
            _loc1_ = "tires";
            break;
         case 14:
            _loc1_ = "wheelF";
            break;
         case 65:
            _loc1_ = "spoiler";
            break;
         case 68:
            _loc1_ = "roofEffect";
            break;
         case 71:
            _loc1_ = "hood";
            break;
         case 72:
            _loc1_ = "hoodCenterEffect";
            break;
         case 73:
            _loc1_ = "sideEffect";
            break;
         case 74:
            _loc1_ = "hoodFrontEffect";
            break;
         case 75:
            _loc1_ = "eyelids";
            break;
         case 76:
            _loc1_ = "lights";
            break;
         case 77:
            _loc1_ = "tailLights";
            break;
         case 128:
            _loc1_ = "bumper";
            break;
         case 129:
            _loc1_ = "skirt";
            break;
         case 130:
            _loc1_ = "bumperRear";
            break;
         case 140:
            _loc1_ = "grille";
            break;
         case 141:
            _loc1_ = "cPillarEffect";
            break;
         case 142:
            _loc1_ = "fenderEffect";
            break;
         case 143:
            _loc1_ = "doorEffect";
            break;
         case 144:
            _loc1_ = "trunk";
            break;
         case 174:
            _loc1_ = "top";
            break;
         default:
            _loc1_;
      }
      return _loc1_;
   }
}
