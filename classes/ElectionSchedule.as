class classes.ElectionSchedule
{
   var votingRounds;
   static var PROMO_PHASE = 1;
   static var NOMINATION_PHASE = 2;
   static var NOMINATION_COUNT_PHASE = 3;
   static var BREAK_1 = 4;
   static var PRE_INTERVIEW_PHASE_1 = 5;
   static var INTERVIEW_PHASE_1 = 6;
   static var VOTING_PHASE_1 = 7;
   static var VOTING_COUNT_PHASE_1 = 8;
   static var BREAK_2 = 9;
   static var PRE_INTERVIEW_PHASE_2 = 10;
   static var INTERVIEW_PHASE_2 = 11;
   static var VOTING_PHASE_2 = 12;
   static var VOTING_COUNT_PHASE_2 = 13;
   static var BREAK_3 = 14;
   static var PRE_INTERVIEW_PHASE_3 = 15;
   static var INTERVIEW_PHASE_3 = 16;
   static var VOTING_PHASE_3 = 17;
   static var VOTING_COUNT_PHASE_3 = 18;
   static var ELECTION_OVER = 19;
   function ElectionSchedule()
   {
      this.votingRounds = new Array();
   }
}
