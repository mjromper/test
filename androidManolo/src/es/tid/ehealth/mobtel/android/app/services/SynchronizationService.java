package es.tid.ehealth.mobtel.android.app.services;

import java.util.HashMap;
import java.util.Iterator;

import org.json.JSONObject;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.json.ConfigJson;
import es.tid.ehealth.mobtel.android.common.json.JsonHttpClient;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class SynchronizationService extends Service{
    
    private static final Logger logger = LoggerFactory.getLogger(SynchronizationService.class);
    
    static final String idKit = "1";

    @Override
    public IBinder onBind(Intent intent) {        
        return null;
    }

    @Override 
    public void onCreate() 
    {
        super.onCreate();
        _startService();
        
        
    }

    @Override 
    public void onDestroy() 
    {
        super.onDestroy();
        _shutdownService();
        
 
    }
    
        
    /**
     * shutting down the Synchronization service
     */
    private void _shutdownService() {
        logger.debug("SynchronizationService stopped");        
    }

    /**
     * starting the synchronization service
     */
    private void _startService()
    {   
        logger.debug("SynchronizationService started");
        doServiceWork();
    }
    
    /**
     * start the processing, the actual work, getting config params, get data from network etc
     */
    private void doServiceWork()
    {
        ContactService cs = new ContactServiceImpl(this);         
        ConfigJson configJson = new ConfigJson();
        JSONObject request = configJson.requestConfigToJSon(idKit);
        JSONObject jSonObj = JsonHttpClient.SendHttpPost(getString(R.string.url_config_cgi), request);      
                        
        if (jSonObj != null){
            
           
            boolean contactOk = true;
            
            configJson.parseFromJSON(jSonObj.toString());
            
            HashMap<String, Contact> contactos = configJson.getContacts();
            String ackIdPkgContact = configJson.getIdPkgContacts();
            if (contactos != null){
                Iterator<String> it1 = contactos.keySet().iterator();
                while (it1.hasNext()){   
                    Contact c = contactos.get(it1.next());
                    if (c.isDelete()){
                        contactOk = cs.delete(c);
                    }else{
                        contactOk = cs.updateOrCreate(c);                      
                    } 
                    
                    if (!contactOk){
                        ackIdPkgContact = "0";
                    }
                }
            }
            
            
            String ackIdPkgSafeZones = configJson.getIdPkgSafeZones();
            
            JSONObject ack = configJson.requesAckToJSon(idKit, ackIdPkgContact, ackIdPkgSafeZones);
            jSonObj = JsonHttpClient.SendHttpPost(getString(R.string.url_ack_cgi),ack);
            
            stopSelf();
            
        }       

    }

}
