package es.tid.ehealth.mobtel.android.app.ui;

import java.util.ArrayList;

import android.app.Activity;
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
		return (long) position;
	}
}
