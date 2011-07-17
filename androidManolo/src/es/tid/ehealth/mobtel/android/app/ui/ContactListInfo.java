package es.tid.ehealth.mobtel.android.app.ui;

import java.util.HashMap;
import java.util.Iterator;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.components.AppListActivity;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class ContactListInfo extends AppListActivity {

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

    private HashMap<String, Contact> contacts;

    /**
     * Fill this activity with contacts data
     */
    private void fillData() {

        final ContactService contactS = new ContactServiceImpl(this);
        contacts = contactS.getAllContactsData();
        if (contacts != null) {
            final String[] ids = new String[contacts.size()];

            final Iterator<String> it2 = contacts.keySet().iterator();
            int i = 0;
            while (it2.hasNext()) {
                ids[i] = it2.next();
                i++;
            }

            this.setListAdapter(new MyArrayAdapter(this, ids, contacts));
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
        // Get the item that was clicked
        final Object o = this.getListAdapter().getItem(position);
        final String keyword = o.toString();
        Toast.makeText(this, "You selected: " + keyword, Toast.LENGTH_SHORT).show();

        final Intent i = new Intent();
        i.setAction(Intent.ACTION_CALL);
        i.setData(Uri.parse("tel:" + contacts.get(keyword).getPhones().get(0).getNumber()));
        startActivity(i);
        finish();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

}

class MyArrayAdapter extends ArrayAdapter<String> {

    // static to save the reference to the outer class and to avoid access to
    // any members of the containing class
    static class ViewHolder {
        public ImageView imageView;
        public TextView textView1;
        public TextView textView2;
    }

    private static final Logger logger = LoggerFactory.getLogger(MyArrayAdapter.class);
    private final Activity context;
    private final String[] ids;

    private final HashMap<String, Contact> contacts;

    /**
     * Default constructor
     * 
     * @param context
     * @param ids
     * @param contacts
     */
    public MyArrayAdapter(final Activity context, final String[] ids, final HashMap<String, Contact> contacts) {
        super(context, R.layout.rowcontact_layout, ids);
        this.context = context;
        this.ids = ids;
        this.contacts = contacts;
    }

    @Override
    public View getView(final int position, final View convertView, final ViewGroup parent) {
        // ViewHolder will buffer the assess to the individual fields of the row
        // layout

        ViewHolder holder;
        // Recycle existing view if passed as parameter
        // This will save memory and time on Android
        // This only works if the base layout for all classes are the same
        View rowView = convertView;
        if (rowView == null) {
            final LayoutInflater inflater = context.getLayoutInflater();
            rowView = inflater.inflate(R.layout.rowcontact_layout, null, true);
            holder = new ViewHolder();
            holder.textView1 = (TextView) rowView.findViewById(R.id.labelcontact);
            holder.imageView = (ImageView) rowView.findViewById(R.id.iconcontact);
            holder.textView2 = (TextView) rowView.findViewById(R.id.labelcontactphone);
            rowView.setTag(holder);
        } else {
            holder = (ViewHolder) rowView.getTag();
        }
        final String idContact = ids[position];
        logger.debug("Contact to be drawn: " + idContact);
        holder.imageView.setImageResource(R.drawable.icon);

        String label1 = contacts.get(idContact).getDisplayName();
        final String label2 = contacts.get(idContact).getPhones().get(0).getNumber();
        final boolean isQuickDial = contacts.get(idContact).getQuickDial() != 0;
        if (isQuickDial) {
            label1 = label1 + " (QD " + contacts.get(idContact).getQuickDial() + ")";
        }
        holder.textView1.setText(label1);
        holder.textView2.setText(label2);
        if (contacts.get(idContact).getPhotoBitmap() != null) {
            holder.imageView.setImageBitmap(contacts.get(idContact).getPhotoBitmap());
        }

        return rowView;
    }
}