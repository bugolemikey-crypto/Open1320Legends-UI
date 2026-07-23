class classes.mc.PopWinSelectCar extends MovieClip
{
   var bg;
   var btnX;
   var carPicker;
   var carsXML;
   var slotIdx;
   var teamIdx;
   static var _mc;
   function PopWinSelectCar()
   {
      super();
      classes.mc.PopWinSelectCar._mc = this;
      this.bg.onRelease = function()
      {
      };
      this.btnX.onRelease = function()
      {
         this._parent._visible = false;
      };
   }
   function init(pTeamIdx, pIdx, pxml)
   {
      this.teamIdx = pTeamIdx;
      if(this.teamIdx == 1)
      {
         this.bg.pointer._x = 68;
      }
      else
      {
         this.bg.pointer._x = 420;
      }
      this.slotIdx = pIdx;
      this.carsXML = pxml;
      this.carPicker.removeMovieClip();
      this.carPicker = this.attachMovie("carPicker","carPicker",this.getNextHighestDepth(),{_x:5,_y:-80,displayWidth:501});
      this.carPicker.initDrivable(this.carsXML,this.onCarSelect);
      this._visible = true;
   }
   function onCarSelect(idx)
   {
      var _loc3_;
      if(idx || idx === 0)
      {
         trace("onCarSelect: " + this.teamIdx + ", " + this.slotIdx);
         _loc3_ = _root.createTeamChallengePanel["team" + this.teamIdx + "Slot" + this.slotIdx];
         _loc3_.selCar = this.carPicker.selectXML.firstChild.childNodes[idx].attributes.i;
         _loc3_.selCarXML = new XML(this.carPicker.selectXML.firstChild.childNodes[idx].toString()).firstChild;
         _loc3_.car.clearCarView();
         classes.Drawing.carView(_loc3_.car,new XML(_loc3_.selCarXML.toString()),10);
      }
      this.carPicker.removeMovieClip();
      classes.mc.PopWinSelectCar._mc._visible = false;
   }
}
