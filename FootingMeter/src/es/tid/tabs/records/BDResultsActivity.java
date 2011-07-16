package es.tid.tabs.records;

import java.util.ArrayList;

import android.app.ListActivity;
import android.os.Bundle;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbRacesAccess;
import es.tid.gmaps.FootingMeterActivity;
import es.tid.tabs.home.UtilsStride;

public class BDResultsActivity extends ListActivity
{
	private static final int VIEW_RACE_ON_MAP = 0;
	private static final int DELETE_RACE = 1;
	private ListView listLV;
	private ResultsAdapter adapter;
	private ArrayList<Race> recordsList;
	private Race selectedRace;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		listLV = this.getListView();

		recordsList = new ArrayList<Race>();

		registerForContextMenu(listLV);

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
		}else{
			listLV.setAdapter(null);
		}
	}

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		Toast.makeText(getApplicationContext(), "Race  selected: "+id, Toast.LENGTH_LONG).show();
		getSelectedRace(id);
		if (selectedRace != null){
			FootingMeterActivity.launch(getApplicationContext(), selectedRace, 1);
		}

	}



	private void getSelectedRace(long id) {
		if (recordsList != null && recordsList.get((int)id) != null){
			selectedRace = recordsList.get((int)id);
		}		
	}

	@Override  
	public void onCreateContextMenu(ContextMenu menu, View v,ContextMenuInfo menuInfo) {  
		super.onCreateContextMenu(menu, v, menuInfo);  
		menu.setHeaderTitle("Race options");  
		menu.add(0, VIEW_RACE_ON_MAP, 0, "View on the map");  
		menu.add(0, DELETE_RACE, 0, "Delete");  
	}  

	@Override  
	public boolean onContextItemSelected(MenuItem item) {  
		getSelectedRace(getSelectedItemId());
		if (selectedRace != null){
			switch (item.getItemId()) {
			case VIEW_RACE_ON_MAP:
				FootingMeterActivity.launch(getApplicationContext(), selectedRace, 1);
				break;
			case DELETE_RACE:
				UtilsStride.deleteRace(selectedRace.getPkey());
				onResume();
				break;
			default:
				break;
			}
			return true;
		}

		return false;

	}  


}