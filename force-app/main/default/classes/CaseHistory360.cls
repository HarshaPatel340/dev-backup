public class CaseHistory360 {
    
    public transient List <CaseHistoryItem> CHIlist            {get; set;}
    public List<Case> Cases                         {get; set;}
    public transient List<CaseHistory> Histories              {get; set;}
    public transient List  <Case_Note__c> Notes                 {get; set;}
    public transient List<CaseSolution> Articles              {get; set;}
    public transient List<CaseArticle> caseArticles           {get; set;}
    public transient List<Solution_Detail__c> Solutions       {get; set;}
    //public transient List<Task> tasks                         {get; set;}
    public transient List<Case_Attachment__c> Attachments     {get;set;}
    public transient List<EmailMessage> Emails                {get; set;}
    public transient List<Chirp_Ticket__c> Chirps             {get; set;}
    public String caseID                            {get; set;}
    public Case aCase                               {get; set;}
    public transient Set<String> prefixSet                    {get; set;}
    private map<Id, KnowledgeArticleVersion> kavMap = new map<Id, KnowledgeArticleVersion>();
    public string URLred {get; set;}
    public List<KnowledgeArticleVersion> kavList {get;set;}
    
    public transient Map<Id,KnowledgeArticleVersion> articleMap {get;set;}
    public boolean displayPopup {get; set;}
    public CaseHistory360(){
        
        CHIlist= new List<CaseHistoryItem>();//added by ashwith
        caseId = Apexpages.currentPage().getParameters().get('id');
        URLred = URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix();
		        
        displayPopup = true;
        Cases = [Select Id, CaseNumber,Case_Record__c,Module__c,Functional_Area__c From Case Where Id =:caseId Limit 1];
        aCase = cases[0];
        Histories = [Select Id, CreatedById, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue, Case.Status From CaseHistory Where CaseId = :caseId AND Field != 'Escalated_Tier_2__c'];
        Notes = [Select Id, Article_Id__c, CreatedById, CreatedBy.Name, CreatedDate, Details__c, Type__c, Has_Attachment__c, Article__c, Article__r.SolutionName, Article__r.SolutionNumber, Is_Email__c, Public__c, From_Type__c, Incoming_Outgoing__c From Case_Note__c Where Case__c = :caseId AND (Incoming_Outgoing__c != 'Incoming' OR (Incoming_Outgoing__c = 'Incoming' AND Type__c = 'BTBB Comment')OR (Incoming_Outgoing__c = 'Incoming' AND isDataload__c = true)) ];
        Emails = [Select Id, CreatedById, CreatedBy.Name, CreatedDate, TextBody, HTMLBody, Subject, FromName, ToAddress, MessageDate, hasAttachment, Incoming, Status, FromAddress From EmailMessage Where ParentId = :caseId ];
        Attachments = [Select Id, CreatedById, CreatedBy.Name, CreatedDate, File_Name__c, Content_Type__c, Notes__c, Preview_Link__c, Internal_Only_Attachment__c, Case_Note__c, File_Name_w_ext__c,Email_Attachment_link__c  FROM Case_Attachment__c Where Related_to__c = :caseId AND Case_Note__c = null AND Show_on_UI__c = TRUE];
        List<Case_Attachment__c> MigratedAttachment=[Select Id, CreatedById, CreatedBy.Name, CreatedDate, File_Name__c, Content_Type__c, Notes__c, Preview_Link__c, Internal_Only_Attachment__c, Case_Note__c, File_Name_w_ext__c FROM Case_Attachment__c Where Related_to__c = :caseId AND Case_note__r.isDataload__c=true AND Case_Note__c IN :Notes  AND Show_on_UI__c = TRUE];
        Solutions = [Select Id, Name, CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate, Description__c, Comments__c, Subject__c, Status__c, Article__c, Article__r.SolutionNumber, Article__r.SolutionName, Article_Id__c, Article_Number__c, Article_Title__c From Solution_Detail__c Where Case__c = :caseId];
        Chirps = [Select Id, Name, CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate, Subject__c, Details__c, Priority__c, Status__c From Chirp_Ticket__c Where Case__c = :caseId];
        Articles = [Select SolutionId, CreatedById, CreatedBy.Name, CreatedDate, Solution.SolutionNumber, Solution.SolutionName, Solution.Summary__c From CaseSolution Where CaseId = :caseId];
        // Added by Dominic on 8/9/2012
        caseArticles = [Select c.KnowledgeArticleId, c.Id, c.CreatedDate, c.CreatedById, c.CreatedBy.Name, c.CaseId, c.ArticleVersionNumber, c.ArticleLanguage From CaseArticle c Where CaseId =: caseId];
        if (caseArticles != null && !caseArticles.isEmpty())
        {
            set<Id> articleIdSet = new set<Id>();
            for (CaseArticle ca : caseArticles)
            {
                if (ca.KnowledgeArticleId != null)
                {
                    articleIdSet.add(ca.KnowledgeArticleId);
                }
            }
            for (KnowledgeArticleVersion kav : [Select KnowledgeArticleId, Title, ArticleNumber, Summary, UrlName
                                                From KnowledgeArticleVersion
                                                Where IsVisibleInCsp = true
                                                And KnowledgeArticleId IN : articleIdSet
                                                And PublishStatus = 'Online'
                                                And Language = 'en_US'])
            {
                kavMap.put(kav.KnowledgeArticleId, kav);
            }
            //71242 Added by Ashwith on 20-03-2025
              for (KnowledgeArticleVersion kav : [Select KnowledgeArticleId, Title, ArticleNumber, Summary, UrlName
                                                From KnowledgeArticleVersion
                                                Where IsVisibleInApp = true AND IsVisibleInCsp=false AND IsVisibleInPkb= false AND IsVisibleInPrm=false
                                                And KnowledgeArticleId IN : articleIdSet
                                                And PublishStatus = 'Online'
                                                And Language = 'en_US'])
            {
                kavMap.put(kav.KnowledgeArticleId, kav);
            }//71242 END
        }
        
        Set<Id> noteArticleIds = new Set<Id>();
        for(Case_Note__c em : [Select Id, Article_Id__c, CreatedById, CreatedBy.Name, CreatedDate, Details__c, Type__c, Has_Attachment__c, Article__c, Article__r.SolutionName, Article__r.SolutionNumber, Is_Email__c, Public__c, From_Type__c, Incoming_Outgoing__c From Case_Note__c Where Case__c = :caseId AND (Article_Id__c != null) AND (Incoming_Outgoing__c != 'Incoming' OR (Incoming_Outgoing__c = 'Incoming' AND Type__c = 'BTBB Comment') OR (Incoming_Outgoing__c = 'Incoming' AND isDataload__c = true))]){
            string articleidsstring = em.Article_Id__c;
            
            for(string recId : articleidsstring.deleteWhitespace().normalizeSpace().split(','))
            {
                if(!String.isblank(recId))
                {
                    string tempStr = recId.trim();
                    noteArticleIds.add((Id)tempStr);
                }
            }
        }
        if(noteArticleIds.size() > 0){
            articleMap = getArticleMap(noteArticleIds);
        }
        prefixSet=new Set<String>();
        Map<String, Schema.SObjectType> gD = Schema.getGlobalDescribe();
        Set<String>keys=gD.keySet();
        
        for(String key:keys){
            Schema.DescribeSObjectResult r = gD.get(key).getDescribe();
            if(r!=null &&r.getKeyPrefix()!=null && r.getKeyPrefix()!='')
                prefixSet.add(r.getKeyPrefix());
        }
        
        String Subject;
        String Summary;
        String Details;
        String oldVal;
        String newVal;
        String Subject_email;
        String Subject_comment;
        String Subject_phonecall;
        String to;
        
        /* * * * * * * * * * * * * CASEHISTORIES * * * * * * * * * * * * */
        
        for(CaseHistory ch : Histories) {
            oldVal=String.valueOf(ch.oldValue);
            newVal=String.valueOf(ch.newValue);
            
            if(isId(oldVal)||isId(newVal)){
                Subject=null;
            } else  if(newVal == null) {
                Subject = null;
            } else {
                if(ch.Case.Status == 'New' && ch.Field == 'Owner')
                    Subject = 'Support Case Created and Assigned to <b>'+newVal+'</b>';
                else if(ch.Field == 'Status'){
                    
                    if(oldval=='Active' && newval=='Awaiting Support Update')
                        Subject = 'Status Changed to <b>' + newVal + '</b>';
                    else if(newVal == 'Awaiting Support Update' || newVal == 'Awaiting Support Update' || newVal == 'Resolved' || newVal == 'Solution Suggested' || newVal == 'Awaiting Client Response')
                        Subject = 'Status Changed to <b>' + newVal + '</b>';
                    else
                        Subject = 'Status Changed to <b>' + newVal + '</b>';
                } else {
                    if(ch.Field == 'Primary_Group_Name__c' && ch.Case.Status != 'New')
                        Subject = 'Primary Group Assigned to <b>' + newVal + '</b>';
                    else if(oldVal != null && newVal != null)
                        Subject = ch.Field + ' Changed from <b>' + oldVal + '</b> to <b>' + newVal + '</b>';
                    else if(oldVal == null && ch.Field != 'Primary_Group_Name__c')
                        Subject = ch.Field + ' Set to <b>' + newVal +  '</b>';
                    else
                        Subject = null;
                }
                if(Subject != Null){
                    //Subject = 'test' + Subject;
                    
                    // AMANDA Add 'No' for Case History Transaction
                    CHIlist.add(new CaseHistoryItem(ch.CreatedDate, Subject, null, null, ch.CreatedBy.Name, ch.CreatedById, ch.Id, 'Transaction', false, false, 'Private',false, 'No'));
                }
            }
        }
        
        /* * * * * * * * * * * * * EMAILMESSAGES * * * * * */
        
        for(EmailMessage em : Emails) {
            Boolean hasHtmlEmailContent=false;
            if(em.Incoming == true && em.FromName != 'Bb Support') {
                List<String> emailSubject=new list<string>();
                if(em.subject!=null)
                {
                    emailSubject = String.valueOf(em.Subject).split('>');
                }
                else
                {
                    emailSubject.add('');
                }
                if(em.HasAttachment == true)
                    Subject = emailSubject[0] + ' from ' + em.FromName + ' <a href="'+URLred+'/' + em.Id + '";>View Email Attachments</a>';
                // Added For Testing Purpse    
                If(emailSubject[0] != Null && emailSubject[0] != ''){
                    System.Debug('Any thing '+emailSubject[0]);
                    //Added by Daksh Sharma for user friendly message for bug #64309
                    List<String> solutionAttributesList = emailSubject[0].split(':');
                    system.debug('Size '+solutionAttributesList.Size());
                    system.debug('List '+solutionAttributesList);
                    if(solutionAttributesList.Size() == 6){
                        String solutionResponse = solutionAttributesList[3];
                            system.debug('Inside Second');
                        if(solutionResponse == '0'){ 
                            Subject = '<b>Solution Declined </b>'+solutionAttributesList[0]+':'+solutionAttributesList[1]+'  '+solutionAttributesList[2]+':'+solutionAttributesList[3]+'  '+solutionAttributesList[4]+':'+solutionAttributesList[5]+' from '+ em.FromName;
                        }else if(solutionResponse == '1'){
                            Subject = '<b>Solution Accepted </b>'+solutionAttributesList[0]+':'+solutionAttributesList[1]+'  '+solutionAttributesList[2]+':'+solutionAttributesList[3]+'  '+solutionAttributesList[4]+':'+solutionAttributesList[5]+' from '+ em.FromName;
                        }else{
                            Subject = emailSubject[0] + ' from ' + em.FromName;
                        }  
                    }
                }
                
                
                Summary = em.TextBody;
                system.debug('Email--'+em.id+em.textbody);
                if(em.Htmlbody != null && em.Htmlbody !='') //&& !em.Htmlbody.contains('[Message Clipped]'))
                {
                    hasHtmlEmailContent=true;
                }
                if(em.textbody != null && em.textbody !='')
                {
                    system.debug('Email--'+em.id);
                    string temp=(em.TextBody).escapeHtml4().replaceAll('[\\n]|[\\r]','<br/>');
                    if(temp.length()>31950)
                    {
                        Details=temp.substring(0,31950)+'<br/><br/>[Message clipped]';
                    }
                    else
                    {
                        Details=temp;
                    }
                }
                if(em.Incoming != false && em.FromName != 'Bb Support')
                    // AMANDA Add 'Yes' for Email Message
                    CHIlist.add(new CaseHistoryItem(em.CreatedDate, Subject, Details, Summary, em.FromName, em.CreatedById,  em.Id, 'Email', em.HasAttachment, em.Incoming, 'Public',hasHtmlEmailContent,'Yes'));
            }
            if(em.Incoming == false && em.Subject.contains('Case Number')){
                List<String> emailSubject2 = String.valueOf(em.Subject).split('\\[');
                Subject = emailSubject2[0];
                Summary = em.textbody;
                Details = em.textbody;
                if(Details != null)
                    Details = Details.replaceAll('[\\n]|[\\r]','<br/>');
                // AMANDA Add 'Yes' for Email Message
                CHIlist.add(new CaseHistoryItem(em.CreatedDate, Subject, Details, Summary, em.FromName, em.CreatedById,  em.Id, 'Email', em.HasAttachment, em.Incoming, 'Public',hasHtmlEmailContent,'Yes'));
            }
        }
        /* * * * * * * * * * * * * CASE_NOTE__C * * * * * * * * * * * * */
        
        for(Case_Note__c em : Notes){
            String Category = ' ';
            String Visibility = ' ';
            Boolean isIncoming;
            
            String DetailsFix = ' ';
            String SummaryFix = ' ';
            set<id> articleids = new set<id>();
            
            if(em.is_Email__c == true)
                Category = 'Email';
            else if(em.Type__c.contains('call') || em.Type__c.contains('Call'))
                Category = 'Phone Call';
            else
                Category = em.Type__c;
            
            if(em.Public__c == true)
                Visibility = 'Public';
            else
                Visibility = 'Private';
            
            if(em.From_Type__c == 'Customer' || em.Incoming_Outgoing__c == 'Incoming' || em.Type__c == 'BTBB Comment')
                isIncoming = true;
            else
                isIncoming = false;
            
            if(em.Article_Id__c == null)
            {
                Details = em.Details__c;
                if(Details!= null) {
                    if(!(Details.contains('<li>')&&Details.contains('</li>')))//added for TP1953
                        Details = Details.replaceAll( '[\\r]|[\\n]' , '<br/>' );
                    Details = Details.replaceAll( '</p><br/><p><br/>' , '<br/><br/>' );
                }
            }
            else
            {
                string articleidsstring = em.Article_Id__c;
                
                for(string recId : articleidsstring.deleteWhitespace().normalizeSpace().split(','))
                {
                    if(!String.isblank(recId))
                    {
                        string tempStr = recId.trim();
                        articleids.add((Id)tempStr);
                    }
                }
                
                if(articleids.size() > 0 && articleMap != null && !articleMap.isEmpty())
                {
                    string tempDetails;
                    for(String recordId : articleids)
                    {
                        if(tempDetails == Null && articleMap.containskey(recordId))
                        {
                            tempDetails = '<b>Article Attached:</b><br/><a class="article_link" onclick="articlelink(\''+ recordId + '\')"  href="#">' + articleMap.get(recordId).ArticleNumber + ' ' + articleMap.get(recordId).Title + '</a>';
                        }
                        else if(tempDetails != Null && articleMap.containskey(recordId))
                        {
                            tempDetails = tempDetails + '<br/>' + '<b>Article Attached:</b><br/><a class="article_link" onclick="articlelink(\''+ recordId + '\')"  href="#">' + articleMap.get(recordId).ArticleNumber + ' ' + articleMap.get(recordId).Title + '</a>';
                        }
                    }
                    if(tempDetails != Null)
                    {
                        Details = tempDetails + '<br/><br/>' + em.Details__c;
                    }
                }
                
                
            }
            
            for(Case_Attachment__c att: MigratedAttachment)
            {
                if(att.Case_Note__c==em.id)
                {
                    Details+='<br/>Attachment: <a href="/apex/Linkredirect?id=' + att.Id + '>' + att.File_Name__c + '</a>';
                    em.Has_Attachment__c=true;
                }
            }
            if(em.Type__c == 'Email' && em.From_Type__c == 'Customer')
                Subject = em.Email_Subject__c;
            else
                Subject = em.Type__c;
            Summary = em.Details__c;
            if(Summary!=null)
                Summary = Summary.replaceAll( ' \\/\\<\\/?[^>]+(>|$)/g ' , ' ' );
            if(em.Type__c != 'Suggest Solution')
                CHIlist.add(new CaseHistoryItem(em.CreatedDate, Subject, Details, Summary, em.CreatedBy.Name, em.CreatedById,  em.Id, Category, em.Has_Attachment__c, isIncoming, Visibility,false,'Yes'));
        }
        
        
        /* * * * * * * * * * * * * CHIRP_TICKETS__R * * * * * * * * * * * */
        
        for(Chirp_Ticket__c ca : Chirps){
            Details = ca.Details__c;
            Subject='<strong>CHIRP Ticket #:</strong>  <a href="#" class="chirp_link" onclick="chirplink(\''+ca.id+'\')" >'+ca.Name+' - '+ca.Subject__c+'</a> - <strong>Status:</strong>  '+ca.Status__c;
            CHIlist.add(new CaseHistoryItem(ca.CreatedDate, Subject, Details, null,  ca.CreatedBy.Name, ca.CreatedById, ca.Id,'CHIRP Ticket', false, false, 'Private',false,'No'));
        }
        
        /* * * * * * * * * * * * * CASESOLUTIONS * * * * * * * * * * * * */
        
        for(CaseSolution cs: Articles){
            Details = cs.Solution.Summary__c;
            Subject = '<b>Article Attached to Case: </b><a href="'+URLred+'/apex/ArticleRedirect?id='+cs.SolutionId+'&isdtp=vw" target="_blank" style="color:blue;">Article #'+cs.Solution.SolutionNumber+' - '+cs.Solution.SolutionName+'</a>';
            Summary= cs.Solution.Summary__c;
            if(Summary != null)
                Summary = Summary.replaceAll( '\\/\\<\\/?[^>]+(>|$)/g' , '');
            CHIlist.add(new CaseHistoryItem(cs.CreatedDate, Subject, Details, Summary, cs.CreatedBy.Name, cs.CreatedById, cs.Id,'Article', false, false, 'Public',false,'Yes'));
        }
        
        // Added by Dominic on 8/9/2012
        /* * * * * * * * * * * * * CASEARTICLES * * * * * * * * * * * * */
        
        for(CaseArticle cs: caseArticles)
        {
            if (kavMap.containsKey(cs.KnowledgeArticleId))
            {
                Subject = '<b>Knowledge Article Attached to Case: </b><a href="'+URLred+'/apex/ArticleRedirect?id=' + cs.KnowledgeArticleId +
                    '&isdtp=vw" target="_blank" style="color:blue;">Article #' + kavMap.get(cs.KnowledgeArticleId).ArticleNumber + ' - ' +
                    kavMap.get(cs.KnowledgeArticleId).Title + '</a>';
                System.debug('Subject$$$$$$$ '+Subject);
                Summary= kavMap.get(cs.KnowledgeArticleId).Summary;
                Details = kavMap.get(cs.KnowledgeArticleId).Summary;
                if(Summary != null)
                    Summary = Summary.replaceAll( '\\/\\<\\/?[^>]+(>|$)/g' , '');
                CHIlist.add(new CaseHistoryItem(cs.CreatedDate, Subject, Details, Summary, cs.CreatedBy.Name, cs.CreatedById, cs.Id,'Article', false, false, 'Public',false,'No'));
            }
        }
        
        /* * * * * * * * * * * * * CASE_ATTACHMENT__R * * * * * * * * * * * * */
        
        for(Case_Attachment__c cs: Attachments){
            if(cs.Email_Attachment_link__c==NULL){
                Details = cs.Notes__c;
                Subject = '<b>Attachment</b> <a href="'+URLred+'/apex/LinkRedirect?id='+cs.Id+'&isdtp=vw" target="_blank";>'+cs.File_Name_w_Ext__c+'</a>';
                Summary='';
                //Summary=  '<a href="/apex/LinkRedirect?id='+cs.Id+'&isdtp=vw" target="_blank";>'+cs.File_Name_w_Ext__c+'</a>';
                CHIlist.add(new CaseHistoryItem(cs.CreatedDate, Subject, Details, Summary, cs.CreatedBy.Name, cs.CreatedById, cs.Id,'Attachment', true, true, 'Public',false,'Yes'));
            }
            else
            {
                Details ='';
                if (cs.Email_Attachment_link__c.contains('068')){
                    System.debug('emailattachmentlink');
                    Subject='<b>Attachment </b><a href="'+URLred+'/sfc/servlet.shepherd/version/download/' + cs.Email_Attachment_link__c  + '";>' + cs.File_Name__c + '</a>';
                    System.debug('subject: ' + Subject);
                } else {
                    Subject = '<b>Attachment</b> <a href="'+URLred+'/servlet/servlet.FileDownload?file=' + cs.Email_Attachment_link__c + '&isdtp=vw"target="_blank";>'+cs.File_Name__c+'</a>';
                }
                Summary='';
                //Summary=  '<a href="/servlet/servlet.FileDownload?file=' + cs.Email_Attachment_link__c + '";>'+cs.File_Name__c+'</a>';
                CHIlist.add(new CaseHistoryItem(cs.CreatedDate, Subject, Details, Summary, cs.CreatedBy.Name, cs.CreatedById, cs.Id,'Attachment', true, true, 'Public',false,'Yes'));
            }
        }
        
        /* * * * * * * * * * * * * SOLUTION_DETAILS__R * * * * * * * * * * * * */
        
        for(Solution_Detail__c sd : Solutions){
            set<id> articleids = new set<id>();
            Subject= '<b>Solution Suggested</b> - <i>Status: '+sd.Status__c+'</i>';
            if(!String.isblank(sd.Article_Id__c))
            {
                string articleidsstring = sd.Article_Id__c;
                
                for(string recId : articleidsstring.deleteWhitespace().normalizeSpace().split(','))
                {
                    if(!String.isblank(recId))
                    {
                        string tempStr = recId.trim();
                        articleids.add((Id)tempStr);
                    }
                }
                
                if(articleids.size() > 0 && articleMap != null && !articleMap.isEmpty())
                {
                    string tempDetails;
                    for(String recordId : articleids)
                    {
                        if(tempDetails == Null && articleMap.containskey(recordId))
                        {
                            tempDetails = '<div><b>Article:</b> <a href="'+URLred+'/apex/ArticleRedirect?id=' + recordId + '">Article #' + articleMap.get(recordId).ArticleNumber + ' ' + articleMap.get(recordId).Title +
                                '</a>';
                        }
                        else if(tempDetails != Null && articleMap.containskey(recordId))
                        {
                            tempDetails = tempDetails + '<br/>' + '<div><b>Article:</b> <a href="'+URLred+'/apex/ArticleRedirect?id=' + recordId + '">Article #' + articleMap.get(recordId).ArticleNumber + ' ' + articleMap.get(recordId).Title +
                                '</a>';
                        }
                    }
                    if(tempDetails != Null)
                    {
                        Details = tempDetails + '<br/><br/>' + '<div style="display:block;padding:15px;margin-top:15px;border: 1px solid #999;"><b>Support Comments:</b> ' + sd.Description__c +
                            '</div><div style="padding:15px;margin-top:15px;background:#F0F0F0;color:#222;"><b>Customer Comments:</b><br/>' + sd.Comments__c + '</div>';
                    }
                }
            }
            else
            {
                Details = '<div style="display:block;padding:15px;margin-top:15px;border: 1px solid #999;"><b>Support Comments:</b><br/>'+sd.Description__c+'</div><div style="padding:15px;margin-top:15px;background:#F0F0F0;color:#222;"><b>Customer Comments:</b><br/> '+sd.Comments__c+'</div>';
            }
            Summary=  sd.Description__c;
            if(Summary!= null)
                Summary = Summary.replaceAll( '\\/<\\/?[^\\>]+(>|$)/g' , '');
            if(Subject != Null)
                CHIlist.add(new CaseHistoryItem(sd.CreatedDate, Subject, Details, Summary, sd.CreatedBy.Name, sd.CreatedById, sd.Id,'Solution', false, false, 'Public',false,'Yes'));
        }
    }
    /* * * * * * * * * * * * * End Constructor * * * * * * * * * * * * */
    public Map<Id,KnowledgeArticleVersion> getArticleMap (Set<Id> noteArticleIds)
    {
        Map<Id,KnowledgeArticleVersion> kavMap = new Map<Id,KnowledgeArticleVersion>();
        
        for(KnowledgeArticleVersion kavrecord: [Select KnowledgeArticleId, Title, ArticleNumber, Summary
                                                From KnowledgeArticleVersion Where KnowledgeArticleId IN:noteArticleIds And PublishStatus = 'Online' And Language = 'en_US'] )
        {
            kavMap.put(kavrecord.KnowledgeArticleId,kavrecord);
        }
        
        return kavMap;
    }
    
    public boolean isId(String at){
        if(at==null)
            return false;
        else if(at.length()<5)
            return false;
        else{
            String testVal = at.substring(0,3);
            if(prefixset.contains(testVal))
                return true;
            /*    for(String prefix : prefixSet){
if(prefix.equals(testVal))
return true;
}*/
        }
        return false;
    }
    
    public String getUserType(){
        return UserInfo.getUserType();
    }
    
    public String getUserProfileId(){
        return UserInfo.getProfileId();
    }
    
    public String getCaseNumber(){
        return Cases[0].CaseNumber;
    }
    public PageReference exportToPDF() {
        
        return Page.CaseHistory360PDF;
    }
    
    public PageReference backtocase(){
        PageReference pageRef = new PageReference('/'+ caseId);
        return pageRef;
    }
    
    public Class CaseHistoryItem{
        
        
        public String addRegex = '\n';
        public string addRegex2='\n\n';
        public string addRegex3='<br />\r\n';
        public String stripRegex = '<.*?>';
        
        Pattern addPattern = pattern.compile(addRegex);
        Pattern addPattern2= pattern.compile(addRegex2);
        Pattern addPattern3= pattern.compile(addRegex3);
        Pattern stripPattern = pattern.compile(stripRegex);
        
        public Datetime createdDate   {get; set;}
        public String Details         {get
        { if(Details!=null)
            return Details.replace('<script>','&lt;script&gt;');
         else
             return Details;
        } set;}
        
        public String Subject         {get
        {
            if(Subject!=null)
                return subject.replace('<script>','&lt;script&gt;');
            else
                return Subject;
        } set;}
        public String Summary         {get; set;}
        public String createdName     {get; set;}
        public String createdId       {get; set;}
        public String mainId          {get; set;}
        public String itemType        {get; set;}
        public String createDateFix   {get; set;}
        public String itemTypeName    {get; set;}
        public string external        {get; set;}
        public Boolean isIncoming     {get; set;}
        public Boolean hasAttachments {get; set;}
        public Boolean hasHtmlEmailContent {get;set;}
        public String showCommunications {get;set;}
        
        public CaseHistoryItem(Datetime aCreateDate, String aSubject, String aDetails, String aSummary, String aCreatedName, String aCreatedId, String aMainId, String aType, boolean aHasAttachments, boolean aIsIncoming, string aExternal,boolean ahasHtmlEmailContent, String aShowCommunications){
            isIncoming = aIsIncoming;
            hasAttachments = aHasAttachments;
            createdDate = aCreateDate;
            external = aExternal;
            hasHtmlEmailContent = ahasHtmlEmailContent;
            createDateFix = createdDate.format('MM/d/yyyy hh:mm:ss a');
            Details=aDetails;
            summary=aSummary;
            Matcher addMatcher;
            if(Details != null )
            {
                Details = Details.replaceall('</div>\n','</div>');
                addMatcher = addPattern3.matcher(Details);
            }
            Matcher stripMatcher;
            if(Summary != null)
                stripMatcher = stripPattern.matcher(Summary);
            
            
            if(Details!=null&&(!(Details.contains('<li>')&&Details.contains('</li>'))))//TP4303
            {
                if(addMatcher != null)
                {
                    Details = addMatcher.replaceAll('<br/>');
                    addMatcher=addPattern2.matcher(Details);
                    if(addMatcher != null)
                        Details=addMatcher.replaceAll('<br/>');
                    addMatcher=addPattern.matcher(Details);
                    if(addMatcher != null)
                        Details=addMatcher.replaceAll('<br/>');
                    //Details=Details.replaceall('<br/><br/>','<br/>');
                }
            }
            
            If(Details!=null)
            {  // TP57695 Community portal URL update change
                if(Details.contains('href="/')){
                    string replacetempDetails ='href="'+URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix()+'/';
                    Details = Details.replaceall('href="/',replacetempDetails);
                    
                }
            }
            
            if(stripMatcher != null)
                Summary = stripMatcher.replaceAll(' ');
            
            Subject = aSubject;
            Details = removeHtmlTags(Details);
            createdName = aCreatedName;
            createdId = aCreatedId;
            mainId = aMainId;
            itemType = getTypeImageMap(aType,aHasAttachments,aIsIncoming, aExternal);
            itemTypeName = aType;
            // AMANDA add
            if (aType.contains('Escalated') || aType.contains('TrackSmart')
                || aType.contains('OpSmart') || aType=='CHIRP Ticket'){
                    showCommunications = 'No';
                } else {
                    showCommunications = aShowCommunications;
                }
        }
        
        private String removeHtmlTags(String details){
            if(details!=null){
                Matcher removeHTMLBegin = Pattern.compile('<html dir="[a-z\\"]+>').matcher(details);
                String afterHTMLBeginremoved = removeHTMLBegin.replaceAll(' ');
                
                //String afterHTMLBeginremoved= details.replace('html dir','');
                Matcher removeHTMLEnd = Pattern.compile('</html>').matcher(afterHTMLBeginremoved);
                String afterHTMLEnd = removeHTMLEnd.replaceAll(' ');
                
                Matcher removeHeadBegin = Pattern.compile('<head*>').matcher(afterHTMLEnd);
                String afterHeadBeginremoved = removeHeadBegin.replaceAll(' ');
                
                Matcher removeHeadEnd = Pattern.compile('</head>').matcher(afterHeadBeginremoved);
                String afterHeadEnd = removeHeadEnd.replaceAll(' ');
                
                Matcher removeBodyBegin = Pattern.compile('<body style="[a-zA-Z0-9,=\\-\\:\\"\\;\\s\'\']+>').matcher(afterHeadEnd);
                String afterBodyBeginremoved = removeBodyBegin.replaceAll(' ');
                
                Matcher removeBodyBegin2 = Pattern.compile('<body').matcher(afterBodyBeginremoved);
                String afterBodyBeginremoved2 = removeBodyBegin2.replaceAll(' ');
                
                Matcher removeBodyEnd = Pattern.compile('</body>').matcher(afterBodyBeginremoved2);
                String afterBodyEnd = removeBodyEnd.replaceAll(' ');
                
                System.debug('HHHHHHHHHHHHHH');
                System.debug('JJJJJJJJ'+afterBodyEnd);
                
                return afterBodyEnd;//.replace('<body style="text-align:center"','<body ');
            }
            return '';
        }
        
        private String getTypeImageMap(String aType, Boolean aHasAttachments, Boolean aIsIncoming, String aExternal){
            if (aType=='Transaction')
                return '/resource/1320414452000/supporticons/icons/32x32/process.png';
            else if(aType=='Attachment')
                return '/resource/1320414452000/supporticons/icons/32x32/attachment.png';
            else if(aType=='Article')
                return '/resource/1320414452000/supporticons/icons/32x32/lock.png';
            else if(aType=='Solution')
                return '/resource/1320414452000/supporticons/icons/32x32/light_bulb.png';
            else if(aType=='CHIRP Ticket')
                return '/resource/1320414452000/supporticons/icons/32x32/tools.png';
            else if(aType=='BTBB Comment' && aHasAttachments == true)
                return '/resource/1320414452000/supporticons/icons/32x32/user_comment_attachment.png';
            else if(aType=='BTBB Comment')
                return '/resource/1320414452000/supporticons/icons/32x32/user_comment.png';
            else if(aType=='Email' && aIsIncoming != true && aHasAttachments == true)
                return '/resource/1320414452000/supporticons/icons/32x32/mail_attachment_send.png';
            else if(aType=='Email' && aIsIncoming == true && aHasAttachments == true)
                return '/resource/1320414452000/supporticons/icons/32x32/mail_attachment_receive.png';
            else if(aType=='Email' && aIsIncoming != true && aHasAttachments == false)
                return '/resource/1320414452000/supporticons/icons/32x32/mail_send.png';
            else if(aType=='Email' && aIsIncoming == true && aHasAttachments == false)
                return '/resource/1320414452000/supporticons/icons/32x32/mail_receive.png';
            else if(aType.contains('Escalated'))
                return '/resource/1320414452000/supporticons/icons/32x32/process_warning.png';
            else if(aType.Contains('Reopen'))
                return '/resource/1320414452000/supporticons/icons/32x32/refresh.png';
            else if(aType.Contains('Closed'))
                return '/resource/1320414452000/supporticons/icons/32x32/accept.png';
            else if(aType == 'BSAN Granted')
                return '/resource/1320414452000/supporticons/icons/32x32/accept_page.png';
            else if(aType.contains('call') || aType.contains('Call'))
                return '/resource/1320414452000/supporticons/icons/32x32/mobile.png';
            else if (aType.contains('TrackSmart'))
                return '/resource/1320414452000/supporticons/icons/32x32/lock_blue.png';
            else if (aType.contains('OpSmart'))
                return '/resource/1320414452000/supporticons/icons/32x32/lock_green.png';
            else if( aHasAttachments != True && (aType == 'Internal Note' || (aExternal == 'Private' && aType != 'Transaction')))
                return '/resource/1320414452000/supporticons/icons/32x32/lock.png';
            else if(aType == 'Internal Note' && aHasAttachments == true)
                return '/resource/1320414452000/supporticons/icons/32x32/internal_attachment.png';
            else if(aType == 'Comment')
                return '/resource/1320414452000/supporticons/icons/32x32/user_comment.png';
            else if(aType=='External Note - No Email' && aHasAttachments == true)
                return '/resource/1479468648000/style2016/include/images/icons/icon-external-note-attachment.png';
            else if(aType== 'External Note - No Email')
                return '/resource/1479468648000/style2016/include/images/icons/icon-external-note.png';
            else if(aType== 'Case Escalation Comments')
                return '/resource/1479468648000/style2016/include/images/icons/icon-clientescalated.jpg';
            else
                return '/resource/1320414452000/supporticons/icons/32x32/full_page.png';
        }
        
        
        
    }
    //Method Written on 21st March by Abhinav for sorting list by date
    public List<CaseHistoryItem> getCaseHistoryItemSort(){
        
        CaseHistoryItem temp ;
        
        for(Integer i=0;i<CHIlist.size();i++){
            
            for(Integer j=1;j<CHIlist.size()-i;j++)
            {
                
                if(CHIlist[j-1].CreatedDate < CHIlist[j].CreatedDate ){
                    temp = CHIlist[j-1];
                    CHIlist[j-1] = CHIlist[j] ;
                    CHIlist[j] = temp;
                }
            }
        }
        return CHIlist;
    }
    
    public list<list<CaseHistoryItem>>getCaseHistoryList(){
        list<CaseHistoryItem> tempList= new list<CaseHistoryItem>();
        list<list<CaseHistoryItem>> fullList= new list<list<CaseHistoryItem>>();
        integer y=0;
        if(CHIlist!=null && CHIlist.size()>0)
        {
            for(CaseHistoryItem ch:CHIlist)
            {
                if(y<=999)
                {
                    tempList.add(ch);
                }
                else
                {
                    fullList.add(templist);
                    templist= new list<CaseHistoryItem>();
                    templist.add(ch);
                    y=0;
                }
                y++;
            }
        }
        if(templist != null && templist.size()>0)
            fullList.add(templist);
        
        if(CHIlist!=null && CHIlist.size()>0)
        {
            CHIlist.Clear();
        }
        return fullList;
    }
}