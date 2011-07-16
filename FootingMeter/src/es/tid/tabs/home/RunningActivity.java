package es.tid.tabs.home;

import java.text.DecimalFormat;
import java.util.Date;

import android.app.Activity;
import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.provider.Settings;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Chronometer;
import android.widget.TextView;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.R;
import es.tid.gmaps.FootingMeterActivity;

public class RunningActivity extends Activity
{
	private static DecimalFormat df = new DecimalFormat("0.###");

	private static final Logger logger = LoggerFactory.getLogger(RunningActivity.class);

	private LocationManager lm;
	private LocationListener locationListener;

	// GUI
	private TextView distanceTV;
	private TextView speedTV;
	private Button stopRaceBtn;
	private Button resumeRaceBtn;
	private Chronometer chronos;

	public boolean recording = true;
	private boolean firstTime = true;

	private long dateRace = new Date().getTime();

	private Button mapBtn;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.running_layout);
		speedTV = (TextView) findViewById(R.id.runningSpeedTV);
		distanceTV = (TextView) findViewById(R.id.runningDistTV);
		chronos = (Chronometer) findViewById(R.id.runningTimeTV);
		stopRaceBtn = (Button) findViewById(R.id.stop_track_btn);
		resumeRaceBtn = (Button) findViewById(R.id.resume_track_btn);
		mapBtn = (Button) findViewById(R.id.buttonmap);
		resumeRaceBtn.setEnabled(true);

		chronos.setBase(SystemClock.elapsedRealtime() - UtilsFooting.totalTime);


		if (recording && firstTime)
		{
			chronos.setBase(SystemClock.elapsedRealtime());
			chronos.start();
			firstTime = false;
			//Reset data
			UtilsFooting.totalTime = SystemClock.elapsedRealtime() - chronos.getBase();
			UtilsFooting.totalDistance = 0;
			// save race
			UtilsFooting.addRaceToDB(dateRace);
		}


		OnClickListener stopTrackBtnListener = new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{

				stopRecording();

			}


		};
		stopRaceBtn.setOnClickListener(stopTrackBtnListener);

		OnClickListener resumeTrackBtnListener = new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{
				if (recording == true)
				{
					recording = false;
					unRegisterLocationListener();
					chronos.stop();
				}
				else
				{
					registerLocationListener();
					recording = true;
					chronos.start();
				}
			}
		};
		resumeRaceBtn.setOnClickListener(resumeTrackBtnListener);

		OnClickListener mapBtnListener = new OnClickListener()
		{
			@Override
			public void onClick(View v)
			{

				unRegisterLocationListener();				
				UtilsFooting.totalTime = SystemClock.elapsedRealtime() - chronos.getBase();
				/*TabGroupActivity parentActivity = (TabGroupActivity) getParent();
				Intent intent = new Intent(parentActivity,
						FootingMeterActivity.class);
				intent.putExtra(FootingMeterActivity.EXTRA_RECORD, 0);
				parentActivity.startChildActivity("FootingMeterActivity",
						intent);	*/		
				FootingMeterActivity.launch(getApplicationContext(), UtilsFooting.actualRace, 0);
			}
		};
		mapBtn.setOnClickListener(mapBtnListener);

		if (lm == null ){
			lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		}
		if (locationListener == null){
			locationListener = new RunLocationListener();
		}

	}
	
	




	@Override
	protected void onStop() {
		unRegisterLocationListener();
		super.onStop();
	}


	@Override
	public void onResume()
	{
		super.onResume();
		if (recording == true)
		{
			registerLocationListener();
		}else{
			unRegisterLocationListener();
		}
		
	}


	private void registerLocationListener() {
		if (lm == null ){
			lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		}
		if (locationListener == null){
			locationListener = new RunLocationListener();
			
		}
		lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10000, 15, locationListener);
		
		logger.info("Location listener registered!");

	}

	private void unRegisterLocationListener() {
		
		if (lm == null )
			lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		
		
		if (locationListener != null)
			lm.removeUpdates(locationListener);
		
		logger.info("Location listener unregistered!");
		locationListener = null;

	}

	private void stopRecording() {
		// save data
		UtilsFooting.totalTime = SystemClock.elapsedRealtime() - chronos.getBase();
		UtilsFooting.addRaceToDB(dateRace);

		//Unregister GPS		
		recording = false;

		//reset values
		chronos.stop(); 
		UtilsFooting.totalDistance = 0;
		UtilsFooting.totalTime = 0;

		//Disable resume button
		resumeRaceBtn.setEnabled(false);

	}


	public class RunLocationListener implements LocationListener
	{

		private double lat = 0, lng = 0, oldLat = 0, oldLng = 0;

		@Override
		public void onLocationChanged(Location loc)
		{
			
			if (loc != null && recording)
			{
								
				oldLat = lat;
				oldLng = lng;
				lat = loc.getLatitude();
				lng = loc.getLongitude();
				if (UtilsFooting.insertLocation((lat), (lng))){
					float[] results = new float[4];
					if (oldLat != 0 && oldLng != 0)
					{
						Location.distanceBetween(oldLat, oldLng, lat, lng, results);
						UtilsFooting.totalDistance += (long) results[0];
						distanceTV.setText(df.format((double) UtilsFooting.totalDistance / 1000) + " Km");
						//TODO set speed text
					}

				}

			}
		}


		@Override
		public void onProviderDisabled(String provider)
		{
			recording = false;
		}

		@Override
		public void onProviderEnabled(String provider)
		{
		}

		@Override
		public void onStatusChanged(String provider, int status, Bundle extras)
		{
		}
	}

}
