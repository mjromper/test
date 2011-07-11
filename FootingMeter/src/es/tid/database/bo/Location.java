package es.tid.database.bo;

/**
 * @author mjrp
 *
 */
public class Location {
    
    private Integer pkey;    
    private Integer lat;    
    private Integer lng; 
    private Integer racePkey;

    /**
     * Default constructor
     */
    public Location() {
        super();
    }

    /**
     * Constructor using fields
     * @param pkey
     * @param lat
     * @param lng
     */
    public Location(Integer pkey, Integer racePkey, Integer lat, Integer lng) {
        super();
        this.pkey = pkey;
        this.lat = lat;
        this.lng = lng;
        this.racePkey = racePkey;
    }

    /**
     * @return the pkey
     */
    public Integer getPkey() {
        return pkey;
    }

    /**
     * @param pkey the pkey to set
     */
    public void setPkey(Integer pkey) {
        this.pkey = pkey;
    }

  

    /**
     * @return the lat
     */
    public Integer getLat() {
        return lat;
    }

    /**
     * @param lat the lat to set
     */
    public void setLat(Integer lat) {
        this.lat = lat;
    }

    /**
     * @return the lng
     */
    public Integer getLng() {
        return lng;
    }

    /**
     * @param lng the lng to set
     */
    public void setLng(Integer lng) {
        this.lng = lng;
    }    

 

	public void setRacePkey(Integer racePkey) {
		this.racePkey = racePkey;
	}

	public Integer getRacePkey() {
		return racePkey;
	}

	@Override
	public String toString() {
		return "Location [pkey=" + pkey + ", lat=" + lat + ", lng=" + lng
				+ ", racePkey=" + racePkey + "]";
	}
	
	

}
