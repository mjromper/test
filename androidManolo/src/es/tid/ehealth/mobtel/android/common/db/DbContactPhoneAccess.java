package es.tid.ehealth.mobtel.android.common.db;

import java.io.InputStream;
import java.util.ArrayList;

import android.content.ContentProviderOperation;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.OperationApplicationException;
import android.database.Cursor;
import android.database.sqlite.SQLiteException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.RemoteException;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.Data;
import android.provider.ContactsContract.PhoneLookup;
import android.provider.ContactsContract.RawContacts;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.bo.Email;
import es.tid.ehealth.mobtel.android.common.bo.MPhone;

/**
 * @author mjrp
 * Class that made real CONTACT database access
 */
public class DbContactPhoneAccess {

	private ContentResolver cr;
	private static final Logger logger = LoggerFactory.getLogger(DbContactPhoneAccess.class);

	static final String MIMETYPE_CONTACT_QUICKDIAL = "vnd.android.cursor.item/quickdial";
	static final String MIMETYPE_CONTACT_IDPLATFORM = "vnd.android.cursor.item/idPlatform";


	/**
	 * Default constructor
	 * @param context
	 */
	public DbContactPhoneAccess(Context context) {
		this.cr = context.getContentResolver();
	}

	/**
	 * Method to create or update a contact into database
	 * @param contact
	 */
	public boolean updateOrCreate(Contact contact, String rawIdContact){
		ContentValues values =  new ContentValues();
		int mod = 0;
		boolean fine = true;
		try {
			values.put(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, contact.getDisplayName());
			mod = cr.update(Data.CONTENT_URI, values, 
					Data.RAW_CONTACT_ID+ "="+ rawIdContact +" AND " +
					Data.MIMETYPE + "='" + Data.CONTENT_TYPE+"'", null);
			if (mod == 0){
				values.put(Data.MIMETYPE, Data.CONTENT_TYPE);
				values.put(Data.RAW_CONTACT_ID, rawIdContact);
				cr.insert(Data.CONTENT_URI, values);
			}
		}catch (SQLiteException e) {
			fine = false;
			logger.error("Update or create contact fase 1:"+e);
		}

		try {
			values.clear();
			values.put(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, contact.getDisplayName());
			mod = cr.update(Data.CONTENT_URI, values, 
					Data.RAW_CONTACT_ID+ "="+ rawIdContact +" AND " +
					Data.MIMETYPE + "='" + StructuredName.CONTENT_ITEM_TYPE+"'", null);
			if (mod == 0){
				values.put(Data.MIMETYPE, StructuredName.CONTENT_ITEM_TYPE);
				values.put(Data.RAW_CONTACT_ID, rawIdContact);
				cr.insert(Data.CONTENT_URI, values);
			}

		}catch (SQLiteException e) {
			fine = false;
			logger.error("Update or create contact fase 2:"+e);
		}         


		try{
			values.clear();
			values.put(ContactsContract.CommonDataKinds.Phone.NUMBER, contact.getPhones().get(0).getNumber());
			values.put(ContactsContract.CommonDataKinds.Phone.TYPE, contact.getPhones().get(0).getType());        
			mod = cr.update(Data.CONTENT_URI,values,
					Data.RAW_CONTACT_ID+"="+rawIdContact+" AND " +
					ContactsContract.CommonDataKinds.Phone.MIMETYPE + "='" +ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE+"'",null);      
			if (mod == 0){
				values.put(ContactsContract.CommonDataKinds.Phone.MIMETYPE, ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE);
				values.put(Data.RAW_CONTACT_ID, rawIdContact);
				cr.insert(Data.CONTENT_URI, values);
			}    

		}catch (SQLiteException e) {
			fine = false;
			logger.error("Update or create contact fase 3:"+e);
		}


		try{
			values.clear();
			values.put(Data.DATA1, String.valueOf(contact.getQuickDial()));
			mod = cr.update(Data.CONTENT_URI,values,                     
					Data.RAW_CONTACT_ID + "=" + rawIdContact + " AND " +
					Data.MIMETYPE + "= '"   + MIMETYPE_CONTACT_QUICKDIAL  + "'", null);              
			if (mod == 0) 
			{                 
				values.put(Data.RAW_CONTACT_ID, rawIdContact);                 
				values.put(Data.MIMETYPE, MIMETYPE_CONTACT_QUICKDIAL);
				cr.insert(Data.CONTENT_URI, values);
			}   

			values.clear();
			values.put(Data.DATA2, String.valueOf(contact.getIdPlat()));       
			mod = cr.update(Data.CONTENT_URI,values,          
					Data.RAW_CONTACT_ID + "=" + rawIdContact + " AND " +
					Data.MIMETYPE + "= '"   + MIMETYPE_CONTACT_IDPLATFORM  + "'", null);              
			if (mod == 0) 
			{                 
				values.put(Data.RAW_CONTACT_ID, rawIdContact);                 
				values.put(Data.MIMETYPE, MIMETYPE_CONTACT_IDPLATFORM);
				cr.insert(Data.CONTENT_URI, values);
			} 

		}catch (SQLiteException e) {
			fine = false;
			logger.error("Update or create contact fase 4:"+e);
		}

		return fine;
	}



