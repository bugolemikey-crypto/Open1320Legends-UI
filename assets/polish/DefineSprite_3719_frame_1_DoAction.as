function getSelectedCarXML()
{
   carXML = new XML(classes.GlobalData.getSelectedCarXML().toString());
}
function cloneCarXML()
{
   cloneXML = new XML(carXML.toString());
}
function drawSwatches()
{
   var _loc5_ = 0;
   while(_loc5_ < paintSwatchArray.length)
   {
      paintSwatchArray[_loc5_].removeMovieClip();
      _loc5_ = _loc5_ + 1;
   }
   paintSwatchArray = new Array();
   var _loc6_ = _global.paintsXML.firstChild;
   _loc5_ = 0;
   var _loc4_;
   var _loc3_;
   while(_loc5_ < _loc6_.childNodes.length)
   {
      if(_loc6_.childNodes[_loc5_].attributes.l == locationID)
      {
         _loc4_ = paintSwatchArray.length;
         _loc3_ = classes.PaintSwatch(paintSwatchContainer.attachMovie("paintSwatch","swatch" + _loc4_,paintSwatchContainer.getNextHighestDepth()));
         _loc3_._x = Math.floor(_loc4_ / columns) * xIndent + _loc4_ % columns * xSpacing;
         _loc3_._y = Math.floor(_loc4_ / columns) * yIndent;
         _loc3_.HexColor = _loc6_.childNodes[_loc5_].attributes.c;
         _loc3_.swatchColorMC.onRelease = function()
         {
            this._parent._parent._parent.addToCart(this._parent.hexColor);
         };
         paintSwatchArray.push(_loc3_);
      }
      _loc5_ = _loc5_ + 1;
   }
   paintSwatchContainer.cacheAsBitmap = true;
   drawFinishPicker();
}
function drawFinishPicker()
{
   finishPicker.removeMovieClip();
   selectedFinish = 0;
   classes.CarConstruction.finishOverride = 0;
   var _loc8_ = Math.ceil(paintSwatchArray.length / columns);
   if(_loc8_ < 1)
   {
      _loc8_ = 1;
   }
   finishPicker = this.createEmptyMovieClip("finishPicker",this.getNextHighestDepth());
   finishPicker._x = paintSwatchContainer._x;
   finishPicker._y = paintSwatchContainer._y + _loc8_ * yIndent + 6;
   finishBtnArray = new Array();
   var _loc7_ = new Array("GLOSS","MATTE","SATIN","CANDY");
   var _loc5_ = new TextFormat();
   _loc5_.font = "_sans";
   _loc5_.size = 9;
   _loc5_.bold = true;
   _loc5_.align = "center";
   var _loc2_ = 0;
   var _loc3_;
   var _loc4_;
   while(_loc2_ < _loc7_.length)
   {
      _loc3_ = finishPicker.createEmptyMovieClip("fin" + _loc2_,_loc2_ + 1);
      _loc3_._x = _loc2_ * 62;
      _loc3_.finishID = _loc2_;
      _loc3_.beginFill(2500141,100);
      _loc3_.lineTo(58,0);
      _loc3_.lineTo(58,17);
      _loc3_.lineTo(0,17);
      _loc3_.endFill();
      _loc4_ = _loc3_.createTextField("fld",1,0,2,58,15);
      _loc4_.selectable = false;
      _loc4_.setNewTextFormat(_loc5_);
      _loc4_.text = _loc7_[_loc2_];
      _loc3_.onRelease = function()
      {
         setFinish(this.finishID);
      };
      finishBtnArray.push(_loc3_);
      _loc2_ = _loc2_ + 1;
   }
   highlightFinish();
}
function setFinish(fin)
{
   selectedFinish = fin;
   classes.CarConstruction.finishOverride = fin;
   highlightFinish();
   classes.Drawing.clearThisCarsBmps(carHolder);
   classes.Drawing.carView(carHolder,cloneXML,100,!isBack ? "front" : "back");
}
function highlightFinish()
{
   var _loc1_ = 0;
   while(_loc1_ < finishBtnArray.length)
   {
      if(_loc1_ == selectedFinish)
      {
         finishBtnArray[_loc1_]._alpha = 100;
         finishBtnArray[_loc1_].fld.textColor = 16777215;
      }
      else
      {
         finishBtnArray[_loc1_]._alpha = 55;
         finishBtnArray[_loc1_].fld.textColor = 10066329;
      }
      _loc1_ = _loc1_ + 1;
   }
}
function drawMenu()
{
   var _loc4_ = 0;
   while(_loc4_ < paintMenuArray.length)
   {
      paintMenuArray[_loc4_].removeMovieClip();
      _loc4_ = _loc4_ + 1;
   }
   paintMenuArray = new Array();
   var _loc5_;
   var _loc6_;
   var _loc3_;
   if(isWholeCar)
   {
      paintSwatchContainer._x = priceDescription._x = finishPicker._x = 200;
      _loc5_ = _global.paintCategoriesXML.firstChild;
      _loc4_ = 0;
      while(_loc4_ < _loc5_.childNodes.length)
      {
         if(Number(_loc5_.childNodes[_loc4_].attributes.i) == -2 && Number(_loc5_.childNodes[_loc4_].attributes.l) == locationID)
         {
            btnFull.price = Number(_loc5_.childNodes[_loc4_].attributes.p);
            btnFull.pointPrice = Number(_loc5_.childNodes[_loc4_].attributes.pp);
            break;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   else
   {
      paintSwatchContainer._x = priceDescription._x = finishPicker._x = 350;
      _loc5_ = _global.paintCategoriesXML.firstChild;
      tfNA = new TextFormat();
      tfNA.color = 6710886;
      _loc4_ = 0;
      while(_loc4_ < _loc5_.childNodes.length)
      {
         if(Number(_loc5_.childNodes[_loc4_].attributes.l) == locationID)
         {
            if(Number(_loc5_.childNodes[_loc4_].attributes.i) == -2)
            {
               btnFull.price = Number(_loc5_.childNodes[_loc4_].attributes.p);
               btnFull.pointPrice = Number(_loc5_.childNodes[_loc4_].attributes.pp);
            }
            else
            {
               _loc6_ = paintMenuArray.length;
               _loc3_ = paintMenuContainer.attachMovie("shopMenuListItem","menu" + _loc6_,paintMenuContainer.getNextHighestDepth());
               _loc3_._x = paintMenuX;
               _loc3_._y = paintMenuY + _loc6_ * paintMenuYSpacing;
               if(Number(_loc5_.childNodes[_loc4_].attributes.i) == -1)
               {
                  _loc3_.txt = "Main Body";
                  if(selectedButton.partCategoryID == -2)
                  {
                     selectedButton = _loc3_;
                  }
               }
               else
               {
                  _loc3_.txt = _loc5_.childNodes[_loc4_].firstChild;
               }
               _loc3_.partCategoryID = Number(_loc5_.childNodes[_loc4_].attributes.i);
               _loc3_.price = Number(_loc5_.childNodes[_loc4_].attributes.p);
               _loc3_.pointPrice = Number(_loc5_.childNodes[_loc4_].attributes.pp);
               _loc3_.onRollOver = function()
               {
                  setHiAnim(menuMC.shopMenu.hiRO1,this._y - menuMC._y - menuMC.shopMenu._y);
               };
               _loc3_.onRollOut = _loc3_.onDragOut = function()
               {
                  setHiAnim(menuMC.shopMenu.hiRO1,menuMC.shopMenu.hiRO1.by);
               };
               if(isPartCategoryInstalled(carXML.firstChild,_loc3_.partCategoryID))
               {
                  _loc3_.onRelease = function()
                  {
                     resetMenu();
                     this.fld.setTextFormat(tfNA);
                     setHiAnim(menuMC.shopMenu.hiSel1,this._y - menuMC._y - menuMC.shopMenu._y);
                     selectedButton = this;
                     updatePriceDescription();
                  };
               }
               else
               {
                  _loc3_.fld.setTextFormat(tfNA);
               }
               paintMenuArray.push(_loc3_);
            }
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   updatePriceDescription();
}
function resetMenu()
{
   var _loc1_ = 0;
   while(_loc1_ < paintMenuArray.length)
   {
      if(isPartCategoryInstalled(carXML.firstChild,paintMenuArray[_loc1_].partCategoryID))
      {
         paintMenuArray[_loc1_].fld.setTextFormat(tfInit);
      }
      _loc1_ = _loc1_ + 1;
   }
}
function updatePriceDescription()
{
   if(selectedButton)
   {
      priceDescription.text = selectedButton.txt + ": ($" + selectedButton.price + ")";
   }
   else
   {
      priceDescription.text = "";
   }
}
function isPartCategoryInstalled(xml, pid)
{
   if(pid < 0)
   {
      return true;
   }
   var _loc1_ = 0;
   while(_loc1_ < xml.childNodes.length)
   {
      if(Number(xml.childNodes[_loc1_].attributes.ci) == pid && Number(xml.childNodes[_loc1_].attributes["in"]) == 1)
      {
         return true;
      }
      _loc1_ = _loc1_ + 1;
   }
   return false;
}
function addToCart(clr)
{
   var _loc3_;
   var _loc5_;
   var _loc1_;
   var _loc2_;
   if(selectedButton)
   {
      if(selectedButton.partCategoryID == -2)
      {
         if(cartArray.length > 0)
         {
            if(cartArray[0].partCategoryID != -2)
            {
               cartArray = new Array();
            }
            cloneCarXML();
         }
      }
      else if(cartArray.length == 1)
      {
         if(cartArray[0].partCategoryID == -2)
         {
            cartArray = new Array();
            cloneCarXML();
         }
      }
      _loc3_ = false;
      i = 0;
      while(i < cartArray.length)
      {
         if(cartArray[i].partCategoryID == selectedButton.partCategoryID)
         {
            _loc5_ = new Object();
            _loc5_.partCategoryID = selectedButton.partCategoryID;
            _loc5_.price = selectedButton.price;
            _loc5_.pointPrice = selectedButton.pointPrice;
            _loc5_.paintColor = clr;
            cartArray[i] = _loc5_;
            _loc3_ = true;
            break;
         }
         i++;
      }
      if(!_loc3_)
      {
         _loc5_ = new Object();
         _loc5_.partCategoryID = selectedButton.partCategoryID;
         _loc5_.price = selectedButton.price;
         _loc5_.pointPrice = selectedButton.pointPrice;
         _loc5_.paintColor = clr;
         cartArray.push(_loc5_);
      }
      _loc1_ = 0;
      _loc2_ = 0;
      var i = 0;
      while(i < cartArray.length)
      {
         _loc1_ += cartArray[i].price;
         _loc2_ += cartArray[i].pointPrice;
         i++;
      }
      priceGroup.fldPrice.autoSize = true;
      priceGroup.txtPrice = "$" + _loc1_;
      if(priceGroup.fldPrice._width > 109)
      {
         priceGroup.fldPrice._xscale = 10900 / priceGroup.fldPrice._width;
         priceGroup.fldPrice._yscale = priceGroup.fldPrice._yscale;
      }
      pointsGroup.fldPoints.autoSize = true;
      pointsGroup.txtPoints = _loc2_;
      if(pointsGroup.fldPoints._width > 74)
      {
         pointsGroup.fldPoints._xscale = 7400 / pointsGroup.fldPoints._width;
         pointsGroup.fldPoints._yscale = pointsGroup.fldPoints._yscale;
      }
   }
   paintCar(clr);
}
function paintCar(clr)
{
   var _loc3_ = Number(selectedButton.partCategoryID);
   var _loc1_;
   if(_loc3_ == -2)
   {
      cloneXML.firstChild.attributes.cc = clr;
      for(var _loc4_ in cloneXML.firstChild.childNodes)
      {
         _loc1_ = cloneXML.firstChild.childNodes[_loc4_].attributes;
         if(_loc1_["in"] == 1 && classes.CarSpecs.isPaintable(Number(_loc1_.ci)))
         {
            _loc1_.cc = clr;
         }
      }
   }
   else if(_loc3_ == -1)
   {
      cloneXML.firstChild.attributes.cc = clr;
   }
   else
   {
      for(_loc4_ in cloneXML.firstChild.childNodes)
      {
         _loc1_ = cloneXML.firstChild.childNodes[_loc4_].attributes;
         if(_loc1_["in"] == 1 && Number(_loc1_.ci) == _loc3_)
         {
            _loc1_.cc = clr;
         }
      }
   }
   classes.Drawing.clearThisCarsBmps(carHolder);
   classes.Drawing.carView(carHolder,cloneXML,100,!isBack ? "front" : "back");
}
function checkOut(paymentType)
{
   var _loc3_ = "";
   var _loc2_ = 0;
   while(_loc2_ < cartArray.length)
   {
      _loc3_ += cartArray[_loc2_].partCategoryID + "~" + cartArray[_loc2_].paintColor;
      if(_loc2_ + 1 < cartArray.length)
      {
         _loc3_ += ",";
      }
      _loc2_ = _loc2_ + 1;
   }
   if(_loc3_.length > 0)
   {
      _root.buyPaint(accountCarID,escape(_loc3_),paymentType,cartArray);
   }
}
function setHiAnim(_mc, ty)
{
   _mc.ty = ty;
   _mc.onEnterFrame = function()
   {
      if(Math.abs(this.ty - this._y) > 0.1)
      {
         this._y += (this.ty - this._y) / 3;
      }
      else
      {
         this._y = this.ty;
         delete this.onEnterFrame;
      }
   };
}
function startBuyPaint(paymentType, amt)
{
   _root.attachMovie("alertBuyCar","abc",_root.getNextHighestDepth());
   _root.abc.addButton("OK",true);
   _root.abc.addButton("Cancel");
   _root.abc.contentMC.txtName = "Buying Paint Job";
   _root.abc.contentMC.alertIconMC._visible = false;
   _root.abc.contentMC.txtTitle = "Buying Paint Job";
   _root.abc.contentMC.createEmptyMovieClip("viewThumb",_root.abc.contentMC.getNextHighestDepth());
   _root.abc.contentMC.viewThumb._x = 264;
   _root.abc.contentMC.viewThumb._y = 143;
   _root.abc.thumb = new BitmapData(160,100,true,0);
   var _loc5_ = new flash.geom.Matrix(0.25,0,0,0.25,0,0);
   _root.abc.thumb.draw(carHolder,_loc5_,new ColorTransform(),"normal",null,true);
   _root.abc.contentMC.viewThumb.attachBitmap(_root.abc.thumb,0,"auto",true);
   _root.abc.contentMC.fldPrice.autoSize = "right";
   if(paymentType == "m")
   {
      _root.abc.contentMC.txtPrice = "$" + amt;
      _root.abc.contentMC.pointsIcon._visible = false;
      _root.abc.contentMC.txtMsg = "You have chosen to pay with your Funds. This will deduct " + amt + " from your funds.  Are you sure you want to buy this paint job?";
   }
   else
   {
      _root.abc.contentMC.txtPrice = amt + " Points";
      _root.abc.contentMC.pointsIcon._x = _root.abc.contentMC.fldPrice._x - _root.abc.contentMC.pointsIcon._width - 3;
      _root.abc.contentMC.txtMsg = "You have chosen to pay with your Points. This will deduct " + amt + " from your Points balance.  Are you sure you want to buy this paint job?";
   }
   var _loc4_ = new Object();
   _loc4_.onRelease = function(theButton, keepBoxOpen)
   {
      switch(theButton.btnLabel.text)
      {
         case "Cancel":
            break;
         case "OK":
            checkOut(paymentType);
            _root.abc.removeButtons();
            _root.abc.addDisabledButton("Cancel");
            _root.abc.addDisabledButton("OK");
      }
      if(!keepBoxOpen)
      {
         false;
         theButton._parent._parent.closeMe();
      }
   };
   _root.abc.addListener(_loc4_);
}
function afterDialogSelectCar()
{
   cc.garbageCollect();
   _parent.sectionName = "paint";
   _parent.locationID = locationID;
   _parent.gotoAndPlay(1);
}
