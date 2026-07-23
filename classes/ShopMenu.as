class classes.ShopMenu
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
   var objRef;
   var onEnterFrame;
   var onPartClickAction;
   var partCatXML;
   var partXML;
   var pcid;
   var selectedCarXML;
   var showSI;
   var tfInit;
   var tfNA;
   var ty;
   var yShow;
   var infoPanel;
   var infoTitle;
   var infoBody;
   var curReqs;
   var curCons;
   var curBlocked;
   function ShopMenu(mc, pLocationID, pPartCatXML, pPartXML, pSelectedCarXML, pOnPartClickAction, showOnLoadMouse)
   {
      this.__MC = mc;
      this.__MC.objRef = this;
      this.locationID = pLocationID;
      this.partCatXML = pPartCatXML;
      this.partXML = pPartXML;
      this.selectedCarXML = pSelectedCarXML;
      this.onPartClickAction = pOnPartClickAction;
      this.menuItemHeight = 14;
      this.tfInit = new TextFormat();
      this.tfInit.color = 16777215;
      this.tfNA = new TextFormat();
      this.tfNA.color = 6710886;
      this.yShow = this.__MC._y;
      this.__MC._parent.bars.objRef = this;
      this.__MC._parent.bars.onRollOver = function()
      {
         trace("parent bars rollover");
         this.objRef.showPanel();
      };
      this.init(showOnLoadMouse);
   }
   function getCategoryAvailability(parentID, p)
   {
      var _loc7_ = 0;
      var _loc4_ = this.partCatXML.firstChild;
      var _loc3_ = 0;
      var _loc6_;
      var _loc2_;
      while(_loc3_ < _loc4_.childNodes.length)
      {
         if(_loc4_.childNodes[_loc3_].attributes.pi == parentID)
         {
            _loc6_ = 0;
            if(_loc4_.childNodes[_loc3_].attributes.c == 0)
            {
               _loc2_ = 0;
               while(_loc2_ < p.firstChild.childNodes.length)
               {
                  if(p.firstChild.childNodes[_loc2_].attributes.l == this.locationID && p.firstChild.childNodes[_loc2_].attributes.pi == _loc4_.childNodes[_loc3_].attributes.i)
                  {
                     _loc6_ = _loc6_ + 1;
                  }
                  _loc2_ = _loc2_ + 1;
               }
            }
            else
            {
               _loc6_ = this.getCategoryAvailability(_loc4_.childNodes[_loc3_].attributes.i,p);
            }
            _loc7_ += _loc6_;
            _loc4_.childNodes[_loc3_].attributes.p = _loc6_;
         }
         _loc3_ = _loc3_ + 1;
      }
      return _loc7_;
   }
   function getCategory(parentID, menuDepth, dotClr)
   {
      this.collapseToDepth(menuDepth);
      var _loc6_ = this.__MC.createEmptyMovieClip("partContainer" + menuDepth,this.__MC.getNextHighestDepth());
      _loc6_._x = 16 + menuDepth * 140;
      var _loc3_ = this.partCatXML.firstChild;
      var _loc5_ = 0;
      var _loc9_ = "";
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc4_].attributes.i == parentID)
         {
            _loc9_ = _loc3_.childNodes[_loc4_].attributes.n;
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
         this.__MC._parent["txtHead" + menuDepth] = _loc9_;
      }
      _loc4_ = 0;
      var _loc2_;
      while(_loc4_ < _loc3_.childNodes.length)
      {
         if(_loc3_.childNodes[_loc4_].attributes.pi == parentID)
         {
            _loc2_ = _loc6_.attachMovie("shopMenuListItem","cat" + _loc5_,_loc6_.getNextHighestDepth());
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
      var reqCon = this.getPartReqsAndCons(parentID);
      this.curReqs = reqCon.reqs;
      this.curCons = reqCon.cons;
      this.curBlocked = this.hasUnmetRequirements(reqCon);
      var xmlnode = this.partXML.firstChild;
      var menuItemIndex = 0;
      var i = 0;
      while(i < xmlnode.childNodes.length)
      {
         if(xmlnode.childNodes[i].attributes.l == this.locationID && xmlnode.childNodes[i].attributes.pi == parentID)
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
               grade.text = xmlnode.childNodes[i].attributes.g;
            }
            trace("update installed: " + installed);
            tmpMC._installed = Boolean(installed);
            tmpMC.installedCheckMC._visible = Boolean(installed);
            tmpMC.pcid = xmlnode.childNodes[i].attributes.i;
            tmpMC.partNode = xmlnode.childNodes[i];
            if(installed == 1)
            {
               tmpMC.ownState = 1;
            }
            else if(this.getPartOwnership(xmlnode.childNodes[i].attributes.i) == "Bought but not installed")
            {
               tmpMC.ownState = 2;
            }
            else
            {
               tmpMC.ownState = 0;
            }
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
               this.objRef.clickAction(this.pcid);
            };
            menuItemIndex++;
         }
         i++;
      }
   }
   function collapseToDepth(targetDepth)
   {
      this.hidePartInfo(true);
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
         trace("targetIdx undefined");
         trace(this.__MC.hiSelPart);
         trace(this.__MC.hiSelPart._y);
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
         trace("targetIdx defined");
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
      this.__MC["partContainer" + hiDepth]["cat" + targetIdx].fld.embedFonts = true;
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
         this.addRow(_loc3_,"Status","Available",15132390);
      }
      if(Number(_loc6_.p) > 0)
      {
         if(_loc4_)
         {
            this.addRow(_loc3_,"Value","$" + classes.NumFuncs.commaFormat(_loc6_.p),15132390);
         }
         else
         {
            this.addRow(_loc3_,"Price","$" + classes.NumFuncs.commaFormat(_loc6_.p),15132390);
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
      _loc2_.icon._x = 8;
      _loc2_.icon._y = 6;
      var _loc3_ = rowMC._parent._x + 148;
      if(_loc3_ > 580)
      {
         _loc3_ = 580;
      }
      _loc2_._x = _loc3_;
      var _loc7_ = rowMC._y;
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
   function drawBox(mc, x, y, w, h)
   {
      mc.moveTo(x,y);
      mc.lineTo(x + w,y);
      mc.lineTo(x + w,y + h);
      mc.lineTo(x,y + h);
      mc.lineTo(x,y);
   }
   function showPanel()
   {
      clearInterval(this.showSI);
      clearInterval(this.checkSI);
      this.showSI = setInterval(this.stepPanel,30,this,this.yShow);
      this.checkSI = setInterval(this.checkPanelHit,100,this);
      trace("showPanel");
   }
   function hidePanel()
   {
      clearInterval(this.checkSI);
      clearInterval(this.showSI);
      this.showSI = setInterval(this.stepPanel,30,this,- this.__MC._height);
      trace("hidePanel");
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
      trace("stepPanel");
      trace("targetY: " + targetY);
      trace("objRef.__MC._y: " + objRef.__MC._y);
      if(Math.abs(targetY - objRef.__MC._y) > 0.1)
      {
         trace("step!");
         objRef.__MC._y += (targetY - objRef.__MC._y) / 3;
      }
      else
      {
         trace("clearInterval");
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
   function clickAction(param)
   {
      this.onPartClickAction(param);
   }
   function init(showOnLoadMouse)
   {
      this.__MC._y = this.yShow;
      if(showOnLoadMouse)
      {
         this.__MC.onEnterFrame = function()
         {
            if(this.hitTest(_root._xmouse,_root._ymouse))
            {
               trace("init");
               this.objRef.showPanel();
               delete this.onEnterFrame;
            }
         };
      }
      this.getCategoryAvailability(0,this.partXML);
      this.getCategory(0,0);
      this.getPartReqsAndCons(94);
   }
}
