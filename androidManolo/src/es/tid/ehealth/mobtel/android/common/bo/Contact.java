package es.tid.ehealth.mobtel.android.common.bo;

import java.util.ArrayList;

import android.graphics.Bitmap;



public class Contact {
	protected String id;
	private String idPlat;
	protected String displayName;
	protected ArrayList<MPhone> phones;
	private ArrayList<Email> emails;
	protected Bitmap photoBitmap;
	protected int quickDial = 0; 	
	protected boolean delete;
	
	public Contact(){
	    phones = new ArrayList<MPhone>();
	    delete = false;
	}

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getDisplayName() {
		return displayName;
	}
	public void setDisplayName(String dName) {
		this.displayName = dName;
	}
	public ArrayList<MPhone> getPhones() {
		return phones;
	}
	public void setPhones(ArrayList<MPhone> phones) {
		this.phones = phones;
	}
	public void addPhone(MPhone phone) {
		this.phones.add(phone);
	}
	public void setPhotoBitmap(Bitmap photo) {
		this.photoBitmap = photo;
	}
	public Bitmap getPhotoBitmap() {
		return photoBitmap;
	}
	public void setQuickDial(int quickDial) {
		this.quickDial = quickDial;
	}
	public int getQuickDial() {
		return quickDial;
	}
    public void setIdPlat(String idPlat) {
        this.idPlat = idPlat;
    }
    public String getIdPlat() {
        return idPlat;
    }

    public boolean isDelete() {
        return delete;
    }
    public void setDelete(boolean delete) {
        this.delete = delete;
    }

    public void setEmails(ArrayList<Email> emails) {
        this.emails = emails;
    }

    public ArrayList<Email> getEmails() {
        return emails;
    }
    
    public String toString(){
        StringBuilder sb = new StringBuilder();
        sb.append("Contacto: \n");
        sb.append("idContact = ").append(id).append("\n");
        sb.append("idPlat = ").append(idPlat).append("\n");
        sb.append("displayname = ").append(displayName).append("\n");
        sb.append("phone = ").append(phones.get(0).getNumber()).append("\n");
        sb.append("quickOrder = ").append(quickDial).append("\n");
        sb.append("deleted = ").append(delete).append("\n");
        return sb.toString();
    }
}
