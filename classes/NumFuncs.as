class classes.NumFuncs
{
   static var maxInterval = 2147483647;
   function NumFuncs()
   {
   }
   static function getHoursAmPm(hour24)
   {
      var _loc2_ = new Object();
      _loc2_.ampm = hour24 >= 12 ? "PM" : "AM";
      var _loc1_ = hour24 % 12;
      if(_loc1_ == 0)
      {
         _loc1_ = 12;
      }
      _loc2_.hours = _loc1_;
      return _loc2_;
   }
   static function get2Mins(min)
   {
      var _loc1_ = "";
      if(min < 10)
      {
         _loc1_ += "0";
      }
      _loc1_ += min.toString();
      return _loc1_;
   }
   static function getTimeFormatted(theDate)
   {
      var _loc3_ = classes.NumFuncs.getHoursAmPm(theDate.getHours());
      var _loc2_ = classes.NumFuncs.get2Mins(theDate.getMinutes());
      var _loc1_ = _loc3_.hours + ":" + _loc2_ + _loc3_.ampm;
      trace("getTimeFormatted");
      trace(_loc2_);
      trace(_loc1_);
      return _loc1_;
   }
   static function dayName(n)
   {
      var _loc2_ = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
      if(n === 0 || n > 0)
      {
         return _loc2_[n];
      }
      return "";
   }
   static function monthName(m)
   {
      var _loc2_ = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
      if(m === 0 || m > 0)
      {
         return _loc2_[m];
      }
      return "";
   }
   static function commaFormat(rawNum)
   {
      var _loc4_ = String(rawNum);
      var _loc1_ = _loc4_.split(".");
      var _loc2_ = "";
      var _loc3_;
      if(_loc1_[0].length > 3)
      {
         _loc3_ = _loc1_[0].length % 3;
         if(_loc3_)
         {
            _loc2_ += _loc1_[0].substr(0,_loc3_) + ",";
            _loc1_[0] = _loc1_[0].substr(_loc3_);
         }
         while(_loc1_[0].length > 3)
         {
            _loc2_ += _loc1_[0].substr(0,3) + ",";
            _loc1_[0] = _loc1_[0].substr(3);
         }
         _loc2_ += _loc1_[0];
         if(_loc1_[1].length)
         {
            _loc2_ += "." + _loc1_[1];
         }
         return _loc2_;
      }
      return String(rawNum);
   }
   static function toText(num)
   {
      if(!(num >= 0 && num <= 20))
      {
         return "unknown";
      }
      switch(num)
      {
         case 0:
            return "zero";
         case 1:
            return "one";
         case 2:
            return "two";
         case 3:
            return "three";
         case 4:
            return "four";
         case 5:
            return "five";
         case 6:
            return "six";
         case 7:
            return "seven";
         case 8:
            return "eight";
         case 9:
            return "nine";
         case 10:
            return "ten";
         case 11:
            return "eleven";
         case 12:
            return "twelve";
         case 13:
            return "thirteen";
         case 14:
            return "fourteen";
         case 15:
            return "fifteen";
         case 16:
            return "sixteen";
         case 17:
            return "seventeen";
         case 18:
            return "eighteen";
         case 19:
            return "nineteen";
         case 20:
            return "twenty";
         default:
            return;
      }
   }
   static function toOrdinal(num)
   {
      var _loc2_;
      num = Math.floor(num);
      _loc2_ = num % 10;
      switch(_loc2_)
      {
         case 1:
            return String(num) + "st";
         case 2:
            return String(num) + "nd";
         case 3:
            return String(num) + "rd";
         default:
            return String(num) + "th";
      }
   }
   static function zeroFill(num, toDecPlace)
   {
      var _loc2_ = String(num);
      var _loc4_ = _loc2_.indexOf(".");
      if(_loc4_ == -1)
      {
         _loc2_ += ".";
      }
      var _loc1_ = 0;
      while(_loc1_ < toDecPlace)
      {
         _loc2_ += "0";
         _loc1_ = _loc1_ + 1;
      }
      return _loc2_.substr(0,_loc2_.indexOf(".") + toDecPlace + 1);
   }
   static function toDecimalPlaces(num, toDecPlace)
   {
      if(toDecPlace == undefined)
      {
         toDecPlace = 0;
      }
      var _loc1_ = Math.pow(10,toDecPlace);
      var _loc3_ = Math.round(num * _loc1_) / _loc1_;
      return String(_loc3_);
   }
   static function formatSecs(numOfSecs)
   {
      var _loc1_;
      var _loc2_;
      var _loc4_;
      var _loc5_;
      _loc1_ = Math.floor(numOfSecs / 3600);
      _loc2_ = Math.floor(numOfSecs / 60 - _loc1_ * 60);
      _loc4_ = Math.floor(numOfSecs - (_loc1_ * 3600 + _loc2_ * 60));
      _loc5_ = classes.NumFuncs.zeroPrefix(_loc1_) + ":" + classes.NumFuncs.zeroPrefix(_loc2_) + "." + classes.NumFuncs.zeroPrefix(_loc4_);
      return _loc5_;
   }
   static function formatSecsAllSemicolons(numOfSecs)
   {
      var _loc1_;
      var _loc2_;
      var _loc4_;
      var _loc5_;
      _loc1_ = Math.floor(numOfSecs / 3600);
      _loc2_ = Math.floor(numOfSecs / 60 - _loc1_ * 60);
      _loc4_ = Math.floor(numOfSecs - (_loc1_ * 3600 + _loc2_ * 60));
      _loc5_ = classes.NumFuncs.zeroPrefix(_loc1_) + ":" + classes.NumFuncs.zeroPrefix(_loc2_) + ":" + classes.NumFuncs.zeroPrefix(_loc4_);
      return _loc5_;
   }
   static function zeroPrefix(number)
   {
      var _loc1_;
      if(number < 10)
      {
         _loc1_ = "0" + number;
      }
      else
      {
         _loc1_ = String(number);
      }
      return _loc1_;
   }
   static function dateFormat(theDate)
   {
      trace("dateFormat");
      trace(theDate.getMonth());
      var _loc3_ = classes.NumFuncs.zeroPrefix(theDate.getMonth() + 1);
      var _loc2_ = classes.NumFuncs.zeroPrefix(theDate.getDate());
      var _loc4_ = String(theDate.getFullYear());
      return String(_loc3_ + "/" + _loc2_ + "/" + _loc4_);
   }
}
