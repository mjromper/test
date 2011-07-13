package es.tid.tabs.records;

import java.util.ArrayList;

import android.app.ListActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbRacesAccess;
import es.tid.gmaps.FootingMeterActivity;

public class BDResultsActivity extends ListActivity
{
	private ListView listLV;
	private ResultsAdapter adapter;
	private ArrayList<Race> recordsList;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
    	listLV = this.getListView();

		recordsList = new ArrayList<Race>();
		
	}

	@Override
	public void onResume()
	{
		super.onResume();
		if (recordsList != null){
			recordsList.clear();
		}
		DbRacesAccess dbRaces = new DbRacesAccess(this, DbRacesAccess.DB_NAME);
		recordsList = dbRaces.findAll();
		if (recordsList != null){
			adapter = new ResultsAdapter(this, recordsList);
			listLV.setAdapter(adapter);
		}
	}
	
	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		Toast.makeText(getApplicationContext(), "Race selected: "+id, Toast.LENGTH_LONG).show();
		//super.onListItemClick(l, v, position, id);
		if (recordsList != null && recordsList.get((int)id) != null){
			FootingMeterActivity.launch(getApplicationContext(), recordsList.get((int)id), 1);
		}
	}


}