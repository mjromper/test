package es.tid.listener;

import es.tid.gmaps.FootingMeterActivity;
import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;
import android.widget.Toast;

public class MyLocationListener implements LocationListener {

	private Context context;
	private FootingMeterActivity activity;


	public MyLocationListener(FootingMeterActivity activity) {
		context = activity.getApplicationContext();
		this.activity = activity;
	}


	@Override
	public void onLocationChanged(Location loc)
	{

		Double lat = loc.getLatitude();
		Double lng = loc.getLongitude();

		String Text = "My current location is: " +
		"Latitud =" + lat +
		"Longitud = " + lng;

		Toast.makeText(context,Text,Toast.LENGTH_LONG).show();

		activity.addLocation2Map(lat, lng);
		activity.insertLocation(lat, lng);
		
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

}
