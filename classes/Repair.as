class classes.Repair
{
   function Repair()
   {
   }
   static function formatDamageItem(pcid, damage, numCylinder, numValve)
   {
      trace("formatDamageItem: " + pcid + ", " + damage + ", " + numCylinder + ", " + numValve);
      var _loc2_ = new Object();
      _loc2_.title = "";
      _loc2_.description = "";
      var _loc3_;
      var _loc1_;
      var _loc4_;
      if(pcid == 45)
      {
         _loc3_ = damage / 100 * numValve;
         _loc1_ = "Valve";
         _loc4_ = true;
      }
      else if(pcid == 135)
      {
         _loc3_ = damage / 100 * numCylinder;
         _loc1_ = "Connecting Rod";
         _loc4_ = true;
      }
      else if(pcid == 44)
      {
         _loc3_ = damage / 100 * numCylinder;
         _loc1_ = "Piston";
         _loc4_ = true;
      }
      else if(pcid == 136)
      {
         _loc3_ = damage / 100;
         _loc1_ = "Head Gasket";
         _loc4_ = false;
      }
      else if(pcid == 39)
      {
         _loc3_ = damage / 100;
         _loc1_ = "Engine Block";
         _loc4_ = false;
      }
      else if(pcid == 154)
      {
         _loc3_ = damage / 100 * numValve;
         _loc1_ = "Apex Seal";
         _loc4_ = true;
      }
      else if(pcid == 156)
      {
         _loc3_ = damage / 100 * numCylinder;
         _loc1_ = "Rotor Housing";
         _loc4_ = true;
      }
      else if(pcid == 155)
      {
         _loc3_ = damage / 100 * numCylinder;
         _loc1_ = "Rotor";
         _loc4_ = true;
      }
      else if(pcid == 157)
      {
         _loc3_ = damage / 100;
         _loc1_ = "Corner and Side Seals";
         _loc4_ = false;
      }
      else if(pcid == 153)
      {
         _loc3_ = damage / 100;
         _loc1_ = "Engine Block";
         _loc4_ = false;
      }
      var _loc7_;
      if(_loc3_ == 0)
      {
         if(_loc4_)
         {
            _loc2_.title = "Healthy " + _loc1_ + "s";
            _loc2_.description = "All " + _loc1_.toLowerCase() + "s are in good condition.";
         }
         else
         {
            _loc2_.title = "Healthy " + _loc1_;
            _loc2_.description = "The " + _loc1_.toLowerCase() + " is in good condition.";
         }
      }
      else if(_loc3_ < 0.5)
      {
         if(_loc4_)
         {
            _loc2_.title = "Stressed " + _loc1_ + "s";
            _loc2_.description = "1 " + _loc1_.toLowerCase() + " is showing signs of stress. It is not affecting your power, but might not last many more races.";
         }
         else
         {
            _loc2_.title = "Stressed " + _loc1_;
            _loc2_.description = "The " + _loc1_.toLowerCase() + " is showing signs of stress. It is not affecting your power, but might not last many more races.";
         }
      }
      else if(_loc3_ < 1)
      {
         if(_loc4_)
         {
            _loc2_.title = "Worn " + _loc1_ + "s";
            _loc2_.description = "1 " + _loc1_.toLowerCase() + " is very close to failing. It is not affecting your power yet, but it could fail while racing soon.";
         }
         else
         {
            _loc2_.title = "Worn " + _loc1_;
            _loc2_.description = "The " + _loc1_.toLowerCase() + " is very close to failing. It is not affecting your power yet, but it could fail while racing soon.";
         }
      }
      else if(_loc4_)
      {
         _loc7_ = Math.floor(_loc3_);
         if(_loc7_ == 1)
         {
            _loc2_.title = "Broken " + _loc1_;
            _loc2_.description = _loc7_ + " " + _loc1_.toLowerCase() + " has completely failed. It must be replaced for the engine to run correctly.";
         }
         else
         {
            _loc2_.title = "Broken " + _loc1_ + "s";
            _loc2_.description = _loc7_ + " " + _loc1_.toLowerCase() + "s have completely failed. They must be replaced for the engine to run correctly.";
         }
      }
      else
      {
         _loc2_.title = "Broken " + _loc1_;
         _loc2_.description = "The " + _loc1_.toLowerCase() + " has completely failed. It must be replaced for the engine to run correctly.";
      }
      return _loc2_;
   }
   static function showDamageList(txml)
   {
      var _loc9_ = 0;
      var _loc10_ = 0;
      var _loc6_ = "";
      var _loc12_ = Number(txml.attributes.p);
      var _loc11_ = Number(txml.attributes.v);
      if("35".indexOf(String(classes.GlobalData.role)) > -1)
      {
         _loc6_ += "Note: Members receive a more detailed report including repair prices.\r\r";
      }
      var _loc2_ = 0;
      var _loc1_;
      var _loc3_;
      var _loc5_;
      var _loc4_;
      var _loc7_;
      while(_loc2_ < txml.childNodes.length)
      {
         _loc1_ = txml.childNodes[_loc2_];
         if(Number(_loc1_.attributes.ci) != 102)
         {
            _loc3_ = Number(_loc1_.attributes.d);
            if(_loc3_)
            {
               _loc5_ = classes.Repair.formatDamageItem(Number(_loc1_.attributes.ci),_loc3_,_loc12_,_loc11_);
               _loc4_ = Number(_loc1_.attributes.p);
               _loc7_ = Number(_loc1_.attributes.pp);
               _loc6_ += _loc5_.title + "\r";
               if("1246".indexOf(String(classes.GlobalData.role)) > -1)
               {
                  _loc6_ += _loc5_.description + "\r";
                  _loc6_ += "Repair cost: $" + _loc4_ + "\r\r";
               }
               _loc9_ += _loc4_;
               _loc10_ += _loc7_;
            }
         }
         _loc2_ = _loc2_ + 1;
      }
      if("1246".indexOf(String(classes.GlobalData.role)) > -1)
      {
         _loc6_ += "Total repair cost: $" + _loc9_ + "\r";
      }
      classes.Control.dialogTextBlob("Damage Report",_loc6_,"shop");
   }
}
