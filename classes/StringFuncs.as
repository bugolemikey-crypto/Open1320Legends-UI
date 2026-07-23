class classes.StringFuncs
{
   function StringFuncs()
   {
   }
   static function isNumeric(letter)
   {
      if(!letter.length)
      {
         return false;
      }
      var _loc1_ = letter.charCodeAt(0);
      if(_loc1_ >= 48 && _loc1_ <= 57)
      {
         return true;
      }
      return false;
   }
   static function isWordChar(letter)
   {
      if(!letter.length)
      {
         return false;
      }
      var _loc1_ = letter.charCodeAt(0);
      if(_loc1_ >= 65 && _loc1_ <= 90 || _loc1_ >= 97 && _loc1_ <= 122)
      {
         return true;
      }
      return false;
   }
   static function isKeyboardChar(letter)
   {
      var _loc2_ = " `~!@#$%\\^&*()_\\-+=[]{}|;:\'\",.<>/?\\";
      if(!letter.length)
      {
         return false;
      }
      var _loc4_ = letter.charCodeAt(0);
      if(_loc4_ >= 65 && _loc4_ <= 90 || _loc4_ >= 97 && _loc4_ <= 122 || _loc4_ >= 48 && _loc4_ <= 57)
      {
         return true;
      }
      var _loc1_ = 0;
      while(_loc1_ < _loc2_.length)
      {
         if(letter == _loc2_.charAt(_loc1_))
         {
            return true;
         }
         _loc1_ = _loc1_ + 1;
      }
      return false;
   }
   static function unSpecialChars(str)
   {
      var _loc1_ = "";
      _loc1_ = str.split("&apos;").join("\'");
      return _loc1_;
   }
   static function escapeD(str)
   {
      var _loc1_ = str;
      _loc1_ = _loc1_.split("\"").join("\" & QUOTE & \"");
      return _loc1_;
   }
   static function escapeHTML(str)
   {
      var _loc1_ = str;
      _loc1_ = _loc1_.split("\r\n").join(" ");
      _loc1_ = _loc1_.split("\r").join("");
      _loc1_ = _loc1_.split("\n").join("");
      _loc1_ = _loc1_.split("&").join("&amp;");
      _loc1_ = _loc1_.split("<").join("&lt;");
      _loc1_ = _loc1_.split(">").join("&gt;");
      _loc1_ = _loc1_.split(String.fromCharCode(13)).join("<br/>");
      return _loc1_;
   }
   static function escapeAS(str)
   {
      var _loc1_ = "";
      _loc1_ = str.split("\"").join("\\\"");
      return _loc1_;
   }
   static function readCdata(str)
   {
      var _loc1_ = "";
      _loc1_ = classes.StringFuncs.strReplace(str,"&lt;","<");
      _loc1_ = classes.StringFuncs.strReplace(_loc1_,"&gt;",">");
      _loc1_ = classes.StringFuncs.strReplace(_loc1_,"&quot;","\"");
      _loc1_ = classes.StringFuncs.strReplace(_loc1_,"&apos;","\'");
      _loc1_ = classes.StringFuncs.strReplace(_loc1_,"&amp;","&");
      return _loc1_;
   }
   static function strReplace(str, findStr, replaceStr)
   {
      return str.split(findStr).join(replaceStr);
   }
   static function stripHTML(str)
   {
      var _loc4_;
      var _loc1_;
      _loc4_ = "";
      var _loc5_ = str.length;
      _loc1_ = 0;
      var _loc3_;
      while(_loc1_ < _loc5_)
      {
         if(str.charAt(_loc1_) != "<")
         {
            _loc4_ += str.substr(_loc1_,1);
         }
         else
         {
            _loc3_ = str.substr(_loc1_).indexOf(">");
            _loc1_ += _loc3_;
         }
         _loc1_ = _loc1_ + 1;
      }
      return _loc4_;
   }
   static function stripNLCR(str)
   {
      str = str.split("\n").join("");
      str = str.split("\r").join("");
      return str;
   }
   static function addLineBreaksAfterImg(str)
   {
      var _loc12_;
      _loc12_ = "";
      var _loc4_ = str.indexOf("<img");
      var _loc8_;
      var _loc6_;
      var _loc5_;
      var _loc11_;
      var _loc3_;
      var _loc9_;
      var _loc10_;
      var _loc7_;
      var _loc2_;
      while(_loc4_ != -1)
      {
         trace("found img!!!");
         _loc9_ = 0;
         _loc10_ = "";
         _loc8_ = str.indexOf("height=",_loc4_);
         _loc6_ = str.indexOf(">",_loc4_);
         if(_loc6_ > _loc8_ && _loc8_ != -1 && _loc6_ != -1)
         {
            _loc5_ = str.substring(0,_loc6_ + 1);
            _loc11_ = str.substring(_loc6_ + 1);
            _loc3_ = _loc8_ + 8;
            while(classes.StringFuncs.isNumeric(str.charAt(_loc3_)))
            {
               trace("isNumeric!");
               _loc10_ += str.charAt(_loc3_);
               _loc3_ = _loc3_ + 1;
            }
            _loc9_ = Number(_loc10_);
            if(_loc9_ > 0)
            {
               _loc7_ = _loc9_ / 15;
               trace("numOfBreaks: " + _loc7_);
               _loc2_ = 0;
               while(_loc2_ < _loc7_)
               {
                  trace("numOfBreaks!");
                  _loc5_ = _loc5_.concat("<br />");
                  _loc2_ = _loc2_ + 1;
               }
            }
            str = _loc5_.concat(_loc11_);
         }
         _loc4_ = _loc4_ + 1;
         _loc4_ = str.indexOf("<img",_loc4_);
      }
      _loc12_ = str;
      trace("temp");
      trace(_loc12_);
      return _loc12_;
   }
   static function addHyperlinkHandler(str)
   {
      trace(str);
      str = str.split("href=\"").join("href=\"asfunction:_root.linkHandler,");
      trace(str);
      return str;
   }
   static function underlineHyperlinks(str)
   {
      var _loc8_;
      _loc8_ = "";
      var _loc3_ = str.indexOf("href");
      var _loc9_;
      var _loc6_;
      var _loc5_;
      var _loc2_;
      var _loc4_;
      var _loc7_;
      while(_loc3_ != -1)
      {
         trace("found link");
         _loc7_ = "<u/>";
         _loc6_ = str.indexOf(">",_loc3_);
         _loc2_ = str.substring(0,_loc6_ + 1);
         _loc4_ = str.substring(_loc6_ + 1);
         _loc2_ = _loc2_.concat("<u>");
         str = _loc2_.concat(_loc4_);
         _loc5_ = str.indexOf("<",_loc3_);
         _loc2_ = str.substring(0,_loc5_);
         _loc4_ = str.substring(_loc5_);
         _loc2_ = _loc2_.concat("<u/>");
         str = _loc2_.concat(_loc4_);
         _loc3_ = _loc3_ + 1;
         _loc3_ = str.indexOf("href",_loc3_);
      }
      _loc8_ = str;
      trace("temp");
      trace(_loc8_);
      return _loc8_;
   }
   static function addLineBreaksAfterParagraphTags(str)
   {
      str = str.split("</p>").join("</p><br/>");
      return str;
   }
   static function addLineBreaksInLists(str)
   {
      str = str.split("</li>").join("</li><br/>");
      return str;
   }
   static function fixHTMLForFlash(str)
   {
      trace(str);
      str = classes.StringFuncs.addLineBreaksAfterImg(str);
      str = classes.StringFuncs.addHyperlinkHandler(str);
      str = classes.StringFuncs.addLineBreaksAfterParagraphTags(str);
      str = classes.StringFuncs.addLineBreaksInLists(str);
      trace(str);
      return str;
   }
}
