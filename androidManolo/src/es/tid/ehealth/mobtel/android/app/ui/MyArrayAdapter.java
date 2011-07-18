package es.tid.ehealth.mobtel.android.app.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.common.bo.Contact;

public class MyArrayAdapter extends  BaseAdapter {

	private static final Logger logger = LoggerFactory.getLogger(MyArrayAdapter.class);
	private final Activity activity;
	private ArrayList<Contact> contacts;
	private final String[] ids;

	/**
	 * Default constructor
	 * @param ids 
	 * 
	 * @param context
	 * @param ids
	 * @param contacts
	 */
	public MyArrayAdapter(final Activity activity , String[] ids, final ArrayList<Contact> contacts) {
		this.activity = activity;
		this.contacts = contacts;
		this.ids = ids;
	}
	
	public int getCount()
	{
		return contacts.size();
	}

	public Contact getItem(int position)
	{
		return contacts.get(position);
	}

	public long getItemId(int position)
	{
		ContactListInfo.selectedContact = getItem(position);
		return Long.valueOf(ids[position]);
	}
	
	

	@Override
	public View getView(final int position, View convertView, final ViewGroup parent) {
		if (contacts != null){
			
			if (convertView == null)
			{
				LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.rowcontact_layout, null);
			}
			
			Contact contact = contacts.get(position);
			String label1 = contact.getDisplayName();
			String label2 = "";
			
			ImageView image = (ImageView) convertView.findViewById(R.id.iconcontact);
			image.setImageResource(R.drawable.icon);
			
			TextView name = (TextView) convertView.findViewById(R.id.labelcontact);
			name.setText(label1);

			try {
				if (contact.getPhones() != null && contact.getPhones().size() > 0 && contact.getPhones().get(0)!= null 
						&& contact.getPhones().get(0).getNumber() != null){
					label2 = contact.getPhones().get(0).getNumber();
				}
				TextView phone = (TextView) convertView.findViewById(R.id.labelcontactphone);
				phone.setText(label2);
			}catch (Exception e) {
				logger.error("Error Adapter: "+e);
			}					

			if (contact.getPhotoBitmap() != null) {
				image.setImageBitmap(contact.getPhotoBitmap());
			}
		}

		return convertView;
	}

}
