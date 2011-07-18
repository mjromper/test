package es.tid.gmaps;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Chronometer;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.R;
import es.tid.database.bo.FMLocation;
import es.tid.database.bo.Race;
import es.tid.tabs.home.UtilsFooting;

public class FootingMeterActivity extends MapActivity implements LocationListener{

	private static final Logger logger = LoggerFactory.getLogger(FootingMeterActivity.class);
	private static DecimalFormat df = new DecimalFormat("0.###");
	public static final String EXTRA_RECORD = "record";
	private static final int EXIT = 0;
	private static final int SATELLITE = 1;

	private MapView mapView;
	private List<Overlay> mapOverlays;
	private Drawable drawable;
	private HelloItemizedOverlay itemizedoverlay;

	private double lat = 0, lng = 0, oldLat = 0, oldLng = 0;

	private TextView distance;

	private Chronometer chronos;
	private boolean satellite = false;
	private int record = 0;



	@Override
	protected void onResume() {
		logger.info("onResume()");
		super.onResume();
	}

	@Override
	protected void onStart() {
		logger.info("onStart()");		
		super.onStart();
		if (record == 0){	
			registerGPS();
			logger.info("onStart# GPS ON");
			chronos.setBase(SystemClock.elapsedRealtime() - UtilsFooting.totalTime);
			chronos.start();
			distance.setText("Distance: "+df.format((double) UtilsFooting.totalDistance / 1000) + " Km");
		}else{
			unRegisterGPS();
			logger.info("onStart# GPS OFF");
			chronos.setBase(SystemClock.elapsedRealtime() - UtilsFooting.actualRace.getDuration());		
			distance.setText("Distance: "+df.format((double) UtilsFooting.actualRace.getDistance() / 1000) + " Km");
		}
	}

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		distance = (TextView) findViewById(R.id.map_distance);
		chronos = (Chronometer) findViewById(R.id.map_chrono);

		mapView = (MapView) findViewById(R.id.map_view);
		mapView.setBuiltInZoomControls(true);

		mapOverlays = mapView.getOverlays();
		if (UtilsFooting.actualRace != null){
			if (UtilsFooting.actualRace.getType().equals("On foot")){
				UtilsFooting.market = R.drawable.icon_run;
			}else{
				UtilsFooting.market = R.drawable.icon_bike;
			}
		}
		drawable = this.getResources().getDrawable(UtilsFooting.market);
		itemizedoverlay = new HelloItemizedOverlay(drawable, this);
		mapOverlays.add(itemizedoverlay);

		mapView.invalidate();

		mapView.getController().setZoom(18);
		mapView.setClickable(true);
		mapView.setEnabled(true);		
		mapView.displayZoomControls(true);
		mapView.setSatellite(satellite);

		Bundle extras = getIntent().getExtras();
		record   = extras.getInt(EXTRA_RECORD);	

		if (UtilsFooting.actualRace != null){
			drawRace2Map(UtilsFooting.actualRace);			
		}	
		
	}

	private void drawRace2Map(final Race race) {

		logger.info("Drawing race into map");

		ArrayList<FMLocation> locations = UtilsFooting.findLocationsByRacePkey(race.getPkey());
		if (locations!=null){
			for (int i=0; i< locations.size();i++){
				GeoPoint geop = new GeoPoint((int) (locations.get(i).getLat() * UtilsFooting.GEO_CONV), 
						(int) (locations.get(i).getLng() * UtilsFooting.GEO_CONV));
				addLocation2Map(geop);
			}
		}

	}


	private void addLocation2Map(GeoPoint point){

		OverlayItem overlayitem = new OverlayItem(point, "Location", "("+point.getLatitudeE6()/UtilsFooting.GEO_CONV+", "+point.getLongitudeE6()/UtilsFooting.GEO_CONV+")");
		//logger.info("Location added to MAP: "+point);
		mapView.getController().animateTo(point);
		itemizedoverlay.addOverlay(overlayitem);
		mapView.postInvalidate();
	}


	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}	

	/**
	 * Launch this activity
	 * 
	 * @param context
	 * @param record 
	 */
	public static void launch(final Context context, final Race race, int record) {
		UtilsFooting.actualRace = race;
		final Intent i = new Intent(context, FootingMeterActivity.class);
		i.putExtra(EXTRA_RECORD, record);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(i);
	}

	/**
	 * The primary purpose is to prevent systems before
	 * android.os.Build.VERSION_CODES.ECLAIR from calling their default
	 * KeyEvent.KEYCODE_BACK during onKeyDown.
	 */
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		if (keyCode == KeyEvent.KEYCODE_BACK)
		{
			unRegisterGPS();
			logger.info("KEYCODE_BACK# GPS OFF");

			// preventing default implementation previous to
			// android.os.Build.VERSION_CODES.ECLAIR
			//finish();
			return super.onKeyDown(keyCode, event);
		}
		return super.onKeyDown(keyCode, event);
	}

	private void unRegisterGPS() {
		UtilsFooting.lm.removeUpdates(this);

	}
	
	private void registerGPS() {
		UtilsFooting.lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 8000, 10, this);

	}

	@Override
	public void onLocationChanged(Location location) {

		oldLat = lat;
		oldLng = lng;
		lat = location.getLatitude();
		lng = location.getLongitude();
		if (UtilsFooting.insertLocation((lat), (lng))){			
			float[] results = new float[4];
			if (oldLat != 0 && oldLng != 0)
			{
				Location.distanceBetween(oldLat, oldLng, lat, lng, results);				
				UtilsFooting.totalDistance += (long) results[0];
				distance.setText("Distance: "+df.format((double) UtilsFooting.totalDistance / 1000) + " Km");

			}

			GeoPoint geop = new GeoPoint((int) (lat* UtilsFooting.GEO_CONV) , (int) (lng* UtilsFooting.GEO_CONV));
			addLocation2Map(geop);
		}

	}

	@Override
	public void onProviderDisabled(String provider) {
		Toast.makeText(this,"Gps Disabled",Toast.LENGTH_SHORT ).show();

	}

	@Override
	public void onProviderEnabled(String provider) {
		Toast.makeText(this,"Gps Enabled", Toast.LENGTH_SHORT).show();

	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {
		//Toast.makeText(context,"Gps Status changed:" +status+", provider = "+provider, Toast.LENGTH_SHORT).show();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu)
	{
		menu.add(0,SATELLITE,0,"Satellite On");
		menu.add(0,EXIT,0,"Exit Map");
		return true;
	}

	public boolean onOptionsItemSelected (MenuItem item){

		switch (item.getItemId()){
		case SATELLITE :
			if (satellite){
				satellite  = false;
				mapView.setSatellite(satellite);
				item.setTitle("Satellite On");
			}else{
				satellite  = true;
				mapView.setSatellite(satellite);
				item.setTitle("Satellite Off");
			}
			return true;		
		case EXIT :  
			unRegisterGPS();
			logger.info("EXIT# GPS OFF");
			finish();
			return true;
		}
		return false;
	}


}





