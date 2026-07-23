class classes.GaragePartMenu
{
   var __MC;
   var _y;
   var ai;
   var checkSI;
   var clr;
   var hasChild;
   var hitTest;
   var idx;
   var menuDepth;
   var menuItemHeight;
   var objRef;
   var onEnterFrame;
   var onPartClickAction;
   var partCatXML;
   var partType;
   var partXML;
   var pcid;
   var selectedCarXML;
   var showSI;
   var tfInit;
   var tfInstalled;
   var tfNA;
   var tfSpare;
   var ty;
   var yShow;
   function GaragePartMenu(mc, pPartCatXML, pPartXML, pSelectedCarXML, pOnPartClickAction)
   {
      this.__MC = mc;
      this.__MC.objRef = this;
      this.partCatXML = pPartCatXML;
      this.partXML = pPartXML;
      this.selectedCarXML = pSelectedCarXML;
      this.onPartClickAction = pOnPartClickAction;
      this.menuItemHeight = 13;
      this.tfInit = new TextFormat();
      this.tfInit.color = 16777215;
      this.tfNA = new TextFormat();
      this.tfNA.color = 6710886;
      this.tfInstalled = new TextFormat();
      this.tfInstalled.color = 6750054;
      this.tfSpare = new TextFormat();
      this.tfSpare.color = 16761421;
      this.yShow = this.__MC._y;
      this.__MC._parent.bars.objRef = this;
      this.__MC._parent.bars.onRollOver = function()
      {
         this.objRef.showPanel();
      };
      this.init();
   }
   function getCategoryAvailability(parentID, p)
   {
      var _loc7_ = 0;
      var _loc4_ = this.partCatXML.firstChild;
      var _loc3_ = 0;
      var _loc5_;
      var _loc2_;
      while(_loc3_ < _loc4_.childNodes.length)
      {
         if(_loc4_.childNodes[_loc3_].attributes.pi == parentID)
         {
            _loc5_ = 0;
            if(_loc4_.childNodes[_loc3_].attributes.c == 0)
            {
               _loc2_ = 0;
               while(_loc2_ < p.firstChild.childNodes.length)
               {
                  if(p.firstChild.childNodes[_loc2_].attributes.pi == _loc4_.childNodes[_loc3_].attributes.i)
                  {
                     _loc5_ = _loc5_ + 1;
                  }
                  _loc2_ = _loc2_ + 1;
               }
            }
            else
            {
               _loc5_ = this.getCategoryAvailability(_loc4_.childNodes[_loc3_].attributes.i,p);
            }
            _loc7_ += _loc5_;
            _loc4_.childNodes[_loc3_].attributes.p = _loc5_;
         }
         _loc3_ = _loc3_ + 1;
      }
      return _loc7_;
   }
   function getCategory(parentID, menuDepth, dotClr)
   {
      this.collapseToDepth(menuDepth);
      var _loc7_ = this.__MC.createEmptyMovieClip("partContainer" + menuDepth,this.__MC.getNextHighestDepth());
      _loc7_._x = 16 + menuDepth * 140;
      var _loc3_ = this.partCatXML.firstChild;
      var _loc5_ = 0;
      var _loc10_ = "";
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc4_].attributes.i == parentID)
         {
            _loc10_ = _loc3_.childNodes[_loc4_].attributes.n;
            break;
         }
         _loc4_ = _loc4_ + 1;
      }
      if(!dotClr && dotClr !== 0)
      {
         dotClr = 11184810;
      }
      if(menuDepth > 0)
      {
         this.__MC._parent["dot" + menuDepth + "Clr"] = new Color(this.__MC._parent["dot" + menuDepth]);
         this.__MC._parent["dot" + menuDepth]._visible = true;
         this.__MC._parent["dot" + menuDepth + "Clr"].setRGB(dotClr);
         this.__MC._parent["txtHead" + menuDepth] = _loc10_;
      }
      _loc4_ = 0;
      var _loc6_;
      var _loc2_;
      while(_loc4_ < _loc3_.childNodes.length)
      {
         _loc6_ = false;
         switch(Number(_loc3_.childNodes[_loc4_].attributes.i))
         {
            case 101:
            case 126:
            case 127:
            case 138:
               _loc6_ = true;
         }
         if(_loc3_.childNodes[_loc4_].attributes.pi == parentID && !_loc6_ && _loc3_.childNodes[_loc4_].attributes.pi != 22)
         {
            _loc2_ = _loc7_.attachMovie("shopMenuListItem","cat" + _loc5_,_loc7_.getNextHighestDepth());
            _loc2_.txt = _loc3_.childNodes[_loc4_].attributes.n;
            _loc2_.clr = new Color(_loc2_.dot);
            if(_loc3_.childNodes[_loc4_].attributes.cl.length)
            {
               _loc2_.clr.setRGB(Number("0x" + _loc3_.childNodes[_loc4_].attributes.cl));
            }
            else
            {
               _loc2_.clr.setRGB(dotClr);
            }
            if(_loc3_.childNodes[_loc4_].attributes.c > 0)
            {
               _loc2_.hasChild = 1;
            }
            else
            {
               _loc2_.hasChild = 0;
            }
            _loc2_._y = 3 + _loc5_ * this.menuItemHeight;
            _loc2_.pcid = _loc3_.childNodes[_loc4_].attributes.i;
            _loc2_.idx = _loc5_;
            _loc2_.menuDepth = menuDepth;
            _loc2_.objRef = this;
            _loc2_.onRollOver = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,this.idx);
            };
            _loc2_.onRollOut = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth);
            };
            _loc2_.onRelease = function()
            {
               if(this.hasChild == 1)
               {
                  this.objRef.getCategory(this.pcid,this.menuDepth + 1,this.clr.getRGB());
               }
               else
               {
                  this.objRef.getPart(this.pcid,this.menuDepth + 1,this.clr.getRGB());
               }
               this.objRef.setHiMotion("hiSel",this.menuDepth,this.idx);
               this.objRef.setHiText(this.menuDepth,this.idx,this.objRef.tfNA);
            };
            if(_loc3_.childNodes[_loc4_].attributes.p <= 0)
            {
               _loc2_.na = true;
               _loc2_.fld.setTextFormat(this.tfNA);
            }
            _loc5_ = _loc5_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function getPart(parentID, menuDepth, dotClr)
   {
      this.collapseToDepth(menuDepth);
      var partContainer = this.__MC.createEmptyMovieClip("partContainer" + menuDepth,this.__MC.getNextHighestDepth());
      partContainer._x = 16 + menuDepth * 140;
      var xmlnode = this.partCatXML.firstChild;
      var headName = "";
      var i = 0;
      while(i < xmlnode.childNodes.length)
      {
         if(xmlnode.childNodes[i].attributes.i == parentID)
         {
            headName = xmlnode.childNodes[i].attributes.n;
            break;
         }
         i++;
      }
      if(!dotClr && dotClr !== 0)
      {
         dotClr = 11184810;
      }
      if(menuDepth > 0)
      {
         this.__MC._parent["dot" + menuDepth + "Clr"] = new Color(this.__MC._parent["dot" + menuDepth]);
         this.__MC._parent["dot" + menuDepth]._visible = true;
         this.__MC._parent["dot" + menuDepth + "Clr"].setRGB(dotClr);
         this.__MC._parent["txtHead" + menuDepth] = headName;
      }
      var xmlnode = this.partXML.firstChild;
      var menuItemIndex = 0;
      var i = 0;
      while(i < xmlnode.childNodes.length)
      {
         if(xmlnode.childNodes[i].attributes.pi == parentID)
         {
            var tmpMC = partContainer.attachMovie("shopMenuPartItem","PartList" + menuItemIndex,partContainer.getNextHighestDepth());
            tmpMC._y = 3 + menuItemIndex * this.menuItemHeight;
            var installed = Number(xmlnode.childNodes[i].attributes["in"]);
            with(tmpMC)
            {
               partName.text = xmlnode.childNodes[i].attributes.n;
               tmpMC._id = xmlnode.childNodes[i].attributes.i;
               price.text = "$" + xmlnode.childNodes[i].attributes.p;
            }
            if(installed == 1)
            {
               tmpMC.ownState = 1;
               tmpMC.partName.setTextFormat(this.tfInstalled);
            }
            else
            {
               tmpMC.ownState = 2;
               tmpMC.partName.setTextFormat(this.tfSpare);
            }
            tmpMC._installed = Boolean(installed);
            tmpMC.installedCheckMC._visible = Boolean(installed);
            tmpMC.ai = xmlnode.childNodes[i].attributes.ai;
            tmpMC.pcid = xmlnode.childNodes[i].attributes.i;
            tmpMC.partType = xmlnode.childNodes[i].attributes.t;
            tmpMC.idx = menuItemIndex;
            tmpMC.menuDepth = menuDepth;
            tmpMC.objRef = this;
            tmpMC.partNode = xmlnode.childNodes[i];
            tmpMC.onRollOver = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,this.idx,true);
               classes.GaragePartMenu.showPartPanel(this,0);
            };
            tmpMC.onRollOut = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,null,true);
               this._parent._parent.gpmInfo._visible = false;
            };
            tmpMC.onRelease = function()
            {
               this.objRef.clickAction(this.ai,this.partType);
            };
            menuItemIndex++;
         }
         i++;
      }
      partContainer.sp = new controls.ScrollPane(partContainer,undefined,200);
   }
   static function pRow(p, n, label, value, col)
   {
      if(value == undefined || String(value) == "")
      {
         return n;
      }
      var _loc4_ = 5 + n * 13;
      var _loc1_ = p.attachMovie("shopMenuPartItem","r" + n,100 + n);
      _loc1_._x = 7;
      _loc1_._y = _loc4_;
      _loc1_.partName.text = label;
      _loc1_.price.text = "";
      _loc1_.installedCheckMC._visible = false;
      var _loc2_ = p.attachMovie("shopMenuPartItem","v" + n,200 + n);
      _loc2_._x = 66;
      _loc2_._y = _loc4_;
      _loc2_.partName.text = String(value);
      _loc2_.price.text = "";
      _loc2_.installedCheckMC._visible = false;
      var _loc3_ = new TextFormat();
      _loc3_.color = 9081241;
      _loc1_.partName.setTextFormat(_loc3_);
      if(col != undefined)
      {
         _loc3_ = new TextFormat();
         _loc3_.color = col;
         _loc2_.partName.setTextFormat(_loc3_);
      }
      return n + 1;
   }
   static function showPartPanel(rowMC, mode)
   {
      var _loc3_ = rowMC.partNode.attributes;
      var _loc5_ = rowMC._parent._parent;
      var _loc2_ = _loc5_.gpmInfo;
      if(_loc2_ == undefined)
      {
         _loc2_ = _loc5_.createEmptyMovieClip("gpmInfo",_loc5_.getNextHighestDepth());
         _loc2_.createEmptyMovieClip("bg",1);
      }
      _loc2_.swapDepths(_loc5_.getNextHighestDepth());
      var _loc1_ = 0;
      while(_loc1_ < 12)
      {
         _loc2_["r" + _loc1_].removeMovieClip();
         _loc2_["v" + _loc1_].removeMovieClip();
         _loc1_ = _loc1_ + 1;
      }
      var _loc4_ = 0;
      _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Part",_loc3_.n,16777215);
      var _loc6_ = _loc3_.bn;
      if(_loc6_ == undefined || _loc6_ == "")
      {
         _loc6_ = _loc3_.b;
      }
      _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Brand",_loc6_,15132390);
      var _loc7_ = 16761421;
      if(rowMC.ownState == 1)
      {
         _loc7_ = 6750054;
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Status","Installed",6750054);
      }
      else if(rowMC.ownState == 2)
      {
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Status","Owned",16761421);
      }
      else
      {
         _loc7_ = 9081241;
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Status","Not owned",9081241);
      }
      if(Number(_loc3_.p) > 0)
      {
         if(mode == 1)
         {
            _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Price","$" + classes.NumFuncs.commaFormat(_loc3_.p),15132390);
         }
         else
         {
            _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Trade-in","$" + classes.NumFuncs.commaFormat(_loc3_.p),15132390);
         }
      }
      if(Number(_loc3_.hp) != 0)
      {
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Power","+" + _loc3_.hp + " hp",6750054);
      }
      if(Number(_loc3_.tq) != 0)
      {
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Torque","+" + _loc3_.tq + " lb-ft",6750054);
      }
      if(Number(_loc3_.wt) != 0)
      {
         _loc4_ = classes.GaragePartMenu.pRow(_loc2_,_loc4_,"Weight",_loc3_.wt + " lbs",16761421);
      }
      var _loc8_ = 10 + _loc4_ * 13;
      _loc2_.bg.clear();
      _loc2_.bg.lineStyle(1,4276545,100);
      _loc2_.bg.beginFill(1381397,96);
      _loc2_.bg.moveTo(0,0);
      _loc2_.bg.lineTo(166,0);
      _loc2_.bg.lineTo(166,_loc8_);
      _loc2_.bg.lineTo(0,_loc8_);
      _loc2_.bg.lineTo(0,0);
      _loc2_.bg.endFill();
      _loc2_.bg.lineStyle();
      _loc2_.bg.beginFill(_loc7_,100);
      _loc2_.bg.moveTo(0,0);
      _loc2_.bg.lineTo(3,0);
      _loc2_.bg.lineTo(3,_loc8_);
      _loc2_.bg.lineTo(0,_loc8_);
      _loc2_.bg.lineTo(0,0);
      _loc2_.bg.endFill();
      var _loc9_ = rowMC._parent._x + 148;
      if(_loc9_ > 620)
      {
         _loc9_ = 620;
      }
      var _loc10_ = rowMC._y + rowMC._parent.sp.scrollDistance - 4;
      if(_loc10_ + _loc8_ > 212)
      {
         _loc10_ = 212 - _loc8_;
      }
      if(_loc10_ < 0)
      {
         _loc10_ = 0;
      }
      _loc2_._x = _loc9_;
      _loc2_._y = _loc10_;
      _loc2_._visible = true;
   }
   static function isWheelCategory(n)
   {
      return n == "Wheels & Tires" || n == "Wheels" || n == "Tires" || n == "Rims";
   }
   function collapseToDepth(targetDepth)
   {
      this.__MC.gpmInfo._visible = false;
      var _loc2_ = targetDepth;
      while(_loc2_ <= 4)
      {
         this.__MC["partContainer" + _loc2_].sp.destroy();
         this.__MC["partContainer" + _loc2_].removeMovieClip();
         this.__MC._parent["dot" + _loc2_]._visible = false;
         this.__MC._parent["txtHead" + _loc2_] = "";
         this.__MC["hiSel" + _loc2_].ty = - this.__MC["hiSel" + _loc2_]._height - 10;
         this.__MC["hiRO" + _loc2_].ty = - this.__MC["hiRO" + _loc2_]._height - 10;
         this.__MC["hiSel" + _loc2_]._y = this.__MC["hiSel" + _loc2_].ty;
         this.__MC["hiRO" + _loc2_]._y = this.__MC["hiRO" + _loc2_].ty;
         _loc2_ = _loc2_ + 1;
      }
   }
   function setHiMotion(hiType, hiDepth, targetIdx, forPart)
   {
      var _loc2_;
      var _loc4_;
      if(forPart)
      {
         _loc2_ = this.__MC[hiType + "Part"];
         _loc4_ = this.__MC["partContainer" + hiDepth]["PartList" + targetIdx];
         _loc2_._x = this.__MC["partContainer" + hiDepth]._x;
         _loc2_._width = this.__MC["partContainer" + hiDepth]._width;
      }
      else
      {
         _loc2_ = this.__MC[hiType + hiDepth];
         _loc4_ = this.__MC["partContainer" + hiDepth]["cat" + targetIdx];
      }
      if(targetIdx == undefined)
      {
         if(forPart)
         {
            _loc2_.ty = this.__MC.hiSelPart._y;
         }
         else
         {
            _loc2_.ty = this.__MC["hiSel" + hiDepth]._y;
         }
      }
      else
      {
         _loc2_.ty = _loc4_._y + _loc4_._parent.sp.scrollDistance;
      }
      _loc2_.onEnterFrame = function()
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
   function setHiText(hiDepth, targetIdx, ptf)
   {
      trace("setHiText: " + ptf);
      for(var _loc3_ in this.__MC["partContainer" + hiDepth])
      {
         if(this.__MC["partContainer" + hiDepth][_loc3_].na)
         {
            this.__MC["partContainer" + hiDepth][_loc3_].fld.setTextFormat(this.tfNA);
         }
         else
         {
            this.__MC["partContainer" + hiDepth][_loc3_].fld.setTextFormat(this.tfInit);
         }
      }
      this.__MC["partContainer" + hiDepth]["cat" + targetIdx].fld.setTextFormat(ptf);
   }
   function showPanel()
   {
      clearInterval(this.showSI);
      clearInterval(this.checkSI);
      this.showSI = setInterval(this.stepPanel,30,this,this.yShow);
      this.checkSI = setInterval(this.checkPanelHit,100,this);
   }
   function hidePanel()
   {
      clearInterval(this.checkSI);
      clearInterval(this.showSI);
      this.showSI = setInterval(this.stepPanel,30,this,- this.__MC._height);
   }
   function prepPanelRemove()
   {
      trace(this.checkSI);
      trace(this.showSI);
      clearInterval(this.checkSI);
      clearInterval(this.showSI);
   }
   function stepPanel(objRef, targetY)
   {
      if(Math.abs(targetY - objRef.__MC._y) > 0.1)
      {
         objRef.__MC._y += (targetY - objRef.__MC._y) / 3;
      }
      else
      {
         clearInterval(objRef.showSI);
      }
   }
   function checkPanelHit(objRef)
   {
      if(!objRef.__MC.hitTest(_root._xmouse,_root._ymouse,false) && !objRef.__MC._parent.bars.hitTest(_root._xmouse,_root._ymouse,false))
      {
         objRef.hidePanel();
      }
   }
   function clickAction(param, param2)
   {
      this.onPartClickAction(param,param2);
   }
   function init()
   {
      this.__MC._y = this.yShow;
      this.__MC.onEnterFrame = function()
      {
         if(this.hitTest(_root._xmouse,_root._ymouse))
         {
            this.objRef.showPanel();
            delete this.onEnterFrame;
         }
      };
      this.getCategoryAvailability(0,this.partXML);
      this.getCategory(0,0);
   }
}
