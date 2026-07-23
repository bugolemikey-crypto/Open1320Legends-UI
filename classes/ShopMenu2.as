class classes.ShopMenu2
{
   var __MC;
   var _y;
   var checkSI;
   var clr;
   var hasChild;
   var hitTest;
   var idx;
   var locationID;
   var menuDepth;
   var menuItemHeight;
   var na;
   var objRef;
   var onEnterFrame;
   var onPartClickAction;
   var parentCid;
   var partCatXML;
   var partOwnAndUninstalledXML;
   var partType;
   var partXML;
   var pcid;
   var selectedCarXML;
   var showSI;
   var storeType;
   var tfInit;
   var tfInstalled;
   var tfNA;
   var tfOwn;
   var ty;
   var yShow;
   function ShopMenu2(mc, pLocationID, pPartCatXML, pPartXML, pPartOwnAndUninstalledXML, pSelectedCarXML, pOnPartClickAction, pStoreType)
   {
      this.__MC = mc;
      this.__MC.objRef = this;
      this.locationID = pLocationID;
      this.partCatXML = pPartCatXML;
      this.partXML = pPartXML;
      this.partOwnAndUninstalledXML = pPartOwnAndUninstalledXML;
      this.selectedCarXML = pSelectedCarXML;
      this.onPartClickAction = pOnPartClickAction;
      this.menuItemHeight = 14;
      this.tfInit = new TextFormat();
      this.tfInit.color = 16777215;
      this.tfNA = new TextFormat();
      this.tfNA.color = 6710886;
      this.tfInstalled = new TextFormat();
      this.tfInstalled.color = 61680;
      this.tfOwn = new TextFormat();
      this.tfOwn.color = 14872576;
      this.yShow = this.__MC._y;
      this.__MC._parent.bars.objRef = this;
      this.__MC._parent.bars.onRollOver = function()
      {
         this.objRef.showPanel();
      };
      this.storeType = pStoreType;
      this.init();
   }
   function getCategoryAvailability(parentID, p)
   {
      var _loc7_ = 0;
      var _loc6_ = this.partCatXML.firstChild;
      var _loc5_ = 0;
      var _loc4_;
      var _loc2_;
      while(_loc5_ < _loc6_.childNodes.length)
      {
         if(_loc6_.childNodes[_loc5_].attributes.pi == parentID)
         {
            _loc4_ = 0;
            if(_loc6_.childNodes[_loc5_].attributes.c == 0)
            {
               _loc2_ = 0;
               while(_loc2_ < p.firstChild.childNodes.length)
               {
                  if(p.firstChild.childNodes[_loc2_].attributes.pi == _loc6_.childNodes[_loc5_].attributes.i)
                  {
                     if(p.firstChild.childNodes[_loc2_].attributes.b == "66")
                     {
                        if(Number(p.firstChild.childNodes[_loc2_].attributes.l) <= this.locationID)
                        {
                           _loc4_ = _loc4_ + 1;
                        }
                     }
                     else if(p.firstChild.childNodes[_loc2_].attributes.l == this.locationID)
                     {
                        _loc4_ = _loc4_ + 1;
                     }
                     else if(p.firstChild.childNodes[_loc2_].attributes.pi == 160 || p.firstChild.childNodes[_loc2_].attributes.pi == 161 || p.firstChild.childNodes[_loc2_].attributes.pi == 162 || p.firstChild.childNodes[_loc2_].attributes.pi == 163)
                     {
                        _loc4_ = _loc4_ + 1;
                     }
                  }
                  _loc2_ = _loc2_ + 1;
               }
            }
            else
            {
               _loc4_ = this.getCategoryAvailability(_loc6_.childNodes[_loc5_].attributes.i,p);
            }
            _loc7_ += _loc4_;
            _loc6_.childNodes[_loc5_].attributes.p = _loc4_;
         }
         _loc5_ = _loc5_ + 1;
      }
      return _loc7_;
   }
   function getCategory(parentID, menuDepth, dotClr)
   {
      this.collapseToDepth(menuDepth);
      var _loc7_ = this.__MC.createEmptyMovieClip("partContainer" + menuDepth,this.__MC.getNextHighestDepth());
      _loc7_._x = 16 + menuDepth * 140;
      var _loc3_ = this.partCatXML.firstChild;
      trace("tracing the node");
      trace(_loc3_);
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
      var _loc2_;
      var _loc6_;
      while(_loc4_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc4_].attributes.pi == parentID && _loc3_.childNodes[_loc4_].attributes.s == this.storeType)
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
            _loc2_.pcid = Number(_loc3_.childNodes[_loc4_].attributes.i);
            _loc2_.parentCid = Number(_loc3_.childNodes[_loc4_].attributes.pi);
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
               trace("tempMC.onRelease");
               trace(this.pcid);
               trace(this.parentCid);
               if(this.pcid == 22)
               {
                  trace("custom gear box!");
                  this.objRef.collapseToDepth(this.menuDepth + 1);
                  this.objRef.clickAction(this.pcid,"");
               }
               else if(this.pcid == 159)
               {
                  if(!this.na)
                  {
                     this.objRef.collapseToDepth(this.menuDepth + 1);
                     this.objRef.clickAction(this.pcid,"");
                  }
               }
               else if(this.pcid == 146 || this.pcid == 148 || this.pcid == 149 || this.pcid == 150 || this.pcid == 151)
               {
                  this.objRef.collapseToDepth(this.menuDepth + 1);
                  this.objRef.clickAction(this.pcid,"");
               }
               else if(this.pcid == 172)
               {
                  this.objRef.collapseToDepth(this.menuDepth + 1);
                  this.objRef.clickAction(this.pcid,"");
               }
               else if(this.hasChild == 1)
               {
                  this.objRef.getCategory(this.pcid,this.menuDepth + 1,this.clr.getRGB());
               }
               else
               {
                  trace("other part!");
                  this.objRef.getPart(this.pcid,this.menuDepth + 1,this.clr.getRGB());
               }
               this.objRef.setHiMotion("hiSel",this.menuDepth,this.idx);
               this.objRef.setHiText(this.menuDepth,this.idx,this.objRef.tfNA);
            };
            _loc6_ = Number(_loc3_.childNodes[_loc4_].attributes.i);
            if(_loc3_.childNodes[_loc4_].attributes.p <= 0 && _loc3_.childNodes[_loc4_].attributes.pp <= 0 && _loc6_ != 22 && _loc6_ != 2)
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
      trace("getPart parentID: " + parentID);
      var i = 0;
      while(i < xmlnode.childNodes.length)
      {
         if(xmlnode.childNodes[i].attributes.i == parentID)
         {
            headName = xmlnode.childNodes[i].attributes.n;
            trace("found: " + headName);
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
         if(xmlnode.childNodes[i].attributes.pi == parentID && (xmlnode.childNodes[i].attributes.l == this.locationID || Number(xmlnode.childNodes[i].attributes.l) <= this.locationID && xmlnode.childNodes[i].attributes.b == "66"))
         {
            var tmpMC = partContainer.attachMovie("shopMenuPartItem","PartList" + menuItemIndex,partContainer.getNextHighestDepth());
            tmpMC._y = 3 + menuItemIndex * this.menuItemHeight;
            var installed;
            if(this.getPartOwnership(xmlnode.childNodes[i].attributes.i) == "Bought and Installed")
            {
               installed = 1;
            }
            else
            {
               installed = 0;
            }
            with(tmpMC)
            {
               partName.text = xmlnode.childNodes[i].attributes.n;
               tmpMC._id = xmlnode.childNodes[i].attributes.i;
               price.text = "$" + xmlnode.childNodes[i].attributes.p;
            }
            trace("update installed: " + installed);
            tmpMC._installed = Boolean(installed);
            tmpMC.installedCheckMC._visible = Boolean(installed);
            tmpMC.pcid = xmlnode.childNodes[i].attributes.i;
            tmpMC.partType = xmlnode.childNodes[i].attributes.t;
            tmpMC.idx = menuItemIndex;
            tmpMC.menuDepth = menuDepth;
            tmpMC.objRef = this;
            tmpMC.partNode = xmlnode.childNodes[i];
            tmpMC.onRollOver = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,this.idx,true);
               classes.GaragePartMenu.showPartPanel(this,1);
            };
            tmpMC.onRollOut = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,null,true);
               this._parent._parent.gpmInfo._visible = false;
            };
            tmpMC.onRelease = function()
            {
               this.objRef.clickAction(this.pcid,this.partType);
            };
            var isInstalled = false;
            var j = 0;
            while(j < this.selectedCarXML.firstChild.childNodes.length)
            {
               if(xmlnode.childNodes[i].attributes.i == this.selectedCarXML.firstChild.childNodes[j].attributes.i && xmlnode.childNodes[i].attributes.t == this.selectedCarXML.firstChild.childNodes[j].attributes.pt)
               {
                  isInstalled = true;
                  break;
               }
               j++;
            }
            tmpMC.ownState = 0;
            if(isInstalled)
            {
               tmpMC.ownState = 1;
               tmpMC.partName.text += " (installed)";
               tmpMC.partName.setTextFormat(this.tfInstalled);
            }
            else
            {
               var own = false;
               var j = 0;
               while(j < this.partOwnAndUninstalledXML.firstChild.childNodes.length)
               {
                  if(xmlnode.childNodes[i].attributes.i == this.partOwnAndUninstalledXML.firstChild.childNodes[j].attributes.i && xmlnode.childNodes[i].attributes.t == this.partOwnAndUninstalledXML.firstChild.childNodes[j].attributes.t)
                  {
                     own = true;
                     break;
                  }
                  j++;
               }
               if(own)
               {
                  tmpMC.ownState = 2;
                  tmpMC.partName.text += " (own)";
                  tmpMC.partName.setTextFormat(this.tfOwn);
               }
            }
            menuItemIndex++;
         }
         i++;
      }
   }
   function collapseToDepth(targetDepth)
   {
      this.__MC.gpmInfo._visible = false;
      var _loc2_ = targetDepth;
      while(_loc2_ <= 4)
      {
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
         _loc2_.ty = _loc4_._y;
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
   function getPartOwnership(pid)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.selectedCarXML.firstChild.childNodes.length)
      {
         if(pid == this.selectedCarXML.firstChild.childNodes[_loc2_].attributes.i)
         {
            if(this.selectedCarXML.firstChild.childNodes[_loc2_].attributes["in"] == "1")
            {
               return "Bought and Installed";
            }
            return "Bought but not installed";
         }
         _loc2_ = _loc2_ + 1;
      }
      return "Not yet purchased";
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
      trace("prepPanelRemove");
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
   function clickAction(param1, param2)
   {
      this.onPartClickAction(param1,param2);
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
