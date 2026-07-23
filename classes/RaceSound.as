class classes.RaceSound
{
   var boostLink;
   var boostSnd;
   var bovLink;
   var bovSnd;
   var gearLink;
   var gearSnd;
   var isRevUp;
   var nitrousLink;
   var nitrousReleaseLink;
   var nitrousReleaseSnd;
   var nitrousSnd;
   var oldRPM;
   var redLine;
   var revDownLink;
   var revDownSnd;
   var revUpLink;
   var revUpSnd;
   var screechLink;
   var screechSnd;
   var setVolume;
   var sndSeed;
   static var soundsEnabled;
   static var volumeSI;
   var sndInterval = 2;
   var isNitrousOn = false;
   var isScreechOn = false;
   function RaceSound()
   {
      var _loc2_ = classes.GlobalData.engineSound;
      this.init("ru_" + String(_loc2_),"rd_" + String(_loc2_),"gear shift 02.wav","turbo spool 01.wav","gas hiss sound 2.wav","nitrous release.wav","blow off valve.wav","A_peel_o.wav",8500);
   }
   function set RpmRedLine(v)
   {
      this.redLine = v;
   }
   function init(revUp, revDown, gear, boost, nos, nosRel, bov, screech, rpmRedLine)
   {
      trace("RaceSound::init");
      this.revUpLink = "cache/sounds/" + revUp + ".mp3";
      this.revDownLink = "cache/sounds/" + revDown + ".mp3";
      this.gearLink = gear;
      this.boostLink = boost;
      this.nitrousLink = nos;
      this.nitrousReleaseLink = nosRel;
      this.bovLink = bov;
      this.screechLink = screech;
      this.revUpSnd = new Sound();
      this.revDownSnd = new Sound();
      this.gearSnd = new Sound();
      this.boostSnd = new Sound();
      this.nitrousSnd = new Sound();
      this.nitrousReleaseSnd = new Sound();
      this.bovSnd = new Sound();
      this.screechSnd = new Sound();
      trace("revup: " + revUp);
      this.revUpSnd.onLoad = function(success)
      {
         if(success)
         {
            if(classes.RaceSound.soundsEnabled == true)
            {
               this.setVolume(50);
            }
            else
            {
               this.setVolume(0);
            }
            trace("success loading sound!");
         }
         else
         {
            trace("failed loading sound!");
         }
      };
      this.revDownSnd.onLoad = function(success)
      {
         if(success)
         {
            if(classes.RaceSound.soundsEnabled == true)
            {
               this.setVolume(50);
            }
            else
            {
               this.setVolume(0);
            }
            trace("success loading sound!");
         }
         else
         {
            trace("failed loading sound!");
         }
      };
      this.revUpSnd.loadSound(this.revUpLink,false);
      this.revDownSnd.loadSound(this.revDownLink,false);
      this.gearSnd.attachSound(this.gearLink);
      this.boostSnd.attachSound(this.boostLink);
      this.nitrousSnd.attachSound(this.nitrousLink);
      this.nitrousReleaseSnd.attachSound(this.nitrousReleaseLink);
      this.bovSnd.attachSound(this.bovLink);
      this.screechSnd.attachSound(this.screechLink);
      this.redLine = rpmRedLine;
      this.oldRPM = 0;
      this.isRevUp = false;
      this.sndSeed = 0;
   }
   function playEngineSound(rpm, boostPSI, screech)
   {
      var _loc3_ = rpm >= this.oldRPM;
      var _loc4_;
      var _loc5_;
      if(this.sndSeed % this.sndInterval == 0 || this.isRevUp != _loc3_)
      {
         this.sndSeed = 0;
         if(rpm >= this.oldRPM)
         {
            if(rpm > this.redLine)
            {
               _loc4_ = this.revUpSnd.duration * 0.9;
            }
            else
            {
               _loc4_ = this.revUpSnd.duration * rpm / this.redLine * 0.9;
            }
            if(Math.abs(this.revUpSnd.position - _loc4_) > 100 || this.isRevUp != _loc3_)
            {
               this.revUpSnd.stop();
               this.revDownSnd.stop();
               this.revUpSnd.start(_loc4_ / 1000,1);
            }
            this.isRevUp = true;
         }
         else
         {
            if(rpm > this.redLine)
            {
               _loc4_ = this.revDownSnd.duration * 0.9;
            }
            else
            {
               _loc4_ = this.revDownSnd.duration * (this.redLine - rpm) / this.redLine * 0.9;
            }
            if(Math.abs(this.revDownSnd.position - _loc4_) > 100 || this.isRevUp != _loc3_)
            {
               this.revUpSnd.stop();
               this.revDownSnd.stop();
               this.revDownSnd.start(_loc4_ / 1000,1);
            }
            this.isRevUp = false;
         }
         if(boostPSI > 0)
         {
            if(rpm > this.redLine)
            {
               _loc5_ = this.boostSnd.duration * 0.9;
            }
            else
            {
               _loc5_ = this.boostSnd.duration * rpm / this.redLine * 0.9 * boostPSI / 35;
            }
            if(Math.abs(this.boostSnd.position - _loc5_) > 200)
            {
               this.boostSnd.stop(this.boostLink);
               this.boostSnd.start(_loc5_ / 1000,1);
            }
            if(this.oldRPM - rpm > 1000)
            {
               this.bovSnd.start();
            }
         }
         else
         {
            this.boostSnd.stop(this.boostLink);
         }
         if(this.isScreechOn)
         {
            this.screechSnd.stop(this.screechLink);
            this.screechSnd.start();
         }
      }
      this.oldRPM = rpm;
      this.sndSeed = this.sndSeed + 1;
   }
   function playGearSound()
   {
      this.gearSnd.start();
   }
   function playNitrousSound()
   {
      if(!this.isNitrousOn)
      {
         this.nitrousSnd.start(0,100);
         this.isNitrousOn = true;
      }
   }
   function stopNitrousSound()
   {
      if(this.isNitrousOn)
      {
         this.nitrousSnd.stop(this.nitrousLink);
         this.nitrousReleaseSnd.start();
         this.isNitrousOn = false;
      }
   }
   function playNitrousReleaseSound()
   {
      this.nitrousReleaseSnd.start();
   }
   function stopSound()
   {
      this.revUpSnd.stop();
      this.revDownSnd.stop();
      this.gearSnd.stop();
      this.boostSnd.stop();
      this.nitrousSnd.stop();
      this.nitrousReleaseSnd.stop();
      this.bovSnd.stop();
   }
   function updateScreech(isOn)
   {
      this.isScreechOn = isOn;
   }
   function soundFadeIn()
   {
      _global.clearTimeout(classes.RaceSound.volumeSI);
      classes.RaceSound.volumeSI = _global.setTimeout(this,"fadeInStep",100);
   }
   function soundFadeOut()
   {
      _global.clearTimeout(classes.RaceSound.volumeSI);
      classes.RaceSound.volumeSI = _global.setTimeout(this,"fadeOutStep",100);
   }
   function fadeInStep()
   {
      var _loc4_ = this.revUpSnd.getVolume();
      var _loc3_;
      if(_loc4_ < 100)
      {
         _loc3_ = Math.min(100,_loc4_ + 10);
         this.revUpSnd.setVolume(_loc3_);
         this.revDownSnd.setVolume(_loc3_);
         this.gearSnd.setVolume(_loc3_);
         this.boostSnd.setVolume(_loc3_);
         this.nitrousSnd.setVolume(_loc3_);
         this.nitrousReleaseSnd.setVolume(_loc3_);
         this.bovSnd.setVolume(_loc3_);
         classes.RaceSound.volumeSI = _global.setTimeout(this,"fadeInStep",100);
      }
   }
   function fadeOutStep()
   {
      var _loc4_ = this.revUpSnd.getVolume();
      var _loc3_;
      if(_loc4_ > 0)
      {
         _loc3_ = Math.max(0,_loc4_ - 10);
         this.revUpSnd.setVolume(_loc3_);
         this.revDownSnd.setVolume(_loc3_);
         this.gearSnd.setVolume(_loc3_);
         this.boostSnd.setVolume(_loc3_);
         this.nitrousSnd.setVolume(_loc3_);
         this.nitrousReleaseSnd.setVolume(_loc3_);
         this.bovSnd.setVolume(_loc3_);
         classes.RaceSound.volumeSI = _global.setTimeout(this,"fadeOutStep",100);
      }
   }
   function enableSound()
   {
      this.revUpSnd.setVolume(100);
      this.revDownSnd.setVolume(100);
      this.gearSnd.setVolume(100);
      this.boostSnd.setVolume(100);
      this.nitrousSnd.setVolume(100);
      this.nitrousReleaseSnd.setVolume(100);
      this.bovSnd.setVolume(100);
   }
   function disableSound()
   {
      trace("disableSound!");
      this.revUpSnd.setVolume(0);
      this.revDownSnd.setVolume(0);
      this.gearSnd.setVolume(0);
      this.boostSnd.setVolume(0);
      this.nitrousSnd.setVolume(0);
      this.nitrousReleaseSnd.setVolume(0);
      this.bovSnd.setVolume(0);
   }
   function enableLoadedSounds()
   {
      this.revUpSnd.setVolume(50);
      this.revDownSnd.setVolume(50);
   }
   function disableLoadedSounds()
   {
      trace("disableLoadedSounds");
      this.revUpSnd.setVolume(0);
      this.revDownSnd.setVolume(0);
   }
}
