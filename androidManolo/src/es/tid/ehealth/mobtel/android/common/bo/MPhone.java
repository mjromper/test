package es.tid.ehealth.mobtel.android.common.bo;

public class MPhone {
 	private String number;
 	private int type;
 	
 	public String getNumber() {
 		return number;
 	}
 
 	public void setNumber(String number) {
 		this.number = number;
 	}
 
 	public int getType() {
 		return type;
 	}
 
 	public void setType(int type) {
 		this.type = type;
 	}
 
 	public MPhone(String n, int t) {
 		this.number = n;
 		this.type = t;
 	}
 	
 }