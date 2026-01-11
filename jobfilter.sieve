require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags"];       

/* Do not run this filter on spam */
if allof (
  environment :matches "vnd.proton.spam-threshold" "",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
} 

/*  Job application confirmations (EN + DA), Subject-only.
    Uses :matches with wildcards (*) to allow punctuation/extra words.
    Excludes common rejection phrases.
    Proton Sieve doesn’t support body matching.
    @type and
    @comparator matches (i;unicode-casemap)
    */
    if anyof (
  /* Path 1: existing positives minus rejections */
    allof (
      anyof (
     header :comparator "i;unicode-casemap" :matches "Subject" [
      "*Thank*you*for*applying*",
      "*your*application*was*sent*",
      "*Thank*you*for*your*application*",
      "*Thanks*for*applying*",
      "*Application*received*",
      "*Your*application*has*been*received*",
      "*We*have*received*your*application*",
      "*Thank*you*for*your*interest*",
      "*application*submitted*",
      "*has*been*submitted*",
      "*Tak*for*din*ansøgning*",
      "*Tak*for*din*ansogning*",
      "*Mange*tak*for*din*ansøgning*",
      "*Ansøgning*modtaget*",
      "*Din*ansøgning*er*modtaget*",
      "*Vi*har*modtaget*din*ansøgning*",
      "*Tak*for*din*interesse*",
      "*great*that*you’re*interested*",
      "*you*just*applied*"
     ]
      ),
      not anyof (
     header :comparator "i;unicode-casemap" :matches "Subject" [
      "*reject*",
      "*declin*",
      "*unsuccessful*",
      "*unfortunately*",
      "*regret*to*inform*",
      "*not*moving*forward*",
      "*not*proceed*",
      "*another*direction*",
      "*not*selected*",
      "*we*will*not*be*moving*forward*",
      "*afslag*",
      "*desværre*",
      "*desvaerre*",
      "*ikke*gå*videre*",
      "*ikke*ga*videre*",
      "*gået*videre*med*andre*",
      "*gaet*videre*med*andre*",
      "*vi*har*valgt*at*gå*videre*med*andre*",
      "*Regarding*your*application",
      "*ikke*kommet*i*betragtning*"
     ]
      )
        ),

/* Path 2: OR group — from noreply@thehub.io AND subject contains “Your application for” */
  allof (
    address :comparator "i;unicode-casemap" :is "from" "noreply@thehub.io",
    header  :comparator "i;unicode-casemap" :contains "Subject" "Your application for"
    /* If you prefer wildcard matching:
       header :comparator "i;unicode-casemap" :matches "Subject" "*Your*application*for*" */
  )


    ) {
    addflag "\\Seen";
    fileinto "Confirmations";
      /* Choose ONE of the following:
        If you use Folders and want it out of Inbox, keep only fileinto (no keep/stop needed).
        If you use Labels or want a copy to remain in Inbox too, uncomment keep. */
  keep;
  stop;
        }
         
