package es.tid.ehealth.mobtel.android.common.json;

import java.io.IOException;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.ContactsContract.CommonDataKinds.Phone;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.bo.MPhone;
import es.tid.ehealth.mobtel.android.common.utils.Base64;

public class ConfigJson {

    public final String JSON_NAME_CONFIG = "configJson";
    public final String JSON_NAME_ACK_CONFIG = "ackConfig";

    //Default
    public final String JSON_NAME_ID_KIT = "idKit";   
    public final String JSON_NAME_TIMESTAMP = "timeStamp";

    //Contact
    public final String JSON_NAME_CONTACTS= "contacts";
    public final String JSON_NAME_CONTACTS_ARRAY= "arrayContacts";
    public final String JSON_NAME_ID_PKG_CONTACTS = "idPkgContacts";
    public final String JSON_NAME_CONTACT_ID = "idContact";
    public final String JSON_NAME_ALIAS = "alias";
    public final String JSON_NAME_PHONE = "phone";
    public final String JSON_NAME_QUICK_ORDER = "quickOrder";
    public final String JSON_NAME_IMAGE = "image";
    public final String JSON_NAME_DELETED = "deleted";

    //SafeZones
    public final String JSON_NAME_SAFEZONES = "safeZones";
    public final String JSON_NAME_SAFEZONES_ARRAY = "arraySafeZones";
    public final String JSON_NAME_ID_PKG_SAFEZONES = "idPkgSafeZones";

    //ACK´s
    public final String JSON_NAME_ACK_CONTACTS = "ackIdPkgContacts";
    public final String JSON_NAME_ACK_SAFEZONES = "ackIdPkgSafeZones";

    protected JSONObject jObject;
    private HashMap<String,Contact> contacts = null;
    private String idPkgContacts;
    private String idPkgSafeZones;
    protected String idKit;
    protected String timeStamp;

    private static final Logger logger = LoggerFactory.getLogger(ConfigJson.class);


    /**
     * Method to parse a JSON Configuration String
     * @param jsonString
     * @throws JSONException
     */
    public void parseFromJSON(final String jsonString) {

        logger.debug("JSON String:"+jsonString);

        try {
            jObject = new JSONObject(jsonString);
            final JSONObject data = new JSONObject(jObject.getString(JSON_NAME_CONFIG));

            idKit = data.getString(JSON_NAME_ID_KIT);
            timeStamp = data.getString(JSON_NAME_TIMESTAMP);        

            //CONTACTS
            final JSONObject dataContacts = new JSONObject(data.getString(JSON_NAME_CONTACTS));
            idPkgContacts = dataContacts.getString(JSON_NAME_ID_PKG_CONTACTS);
            parseContacts(dataContacts.getJSONArray(JSON_NAME_CONTACTS_ARRAY));        
            
            /*
            //SAFEZONES
            final JSONObject dataSafesZones = new JSONObject(data.getString(JSON_NAME_SAFEZONES));
            idPkgSafeZones = dataSafesZones.getString(JSON_NAME_ID_PKG_SAFEZONES);
            parseSafeZones(dataSafesZones.getJSONArray(JSON_NAME_SAFEZONES_ARRAY));
            */

        } catch (JSONException e) {    
            contacts = null;
            logger.error("Error parsing Configuration JSON: "+e);
        } 


    }

    /**
     * Method to parse contacts
     * @param contactArray
     * @throws JSONException
     */
    private void parseContacts(JSONArray contactArray) throws JSONException{

        logger.debug("There are ("+contactArray.length()+") CONTACTS to parse for this package with id = "+idPkgContacts);
        for (int i = 0; i < contactArray.length(); i++) {
            String idContact = contactArray.getJSONObject(i).getString(JSON_NAME_CONTACT_ID);
            String displayName = contactArray.getJSONObject(i).getString(JSON_NAME_ALIAS);
            
            String quick = contactArray.getJSONObject(i).getString(JSON_NAME_QUICK_ORDER);

            String deleted = contactArray.getJSONObject(i).getString(JSON_NAME_DELETED);
            //boolean delete = Boolean.getBoolean(deleted);
            boolean delete = false;
            if (deleted.equals("true")){
                delete = true;
            }

            byte[] photoBase64 = null;
            try {
                String photoString = contactArray.getJSONObject(i).getString(JSON_NAME_IMAGE);
                photoBase64 = Base64.decode(photoString.getBytes());
            } catch (final IOException e) {
                logger.error("Error decoding image in config contact JSON: "+e);
            }
            String phoneNumber = contactArray.getJSONObject(i).getString(
                    JSON_NAME_PHONE);
            MPhone mPhone = null;           
            mPhone = new MPhone(phoneNumber, Phone.TYPE_MOBILE);

            Bitmap photoBitmap = null;
            if (photoBase64.length > 0) {
                photoBitmap = BitmapFactory.decodeByteArray(photoBase64, 0,
                        photoBase64.length);
            }

            if (contacts == null ){
                contacts = new HashMap<String, Contact>(contactArray.length());
            }


            //Set info into contact object
            Contact contact = new Contact();            
            contact.setIdPlat(idContact);
            contact.setDisplayName(displayName);
            contact.addPhone(mPhone);
            if (quick != null && !quick.equals("")){
                contact.setQuickDial(Integer.parseInt(quick));
            }            
            contact.setPhotoBitmap(photoBitmap);
            contact.setDelete(delete);


            logger.debug(contact.toString());

            contacts.put(idContact,contact);           

        }
    }


