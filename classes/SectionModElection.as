class classes.SectionModElection extends classes.SectionClip
{
   var _amountOfVotes;
   var _bubblePositionObject;
   var _candidateStripColor;
   var _dropDownMenu;
   var _electionList;
   var _electionSchedule;
   var _isInterviewRoom;
   var _numNomsRemaining;
   var _parent;
   var _secsRemaining;
   var _spectatorStripColor;
   var btnCandidate;
   var btnSpectator;
   var cid;
   var countdownIntervalID;
   var cover;
   var createEmptyMovieClip;
   var cy;
   var electionContent;
   var electionInterviewText;
   var electionTitleText;
   var enabled;
   var fldCandidate;
   var fldSpectator;
   var getNextHighestDepth;
   var gotoAndStop;
   var intervalIDs;
   var interviewRoom;
   var nominationClosedText;
   var nominationContent;
   var nominationResultText;
   var nominationText;
   var phaseIntervalID;
   var promoText;
   var scrollerContent;
   var scrollerObj;
   var stop;
   var stripGroup;
   var userList;
   var userListVoting;
   var votingClosedText;
   static var MC;
   var _intervieweeListVSpace = 30;
   function SectionModElection()
   {
      super();
      trace("SectionModElection Constructor");
      _global.electionChatRoom = true;
      classes.SectionModElection.MC = this;
      this.stop();
      _root.getElectionSchedule();
   }
   function doPromotion(timeRemaining)
   {
      trace("doPromotion");
      this.gotoAndStop("Promotion");
      this.fillPromoDates();
   }
   function takeElectionSchedule(electionSchedule)
   {
      trace("takeElectionSchedule");
      trace(electionSchedule.currentDate);
      this._electionSchedule = electionSchedule;
      trace(this._electionSchedule.currentDate);
      classes.Lookup.addCallback("setElectionPhase",this,this.setElectionPhase,"1");
      _root.getElectionPhase(1);
   }
   function phaseExpired()
   {
      trace("phaseExpired!");
      this.cleanUp();
      classes.Lookup.addCallback("setElectionPhase",classes.SectionModElection.MC,classes.SectionModElection.MC.setElectionPhase,"1");
      _root.getElectionPhase(1);
      _root.displayAlert("warningtriangle","Phase Expired","This phase of the election has expired. Press ok to see the next phase");
   }
   function setElectionPhase(argObj)
   {
      var _loc3_ = argObj.phase;
      var _loc2_ = argObj.secsRemaining;
      var _loc5_ = argObj.activeElection;
      classes.Control.setMapButton("modElection");
      trace("setting interval");
      trace(_loc2_);
      trace(_loc2_ * 1000);
      this._secsRemaining = _loc2_;
      this.phaseIntervalID = setInterval(this,"phaseExpired",_loc2_ * 1000);
      this._electionSchedule.currentPhase = _loc3_;
      if(_loc5_ != 1)
      {
         this.showNoElection();
      }
      else
      {
         switch(_loc3_)
         {
            case classes.ElectionSchedule.PROMO_PHASE:
               this.doPromotion();
               break;
            case classes.ElectionSchedule.NOMINATION_PHASE:
               this.doNomination();
               break;
            case classes.ElectionSchedule.NOMINATION_COUNT_PHASE:
               this.doNominationCount();
               break;
            case classes.ElectionSchedule.BREAK_1:
            case classes.ElectionSchedule.BREAK_2:
            case classes.ElectionSchedule.BREAK_3:
               this.doNominationResult();
               break;
            case classes.ElectionSchedule.PRE_INTERVIEW_PHASE_1:
            case classes.ElectionSchedule.INTERVIEW_PHASE_1:
               clearInterval(this.phaseIntervalID);
               this._electionSchedule.currentRound = 1;
               this.doInterview();
               break;
            case classes.ElectionSchedule.VOTING_PHASE_1:
               this._electionSchedule.currentRound = 1;
               this.doVoting();
               break;
            case classes.ElectionSchedule.VOTING_COUNT_PHASE_1:
               this._electionSchedule.currentRound = 1;
               this.doVotingCount();
               break;
            case classes.ElectionSchedule.PRE_INTERVIEW_PHASE_2:
            case classes.ElectionSchedule.INTERVIEW_PHASE_2:
               clearInterval(this.phaseIntervalID);
               this._electionSchedule.currentRound = 2;
               this.doInterview();
               break;
            case classes.ElectionSchedule.VOTING_PHASE_2:
               this._electionSchedule.currentRound = 2;
               this.doVoting();
               break;
            case classes.ElectionSchedule.VOTING_COUNT_PHASE_2:
               this._electionSchedule.currentRound = 2;
               this.doVotingCount();
               break;
            case classes.ElectionSchedule.PRE_INTERVIEW_PHASE_3:
            case classes.ElectionSchedule.INTERVIEW_PHASE_3:
               clearInterval(this.phaseIntervalID);
               this._electionSchedule.currentRound = 3;
               this.doInterview();
               break;
            case classes.ElectionSchedule.VOTING_PHASE_3:
               this._electionSchedule.currentRound = 3;
               this.doVoting();
               break;
            case classes.ElectionSchedule.VOTING_COUNT_PHASE_3:
               this._electionSchedule.currentRound = 3;
               this.doVotingCount();
               break;
            case classes.ElectionSchedule.ELECTION_OVER:
               clearInterval(this.phaseIntervalID);
               this.doNominationResult();
            default:
               return;
         }
      }
   }
   function fillPromoDates()
   {
      this.promoText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      this.promoText.txtNominations.text = this._electionSchedule.nomDates;
      this.promoText.txtEliminations.text = this._electionSchedule.eliminationDates;
      this.promoText.txtFinalVote.text = this._electionSchedule.finalVoteDates;
   }
   function doNomination()
   {
      trace("doNomination");
      this.gotoAndStop("Nomination"); //unpopped
      this.nominationContent.stop();
      this.nominationContent._visible = false;
      this.nominationText._visible = false;
      _root.getNominateCount();
   }
   function takeNomsRemaining(numNomsRemaining)
   {
      this._numNomsRemaining = numNomsRemaining;
      trace("takeNomsRemaining: " + this._numNomsRemaining);
   }
   function startNomination()
   {
      trace("startNomination");
      if(this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo)
      {
         trace("Removing UserInfo!");
         this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo.removeMovieClip();
      }
      this.nominationContent.txtWelcome._visible = true;
      var _loc9_ = classes.GlobalData.attr;
      trace("isMember: " + classes.GlobalData.attr.mb);
      this.nominationText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      var _loc5_ = this._electionSchedule.nomDates.split(" ");
      var _loc6_ = _loc5_[0].substr(0,3);
      var _loc4_ = _loc6_.toUpperCase() + " " + _loc5_[1];
      trace("nom dates!: " + _loc4_);
      this.nominationText.txtNominationDates.text = _loc4_;
      var _loc2_ = this._electionSchedule.votingRounds[1].interviewEnd;
      var _loc7_ = _loc2_.getMonth();
      var _loc3_ = classes.NumFuncs.monthName(_loc7_);
      trace(_loc3_ + " " + _loc2_.getDate());
      var _loc8_ = _loc3_.substr(0,3);
      this._electionSchedule.eliminationBeginsShortenedDate = _loc8_ + " " + _loc2_.getDate();
      this._electionSchedule.eliminationBeginsFullDate = _loc3_ + " " + _loc2_.getDate();
      this.nominationText.txtElimationRoundVoting.text = "ELIMINATION ROUND VOTING BEGINS " + this._electionSchedule.eliminationBeginsShortenedDate.toUpperCase();
      this.nominationContent._visible = true;
      this.nominationText._visible = true;
      if(Number(classes.GlobalData.attr.mb) == 0)
      {
         trace("going to NomNotEligible");
         this.nominationContent.nomUserBoxMovie._visible = false;
         this.nominationContent.gotoAndStop("NomNotEligible");
         this.fillUser(false);
      }
      else if(this._numNomsRemaining == 0)
      {
         trace("going to NoNomsLeft");
         this.nominationContent.nomUserBoxMovie._visible = false;
         this.nominationContent.gotoAndStop("NoNomsLeft");
         this.nominationContent.noNomsLeftBox.txtCheckBack.text = "Be sure to check back on " + this._electionSchedule.eliminationBeginsFullDate + "th and vote for your favorite candidates when the election elimination process begins.";
         this.fillUser(false);
      }
      else
      {
         trace("going to NomSearchUser");
         this.nominationContent.gotoAndStop("NomSearchUser");
         this.nominationContent.nomUserBoxMovie._visible = true;
         this.nominationContent.nomUserBoxMovie.gotoAndStop("SearchUser");
         this.fillUser(true);
         this.addDropDownSearch();
      }
   }
   function takeNominationResult(s, e)
   {
      this.nominationContent.nomUserBoxMovie._visible = true;
      this._dropDownMenu.destroy();
      this.nominationContent.gotoAndStop("NomSearchUser");
      if(s == 1)
      {
         this.showNominateSuccess();
      }
      else
      {
         this.showNominateFailure(e);
      }
   }
   function showNominateSuccess()
   {
      trace("showNominateSuccess");
      this._numNomsRemaining = this._numNomsRemaining - 1;
      this.nominationContent.nomUserBoxMovie.gotoAndStop("NomSuccess");
      this.listenForOK(this.nominationContent.nomUserBoxMovie.nomPlayerNominatedBox.btnOK);
   }
   function showNominateFailure(message)
   {
      trace("showNominateFailure");
      this.nominationContent.nomUserBoxMovie.gotoAndStop("NomPlayerNotNominated");
      this.nominationContent.nomUserBoxMovie.nomPlayerNotNominatedBox.txtError.text = message;
      this.listenForOK(this.nominationContent.nomUserBoxMovie.nomPlayerNotNominatedBox.btnOK);
   }
   function listenForOK(okButton)
   {
      okButton.onRelease = function()
      {
         trace("btnOK released!!!!");
         classes.SectionModElection.MC.startNomination();
      };
   }
   function textEnteredInSearchBox()
   {
      trace("textEnteredInSearchBox");
      this.disallowNominate();
   }
   function addDropDownSearch()
   {
      trace("addDropDownSearch");
      this._dropDownMenu = new classes.ui.UserSearchDropDown(this.nominationContent.nomUserBoxMovie,"ddUserSearchBase","Arial","Arial",196,19.6,false,241,19.6,this,"1");
      this._dropDownMenu.x = 18;
      this._dropDownMenu.y = 75.3;
   }
   function nomineeSelected(uID)
   {
      if(this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo)
      {
         trace("Removing UserInfo!");
         this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo.removeMovieClip();
      }
      trace("nomineeSelected");
      this.disallowNominate();
      this._dropDownMenu.enableInput(false);
      this._dropDownMenu.enableSearchResults(false);
      classes.Frame.serverLights(true);
      classes.Lookup.addCallback("getUser",this,this.CB_getUser,String(uID));
      _root.getUser(uID);
   }
   function CB_getUser(d)
   {
      trace("CB_getUser");
      classes.Frame.serverLights(false);
      var _loc2_ = new XML(d);
      var _loc3_ = _loc2_.firstChild.firstChild.attributes.mb;
      trace("member, mod election: " + _loc3_);
      trace("attributes: " + _loc2_.firstChild.firstChild.attributes.mb);
      if(_loc3_ == "False")
      {
         this.selectedUserNotEligible();
      }
      else
      {
         trace("CastNomination");
         trace(this._dropDownMenu);
         this.nominationContent.nomUserBoxMovie.gotoAndStop("CastNomination");
         trace(this._dropDownMenu);
         this.allowNominate();
      }
      this._dropDownMenu.enableInput(true);
      this._dropDownMenu.enableSearchResults(true);
      this.showUser(_loc2_,this.nominationContent.nomUserBoxMovie.userInfoHolder,0,0);
   }
   function selectedUserNotEligible()
   {
      this.nominationContent.nomUserBoxMovie.gotoAndStop("PlayerNotEligible");
   }
   function allowNominate()
   {
      var _loc3_ = new Object();
      this.nominationContent.nomUserBoxMovie.btnNomUser.onRelease = function()
      {
         this.enabled = false;
         trace("cast nomination!");
         trace(this._parent._parent);
         trace(classes.SectionModElection.MC._dropDownMenu);
         trace(classes.SectionModElection.MC._dropDownMenu.currentSelected);
         trace(classes.SectionModElection.MC._dropDownMenu.currentSelected.value);
         _root.nominate(classes.SectionModElection.MC._dropDownMenu.currentSelected.value);
         classes.SectionModElection.MC.nominationContent.nomUserBoxMovie._visible = false;
         classes.SectionModElection.MC.nominationContent.txtWelcome._visible = false;
         this._parent._parent.gotoAndStop("NomProcessing");
      };
      trace("btnNomUser");
      trace(this.nominationContent.nomUserBoxMovie.btnNomUser);
      this.nominationContent.nomUserBoxMovie.btnNomUser.enabled = true;
   }
   function disallowNominate()
   {
      trace("disallowNominate!");
      if(this.nominationContent.nomUserBoxMovie.btnNomUser)
      {
         trace("btnNomUser.enabled set to false");
         trace(this.nominationContent.nomUserBoxMovie.btnNomUser);
         this.nominationContent.nomUserBoxMovie.btnNomUser.enabled = false;
      }
   }
   function showUser(viewXML, context, x, y)
   {
      var _loc13_ = viewXML.firstChild.firstChild.attributes.i;
      var _loc3_ = Number(viewXML.firstChild.firstChild.attributes.ti);
      var _loc4_ = viewXML.firstChild.firstChild.attributes.tn;
      var _loc10_ = viewXML.firstChild.firstChild.attributes.u;
      var _loc6_ = viewXML.firstChild.firstChild.attributes.sc;
      trace("nominationContent: " + this.nominationContent + " - " + this.nominationContent.nomUserBoxMovie + " - " + this.nominationContent.nomUserBoxMovie.userInfo);
      var _loc11_ = context.attachMovie("userInfo","userInfo",context.getNextHighestDepth(),{_x:x,_y:y,uID:_loc13_,uName:_loc10_,tID:_loc3_,tName:_loc4_,uCred:_loc6_,showBadgesXML:new XML(viewXML.firstChild.firstChild.toString())});
   }
   function cantNomNotMember()
   {
      this.nominationContent._visible = true;
      this.nominationText._visible = true;
   }
   function fillUser(showNomsLeft)
   {
      this.nominationContent.txtWelcome.text = "Welcome " + classes.GlobalData.attr.u + ", ";
      var _loc2_;
      if(showNomsLeft == true)
      {
         _loc2_ = " nominations left.";
         if(this._numNomsRemaining == 1)
         {
            _loc2_ = " nomination left.";
         }
         this.nominationContent.txtWelcome.text += "you have " + this._numNomsRemaining + _loc2_;
      }
   }
   function fillNomsLeft()
   {
      trace("fillNomsLeft");
      trace(this._numNomsRemaining);
      this.nominationContent.txtNomsLeft.text = "you have " + this._numNomsRemaining + " nominations left.";
   }
   function fillNominationInfo()
   {
      this.nominationText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      this.nominationText.txtNominationDates.text = this._electionSchedule.nomDates;
      this.nominationText.txtElimationRoundVoting.text = "Elimination Round Voting Begins Nov 15th";
      this.nominationText._visible = true;
   }
   function doNominationCount()
   {
      trace("doNominationCount");
      this.gotoAndStop("NominationPreAnnounce"); //unpopped
      this.nominationClosedText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      trace(this._electionSchedule.nomAnnounceBeg);
      var _loc2_ = classes.NumFuncs.getTimeFormatted(this._electionSchedule.nomAnnounceBeg);
      trace("nomAnnounceTime");
      trace(_loc2_);
      this.nominationClosedText.txtNomBeingProcessed.text = "YOUR NOMINATIONS ARE BEING PROCESSED\nTHE TOP 50 WILL BE ANNOUNCED AT " + _loc2_ + ".";
   }
   function doNominationResult()
   {
      trace("doNominationResult");
      this.gotoAndStop("NominationAnnounce"); //unpopped
      trace(this.nominationResultText);
      trace("hello!");
      this.nominationResultText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      this.nominationResultText.txtTop.text = "";
      var _loc3_ = "";
      var _loc2_;
      if(this._electionSchedule.currentPhase == classes.ElectionSchedule.BREAK_1)
      {
         _loc2_ = this._electionSchedule.votingRounds[1].interviewBeg;
         _loc3_ = "ROUND 1 INTERVIEWS: ";
      }
      else if(this._electionSchedule.currentPhase == classes.ElectionSchedule.BREAK_2)
      {
         _loc2_ = this._electionSchedule.votingRounds[2].interviewBeg;
         _loc3_ = "ROUND 2 INTERVIEWS: ";
      }
      else
      {
         _loc2_ = this._electionSchedule.votingRounds[3].interviewBeg;
         _loc3_ = "ROUND 3 INTERVIEWS: ";
      }
      var _loc6_ = _loc2_.getMonth() + 1;
      var _loc4_ = _loc2_.getDate();
      var _loc5_ = classes.NumFuncs.getTimeFormatted(_loc2_);
      _loc3_ += _loc6_ + "/" + _loc4_ + " " + _loc5_;
      this.nominationResultText.txtInterviewPreview.text = _loc3_;
      if(this._electionSchedule.currentPhase == classes.ElectionSchedule.ELECTION_OVER)
      {
         this.nominationResultText.txtInterviewPreview._visible = false;
         this.nominationResultText.txtTop.text = "YOUR NEW MODERATORS!";
      }
      this.userListVoting = this.createEmptyMovieClip("userListHolder",this.getNextHighestDepth());
      trace(this.userList);
      this.userListVoting._x = 26;
      this.userListVoting._y = 292;
      this.showUserList(-1);
   }
   function takeElectionResult(userListArray)
   {
      if(this._electionSchedule.currentPhase == classes.ElectionSchedule.BREAK_1 || this._electionSchedule.currentPhase == classes.ElectionSchedule.BREAK_2 || this._electionSchedule.currentPhase == classes.ElectionSchedule.BREAK_3)
      {
         classes.SectionModElection.MC.displayUserResults(userListArray,this.racerItemClick);
      }
      else
      {
         classes.SectionModElection.MC.displayUserResults(userListArray,this.racerVoteClick);
      }
   }
   function showUserList(round)
   {
      _root.getElectionResult(round);
   }
   function displayUserResults(userListArray, callbackFunc)
   {
      var _loc7_ = 30;
      if(this._electionSchedule.currentPhase == classes.ElectionSchedule.VOTING_PHASE_1 || this._electionSchedule.currentPhase == classes.ElectionSchedule.VOTING_PHASE_2 || this._electionSchedule.currentPhase == classes.ElectionSchedule.VOTING_PHASE_3)
      {
         _loc7_ = 25;
      }
      var _loc8_ = 155;
      var _loc6_ = Math.ceil(userListArray.length / 5);
      var _loc5_ = 1;
      var _loc3_ = 0;
      trace("nominationClosedText.txtTop");
      trace(this.nominationResultText.txtTop);
      trace(userListArray.length);
      if(this._electionSchedule.currentPhase == classes.ElectionSchedule.ELECTION_OVER)
      {
         this.nominationResultText.txtInterviewPreview._visible = false;
         this.nominationResultText.txtTop.text = "YOUR NEW MODERATORS!";
      }
      else if(this.nominationResultText)
      {
         this.nominationResultText.txtTop.text = "YOUR TOP " + userListArray.length + " NOMINEES!";
      }
      if(_loc6_ < 1)
      {
         _loc6_ = 1;
      }
      trace("countPerColumn");
      trace(_loc6_);
      var _loc2_ = 0;
      while(_loc2_ < userListArray.length)
      {
         if(_loc3_ == _loc6_)
         {
            _loc5_ = _loc5_ + 1;
            _loc3_ = 0;
         }
         trace("currentColumn");
         trace(_loc5_);
         classes.Drawing.userListItem(this.userListVoting,"item" + _loc2_,Number(userListArray[_loc2_].i),String(userListArray[_loc2_].u),_loc8_ * (_loc5_ - 1),_loc3_ * _loc7_,callbackFunc);
         _loc3_ = _loc3_ + 1;
         _loc2_ = _loc2_ + 1;
      }
   }
   function displayIntervieweeList(userListArray)
   {
      if(this.scrollerContent != undefined)
      {
         this.scrollerObj.destroy();
         this.scrollerContent.removeMovieClip();
      }
      this.scrollerContent = this.interviewRoom.interviewListHolder.createEmptyMovieClip("scrollerContent",this.getNextHighestDepth());
      this.scrollerContent.attachMovie("IntervieweeHilite","hilite",this.scrollerContent.getNextHighestDepth());
      this.interviewRoom.interviewListHolder.scrollerContent.hilite._visible = false;
      trace("userListArray length");
      trace(userListArray.length);
      var _loc2_ = 0;
      while(_loc2_ < userListArray.length)
      {
         classes.Drawing.userListItem(this.scrollerContent,"item" + _loc2_,Number(userListArray[_loc2_].i),String(userListArray[_loc2_].u),0,_loc2_ * this._intervieweeListVSpace,null);
         _loc2_ = _loc2_ + 1;
      }
      this.scrollerObj = new controls.ScrollPane(this.scrollerContent,141,515,null,515,127,0);
   }
   function racerItemClick(id)
   {
      trace("racerItemClick: " + id);
      classes.Control.focusViewer(id);
   }
   function racerVoteClick(id)
   {
      trace("userVoteSelected: " + classes.SectionModElection.MC._userVoteSelected);
      if(classes.SectionModElection.MC._userVoteSelected == false)
      {
         trace("racerVoteClick: " + id);
         trace("nomineeSelected");
         if(classes.SectionModElection.MC.electionContent.userInfoHolder.userInfo)
         {
            classes.SectionModElection.MC.electionContent.userInfoHolder.userInfo.removeMovieClip();
         }
         classes.SectionModElection.MC._userVoteSelected = true;
         classes.SectionModElection.MC.electionContent.btnVote.enabled = false;
         classes.SectionModElection.MC._voteForThisGuy = id;
         classes.Frame.serverLights(true);
         classes.Lookup.addCallback("getUser",classes.SectionModElection.MC,classes.SectionModElection.MC.CB_getUserVote,String(id));
         _root.getUser(id);
      }
   }
   function CB_getUserVote(d)
   {
      trace("CB_getUserVote");
      classes.Frame.serverLights(false);
      var _loc2_ = new XML(d);
      var _loc3_ = Number(_loc2_.firstChild.firstChild.attributes.i);
      this.electionContent.gotoAndStop("Vote");
      this.setVoteStuffVisibility(true);
      classes.SectionModElection.MC._userVoteSelected = false;
      this.showUser(_loc2_,this.electionContent.userInfoHolder,0,0);
      this.listenForUserVote();
   }
   function listenForUserVote()
   {
      this.electionContent.btnVote.enabled = true;
      this.electionContent.txtUserInput.restrict = "0-9";
      this.electionContent.btnVote.onRelease = function()
      {
         trace("user pressed vote button!");
         trace(classes.SectionModElection.MC.electionContent.txtUserInput);
         trace(classes.SectionModElection.MC.electionContent.txtUserInput.length);
         trace(Number(classes.SectionModElection.MC.electionContent.txtUserInput.text));
         if(classes.SectionModElection.MC.electionContent.txtUserInput.length > 0 && Number(classes.SectionModElection.MC.electionContent.txtUserInput.text) > 0)
         {
            classes.SectionModElection.MC._userVoteSelected = true;
            classes.SectionModElection.MC._amountOfVotes = Number(classes.SectionModElection.MC.electionContent.txtUserInput.text);
            _root.electionVote(classes.SectionModElection.MC._voteForThisGuy,classes.SectionModElection.MC.electionContent.txtUserInput.text);
            classes.SectionModElection.MC.electionContent.processingMovie._visible = true;
            classes.SectionModElection.MC.setVoteStuffVisibility(false);
         }
      };
   }
   function takeVoteResult(s, message)
   {
      this.electionContent.processingMovie._visible = false;
      this.setVoteStuffVisibility(true);
      if(s == 1)
      {
         this.electionContent.gotoAndStop("VotingSuccess");
         this.electionContent.txtSuccess.text = classes.NumFuncs.commaFormat(this._amountOfVotes) + " ACCEPTED";
      }
      else
      {
         this.electionContent.gotoAndStop("VotingError");
         this.electionContent.txtError.text = message;
      }
      this.electionContent.btnOK.onRelease = function()
      {
         classes.SectionModElection.MC.electionContent.userInfoHolder.userInfo.removeMovieClip();
         classes.SectionModElection.MC.setupVoting();
      };
   }
   function setVoteStuffVisibility(visible)
   {
      classes.SectionModElection.MC.electionContent.voteMovie._visible = visible;
      classes.SectionModElection.MC.electionContent.userInfoHolder._visible = visible;
      classes.SectionModElection.MC.electionContent.txtUserInput._visible = visible;
      classes.SectionModElection.MC.electionContent.btnVote._visible = visible;
   }
   function timeCountdown()
   {
      this._secsRemaining = this._secsRemaining - 1;
      this.fillInTimeRemaining();
   }
   function fillInTimeRemaining()
   {
      this.electionTitleText.txtTimeRemaining.text = "TIME REMAINING: " + classes.NumFuncs.formatSecs(this._secsRemaining);
   }
   function doVoting()
   {
      this.countdownIntervalID = setInterval(this,"timeCountdown",1000);
      this.fillInTimeRemaining();
      this.setupVoting();
   }
   function setupVoting()
   {
      trace("doVoting");
      this.gotoAndStop("Election"); //unpopped
      this.electionContent.gotoAndStop("SelectCandidate");
      this.electionContent.processingMovie._visible = false;
      trace(this.electionContent);
      trace(this.electionContent.txtWelcome);
      this.electionContent.txtWelcome.text = "Welcome " + classes.GlobalData.attr.u + ", ";
      this.electionTitleText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      this.electionTitleText.txtRoundVoting.text = "ROUND " + this._electionSchedule.currentRound + " VOTING";
      classes.SectionModElection.MC._userVoteSelected = false;
      trace("going to vote");
      trace(this.userListVoting);
      this.electionContent.gotoAndStop("SelectCandidate");
      if(this.userListVoting == null)
      {
         trace("creating a new user list");
         this.userListVoting = this.createEmptyMovieClip("userListHolder",this.getNextHighestDepth());
         trace(this.userListVoting);
         this.userListVoting._x = 26;
         this.userListVoting._y = 341;
         this.showUserList(-2);
      }
   }
   function doInterview()
   {
      trace("doInterview");
      this.gotoAndStop("ElectionMenu"); //unpopped
      classes.Control.setMapButton("modElection");
      this.intervalIDs = new Object();
      this.electionInterviewText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      this.electionInterviewText.txtRound.text = "ROUND " + this._electionSchedule.currentRound;
      var _loc3_ = classes.NumFuncs.getTimeFormatted(this._electionSchedule.votingRounds[this._electionSchedule.currentRound].interviewEnd);
      trace("voting begins");
      trace(this._electionSchedule.votingRounds[this._electionSchedule.currentRound].interviewEnd.getHours());
      this.electionInterviewText.txtVotingBegins.text = "VOTING BEGINS AT " + _loc3_;
      this.stripGroup._visible = false;
      this.stripGroup.gotoAndStop(1);
      this._spectatorStripColor = new Color(this.fldSpectator);
      this._candidateStripColor = new Color(this.fldCandidate);
      this.btnSpectator.onRollOver = function()
      {
         trace("btnSpectator RollOver");
         classes.SectionModElection.MC._spectatorStripColor.setRGB(16777215);
      };
      this.btnCandidate.onRollOver = function()
      {
         classes.SectionModElection.MC._candidateStripColor.setRGB(16777215);
      };
      this.btnSpectator.onRollOut = function()
      {
         trace("btnSpectator Roll Out");
         trace(this.stripGroup._visible);
         if(classes.SectionModElection.MC.stripGroup._visible == false)
         {
            trace("setting color back to black!");
            classes.SectionModElection.MC._spectatorStripColor.setRGB(4473924);
         }
      };
      this.btnCandidate.onRollOut = function()
      {
         classes.SectionModElection.MC._candidateStripColor.setRGB(4473924);
      };
      this.btnSpectator.onRelease = function()
      {
         trace("btnSpectator Pressed");
         classes.SectionModElection.MC.stripGroup.idx = 10;
         classes.SectionModElection.MC.stripGroup._visible = true;
         classes.SectionModElection.MC._spectatorStripColor.setRGB(16777215);
         classes.SectionModElection.MC.stripGroup.gotoAndPlay("showMe");
      };
      this.btnCandidate.onRelease = function()
      {
         trace("btnCandidate Pressed");
         classes.SectionModElection.MC.enterRaceWaitRoom(10);
         _root.JoinElection();
      };
   }
   function enterRaceWaitRoom(type)
   {
      trace("enterRaceWaitRoom!");
      this.gotoAndStop("ElectionMenuWait");
      this.cover.useHandCursor = false;
   }
   function clearWait()
   {
      this.gotoAndStop("ElectionMenu");
   }
   function enterRaceRoom(pcid, pcy, type, roomName, isPriv, isMem, asInvisible)
   {
      trace("enterRaceRoom");
      trace(pcid);
      _global.newRoomName = roomName;
      this.cid = pcid;
      this.cy = pcy;
      if(isPriv == 1)
      {
         _root.attachMovie("dialogContainer","abc",_root.getNextHighestDepth(),{contentName:"dialogPrivateRoomContent",typeID:type,roomID:this.cid,roomName:roomName,asInvisible:asInvisible});
      }
      else
      {
         this.enterRaceWaitRoom(type);
         _root.chatJoin(5,this.cid,"",asInvisible);
      }
   }
   function showRaceRoom(isInterviewRoom)
   {
      var _loc3_;
      this._isInterviewRoom = isInterviewRoom;
      trace("show race room!");
      _global.chatObj = new Object();
      this.gotoAndStop("ElectionInterview"); //unpopped
      classes.Control.setMapButton("modInterview");
      this.interviewRoom.chatWindowInterview.tf.text = "";
   }
   function takeInterviewList(d)
   {
      var _loc3_ = new XML(d);
      var _loc2_ = new Object();
      _loc2_.ji1 = _loc3_.firstChild.attributes.ji1;
      _loc2_.ju1 = _loc3_.firstChild.attributes.ju1;
      _loc2_.ji2 = _loc3_.firstChild.attributes.ji2;
      _loc2_.ju2 = _loc3_.firstChild.attributes.ju2;
      _loc2_.ji3 = _loc3_.firstChild.attributes.ji3;
      _loc2_.ju3 = _loc3_.firstChild.attributes.ju3;
      trace(_loc2_.ji1);
      trace("take interview list: " + _loc2_.ju1);
      this._electionList = _loc2_;
      this.interviewRoom.judgeDisplay.txtJudge1.autoSize = "center";
      this.interviewRoom.judgeDisplay.txtJudge2.autoSize = "center";
      this.interviewRoom.judgeDisplay.txtJudge3.autoSize = "center";
      trace(_loc2_.ju1);
      trace(_loc2_.ju2);
      trace(_loc2_.ju3);
      this.interviewRoom.judgeDisplay.txtJudge1.text = _loc2_.ju1;
      this.interviewRoom.judgeDisplay.txtJudge2.text = _loc2_.ju2;
      this.interviewRoom.judgeDisplay.txtJudge3.text = _loc2_.ju3;
      classes.Drawing.portrait(this.interviewRoom.judgeDisplay.judgeHolder1,_loc2_.ji1,1,0,0,2);
      classes.Drawing.portrait(this.interviewRoom.judgeDisplay.judgeHolder2,_loc2_.ji2,1,0,0,2);
      classes.Drawing.portrait(this.interviewRoom.judgeDisplay.judgeHolder3,_loc2_.ji3,1,0,0,2);
      this.interviewRoom.judgeDisplay.judgeHolder1._xscale = this.interviewRoom.judgeDisplay.judgeHolder1._yscale = 50;
      this.interviewRoom.judgeDisplay.judgeHolder2._xscale = this.interviewRoom.judgeDisplay.judgeHolder2._yscale = 50;
      this.interviewRoom.judgeDisplay.judgeHolder3._xscale = this.interviewRoom.judgeDisplay.judgeHolder3._yscale = 50;
      this._bubblePositionObject = new Object();
      this._bubblePositionObject.candidate = new Object();
      this._bubblePositionObject.candidate.x = this.interviewRoom.tgtCandidate._x;
      this._bubblePositionObject.candidate.y = this.interviewRoom.tgtCandidate._y;
      this._bubblePositionObject.candidate.t = "C";
      this._bubblePositionObject[_loc2_.ju1] = new Object();
      this._bubblePositionObject[_loc2_.ju1].x = this.interviewRoom.tgtJudge1._x;
      this._bubblePositionObject[_loc2_.ju1].y = this.interviewRoom.tgtJudge1._y;
      this._bubblePositionObject[_loc2_.ju1].t = "1";
      this._bubblePositionObject[_loc2_.ju2] = new Object();
      this._bubblePositionObject[_loc2_.ju2].x = this.interviewRoom.tgtJudge2._x;
      this._bubblePositionObject[_loc2_.ju2].y = this.interviewRoom.tgtJudge2._y;
      this._bubblePositionObject[_loc2_.ju2].t = "2";
      this._bubblePositionObject[_loc2_.ju3] = new Object();
      this._bubblePositionObject[_loc2_.ju3].x = this.interviewRoom.tgtJudge3._x;
      this._bubblePositionObject[_loc2_.ju3].y = this.interviewRoom.tgtJudge3._y;
      this._bubblePositionObject[_loc2_.ju3].t = "3";
      trace("name!: ");
      trace(this._bubblePositionObject.Shimrod);
      trace(_loc2_.ju3);
      this.takeIntervieweeList(_loc3_);
   }
   function takeIntervieweeList(rXML)
   {
      var _loc3_ = new Array();
      var _loc6_ = rXML.firstChild.childNodes.length;
      this._electionList.current = rXML.firstChild.attributes.cur;
      var _loc2_ = 0;
      while(_loc2_ < _loc6_)
      {
         _loc3_.push(new Object({i:rXML.firstChild.childNodes[_loc2_].attributes.i,u:rXML.firstChild.childNodes[_loc2_].firstChild}));
         trace(_loc3_[_loc2_].i);
         _loc2_ = _loc2_ + 1;
      }
      this._electionList.interviewees = _loc3_;
      if(this.userList)
      {
         this.userList.removeMovieClip();
      }
      this.userList = this.interviewRoom.createEmptyMovieClip("userListHolder",this.getNextHighestDepth());
      trace(this.userList);
      this.userList._x = 26;
      this.userList._y = 292;
      this.displayIntervieweeList(this._electionList.interviewees);
      trace("electionList.current");
      trace(this._electionList.current);
      if(Number(this._electionList.current) != -1)
      {
         this.displayCurrentInterviewee();
      }
   }
   function isJudge(username)
   {
      var _loc3_;
      _loc3_ = false;
      trace(username);
      trace(this._electionList.ju1);
      if(this._electionList.ju1 == username || this._electionList.ju2 == username || this._electionList.ju3 == username)
      {
         _loc3_ = true;
      }
      return _loc3_;
   }
   function isInterviewee(username)
   {
      var _loc4_;
      _loc4_ = false;
      trace("isInterviewee");
      trace(username);
      trace(this._electionList.interviewees.length);
      var _loc2_ = 0;
      while(_loc2_ < this._electionList.interviewees.length)
      {
         trace("username");
         trace(this._electionList.interviewees[_loc2_].u);
         trace(username.length);
         trace(String(this._electionList.interviewees[_loc2_].u).length);
         if(String(this._electionList.interviewees[_loc2_].u) == username)
         {
            trace("true!");
            _loc4_ = true;
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
      return _loc4_;
   }
   function takeNewInterviewee(accountID)
   {
      this._electionList.current = accountID;
      this.displayCurrentInterviewee();
   }
   function interviewOver()
   {
      this.removeBubble("C");
      this.interviewRoom.interviewListHolder.scrollerContent.hilite._visible = false;
      if(this.interviewRoom.userInfoHolder.userInfo)
      {
         this.interviewRoom.userInfoHolder.userInfo.removeMovieClip();
      }
   }
   function displayCurrentInterviewee()
   {
      trace("displayCurrentInterviewee");
      this.hiliteCurrentInterviewee();
      this.removeBubble("C");
      if(this.interviewRoom.userInfoHolder.userInfo)
      {
         this.interviewRoom.userInfoHolder.userInfo.removeMovieClip();
      }
      classes.Lookup.addCallback("getUser",this,this.CB_getUserInterview,this._electionList.current);
      _root.getUser(this._electionList.current);
   }
   function hiliteCurrentInterviewee()
   {
      trace("hiliteCurrentInterviewee");
      this.interviewRoom.interviewListHolder.scrollerContent.hilite._visible = true;
      var _loc2_ = 0;
      while(_loc2_ < this._electionList.interviewees.length)
      {
         trace(this.interviewRoom.intervieweeHilite.interviewListHolder.scrollerContent.hilite);
         if(this._electionList.interviewees[_loc2_].i == this._electionList.current)
         {
            trace("found it!");
            this.interviewRoom.interviewListHolder.scrollerContent.hilite._x = -8;
            this.interviewRoom.interviewListHolder.scrollerContent.hilite._y = this._intervieweeListVSpace * _loc2_ - 3;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function CB_getUserInterview(d)
   {
      trace("CB_getUserInterview");
      var _loc2_ = new XML(d);
      if(this.interviewRoom.userInfoHolder.userInfo)
      {
         this.interviewRoom.userInfoHolder.userInfo.removeMovieClip();
      }
      this.showUser(_loc2_,this.interviewRoom.userInfoHolder,0,0);
   }
   function displayElectionInterviewMessage(username, msg)
   {
      trace("displayElectionInterviewMessage");
      var _loc2_ = username;
      if(this.isJudge(username) != true)
      {
         _loc2_ = "candidate";
      }
      trace(_loc2_);
      this.displayBubbleText(_loc2_,msg);
      classes.InterviewChat.addToHistory(null,username,classes.data.Profanity.filterString(msg));
   }
   function castCheerVote(type)
   {
      trace("SectionModElection::castCheerVote: " + type);
      _root.chatCheerVote(type,this._electionList.current);
   }
   function displayBubbleText(name, msg)
   {
      trace("display bubble text");
      trace(name);
      var _loc2_;
      trace("bubblePositionObject: " + this._bubblePositionObject);
      for(_loc2_ in this._bubblePositionObject)
      {
         trace("i = " + _loc2_ + " : " + this._bubblePositionObject[_loc2_].t);
      }
      trace(this._bubblePositionObject[name]);
      var _loc4_ = this.interviewRoom;
      var _loc6_ = _loc4_.getNextHighestDepth();
      var _loc5_ = {txt:msg,ww:200,u:name,t:this._bubblePositionObject[name].t,x:this._bubblePositionObject[name].x,y:this._bubblePositionObject[name].y};
      if(name == "candidate")
      {
         _loc5_.ww = 400;
      }
      this.removeBubble(this._bubblePositionObject[name].t);
      var _loc10_ = _loc4_.attachMovie("electionBubble","racer" + this._bubblePositionObject[name].t + "Bubble",_loc6_,_loc5_);
      this.intervalIDs[this._bubblePositionObject[name].t] = setInterval(this,"removeBubble",5000,this._bubblePositionObject[name].t);
   }
   function clearAllIntervals()
   {
      trace("clearAllIntervals");
      var _loc2_;
      for(_loc2_ in this.intervalIDs)
      {
         trace("i = " + _loc2_ + " : " + this.intervalIDs[_loc2_]);
         clearInterval(this.intervalIDs[_loc2_]);
      }
      trace("phaseIntervalID: " + this.phaseIntervalID);
      clearInterval(this.phaseIntervalID);
      clearInterval(this.countdownIntervalID);
   }
   function cleanUp()
   {
      trace("cleanUp");
      this.clearAllIntervals();
      trace(this);
      trace(this.nominationContent);
      trace(this.nominationContent.nomUserBoxMovie);
      trace(this.nominationContent.nomUserBoxMovie.userInfoHolder);
      trace(this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo);
      if(this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo)
      {
         trace("Removing UserInfo!");
         this.nominationContent.nomUserBoxMovie.userInfoHolder.userInfo.removeMovieClip();
      }
      if(this.scrollerContent)
      {
         this.scrollerObj.destroy();
         this.scrollerContent.removeMovieClip();
      }
      if(this.electionContent.userInfoHolder.userInfo)
      {
         this.electionContent.userInfoHolder.userInfo.removeMovieClip();
      }
      if(this._dropDownMenu)
      {
         this._dropDownMenu.destroy();
      }
      if(this.userList)
      {
         this.userList.removeMovieClip();
      }
      if(this.userListVoting)
      {
         this.userListVoting.removeMovieClip();
      }
      if(this.interviewRoom.userInfoHolder.userInfo)
      {
         this.interviewRoom.userInfoHolder.userInfo.removeMovieClip();
      }
   }
   function removeBubble(objType)
   {
      trace("removeBubble");
      trace(objType);
      trace(this.interviewRoom);
      trace(this.interviewRoom["racer" + objType + "Bubble"]);
      if(this.interviewRoom["racer" + objType + "Bubble"])
      {
         this.interviewRoom["racer" + objType + "Bubble"].removeMovieClip();
      }
      clearInterval(this.intervalIDs[objType]);
      this.intervalIDs[objType] = null;
   }
   function doVotingCount()
   {
      trace("doVotingCount");
      this.gotoAndStop("VotingClosed");
      this.votingClosedText.txtQuarter.text = "Q" + this._electionSchedule.quarter;
      var _loc2_ = classes.NumFuncs.getTimeFormatted(this._electionSchedule.votingRounds[this._electionSchedule.currentRound].votingResults);
      this.votingClosedText.txtResults.text = "RESULTS WILL BE ANNOUNCED TONIGHT AT " + _loc2_;
   }
   function doElectionOver()
   {
      trace("doElectionOver");
   }
   function showNoElection()
   {
      this.gotoAndStop("NoElection");
   }
}