	/**
	 * Method to get basic data of a contact
	 * @param idContact
	 * @param loadphoto, it indicates if is necessary or not load photo into basic data
	 * @return Contact
	 */
	public Contact getContactBasicData(String idContact, boolean loadphoto){
		Contact contactInfo = null;

		// Load the display name for the specified person
		Uri contactUri = ContactsContract.Contacts.CONTENT_URI;
		//FIXME Mirar si este o el otro
		//Uri rawContactUri = RawContacts.CONTENT_URI;
		Uri uri = ContentUris.withAppendedId(contactUri, Long.valueOf(idContact));
		Cursor cursor = cr.query(uri, 
				new String[]{Contacts._ID, Contacts.DISPLAY_NAME, Contacts.HAS_PHONE_NUMBER}, null, null, null);      

		try {
			if (cursor != null){
				if (cursor.moveToFirst()) {
					contactInfo = new Contact();
					contactInfo.setId(idContact);
					contactInfo.setDisplayName(cursor.getString(1));  

					if (Integer.parseInt(cursor.getString(2)) > 0){
						ArrayList<MPhone> phones = null;
						if (contactInfo != null){
							phones = getPhonesByIdContact(contactInfo.getId());           
							contactInfo.setPhones(phones);
						}   
					}             

					if (loadphoto){
						Bitmap photo = getPhotoBitmap(String.valueOf(idContact));
						contactInfo.setPhotoBitmap(photo);
					} 

					String quickDial = getQuickOrderData(idContact);
					if (quickDial != null){
						contactInfo.setQuickDial(Integer.parseInt(quickDial));
					}
				}
			}else{
				logger.info("getContactBasicData# no data found!!");
			}
		}catch (Exception e) {
			logger.error("Error getContactBasicData:"+e);

		}finally{
			if (cursor != null)
				cursor.close();
		}
		return contactInfo;
	}

	/**
	 * Method to get all(advanced) contact data
	 * @param idContact
	 * @return Contact
	 */    
	public Contact getContactData(String idContact) {

		Contact contactInfo = getContactBasicData(idContact,true);        
		//String idPlatform = getIdPlatformData(idContact);
		//contactInfo.setIdPlat(idPlatform);
		//contactInfo.setEmails(getEmailsByIdContact(idContact));


		return contactInfo;  // <-- returns info for contact
	}

