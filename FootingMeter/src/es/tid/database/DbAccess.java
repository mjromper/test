package es.tid.database;

import java.util.ArrayList;

import android.content.Context;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

/**
 * @author mjrp
 * 
 * @param <T>
 */
public abstract class DbAccess<T> extends SQLiteOpenHelper {

	private static final Logger LOG = LoggerFactory.getLogger(DbAccess.class);

	public static final String DB_NAME = "footing.db";
	public static final String DB_NAME_TEST = "footingTest.db";

	public static final String DB_PATH_EXTERNAL = "/mnt/sdcard/hathdroid/";

	public static final int DB_VERSION = 2;

	public static final String DB_PATH_LOCAL = "footing.db";



	// Sections lifted from the originating class SqliteOpenHelper.java

	public DbAccess(final Context context, final String name, final CursorFactory factory, final int version) {
		super(context, name, factory, version);

	}

	/**
	 * Method to delete all entities
	 * 
	 * @return
	 * 
	 * @throws SQLException
	 */
	public abstract void deleteAll();

	/**
	 * Remove entity by pkey
	 * 
	 * @param pkey
	 * @throws SQLException
	 */
	public abstract void deleteByPkey(final Integer pkey) throws SQLException;

	/**
	 * Drop table
	 */
	protected abstract void dropTable() throws SQLException;

	/**
	 * Find all entities
	 * 
	 * @return
	 * @throws SQLException
	 */
	public abstract ArrayList<T> findAll() throws SQLException;

	/**
	 * Find entity by pkey
	 * 
	 * @param pkey
	 * @return
	 * @throws SQLException
	 */
	public abstract T findByPkey(final Integer pkey) throws SQLException;

	/**
	 * Method to insert a new entity
	 * 
	 * @param safezone
	 * @throws SQLException
	 */
	public abstract void insert(final T entity) throws SQLException;

	/**
	 * Method to update an entity
	 * 
	 * @param safezone
	 * @throws SQLException
	 */
	public abstract void update(final T entity) throws SQLException;

	/**
	 * Method to insert or update an entity
	 * 
	 * @param entity
	 * @throws SQLException
	 */
	public abstract void insertOrUpdate(final T entity) throws SQLException;



	/*
	 * (non-Javadoc)
	 * 
	 * @see android.database.sqlite.SQLiteOpenHelper#onCreate(android.database.sqlite.SQLiteDatabase)
	 */
	@Override
	public void onCreate(final SQLiteDatabase db) {

		/**
		 * LOCATIONS DATABASE
		 */
		final StringBuilder sb_locations = new StringBuilder();
		sb_locations.append("CREATE TABLE IF NOT EXISTS ");
		sb_locations.append(DbTableModel.TABLE_LOCATIONS_NAME);
		sb_locations.append(" ( ");
		sb_locations.append(DbTableModel.LOCATION_ID);
		sb_locations.append(" INTEGER PRIMARY KEY AUTOINCREMENT, "); 
		sb_locations.append(DbTableModel.LOCATION_RACE);
		sb_locations.append(" INTEGER NOT NULL, "); 
		sb_locations.append(DbTableModel.LOCATION_LAT);
		sb_locations.append(" REAL NOT NULL, ");
		sb_locations.append(DbTableModel.LOCATION_LNG);
		sb_locations.append(" REAL NOT NULL ");
		sb_locations.append(" );");

		/**
		 * RACES DATABASE
		 */
		final StringBuilder sb_races = new StringBuilder();
		sb_races.append("CREATE TABLE IF NOT EXISTS ");
		sb_races.append(DbTableModel.TABLE_RACES_NAME);
		sb_races.append(" (");
		sb_races.append(DbTableModel.RACE_ID);
		sb_races.append(" INTEGER PRIMARY KEY AUTOINCREMENT, ");
		sb_races.append(DbTableModel.RACE_NAME);
		sb_races.append(" TEXT NULL, " );
		sb_races.append(DbTableModel.RACE_TYPE);
		sb_races.append(" TEXT NULL, " );
		sb_races.append(DbTableModel.RACE_DURATION);
		sb_races.append(" TEXT NULL, ");
		sb_races.append(DbTableModel.RACE_DISTANCE);
		sb_races.append(" TEXT NULL, ");	
		sb_races.append(DbTableModel.RACE_DATE);
		sb_races.append(" TEXT NOT NULL ");		
		sb_races.append(" );");

		
		db.execSQL(sb_locations.toString());
		LOG.info("TABLE " + DbTableModel.TABLE_LOCATIONS_NAME + " CREATED");

		db.execSQL(sb_races.toString());
		LOG.info("TABLE " + DbTableModel.TABLE_RACES_NAME + " CREATED");

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.database.sqlite.SQLiteOpenHelper#onUpgrade(android.database.sqlite.SQLiteDatabase, int, int)
	 */
	@Override
	public void onUpgrade(final SQLiteDatabase db, final int oldVersion, final int newVersion) {

		if (oldVersion != newVersion) {
			db.execSQL("DROP TABLE IF EXISTS " + DbTableModel.TABLE_LOCATIONS_NAME);
			db.execSQL("DROP TABLE IF EXISTS " + DbTableModel.TABLE_RACES_NAME);

			onCreate(db);
		}
	}

}
