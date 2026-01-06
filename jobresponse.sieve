require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric", "spamtest"];
require ["fileinto", "imap4flags"];       
/* Do not run on spam */
if allof (
  environment :matches "vnd.proton.spam-threshold" "*",
  spamtest :value "ge" :comparator "i;ascii-numeric" "${1}"
) {
  return;
}

/* Decisions: subjects containing "regarding your application" (exclude rejections) */
if allof (
  anyof (
    header :comparator "i;unicode-casemap" :matches "Subject" [
      "*regarding*your*application*",
      "*An*update*on*your*application*",
      "*Thank*you*for*your*job*application*",
      "*Your*candidacy*update*",
      "*Your*application*to*",
      "*Update*regarding*your*application*"
    ]
  )
) {
    addflag "\\Seen";
    fileinto "Responses";
      /* Choose ONE of the following:
        If you use Folders and want it out of Inbox, keep only fileinto (no keep/stop needed).
        If you use Labels or want a copy to remain in Inbox too, uncomment keep. */
  keep;
  stop;
}