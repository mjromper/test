package es.tid.database;

public final class DbTableModel {

    
    /**
     * LOCATIONS TABLE
     */
    public static final String TABLE_LOCATIONS_NAME = "locations";
    
    public static final String LOCATION_ID = android.provider.BaseColumns._ID;
    public static final String LOCATION_RACE = "race";
    public static final String LOCATION_LAT = "lat";
    public static final String LOCATION_LNG = "lng";
    
    
    /**
     * RACES TABLE
     */
    public static final String TABLE_RACES_NAME = "races";
    
    public static final String RACE_ID = android.provider.BaseColumns._ID;
    public static final String RACE_DATE = "date";
    public static final String RACE_NAME = "name";
    public static final Object RACE_DURATION = "duration";

	
    
    
    
    /**
       The caller references the constants using Consts.EMPTY_STRING,
       and so on. Thus, the caller should be prevented from constructing objects of
       this class, by declaring this private constructor.
     */
    private DbTableModel(){
        //this prevents even the native class from
        //calling this constructor as well :
        throw new AssertionError();
    }

}


