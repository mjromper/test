package es.tid.ehealth.mobtel.android.app.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class ContactListInfo extends ListActivity {

	private static final Logger logger = LoggerFactory.getLogger(ContactListInfo.class);
	private static final int SET_AS_EMERGENCY = 0;
	private static final int SET_AS_QD1 = 1;
	private static final int SET_AS_QD2 = 2;
	private static final int SET_AS_QD3 = 3;
	private static final int SET_AS_QD4 = 4;
	private static Activity parent = null;
	private MyArrayAdapter adapter;


	/**
	 * Launch this activity
	 * 
	 * @param context
	 */
	public static void launch(Activity parentActivity) {
		parent = parentActivity;
		final Intent i = new Intent(parentActivity, ContactListInfo.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		parentActivity.startActivity(i);
	}

	private ArrayList<Contact> contacts;
	private Contact selectedContact;
	private ListView listLV;


	/**
	 * Called when the activity is first created. *
	 */
	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		listLV = this.getListView();
		registerForContextMenu(listLV);
		fillData();
	}
	
	/**
	 * Fill this activity with contacts data
	 */
	private void fillData() {
		
		final ContactService contactS = new ContactServiceImpl(this);
		contacts = contactS.getAllContactsData();
		if (contacts != null) {
			adapter = new MyArrayAdapter(this, contacts);
			listLV.setAdapter(adapter);
		}else{
			listLV.setAdapter(null);
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.ListActivity#onListItemClick(android.widget.ListView, android.view.View, int, long)
	 */
	@Override
	protected void onListItemClick(final ListView l, final View v, final int position, final long id) {
		super.onListItemClick(l, v, position, id);		
		// Get the item that was clicked
		Contact selected = contacts.get(position);
		if (selected.getPhones() != null && selected.getPhones().size() > 0 && selected.getPhones().get(0)!= null 
				&& selected.getPhones().get(0).getNumber() != null){

			final Intent i = new Intent();
			i.setAction(Intent.ACTION_CALL);
			String number = selected.getPhones().get(0).getNumber();
			if (!number.startsWith("0034")){
				number = "0034"+number;			
			}
			i.setData(Uri.parse("tel:" + number));
			parent.startActivity(i);
			finish();
		}else{
			Toast.makeText(this, "This contact has no phone number to make call", Toast.LENGTH_SHORT).show();
		}


	}

	@Override
	protected void onStart() {
		super.onStart();
	}
	
	@Override  
	public void onCreateContextMenu(ContextMenu menu, View v,ContextMenuInfo menuInfo) {  
		super.onCreateContextMenu(menu, v, menuInfo);  
		menu.setHeaderTitle("Contact Options");  
		menu.add(0, SET_AS_EMERGENCY, 0, "Set as emergency contact");  
		menu.add(0, SET_AS_QD1, 0, "Set as quick dial 1");
		menu.add(0, SET_AS_QD2, 0, "Set as quick dial 2");
		menu.add(0, SET_AS_QD3, 0, "Set as quick dial 3");
		menu.add(0, SET_AS_QD4, 0, "Set as quick dial 4");
	}  

	@Override  
	public boolean onContextItemSelected(MenuItem item) {
		Long id = getSelectedItemId();
		getSelectedContact(id);
		if (selectedContact != null){
			switch (item.getItemId()) {
			case SET_AS_EMERGENCY:				
				UtilsTelecare.emergencyNumber = selectedContact.getPhones().get(0).getNumber();
				logger.info("Set number as emergency number:" +UtilsTelecare.emergencyNumber);
				break;
			case SET_AS_QD1:
				UtilsTelecare.qd1 = selectedContact.getPhones().get(0).getNumber();
				break;
			case SET_AS_QD2:
				UtilsTelecare.qd2 = selectedContact.getPhones().get(0).getNumber();
				break;
			case SET_AS_QD3:
				UtilsTelecare.qd3 = selectedContact.getPhones().get(0).getNumber();
				break;
			case SET_AS_QD4:
				UtilsTelecare.qd4 = selectedContact.getPhones().get(0).getNumber();
				break;
			default:
				break;
			}
			return true;
		}

		return false;

	}

	private void getSelectedContact(long id) {
		if (contacts != null && contacts.get((int) id) != null){
			selectedContact = contacts.get((int) id);
		}
		
	}
	

}



