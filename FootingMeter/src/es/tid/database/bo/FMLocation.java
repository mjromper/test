package es.tid.database.bo;

/**
 * @author mjrp
 *
 */
public class FMLocation {
    
    private Integer pkey;    
    private Double lat;    
    private Double lng; 
    private Integer racePkey;

    /**
     * Default constructor
     */
    public FMLocation() {
        super();
    }

    /**
     * Constructor using fields
     * @param pkey
     * @param lat
     * @param lng
     */
    public FMLocation(Integer pkey, Integer racePkey, Double lat, Double lng) {
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
    public Double getLat() {
        return lat;
    }

    /**
     * @param lat the lat to set
     */
    public void setLat(Double lat) {
        this.lat = lat;
    }

    /**
     * @return the lng
     */
    public Double getLng() {
        return lng;
    }

    /**
     * @param lng the lng to set
     */
    public void setLng(Double lng) {
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
