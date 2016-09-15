/**
 * Services class to provide Account sObject centric logical support
 * 
 * @author Carl Vescovi, PwC
 * @revision Anterey Custodio, Oakton, 15/09/2016 - as of version 36, final variables
 *				are not covered on test classes. removed it for now.
 * 
 */

public with sharing class AccountServices {
    
    public static String ACCOUNT_INDIVIDUAL_TYPE = 'Individual';		// reference to record type developer name for type used on individuals
    public static String ACCOUNT_ORGANISATION_TYPE = 'Organization';		// reference to record type developer name for type used on organisations
    
}