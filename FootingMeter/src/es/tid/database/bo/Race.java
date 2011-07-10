package es.tid.database.bo;

import java.util.Date;

public class Race {
	
	private Integer pkey;    
	private String name;
	private Long date;
	private Long duration;
	
	public Race(){
		super();
	}

	public Race(Integer pkey, String name, Long date, Long duration) {
		super();
		this.pkey = pkey;
		this.name = name;
		this.date = date;
		this.duration = duration;
	}

	public void setPkey(Integer pkey) {
		this.pkey = pkey;
	}

	public Integer getPkey() {
		return pkey;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setDate(Long date) {
		this.date = date;
	}

	public Long getDate() {
		return date;
	}

	@Override
	public String toString() {
		return "Race [date= " + new Date(date) + "]";
	}

	public void setDuration(Long duration) {
		this.duration = duration;
	}

	public Long getDuration() {
		return duration;
	}

}
