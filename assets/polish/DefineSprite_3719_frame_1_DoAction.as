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
   // Member-only colours arrive flagged mc='1'. The server has always REJECTED
   // them for non-members (local-account-store: "membership-required"), but the
   // shop drew them exactly like any other swatch, so the only feedback was a
   // failed purchase. Dim them and leave them unclickable instead.
   var _loc7_ = Number(classes.GlobalData.attr.mb) > 0;
   while(_loc5_ < _loc6_.childNodes.length)
   {
      if(_loc6_.childNodes[_loc5_].attributes.l == locationID)
      {
         _loc4_ = paintSwatchArray.length;
         _loc3_ = classes.PaintSwatch(paintSwatchContainer.attachMovie("paintSwatch","swatch" + _loc4_,paintSwatchContainer.getNextHighestDepth()));
         _loc3_._x = Math.floor(_loc4_ / columns) * xIndent + _loc4_ % columns * xSpacing;
         _loc3_._y = Math.floor(_loc4_ / columns) * yIndent;
         _loc3_.HexColor = _loc6_.childNodes[_loc5_].attributes.c;
         if(Number(_loc6_.childNodes[_loc5_].attributes.mc) == 1 && !_loc7_)
         {
            _loc3_._alpha = 32;
         }
         else
         {
            _loc3_.swatchColorMC.onRelease = function()
            {
               this._parent._parent._parent.addToCart(this._parent.hexColor);
            };
         }
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
   // Show whatever finish this car already carries rather than resetting it, now
   // that the finish is keyed per car instead of being one global override.
   selectedFinish = Number(classes.CarConstruction.finishStore()[accountCarID]);
   if(!selectedFinish)
   {
      selectedFinish = 0;
   }
   // Built from the shop's own shopMenuListItem symbol rather than a runtime
   // TextField. Two attempts at createTextField here rendered the plate but never
   // the label: a runtime field with the "_sans" device font draws nothing in this
   // Director-hosted player. shopMenuListItem already renders text correctly (it
   // is what draws the menu above), carries its own `txt` setter and `fld`, and
   // works when attached to a createEmptyMovieClip - drawMenu does exactly that.
   // Placed under btnSpecific in the left menu column, read from the instance at
   // runtime so it tracks the real layout, and where there is guaranteed room.
   finishPicker = this.createEmptyMovieClip("finishPicker",20000);
   finishPicker._x = btnSpecific._x;
   finishPicker._y = btnSpecific._y + 26;
   finishBtnArray = new Array();
   // Index 6 is the underglow colour cycler, not a finish. It rides this loop,
   // highlightFinish and setFinish's redraw rather than bringing its own
   // attachMovie/label/redraw trio - a second set does not fit the budget.
   var _loc4_ = new Array("Gloss finish","Matte finish","Satin finish","Candy finish","Flake finish","Pearl finish","Underglow");
   var _loc2_ = 0;
   var _loc3_;
   // Finishes and underglow are members-only. Row 0 (Gloss) stays open to
   // everyone - it is the "no finish" state, so locking it would strand a
   // lapsed member on whatever they last picked with no way back to stock.
   //
   // Enforced client-side because the feature IS client-side: a finish lives in
   // a local SharedObject and underglow only in memory, so there is no server
   // call to reject. That makes the gate bypassable by a modified client, but
   // the prize is a cosmetic nobody else can see - not worth more than this
   // until they become server entities, at which point the check moves there.
   var _loc5_ = Number(classes.GlobalData.attr.mb) > 0;
   while(_loc2_ < _loc4_.length)
   {
      _loc3_ = finishPicker.attachMovie("shopMenuListItem","fin" + _loc2_,_loc2_ + 1);
      _loc3_._y = _loc2_ * paintMenuYSpacing;
      _loc3_.finishID = _loc2_;
      _loc3_.txt = _loc4_[_loc2_];
      if(_loc2_ > 0 && !_loc5_)
      {
         _loc3_._alpha = 40;
         _loc2_ = _loc2_ + 1;
         finishBtnArray.push(_loc3_);
         continue;
      }
      _loc3_.onRelease = function()
      {
         if(this.finishID < 6)
         {
            setFinish(this.finishID);
         }
         else
         {
            // Cycle the colour rather than toggling, so the row doubles as the
            // colour picker without spending a second row of a menu that is
            // already taller than its panel.
            glowStep = !glowStep ? 1 : glowStep + 1;
            if(glowStep >= classes.CarConstruction.glowColors.length)
            {
               glowStep = 0;
            }
            classes.CarConstruction.glowMap[accountCarID] = classes.CarConstruction.glowColors[glowStep];
            setFinish(selectedFinish);
         }
      };
      finishBtnArray.push(_loc3_);
      _loc2_ = _loc2_ + 1;
   }
   highlightFinish();
}
function setFinish(fin)
{
   selectedFinish = fin;
   classes.CarConstruction.setCarFinish(accountCarID,fin);
   highlightFinish();
   classes.Drawing.clearThisCarsBmps(carHolder);
   classes.Drawing.carView(carHolder,cloneXML,100,!isBack ? "front" : "back");
}
function highlightFinish()
{
   // tfInit (white) / tfNA (grey) are the shop's own menu formats, so the
   // selected finish reads the same way a selected menu row does.
   var _loc1_ = 0;
   while(_loc1_ < finishBtnArray.length)
   {
      // selectedFinish is only ever 0-5, so row 6 lights from the glow colour.
      if(_loc1_ == selectedFinish || _loc1_ == 6 && classes.CarConstruction.glowMap[accountCarID])
      {
         finishBtnArray[_loc1_].fld.setTextFormat(tfInit);
      }
      else
      {
         finishBtnArray[_loc1_].fld.setTextFormat(tfNA);
      }
      _loc1_ = _loc1_ + 1;
   }
}
function drawMenu()
{
   // The category list has always been taller than the plate behind it: rows run
   // from y=127 at a 14px pitch and the panel ends near y=344, so it held about
   // 16 of them. Fender Effect, Door Effect and Convertible Top were already
   // falling off the bottom before Wheels was added, and Wheels - being last -
   // landed clear outside and could not be clicked at all. 11px fits all 20
   // inside the plate. Set here rather than in DoAction_2, which carries the
   // original constants but is a duplicate frame tag FFDec cannot -replace.
   paintMenuYSpacing = 11;
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
      paintSwatchContainer._x = priceDescription._x = 200;
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
      paintSwatchContainer._x = priceDescription._x = 350;
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
   // Do NOT prefix a finish onto clr here. Tried 2026-07-26: sending an
   // 8-character cc ("05" + "C1121F") makes the server reject the purchase with
   // "illegal action" - it validates the colour string, so the high byte of cc is
   // not a usable channel and finishes cannot be server-persisted or made visible
   // to other players this way. checkOut must keep sending six characters.
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
