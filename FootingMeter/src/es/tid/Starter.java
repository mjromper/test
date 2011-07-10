package es.tid;


import android.app.TabActivity;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TabHost;
import es.tid.tabs.HomeGroupActivity;
import es.tid.tabs.RecordsGroupActivity;


public class Starter extends TabActivity {

	private static final int EXIT = 0;
	private TabHost tabHost;


	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);

		// Resources res = getResources(); // Resource object to get Drawables
		final String home = getString(R.string.home_tab);
		final String map = getString(R.string.stored_tab);
		final Resources res = getResources();

		tabHost = getTabHost();

		tabHost.addTab(tabHost.newTabSpec(home).setIndicator(home, res.getDrawable(R.drawable.ic_tab_home)).setContent(
				new Intent(this, HomeGroupActivity.class)));
		
		tabHost.addTab(tabHost.newTabSpec(map).setIndicator(map, res.getDrawable(R.drawable.ic_tab_map))
				.setContent(new Intent(this, RecordsGroupActivity.class)));

		

		tabHost.setCurrentTab(0);
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu)
	{
		menu.add(0,EXIT,0,"Exit");
		return true;
	}
	
	public boolean onOptionsItemSelected (MenuItem item){

		switch (item.getItemId()){


		case EXIT :   
			finish();
			return true;
		}
		return false;
	}


}