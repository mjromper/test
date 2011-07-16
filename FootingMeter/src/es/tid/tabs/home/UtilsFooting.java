package es.tid.tabs.home;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

import es.tid.Starter;
import es.tid.database.bo.FMLocation;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbLocationsAccess;
import es.tid.database.impl.DbRacesAccess;

public class UtilsFooting {


	public static String runningName = "Today Track";

	public static long totalDistance = 0;

	public static long totalTime = 0;

	public static Starter mainActivity;

	public static Race actualRace = null;


	private static int oldLat;
	private static int oldLng;

	public static final double GEO_CONV = 1E6;

	public static void addRaceToDB(long date) {

		DbRacesAccess dbRaces = new DbRacesAccess(mainActivity, DbRacesAccess.DB_NAME);

		Race race = new Race();
		race.setName(runningName);
		race.setDuration(totalTime);
		race.setDistance(totalDistance);
		race.setDate(date);		
		dbRaces.insertOrUpdate(race);	

		actualRace = dbRaces.selectRaceByDate(date);


	}

	public static boolean insertLocation(Double lat, Double lng) {
		
		boolean res = false;

		if (actualRace != null){
			FMLocation loc = new FMLocation();
			loc.setLat(lat);
			loc.setLng(lng);
			int latE6 = (int)(lat*GEO_CONV);
			int lngE6 = (int)(lng*GEO_CONV);
			
			if (latE6 != oldLat && lngE6 != oldLng){	
				
				oldLat = latE6;
				oldLng = lngE6;
				loc.setRacePkey(actualRace.getPkey());

				DbLocationsAccess dbLocations = new DbLocationsAccess(mainActivity, DbRacesAccess.DB_NAME);
				dbLocations.insert(loc);
				res = true;
			}
		}
		
		return res;

	}

	public static ArrayList<FMLocation> findLocationsByRacePkey(Integer pkey) {

		DbLocationsAccess dbLocations = new DbLocationsAccess(mainActivity, DbRacesAccess.DB_NAME);
		return dbLocations.selectLocationByRacePkey(pkey);
	}

	public static void deleteRace(Integer pkey) {
		DbRacesAccess dbRaces = new DbRacesAccess(mainActivity, DbRacesAccess.DB_NAME);
		dbRaces.deleteByPkey(pkey);
		
	}
	
	public static void createGpsDisabledAlert(final Context context){  
		AlertDialog.Builder builder = new AlertDialog.Builder(context);  
		builder.setMessage("Your GPS is disabled! Would you like to enable it?")  
		.setCancelable(false)  
		.setPositiveButton("Enable GPS",  
				new DialogInterface.OnClickListener(){  
			public void onClick(DialogInterface dialog, int id){  
				Intent gpsOptionsIntent = new Intent(  
						android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);  
				context.startActivity(gpsOptionsIntent);  
			}  
		});  
		builder.setNegativeButton("Do nothing",  
				new DialogInterface.OnClickListener(){  
			public void onClick(DialogInterface dialog, int id){  
				dialog.cancel();  
			}  
		});  
		AlertDialog alert = builder.create();  
		alert.show();  
	}  

}
