package es.tid.gmaps;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings;
import android.view.Menu;
import android.view.MenuItem;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.google.code.microlog4android.Level;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.appender.FileAppender;
import com.google.code.microlog4android.config.PropertyConfigurator;
import com.google.code.microlog4android.format.PatternFormatter;

import es.tid.R;
import es.tid.RaceListActivity;
import es.tid.database.bo.Location;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbLocationsAccess;
import es.tid.database.impl.DbRacesAccess;
import es.tid.listener.MyLocationListener;

public class FootingMeterActivity extends MapActivity {

	private static final Logger logger = LoggerFactory.getLogger(FootingMeterActivity.class);

	private static Race race;

	private MapView mapView;
	private List<Overlay> mapOverlays;
	private Drawable drawable;
	private HelloItemizedOverlay itemizedoverlay;
	private MyLocationListener mlocListener;

	private DbRacesAccess dbRaces;

	private DbLocationsAccess dbLocations;

	private Long raceDate;

	private static final int START_RUNNIG = 0;
	private static final int STOP_RUNNING = 1;
	private static final int STORED_RACES = 2;
	private static final int EXIT = 3;



	@Override
	protected void onResume() {
		logger.info("onResume()");
		super.onResume();
	}

	@Override
	protected void onStart() {
		logger.info("onStart()");
		super.onStart();
	}

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		dbRaces = new DbRacesAccess(this, DbRacesAccess.DB_NAME);
		dbLocations = new DbLocationsAccess(this, DbLocationsAccess.DB_NAME);

		micrologMainConfigurator();		

		mapView = (MapView) findViewById(R.id.map_view);
		mapView.setBuiltInZoomControls(true);

		mapOverlays = mapView.getOverlays();
		drawable = this.getResources().getDrawable(R.drawable.icon);
		itemizedoverlay = new HelloItemizedOverlay(drawable, this);
		mapOverlays.add(itemizedoverlay);

		mapView.invalidate();

		mapView.getController().setZoom(18);
		mapView.setClickable(true);
		mapView.setEnabled(true);
		mapView.setSatellite(true);
		mapView.displayZoomControls(true);

		//initMap();

		logger.info("Footing Application Started!!!");

		if (race != null){
			drawRace2Map(race);
		}

	}

	private void drawRace2Map(final Race race) {

		resetMap();
		
		logger.info("Drawing race into map");
		ArrayList<Location> locations = dbLocations.selectLocationByRacePkey(race.getPkey());
		if (locations!=null){
			for (int i=0; i< locations.size();i++){
				addLocation2Map(locations.get(i).getLat(), locations.get(i).getLng());
			}
		}

	}


	public void addLocation2Map(double lat, double lng){

		GeoPoint point = new GeoPoint((int) (lat * 1E6),(int) (lng * 1E6));
		OverlayItem overlayitem = new OverlayItem(point, "Location", ""+lat+", "+lng);
		logger.info("Location added to MAP: "+point);
		mapView.getController().animateTo(point);
		itemizedoverlay.addOverlay(overlayitem);
		mapView.postInvalidate();
	}

	private void registerLocationListener() {

		try {
			Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, true);
			logger.info("GPS enabled !");
		} catch (Exception e) {
			logger.error("Error enabling GPS: "+e);
		}
		LocationManager mlocManager = (LocationManager)getSystemService(Context.LOCATION_SERVICE);
		mlocListener = new MyLocationListener(this);
		mlocManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 3000, 10, mlocListener);
		logger.info("Location listener registered!");

	}

	private void unRegisterLocationListener() {

		try {
			Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, false);
			logger.info("GPS dsiabled !");
		} catch (Exception e) {
			logger.error("Error disabling GPS: "+e);
		}
		if (mlocListener != null){
			LocationManager mlocManager = (LocationManager)getSystemService(Context.LOCATION_SERVICE);
			mlocManager.removeUpdates(mlocListener);
			logger.info("Location listener unregistered!");
		}

	}

	@Override
	protected boolean isRouteDisplayed() {
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

	public boolean onCreateOptionsMenu(Menu menu){

		menu.add(0,START_RUNNIG,0,"Start running");
		menu.add(0,STOP_RUNNING,0,"Stop running");
		menu.add(0,STORED_RACES,0,"Stored races");		
		menu.add(0,EXIT,0,"Exit");
		return true;

	}

	public boolean onOptionsItemSelected (MenuItem item){

		switch (item.getItemId()){

		case START_RUNNIG :

			resetMap();

			registerLocationListener();

			Race r = new Race();
			raceDate = new Date().getTime();
			r.setDate(raceDate);
			dbRaces.insert(r);	

			return true;
		case STOP_RUNNING :
			unRegisterLocationListener();
			raceDate = null;			
			return true;
		case STORED_RACES :			
			unRegisterLocationListener();
			raceDate = null;
			RaceListActivity.launch(getApplicationContext());			
			return true;
		case EXIT :   
			unRegisterLocationListener();
			finish();
			return true;
		}
		return false;
	}

	private void resetMap() {
		itemizedoverlay.clear();		
	}

	/**
	 * Launch this activity
	 * 
	 * @param context
	 */
	public static void launch(final Context context, final Race race) {
		FootingMeterActivity.race = race;
		final Intent i = new Intent(context, FootingMeterActivity.class);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(i);
	}

	public void insertLocation(double lat, double lng) {
		Location loc = new Location();
		loc.setLat(lat);
		loc.setLng(lng);

		loc.setRacePkey(dbRaces.selectRaceByDate(raceDate).getPkey());

		dbLocations.insert(loc);

	}

}





