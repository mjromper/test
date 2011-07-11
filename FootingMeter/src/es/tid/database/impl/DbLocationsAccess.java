package es.tid.database.impl;

import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.database.DbAccess;
import es.tid.database.DbTableModel;
import es.tid.database.bo.Location;



/**
 * Class that implements access to SQL-Lite database for safezones
 * @author mjrp
 *
 */

public class DbLocationsAccess extends DbAccess<Location> {



	private static final Logger LOG = LoggerFactory.getLogger(DbLocationsAccess.class);

	private static final String[] ALL_COLUMNS = { DbTableModel.LOCATION_ID, 
		DbTableModel.LOCATION_LAT,  DbTableModel.LOCATION_LNG,
		DbTableModel.LOCATION_RACE};

	/**
	 * Default constructor
	 * 
	 * @param context
	 */
	public DbLocationsAccess(final Context context, final String dbName) {
		super(context, dbName, null, DB_VERSION);
	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#deleteAll()
	 */
	@Override
	public void deleteAll() throws SQLException {
		try{
			getWritableDatabase().delete(DbTableModel.TABLE_LOCATIONS_NAME, null, null);
			LOG.info("Deleted all locations database info");
		}catch (Exception e) {
			LOG.info("No location found to delete");
		}
	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#dropTable()
	 */
	@Override
	public void dropTable() throws SQLException {
		getWritableDatabase().execSQL("DROP TABLE IF EXISTS " + DbTableModel.TABLE_LOCATIONS_NAME);
		LOG.debug("TABLE " + DbTableModel.TABLE_LOCATIONS_NAME + " DROPPED");
	}

	/**
	 * Return a safezone fill with all cursor fields
	 * 
	 * @param cursor
	 * @return
	 */
	private Location getEntityByCursor(final Cursor cursor) {
		Location safezone = null;
		if (cursor != null) {
			safezone = new Location();
			safezone.setPkey(cursor.getInt(cursor.getColumnIndex(DbTableModel.LOCATION_ID)));
			safezone.setRacePkey(cursor.getInt(cursor.getColumnIndex(DbTableModel.LOCATION_RACE)));
			safezone.setLat(cursor.getInt(cursor.getColumnIndex(DbTableModel.LOCATION_LAT)));
			safezone.setLng(cursor.getInt(cursor.getColumnIndex(DbTableModel.LOCATION_LNG)));
		}

		return safezone;
	}

	/**
	 * Method to get values from safezone business object
	 * 
	 * @return
	 */
	private ContentValues getContentValues(final Location location) {
		final ContentValues vals = new ContentValues();
		vals.put(DbTableModel.LOCATION_RACE, location.getRacePkey());
		vals.put(DbTableModel.LOCATION_LAT, location.getLat());
		vals.put(DbTableModel.LOCATION_LNG, location.getLng());       
		return vals;
	}


	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#insert(java.lang.Object)
	 */
	@Override
	public void insert(final Location location) throws SQLException {

		final ContentValues values = getContentValues(location);
		getWritableDatabase().insertOrThrow(DbTableModel.TABLE_LOCATIONS_NAME, null, values);

		LOG.debug("Location (" +location.getLat()+", " +location.getLng()+") inserted");

	}


	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#findByPkey(java.lang.Integer)
	 */
	@Override
	public Location findByPkey(final Integer pkey) throws SQLException {

		Location location = null;

		final String selection = DbTableModel.LOCATION_ID + " = " + pkey;
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_LOCATIONS_NAME, ALL_COLUMNS, selection, null,
				null, null, null);

		if (cursor != null && cursor.moveToFirst()) {
			location = getEntityByCursor(cursor);
			cursor.close();
		}

		return location;

	}



	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#deleteByPkey(java.lang.Integer)
	 */
	@Override
	public void deleteByPkey(final Integer pkey) throws SQLException {

		final int res = getWritableDatabase().delete(DbTableModel.TABLE_LOCATIONS_NAME,
				DbTableModel.LOCATION_ID + "=" + pkey, null);
		if (res > 0) {
			LOG.debug("No location with _ID (" + pkey + ") found to remove it");
		} else {
			LOG.debug("Location remove it -> PKEY: " + pkey);
		}

	}


	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#findAll()
	 */
	@Override
	public ArrayList<Location> findAll() throws SQLException {

		ArrayList<Location> locations = null;        

		// Perform a managed query. The Activity will handle closing
		// and re-querying the cursor when needed.
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_LOCATIONS_NAME, ALL_COLUMNS, null, null, null,
				null, null);

		if (cursor != null && cursor.getCount() > 0) {
			locations = new ArrayList<Location>(0);
		}

		while (cursor.moveToNext()) {
			final Location location = getEntityByCursor(cursor);
			locations.add(location);

		}

		if (cursor != null){
			cursor.close();
		}

		return locations;
	}




	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#update(java.lang.Object)
	 */
	@Override
	public void update(final Location location) throws SQLException {
		// UPDATE SAFEZONE ADDITIONAL INFO
		try {

			final ContentValues vals = getContentValues(location);

			getWritableDatabase().update(DbTableModel.TABLE_LOCATIONS_NAME, vals,
					DbTableModel.LOCATION_ID + "=" + location.getPkey(), null);

			LOG.debug("Location (" +location.getLat()+", " +location.getLng()+") updated");

		} catch (final SQLException e) {
			LOG.error("Error updating safezone info: " + e);
			throw e;
		}

	}

	/**
	 * Find safezone by name
	 * 
	 * @param name
	 * @return Safezone
	 */
	public ArrayList<Location> selectLocationByRacePkey(Integer racePkey) {
		ArrayList<Location> locations = null;

		final String selection = DbTableModel.LOCATION_RACE + " = '" + racePkey + "'";
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_LOCATIONS_NAME, ALL_COLUMNS, selection, null,
				null, null, null);

		if (cursor != null && cursor.getCount() > 0) {
			locations = new ArrayList<Location>(0);
		}

		while (cursor.moveToNext()) {
			final Location location = getEntityByCursor(cursor);
			locations.add(location);

		}

		if (cursor != null){
			cursor.close();
		}

		return locations;

	}

	/* (non-Javadoc)
	 * @see es.tid.ehealth.mobtel.mobile.hathdroid.common.database.DbAccess#insertOrUpdate(java.lang.Object)
	 */
	@Override
	public void insertOrUpdate(Location entity) throws SQLException {
		if (entity != null){

			if (entity.getPkey() == null){
				insert(entity);     
			} else{
				//Entity already exists
				update(entity);
			}
		}

	}

}
