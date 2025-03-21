/**
 * @prettier
 */
public with sharing class AcceptController {
    @AuraEnabled(cacheable=false)
    public static String changeOwner(Id recordId, Id userId) {
        String result;
        Case selectedCase = [SELECT Status, OwnerId FROM Case WHERE Id = :recordId];
        if (selectedCase.Status != 'Resolved' && selectedCase.OwnerId != userId) {
            selectedCase.OwnerId = userId;
            update selectedCase;
            result = 'Success';
        } else {
            result = 'Error: Ensure you do not already own this Case and the status is not Closed.';
        }
        return result;
    }
}