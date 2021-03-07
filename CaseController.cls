public class CaseController{
 public override void beforeInsert() {
	Map<Id,List<EmailMessage>>caseEmailMessages=new Map<Id,List<EmailMessage>>();
	for (EmailMessage eMessage : (List<EmailMessage>) trigger.new) {
		if(eMessage.ParentId!=null){
				if(caseEmailMessages.containsKey(eMessage.ParentId)){
					caseEmailMessages.get(eMessage.ParentId).add(eMessage);
				}
				else{
					List<EmailMessage> ems=new List<EmailMessage>();
					ems.add(eMessage);
					caseEmailMessages.put(eMessage.ParentId,ems);
				}
		}
	}
	if(caseEmailMessages.keyset().size()>0){
		Map<Id,DateTime> maxInboundDate=getMaxInOrOutBoundMessageDate(caseEmailMessages.keyset(),true);
		Map<Id,DateTime> maxOutboundDate=getMaxInOrOutBoundMessageDate(caseEmailMessages.keyset(),false);
		for (EmailMessage eMessage : (List<EmailMessage>) trigger.new) {
			if(maxInboundDate.containsKey(eMessage.ParentId)){
				eMessage.Last_Inbound_Email_Timestamp__c=maxInboundDate.get(eMessage.ParentId);
			}
			if(maxOutboundDate.containsKey(eMessage.ParentId)){
				eMessage.Last_Outbound_Email_Timestamp__c=maxOutboundDate.get(eMessage.ParentId);
			}
		}
	}
 }
 public Map<Id,DateTime>  getMaxInOrOutBoundMessageDate(Set<Id>caseIds,Boolean Incoming)
 {
		Map<Id,DateTime>maxDate=new Map<Id,DateTime>();
		for(Case caseObject:[select id, Contact.Id, SuppliedEmail,Last_Name__c,Type, (select id,CreatedDate,Incoming,Last_Inbound_Email_Timestamp__c,Last_Outbound_Email_Timestamp__c, ccaddress, BccAddress,HtmlBody, FromAddress, Subject, ToAddress from EmailMessages WHERE Incoming=Incoming ) from Case where Id=caseIds])
		{
			Datetime tempMaxDate=null;
			for(EmailMessage emailMessage:caseObject.EmailMessages){
				if(tempMaxDate==null)tempMaxDate=emailMessage.CreatedDate;
				else{
					if(emailMessage.CreatedDate>=tempMaxDate){
						tempMaxDate=emailMessage.CreatedDate;
					}   
				} 
			}
			if(tempMaxDate!=null){
			maxDate.put(caseObject.Id,tempMaxDate);
			}
		}
		return maxDate;
 }
}
