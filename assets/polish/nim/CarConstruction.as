class classes.CarConstruction
{
   var __MC;
   var backView;
   var bdTireMap;
   var coreYAdj;
   var tireFrac;
   var tireFracR;
   var wheelFrac;
   var wheelFracR;
   var partsArr = new Array("roofEffect","spoiler","eyelids","hoodFrontEffect","hoodCenterEffect","sideEffect","cPillarEffect","fenderEffect","doorEffect","grille","top","body","bodyOpp","trunk","bumper","bumperRear","skirt","hood","wheelF","wheelR");
   var optionalPartsArr = new Array("roofEffect","spoiler","eyelids","hoodFrontEffect","hoodCenterEffect","sideEffect","cPillarEffect","fenderEffect","doorEffect","grille","top","lights","tailLights");
   static var corePartsArr = new Array("wheelMaskAddF","wheelMaskAddR","roofEffect","spoiler","eyelids","hoodFrontEffect","hoodCenterEffect","sideEffect","cPillarEffect","fenderEffect","doorEffect","hood","grille","top","bumper","bumperRear","lights","tailLights","skirt","body","bodyOpp","trunk","underCarriage");
   var wheelPartsArr = new Array("wheelF","wheelR","tireF","tireR","brake","tireBack");
   // Finish per account car ID. A single global override made every car in the
   // client take whatever was last picked in the paint shop; keyed by car, the
   // finish follows the car into the garage, viewer and race instead. Session
   // scoped - the server never sees it, see setColors.
   static var finishMap = new Object();
   function CarConstruction(mc, pBackView)
   {
      this.__MC = mc;
      this.backView = pBackView;
      this.__MC.wheelMaskAddF._visible = false;
      this.__MC.wheelMaskAddR._visible = false;
      this.bdTireMap = new flash.display.BitmapData(640,400,true,4278190080);
   }
   function init()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.partsArr.length)
      {
         if(this.__MC[this.partsArr[_loc2_]].actual)
         {
            this.initPart(this.__MC[this.partsArr[_loc2_]].actual);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function initBase()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.partsArr.length)
      {
         this.initPartBaseY(this.__MC[this.partsArr[_loc2_]]);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < this.wheelPartsArr.length)
      {
         this.initPartBaseX(this.__MC[this.wheelPartsArr[_loc2_]]);
         this.initPartBaseY(this.__MC[this.wheelPartsArr[_loc2_]]);
         _loc2_ = _loc2_ + 1;
      }
      _loc2_ = 0;
      while(_loc2_ < classes.CarConstruction.corePartsArr.length)
      {
         this.initPartBaseY(this.__MC[classes.CarConstruction.corePartsArr[_loc2_]]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function drawTireMap()
   {
      var _loc2_ = new flash.geom.Matrix();
      _loc2_.translate(this.__MC.body._x,this.__MC.body._y);
      this.bdTireMap.fillRect(this.bdTireMap.rectangle,4278190080);
      this.bdTireMap.draw(this.__MC.body,_loc2_,new flash.geom.ColorTransform(),"erase");
      _loc2_.tx = _loc2_.ty = 0;
      _loc2_.translate(this.__MC.bumper._x,this.__MC.bumper._y);
      this.bdTireMap.draw(this.__MC.bumper,_loc2_,new flash.geom.ColorTransform(),"erase");
      _loc2_.tx = _loc2_.ty = 0;
      _loc2_.translate(this.__MC.bumperRear._x,this.__MC.bumperRear._y);
      this.bdTireMap.draw(this.__MC.bumperRear,_loc2_,new flash.geom.ColorTransform(),"erase");
      _loc2_.tx = _loc2_.ty = 0;
      _loc2_.translate(this.__MC.skirt._x,this.__MC.skirt._y);
      this.bdTireMap.draw(this.__MC.skirt,_loc2_,new flash.geom.ColorTransform(),"erase");
      _loc2_.tx = _loc2_.ty = 0;
      _loc2_.translate(this.__MC.wheelMaskAddF._x,this.__MC.wheelMaskAddF._y);
      this.bdTireMap.draw(this.__MC.wheelMaskAddF,_loc2_);
      _loc2_.tx = _loc2_.ty = 0;
      _loc2_.translate(this.__MC.wheelMaskAddR._x,this.__MC.wheelMaskAddR._y);
      this.bdTireMap.draw(this.__MC.wheelMaskAddR,_loc2_);
   }
   function setTireFGroup(isRacing)
   {
      var _loc3_ = 1;
      var _loc4_ = 1;
      if(isRacing)
      {
         _loc3_ = 0.22;
         _loc4_ = 0.47;
      }
      var _loc2_;
      if(isRacing)
      {
         _loc2_ = new flash.geom.Point(8,35);
      }
      else if(this.backView)
      {
         _loc2_ = new flash.geom.Point(23,35);
      }
      else
      {
         _loc2_ = new flash.geom.Point(94,75);
      }
      this.__MC.tireF._xscale *= _loc3_ * this.tireFrac;
      this.__MC.tireF._yscale *= _loc4_ * this.tireFrac;
      this.__MC.tireF._x += _loc2_.x * (1 - this.tireFrac);
      this.__MC.tireF._y += _loc2_.y * (1 - this.tireFrac);
      this.__MC.wheelF._xscale *= _loc3_ * this.wheelFrac;
      this.__MC.wheelF._yscale *= _loc4_ * this.wheelFrac;
      this.__MC.wheelF._x += _loc2_.x * (1 - this.wheelFrac);
      this.__MC.wheelF._y += _loc2_.y * (1 - this.wheelFrac);
      this.__MC.brake._x = this.__MC.wheelF._x - (1 - this.wheelFrac) * 10;
      this.__MC.brake._y = this.__MC.wheelF._y - (1 - this.wheelFrac) * 6;
   }
   function setTireRGroup()
   {
      var _loc2_;
      if(this.backView)
      {
         _loc2_ = new flash.geom.Point(28,74);
      }
      else
      {
         _loc2_ = new flash.geom.Point(41,40);
      }
      this.__MC.tireR._xscale *= this.tireFracR;
      this.__MC.tireR._yscale *= this.tireFracR;
      this.__MC.tireR._x += _loc2_.x * (1 - this.tireFracR);
      this.__MC.tireR._y += _loc2_.y * (1 - this.tireFracR);
      this.__MC.tireBack._yscale = 0.91 * (0.5 + this.tireFracR / 2) * 100;
      this.__MC.wheelR._xscale *= this.wheelFracR;
      this.__MC.wheelR._yscale *= this.wheelFracR;
      this.__MC.wheelR._x += _loc2_.x * (1 - this.wheelFracR);
      this.__MC.wheelR._y += _loc2_.y * (1 - this.wheelFracR);
   }
   function drawTireFGroup()
   {
      this.drawTireMap();
      var _loc3_ = new flash.display.BitmapData(145,149,true,0);
      var _loc4_;
      if(this.backView)
      {
         _loc4_ = new flash.geom.Point(23,35);
      }
      else
      {
         _loc4_ = new flash.geom.Point(94,75);
      }
      var _loc2_ = new flash.geom.Matrix();
      _loc2_.a = this.tireFrac;
      _loc2_.d = this.tireFrac;
      _loc2_.tx = _loc4_.x * (1 - _loc2_.a);
      _loc2_.ty = _loc4_.y * (1 - _loc2_.d);
      _loc3_.draw(this.__MC.tireF,_loc2_);
      _loc2_.a = this.wheelFrac;
      _loc2_.d = this.wheelFrac;
      _loc2_.tx = _loc4_.x * (1 - _loc2_.a);
      _loc2_.ty = _loc4_.y * (1 - _loc2_.d);
      _loc3_.draw(this.__MC.wheelF,_loc2_);
      this.__MC.brake._x = this.__MC.wheelF._x - (1 - this.wheelFrac) * 10;
      this.__MC.brake._y = this.__MC.wheelF._y - (1 - this.wheelFrac) * 6;
      this.__MC.bdTireFront.dispose();
      this.__MC.bdTireFront = new flash.display.BitmapData(145,149,true,0);
      this.__MC.bdTireFront.copyPixels(_loc3_,_loc3_.rectangle,new flash.geom.Point(0,0),this.bdTireMap,new flash.geom.Point(this.__MC.tireF._x,this.__MC.tireF._y));
      for(var _loc5_ in this.__MC.tireF)
      {
         this.__MC.tireF[_loc5_]._visible = false;
      }
      this.__MC.wheelF._visible = false;
      this.__MC.tireF.attachBitmap(this.__MC.bdTireFront,1,false,true);
      _loc3_.dispose();
      false;
   }
   function drawTireRGroup()
   {
      this.drawTireMap();
      var _loc3_ = new flash.display.BitmapData(145,149,true,0);
      var _loc4_;
      if(this.backView)
      {
         _loc4_ = new flash.geom.Point(28,74);
      }
      else
      {
         _loc4_ = new flash.geom.Point(41,40);
      }
      var _loc2_ = new flash.geom.Matrix();
      _loc2_.a = this.tireFracR;
      _loc2_.d = this.tireFracR;
      _loc2_.tx = _loc4_.x * (1 - _loc2_.a);
      _loc2_.ty = _loc4_.y * (1 - _loc2_.d);
      _loc3_.draw(this.__MC.tireR,_loc2_);
      _loc2_.a = this.wheelFracR;
      _loc2_.d = this.wheelFracR;
      _loc2_.tx = _loc4_.x * (1 - _loc2_.a);
      _loc2_.ty = _loc4_.y * (1 - _loc2_.d);
      _loc3_.draw(this.__MC.wheelR,_loc2_);
      this.__MC.bdTireRear.dispose();
      this.__MC.bdTireRear = new flash.display.BitmapData(145,149,true,0);
      this.__MC.bdTireRear.copyPixels(_loc3_,_loc3_.rectangle,new flash.geom.Point(0,0),this.bdTireMap,new flash.geom.Point(this.__MC.tireR._x,this.__MC.tireR._y));
      _loc3_.dispose();
      for(var _loc5_ in this.__MC.tireR)
      {
         this.__MC.tireR[_loc5_]._visible = false;
      }
      this.__MC.wheelR._visible = false;
      this.__MC.tireR.attachBitmap(this.__MC.bdTireRear,1,false,true);
      _loc3_.dispose();
      false;
      this.__MC.tireBack._yscale = 0.91 * (0.5 + this.tireFracR / 2) * 100;
   }
   function initPart(target)
   {
      with(target)
      {
         shad.removeMovieClip();
         hi.removeMovieClip();
         paint.duplicateMovieClip("shad",target.getNextHighestDepth());
         paint.duplicateMovieClip("hi",target.getNextHighestDepth());
         noPaint.swapDepths(target.getNextHighestDepth());
         target.clr = new Color(paint);
         clr.setRGB(255);
         target.mtxShad = new Array();
         mtxShad = mtxShad.concat([1,0,0,0,0]);
         mtxShad = mtxShad.concat([1,0,0,0,0]);
         mtxShad = mtxShad.concat([1,0,0,0,0]);
         mtxShad = mtxShad.concat([0,0,0,1,0]);
         target.fltrShad = new flash.filters.ColorMatrixFilter(mtxShad);
         target.mtxShad2 = new Array();
         mtxShad2 = mtxShad2.concat([1.4409448818897639,0,0,0,-28]);
         mtxShad2 = mtxShad2.concat([0,1.4409448818897639,0,0,-28]);
         mtxShad2 = mtxShad2.concat([0,0,1.4409448818897639,0,-28]);
         mtxShad2 = mtxShad2.concat([0,0,0,1,0]);
         target.fltrShad2 = new flash.filters.ColorMatrixFilter(mtxShad2);
         shad.filters = new Array(fltrShad,fltrShad2);
         shad.blendMode = "multiply";
         target.mtxHi = new Array();
         mtxHi = mtxHi.concat([0,0,1,0,0]);
         mtxHi = mtxHi.concat([0,0,1,0,0]);
         mtxHi = mtxHi.concat([0,0,1,0,0]);
         mtxHi = mtxHi.concat([0,0,0,1,0]);
         target.fltrHi = new flash.filters.ColorMatrixFilter(mtxHi);
         hi.filters = new Array(fltrHi);
         hi.blendMode = "screen";
      }
   }
   function initPartBaseX(target)
   {
      target.baseX = target._x;
   }
   function initPartBaseY(target)
   {
      target.baseY = target._y;
   }
   function setPartColor(target, newClr)
   {
      target = target.actual;
      target.hi._alpha = 100;
      var _loc2_ = target.shad.filters;
      target.shad.filters = [_loc2_[0]];
      target.clr.setRGB(newClr & 16777215);
      false;
   }
   function setPartPrimer(target)
   {
      target.clr.setRGB(8421504);
      target.hi._alpha = 50;
      var _loc4_ = [1,0,0,0,80,0,1,0,0,80,0,0,1,0,80,0,0,0,1,0];
      var _loc1_ = target.shad.filters;
      var _loc2_ = new flash.filters.ColorMatrixFilter(_loc4_);
      _loc1_.push(_loc2_);
      target.shad.filters = _loc1_;
      false;
      false;
      false;
   }
   // Sparkle, clipped to the panel in PIXELS rather than with setMask.
   //
   // setMask cannot work here at all: what the player sees is not these clips but
   // the flattened bitmap Drawing.snapshotCar builds with BitmapData.draw(), and
   // draw() does not honour a setMask clip. The mask applied on screen and was
   // then discarded by the snapshot, so sparkle covered the background no matter
   // how the blend modes and wrappers were arranged. Baking the panel's alpha
   // into the pixels puts the clipping somewhere draw() has no say over.
   function setPartFlake(target, useFlake)
   {
      target.flakeHolder.removeMovieClip();
      target.flakeMask.removeMovieClip();
      if(!useFlake)
      {
         return undefined;
      }
      var _loc2_ = target.hi.getBounds(target);
      var _loc9_ = Math.ceil(_loc2_.xMax - _loc2_.xMin);
      var _loc8_ = Math.ceil(_loc2_.yMax - _loc2_.yMin);
      if(_loc9_ < 2 || _loc8_ < 2 || _loc9_ > 1400 || _loc8_ > 1400)
      {
         return undefined;
      }
      // Drawn from hi, not paint. initPart duplicates shad and hi BEFORE applying
      // Color(paint), so paint is a flat tint carrying no shading while hi keeps
      // the art's detail - and hi has the same panel shape either way.
      var _loc5_ = new flash.display.BitmapData(_loc9_,_loc8_,true,0);
      var _loc7_ = new flash.geom.Matrix();
      _loc7_.scale(target.hi._xscale / 100,target.hi._yscale / 100);
      _loc7_.translate(target.hi._x - _loc2_.xMin,target.hi._y - _loc2_.yMin);
      _loc5_.draw(target.hi,_loc7_);
      // Move the blue channel into alpha, the same luminance proxy fltrHi uses.
      // Alpha then carries brightness AND coverage at once, so the sparkle
      // concentrates where light falls and still clips to the panel: outside it
      // both blue and alpha are already 0. Uniform density read as spatter.
      _loc5_.copyChannel(_loc5_,_loc5_.rectangle,new flash.geom.Point(0,0),4,8);
      // Sparse opaque specks at panel size. Seeding off the size keeps adjacent
      // panels from showing the same pattern.
      var _loc6_ = new flash.display.BitmapData(_loc9_,_loc8_,false,0);
      _loc6_.noise(9871 + _loc9_ + _loc8_,0,255,7,true);
      var _loc4_ = new flash.display.BitmapData(_loc9_,_loc8_,true,0);
      _loc4_.threshold(_loc6_,_loc6_.rectangle,new flash.geom.Point(0,0),">",4294506744,4294967295,4294967295,false);
      // alphaBitmapData multiplies the specks by the panel's alpha, so anything
      // outside the panel ends up fully transparent.
      var _loc3_ = new flash.display.BitmapData(_loc9_,_loc8_,true,0);
      _loc3_.copyPixels(_loc4_,_loc4_.rectangle,new flash.geom.Point(0,0),_loc5_,new flash.geom.Point(0,0),false);
      _loc6_.dispose();
      _loc4_.dispose();
      _loc5_.dispose();
      var _loc10_ = target.createEmptyMovieClip("flakeHolder",target.getNextHighestDepth());
      _loc10_._x = _loc2_.xMin;
      _loc10_._y = _loc2_.yMin;
      _loc10_.blendMode = "screen";
      // Raised from 38 to offset the luminance modulation, which dims the sparkle
      // everywhere the panel is not brightly lit.
      _loc10_._alpha = 60;
      _loc10_.attachBitmap(_loc3_,1,"auto",true);
      // Keep trim, badges and light housings above the sparkle.
      target.noPaint.swapDepths(target.getNextHighestDepth());
   }
   function liftFilter(v)
   {
      return new flash.filters.ColorMatrixFilter([1,0,0,0,v,0,1,0,0,v,0,0,1,0,v,0,0,0,1,0]);
   }
   function candyFilter(c)
   {
      var _loc5_ = (c >> 16 & 255) / 255;
      var _loc4_ = (c >> 8 & 255) / 255;
      var _loc3_ = (c & 255) / 255;
      var _loc2_ = _loc5_;
      if(_loc4_ > _loc2_)
      {
         _loc2_ = _loc4_;
      }
      if(_loc3_ > _loc2_)
      {
         _loc2_ = _loc3_;
      }
      if(_loc2_ <= 0)
      {
         _loc5_ = 1;
         _loc4_ = 1;
         _loc3_ = 1;
      }
      else
      {
         _loc5_ = 0.38 + 0.62 * (_loc5_ / _loc2_);
         _loc4_ = 0.38 + 0.62 * (_loc4_ / _loc2_);
         _loc3_ = 0.38 + 0.62 * (_loc3_ / _loc2_);
      }
      // Contrast is folded into the same matrix. fltrHi has already flattened
      // every channel to luminance L, so each row reads only its own channel:
      // out = tint * (2.3L - 150). Everything below L~65 clamps to black, which
      // turns the broad gloss highlight into a tight bloom - that tightness is
      // what reads as candy. Tint alone was not enough: normalising to the
      // brightest channel makes the effect depend on how many channels are low,
      // so it was strong on red (1, .38, .38) and invisible on yellow (1, 1, .38).
      return new flash.filters.ColorMatrixFilter([2.3 * _loc5_,0,0,0,-150 * _loc5_,0,2.3 * _loc4_,0,0,-150 * _loc4_,0,0,2.3 * _loc3_,0,-150 * _loc3_,0,0,0,1,0]);
   }
   function setPartFinish(target, fin)
   {
      target = target.actual;
      if(!target.hi)
      {
         return undefined;
      }
      target.hi.blendMode = "screen";
      target.hi.filters = [target.fltrHi];
      this.setPartFlake(target,fin == 4);
      // Flake keeps the gloss base and gets its character from the sparkle layer,
      // so it wants none of the shad/hi tuning the other three finishes apply.
      if(!fin || fin == 4)
      {
         return undefined;
      }
      var _loc2_ = target.shad.filters;
      if(fin == 1)
      {
         // No specular at all. 24% still left a visible sheen on large panels.
         target.hi._alpha = 0;
         _loc2_.push(this.liftFilter(22));
      }
      else if(fin == 2)
      {
         target.hi._alpha = 58;
         _loc2_.push(this.liftFilter(7));
      }
      else if(fin == 3)
      {
         target.hi._alpha = 100;
         target.hi.filters = [target.fltrHi,this.candyFilter(target.clr.getRGB())];
         _loc2_.push(this.liftFilter(-14));
      }
      target.shad.filters = _loc2_;
   }
   function setFinishes(fin, carID)
   {
      // The high byte of cc wins if the server ever carries one; otherwise fall
      // back to the local per-car map. setPartColor masks with 0xFFFFFF, so an
      // 8-character cc can never corrupt the hue either way.
      var _loc3_ = fin;
      if(!_loc3_)
      {
         _loc3_ = Number(classes.CarConstruction.finishMap[carID]);
      }
      if(!_loc3_)
      {
         _loc3_ = 0;
      }
      var _loc2_ = 0;
      while(_loc2_ < this.partsArr.length)
      {
         this.setPartFinish(this.__MC[this.partsArr[_loc2_]],_loc3_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function setGlobalColor(newClr)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.partsArr.length)
      {
         this.setPartColor(this.__MC[this.partsArr[_loc2_]],newClr);
         _loc2_ = _loc2_ + 1;
      }
   }
   function setCar(cs, racing, scale)
   {
      this.tireFrac = cs.tireScale / 100;
      this.tireFracR = this.tireFrac;
      this.wheelFrac = cs.wheelScale / 100;
      this.wheelFracR = this.wheelFrac;
      var _loc2_ = 0;
      while(_loc2_ < this.optionalPartsArr.length)
      {
         this.__MC[this.optionalPartsArr[_loc2_]]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
      var _loc4_;
      for(var _loc5_ in cs)
      {
         if(typeof cs[_loc5_] == "number")
         {
            if(_loc5_.substr(_loc5_.length - 2,2) == "ID" && _loc5_.substr(0,5) != "wheel")
            {
               _loc4_ = _loc5_.substring(0,_loc5_.length - 2);
               this.__MC[_loc4_]._visible = true;
               this.__MC[_loc4_].actual.gotoAndStop(cs[_loc5_]);
            }
         }
      }
      this.initBase();
      this.init();
      this.setColors(cs);
      this.coreYAdj = Math.ceil(cs.rideHeight - (1 - this.tireFrac) * 75);
      for(_loc5_ in classes.CarConstruction.corePartsArr)
      {
         this.__MC[classes.CarConstruction.corePartsArr[_loc5_]]._y = this.__MC[classes.CarConstruction.corePartsArr[_loc5_]].baseY - this.coreYAdj;
      }
      for(_loc5_ in this.wheelPartsArr)
      {
         this.__MC[this.wheelPartsArr[_loc5_]]._y = this.__MC[this.wheelPartsArr[_loc5_]].baseY + Math.ceil((1 - this.tireFrac) * 75);
      }
      if(this.backView)
      {
         this.__MC.tireF._y = this.__MC.tireF.baseY + Math.ceil((1 - this.tireFrac) * 65 - cs.rideHeight / 2);
         this.__MC.wheelF._y = this.__MC.tireF._y;
      }
      else
      {
         this.__MC.tireF._x = this.__MC.tireF.baseX + Math.ceil((1 - this.tireFrac) * 94) / 4;
         this.__MC.wheelF._x = this.__MC.wheelF.baseX + Math.ceil((1 - this.tireFrac) * 94) / 4;
         this.__MC.tireR._y = this.__MC.tireR.baseY + Math.floor((1 - this.tireFracR) * 65 - cs.rideHeight / 2);
         this.__MC.wheelR._y = this.__MC.tireR._y;
      }
      if(racing)
      {
         this.setTireFGroup(true);
         this.setTireRGroup();
      }
      else if(scale >= 15)
      {
         this.setTireFGroup();
         this.setTireRGroup();
      }
      else
      {
         this.drawTireFGroup();
         this.drawTireRGroup();
         this.__MC.wheelF._visible = false;
         this.__MC.wheelR._visible = false;
      }
   }
   function setColors(cs)
   {
      this.setGlobalColor(cs.globalClr);
      for(var _loc3_ in cs)
      {
         if(typeof cs[_loc3_] == "number")
         {
            if(_loc3_.substr(_loc3_.length - 3,3) == "Clr" && _loc3_ != "globalClr")
            {
               this.setPartColor(this.__MC[_loc3_.substring(0,_loc3_.length - 3)],cs[_loc3_]);
            }
         }
      }
      this.setFinishes(cs.globalClr >>> 24,cs.acctCarID);
   }
   function garbageCollect()
   {
      this.bdTireMap.dispose();
      this.__MC.bdTireFront.dispose();
      this.__MC.bdTireRear.dispose();
   }
}
