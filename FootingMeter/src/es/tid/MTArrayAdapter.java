package es.tid;

import java.util.ArrayList;


import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class MTArrayAdapter<T> extends ArrayAdapter<String> {

    // static to save the reference to the outer class and to avoid access to
    // any members of the containing class
    static class ViewHolder {
        public TextView textView1;
    }

    private final Activity context;

    private final ArrayList<T> entities;

    /**
     * Default constructor
     * 
     * @param context
     * @param ids
     * @param contacts
     */
    public MTArrayAdapter(final Activity context, final String[] ids, final ArrayList<T> entities) {
        super(context, R.layout.rowcontact_layout, ids);
        this.context = context;
        this.entities = entities;
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
            rowView.setTag(holder);
        } else {
            holder = (ViewHolder) rowView.getTag();
        }
        String label1 = "";
        if (entities == null){
            label1 = "No contacts";
        }else{
            label1 = entities.get(position).toString();
        }
        holder.textView1.setText(label1);
        

        return rowView;
    }
}    