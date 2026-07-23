class classes.Drawing
{
   var _xscale;
   var action;
   var context;
   var decal;
   var decalLoadin;
   var onEnterFrame;
   var teamID;
   var userID;
   static var bmpObj = new Object();
   static var aryCarDrawings = new Array();
   static var loadPartsArr = new Array("wheelMaskAddR","wheelMaskAddF","shadow","underCarriage","trunk","bodyOpp","body","bumperRear","skirt","bumper","grille","hood","lights","doorEffect","fenderEffect","cPillarEffect","sideEffect","hoodCenterEffect","hoodFrontEffect","eyelids","spoiler","top","roofEffect","tireF","tireR");
   static var loadPartsBackArr = new Array("wheelMaskAddF","wheelMaskAddR","shadow","underCarriage","tireBack","body","bodyOpp","top","trunk","roofEffect","spoiler","sideEffect","cPillarEffect","fenderEffect","doorEffect","bumperRear","tailLights","skirt","tireF","tireR");
   static var optionalPartsArr = new Array("grille","lights","doorEffect","fenderEffect","cPillarEffect","sideEffect","hoodCenterEffect","hoodFrontEffect","eyelids","spoiler","roofEffect","top");
   static var optionalPartsBackArr = new Array("roofEffect","spoiler","sideEffect","cPillarEffect","fenderEffect","doorEffect","tailLights","top");
   static var drawCarQueue = new Array();
   function Drawing(context)
   {
   }
   static function newBaseWindow(_context, ww, hh)
   {
      with(_context)
      {
         colors = [2237994,986895,329223];
         alphas = [100,100,100];
         ratios = [0,207,255];
         matrix = {matrixType:"box",x:0,y:0,w:ww - 5,h:hh - 30,r:1.2217304763960306};
         beginGradientFill("linear",colors,alphas,ratios,matrix);
         moveTo(0,0);
         lineTo(ww,0);
         lineTo(ww,hh);
         lineTo(0,hh);
         lineTo(0,0);
         endFill();
         beginFill(0,100);
         moveTo(0,0);
         lineTo(Math.round(ww * 0.19),0);
         lineTo(ww,Math.round(hh * 0.85));
         lineTo(ww,hh);
         lineTo(0,hh);
         lineTo(0,0);
         endFill();
      }
   }
   static function newConsoleWindow(_context, ww, hh)
   {
      var _loc1_ = new flash.geom.Point(0,0);
      var _loc6_ = new flash.geom.Point(ww,0);
      var _loc5_ = new flash.geom.Point(ww,hh);
      var _loc4_ = new flash.geom.Point(0,hh);
      classes.Drawing.rect(_context,ww,hh,0,100,_loc1_.x,_loc1_.y,8);
   }
   static function rotateConsoleWindow(_context, ww, hh, p1, p2, p3, p4, degrees)
   {
      with(_context)
      {
         clear();
         var fullW = 30;
         var edgeW;
         var vBtm;
         var vAdj = 3;
         if(Math.abs(degrees) > 0)
         {
            edgeW = fullW * Math.sin(degrees * 3.141592653589793 / 180);
            vBtm = p3.y;
            edge.lineTo(edgeW,vPersp);
            edge.lineTo(edgeW,vBtm - vPersp);
            vPersp = fullW / 2 * Math.cos(ptheta);
            var p5 = new flash.geom.Point();
            var p6 = new flash.geom.Point();
            if(degrees > 0)
            {
               p5.x = p2.x + edgeW;
               p5.y = p2.y + vPersp;
               p6.x = p5.x;
               p6.y = p3.y - vPersp;
               moveTo(p2.x,p2.y + vAdj);
               beginFill(0);
               lineTo(p5.x,p5.y + vAdj);
               lineTo(p6.x,p6.y - vAdj);
               lineTo(p3.x,p3.y - vAdj);
               lineTo(p2.x,p2.y + vAdj);
               endFill();
            }
            else
            {
               p5.x = p1.x + edgeW;
               p5.y = p1.y + vPersp;
               p6.x = p5.x;
               p6.y = p4.y - vPersp;
               moveTo(p1.x,p1.y + vAdj);
               beginFill(0);
               lineTo(p5.x,p5.y + vAdj);
               lineTo(p6.x,p6.y - vAdj);
               lineTo(p4.x,p4.y - vAdj);
               lineTo(p1.x,p1.y + vAdj);
               endFill();
            }
         }
      }
   }
   static function addCornerResizer(_context, handleName)
   {
      _context.createEmptyMovieClip("corner",_context.getNextHighestDepth());
      with(_context.corner)
      {
         beginFill(0,0);
         lineTo(20,0);
         lineTo(20,20);
         lineTo(0,20);
         endFill();
      }
      with(_context)
      {
         corner._x = _context._width - corner._width;
         corner._y = _context._y + _context._height - corner._height;
         _context.attachMovie("cornerHandle",handleName,_context.getNextHighestDepth());
         _context[handleName]._x = corner._x;
         _context[handleName]._y = corner._y;
      }
   }
   static function topLines(_lines, _linesMask, ww)
   {
      with(_lines)
      {
         clear();
         colors = [0,0,0,0];
         alphas = [20,50,50,20];
         ratios = [0,15,240,255];
         matrix = {matrixType:"box",x:0,y:0,w:ww,h:1,r:0};
         beginGradientFill("linear",colors,alphas,ratios,matrix);
         moveTo(0,0);
         lineTo(ww,0);
         lineTo(ww,1);
         lineTo(0,1);
         lineTo(0,0);
         endFill();
         colors = [16726051,16726051,16726051,16726051];
         beginGradientFill("linear",colors,alphas,ratios,matrix);
         moveTo(0,1);
         lineTo(ww,1);
         lineTo(ww,2);
         lineTo(0,2);
         lineTo(0,1);
         endFill();
      }
      with(_linesMask)
      {
         clear();
         beginFill(16777215,100);
         lineTo(19,0);
         lineTo(19,10);
         lineTo(0,10);
         lineTo(0,0);
         endFill();
         beginFill(16777215,100);
         moveTo(82,0);
         lineTo(90,0);
         lineTo(90,10);
         lineTo(82,10);
         lineTo(82,0);
         endFill();
         beginFill(16777215,100);
         moveTo(153,0);
         lineTo(_lines._width,0);
         lineTo(_lines._width,10);
         lineTo(153,10);
         lineTo(153,0);
         endFill();
      }
   }
   static function midLines(_lines, ww)
   {
      with(_lines)
      {
         clear();
         colors = [0,0,0,0];
         alphas = [20,50,50,20];
         ratios = [0,15,240,255];
         matrix = {matrixType:"box",x:0,y:0,w:ww,h:1,r:0};
         beginGradientFill("linear",colors,alphas,ratios,matrix);
         moveTo(0,0);
         lineTo(ww,0);
         lineTo(ww,1);
         lineTo(0,1);
         lineTo(0,0);
         endFill();
         colors = [16726051,16726051,16726051,16726051];
         beginGradientFill("linear",colors,alphas,ratios,matrix);
         moveTo(0,1);
         lineTo(ww,1);
         lineTo(ww,2);
         lineTo(0,2);
         lineTo(0,1);
         endFill();
      }
   }
   static function portrait(_context, accountID, shadStrength, offLeft, offTop, lineWeight, fadeIn, avatarType, noCache)
   {
      trace("portrait");
      if(!avatarType)
      {
         avatarType = "avatars";
      }
      if(_context.photo == undefined)
      {
         if(!lineWeight)
         {
            lineWeight = 1;
         }
         if(!offLeft)
         {
            offLeft = 0;
         }
         if(!offTop)
         {
            offTop = 0;
         }
         _context.createEmptyMovieClip("photo",_context.getNextHighestDepth());
         _context.photo.id = accountID;
         with(_context)
         {
            with(photo)
            {
               var cRad = 6;
               var photoW = 98;
               var photoH = 80;
               var photoL = offLeft;
               var photoT = offTop;
               clear();
               moveTo(photoL + cRad,photoT);
               beginFill(5330779);
               lineTo(photoL + photoW - cRad,photoT);
               curveTo(photoL + photoW,photoT,photoL + photoW,photoT + cRad);
               lineTo(photoL + photoW,photoT + photoH - cRad);
               curveTo(photoL + photoW,photoT + photoH,photoL + photoW - cRad,photoT + photoH);
               lineTo(photoL + cRad,photoT + photoH);
               curveTo(photoL,photoT + photoH,photoL,photoT + photoH - cRad);
               lineTo(photoL,photoT + cRad);
               curveTo(photoL,photoT,photoL + cRad,photoT);
               endFill();
            }
            if(photo.pic == undefined)
            {
               photo.createEmptyMovieClip("pic",photo.getNextHighestDepth());
               photo.pic.createEmptyMovieClip("loadin",photo.pic.getNextHighestDepth());
               if(fadeIn)
               {
                  photo.pic.loadin._alpha = 0;
               }
               photo.createEmptyMovieClip("picMask",photo.getNextHighestDepth());
               photo.pic._x = offLeft + lineWeight;
               photo.pic._y = offTop + lineWeight;
            }
            with(photo.picMask)
            {
               var cRad = 6 - (lineWeight - 1);
               var photoW = 98 - 2 * lineWeight;
               var photoH = 80 - 2 * lineWeight;
               var photoL = offLeft + lineWeight;
               var photoT = offTop + lineWeight;
               clear();
               moveTo(photoL + cRad,photoT);
               beginFill(0);
               lineTo(photoL + photoW - cRad,photoT);
               curveTo(photoL + photoW,photoT,photoL + photoW,photoT + cRad);
               lineTo(photoL + photoW,photoT + photoH - cRad);
               curveTo(photoL + photoW,photoT + photoH,photoL + photoW - cRad,photoT + photoH);
               lineTo(photoL + cRad,photoT + photoH);
               curveTo(photoL,photoT + photoH,photoL,photoT + photoH - cRad);
               lineTo(photoL,photoT + cRad);
               curveTo(photoL,photoT,photoL + cRad,photoT);
               endFill();
            }
            photo.pic.setMask(photo.picMask);
         }
         if(avatarType == "teamavatars")
         {
            _context.photo.pic.loadin.attachMovie("portraitTeamAvatar","portrait_offline",1);
         }
         else
         {
            trace("creating portrait_offline!");
            _context.photo.pic.loadin.attachMovie("portrait_offline","portrait_offline",1);
         }
      }
      if(accountID)
      {
         var photoImage = new classes.ImageIO();
         photoImage.avatarType = avatarType;
         photoImage.loadAvatar(_context.photo.pic.loadin,accountID,noCache);
      }
      if(shadStrength)
      {
         var shadFilter = new flash.filters.DropShadowFilter(3 + 2 * shadStrength,45,0,0.45 + 0.05 * shadStrength,9 * shadStrength,9 * shadStrength,1,2);
         var tFilters = [];
         tFilters.push(shadFilter);
         _context.photo.filters = tFilters;
      }
   }
   static function userListItem(_context, newName, pid, puname, px, py, action)
   {
      if(!newName)
      {
         newName = "userListItem";
      }
      if(!px)
      {
         px = 0;
      }
      if(!py)
      {
         py = 0;
      }
      if(!pid || !puname)
      {
         return undefined;
      }
      _context.attachMovie("userListItem",newName,_context.getNextHighestDepth(),{_x:px,_y:py,userID:pid,userName:puname});
      classes.Drawing.portrait(_context[newName],pid,2,0,0,4);
      _context[newName].photo._xscale = 25;
      _context[newName].photo._yscale = 25;
      _context[newName].photo._x = 100;
      if(action)
      {
         _context[newName].context = _context;
         _context[newName].action = action;
         _context[newName].onRelease = function()
         {
            this.action.call(this.context,this.userID);
         };
      }
   }
   static function teamListItem(_context, newName, pid, ptname, px, py, action)
   {
      if(!newName)
      {
         newName = "teamListItem";
      }
      if(!px)
      {
         px = 0;
      }
      if(!py)
      {
         py = 0;
      }
      if(!pid || !ptname)
      {
         return undefined;
      }
      _context.attachMovie("teamListItem",newName,_context.getNextHighestDepth(),{_x:px,_y:py,teamID:pid,teamName:ptname});
      classes.Drawing.portrait(_context[newName],pid,2,0,0,4,false,"teamavatars");
      _context[newName].photo._xscale = 25;
      _context[newName].photo._yscale = 25;
      if(action)
      {
         _context[newName].context = _context;
         _context[newName].action = action;
         _context[newName].onRelease = function()
         {
            this.action.call(this.context,this.teamID);
         };
      }
   }
   static function clearCarBmps()
   {
      var _loc1_ = 0;
      var _loc2_;
      while(_loc1_ < classes.Drawing.aryCarDrawings.length)
      {
         if(classes.Drawing.aryCarDrawings[_loc1_][0].toString() == undefined)
         {
            _loc2_ = 1;
            while(_loc2_ < classes.Drawing.aryCarDrawings[_loc1_].length)
            {
               classes.Drawing.aryCarDrawings[_loc1_][_loc2_].dispose();
               _loc2_ = _loc2_ + 1;
            }
            classes.Drawing.aryCarDrawings.splice(_loc1_,1);
            _loc1_ = _loc1_ - 1;
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function clearThisCarsBmps(targetClip)
   {
      var _loc3_ = targetClip._target;
      var _loc1_ = 0;
      var _loc2_;
      while(_loc1_ < classes.Drawing.aryCarDrawings.length)
      {
         if(classes.Drawing.aryCarDrawings[_loc1_][0]._target == _loc3_)
         {
            _loc2_ = 1;
            while(_loc2_ < classes.Drawing.aryCarDrawings[_loc1_].length)
            {
               classes.Drawing.aryCarDrawings[_loc1_][_loc2_].dispose();
               _loc2_ = _loc2_ + 1;
            }
            classes.Drawing.aryCarDrawings.splice(_loc1_,1);
            _loc1_ = _loc1_ - 1;
         }
         _loc1_ = _loc1_ + 1;
      }
   }
   static function drawDecalsOnCar(targetClip, decalArr, coreYAdj, isBack)
   {
      if(!decalArr.length || !targetClip)
      {
         return undefined;
      }
      targetClip.decalLoader._y -= coreYAdj;
      var _loc6_ = 0;
      var _loc21_;
      var _loc2_;
      var _loc20_;
      var _loc14_;
      var _loc13_;
      var _loc10_;
      var _loc19_;
      var _loc7_;
      var _loc11_;
      var _loc5_;
      var _loc17_;
      var _loc16_;
      var _loc22_;
      var _loc24_;
      var _loc23_;
      var _loc25_;
      var _loc8_;
      var _loc15_;
      var _loc12_;
      var _loc18_;
      while(_loc6_ < decalArr.length)
      {
         _loc21_ = decalArr[_loc6_].part == "full";
         if(_loc21_)
         {
            _loc2_ = targetClip.decalLoader.createEmptyMovieClip("full",targetClip.decalLoader.getNextHighestDepth());
         }
         else
         {
            for(_loc26_ in targetClip.decalLoader)
            {
               if(typeof targetClip.decalLoader[_loc26_] == "movieclip")
               {
                  _loc2_ = targetClip.decalLoader[_loc26_][decalArr[_loc6_].part];
                  break;
               }
            }
         }
         _loc2_.isBack = isBack;
         _loc2_.decalLoadin = decalArr[_loc6_].localPath == undefined ? targetClip[decalArr[_loc6_].catID] : decalArr[_loc6_].localPath;
         _loc2_.part = decalArr[_loc6_].part;
         _loc2_.partClr = decalArr[_loc6_].partClr;
         _loc2_.ii = _loc6_;
         _loc2_.di = Number(decalArr[_loc6_].di);
         _loc2_.decalTextureMap = function(tpm)
         {
            var _loc2_ = tpm.actual;
            if(!_loc2_)
            {
               return undefined;
            }
            if(!_loc2_.decal)
            {
               _loc2_.createEmptyMovieClip("decal",_loc2_.getNextHighestDepth());
               _loc2_.shad.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.hi.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.noPaint.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.bmp = new flash.display.BitmapData(_loc2_.paint._width,_loc2_.paint._height,true,0);
            }
            _loc2_.bmp.draw(this.decal,new flash.geom.Matrix(1,0,0,1,- tpm._x - _loc2_.paint._x,- tpm._y - _loc2_.paint._y - coreYAdj),new flash.geom.ColorTransform(),null,null,true);
            _loc2_.bmp.draw(_loc2_.paint,new flash.geom.Matrix(),new flash.geom.ColorTransform(),"alpha",null,true);
            _loc2_.decal.attachBitmap(_loc2_.bmp,1,"never",true);
            _loc2_.decal._x = _loc2_.paint._x;
            _loc2_.decal._y = _loc2_.paint._y;
         };
         _loc2_.decalTexturePerfect = function(tpm)
         {
            var _loc2_ = tpm.actual;
            if(!_loc2_)
            {
               return undefined;
            }
            if(!_loc2_.decalPerfect)
            {
               _loc2_.createEmptyMovieClip("decalPerfect",_loc2_.getNextHighestDepth());
               _loc2_.shad.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.hi.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.noPaint.swapDepths(_loc2_.getNextHighestDepth());
               _loc2_.bmp = new flash.display.BitmapData(_loc2_.paint._width,_loc2_.paint._height,true,0);
            }
            _loc2_.bmp.draw(this.decalLoadin,new flash.geom.Matrix(1,0,0,1,- tpm._x - _loc2_.paint._x,- tpm._y - _loc2_.paint._y - coreYAdj),new flash.geom.ColorTransform(),null,null,true);
            _loc2_.bmp.draw(_loc2_.paint,new flash.geom.Matrix(),new flash.geom.ColorTransform(),"alpha",null,true);
            _loc2_.decalPerfect.attachBitmap(_loc2_.bmp,1,"never",true);
            _loc2_.decalPerfect._x = _loc2_.paint._x;
            _loc2_.decalPerfect._y = _loc2_.paint._y;
         };
         if(_loc21_)
         {
            _loc2_.decalLoadin.gotoAndStop(_loc2_.di);
            if(_loc2_.decalLoadin.paint != undefined)
            {
               _loc2_.decalLoadin.clr = new Color(_loc2_.decalLoadin.paint);
               _loc2_.decalLoadin.clr.setRGB(_loc2_.partClr);
            }
            _loc2_.decalTexturePerfect(targetClip.roofEffect);
            _loc2_.decalTexturePerfect(targetClip.eyelids);
            _loc2_.decalTexturePerfect(targetClip.hoodCenterEffect);
            _loc2_.decalTexturePerfect(targetClip.hoodBackEffect);
            _loc2_.decalTexturePerfect(targetClip.sideEffect);
            _loc2_.decalTexturePerfect(targetClip.fenderEffect);
            _loc2_.decalTexturePerfect(targetClip.cPillarEffect);
            _loc2_.decalTexturePerfect(targetClip.doorEffect);
            _loc2_.decalTexturePerfect(targetClip.trunk);
            _loc2_.decalTexturePerfect(targetClip.hood);
            _loc2_.decalTexturePerfect(targetClip.grille);
            _loc2_.decalTexturePerfect(targetClip.bumper);
            _loc2_.decalTexturePerfect(targetClip.bumperRear);
            _loc2_.decalTexturePerfect(targetClip.skirt);
            _loc2_.decalTexturePerfect(targetClip.body);
            _loc2_.decalTexturePerfect(targetClip.bodyOpp);
         }
         else
         {
            _loc2_.decalLoadin.gotoAndStop(_loc2_.di);
            if(_loc2_.decalLoadin != undefined)
            {
               _loc20_ = "_________";
               for(_loc26_ in _loc2_.decalLoadin)
               {
                  _loc20_ += _loc26_ + "_______";
               }
            }
            if(_loc2_.decalLoadin.paint != undefined)
            {
               _loc2_.decalLoadin.clr = new Color(_loc2_.decalLoadin.paint);
               _loc2_.decalLoadin.clr.setRGB(_loc2_.partClr);
            }
            _loc14_ = 0;
            _loc13_ = 0;
            for(_loc26_ in _loc2_)
            {
               if(typeof _loc2_[_loc26_] == "movieclip" && _loc26_.substr(0,1) == "p")
               {
                  _loc10_ = _loc26_.substr(1).split("_");
                  if(parseInt(_loc10_[0],10) > _loc14_)
                  {
                     _loc14_ = parseInt(_loc10_[0],10);
                  }
                  if(parseInt(_loc10_[1],10) > _loc13_)
                  {
                     _loc13_ = parseInt(_loc10_[1],10);
                  }
               }
            }
            _loc19_ = new Array();
            _loc7_ = 1;
            while(_loc7_ <= _loc14_)
            {
               _loc11_ = new Array();
               _loc5_ = 1;
               while(_loc5_ <= _loc13_)
               {
                  _loc11_.push([_loc2_["p" + _loc7_ + "_" + _loc5_]._x,_loc2_["p" + _loc7_ + "_" + _loc5_]._y]);
                  _loc5_ = _loc5_ + 1;
               }
               _loc19_.push(_loc11_);
               _loc7_ = _loc7_ + 1;
            }
            _loc17_ = 0;
            _loc16_ = 0;
            switch(decalArr[_loc6_].part)
            {
               case "side":
                  _loc17_ = 650;
                  _loc16_ = 187;
                  break;
               case "front":
                  _loc17_ = 300;
                  _loc16_ = 160;
                  break;
               case "back":
                  _loc17_ = 350;
                  _loc16_ = 150;
                  break;
               case "hood":
                  _loc17_ = 200;
                  _loc16_ = 200;
            }
            trace("scale scale scale scale scale scale: " + _loc2_.decalLoadin._xscale);
            _loc22_ = Math.floor(_loc2_.decalLoadin._width * 100 / _loc2_.decalLoadin._xscale);
            _loc24_ = Math.floor(_loc2_.decalLoadin._height * 100 / _loc2_.decalLoadin._yscale);
            _loc23_ = new flash.geom.Matrix(_loc17_ / _loc22_,0,0,_loc16_ / _loc24_,0,0);
            _loc2_.bmp = new flash.display.BitmapData(_loc17_,_loc16_,true,0);
            _loc2_.bmp.draw(_loc2_.decalLoadin,_loc23_,new flash.geom.ColorTransform(),null,null,true);
            if(_loc2_.decal == undefined)
            {
               _loc2_.createEmptyMovieClip("decal",_loc2_.getNextHighestDepth());
            }
            _loc25_ = new classes.DistordImageToMatrix(_loc2_.decal,_loc2_.bmp,_loc19_);
            switch(_loc2_.part)
            {
               case "side":
                  _loc2_.decalTextureMap(targetClip.body);
                  _loc2_.decalTextureMap(targetClip.skirt);
                  _loc2_.decalTextureMap(targetClip.sideEffect);
                  _loc2_.decalTextureMap(targetClip.doorEffect);
                  _loc2_.decalTextureMap(targetClip.fenderEffect);
                  _loc2_.decalTextureMap(targetClip.cPillarEffect);
                  if(!_loc2_.isBack)
                  {
                     _loc2_.decalTextureMap(targetClip.bumperRear);
                     _loc2_.decalTextureMap(targetClip.trunk);
                  }
                  if(targetClip.bodyOpp != undefined && targetClip.decalLoader.actual.sideOpp != undefined)
                  {
                     trace("************* IS exists **************");
                     _loc8_ = targetClip.decalLoader.actual.sideOpp;
                     _loc15_ = 0;
                     _loc12_ = 0;
                     for(_loc26_ in _loc8_)
                     {
                        if(typeof _loc8_[_loc26_] == "movieclip" && _loc26_.substr(0,1) == "p")
                        {
                           _loc10_ = _loc26_.substr(1).split("_");
                           if(parseInt(_loc10_[0],10) > _loc15_)
                           {
                              _loc15_ = parseInt(_loc10_[0],10);
                           }
                           if(parseInt(_loc10_[1],10) > _loc12_)
                           {
                              _loc12_ = parseInt(_loc10_[1],10);
                           }
                        }
                     }
                     _loc18_ = new Array();
                     _loc7_ = 1;
                     while(_loc7_ <= _loc15_)
                     {
                        _loc11_ = new Array();
                        _loc5_ = 1;
                        while(_loc5_ <= _loc12_)
                        {
                           _loc11_.push([_loc8_["p" + _loc7_ + "_" + _loc5_]._x,_loc8_["p" + _loc7_ + "_" + _loc5_]._y]);
                           _loc5_ = _loc5_ + 1;
                        }
                        _loc18_.push(_loc11_);
                        _loc7_ = _loc7_ + 1;
                     }
                     trace(_loc18_);
                     _loc25_ = new classes.DistordImageToMatrix(_loc2_.decal,_loc2_.bmp,_loc18_);
                     _loc2_.decalTextureMap(targetClip.bodyOpp);
                  }
                  _loc2_.bmp.dispose();
                  _loc2_.decal.removeMovieClip();
                  break;
               case "front":
                  _loc2_.decalTextureMap(targetClip.bumper);
                  _loc2_.bmp.dispose();
                  _loc2_.decal.removeMovieClip();
                  break;
               case "hood":
                  _loc2_.decalTextureMap(targetClip.hood);
                  _loc2_.bmp.dispose();
                  _loc2_.decal.removeMovieClip();
                  break;
               case "back":
                  _loc2_.decalTextureMap(targetClip.trunk);
                  _loc2_.decalTextureMap(targetClip.bumperRear);
                  _loc2_.bmp.dispose();
                  _loc2_.decal.removeMovieClip();
            }
         }
         _loc6_ = _loc6_ + 1;
      }
   }
   static function plateView(targetClip, plateID, lic, scale, registerZero, adjustEuroScale)
   {
      if(!scale)
      {
         scale = 100;
      }
      if(adjustEuroScale && plateID > 7 && plateID < 11)
      {
         scale *= 0.7;
      }
      if(!lic.length)
      {
         lic = "";
      }
      var _loc3_ = new Object();
      _loc3_.onLoadComplete = function(target_mc)
      {
         var _loc3_ = classes.GlobalData.getPlateXML(plateID);
         target_mc.region = _loc3_.attributes.c;
         target_mc.id = _loc3_.attributes.i;
         var _loc2_ = lic.split("_");
         target_mc.seq1 = _loc2_[0];
         target_mc.seq2 = _loc2_[1];
         target_mc.seq3 = _loc2_[2];
         if(target_mc.region == "euro")
         {
            targetClip._xscale = targetClip._yscale = scale;
            if(registerZero)
            {
               target_mc._x = 0;
               target_mc._y = 0;
            }
         }
         else
         {
            targetClip._xscale = targetClip._yscale = scale;
            if(registerZero)
            {
               target_mc._x = -91;
               target_mc._y = 0;
            }
         }
      };
      var _loc2_ = new MovieClipLoader();
      _loc2_.addListener(_loc3_);
      if(targetClip.plateHolder == undefined)
      {
         targetClip.createEmptyMovieClip("plateHolder",targetClip.getNextHighestDepth());
      }
      _loc2_.loadClip("cache/car/plates.swf",targetClip.plateHolder);
   }
   static function drawPlateOnCar(cs, context, pid, lic)
   {
      trace("drawPlateOnCar");
      if(!pid)
      {
         pid = cs.plateID;
      }
      if(!lic)
      {
         lic = cs.lic;
      }
      if(!pid || !lic)
      {
         return undefined;
      }
      trace("drawPlateOnCar: " + pid + ", " + lic);
      if(context.plate == undefined)
      {
         context.createEmptyMovieClip("plate",context.getNextHighestDepth());
      }
      context.plate.transform.colorTransform = new flash.geom.ColorTransform(1,1,1,1,-80,-80,-80,0);
      var _loc3_ = context.bumperRear.actual;
      var _loc5_ = context.bumperRear._x;
      var _loc4_ = context.bumperRear._y;
      trace("plate MC: " + context._parent._parent._parent._parent._parent._name);
      if(context._parent._parent._parent._parent._parent._name == "carAni1")
      {
         if(pid >= 8 && pid <= 10)
         {
            var x1 = _loc5_ + _loc3_.e1._x;
            var y1 = _loc4_ + _loc3_.e1._y;
            var x0 = _loc5_ + _loc3_.e2._x;
            var y0 = _loc4_ + _loc3_.e2._y;
            var x3 = _loc5_ + _loc3_.e3._x;
            var y3 = _loc4_ + _loc3_.e3._y;
            var x2 = _loc5_ + _loc3_.e4._x;
            var y2 = _loc4_ + _loc3_.e4._y;
         }
         else
         {
            var x1 = _loc5_ + _loc3_.p1._x;
            var y1 = _loc4_ + _loc3_.p1._y;
            var x0 = _loc5_ + _loc3_.p2._x;
            var y0 = _loc4_ + _loc3_.p2._y;
            var x3 = _loc5_ + _loc3_.p3._x;
            var y3 = _loc4_ + _loc3_.p3._y;
            var x2 = _loc5_ + _loc3_.p4._x;
            var y2 = _loc4_ + _loc3_.p4._y;
         }
      }
      else if(pid >= 8 && pid <= 10)
      {
         var x0 = _loc5_ + _loc3_.e1._x;
         var y0 = _loc4_ + _loc3_.e1._y;
         var x1 = _loc5_ + _loc3_.e2._x;
         var y1 = _loc4_ + _loc3_.e2._y;
         var x2 = _loc5_ + _loc3_.e3._x;
         var y2 = _loc4_ + _loc3_.e3._y;
         var x3 = _loc5_ + _loc3_.e4._x;
         var y3 = _loc4_ + _loc3_.e4._y;
      }
      else
      {
         var x0 = _loc5_ + _loc3_.p1._x;
         var y0 = _loc4_ + _loc3_.p1._y;
         var x1 = _loc5_ + _loc3_.p2._x;
         var y1 = _loc4_ + _loc3_.p2._y;
         var x2 = _loc5_ + _loc3_.p3._x;
         var y2 = _loc4_ + _loc3_.p3._y;
         var x3 = _loc5_ + _loc3_.p4._x;
         var y3 = _loc4_ + _loc3_.p4._y;
      }
      var _loc13_ = classes.GlobalData.getPlateXML(pid);
      _root.platesHolder.region = _loc13_.attributes.c;
      _root.platesHolder.id = pid;
      var _loc8_ = lic.split("_");
      _root.platesHolder.seq1 = _loc8_[0];
      _root.platesHolder.seq2 = _loc8_[1];
      _root.platesHolder.seq3 = _loc8_[2];
      _root.platesHolder.init();
      var _loc10_ = _root.platesHolder.filters;
      var _loc12_ = new flash.filters.DropShadowFilter(4,120,0,0.8,4,4,1,2);
      _loc10_[0] = _loc12_;
      _root.platesHolder.filters = _loc10_;
      context.plate.onEnterFrame = function()
      {
         classes.Drawing.bmpObj.shopPlate.draw(_root.platesHolder,new flash.geom.Matrix(),new flash.geom.ColorTransform(),null,null,true);
         var _loc3_ = new classes.DistordImageB(this,classes.Drawing.bmpObj.shopPlate,2,2);
         trace([x0,y0,x1,y1,x2,y2,x3,y3]);
         _loc3_.setTransform(x0,y0,x1,y1,x2,y2,x3,y3);
         delete this.onEnterFrame;
      };
      classes.Drawing.bmpObj.shopPlate = new flash.display.BitmapData(414,120,true,0);
   }
   static function refreshPlateOnCar(plateMC, pid, lic)
   {
      function onTO()
      {
         if(plateMC.plate != undefined)
         {
            clearInterval(toSI);
            classes.Drawing.bmpObj.shopPlate.fillRect(classes.Drawing.bmpObj.shopPlate.rectangle,0);
            classes.Drawing.bmpObj.shopPlate.draw(plateMC,new flash.geom.Matrix(),new flash.geom.ColorTransform(),null,null,true);
         }
      }
      var _loc2_ = classes.GlobalData.getPlateXML(pid);
      plateMC.region = _loc2_.attributes.c;
      plateMC.id = pid;
      var _loc1_ = lic.split("_");
      plateMC.seq1 = _loc1_[0];
      plateMC.seq2 = _loc1_[1];
      plateMC.seq3 = _loc1_[2];
      plateMC.init();
      var toSI = setInterval(onTO,50);
   }
   static function carLogo(targetClip, carID)
   {
      targetClip.loadMovie("cache/car/logo_" + carID + ".swf");
   }
   static function insetBox(_context, ww, hh, th, headerColor, winColor, winColor2, angle)
   {
      var headClr;
      var winClr;
      var winClr2;
      var phi = angle <= 0 ? 0 : angle;
      var cRad = 5;
      var thh = th <= cRad ? cRad : th;
      with(_context)
      {
         headClr = 1119253;
         winClr = 592652;
         winClr2 = 1381913;
         clear();
         lineStyle(undefined,0,100);
         beginFill(headClr);
         moveTo(cRad,0);
         lineTo(ww - cRad,0);
         curveTo(ww,0,ww,cRad);
         lineTo(ww,thh);
         lineTo(0,thh);
         lineTo(0,cRad);
         curveTo(0,0,cRad,0);
         endFill();
         moveTo(ww,thh);
         if(winClr2 != undefined)
         {
            colors = [winClr,winClr2];
            alphas = [100,100];
            ratios = [0,255];
            matrix = {matrixType:"box",x:10,y:10,w:ww - 10,h:hh - 10,r:phi / 180 * 3.141592653589793};
            beginGradientFill("linear",colors,alphas,ratios,matrix);
         }
         else
         {
            beginFill(winClr);
         }
         lineTo(ww,hh - cRad);
         curveTo(ww,hh,ww - cRad,hh);
         lineTo(cRad,hh);
         curveTo(0,hh,0,hh - cRad);
         lineTo(0,thh);
         lineTo(ww,thh);
         endFill();
      }
   }
   static function applyInsetBoxFilters(subject)
   {
      var _loc3_ = new flash.filters.DropShadowFilter(3,90,0,0.65,8,8,1,2,true);
      var _loc2_ = new flash.filters.BevelFilter(1,100,5592405,0.7,0,1,1,1,1,1,"outer");
      var _loc4_ = new flash.filters.BevelFilter(1,0,0,1,2236962,1,0,0,1,1,"outer");
      var _loc1_ = [];
      _loc1_[0] = _loc3_;
      _loc1_[1] = _loc2_;
      _loc1_[2] = _loc4_;
      subject.filters = _loc1_;
   }
   static function insetBoxBuddies(_context, ww, hh, th, headerColor, winColor, winColor2, angle, tabPos, tabWidth)
   {
      if(!tabPos)
      {
         tabPos = 15;
      }
      if(!tabWidth)
      {
         tabWidth = 54;
      }
      var headClr;
      var winClr;
      var winClr2;
      var phi = angle <= 0 ? 0 : angle;
      var cRad = 0;
      var thh = th <= cRad ? cRad : th;
      with(_context)
      {
         headClr = 1119253;
         winClr = 592652;
         winClr2 = 1381913;
         clear();
         lineStyle(undefined,0,100);
         beginFill(headClr);
         moveTo(cRad,0);
         lineTo(ww - cRad,0);
         curveTo(ww,0,ww,cRad);
         lineTo(ww,thh);
         lineTo(0,thh);
         lineTo(0,cRad);
         curveTo(0,0,cRad,0);
         endFill();
         moveTo(ww,thh);
         if(winClr2 != undefined)
         {
            colors = [winClr,winClr2];
            alphas = [100,100];
            ratios = [0,255];
            matrix = {matrixType:"box",x:10,y:10,w:ww - 10,h:hh - 10,r:phi / 180 * 3.141592653589793};
            beginGradientFill("linear",colors,alphas,ratios,matrix);
         }
         else
         {
            beginFill(winClr);
         }
         lineTo(ww,hh - cRad);
         curveTo(ww,hh,ww - cRad,hh);
         lineTo(cRad,hh);
         curveTo(0,hh,0,hh - cRad);
         lineTo(0,thh);
         lineTo(tabPos,thh);
         lineTo(tabPos,thh - 15);
         curveTo(tabPos,thh - 18,tabPos + 3,thh - 18);
         lineTo(tabPos + tabWidth - 3,thh - 18);
         curveTo(tabPos + tabWidth,thh - 18,tabPos + tabWidth,thh - 15);
         lineTo(tabPos + tabWidth,thh);
         lineTo(ww,thh);
         endFill();
      }
   }
   static function standardText(_context, fldName, pText, x, y, alpha, pAutoSize, tf)
   {
      if(!fldName.length)
      {
         fldName = "newTextField" + _context.getNextHighestDepth();
      }
      if(!x)
      {
         x = 0;
      }
      if(!y)
      {
         y = 0;
      }
      if(!alpha && alpha !== 0)
      {
         alpha = 100;
      }
      if(!pAutoSize.length || pAutoSize == "true")
      {
         pAutoSize = "left";
      }
      if(!tf)
      {
         tf = new TextFormat();
         tf.font = "Arial";
         tf.size = 11;
         tf.color = 16777215;
      }
      var _loc1_ = _context.createTextField(fldName,_context.getNextHighestDepth(),x,y,5,5);
      _loc1_.selectable = false;
      _loc1_.embedFonts = true;
      _loc1_.autoSize = pAutoSize;
      _loc1_.setNewTextFormat(tf);
      _loc1_._alpha = alpha;
      _loc1_.text = pText;
   }
   static function roundedRect(_context, pWidth, pHeight, cRad, fillColor, alpha, offsetX, offsetY)
   {
      if(!fillColor)
      {
         fillColor = 16777215;
      }
      if(!alpha)
      {
         alpha = 100;
      }
      if(!offsetX)
      {
         offsetX = 0;
      }
      if(!offsetY)
      {
         offsetY = 0;
      }
      with(_context)
      {
         beginFill(fillColor,alpha);
         moveTo(offsetX + cRad,offsetY);
         lineTo(offsetX + pWidth - cRad,offsetY);
         curveTo(offsetX + pWidth,offsetY,offsetX + pWidth,offsetY + cRad);
         lineTo(offsetX + pWidth,offsetY + pHeight - cRad);
         curveTo(offsetX + pWidth,offsetY + pHeight,offsetX + pWidth - cRad,offsetY + pHeight);
         lineTo(offsetX + cRad,offsetY + pHeight);
         curveTo(offsetX,offsetY + pHeight,offsetX,offsetY + pHeight - cRad);
         lineTo(offsetX,offsetY + cRad);
         curveTo(offsetX,offsetY,offsetX + cRad,offsetY);
         endFill();
      }
   }
   static function rect(_context, pWidth, pHeight, fillColor, alpha, offsetX, offsetY, cRad, lineWeight, lineColor, lineAlpha)
   {
      if(fillColor == undefined)
      {
         fillColor = 16777215;
      }
      else if(fillColor == -1)
      {
         fillColor = undefined;
      }
      if(!alpha && alpha !== 0)
      {
         alpha = 100;
      }
      if(!offsetX)
      {
         offsetX = 0;
      }
      if(!offsetY)
      {
         offsetY = 0;
      }
      if(!cRad)
      {
         cRad = 0;
      }
      with(_context)
      {
         if(lineWeight || lineWeight === 0)
         {
            lineStyle(lineWeight,lineColor,lineAlpha);
         }
         beginFill(fillColor,alpha);
         moveTo(offsetX + cRad,offsetY);
         lineTo(offsetX + pWidth - cRad,offsetY);
         curveTo(offsetX + pWidth,offsetY,offsetX + pWidth,offsetY + cRad);
         lineTo(offsetX + pWidth,offsetY + pHeight - cRad);
         curveTo(offsetX + pWidth,offsetY + pHeight,offsetX + pWidth - cRad,offsetY + pHeight);
         lineTo(offsetX + cRad,offsetY + pHeight);
         curveTo(offsetX,offsetY + pHeight,offsetX,offsetY + pHeight - cRad);
         lineTo(offsetX,offsetY + cRad);
         curveTo(offsetX,offsetY,offsetX + cRad,offsetY);
         endFill();
         lineStyle(undefined);
      }
   }
   static function applyMainShad(subject)
   {
      var _loc2_ = new flash.filters.DropShadowFilter(23,45,0,0.6,29,29,1,2);
      var _loc1_ = [];
      _loc1_.push(_loc2_);
      subject.filters = _loc1_;
   }
   static function addToCarQueue(qObj)
   {
      trace("addToCarQueue");
      classes.Drawing.drawCarQueue.push(qObj);
      if(_root.amCarQueue == undefined)
      {
         _root.amCarQueue = _root.createEmptyMovieClip("amCarQueue",_root.getNextHighestDepth());
      }
      _root.amCarQueue.onEnterFrame = function()
      {
         var _loc2_;
         if(classes.Drawing.drawCarQueue.length)
         {
            _loc2_ = classes.Drawing.drawCarQueue[0];
            classes.Drawing.drawCarView(_loc2_.targetClip,_loc2_.carXML,_loc2_.scale,_loc2_.view,_loc2_.override);
            classes.Drawing.drawCarQueue.splice(0,1);
         }
         else
         {
            delete this.onEnterFrame;
         }
      };
   }
   static function carView(targetClip, carXML, scale, view, override)
   {
      trace("carView: ");
      trace("scale: " + scale);
      trace("view: " + view);
      var _loc1_;
      if(targetClip)
      {
         _loc1_ = new Object();
         _loc1_.targetClip = targetClip;
         _loc1_.carXML = carXML;
         _loc1_.scale = scale;
         _loc1_.view = view;
         _loc1_.override = override;
         classes.Drawing.addToCarQueue(_loc1_);
      }
   }
   static function drawCarView(targetClip, carXML, scale, view, override)
   {
      var _loc11_ = Number(carXML.firstChild.attributes.ci);
      if(!scale)
      {
         scale = 100;
      }
      classes.Drawing.clearCarView(targetClip);
      targetClip._visible = false;
      var isBack;
      var _loc34_;
      var _loc25_;
      var _loc36_ = "F";
      if(view == "back" || view == "race" || view == "dyno" || view == "spectate")
      {
         isBack = true;
         _loc36_ = "B";
      }
      var drawSmooth = true;
      if(view == "dyno")
      {
         _loc34_ = true;
         view = "race";
      }
      else if(view == "race")
      {
         if(classes.GlobalData.prefsObj.raceQuality < 5)
         {
            drawSmooth = false;
         }
      }
      else if(view == "spectate")
      {
         if(classes.GlobalData.prefsObj.spectateQuality < 5)
         {
            drawSmooth = false;
         }
         _loc25_ = true;
         view = "race";
      }
      var isPlaceholder;
      var frac = scale / 100;
      var _loc6_ = targetClip.createEmptyMovieClip("carLoadin",targetClip.getNextHighestDepth());
      var _loc29_;
      var _loc24_;
      var _loc30_;
      var _loc14_;
      var _loc3_;
      var _loc5_;
      var _loc9_;
      var _loc7_;
      var _loc4_;
      var _loc10_;
      if(view == "race" && !_loc25_ && !_loc34_ && classes.GlobalData.prefsObj.raceQuality == 1 || _loc25_ && classes.GlobalData.prefsObj.spectateQuality == 1)
      {
         _loc24_ = new Object();
         _loc24_.onLoadInit = function(mc)
         {
            targetClip._xscale = -100;
            targetClip._x += 600;
            targetClip._visible = true;
         };
         _loc24_.onLoadError = function(mc)
         {
         };
         _loc29_ = targetClip.createEmptyMovieClip("carBody",targetClip.getNextHighestDepth());
         _loc30_ = new MovieClipLoader();
         _loc30_.addListener(_loc24_);
         _loc30_.loadClip("cache/car/packages/" + _loc11_ + "b/line.swf",_loc29_);
      }
      else if(view == "race" && !_loc25_ && !_loc34_ && classes.GlobalData.prefsObj.raceQuality == 0)
      {
         targetClip.createEmptyMovieClip("carBody",targetClip.getNextHighestDepth());
      }
      else
      {
         trace("Regular view");
         _loc29_ = targetClip.createEmptyMovieClip("carBody",targetClip.getNextHighestDepth());
         var cc;
         var cs = new classes.CarSpecs();
         if(override)
         {
            cs = override.cs;
            _loc11_ = override.carID;
         }
         else
         {
            cs.applyCarXML(carXML);
         }
         var checkLoaded = function()
         {
            var _loc2_ = true;
            var _loc1_ = 0;
            while(_loc1_ < arrMCL.length)
            {
               if(!arrMCL[_loc1_].mc.isLoaded)
               {
                  _loc2_ = false;
                  break;
               }
               _loc1_ = _loc1_ + 1;
            }
            if(_loc2_)
            {
               trace("isAllLoaded!!!");
               targetClip.carLoadin.wheelF._x = targetClip.carLoadin.tireF._x;
               targetClip.carLoadin.wheelF._y = targetClip.carLoadin.tireF._y;
               targetClip.carLoadin.wheelR._x = targetClip.carLoadin.tireR._x;
               targetClip.carLoadin.wheelR._y = targetClip.carLoadin.tireR._y;
               targetClip.carLoadin.wheelF._xscale = targetClip.carLoadin.tireF._xscale;
               targetClip.carLoadin.wheelF._yscale = targetClip.carLoadin.tireF._yscale;
               trace(targetClip.carLoadin.wheelF._xscale);
               targetClip.carLoadin.wheelR._xscale = targetClip.carLoadin.tireR._xscale;
               targetClip.carLoadin.wheelR._yscale = targetClip.carLoadin.tireR._yscale;
               _loc1_ = 0;
               while(_loc1_ < cs.decalArr.length)
               {
                  if(cs.decalArr[_loc1_].catID == 146)
                  {
                     targetClip.carLoadin["146"].paint.hood.gotoAndStop(cs.hoodID);
                     targetClip.carLoadin["146"].paint.skirt.gotoAndStop(cs.skirtID);
                     targetClip.carLoadin["146"].paint.bumper.gotoAndStop(cs.bumperID);
                     targetClip.carLoadin["146"].paint.bumperRear.gotoAndStop(cs.bumperRearID);
                     break;
                  }
                  _loc1_ = _loc1_ + 1;
               }
               if(isBack)
               {
                  classes.Drawing.drawPlateOnCar(cs,targetClip.carLoadin);
               }
               loadTheRest();
            }
         };
         var checkLoadedPhaseTwo = function()
         {
            if(targetClip.carLoadin.tireF.actual.isLoaded && targetClip.carLoadin.tireR.actual.isLoaded)
            {
               if(isBack)
               {
                  if(!targetClip.carLoadin.tireBack.isLoaded && !targetClip.carLoadin.tireBack.isMissing)
                  {
                     return undefined;
                  }
               }
               if(view == "race" && (!targetClip.carBody.wheelF.isLoaded || !targetClip.carBody.wheelR.isLoaded))
               {
                  return undefined;
               }
               trace("checkLoadedTwo DONE!");
               targetClip._visible = true;
               for(var _loc1_ in targetClip.carLoadin)
               {
                  targetClip.carLoadin[_loc1_]._visible = true;
               }
               cc = new classes.CarConstruction(targetClip.carLoadin,isBack);
               if(view == "race")
               {
                  cc.setCar(cs,true);
               }
               else
               {
                  cc.setCar(cs,false,scale);
               }
               if(!isPlaceholder)
               {
                  classes.Drawing.drawDecalsOnCar(targetClip.carLoadin,cs.decalArr,cc.coreYAdj,isBack);
               }
               finishCar();
               snapshotCar();
            }
         };
         var finishCar = function()
         {
            trace("finishCar: " + view);
            classes.Drawing.clearCarBmps();
            targetClip.snapshot = new flash.display.BitmapData(Math.ceil(640 * frac),Math.ceil(400 * frac),true,0);
            classes.Drawing.aryCarDrawings.push(targetClip,targetClip.snapshot);
            targetClip.carBody.attachBitmap(targetClip.snapshot,targetClip.carBody.getNextHighestDepth(),"always",drawSmooth);
            targetClip.carBody.wheelF.swapDepths(targetClip.carBody.getNextHighestDepth());
            targetClip.carBody.wheelR.swapDepths(targetClip.carBody.getNextHighestDepth());
            if(view == "race")
            {
               targetClip.carLoadin.tireF._x += frac * 18;
            }
            var _loc4_ = targetClip.carLoadin.createEmptyMovieClip("tireMaskAddF",targetClip.carLoadin.getNextHighestDepth());
            var _loc3_ = targetClip.carLoadin.createEmptyMovieClip("tireMaskAddR",targetClip.carLoadin.getNextHighestDepth());
            _loc4_._x = targetClip.carLoadin.wheelMaskAddF._x;
            _loc4_._y = targetClip.carLoadin.wheelMaskAddF._y;
            _loc3_._x = targetClip.carLoadin.wheelMaskAddR._x;
            _loc3_._y = targetClip.carLoadin.wheelMaskAddR._y;
            classes.Drawing.rect(_loc4_,targetClip.carLoadin.wheelMaskAddF._width,targetClip.carLoadin.wheelMaskAddF._height);
            classes.Drawing.rect(_loc3_,targetClip.carLoadin.wheelMaskAddR._width,targetClip.carLoadin.wheelMaskAddR._height);
            var _loc1_;
            var _loc2_;
            if(view == "race")
            {
               _loc1_ = targetClip.carBody.wheelF;
               _loc2_ = targetClip.carBody.wheelR;
               _loc1_._x = targetClip.carLoadin.wheelF._x + frac * 18;
               _loc1_._y = targetClip.carLoadin.wheelF._y;
               _loc2_._x = targetClip.carLoadin.wheelR._x;
               _loc2_._y = targetClip.carLoadin.wheelR._y;
               _loc1_._xscale = targetClip.carLoadin.wheelF._xscale;
               _loc1_._yscale = targetClip.carLoadin.wheelF._yscale;
               _loc2_._xscale = targetClip.carLoadin.wheelR._xscale;
               _loc2_._yscale = targetClip.carLoadin.wheelR._yscale;
               _loc1_._visible = true;
               _loc2_._visible = true;
               trace("race scale: ");
               trace(_loc1_._xscale);
               trace(_loc1_._yscale);
            }
         };
         var addToSnapshot = function(src, scaleFrac)
         {
            var _loc1_ = new flash.geom.Matrix();
            _loc1_.a = _loc1_.d = scaleFrac;
            _loc1_.tx = frac * src._x;
            _loc1_.ty = frac * src._y;
            targetClip.snapshot.draw(src,_loc1_,new flash.geom.ColorTransform(),"normal",null,true);
         };
         var snapshotCar = function()
         {
            trace("snapshotCar: " + view + ", " + frac);
            if(!isBack)
            {
               targetClip.carLoadin.body.actual.racerNumRev.swapDepths(targetClip.carLoadin.body.actual.getNextHighestDepth());
               targetClip.carLoadin.body.actual.racerNum.swapDepths(targetClip.carLoadin.body.actual.getNextHighestDepth());
            }
            targetClip.snapshot.fillRect(targetClip.snapshot.rectangle,0);
            addToSnapshot(targetClip.carLoadin.shadow,frac);
            addToSnapshot(targetClip.carLoadin.underCarriage,frac);
            targetClip.carLoadin.tireF.setMask(null);
            targetClip.carLoadin.tireR.setMask(null);
            targetClip.carLoadin.wheelF.setMask(null);
            targetClip.carLoadin.wheelR.setMask(null);
            addToSnapshot(targetClip.carLoadin.tireR,frac * targetClip.carLoadin.tireR._yscale / 100);
            var _loc4_ = new flash.geom.Matrix();
            _loc4_.a = frac * targetClip.carLoadin.tireF._xscale / 100;
            _loc4_.d = frac * targetClip.carLoadin.tireF._yscale / 100;
            _loc4_.tx = frac * targetClip.carLoadin.tireF._x;
            _loc4_.ty = frac * targetClip.carLoadin.tireF._y;
            targetClip.snapshot.draw(targetClip.carLoadin.tireF,_loc4_,new flash.geom.ColorTransform(),"normal",null,true);
            if(view != "race")
            {
               addToSnapshot(targetClip.carLoadin.wheelF,frac * targetClip.carLoadin.wheelF._yscale / 100);
               addToSnapshot(targetClip.carLoadin.wheelR,frac * targetClip.carLoadin.wheelR._yscale / 100);
            }
            targetClip.carLoadin.tireF.setMask(targetClip.carLoadin.tireMaskAddF);
            targetClip.carLoadin.tireR.setMask(targetClip.carLoadin.tireMaskAddR);
            if(view != "race")
            {
               targetClip.carLoadin.wheelF.setMask(targetClip.carLoadin.wheelMaskAddF);
               targetClip.carLoadin.wheelR.setMask(targetClip.carLoadin.wheelMaskAddR);
            }
            var _loc3_ = new Array("underCarriage","shadow","decalLoader",146,148,149,150,151,160,161,162,163);
            var _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               targetClip.carLoadin[_loc3_[_loc2_]]._visible = false;
               _loc2_ = _loc2_ + 1;
            }
            if(view == "race")
            {
               targetClip.carLoadin.wheelF._visible = false;
               targetClip.carLoadin.wheelR._visible = false;
            }
            targetClip.carLoadin.cacheAsBitmap = true;
            addToSnapshot(targetClip.carLoadin,frac);
            targetClip.carBody._visible = true;
            targetClip._visible = true;
            if(isPlaceholder)
            {
               targetClip.carLoadin._visible = false;
               _loc2_ = 0;
               while(_loc2_ < targetClip.uggWaitArr.length)
               {
                  _root.downloadUgg(targetClip.uggWaitArr[_loc2_].decalObj.path,targetClip);
                  _loc2_ = _loc2_ + 1;
               }
               targetClip.carBody.transform.colorTransform = new flash.geom.ColorTransform(0.3,0.3,0.3,1,0,0,0,0);
               isPlaceholder = false;
            }
            else
            {
               for(var _loc5_ in targetClip.carLoadin)
               {
                  targetClip.carLoadin[_loc5_].actual.bmp.dispose();
               }
               targetClip.carLoadin.removeMovieClip();
            }
            if(targetClip._parent._parent._parent._parent._name.substr(0,6) == "carAni")
            {
               targetClip.flip();
            }
            targetClip.loaded = true;
         };
         var loadTheRest = function()
         {
            trace("loadTheRest");
            if(view == "front" && targetClip.racerNumSeq)
            {
               if(targetClip.isReversed)
               {
                  targetClip.carLoadin.body.actual.racerNumRev.txt = targetClip.racerNumSeq;
               }
               else
               {
                  targetClip.carLoadin.body.actual.racerNum.txt = targetClip.racerNumSeq;
               }
            }
            var _loc4_ = new MovieClipLoader();
            var _loc3_ = new MovieClipLoader();
            _loc4_.addListener(telPhase2);
            _loc3_.addListener(telPhase2);
            var _loc6_;
            if(!targetClip.carLoadin.tireBack.isMissing)
            {
               _loc6_ = new MovieClipLoader();
               _loc6_.addListener(telPhase2);
               _loc6_.loadClip("cache/car/wheel/tireBack.swf",targetClip.carLoadin.tireBack);
            }
            var _loc1_;
            var _loc2_;
            var _loc5_;
            var _loc7_;
            if(view == "race")
            {
               _loc4_.loadClip("cache/car/wheel/tireF.swf",targetClip.carLoadin.tireF.actual);
               _loc3_.loadClip("cache/car/wheel/tireR.swf",targetClip.carLoadin.tireR.actual);
               _loc1_ = targetClip.carBody.createEmptyMovieClip("wheelF",targetClip.carBody.getNextHighestDepth());
               _loc2_ = targetClip.carBody.createEmptyMovieClip("wheelR",targetClip.carBody.getNextHighestDepth());
               _loc1_._x = targetClip.carLoadin.wheelF._x;
               _loc1_._y = targetClip.carLoadin.wheelF._y;
               _loc2_._x = targetClip.carLoadin.wheelR._x;
               _loc2_._y = targetClip.carLoadin.wheelR._y;
               _loc1_._visible = false;
               _loc2_._visible = false;
               _loc5_ = new MovieClipLoader();
               _loc7_ = new MovieClipLoader();
               _loc5_.addListener(telPhase2);
               _loc7_.addListener(telPhase2);
               _loc5_.loadClip("cache/car/wheel/wheelR_" + cs.wheelFID + ".swf",_loc1_);
               _loc7_.loadClip("cache/car/wheel/wheelR_" + cs.wheelRID + ".swf",_loc2_);
            }
            else
            {
               _loc4_.loadClip("cache/car/wheel/tire" + (!isBack ? "F" : "B") + "F_" + cs.tiresID + ".swf",targetClip.carLoadin.tireF.actual);
               _loc3_.loadClip("cache/car/wheel/tire" + (!isBack ? "F" : "B") + "R_" + cs.tiresID + ".swf",targetClip.carLoadin.tireR.actual);
            }
         };
         _loc14_ = new Object();
         _loc14_.onLoadInit = function(mc)
         {
            mc._visible = false;
            if(mc._name != 146 && mc._name != 148 && mc._name != 149 && mc._name != 150 && mc._name != 151 && mc._name != 160 && mc._name != 161 && mc._name != 162 && mc._name != 163 && mc._name != "wheelF" && mc._name != "wheelR")
            {
               for(var _loc2_ in mc)
               {
                  if(typeof mc[_loc2_] == "movieclip")
                  {
                     mc[_loc2_]._name = "actual";
                     break;
                  }
               }
               if(mc._name != "decalLoader")
               {
                  mc._x = mc.actual.tx;
                  mc._y = mc.actual.ty;
                  mc._xscale = mc.actual.scx;
                  mc._yscale = mc.actual.scy;
               }
            }
            trace("movieclip loaded: " + mc._name);
            mc.isLoaded = true;
            checkLoaded();
         };
         _loc14_.onLoadError = function(mc)
         {
            mc.isLoaded = true;
            mc.isMissing = true;
            var _loc7_;
            var _loc2_;
            if(mc._name == 160 || mc._name == 161 || mc._name == 162 || mc._name == 163)
            {
               isPlaceholder = true;
               if(!targetClip.uggWaitArr)
               {
                  targetClip.uggWaitArr = new Array();
               }
               _loc2_ = arrMCL.length - 1;
               while(_loc2_ >= 0)
               {
                  if(arrMCL[_loc2_].mc == mc)
                  {
                     _loc7_ = arrMCL[_loc2_].decalObj;
                     break;
                  }
                  _loc2_ = _loc2_ - 1;
               }
               targetClip.uggWaitArr.push({cname:mc._name,mc:mc,decalObj:_loc7_});
               targetClip.uggOnRetrieve = function(cname, isNewFileAvailable)
               {
                  trace("uggOnRetrieve..." + cname);
                  var _loc1_ = 0;
                  var _loc3_;
                  var _loc2_;
                  while(_loc1_ < targetClip.uggWaitArr.length)
                  {
                     if(cname == targetClip.uggWaitArr[_loc1_].cname)
                     {
                        trace("found in uggWaitArr");
                        if(!isNewFileAvailable)
                        {
                           targetClip.uggWaitArr[_loc1_].mc.isUpdated = true;
                           targetClip.checkUggUpdate();
                           return undefined;
                        }
                        _loc3_ = new MovieClipLoader();
                        _loc2_ = new Object();
                        _loc2_.onLoadInit = function(mc)
                        {
                           trace("onUgg.onLoadInit: " + mc._name);
                           mc._visible = false;
                           mc.isUpdated = true;
                           targetClip.checkUggUpdate();
                        };
                        _loc2_.onLoadError = function(mc)
                        {
                           trace("onLoadError: " + mc._name);
                           mc.isUpdated = true;
                           targetClip.checkUggUpdate();
                        };
                        _loc3_.addListener(_loc2_);
                        _loc3_.loadClip(targetClip.uggWaitArr[_loc1_].decalObj.path,targetClip.carLoadin[cname]);
                        break;
                     }
                     _loc1_ = _loc1_ + 1;
                  }
               };
               targetClip.checkUggUpdate = function()
               {
                  var _loc2_ = true;
                  var _loc1_ = 0;
                  while(_loc1_ < targetClip.uggWaitArr.length)
                  {
                     if(!targetClip.uggWaitArr[_loc1_].mc.isUpdated)
                     {
                        _loc2_ = false;
                        break;
                     }
                     _loc1_ = _loc1_ + 1;
                  }
                  if(_loc2_)
                  {
                     trace("isAllUpdated");
                     classes.Drawing.drawDecalsOnCar(targetClip.carLoadin,cs.decalArr,cc.coreYAdj,isBack);
                     snapshotCar();
                     targetClip.carBody.transform.colorTransform = new flash.geom.ColorTransform(1,1,1,1,0,0,0,0);
                  }
                  else
                  {
                     trace("is NOT allUpdated");
                  }
               };
            }
         };
         var telPhase2 = new Object();
         telPhase2.onLoadInit = function(mc)
         {
            trace("telPhase2.onLoadInit: " + mc._name);
            mc.isLoaded = true;
            checkLoadedPhaseTwo();
         };
         telPhase2.onLoadError = function(mc)
         {
            trace("onLoadError: " + mc._name);
            mc.isLoaded = true;
            checkLoadedPhaseTwo();
         };
         var arrMCL = new Array();
         _loc3_ = 0;
         while(_loc3_ < cs.decalArr.length)
         {
            arrMCL.push({decalObj:cs.decalArr[_loc3_],cname:cs.decalArr[_loc3_].catID,mc:_loc6_.createEmptyMovieClip(cs.decalArr[_loc3_].catID,_loc6_.getNextHighestDepth()),mcl:new MovieClipLoader()});
            _loc3_ = _loc3_ + 1;
         }
         arrMCL.push({cname:"decalLoader",mc:_loc6_.createEmptyMovieClip("decalLoader",_loc6_.getNextHighestDepth()),mcl:new MovieClipLoader()});
         _loc5_ = !isBack ? classes.Drawing.loadPartsArr : classes.Drawing.loadPartsBackArr;
         _loc9_ = !isBack ? classes.Drawing.optionalPartsArr : classes.Drawing.optionalPartsBackArr;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            _loc7_ = false;
            _loc4_ = 0;
            while(_loc4_ < _loc9_.length)
            {
               if(_loc5_[_loc3_] == _loc9_[_loc4_])
               {
                  _loc7_ = true;
                  break;
               }
               _loc4_ = _loc4_ + 1;
            }
            if(!_loc7_ || _loc7_ && cs[_loc5_[_loc3_] + "ID"] > 0)
            {
               trace("adding part: " + _loc5_[_loc3_] + ", " + cs[_loc5_[_loc3_] + "ID"]);
               arrMCL.push({cname:_loc5_[_loc3_],mc:_loc6_.createEmptyMovieClip(_loc5_[_loc3_],_loc6_.getNextHighestDepth()),mcl:new MovieClipLoader()});
            }
            _loc3_ = _loc3_ + 1;
         }
         arrMCL.push({cname:"wheelF",mc:_loc6_.createEmptyMovieClip("wheelF",_loc6_.getNextHighestDepth()),mcl:new MovieClipLoader()});
         arrMCL.push({cname:"wheelR",mc:_loc6_.createEmptyMovieClip("wheelR",_loc6_.getNextHighestDepth()),mcl:new MovieClipLoader()});
         _loc3_ = 0;
         while(_loc3_ < arrMCL.length)
         {
            arrMCL[_loc3_].mcl.addListener(_loc14_);
            if(arrMCL[_loc3_].decalObj)
            {
               if(arrMCL[_loc3_].decalObj.localPath == undefined)
               {
                  if(arrMCL[_loc3_].decalObj.isUGG)
                  {
                     arrMCL[_loc3_].decalObj.path = "cache/car/userDecals/" + arrMCL[_loc3_].decalObj.catID + "_" + arrMCL[_loc3_].decalObj.di + ".swf";
                     _loc10_ = arrMCL[_loc3_].decalObj.path;
                  }
                  else
                  {
                     _loc10_ = "cache/car/decals/" + arrMCL[_loc3_].decalObj.parentdi + "_" + arrMCL[_loc3_].decalObj.part + (!(arrMCL[_loc3_].decalObj.part == "full" && isBack) ? "" : "_b") + ".swf";
                  }
                  arrMCL[_loc3_].mcl.loadClip(_loc10_,arrMCL[_loc3_].mc);
               }
               else
               {
                  arrMCL[_loc3_].mc = arrMCL[_loc3_].decalObj.localPath;
                  arrMCL[_loc3_].mc.isLoaded = true;
                  trace("decal localPath clip: " + arrMCL[_loc3_].mc);
                  checkLoaded();
               }
            }
            else if(arrMCL[_loc3_].cname == "wheelF" || arrMCL[_loc3_].cname == "wheelR")
            {
               arrMCL[_loc3_].mcl.loadClip("cache/car/wheel/wheel" + (!isBack ? "F" : "B") + arrMCL[_loc3_].cname.substr(5,1) + "_" + cs.wheelRID + ".swf",arrMCL[_loc3_].mc);
            }
            else
            {
               trace("cache/car/packages/" + _loc11_ + (!isBack ? "f" : "b") + "/" + arrMCL[_loc3_].cname + ".swf");
               arrMCL[_loc3_].mcl.loadClip("cache/car/packages/" + _loc11_ + (!isBack ? "f" : "b") + "/" + arrMCL[_loc3_].cname + ".swf",arrMCL[_loc3_].mc);
            }
            _loc3_ = _loc3_ + 1;
         }
      }
      targetClip.clearCarView = function()
      {
         targetClip.snapshot.dispose();
         delete targetClip.snapshot;
         targetClip.carBody.removeMovieClip();
         classes.Drawing.clearThisCarsBmps(targetClip);
         classes.ClipFuncs.removeAllClips(targetClip);
      };
      targetClip.flip = function()
      {
         var _loc2_ = this._xscale / 100;
         var _loc3_ = this._xscale / Math.abs(this._xscale);
         this._xscale *= -1;
         trace("flip...");
         trace(_loc3_);
         trace(_loc2_);
         trace(this._xscale);
         targetClip._x += _loc3_ * _loc2_ * 600;
      };
   }
   static function clearCarView(context)
   {
      context.snapshot.dispose();
      delete context.snapshot;
      classes.Drawing.clearThisCarsBmps(context);
      classes.ClipFuncs.removeAllClips(context);
   }
}
