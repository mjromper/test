package es.tid.ehealth.mobtel.android.common.services;

import java.util.ArrayList;
import java.util.HashMap;

import es.tid.ehealth.mobtel.android.common.bo.Contact;

/**
 * @author mjrp
 * Interface that indicates Services to access contact data
 */
public interface ContactService {

    /**
     * Create or update(if already exists) contact data
     * @param contactBO
     * @return
     */
    public boolean updateOrCreate(Contact contact);

    /**
     * Get a hasmap of all contacts inserted the system 
     * @return HashMap<String,Contact> contact hashmap idexed by it idContact
     */
    public ArrayList<Contact> getAllContactsData();

    /**
     * Look for a contact by it phone number
     * @param phoneNumber
     * @return Contact
     */
    public Contact getContactByPhoneNumber(String phoneNumber);

    /**
     * Get a hashmap of contacts who are quickdials
     * @return HashMap<String,Contact> of quickdial contacts
     */
    public HashMap<Integer, Contact> getQuickDialContactsData();

    /**
     * Delete contact with thi contact id
     * @param idContact
     * @return true if done, false otherwise
     */
    public boolean delete(Contact contact);


}
