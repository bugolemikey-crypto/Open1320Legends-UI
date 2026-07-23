class classes.mc.PopWinSelectRacer extends MovieClip
{
   var bg;
   var btnX;
   var clr;
   var frac;
   var idx;
   var listMask;
   var maskH;
   var maskT;
   var teamIdx;
   var userList;
   var userListXML;
   static var _mc;
   function PopWinSelectRacer()
   {
      super();
      classes.mc.PopWinSelectRacer._mc = this;
      this.bg.onRelease = function()
      {
      };
      this.btnX.onRelease = function()
      {
         this._parent._visible = false;
      };
   }
   function drawUserList(pXML)
   {
      this.userListXML = new XML(pXML.toString());
      for(var _loc9_ in this.userList)
      {
         this.userList[_loc9_].removeMovieClip();
      }
      this.userList.attachMovie("racerSelectorEmpty","itemEmpty",this.userList.getNextHighestDepth());
      this.userList.itemEmpty.onRelease = function()
      {
         this._parent._parent.onPick(0);
      };
      var _loc2_;
      var _loc10_;
      var _loc3_ = 0;
      while(_loc3_ < this.userListXML.firstChild.childNodes.length)
      {
         _loc2_ = this.userList.attachMovie("userListItem","item" + this.userListXML.firstChild.childNodes[_loc3_].attributes.i,this.userList.getNextHighestDepth(),{userID:Number(this.userListXML.firstChild.childNodes[_loc3_].attributes.i),userName:this.userListXML.firstChild.childNodes[_loc3_].attributes.un});
         classes.Drawing.portrait(_loc2_,this.userListXML.firstChild.childNodes[_loc3_].attributes.i,2,0,0,4);
         _loc2_.photo._xscale = 25;
         _loc2_.photo._yscale = 25;
         _loc2_.photo._x = 100;
         _loc2_.photo.onRollOver = _loc2_.photo.onDragOver = function()
         {
            this.clr = new Color(this);
            this.clr.setTransform({rb:0,gb:100,bb:100});
         };
         _loc2_.photo.onRollOut = _loc2_.photo.onDragOut = function()
         {
            this.clr.setTransform({rb:0,gb:0,bb:0});
         };
         _loc2_.photo.onRelease = function()
         {
            classes.Control.focusViewer(this._parent.userID);
            this.clr.setTransform({rb:0,gb:0,bb:0});
         };
         _loc2_.bar.onRollOver = _loc2_.bar.onDragOver = function()
         {
            this.clr = new Color(this);
            this.clr.setRGB(5636095);
         };
         _loc2_.bar.onRollOut = _loc2_.bar.onDragOut = function()
         {
            this.clr.setRGB(16777215);
         };
         _loc2_.bar.onRelease = function()
         {
            this.clr.setRGB(16777215);
            this._parent._parent._parent.onPick(this._parent.userID,this._parent.userName);
         };
         _loc3_ = _loc3_ + 1;
      }
      this.orderUserList();
   }
   function orderUserList()
   {
      this.userList.clear();
      var vMargin = 0;
      var vSpace = 24;
      var orderArr = new Array();
      var i = 0;
      while(i < this.userListXML.firstChild.childNodes.length)
      {
         orderArr.push({id:this.userListXML.firstChild.childNodes[i].attributes.i,teamID:this.userListXML.firstChild.childNodes[i].attributes.ti,uName:this.userListXML.firstChild.childNodes[i].attributes.un});
         i++;
      }
      orderArr.sortOn(["uName"]);
      i = 0;
      while(i < orderArr.length)
      {
         this.userList["item" + orderArr[i].id]._y = (i + 1) * vSpace;
         this.userList["item" + orderArr[i].id].swapDepths(0);
         this.userList["item" + orderArr[i].id].swapDepths(i + 1);
         i++;
      }
      with(this.userList)
      {
         moveTo(0,0);
         beginFill(0,0);
         lineTo(10,0);
         lineTo(10,_height + vMargin);
         endFill();
      }
      this.userList.maskH = this.listMask._height;
      this.userList.maskT = this.listMask._y;
      this.userList._y = this.listMask._y;
      if(this.userList._height > this.listMask._height)
      {
         this.userList.onEnterFrame = function()
         {
            if(this.listMask.hitTest(_root._xmouse,_root._ymouse,false))
            {
               this.frac = (this._parent._ymouse - this.maskT) / this.maskH;
               this._y = this.maskT - (this._height - this.maskH) * this.frac;
            }
         };
      }
      else
      {
         delete this.userList.onEnterFrame;
         this.userList._y = this.listMask._y;
      }
   }
   function onPick(uid, uname)
   {
      var _loc3_ = _root.createTeamChallengePanel["team" + this.teamIdx + "Slot" + this.idx];
      var _loc5_ = _root.createTeamChallengePanel["btn" + this.teamIdx + "Add" + this.idx];
      _loc3_.photo.removeMovieClip();
      _loc3_.car.removeMovieClip();
      if(!uid)
      {
         _loc3_._visible = false;
         _loc5_._visible = true;
      }
      else
      {
         _loc3_.userID = uid;
         _loc3_.userName = uname;
         classes.Drawing.portrait(_loc3_,uid,2,0,0,4);
         _loc3_.photo._xscale = _loc3_.photo._yscale = 25;
         _loc3_.photo._x = 60;
         _loc3_.photo.onRollOver = _loc3_.photo.onDragOver = function()
         {
            this.clr = new Color(this);
            this.clr.setTransform({rb:0,gb:100,bb:100});
         };
         _loc3_.photo.onRollOut = _loc3_.photo.onDragOut = function()
         {
            this.clr.setTransform({rb:0,gb:0,bb:0});
         };
         _loc3_.photo.onRelease = function()
         {
            classes.Control.focusViewer(this._parent.userID);
            this.clr.setTransform({rb:0,gb:0,bb:0});
         };
         _loc3_.createEmptyMovieClip("car",_loc3_.getNextHighestDepth());
         _loc3_.car._x = -40;
         _loc3_.car._y = -9;
         classes.Lookup.addCallback("getOtherUserCars",_loc3_,this.getCarsCB,String(uid));
         _root.getOtherUserCars(uid);
         if(this.teamIdx == 2)
         {
            _loc3_.photo._x = -84;
            _loc3_.car._x *= -1;
            _loc3_.tf = _loc3_.fld.getTextFormat();
            _loc3_.tf.align = "left";
            _loc3_.fld.setTextFormat(_loc3_.tf);
         }
         else
         {
            _loc3_.car._xscale *= -1;
         }
         _loc3_._visible = true;
         _loc5_._visible = false;
      }
      classes.mc.PopWinSelectRacer._mc._visible = false;
   }
   function getCarsCB(txml)
   {
      var _loc3_ = this;
      _loc3_.carsXML = txml;
      _loc3_.selCarXML = null;
      _loc3_.selCar = 0;
      var _loc4_ = 0;
      while(_loc4_ < _loc3_.carsXML.firstChild.childNodes.length)
      {
         if(_loc3_.carsXML.firstChild.childNodes[_loc4_].attributes.i == _loc3_.carsXML.firstChild.attributes.dc)
         {
            _loc3_.selCarXML = _loc3_.carsXML.firstChild.childNodes[_loc4_];
            _loc3_.selCar = Number(_loc3_.selCarXML.attributes.i);
         }
         _loc4_ = _loc4_ + 1;
      }
      if(!_loc3_.selCar)
      {
         _loc3_.selCarXML = _loc3_.carsXML.firstChild.childNodes[0];
         _loc3_.selCar = Number(_loc3_.selCarXML.attributes.i);
      }
      _loc3_.car.clearCarView();
      classes.Drawing.carView(_loc3_.car,new XML(_loc3_.selCarXML.toString()),10);
      _loc3_.car.onRollOver = _loc3_.car.onDragOver = function()
      {
         this.clr = new Color(this);
         this.clr.setTransform({rb:0,gb:100,bb:100});
      };
      _loc3_.car.onRollOut = _loc3_.car.onDragOut = function()
      {
         this.clr.setTransform({rb:0,gb:0,bb:0});
      };
      _loc3_.car.onRelease = function()
      {
         classes.mc.PopWinSelectRacer._mc._visible = false;
         _root.createTeamChallengePanel.popSelectCar._y = this._parent._y;
         _root.createTeamChallengePanel.popSelectCar._visible = true;
         classes.mc.PopWinSelectRacer._mc.popCarPicker(this._parent.teamIdx,this._parent.idx,this._parent.carsXML);
         this.clr.setTransform({rb:0,gb:0,bb:0});
      };
   }
   function popCarPicker(teamIdx, idx, txml)
   {
      _root.createTeamChallengePanel.popSelectCar.init(teamIdx,idx,txml);
   }
}
