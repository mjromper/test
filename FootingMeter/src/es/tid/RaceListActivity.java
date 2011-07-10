package es.tid;

import java.util.ArrayList;

import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbRacesAccess;
import es.tid.gmaps.FootingMeterActivity;



/**
 * SettingsListActivity class for HatHDroid project
 *
 * @author mjrp
 */
public class RaceListActivity extends ListActivity {


    private ArrayList<Race> races;

	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);        
        fillData();        
    }
    
    private void fillData() {
        DbRacesAccess racesDB = new DbRacesAccess(getApplicationContext(), DbRacesAccess.DB_NAME);
        
        races = racesDB.findAll();
        if (races != null){
            final String[] ids = new String[races.size()];
            for (int i=0; i < races.size(); i++){
                ids[i] = races.get(i).getPkey().toString();            
            }
            this.setListAdapter(new MTArrayAdapter<Race>(this, ids, races));
        }       
        
    }  
    
    /**
     * Launch this activity
     * 
     * @param context
     */
    public static void launch(final Context context) {
        final Intent i = new Intent(context, RaceListActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(i);
    }

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		Toast.makeText(getApplicationContext(), "Race selected: "+id, Toast.LENGTH_LONG).show();
		//super.onListItemClick(l, v, position, id);
		if (races != null && races.get((int)id) != null){
			FootingMeterActivity.launch(getApplicationContext(), races.get((int)id));
		}
	}
    
    
    

}
