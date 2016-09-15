/** 
 * A custom wrapper class used to simply the representation and use of Monash Student Management System (SMS) information.
 * <p>
 * All attributes align to those returned in the JSON response received 
 * when requesting Citizenship information via a callout to the API.Monash web service
 * for a given person id.
 * <p>
 * See https://api-dev.monash.edu/static/api for service details
 * 
 */
public class API_StudentCitizenship {
	public String personId {get;set;}
    public string citizenshipType {get;set;}

	public API_StudentCitizenship(){
        this.personId = '';
        this.citizenshipType = '';
    }
}