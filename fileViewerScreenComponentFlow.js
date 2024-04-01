// Import necessary modules and methods from the LWC framework and Salesforce
import { LightningElement, api, wire } from "lwc";
import getRelatedFilesByRecordId from "@salesforce/apex/FilePreviewAndDownloadController.getRelatedFilesByRecordId";
import { NavigationMixin } from "lightning/navigation";

// Define the LWC component class
export default class FilePreviewAndDownloads extends NavigationMixin(
  LightningElement
) {
  // Public property for record ID, accessible externally
  @api recordId;
  // Initialize an array to hold the list of files related to the record
  filesList = [];

  // Wire decorator to call the Apex method getRelatedFilesByRecordId automatically
  // when the component is rendered and whenever the recordId changes
  @wire(getRelatedFilesByRecordId, { recordId: "$recordId" })
  wiredResult({ error, data }) {
    if (data) {
      // If data is returned, map each file's details to the filesList array
      this.filesList = data.map((file) => ({
        label: file.title,
        contentVersionId: file.contentVersionId,
        url: `/sfc/servlet.shepherd/document/download/${file.contentDocumentId}`,
      }));
    } else if (error) {
      // Log the error to the console if there is an issue in fetching the data
      console.error(error);
    }
  }

  // Handler for the preview button click event
  previewHandler(event) {
    // Get the contentVersionId from the button's dataset
    const contentVersionId = event.target.dataset.contentVersionId;
    // Construct the URL for the file preview
    const url = `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${contentVersionId}`;
    // Open the URL in a new tab
    window.open(url, "_blank");
  }
}
