package es.tid.ehealth.mobtel.android.common.services.impl;

import java.util.ArrayList;
import java.util.HashMap;

import android.content.Context;
import android.database.Cursor;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Phone;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.bo.MPhone;
import es.tid.ehealth.mobtel.android.common.db.DbContactPhoneAccess;
import es.tid.ehealth.mobtel.android.common.services.ContactService;

public class ContactServiceImpl implements ContactService{

	private static final Logger logger = LoggerFactory.getLogger(ContactServiceImpl.class);

	private static final int MAX_NUM_OF_QUICKDIALS = 4;    

	/**
	 * To made possible db contact access
	 */
	private DbContactPhoneAccess contactsPhoneDbAccess;


	/**
	 * Default constructor
	 * @param context
	 */
	public ContactServiceImpl(Context context) {

		contactsPhoneDbAccess = new DbContactPhoneAccess(context);       

	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#updateOrCreateContact(es.tid.ehealth.mobtel.android.common.bo.Contact)
	 */
	@Override
	public boolean updateOrCreate(Contact contact){
		String idContact = contactsPhoneDbAccess.getIdContactByDisplayName(contact.getDisplayName());
		String rawIdContact = null;
		boolean update = false;

		if (idContact == null){            
			rawIdContact = contactsPhoneDbAccess.addContactToPhoneDb(contact.getDisplayName());
			idContact = contactsPhoneDbAccess.getContactId(rawIdContact);

		}else{  
			update = true;
			rawIdContact = contactsPhoneDbAccess.getRawIdContactById(idContact);
		} 

		contact.setId(idContact);  
		boolean persist = contactsPhoneDbAccess.updateOrCreate(contact,rawIdContact);

		if (persist){
			if (update){
				logger.info("Contact "+contact.getDisplayName()+" UPDATED!!");
			}else{
				logger.info("Contact "+contact.getDisplayName()+" INSERTED!!");
			}
		}
		return persist;
	}   


	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#getAllContactsData()
	 */
	@Override
	public ArrayList<Contact> getAllContactsData() {


		Cursor cursor = contactsPhoneDbAccess.getCursor();
		ArrayList<Contact> contacts = null;
		try {          

			if (cursor.getCount() > 0) {
				logger.info("Contacts found: "+cursor.getCount());
				contacts = new ArrayList<Contact>(0);
				while (cursor.moveToNext()) {
					String idContact = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));
					Contact contact = contactsPhoneDbAccess.getContactBasicData(idContact,true);  
					contacts.add(contact);
				}
			}
		}catch (Exception e) {
			logger.error("# getAllContactsData: "+e);

		}finally{
			cursor.close();
		}

		return contacts;
	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#getContactByPhoneNumber(java.lang.String)
	 */
	@Override
	public Contact getContactByPhoneNumber(String phoneNumber) {        
		return contactsPhoneDbAccess.getContactByPhoneNumber(phoneNumber);
	}

	//	/* (non-Javadoc)
	//	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#getQuickDialContactsData()
	//	 */
	//	@Override
	//	public HashMap<Integer, Contact> getQuickDialContactsData() {
	//		HashMap<Integer, Contact> quicks = null;
	//		Cursor cursor = contactsPhoneDbAccess.getCursor();
	//		if (cursor != null){
	//			try {       
	//				if (cursor.getCount() > 0) {
	//
	//					while (cursor.moveToNext()) {
	//						String idContact = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));
	//						String quickDial = contactsPhoneDbAccess.getQuickOrderData(idContact);
	//						if (quickDial!=null){                        
	//							Contact contact = contactsPhoneDbAccess.getContactBasicData(idContact,true);
	//							if (contact != null && quicks == null){
	//								quicks = new HashMap<Integer,Contact>();
	//
	//							}
	//							if (quicks != null){
	//								quicks.put(Integer.parseInt(quickDial),contact);
	//								logger.debug("QuickDial contact found: "+quickDial);
	//							}
	//
	//						}    
	//
	//						if (quicks!= null && quicks.size() == MAX_NUM_OF_QUICKDIALS){
	//							break;
	//						}
	//
	//					}
	//				}
	//			}finally{
	//				cursor.close();
	//			}
	//		}else{
	//			logger.info("#getQuickDialContactsData: NOT quicksdials FOUND");
	//		}
	//		return quicks;
	//	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#getQuickDialContactsData()
	 */
	@Override
	public HashMap<Integer, Contact> getQuickDialContactsData() {
		HashMap<Integer, Contact> quicks = null;
		quicks = new HashMap<Integer,Contact>();
		Cursor cursor = contactsPhoneDbAccess.getCursor();
		int quick = 1;
		if (cursor != null){
			try {       
				if (cursor.getCount() > 0) {

					while (cursor.moveToNext()) {
						String idContact = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));						
						Contact contact = contactsPhoneDbAccess.getContactBasicData(idContact,true);

						if (contact.getPhotoBitmap() != null && contact.getPhones() != null && contact.getPhones().size() > 0){

							if (quicks != null){
								quicks.put(quick,contact);
								logger.debug("QuickDial contact found: "+quick);
								quick++;
							}

						}    

						if (quicks != null && quicks.size() == MAX_NUM_OF_QUICKDIALS){
							break;
						}
					}

				}

			}finally{
				cursor.close();
			}
		}else{
			logger.info("#getQuickDialContactsData: NOT quicksdials FOUND");
		}
		return quicks;
	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.android.common.services.ContactService#delete(java.lang.String)
	 */
	@Override
	public boolean delete(Contact contact) {        

		return contactsPhoneDbAccess.delete(contact);

	}


	protected void test(){

		Contact cTest = new Contact();
		cTest.setDisplayName("Fernando");
		cTest.addPhone(new MPhone("698951325", Phone.TYPE_MOBILE));
		cTest.setQuickDial(4);
		cTest.setIdPlat("112222");           

		updateOrCreate(cTest);            
	}



}


