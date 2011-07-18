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
import es.tid.database.bo.Race;



/**
 * Class that implements access to SQL-Lite database for races
 * @author mjrp
 *
 */

public class DbRacesAccess extends DbAccess<Race> {



	private static final Logger LOG = LoggerFactory.getLogger(DbRacesAccess.class);

	private static final String[] ALL_COLUMNS = { DbTableModel.RACE_ID, 
		DbTableModel.RACE_NAME,
		DbTableModel.RACE_TYPE,
		DbTableModel.RACE_DATE, 
		DbTableModel.RACE_DURATION, 
		DbTableModel.RACE_DISTANCE};

	/**
	 * Default constructor
	 * 
	 * @param context
	 */
	public DbRacesAccess(final Context context, final String dbName) {
		super(context, dbName, null, DB_VERSION);
	}

	@Override
	public void deleteAll() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void deleteByPkey(Integer pkey) throws SQLException {
		final int res = getWritableDatabase().delete(DbTableModel.TABLE_RACES_NAME,
				DbTableModel.RACE_ID + "=" + pkey, null);
		if (res > 0) {
			LOG.debug("Race remove it -> PKEY: " + pkey);
		} else {
			LOG.debug("No race with _ID (" + pkey + ") found to remove it");
		}
		
	}

	@Override
	protected void dropTable() throws SQLException {
		// TODO Auto-generated method stub
		
	}

	@Override
	public ArrayList<Race> findAll() throws SQLException {
		ArrayList<Race> races = null;        

		// Perform a managed query. The Activity will handle closing
		// and re-querying the cursor when needed.
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_RACES_NAME, ALL_COLUMNS, null, null, null,
				null, null);

		if (cursor != null && cursor.getCount() > 0) {
			races = new ArrayList<Race>(0);
		}

		while (cursor.moveToNext()) {
			final Race race = getEntityByCursor(cursor);
			races.add(race);

		}

		if (cursor != null){
			cursor.close();
		}

		return races;
	}

	@Override
	public Race findByPkey(Integer pkey) throws SQLException {
		Race race = null;

		final String selection = DbTableModel.RACE_ID + " = " + pkey;
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_RACES_NAME, ALL_COLUMNS, selection, null,
				null, null, null);

		if (cursor != null && cursor.moveToFirst()) {
			race = getEntityByCursor(cursor);
			cursor.close();
		}

		return race;
	}

	@Override
	public void insert(Race entity) throws SQLException {
		final ContentValues values = getContentValues(entity);
		getWritableDatabase().insertOrThrow(DbTableModel.TABLE_RACES_NAME, null, values);

		LOG.debug("Race "+entity.getDate()+"  inserted");
		
	}

	@Override
	public void update(Race entity) throws SQLException {
		// UPDATE SAFEZONE ADDITIONAL INFO
		try {

			final ContentValues vals = getContentValues(entity);

			getWritableDatabase().update(DbTableModel.TABLE_RACES_NAME, vals,
					DbTableModel.RACE_ID + "=" + entity.getPkey(), null);

			LOG.debug("Race (" +entity.getDate()+") updated");

		} catch (final SQLException e) {
			LOG.error("Error updating race info: " + e);
			throw e;
		}

		
	}

	@Override
	public void insertOrUpdate(Race entity) throws SQLException {
		if (entity != null){

			if (entity.getPkey() == null){
				
				Race base = selectRaceByDate(entity.getDate());
				if (base != null){
					entity.setPkey(base.getPkey());
					update(entity);
				}else{
					insert(entity);    
				}
				 
			} else{
				//Entity already exists
				update(entity);
			}
		}
		
	}
	
	/**
	 * Method to get values from safezone business object
	 * 
	 * @return
	 */
	private ContentValues getContentValues(final Race race) {
		final ContentValues vals = new ContentValues();
		vals.put(DbTableModel.RACE_NAME,race.getName());
		vals.put(DbTableModel.RACE_TYPE,race.getType());
		vals.put(DbTableModel.RACE_DATE, race.getDate());   
		vals.put(DbTableModel.RACE_DURATION, race.getDuration());
		vals.put(DbTableModel.RACE_DISTANCE, race.getDistance());
		return vals;
	}
	
	/**
	 * Return a safezone fill with all cursor fields
	 * 
	 * @param cursor
	 * @return
	 */
	private Race getEntityByCursor(final Cursor cursor) {
		Race race = null;
		if (cursor != null) {
			race = new Race();
			race.setPkey(cursor.getInt(cursor.getColumnIndex(DbTableModel.RACE_ID)));
			race.setName(cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_NAME)));
			race.setType(cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_TYPE)));
			race.setDate(Long.valueOf(cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_DATE))));
			if (cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_DURATION))!= null){
				race.setDuration(Long.valueOf(cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_DURATION))));
			}
			if (cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_DISTANCE))!= null){
				race.setDistance(Long.valueOf(cursor.getString(cursor.getColumnIndex(DbTableModel.RACE_DISTANCE))));
			}
		}

		return race;
	}

	public Race selectRaceByDate(Long raceDate) {
		Race race = null;

		final String selection = DbTableModel.RACE_DATE + " = " + raceDate;
		final Cursor cursor = getReadableDatabase().query(DbTableModel.TABLE_RACES_NAME, ALL_COLUMNS, selection, null,
				null, null, null);

		if (cursor != null && cursor.moveToFirst()) {
			race = getEntityByCursor(cursor);
			cursor.close();
		}

		return race;
	}

	
}
