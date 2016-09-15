/** 
 * A custom wrapper class used to simply the representation and use of Monash Student Management System (SMS) information.
 * <p>
 * All attributes align to those returned in the JSON response received 
 * when requesting person note information via a callout to the API.Monash web service
 * for a given person id.
 * <p>
 * See https://api-dev.monash.edu/static/api for service details
 * 
 */
public class API_StudentPersonNote {

    public string personId {get;set;}
    public string referenceNumber {get;set;}
    public string peNoteType {get;set;}
    public string noteText {get;set;}

    public API_StudentPersonNote(){
        this.personId = '';
        this.referenceNumber = '';
        this.peNoteType = '';
        this.noteText = '';
    }
    
}