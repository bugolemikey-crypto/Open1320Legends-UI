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
   var tfBlocked;
   var ty;
   var yShow;
   var infoPanel;
   var infoTitle;
   var infoBody;
   var curReqs;
   var curCons;
   var curBlocked;
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
      this.tfBlocked = new TextFormat();
      this.tfBlocked.color = 16739179;
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
      var _loc8_;
      var _loc9_;
      var _loc11_;
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
            _loc8_ = this.glyphKeyForCategory(_loc3_.childNodes[_loc4_].attributes.i);
            if(_loc8_ != "part" && _loc2_.dot != undefined)
            {
               _loc11_ = _loc2_.dot.getBounds(_loc2_);
               _loc9_ = _loc2_.createEmptyMovieClip("gpmIcon",900);
               _loc9_._x = (_loc11_.xMin + _loc11_.xMax) / 2 - 4;
               _loc9_._y = (_loc11_.yMin + _loc11_.yMax) / 2 - 4;
               this.drawGlyph(_loc9_,_loc8_,_loc2_.clr.getRGB(),8);
               _loc2_.dot._visible = false;
            }
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
      var reqCon = this.getPartReqsAndCons(parentID);
      this.curReqs = reqCon.reqs;
      this.curCons = reqCon.cons;
      this.curBlocked = this.hasUnmetRequirements(reqCon);
      var glyphKey = this.glyphKeyForCategory(parentID);
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
               tmpMC.partName.setTextFormat(this.tfInstalled);
            }
            else if(this.curBlocked)
            {
               tmpMC.partName.setTextFormat(this.tfBlocked);
            }
            else
            {
               tmpMC.partName.setTextFormat(this.tfSpare);
            }
            tmpMC._installed = Boolean(installed);
            tmpMC.installedCheckMC._visible = Boolean(installed);
            tmpMC.ai = xmlnode.childNodes[i].attributes.ai;
            tmpMC.pcid = xmlnode.childNodes[i].attributes.i;
            tmpMC.partType = xmlnode.childNodes[i].attributes.t;
            tmpMC.partNode = xmlnode.childNodes[i];
            tmpMC.glyphKey = glyphKey;
            tmpMC.dotClr = dotClr;
            tmpMC.idx = menuItemIndex;
            tmpMC.menuDepth = menuDepth;
            tmpMC.objRef = this;
            tmpMC.onRollOver = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,this.idx,true);
               this.objRef.showPartInfo(this,false);
            };
            tmpMC.onRollOut = function()
            {
               this.objRef.setHiMotion("hiRO",this.menuDepth,null,true);
               this.objRef.hidePartInfo();
            };
            tmpMC.onRelease = function()
            {
               this.objRef.showPartInfo(this,true);
               this.objRef.clickAction(this.ai,this.partType);
            };
            menuItemIndex++;
         }
         i++;
      }
      partContainer.sp = new controls.ScrollPane(partContainer,undefined,200);
   }
   function hasUnmetRequirements(reqCon)
   {
      if(this.selectedCarXML == undefined || this.selectedCarXML.firstChild == undefined)
      {
         return false;
      }
      var _loc2_ = 0;
      while(_loc2_ < reqCon.reqs.length)
      {
         if(reqCon.reqs[_loc2_].partOwnership == "Not yet purchased")
         {
            return true;
         }
         _loc2_ = _loc2_ + 1;
      }
      return false;
   }
   function collapseToDepth(targetDepth)
   {
      this.hidePartInfo(true);
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
   function getPartReqsAndCons(pcid)
   {
      var _loc7_ = new Array();
      _loc7_.reqs = new Array();
      _loc7_.cons = new Array();
      var _loc3_ = this.partCatXML.firstChild;
      var _loc11_ = 0;
      var _loc10_;
      var _loc12_;
      var _loc9_;
      var _loc2_;
      var _loc6_;
      var _loc4_;
      var _loc5_;
      var _loc8_;
      while(_loc11_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc11_].attributes.i == pcid)
         {
            _loc10_ = _loc3_.childNodes[_loc11_].firstChild;
            _loc12_ = _loc3_.childNodes[_loc11_].childNodes[1];
            _loc9_ = 0;
            while(_loc9_ < _loc10_.childNodes.length)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc3_.childNodes.length)
               {
                  if(_loc3_.childNodes[_loc2_].attributes.i == _loc10_.childNodes[_loc9_].attributes.i)
                  {
                     _loc6_ = new Object();
                     _loc6_.partCategoryID = _loc3_.childNodes[_loc2_].attributes.i;
                     _loc6_.partCategoryName = _loc3_.childNodes[_loc2_].attributes.n;
                     _loc6_.partOwnership = this.getPartCategoryOwnership(_loc3_.childNodes[_loc2_].attributes.i);
                     _loc7_.reqs.push(_loc6_);
                     _loc4_ = this.getPartReqsAndCons(_loc3_.childNodes[_loc2_].attributes.i);
                     _loc5_ = 0;
                     while(_loc5_ < _loc4_.reqs.length)
                     {
                        _loc7_.reqs.push(_loc4_.reqs[_loc5_]);
                        _loc5_ = _loc5_ + 1;
                     }
                     _loc5_ = 0;
                     while(_loc5_ < _loc4_.cons.length)
                     {
                        _loc7_.cons.push(_loc4_.cons[_loc5_]);
                        _loc5_ = _loc5_ + 1;
                     }
                     break;
                  }
                  _loc2_ = _loc2_ + 1;
               }
               _loc9_ = _loc9_ + 1;
            }
            _loc9_ = 0;
            while(_loc9_ < _loc12_.childNodes.length)
            {
               _loc2_ = 0;
               while(_loc2_ < this.selectedCarXML.firstChild.childNodes.length)
               {
                  if(_loc12_.childNodes[_loc9_].attributes.i == this.selectedCarXML.firstChild.childNodes[_loc2_].attributes.ci)
                  {
                     if(this.selectedCarXML.firstChild.childNodes[_loc2_].attributes["in"] == "1")
                     {
                        _loc8_ = new Object();
                        _loc8_.partID = this.selectedCarXML.firstChild.childNodes[_loc2_].attributes.i;
                        _loc8_.partName = this.selectedCarXML.firstChild.childNodes[_loc2_].attributes.n;
                        _loc7_.cons.push(_loc8_);
                     }
                  }
                  _loc2_ = _loc2_ + 1;
               }
               _loc9_ = _loc9_ + 1;
            }
            return _loc7_;
         }
         _loc11_ = _loc11_ + 1;
      }
      return _loc7_;
   }
   function getPartCategoryOwnership(pcid)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.selectedCarXML.firstChild.childNodes.length)
      {
         if(pcid == this.selectedCarXML.firstChild.childNodes[_loc2_].attributes.ci)
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
   function findCategoryNode(cid)
   {
      var _loc3_ = this.partCatXML.firstChild;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc2_].attributes.i == cid)
         {
            return _loc3_.childNodes[_loc2_];
         }
         _loc2_ = _loc2_ + 1;
      }
      return undefined;
   }
   function categoryChain(cid)
   {
      var _loc5_ = "";
      var _loc2_ = cid;
      var _loc4_ = 0;
      var _loc3_;
      while(_loc4_ < 12)
      {
         _loc3_ = this.findCategoryNode(_loc2_);
         if(_loc3_ == undefined)
         {
            break;
         }
         _loc5_ += String(_loc3_.attributes.n).toLowerCase() + " ";
         _loc2_ = _loc3_.attributes.pi;
         if(Number(_loc2_) <= 0)
         {
            break;
         }
         _loc4_ = _loc4_ + 1;
      }
      return _loc5_;
   }
   function glyphKeyForCategory(cid)
   {
      var _loc2_ = this.categoryChain(cid);
      if(_loc2_.indexOf("nitrous") >= 0)
      {
         return "nitrous";
      }
      if(_loc2_.indexOf("turbo") >= 0 || _loc2_.indexOf("supercharg") >= 0 || _loc2_.indexOf("forced induction") >= 0 || _loc2_.indexOf("intercool") >= 0)
      {
         return "boost";
      }
      if(_loc2_.indexOf("exhaust") >= 0 || _loc2_.indexOf("muffler") >= 0 || _loc2_.indexOf("header") >= 0 || _loc2_.indexOf("catalytic") >= 0)
      {
         return "exhaust";
      }
      if(_loc2_.indexOf("intake") >= 0 || _loc2_.indexOf("air ") >= 0 || _loc2_.indexOf("filter") >= 0 || _loc2_.indexOf("manifold") >= 0)
      {
         return "intake";
      }
      if(_loc2_.indexOf("fuel") >= 0 || _loc2_.indexOf("carbur") >= 0)
      {
         return "fuel";
      }
      if(_loc2_.indexOf("cool") >= 0 || _loc2_.indexOf("oil") >= 0 || _loc2_.indexOf("radiator") >= 0)
      {
         return "cooling";
      }
      if(_loc2_.indexOf("drivetrain") >= 0 || _loc2_.indexOf("gear") >= 0 || _loc2_.indexOf("clutch") >= 0)
      {
         return "drivetrain";
      }
      if(_loc2_.indexOf("electronic") >= 0 || _loc2_.indexOf("ignition") >= 0 || _loc2_.indexOf("ecu") >= 0 || _loc2_.indexOf("spark") >= 0 || _loc2_.indexOf("gauge") >= 0 || _loc2_.indexOf("batter") >= 0)
      {
         return "electronics";
      }
      if(_loc2_.indexOf("suspension") >= 0 || _loc2_.indexOf("spring") >= 0 || _loc2_.indexOf("sway") >= 0 || _loc2_.indexOf("strut") >= 0 || _loc2_.indexOf("brake") >= 0 || _loc2_.indexOf("control arm") >= 0)
      {
         return "suspension";
      }
      if(_loc2_.indexOf("wheel") >= 0 || _loc2_.indexOf("tire") >= 0 || _loc2_.indexOf("rim") >= 0)
      {
         return "wheel";
      }
      if(_loc2_.indexOf("engine") >= 0 || _loc2_.indexOf("internal") >= 0 || _loc2_.indexOf("piston") >= 0 || _loc2_.indexOf("cam") >= 0 || _loc2_.indexOf("block") >= 0 || _loc2_.indexOf("rotary") >= 0 || _loc2_.indexOf("valvetrain") >= 0)
      {
         return "engine";
      }
      if(_loc2_.indexOf("exterior") >= 0 || _loc2_.indexOf("body") >= 0 || _loc2_.indexOf("hood") >= 0 || _loc2_.indexOf("bumper") >= 0 || _loc2_.indexOf("spoiler") >= 0 || _loc2_.indexOf("panel") >= 0)
      {
         return "body";
      }
      return "part";
   }
   function drawArc(mc, cx, cy, r)
   {
      var _loc4_ = r * 0.4142136;
      mc.moveTo(cx + r,cy);
      mc.curveTo(cx + r,cy + _loc4_,cx + r * 0.7071068,cy + r * 0.7071068);
      mc.curveTo(cx + _loc4_,cy + r,cx,cy + r);
      mc.curveTo(cx - _loc4_,cy + r,cx - r * 0.7071068,cy + r * 0.7071068);
      mc.curveTo(cx - r,cy + _loc4_,cx - r,cy);
      mc.curveTo(cx - r,cy - _loc4_,cx - r * 0.7071068,cy - r * 0.7071068);
      mc.curveTo(cx - _loc4_,cy - r,cx,cy - r);
      mc.curveTo(cx + _loc4_,cy - r,cx + r * 0.7071068,cy - r * 0.7071068);
      mc.curveTo(cx + r,cy - _loc4_,cx + r,cy);
   }
   function drawBox(mc, x, y, w, h)
   {
      mc.moveTo(x,y);
      mc.lineTo(x + w,y);
      mc.lineTo(x + w,y + h);
      mc.lineTo(x,y + h);
      mc.lineTo(x,y);
   }
   function drawGlyph(mc, key, color, size)
   {
      mc.clear();
      var _loc9_ = size / 16;
      mc._xscale = mc._yscale = _loc9_ * 100;
      mc.beginFill(color,100);
      var _loc2_;
      var _loc3_;
      switch(key)
      {
         case "engine":
            this.drawBox(mc,1,5,14,9);
            this.drawBox(mc,4,2,3,3);
            this.drawBox(mc,9,2,3,3);
            break;
         case "intake":
            this.drawArc(mc,8,8,7);
            mc.endFill();
            mc.beginFill(color,40);
            this.drawArc(mc,8,8,3.5);
            break;
         case "exhaust":
            this.drawBox(mc,1,6,10,4);
            this.drawArc(mc,12,8,4);
            break;
         case "boost":
            this.drawArc(mc,7,9,6);
            this.drawBox(mc,10,1,5,5);
            break;
         case "nitrous":
            this.drawBox(mc,5,4,6,11);
            this.drawBox(mc,6.5,1,3,3);
            break;
         case "fuel":
            mc.moveTo(8,1);
            mc.lineTo(14,9);
            mc.curveTo(14,15,8,15);
            mc.curveTo(2,15,2,9);
            mc.lineTo(8,1);
            break;
         case "cooling":
            this.drawBox(mc,2,2,12,12);
            mc.endFill();
            mc.beginFill(color,35);
            this.drawBox(mc,4,4,2,8);
            this.drawBox(mc,7,4,2,8);
            this.drawBox(mc,10,4,2,8);
            break;
         case "drivetrain":
            _loc2_ = 0;
            while(_loc2_ < 8)
            {
               _loc3_ = _loc2_ * 45 * Math.PI / 180;
               this.drawBox(mc,8 + Math.cos(_loc3_) * 6 - 1.5,8 + Math.sin(_loc3_) * 6 - 1.5,3,3);
               _loc2_ = _loc2_ + 1;
            }
            this.drawArc(mc,8,8,5);
            mc.endFill();
            mc.beginFill(color,25);
            this.drawArc(mc,8,8,2);
            break;
         case "electronics":
            mc.moveTo(9,1);
            mc.lineTo(3,9);
            mc.lineTo(7,9);
            mc.lineTo(6,15);
            mc.lineTo(13,7);
            mc.lineTo(9,7);
            mc.lineTo(9,1);
            break;
         case "suspension":
            this.drawBox(mc,6,1,4,2);
            this.drawBox(mc,6,13,4,2);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               this.drawBox(mc,3,3.5 + _loc2_ * 2.5,10,1.4);
               _loc2_ = _loc2_ + 1;
            }
            break;
         case "wheel":
            this.drawArc(mc,8,8,7.5);
            mc.endFill();
            mc.beginFill(color,30);
            this.drawArc(mc,8,8,4);
            break;
         case "body":
            mc.moveTo(1,11);
            mc.lineTo(4,6);
            mc.lineTo(11,6);
            mc.lineTo(15,11);
            mc.lineTo(15,13);
            mc.lineTo(1,13);
            mc.lineTo(1,11);
            break;
         default:
            this.drawArc(mc,8,8,4);
      }
      mc.endFill();
   }
   function ensureInfoPanel()
   {
      if(this.infoPanel != undefined)
      {
         return;
      }
      var _loc2_ = this.__MC.createEmptyMovieClip("gpmInfoPanel",30000);
      _loc2_._visible = false;
      _loc2_.createEmptyMovieClip("bg",1);
      _loc2_.createEmptyMovieClip("icon",2);
      _loc2_.createTextField("fldTitle",3,28,5,160,18);
      _loc2_.createTextField("fldBody",4,10,24,178,18);
      var _loc3_ = new TextFormat();
      _loc3_.font = "_sans";
      _loc3_.size = 11;
      _loc3_.bold = true;
      _loc3_.color = 16777215;
      _loc2_.fldTitle.selectable = false;
      _loc2_.fldTitle.multiline = false;
      _loc2_.fldTitle.wordWrap = false;
      _loc2_.fldTitle.autoSize = "left";
      _loc2_.fldTitle.setNewTextFormat(_loc3_);
      var _loc4_ = new TextFormat();
      _loc4_.font = "_sans";
      _loc4_.size = 10;
      _loc4_.bold = false;
      _loc4_.color = 14540253;
      _loc4_.tabStops = [56];
      _loc2_.fldBody.selectable = false;
      _loc2_.fldBody.multiline = true;
      _loc2_.fldBody.wordWrap = true;
      _loc2_.fldBody.autoSize = "left";
      _loc2_.fldBody.setNewTextFormat(_loc4_);
      this.infoPanel = _loc2_;
      this.infoTitle = _loc2_.fldTitle;
      this.infoBody = _loc2_.fldBody;
   }
   function newAcc()
   {
      var _loc1_ = new Object();
      _loc1_.text = "";
      _loc1_.sb = new Array();
      _loc1_.se = new Array();
      _loc1_.sc = new Array();
      _loc1_.sf = new Array();
      return _loc1_;
   }
   function span(acc, b, e, c, bold)
   {
      acc.sb.push(b);
      acc.se.push(e);
      acc.sc.push(c);
      acc.sf.push(bold);
   }
   function addRow(acc, label, value, color)
   {
      if(value == undefined || String(value) == "")
      {
         return undefined;
      }
      var _loc2_ = acc.text.length;
      acc.text += label + "\t" + String(value) + "\n";
      this.span(acc,_loc2_,_loc2_ + label.length,9081241,false);
      this.span(acc,_loc2_ + label.length + 1,acc.text.length - 1,color,false);
   }
   function addHead(acc, label)
   {
      var _loc2_ = acc.text.length;
      acc.text += label + "\n";
      this.span(acc,_loc2_,_loc2_ + label.length,9081241,true);
   }
   function addBullet(acc, label, color)
   {
      var _loc2_ = acc.text.length;
      acc.text += "- " + label + "\n";
      this.span(acc,_loc2_,acc.text.length - 1,color,false);
   }
   function buildInfoBody(node)
   {
      var _loc6_ = node.attributes;
      var _loc4_ = Number(_loc6_["in"]) == 1;
      var _loc3_ = this.newAcc();
      var _loc7_ = _loc6_.bn;
      if(_loc7_ == undefined || _loc7_ == "")
      {
         _loc7_ = _loc6_.b;
      }
      this.addRow(_loc3_,"Brand",_loc7_,15132390);
      if(_loc4_)
      {
         this.addRow(_loc3_,"Status","Installed",6750054);
      }
      else
      {
         this.addRow(_loc3_,"Status","In parts bin",16761421);
      }
      if(Number(_loc6_.p) > 0)
      {
         if(_loc4_)
         {
            this.addRow(_loc3_,"Value","$" + classes.NumFuncs.commaFormat(_loc6_.p),15132390);
         }
         else
         {
            this.addRow(_loc3_,"Trade-in","$" + classes.NumFuncs.commaFormat(_loc6_.p),15132390);
         }
      }
      if(Number(_loc6_.pp) > 0)
      {
         this.addRow(_loc3_,"Points",classes.NumFuncs.commaFormat(_loc6_.pp),15132390);
      }
      if(Number(_loc6_.hp) != 0)
      {
         this.addRow(_loc3_,"Power",this.signed(_loc6_.hp) + " hp",6750054);
      }
      if(Number(_loc6_.tq) != 0)
      {
         this.addRow(_loc3_,"Torque",this.signed(_loc6_.tq) + " lb-ft",6750054);
      }
      if(Number(_loc6_.wt) != 0)
      {
         this.addRow(_loc3_,"Weight",this.signed(_loc6_.wt) + " lbs",16761421);
      }
      var _loc2_;
      var _loc8_;
      var _loc5_;
      if(this.selectedCarXML != undefined && this.selectedCarXML.firstChild != undefined)
      {
         if(this.curReqs.length > 0)
         {
            this.addHead(_loc3_,"Requires");
            _loc2_ = 0;
            while(_loc2_ < this.curReqs.length)
            {
               _loc8_ = this.curReqs[_loc2_].partOwnership;
               if(_loc8_ == "Not yet purchased")
               {
                  _loc5_ = 16739179;
               }
               else if(_loc8_ == "Bought but not installed")
               {
                  _loc5_ = 16761421;
               }
               else
               {
                  _loc5_ = 6750054;
               }
               this.addBullet(_loc3_,this.curReqs[_loc2_].partCategoryName,_loc5_);
               _loc2_ = _loc2_ + 1;
            }
         }
         if(this.curCons.length > 0)
         {
            this.addHead(_loc3_,"Conflicts");
            _loc2_ = 0;
            while(_loc2_ < this.curCons.length)
            {
               this.addBullet(_loc3_,this.curCons[_loc2_].partName,16739179);
               _loc2_ = _loc2_ + 1;
            }
         }
      }
      return _loc3_;
   }
   function applyInfoBody(acc)
   {
      this.infoBody.text = acc.text;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < acc.sb.length)
      {
         _loc3_ = new TextFormat();
         _loc3_.font = "_sans";
         _loc3_.size = 10;
         _loc3_.color = acc.sc[_loc2_];
         _loc3_.bold = acc.sf[_loc2_];
         _loc3_.tabStops = [56];
         this.infoBody.setTextFormat(acc.sb[_loc2_],acc.se[_loc2_],_loc3_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function signed(v)
   {
      var _loc1_ = Number(v);
      if(_loc1_ > 0)
      {
         return "+" + classes.NumFuncs.commaFormat(_loc1_);
      }
      return classes.NumFuncs.commaFormat(_loc1_);
   }
   function accentForRow(rowMC)
   {
      if(rowMC._installed)
      {
         return 6750054;
      }
      if(this.curBlocked)
      {
         return 16739179;
      }
      return 16761421;
   }
   function showPartInfo(rowMC, pinned)
   {
      var _loc6_ = rowMC.partNode;
      if(_loc6_ == undefined)
      {
         return;
      }
      this.ensureInfoPanel();
      var _loc2_ = this.infoPanel;
      _loc2_.pinned = pinned == true;
      var _loc5_ = this.accentForRow(rowMC);
      this.infoTitle.text = String(_loc6_.attributes.n);
      this.infoBody._width = 178;
      this.applyInfoBody(this.buildInfoBody(_loc6_));
      var _loc4_ = this.infoBody._y + this.infoBody._height + 8;
      if(_loc4_ < 60)
      {
         _loc4_ = 60;
      }
      this.drawPanelBG(_loc2_.bg,196,_loc4_,_loc5_);
      this.drawGlyph(_loc2_.icon,rowMC.glyphKey,_loc5_,16);
      _loc2_.icon._x = 8;
      _loc2_.icon._y = 6;
      var _loc3_ = rowMC._parent._x + 148;
      if(_loc3_ > 580)
      {
         _loc3_ = 580;
      }
      _loc2_._x = _loc3_;
      var _loc7_ = rowMC._y + rowMC._parent.sp.scrollDistance;
      if(_loc7_ + _loc4_ > 205)
      {
         _loc7_ = 205 - _loc4_;
      }
      if(_loc7_ < 0)
      {
         _loc7_ = 0;
      }
      _loc2_._y = _loc7_;
      _loc2_._visible = true;
   }
   function hidePartInfo(force)
   {
      if(this.infoPanel == undefined)
      {
         return;
      }
      if(this.infoPanel.pinned && force != true)
      {
         return;
      }
      this.infoPanel.pinned = false;
      this.infoPanel._visible = false;
   }
   function drawPanelBG(mc, w, h, accent)
   {
      mc.clear();
      mc.lineStyle(1,2765112,100);
      mc.beginFill(724498,94);
      this.drawBox(mc,0,0,w,h);
      mc.endFill();
      mc.lineStyle();
      mc.beginFill(accent,100);
      this.drawBox(mc,0,0,3,h);
      mc.endFill();
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
