class classes.CarPickerGarage extends MovieClip
{
   var btnLeft;
   var btnRight;
   var carCount;
   var currentHole;
   var currentIndex;
   var displayWidth;
   var fullyLoaded;
   var gridHoles;
   var hi;
   var impoundIndex;
   var impoundedClick;
   var loadedCars;
   var maxIndex;
   var moveCount;
   var numberOfDots;
   var obj;
   var onClick;
   var onRO;
   var pickerType;
   var selectXML;
   var slotGroup;
   var tX;
   var useScrollerButtons;
   var hSpace = 106;
   var slotCount = 0;
   var impoundCount = 0;
   function CarPickerGarage()
   {
      super();
   }
   function CarPicker()
   {
      this.cacheAsBitmap = true;
      this.btnLeft._visible = false;
      this.btnRight._visible = false;
      this.useScrollerButtons = false;
   }
   function init(pickerXML, onClickIn, onROIn)
   {
      this.useScrollerButtons = true;
      this.currentIndex = 0;
      this.currentHole = 0;
      this.maxIndex = -1;
      if(this.impoundCount)
      {
         this.slotCount = this.slotCount + 1;
         this.carCount = this.carCount + 1;
      }
      this.moveCount = Math.floor(this.displayWidth / this.hSpace);
      this.numberOfDots = Math.ceil(this.carCount / this.moveCount);
      this.btnLeft._visible = true;
      this.btnRight._visible = true;
      this.onRO = onROIn;
      this.onClick = onClickIn;
      this.loadedCars = new Array();
      trace("car picker x: " + this._x);
      trace("car picker y: " + this._y);
      var i = 0;
      var _loc3_;
      while(i < this.numberOfDots)
      {
         this.loadedCars[i] = false;
         trace("holes!");
         _loc3_ = this.gridHoles.attachMovie("carPickerGridHole",String("hole" + i),this.gridHoles.getNextHighestDepth(),{_x:-1 + i * 11,_y:-2});
         _loc3_.id = i;
         this.setHoleFunctions(_loc3_);
         if(i == 0)
         {
            _loc3_.gotoAndStop(2);
            _loc3_.onRollOut = null;
            _loc3_.onRollOver = null;
         }
         i++;
      }
      this.btnLeft.enabled = false;
      if(this.currentIndex + this.moveCount >= pickerXML.firstChild.childNodes.length)
      {
         this.btnRight.enabled = false;
      }
      else
      {
         this.btnRight.enabled = true;
      }
      var _loc6_ = false;
      var _loc4_;
      var _loc8_;
      if(this.impoundCount)
      {
         _loc4_ = 0;
         while(_loc4_ <= pickerXML.firstChild.childNodes.length)
         {
            if(pickerXML.firstChild.childNodes[_loc4_].nodeName == "empty")
            {
               _loc6_ = true;
               this.impoundIndex = _loc4_;
               _loc8_ = new XMLNode(1,"impound");
               pickerXML.firstChild.insertBefore(_loc8_,pickerXML.firstChild.childNodes[_loc4_]);
               break;
            }
            _loc4_ = _loc4_ + 1;
         }
         if(_loc6_ == false)
         {
            this.impoundIndex = this.slotCount - 1;
            _loc8_ = new XMLNode(1,"impound");
            pickerXML.firstChild.appendChild(_loc8_);
         }
      }
      this.btnLeft.onRelease = function()
      {
         trace("btnLeft!");
         var _loc3_ = this._parent.currentIndex / this._parent.moveCount;
         this._parent.setNewHole(_loc3_ - 1,this._parent);
         trace("number of holes: " + Number(_global.locationXML.firstChild.childNodes[i].attributes.ps) * (!Number(classes.GlobalData.attr.mb) ? 1 : 2));
      };
      this.btnRight.onRelease = function()
      {
         trace("btnRight!");
         var _loc2_ = this._parent.currentIndex / this._parent.moveCount;
         this._parent.setNewHole(_loc2_ + 1,this._parent);
      };
      if(!pickerXML.firstChild.childNodes.length)
      {
         this.showNoneAvailable();
      }
      else
      {
         this.selectXML = pickerXML;
      }
      this.slotGroup.fullyLoaded = false;
      this.drawCars(this);
      this.setTextCars(this);
      this.slotGroup.hi = pickerXML.firstChild.childNodes.length - 1;
      var _loc7_ = this.createEmptyMovieClip("displayMask",this.getNextHighestDepth());
      classes.Drawing.rect(_loc7_,this.displayWidth,this.slotGroup.slot0._height,0,0,12);
      this.slotGroup.setMask(_loc7_);
   }
   function setHoleFunctions(hole)
   {
      trace("setHoleFunctions");
      hole.onRollOver = function()
      {
         this.gotoAndStop(3);
      };
      hole.onRollOut = function()
      {
         trace("onRollOut");
         this.gotoAndStop(1);
      };
      hole.onRelease = this.holeRelease;
   }
   function holeRelease()
   {
      this._parent._parent.setNewHole(MovieClip(this).id,this._parent._parent);
   }
   function setNewHole(newHole, mainClip)
   {
      trace("main clip location: " + mainClip._x + " " + mainClip._y);
      var _loc4_ = mainClip.currentIndex / mainClip.moveCount;
      trace("newHole");
      trace(newHole);
      trace(mainClip);
      trace(_loc4_);
      var _loc5_ = false;
      if(newHole > _loc4_)
      {
         _loc5_ = true;
      }
      var _loc6_ = this.moveCount * this.hSpace * (_loc4_ - newHole);
      if(newHole < this.carCount / this.moveCount)
      {
         mainClip.gridHoles[String("hole" + mainClip.currentHole)].gotoAndStop(1);
         this.setHoleFunctions(mainClip.gridHoles[String("hole" + mainClip.currentHole)]);
         mainClip.gridHoles[String("hole" + newHole)].gotoAndStop(2);
         mainClip.gridHoles[String("hole" + newHole)].onRollOut = null;
         mainClip.gridHoles[String("hole" + newHole)].onRollOver = null;
         mainClip.currentHole = newHole;
      }
      mainClip.currentIndex = newHole * mainClip.moveCount;
      this.setTextCars(mainClip);
      mainClip.drawCars(mainClip);
      mainClip.doTween(_loc5_,_loc6_);
   }
   function setTextCars(context)
   {
      trace("setTextCars");
      trace(context);
      var _loc4_ = context.currentIndex / context.moveCount;
      trace(String((_loc4_ + 1) * context.moveCount));
      var _loc2_ = context.carCount;
      var _loc3_ = (_loc4_ + 1) * context.moveCount;
      if(context.impoundCount)
      {
         _loc2_ -= 1;
         if(context.currentIndex + context.moveCount > context.impoundIndex)
         {
            _loc3_ -= 1;
         }
      }
      if(_loc3_ > _loc2_)
      {
         _loc3_ = _loc2_;
      }
      context.txtCars.text = String(String(_loc3_) + "/" + String(_loc2_));
   }
   function setScrollAction()
   {
      if(this.useScrollerButtons == false && this.slotGroup._width > this.displayWidth)
      {
         this.slotGroup.onEnterFrame = function()
         {
            var _loc3_;
            if(this.fullyLoaded)
            {
               if(this["slot" + this.hi]._width && this.hitTest(_root._xmouse,_root._ymouse,false))
               {
                  this.tX = (- (this._width - this._parent.displayWidth)) * this._parent._xmouse / this._parent.displayWidth;
                  this._x += (this.tX - this._x) / 3;
               }
            }
            else
            {
               _loc3_ = 0;
               for(var _loc4_ in this)
               {
                  if(_loc4_.substr(0,4) == "slot")
                  {
                     if(this[_loc4_].thumb.loaded || !this[_loc4_].cid)
                     {
                        _loc3_ = _loc3_ + 1;
                     }
                  }
               }
               if(_loc3_ >= this._parent.slotCount)
               {
                  this.fullyLoaded = true;
               }
            }
         };
      }
   }
   function setSelectedSlot(idx)
   {
      trace("setSelectedSlot: " + idx);
      for(var _loc3_ in this.slotGroup)
      {
         if(_loc3_.substr(0,4) == "slot")
         {
            this.slotGroup[_loc3_].btn._visible = true;
            this.slotGroup[_loc3_].hi._visible = false;
            if(this.slotGroup[_loc3_].idx == idx)
            {
               this.slotGroup[_loc3_].btn._visible = false;
               this.slotGroup[_loc3_].hi._visible = true;
            }
         }
      }
   }
   function setSelectedCar(cid)
   {
      for(var _loc2_ in this.slotGroup)
      {
         if(_loc2_.substr(0,4) == "slot")
         {
            if(classes.GlobalData.attr.dc == this.slotGroup[_loc2_].cid)
            {
               this.setSelectedSlot(this.slotGroup[_loc2_].idx);
               break;
            }
         }
      }
   }
   function initDrivable(listXML, onClick, onRO)
   {
      this.pickerType = 0;
      var _loc3_ = new XML(listXML.toString());
      var _loc4_ = _loc3_.firstChild.childNodes.length - 1;
      var _loc2_;
      if(!isNaN(_loc4_))
      {
         _loc2_ = _loc4_;
         while(_loc2_ >= 0)
         {
            if(Number(_loc3_.firstChild.childNodes[_loc2_].attributes.ii))
            {
               _loc3_.firstChild.childNodes[_loc2_].removeNode();
               this.impoundCount = this.impoundCount + 1;
            }
            else if(Number(_loc3_.firstChild.childNodes[_loc2_].attributes.lk))
            {
               _loc3_.firstChild.childNodes[_loc2_].removeNode();
            }
            _loc2_ = _loc2_ - 1;
         }
      }
      if(_loc3_.firstChild.childNodes.length)
      {
         this.init(_loc3_,onClick,onRO);
      }
      else
      {
         this.showNoneAvailable();
      }
   }
   function initSellable(listXML, onClick, onRO)
   {
      this.pickerType = 0;
      var _loc3_ = new XML(listXML.toString());
      var _loc4_ = _loc3_.firstChild.childNodes.length - 1;
      var _loc2_;
      if(!isNaN(_loc4_))
      {
         _loc2_ = _loc4_;
         while(_loc2_ >= 0)
         {
            if(Number(_loc3_.firstChild.childNodes[_loc2_].attributes.lk))
            {
               _loc3_.firstChild.childNodes[_loc2_].removeNode();
            }
            _loc2_ = _loc2_ - 1;
         }
      }
      if(_loc3_.firstChild.childNodes.length)
      {
         this.init(_loc3_,onClick,onRO);
      }
      else
      {
         this.showNoneAvailable();
      }
   }
   function initEngines(pickerXML, onClick, onRO)
   {
      this.pickerType = 0;
      var _loc3_;
      var _loc5_;
      var _loc8_;
      var _loc6_;
      if(pickerXML.firstChild.childNodes.length)
      {
         if(this.selectXML.firstChild.childNodes.length)
         {
            _loc3_ = 0;
            while(_loc3_ < pickerXML.firstChild.childNodes.length)
            {
               this.selectXML.firstChild.appendChild(pickerXML.firstChild.childNodes[_loc3_].cloneNode(true));
               _loc3_ = _loc3_ + 1;
            }
         }
         else
         {
            this.selectXML = pickerXML;
         }
         _loc5_ = this.slotCount;
         _loc8_ = _loc5_ + pickerXML.firstChild.childNodes.length;
         _loc6_ = _loc5_ * this.hSpace;
         _loc3_ = _loc5_;
         while(_loc3_ < _loc8_)
         {
            this.slotGroup.attachMovie("carPickerEngineSlot","slot" + _loc3_,_loc3_,{_x:_loc6_});
            _loc6_ += 66;
            this.slotGroup["slot" + _loc3_].idx = _loc3_;
            this.slotGroup["slot" + _loc3_].hi._visible = false;
            this.slotGroup["slot" + _loc3_].locked._visible = false;
            this.slotGroup["slot" + _loc3_].forSale._visible = false;
            this.slotGroup["slot" + _loc3_].testDriveExpired._visible = false;
            this.slotGroup["slot" + _loc3_].eid = Number(pickerXML.firstChild.childNodes[_loc3_ - _loc5_].attributes.i);
            this.slotGroup["slot" + _loc3_].ei = Number(pickerXML.firstChild.childNodes[_loc3_ - _loc5_].attributes.ei);
            this.slotGroup["slot" + _loc3_].txt = pickerXML.firstChild.childNodes[_loc3_ - _loc5_].attributes.n;
            this.slotGroup["slot" + _loc3_].createEmptyMovieClip("thumb",2);
            this.slotGroup["slot" + _loc3_].thumb._x = 30;
            this.slotGroup["slot" + _loc3_].thumb._y = -5;
            this.slotGroup["slot" + _loc3_].thumb._xscale = 50;
            this.slotGroup["slot" + _loc3_].thumb._yscale = 50;
            trace(_global.assetPath + "/parts/m" + this.slotGroup["slot" + _loc3_].ei + ".swf");
            this.slotGroup["slot" + _loc3_].thumb.loadMovie(_global.assetPath + "/parts/m" + this.slotGroup["slot" + _loc3_].ei + ".swf");
            this.slotGroup["slot" + _loc3_].btn.onRollOver = function()
            {
               onRO.call(this._parent,this._parent.idx);
            };
            this.slotGroup["slot" + _loc3_].btn.onRelease = function()
            {
               onClick.call(this._parent._parent._parent._parent,this._parent.eid);
               this._parent._parent._parent.setSelectedSlot(this._parent.idx);
            };
            this.slotCount = this.slotCount + 1;
            _loc3_ = _loc3_ + 1;
         }
         this.slotGroup.hi = pickerXML.firstChild.childNodes.length - 1;
         if(!displayMask)
         {
            var displayMask = this.createEmptyMovieClip("displayMask",this.getNextHighestDepth());
            classes.Drawing.rect(displayMask,this.displayWidth,this.slotGroup.slot0._height,0,0);
            this.slotGroup.setMask(displayMask);
         }
         this.setScrollAction();
      }
   }
   function initHomeGarage(listXML, onClick, onRO)
   {
      this.pickerType = 1;
      var _loc4_ = new XML(listXML.toString());
      var _loc8_ = _loc4_.firstChild.childNodes.length;
      var _loc3_;
      if(!isNaN(_loc8_))
      {
         _loc3_ = _loc8_ - 1;
         while(_loc3_ >= 0)
         {
            if(Number(_loc4_.firstChild.childNodes[_loc3_].attributes.ii))
            {
               _loc4_.firstChild.childNodes[_loc3_].removeNode();
               this.impoundCount = this.impoundCount + 1;
            }
            _loc3_ = _loc3_ - 1;
         }
      }
      var _loc7_ = _loc4_.firstChild.childNodes.length;
      this.carCount = _loc7_;
      var _loc6_ = 0;
      _loc3_ = 0;
      while(_loc3_ < _global.locationXML.firstChild.childNodes.length)
      {
         if(classes.GlobalData.attr.lid == _global.locationXML.firstChild.childNodes[_loc3_].attributes.lid)
         {
            _loc6_ = Number(_global.locationXML.firstChild.childNodes[_loc3_].attributes.ps) * (!Number(classes.GlobalData.attr.mb) ? 1 : 2);
         }
         _loc3_ = _loc3_ + 1;
      }
      trace("number of spots: " + _loc6_);
      _loc3_ = _loc7_;
      var _loc5_;
      while(_loc3_ < _loc6_)
      {
         _loc5_ = new XMLNode(1,"empty");
         _loc4_.firstChild.appendChild(_loc5_);
         _loc3_ = _loc3_ + 1;
      }
      this.slotCount = Number(_loc4_.firstChild.childNodes.length);
      if(_loc4_.firstChild.childNodes.length)
      {
         this.init(_loc4_,onClick,onRO);
      }
      else
      {
         this.showNoneAvailable();
      }
   }
   function showNoneAvailable()
   {
      trace("showNoneAvailable");
      this.slotGroup.slot0.locked._visible = false;
      this.slotGroup.slot0.forSale._visible = false;
      this.slotGroup.slot0.testDriveExpired._visible = false;
      this.slotGroup.slot0.attachMovie("carPickerNoneAvailable","noneAvailable",1);
   }
   function showImpounded(onClick, onRO)
   {
      this.impoundedClick = onClick;
   }
   function doImpounded()
   {
      trace("showImpounded");
      var _loc3_;
      var _loc2_;
      var _loc4_;
      if(this.impoundCount)
      {
         _loc3_ = this.impoundCount + "\rCAR";
         if(this.impoundCount > 1)
         {
            _loc3_ += "S";
         }
         _loc3_ += " IMPOUNDED";
         trace("impoundIndex: " + this.impoundIndex);
         trace("slotX: " + this.slotGroup["slot" + this.impoundIndex]._x);
         _loc2_ = this.slotGroup["slot" + this.impoundIndex];
         _loc4_ = 0;
         _loc2_._x = this.impoundIndex * this.hSpace;
         _loc2_.idx = this.impoundIndex;
         _loc2_.lines._visible = false;
         _loc2_.forSale._visible = false;
         _loc2_.locked._visible = true;
         _loc2_.testDriveExpired._visible = false;
         _loc2_.attachMovie("carPickerCarsImpounded","carsImpounded",1,{txt:_loc3_});
         _loc2_.btn.onRelease = function()
         {
            trace("impoundedClick" + this._parent._parent._parent);
            this._parent._parent._parent.impoundedClick.call(this._parent,this._parent.idx);
         };
         this.setScrollAction();
      }
   }
   function doTween(goRight, scrollAmount)
   {
      trace("hi");
      trace("btnRight: " + this.btnRight);
      this.btnRight.enabled = false;
      this.btnLeft.enabled = false;
      this.enableDots(false);
      trace("scrollAmount: " + scrollAmount);
      trace(this);
      trace(this._x);
      var _loc2_ = new mx.transitions.Tween(this.slotGroup,"_x",mx.transitions.easing.Strong.easeOut,this.slotGroup._x,this.slotGroup._x + scrollAmount,0.5,true);
      _loc2_.onMotionFinished = function()
      {
         trace("btnRight: " + this.obj._parent.btnRight);
         trace("parent: " + this.obj._parent);
         this.obj._parent.enableDots(true);
         this.obj._parent.btnRight.enabled = true;
         this.obj._parent.btnLeft.enabled = true;
         if(this.obj._parent.currentIndex == 0)
         {
            this.obj._parent.btnLeft.enabled = false;
         }
         else if(this.obj._parent.currentIndex + this.obj._parent.moveCount >= this.obj._parent.selectXML.firstChild.childNodes.length)
         {
            this.obj._parent.btnRight.enabled = false;
         }
      };
   }
   function drawCars(context)
   {
      with(context)
      {
         trace("context: " + context);
         trace("currentIndex: " + currentIndex);
         trace("maxIndex: " + maxIndex);
         var initialValue = this.currentIndex;
         var alreadyLoaded = false;
         if(loadedCars[initialValue / moveCount] == false)
         {
            var pickerXML = selectXML;
            maxIndex = currentIndex;
            trace(maxIndex);
            loadedCars[initialValue / moveCount] = true;
            if(this.currentIndex == 0)
            {
               var i = 1;
               while(i < slotCount)
               {
                  trace("empty!");
                  slotGroup.slot0.duplicateMovieClip("slot" + i,i,{_x:i * hSpace});
                  slotGroup["slot" + i].locked._visible = false;
                  slotGroup["slot" + i].forSale._visible = false;
                  slotGroup["slot" + i].testDriveExpired._visible = false;
                  slotGroup["slot" + i].hi._visible = false;
                  if(pickerXML.firstChild.childNodes[i].nodeName == "empty")
                  {
                     slotGroup["slot" + i].attachMovie("carPickerEmpty","empty",1);
                     slotGroup["slot" + i].btn.enabled = false;
                  }
                  i++;
               }
            }
            trace("initialValue: " + initialValue);
            trace("currentIndex: " + currentIndex);
            var i = initialValue;
            while(i < this.currentIndex + moveCount)
            {
               trace("i: " + i);
               trace(slotGroup["slot" + i]._x);
               trace("booyaa!");
               if(pickerXML.firstChild.childNodes[i].nodeName == "impound")
               {
                  doImpounded();
                  slotGroup["slot" + i].hi._visible = false;
                  slotGroup["slot" + i].idx = i;
               }
               else if(pickerXML.firstChild.childNodes[i].nodeName != "empty")
               {
                  slotGroup["slot" + i].locked._visible = true;
                  slotGroup["slot" + i].forSale._visible = true;
                  slotGroup["slot" + i].testDriveExpired._visible = true;
                  trace("full slot");
                  slotGroup["slot" + i].hi._visible = false;
                  slotGroup["slot" + i].idx = i;
                  slotGroup["slot" + i].cid = Number(pickerXML.firstChild.childNodes[i].attributes.i);
                  slotGroup["slot" + i].createEmptyMovieClip("plateHolder",1);
                  slotGroup["slot" + i].plateHolder._x = 22;
                  classes.Drawing.plateView(slotGroup["slot" + i].plateHolder,Number(pickerXML.firstChild.childNodes[i].attributes.pi),pickerXML.firstChild.childNodes[i].attributes.pn,13.5,true);
                  slotGroup["slot" + i].createEmptyMovieClip("thumb",2);
                  slotGroup["slot" + i].thumb._x = 40;
                  slotGroup["slot" + i].thumb._y = -5;
                  trace("ii:" + Number(pickerXML.firstChild.childNodes[i].attributes.ii));
                  if(!Number(pickerXML.firstChild.childNodes[i].attributes.ii))
                  {
                     slotGroup["slot" + i].locked._visible = false;
                  }
                  else
                  {
                     slotGroup["slot" + i].locked.swapDepths(3);
                  }
                  if(!Number(pickerXML.firstChild.childNodes[i].attributes.lk))
                  {
                     trace("make lock invisible!");
                     slotGroup["slot" + i].forSale._visible = false;
                  }
                  else
                  {
                     trace("make lock visible!");
                     slotGroup["slot" + i].forSale._visible = true;
                     slotGroup["slot" + i].forSale.swapDepths(4);
                  }
                  trace("expired: " + pickerXML.firstChild.childNodes[i].attributes.tdex);
                  if(!Number(pickerXML.firstChild.childNodes[i].attributes.tdex))
                  {
                     slotGroup["slot" + i].testDriveExpired._visible = false;
                  }
                  else
                  {
                     trace("yeah expired!");
                     slotGroup["slot" + i].testDriveExpired._visible = true;
                     trace(slotGroup["slot" + i].testDriveExpired);
                     trace(slotGroup["slot" + i].testDriveExpired._visible);
                     slotGroup["slot" + i].locked._visible = false;
                     slotGroup["slot" + i].forSale._visible = false;
                     slotGroup["slot" + i].testDriveExpired.swapDepths(5);
                  }
                  slotGroup["slot" + i].btn.onRollOver = function()
                  {
                     onRO.call(_parent,this._parent.idx);
                  };
                  trace("pickerType: " + pickerType);
                  if(Number(pickerXML.firstChild.childNodes[i].attributes.tdex) && pickerType == 1)
                  {
                     trace("add onrelease!");
                     slotGroup["slot" + i].btn.onRelease = function()
                     {
                        _root.displayTestDriveExpiredIfNecessaryNotLogin();
                     };
                  }
                  else
                  {
                     slotGroup["slot" + i].btn.onRelease = function()
                     {
                        onClick.call(this._parent._parent._parent._parent,this._parent.idx);
                        this._parent._parent._parent.setSelectedSlot(this._parent.idx);
                     };
                  }
               }
               classes.Drawing.carView(slotGroup["slot" + i].thumb,new XML(pickerXML.firstChild.childNodes[i].toString()),12.5,"front");
               i++;
            }
            slotGroup["slot" + i].cacheAsBitmap = true;
         }
      }
   }
   function enableDots(enable)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.numberOfDots)
      {
         trace("gridHoles: " + this.gridHoles);
         this.gridHoles[String("hole" + _loc2_)].enabled = enable;
         _loc2_ = _loc2_ + 1;
      }
   }
}
