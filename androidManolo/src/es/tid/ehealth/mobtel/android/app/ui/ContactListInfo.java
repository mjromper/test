package es.tid.ehealth.mobtel.android.app.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class ContactListInfo extends ListActivity {

	private static final Logger logger = LoggerFactory.getLogger(ContactListInfo.class);

	/**
	 * Launch this activity
	 * 
	 * @param context
	 */
	public static void launch(final Context context) {
		final Intent i = new Intent(context, ContactListInfo.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(i);
	}

	private ArrayList<Contact> contacts;

	/**
	 * Fill this activity with contacts data
	 */
	private void fillData() {

		final ContactService contactS = new ContactServiceImpl(this);
		contacts = contactS.getAllContactsData();
		if (contacts != null) {
			this.setListAdapter(new MyArrayAdapter(this, contacts));
		}

	}

	/**
	 * Called when the activity is first created. *
	 */
	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		fillData();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.ListActivity#onListItemClick(android.widget.ListView, android.view.View, int, long)
	 */
	@Override
	protected void onListItemClick(final ListView l, final View v, final int position, final long id) {
		super.onListItemClick(l, v, position, id);
		Contact selected = contacts.get(position);
		// Get the item that was clicked
		//Toast.makeText(this, "You selected: " + position, Toast.LENGTH_SHORT).show();
		if (selected.getPhones() != null && selected.getPhones().size() > 0 && selected.getPhones().get(0)!= null 
				&& selected.getPhones().get(0).getNumber() != null){

			final Intent i = new Intent();
			i.setAction(Intent.ACTION_CALL);
			String number = selected.getPhones().get(0).getNumber();
			if (!number.startsWith("0034")){
				number = "0034"+number;			
			}
			i.setData(Uri.parse("tel:" + number));
			startActivity(i);
			finish();
		}else{
			Toast.makeText(this, "This contact has no phone number to make call", Toast.LENGTH_SHORT).show();
		}


	}

	@Override
	protected void onStart() {
		super.onStart();
	}

}

class MyArrayAdapter extends  BaseAdapter {

	// static to save the reference to the outer class and to avoid access to
	// any members of the containing class
	static class ViewHolder {
		public ImageView imageView;
		public TextView contactName;
		public TextView contactPhone;
	}

	private static final Logger logger = LoggerFactory.getLogger(MyArrayAdapter.class);
	private final Activity context;

	private final ArrayList<Contact> contacts;

	/**
	 * Default constructor
	 * 
	 * @param context
	 * @param ids
	 * @param contacts
	 */
	public MyArrayAdapter(final Activity context , final ArrayList<Contact> contacts) {
		this.context = context;
		this.contacts = contacts;
	}

	@Override
	public View getView(final int position, final View convertView, final ViewGroup parent) {
		View rowView = convertView;
		if (contacts != null){
			Contact contact = contacts.get(position);
			String label1 = contact.getDisplayName();
			String label2 = "";


			ViewHolder holder;
			if (rowView == null) {
				final LayoutInflater inflater = context.getLayoutInflater();
				rowView = inflater.inflate(R.layout.rowcontact_layout, null, true);
				holder = new ViewHolder();
				holder.contactName = (TextView) rowView.findViewById(R.id.labelcontact);
				holder.imageView = (ImageView) rowView.findViewById(R.id.iconcontact);
				holder.contactPhone = (TextView) rowView.findViewById(R.id.labelcontactphone);
				rowView.setTag(holder);
			} else {
				holder = (ViewHolder) rowView.getTag();
			}
			holder.imageView.setImageResource(R.drawable.icon);
			holder.contactName.setText(label1);

			try {
				if (contact.getPhones() != null && contact.getPhones().size() > 0 && contact.getPhones().get(0)!= null 
						&& contact.getPhones().get(0).getNumber() != null){
					label2 = contact.getPhones().get(0).getNumber();
				}
				holder.contactPhone.setText(label2);
			}catch (Exception e) {
				logger.error("Error Adapter: "+e);
			}					

			if (contact.getPhotoBitmap() != null) {
				holder.imageView.setImageBitmap(contact.getPhotoBitmap());
			}
		}

		return rowView;
	}

	@Override
	public int getCount() {		
		return contacts.size();
	}

	@Override
	public Object getItem(int position) {
		return contacts.get(position);
	}

	@Override
	public long getItemId(int position) {		
		return position;
	}
}