	/**
	 * Method to get phones list of a contact    
	 * @param idContact
	 * @return ArrayList of phones
	 */
	protected ArrayList<MPhone> getPhonesByIdContact(String idContact){
		ArrayList<MPhone> phones = null;
		MPhone phone = null;
		// GET PHONE NUMBERS WITH QUERY STRING

		Cursor phoneCursor = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,null,ContactsContract.CommonDataKinds.Phone.CONTACT_ID
				+ " = ?", new String[] { idContact }, null);
		if (phoneCursor != null){
			if (phoneCursor.getCount()>0){ 
				phones = new ArrayList<MPhone>(0);
				// WHILE WE HAVE CURSOR GET THE PHONE NUMERS
				while (phoneCursor.moveToNext()) {
					// Do something with phones
					String phoneNumber = phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DATA));
					int phoneType = phoneCursor.getInt(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE));
					phone = new MPhone(phoneNumber, phoneType);
					phones.add(phone);

				}

			}
			phoneCursor.close();
		}
		return phones;
	}

	/**
	 * Return if exists or not exists a contact in phones contact database with this displayName AND this phoneNumber
	 * @param ct
	 * @param phoneNumber
	 * @param name
	 * @return boolean
	 */
	public boolean existsContactPhoneNumber(String phoneNumber, String name){

		Uri lookupUri = Uri.withAppendedPath(PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber));
		Cursor c = cr.query(lookupUri, new String[]{PhoneLookup.DISPLAY_NAME},null,null,null);
		String displayName = "";
		boolean idem = false;
		if (c != null){
			try {
				if (c.moveToFirst()){
					displayName = c.getString(0);            
					idem = (name.equalsIgnoreCase(displayName));  
					logger.debug("ContactBO ("+name+", "+phoneNumber+") EXISTS?? ->> "+idem);
				}
			} finally {
				c.close();
			}  
		}
		return idem;       
	}

	/**
	 * Get a contact by its phone number
	 * @param phoneNumber
	 * @return Contact
	 */
	public Contact getContactByPhoneNumber(String phoneNumber){

		Contact contact = null;

		Uri lookupUri = Uri.withAppendedPath(PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber));
		Cursor c = cr.query(lookupUri, new String[]{PhoneLookup.DISPLAY_NAME,PhoneLookup.TYPE},null,null,null);

		if (c!=null){
			try {


				if (c.moveToFirst()){
					contact = new Contact();
					String id = getIdContactByDisplayName(c.getString(0));                
					contact = getContactBasicData(id,true);
				}
			} finally {
				c.close();
			}  
		}else{
			logger.info("#getContactByPhoneNumber, phoneNumber NOT FOUND!!: "+phoneNumber);
		}
		return contact;       
	}

	/**
	 * Get the contact id for the contact with this display name
	 * @param displayName
	 * @return idContact
	 */
	public String getIdContactByDisplayName(String displayName){
		String idContact = null;

		Cursor cursor = cr.query(ContactsContract.Contacts.CONTENT_URI, null,
				"DISPLAY_NAME = '" + displayName + "'", null, null);
		if (cursor.moveToFirst()) {  
			idContact = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));
			cursor.close();
		}    
		return idContact;
	}

	/**
	 * 
	 * @param displayName
	 * @return the contact id
	 */
	public String addContactToPhoneDb(String displayName) {
		ContentValues values =  new ContentValues();

		//INSERT INTO CONTACT GUIA
		values.put(Data.DISPLAY_NAME, displayName);
		Uri rawContactUri = cr.insert(RawContacts.CONTENT_URI, values);
		String rawContactid = String.valueOf(ContentUris.parseId(rawContactUri)); 
		return rawContactid;

	}

	/**
	 * Get the quick order for the contact with this contact id
	 * @param idContact
	 * @return quick order of this contact
	 */    
	public String getQuickOrderData(String idContact){
		String data1 = null;
		Cursor cursor = cr.query(Data.CONTENT_URI, 
				null, Data.CONTACT_ID + "=? AND " + 
				Data.MIMETYPE +  "= '"   + MIMETYPE_CONTACT_QUICKDIAL  + "'", 
				new String[] { String.valueOf(idContact) }, null);
		if (cursor != null){
			while(cursor.moveToNext()){
				data1 = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.Data.DATA1));
			}
			cursor.close();
		}
		return data1;       
	}

	/**
	 * Get platform id for the contact with this contact id
	 * @param idContact
	 * @return idPlatform
	 */
	protected String getIdPlatformData(String idContact){
		String data2 = "";
		Cursor cursor = cr.query(Data.CONTENT_URI, 
				null, Data.CONTACT_ID + "=? AND " + 
				Data.MIMETYPE +  "= '"   + MIMETYPE_CONTACT_IDPLATFORM  + "'", 
				new String[] { String.valueOf(idContact) }, null);
		if (cursor != null){
			while(cursor.moveToNext()){
				data2 = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.Data.DATA2));

			}
			cursor.close();
		}
		return data2;

	}

	/**
	 * Get the photo bitmap 
	 * @param idContact
	 * @return photo Bitmap
	 */
	protected Bitmap getPhotoBitmap(String idContact) {

		long id = Long.valueOf(idContact);      
		Uri contactPhotoUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, id);
		// contactPhotoUri --> content://com.android.contacts/contactBOs/1557
		InputStream photoDataStream = Contacts.openContactPhotoInputStream(cr,contactPhotoUri); // <-- always null
		Bitmap photo = BitmapFactory.decodeStream(photoDataStream);
		return photo;
	}

	/**
	 * Get emails for contact id
	 * @param idContact
	 * @return list of emails
	 */
	protected ArrayList<Email> getEmailsByIdContact(String idContact) {
		ArrayList<Email> emails = null;
		Cursor emailCursor = cr.query(ContactsContract.CommonDataKinds.Email.CONTENT_URI, 
				null, 
				ContactsContract.CommonDataKinds.Email.CONTACT_ID  + " = ?", 
				new String[] { idContact },
				null);
		if (emailCursor != null){
			if (emailCursor.getCount()>0){
				emails = new ArrayList<Email>();

				while (emailCursor.moveToNext()) {
					// This would allow you get several email addresses
					// if the email addresses were stored in an array
					String email = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA));
					String emailType = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE));
					emails.add(new Email(email, emailType));

				}
			}
			emailCursor.close();
		}
		return emails;
	}

	/**
	 * Get contact id for the contact with this raw contact id
	 * @param rawContactId
	 * @return contact id
	 */
	public String getContactId(String rawIdContact) {

		long raw = Long.valueOf(rawIdContact);
		Cursor cur = null;
		String res = null;
		try {
			cur = cr.query(ContactsContract.RawContacts.CONTENT_URI, new String[] { ContactsContract.RawContacts.CONTACT_ID }, ContactsContract.RawContacts._ID + "=" + raw, null, null);
			if (cur.moveToFirst()) {
				res = cur.getString(cur.getColumnIndex(ContactsContract.RawContacts.CONTACT_ID));				 
			}
		} catch (Exception e) {
			logger.error("Error looking for idContact for rawcontact = "+rawIdContact);
		} finally {
			if (cur != null) {
				cur.close();
			}
		}
		return res;
	}

	/**
	 * Get a general contact cursor
	 * @return Cursor
	 */    
	public Cursor getCursor() {

		String selection = ContactsContract.Contacts.IN_VISIBLE_GROUP + " = '" + (false ? "0" : "1") + "'";
		String sortOrder = ContactsContract.Contacts.DISPLAY_NAME + " COLLATE LOCALIZED ASC";
		Uri uri = ContactsContract.Contacts.CONTENT_URI;
		/*
       String[] projection = new String[] {
               ContactsContract.Contacts._ID,
               ContactsContract.Contacts.DISPLAY_NAME,

       };
		 */

		return cr.query(uri, null, selection, null, sortOrder);
	}

	public boolean delete(Contact contact) {

		String idContact = getIdContactByDisplayName(contact.getDisplayName());        
		if (idContact != null){
			//if id is contact id
			ArrayList<ContentProviderOperation> ops = new ArrayList<ContentProviderOperation>(); 
			String[] args = new String[] {idContact}; 
			ops.add(ContentProviderOperation.newDelete(RawContacts.CONTENT_URI).withSelection(RawContacts.CONTACT_ID + "=?", args) .build());
			//if id is raw contact id
			//ops.add(ContentProviderOperation.newDelete(RawContacts.CONTENT_URI).withSelection(RawContacts._ID + "=?", args) .build());
			try {
				cr.applyBatch(ContactsContract.AUTHORITY, ops);
				return true;
			} catch (RemoteException e) {
				logger.error("Error Delete a contact: "+e);
				return false;
			} catch (OperationApplicationException e1) {
				logger.error("Error Delete a contact: "+e1);
				return false;
			}
		}else{
			logger.error("Imposible to delete, this contact NOT EXITS!!");
			return  false;
		}

	}


	public String getRawIdContactById(String idContact){
		String rawIdContact = null;

		Cursor c = cr.query(RawContacts.CONTENT_URI,
				new String[]{RawContacts._ID},
				RawContacts.CONTACT_ID + "=?",
				new String[]{String.valueOf(idContact)}, null);
		try {
			if (c.moveToFirst()){
				rawIdContact = c.getString(0);
			}
		}finally{
			if (c!= null){
				c.close();
			}
		}
		return rawIdContact;
	}

}
