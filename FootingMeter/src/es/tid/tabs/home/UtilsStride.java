package es.tid.tabs.home;

import java.util.ArrayList;

import com.google.android.maps.GeoPoint;
import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.Starter;
import es.tid.database.bo.FMLocation;
import es.tid.database.bo.Race;
import es.tid.database.impl.DbLocationsAccess;
import es.tid.database.impl.DbRacesAccess;

public class UtilsStride {

	private static final Logger logger = LoggerFactory.getLogger(UtilsStride.class);


	public static String runningName = "Today Track";

	public static long totalDistance = 0;

	public static long totalTime = 0;

	public static ArrayList<GeoPoint> pathPoints = new ArrayList<GeoPoint>();

	public static Starter mainActivity;

	public static Race actualRace = null;


	private static int oldLat;
	private static int oldLng;

	public static final double GEO_CONV = 1E6;

	public static void addRaceToDB(long distance, long time, long date) {

		totalDistance = distance;
		totalTime = time;

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

}
