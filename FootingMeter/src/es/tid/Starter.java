package es.tid;


import android.app.TabActivity;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TabHost;

import com.google.code.microlog4android.Level;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.appender.FileAppender;
import com.google.code.microlog4android.config.PropertyConfigurator;
import com.google.code.microlog4android.format.PatternFormatter;

import es.tid.tabs.HomeGroupActivity;
import es.tid.tabs.RecordsGroupActivity;
import es.tid.tabs.home.UtilsFooting;


public class Starter extends TabActivity {
	
	private static final Logger logger = LoggerFactory.getLogger(Starter.class);


	private static final int EXIT = 1;
	
	private TabHost tabHost;


	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		micrologMainConfigurator();
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
		
		UtilsFooting.setMainActivity(this);	
		
		logger.info("FootingMeter APP started!!!");
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
			/*LocationManager lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
			if (lm.isProviderEnabled(LocationManager.GPS_PROVIDER)){  
				UtilsFooting.createGpsDisabledAlert(this);  
			} */	
			finish();
			return true;
		}
		return false;
	}
	
	/**
	 * Configure microlog
	 */
	private void micrologMainConfigurator() {

		PropertyConfigurator.getConfigurator(this).configure();
		int numApp = LoggerFactory.getLogger().getNumberOfAppenders();

		PatternFormatter formatter = new PatternFormatter();
		//formatter.setPattern("[%d] [%t] [%P] %c - %m %T");
		formatter.setPattern("[%d]%:[%P] [%c] - %m %T");        

		for (int i=0;i<numApp;i++){
			//if (LoggerFactory.getLogger().getAppender(i).toString().contains("FileAppender")){
			//LoggerFactory.getLogger().removeAppender(LoggerFactory.getLogger().getAppender(i));
			//}else{
			LoggerFactory.getLogger().getAppender(i).setFormatter(formatter);       
			//}              
		}
		FileAppender myFileAppender = new FileAppender();
		myFileAppender.setFileName("footing_log.txt");
		myFileAppender.setFormatter(formatter);
		LoggerFactory.getLogger().addAppender(myFileAppender);
		LoggerFactory.getLogger().setLevel(Level.DEBUG);

	}

	@Override
	protected void onDestroy() {
		logger.info("FootingMeter APP closed!!!");
		super.onDestroy();
	}
	
	
	
	


}