package es.tid.gmaps;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.provider.Settings;
import android.view.KeyEvent;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.R;
import es.tid.database.bo.Location;
import es.tid.database.bo.Race;
import es.tid.tabs.home.UtilsStride;

public class FootingMeterActivity extends MapActivity {

	private static final Logger logger = LoggerFactory.getLogger(FootingMeterActivity.class);

    private static final String EXTRA_RECORD = "record";

	private MapView mapView;
	private List<Overlay> mapOverlays;
	private Drawable drawable;
	private HelloItemizedOverlay itemizedoverlay;

	private LocationManager lm;
	private YLocationListener listener;

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

		logger.info("Footing Application Started!!!");		
		
		if (UtilsStride.actualRace != null){
			drawRace2Map(UtilsStride.actualRace);
		}
		
		try {
            Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, true);
            logger.info("GPS enabled !");
        } catch (Exception e) {
            logger.error("Error enabling GPS: "+e);
        }   
        
        Bundle extras = getIntent().getExtras();
        int record  = extras.getInt(EXTRA_RECORD);        
       
        if (record == 0){
    		lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
            listener = new YLocationListener(this);
            lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10000, 15, listener);
        }
	}

	private void drawRace2Map(final Race race) {

		logger.info("Drawing race into map");

		ArrayList<Location> locations = UtilsStride.findLocationsByRacePkey(race.getPkey());
		if (locations!=null){
			for (int i=0; i< locations.size();i++){
				GeoPoint geop = new GeoPoint((int) (locations.get(i).getLat() * UtilsStride.GEO_CONV), 
						(int) (locations.get(i).getLng() * UtilsStride.GEO_CONV));
				addLocation2Map(geop);
			}
		}

	}


	public void addLocation2Map(GeoPoint point){

		OverlayItem overlayitem = new OverlayItem(point, "Location", "("+point.getLatitudeE6()/UtilsStride.GEO_CONV+", "+point.getLongitudeE6()/UtilsStride.GEO_CONV+")");
		logger.info("Location added to MAP: "+point);
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
		UtilsStride.actualRace = race;
		final Intent i = new Intent(context, FootingMeterActivity.class);
		i.putExtra(EXTRA_RECORD, record);
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(i);
	}

	public class YLocationListener implements LocationListener {

		private Context context;
		private FootingMeterActivity activity;


		public YLocationListener(FootingMeterActivity activity) {
			context = activity.getApplicationContext();
			this.activity = activity;
		}


		@Override
		public void onProviderDisabled(String provider)
		{

			Toast.makeText(context,"Gps Disabled",Toast.LENGTH_SHORT ).show();

		}


		@Override
		public void onProviderEnabled(String provider)
		{

			Toast.makeText(context,"Gps Enabled", Toast.LENGTH_SHORT).show();

		}


		@Override
		public void onStatusChanged(String provider, int status, Bundle extras)
		{
			//Toast.makeText(context,"Gps Status changed:" +status+", provider = "+provider, Toast.LENGTH_SHORT).show();

		}


		@Override
		public void onLocationChanged(android.location.Location location) {
			double lat = location.getLatitude();
			double lng = location.getLongitude();

			
			if (UtilsStride.insertLocation((lat), (lng))){
				GeoPoint geop = new GeoPoint((int) (lat* UtilsStride.GEO_CONV) , (int) (lng* UtilsStride.GEO_CONV));

				UtilsStride.pathPoints.add(geop);
				activity.addLocation2Map(geop);
			}
			
		}
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
			logger.info("back en map");
			if (lm != null && listener != null){
				try {
					Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, false);
					logger.info("GPS enabled !");
				} catch (Exception e) {
					logger.error("Error enabling GPS: "+e);
				}
				lm.removeUpdates(listener);
				logger.info("Location listener registered!");
			}
			// preventing default implementation previous to
			// android.os.Build.VERSION_CODES.ECLAIR
			listener = null;
			lm = null;
			finish();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}


}





