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

import com.google.android.maps.GeoPoint;
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

    private long totalDistance = 0;
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

        totalDistance = UtilsStride.totalDistance;
        chronos.setBase(SystemClock.elapsedRealtime() - UtilsStride.totalTime);



        if (recording && firstTime)
        {
            chronos.setBase(SystemClock.elapsedRealtime());
            chronos.start();
            firstTime = false;
            // save data
            UtilsStride.addRaceToDB(totalDistance, SystemClock.elapsedRealtime() - chronos.getBase(), dateRace);
        }


        OnClickListener stopTrackBtnListener = new OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                // save data
                UtilsStride.addRaceToDB(totalDistance, SystemClock.elapsedRealtime() - chronos.getBase(), dateRace);

                unRegisterLocationListener();
                recording = false;

                chronos.stop();

                //Intent intent = new Intent(getParent(), FinalResultsActivity.class);
                //TabGroupActivity parentActivity = (TabGroupActivity) getParent();
                //parentActivity.startChildActivity("FinalResultsActivity", intent);
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

                FootingMeterActivity.launch(getApplicationContext(), UtilsStride.actualRace, 0);
            }
        };
        mapBtn.setOnClickListener(mapBtnListener);

        if (lm == null ){
            lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        }
        if (locationListener == null){
            locationListener = new RunLocationListener();
        }

        // GPS
        registerLocationListener();

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

        //UtilsStride.pathPoints.clear();
        //totalDistance = 0;
    }
    
    
    private void registerLocationListener() {
        if (lm == null ){
            lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        }
        if (locationListener == null){
            locationListener = new RunLocationListener();
        }
        try {
            Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, true);
            logger.info("GPS enabled !");
        } catch (Exception e) {
            logger.error("Error enabling GPS: "+e);
        }		
        lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10000, 15, locationListener);
        logger.info("Location listener registered!");

    }

    private void unRegisterLocationListener() {
        if (lm == null ){
            lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        }
        if (locationListener == null){
            locationListener = new RunLocationListener();
        }
        try {
            Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, false);
            logger.info("GPS dsiabled !");
        } catch (Exception e) {
            logger.error("Error disabling GPS: "+e);
        }

        lm.removeUpdates(locationListener);
        logger.info("Location listener unregistered!");
        locationListener = null;

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
            if (lm != null && locationListener != null){
                try {
                    Settings.Secure.setLocationProviderEnabled(getContentResolver(), LocationManager.GPS_PROVIDER, false);
                    logger.info("GPS enabled !");
                } catch (Exception e) {
                    logger.error("Error enabling GPS: "+e);
                }
                lm.removeUpdates(locationListener);
                logger.info("Location listener registered!");
            }
            // preventing default implementation previous to
            // android.os.Build.VERSION_CODES.ECLAIR
            locationListener = null;
            lm = null;
            super.onKeyDown(keyCode, event);
        }
        return super.onKeyDown(keyCode, event);
    }


    public class RunLocationListener implements LocationListener
    {

        private double lat = 0, lng = 0, oldLat = 0, oldLng = 0;
        private double mySpeed;

        @Override
        public void onLocationChanged(Location loc)
        {
            float[] results = new float[4];
            if (loc != null && recording)
            {
                if (!loc.hasSpeed())
                {
                    mySpeed = loc.getSpeed();
                    speedTV.setText("" + mySpeed + "m/s");
                }
                oldLat = lat;
                oldLng = lng;
                lat = loc.getLatitude();
                lng = loc.getLongitude();

                if (oldLat != 0 && oldLng != 0)
                {
                    Location.distanceBetween(oldLat, oldLng, lat, lng, results);
                    setKms(results[0]);
                }

                if (UtilsStride.insertLocation((lat), (lng))){
                    GeoPoint geop = new GeoPoint((int) (lat * UtilsStride.GEO_CONV) , (int) (lng * UtilsStride.GEO_CONV));

                    UtilsStride.pathPoints.add(geop);
                }

            }
        }

        private void setKms(float diff)
        {
            totalDistance += (long) diff;
            UtilsStride.totalDistance = totalDistance;
            distanceTV.setText(df.format((double) totalDistance / 1000) + " Km");
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
