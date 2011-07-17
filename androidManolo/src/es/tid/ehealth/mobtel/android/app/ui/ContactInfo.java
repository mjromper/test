package es.tid.ehealth.mobtel.android.app.ui;

import java.io.InputStream;
import java.util.ArrayList;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.telephony.SmsManager;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.bo.MPhone;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;

public class ContactInfo extends AppActivity{

	private static final Logger logger = LoggerFactory.getLogger(ContactInfo.class);
	
	public static final String ID_CONTACT = "idContact";

	public static final int GET_CONTACT = 0;
	private String idContact = "";
	
	
	private Button buttonCall;
	private Button buttonSendSMS;
	private TextView nameConcat;
	private TextView phoneContact;
	private ImageView imageContact;
	
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		 super.onCreate(savedInstanceState);
	     setContentView(R.layout.contactinfo_layout);
	  
	     // Obtain handles to UI objects
	     buttonCall = (Button) findViewById(R.id.buttoncall); 
	     buttonCall.setOnClickListener(new View.OnClickListener() {
	            public void onClick(View v) {
	            	logger.debug("Call button clicked");
	                callTo(phoneContact.getText().toString());
	            }
	        });
	     buttonSendSMS = (Button) findViewById(R.id.buttonsms);
	     buttonSendSMS.setOnClickListener(new View.OnClickListener() {
	            public void onClick(View v) {
	            	logger.debug("Send SMS button clicked");
	                sendSMS2(phoneContact.getText().toString());
	            }
	        });
	     nameConcat = (TextView) findViewById(R.id.textname);
	     phoneContact = (TextView) findViewById(R.id.textphone);
	     imageContact = (ImageView) findViewById(R.id.userimage);
	     imageContact.setOnClickListener(new View.OnClickListener() {
	            public void onClick(View v) {
	            	logger.debug("ContactBO image button clicked");
	                callTo(phoneContact.getText().toString());
	            }
	        });
	     
	     Bundle extras = getIntent().getExtras();
	     idContact  = extras.getString(ID_CONTACT);
	     
	     Contact c = getContact();
	     nameConcat.setText(c.getDisplayName());
	     phoneContact.setText(c.getPhones().get(0).getNumber());     
	     
	     //Bitmap bMap = BitmapFactory.decodeFile("/sdcard/test2.png");
	     Bitmap bMap = c.getPhotoBitmap();
	     imageContact.setImageBitmap(bMap);
	     
	}

	
	private Contact getContact() {
		Contact contactBO = null;
    	ContentResolver cr = getContentResolver();

    	String selection = ContactsContract.Contacts.IN_VISIBLE_GROUP + " = '" + (false ? "0" : "1") + "'";
    	String sortOrder = ContactsContract.Contacts.DISPLAY_NAME + " COLLATE LOCALIZED ASC";
    	Uri uri = ContactsContract.Contacts.CONTENT_URI;
    	/*
    	String[] projection = new String[] {
    			ContactsContract.Contacts._ID,
    			ContactsContract.Contacts.DISPLAY_NAME,

    	};
    	*/

    	Cursor cursor = cr.query(uri, null, selection, null, sortOrder);

    	if (cursor.getCount() > 0) {

    		while (cursor.moveToNext()) {
    			
    			// ID AND NAME FROM CONTACTS CONTRACTS
    			String id = cursor.getString(cursor
    					.getColumnIndex(ContactsContract.Contacts._ID));
    			String name = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));

    			if (idContact.equals(id)){
    				contactBO = new Contact();
    				logger.debug("ContactBO seleted id = "+id);
    				logger.debug("ContactBO seleted name = "+name);
    				contactBO.setId(id);
    				contactBO.setDisplayName(name);

    				ArrayList<MPhone> phones = null;
    				// GET PHONE NUMBERS WITH QUERY STRING
    				if (Integer.parseInt(cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER))) > 0) {
    					Cursor phoneCursor = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,null,ContactsContract.CommonDataKinds.Phone.CONTACT_ID
    							+ " = ?", new String[] { id }, null);

    					if (phoneCursor.getCount()>0){
    						phones = new ArrayList<MPhone>();
    					}
    					// WHILE WE HAVE CURSOR GET THE PHONE NUMERS
    					while (phoneCursor.moveToNext()) {
    						// Do something with phones
    						String phone = phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DATA));    					
    						int phoneType = phoneCursor.getInt(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE));

    						phones.add(new MPhone(phone,phoneType));
    						logger.debug("ContactBO phones :"+phone+" ,TYPE = "+phoneType);
    						
    					}
    					phoneCursor.close();
    				}
    				contactBO.setPhones(phones);

    				//PHOTO
    				Bitmap photo = getPhoto(cr, Long.valueOf(id));
    				contactBO.setPhotoBitmap(photo);

    				//WHILE WE HAVE CURSOR GET THE EMAIL 
    				/*
    				Cursor emailCursor = cr.query(ContactsContract.CommonDataKinds.Email.CONTENT_URI, null, ContactsContract.CommonDataKinds.Email.CONTACT_ID	+ " = ?", new String[] { id }, null);
    				ArrayList<Email> emails = null;
    				if (emailCursor.getCount()>0){
    					emails = new ArrayList<Email>();
    				}
    				while (emailCursor.moveToNext()) {
    					// This would allow you get several email addresses
    					// if the email addresses were stored in an array
    					String email = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA));
    					String emailType = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE));
    					emails.add(new Email(email, emailType));
    					logger.debug("ContactBO email :"+email+" ,TYPE = "+emailType);
    				
    				}
    				emailCursor.close();
    				contact.setEmail(emails);
    				*/
    				
    				break;
    			}    			
    		}
    	}
    	
    	return contactBO;
	}
	
	private void callTo(String phoneNumber){
		
		Intent i = new Intent();
		i.setAction(Intent.ACTION_CALL);
		i.setData(Uri.parse("tel:" + phoneNumber));
		startActivity(i);
	}
	
	private void sendSMS(String phoneNumber){

		Intent i = new Intent();
		i.setAction(Intent.ACTION_SENDTO);
		i.setData(Uri.parse("smsto:" + phoneNumber));
		startActivity(i);
		
    }
	
	private void sendSMS2(String phoneNumber){

		SmsManager m = SmsManager.getDefault();
		m.sendTextMessage(phoneNumber, null, "holaaaa teleasistiiiido", null, null);
		
    }
	
    
    public Bitmap getPhoto(ContentResolver contentResolver, Long contactId) {
        Uri contactPhotoUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, contactId);

        // contactPhotoUri --> content://com.android.contacts/contacts/1557

        InputStream photoDataStream = Contacts.openContactPhotoInputStream(contentResolver,contactPhotoUri); // <-- always null
        Bitmap photo = BitmapFactory.decodeStream(photoDataStream);
        return photo;
    }
    
    public static void launch(Context context) {
		Intent i = new Intent(context,ContactInfo.class);
		context.startActivity(i);
		
	}

}