    /**
     * Method to parse safe zones 
     * @param safeZonesArray
     */
    private void parseSafeZones(JSONArray safeZonesArray) {
        logger.debug("There are ("+safeZonesArray.length()+") SAFEZONES to parse for this package with id = "+idPkgSafeZones);
        for (int i = 0; i < safeZonesArray.length(); i++) {
            // TODO Fill pase saze Zones          
        }

    }
    
    public JSONObject requestConfigToJSon(final String idKit){
        
        final JSONObject jsoonRoot = new JSONObject();  
        final JSONObject resultAttributes = new JSONObject();
        
        String timeStamp = String.valueOf(System.currentTimeMillis());
      
     // Now generate the JSON output
        try {
            resultAttributes.put(JSON_NAME_ID_KIT, idKit);
            resultAttributes.put(JSON_NAME_TIMESTAMP, timeStamp);             
            jsoonRoot.put(JSON_NAME_CONFIG, resultAttributes);      
        } catch (JSONException e) {
            logger.error("Error requestConfigToJSon:"+e); 
            return null;
        }
        
        return jsoonRoot;       
        
    }
    
    public JSONObject requesAckToJSon(final String idKit,
            final String idPkgContact, 
            final String idPkgSafeZones) {
        final JSONObject jsoonRoot = new JSONObject();      
        final JSONObject resultAttributes = new JSONObject(); 

        String timeStamp = String.valueOf(System.currentTimeMillis());
        try{
            // Now generate the JSON output
            resultAttributes.put(JSON_NAME_ID_KIT, idKit);
            resultAttributes.put(JSON_NAME_TIMESTAMP, timeStamp);        
            resultAttributes.put(JSON_NAME_ACK_CONTACTS, idPkgContact);
            resultAttributes.put(JSON_NAME_ACK_SAFEZONES, idPkgSafeZones);

            jsoonRoot.put(JSON_NAME_ACK_CONFIG, resultAttributes);

        }catch (JSONException e) {
            logger.error("Error requestConfigToJSon:"+e); 
            return null;
        }

        return jsoonRoot;
    }


    /**
     * Test of this class method
     */
    public String testConfigJson (){
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"configJson\":");
        sb.append("{");
        sb.append("\"idKit\":\"62\",");
        sb.append("\"timeStamp\":\"01254122275454564124\",");

        //---ContactArray
        sb.append("\"contacts\":");
        sb.append("{");
        sb.append("\"idPkgContacts\":\"4231\",");
        sb.append("\"arrayContacts\":");
        sb.append("[");

        sb.append("{\"idContact\":\"95\",");
        sb.append("\"alias\":\"Emilio\",");
        sb.append("\"phone\":\"1111111\",");
        sb.append("\"quickOrder\":\"1\",");
        sb.append("\"image\":\"\",");
        sb.append("\"deleted\":\"false\"},");

        sb.append("{\"idContact\":\"96\",");
        sb.append("\"alias\":\"Carmen\",");
        sb.append("\"phone\":\"2222222\",");
        sb.append("\"quickOrder\":\"2\",");
        sb.append("\"image\":\"\",");
        sb.append("\"deleted\":\"false\"},");

        sb.append("{\"idContact\":\"98\",");
        sb.append("\"alias\":\"Antonio\",");
        sb.append("\"phone\":\"4444444\",");
        sb.append("\"quickOrder\":\"4\",");
        sb.append("\"image\":\"\",");
        sb.append("\"deleted\":\"true\"},");  

        sb.append("{\"idContact\":\"97\",");
        sb.append("\"alias\":\"Felipe\",");
        sb.append("\"phone\":\"3333333\",");
        sb.append("\"quickOrder\":\"3\",");
        sb.append("\"image\":\"\",");
        sb.append("\"deleted\":\"false\"}");  



        sb.append("]},");
        //--- END ContactArray

        //---safeZonesArray
        sb.append("\"safeZones\":");   
        sb.append("{");
        sb.append("\"idPkgSafeZones\":\"0\",");
        sb.append("\"arraySafeZones\":");
        sb.append("[");
        sb.append("]}");       
        //---END safeZonesArray


        sb.append("}");
        sb.append("}");

        return sb.toString();

    }

    public HashMap<String,Contact> getContacts() {
        return contacts;
    }

    public void setIdPkgContacts(String idPkgContacts) {
        this.idPkgContacts = idPkgContacts;
    }

    public String getIdPkgContacts() {
        return idPkgContacts;
    }

    public void setIdPkgSafeZones(String idPkgSafeZones) {
        this.idPkgSafeZones = idPkgSafeZones;
    }

    public String getIdPkgSafeZones() {
        return idPkgSafeZones;
    }

}
