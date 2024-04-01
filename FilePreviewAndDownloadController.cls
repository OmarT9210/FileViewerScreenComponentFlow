// Declare the class with 'with sharing' to enforce record-level access permissions
public with sharing class FilePreviewAndDownloadController {

// @AuraEnabled makes the method accessible from the Lightning component
    // 'cacheable=true' allows the client-side cache to store the method's return value
    @AuraEnabled(cacheable=true)
    public static List<FileDetail> getRelatedFilesByRecordId(String recordId) {
        // Query ContentDocumentLink to find all documents linked to the specified recordId
        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        
        // Prepare a list to hold the ContentDocumentIds
        List<Id> documentIds = new List<Id>();
        for (ContentDocumentLink link : links) {
            documentIds.add(link.ContentDocumentId);
        }

        // Query ContentVersion to get the latest version of the documents
        // Exclude JSON files by checking the FileExtension
        List<ContentVersion> versions = [
            SELECT ContentDocumentId, Id, Title, FileExtension 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :documentIds 
            AND IsLatest = TRUE 
            AND FileExtension != 'json'
        ];

        // Prepare a list of FileDetail objects to hold the results
        List<FileDetail> details = new List<FileDetail>();
        for (ContentVersion version : versions) {
            details.add(new FileDetail(version.ContentDocumentId, version.Id, version.Title));
        }
        return details;
    }

    // Inner class to structure the file details data
    public class FileDetail {
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public Id contentVersionId;
        @AuraEnabled public String title;

        // Constructor for the FileDetail class
        public FileDetail(Id contentDocumentId, Id contentVersionId, String title) {
            this.contentDocumentId = contentDocumentId;
            this.contentVersionId = contentVersionId;
            this.title = title;
        }
    }
}