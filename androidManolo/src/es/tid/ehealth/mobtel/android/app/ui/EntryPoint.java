package es.tid.ehealth.mobtel.android.app.ui;


import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.Toast;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.app.services.SynchronizationService;
import es.tid.ehealth.mobtel.android.app.ui.emergency.EmergencyCountDown;
import es.tid.ehealth.mobtel.android.common.bo.Contact;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;
import es.tid.ehealth.mobtel.android.common.services.ContactService;
import es.tid.ehealth.mobtel.android.common.services.impl.ContactServiceImpl;

public class EntryPoint extends AppActivity {   

    private static final Logger logger = LoggerFactory.getLogger(EntryPoint.class);

    private ImageButton emergencyButton;
    private static ImageView signalImage;
    private ImageButton gotocontactsImage;
    private ImageButton[] quickButtons = new ImageButton[4];

    private Contact quickSelected;

    private HashMap<Integer, Contact> qdContacts;

    private ContactService contactS;

    private static final int PICK_CONTACT = 3;


    @Override
    protected void onStart() {
        super.onStart();
    }


    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.entrypoint);
        init();
    }	

    private void init() {

        contactS = new ContactServiceImpl(this);

        emergencyButton = (ImageButton) findViewById(R.id.buttonemergency);
        emergencyButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {  
                logger.debug("Emergency button clicked");
                EmergencyCountDown.launch(getApplicationContext());
                finish();            	            	            	
            }
        });
        emergencyButton.setImageResource(R.drawable.botonemergencia);

        quickButtons[0] = (ImageButton) findViewById(R.id.quickbutton1); 
        quickButtons[0].setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                callTo(1);	            	
            }


        });
        quickButtons[0].setImageResource(R.drawable.nocontactframe);

        quickButtons[1] = (ImageButton) findViewById(R.id.quickbutton2);
        quickButtons[1].setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                callTo(2);            	
            }
        });
        quickButtons[1].setImageResource(R.drawable.nocontactframe);

        quickButtons[2] = (ImageButton) findViewById(R.id.quickbutton3);
        quickButtons[2].setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                callTo(3);
            }
        });
        quickButtons[2].setImageResource(R.drawable.nocontactframe);

        quickButtons[3] = (ImageButton) findViewById(R.id.quickbutton4);
        quickButtons[3].setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                callTo(4);
            }
        });
        quickButtons[3].setImageResource(R.drawable.nocontactframe);		

        loadQuickDials();

        gotocontactsImage = (ImageButton)  findViewById(R.id.imagecontactlist);		
        gotocontactsImage.setImageResource(R.drawable.contact_off_big);
        gotocontactsImage.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                ContactListInfo.launch(getApplicationContext());            

            }
        });

        signalImage = (ImageView)  findViewById(R.id.imagesignal);		
        signalImage.setImageResource(R.drawable.signal2_big);	

        //gotocontactsImage = (ImageButton)  findViewById(R.id.imagegotocontact);		
        //gotocontactsImage.setImageResource(R.drawable.contact_off_big);       
        
    }



    private void loadQuickDials() {	


        qdContacts = contactS.getQuickDialContactsData();

        if (qdContacts != null){
            try {
                for (int i = 1;i<=4;i++){
                    if (qdContacts.get(i) != null && qdContacts.get(i).getPhotoBitmap() != null){
                        logger.debug("Set quickDial "+i);    					
                        quickButtons[i-1].setImageBitmap(qdContacts.get(i).getPhotoBitmap());
                    }
                }    			

            }catch (Exception e) {
                logger.error("Error setting image in quickdials: "+e);
            }
        }else{
            logger.info("No quick dial contacts were being loaded");
        }

    }

    private void callTo(int quick) {		

        try {
            quickSelected = qdContacts.get(quick);	
            logger.debug("Calling to "+quickSelected.getPhones().get(0).getNumber());
            Intent i = new Intent();
            i.setAction(Intent.ACTION_CALL);
            i.setData(Uri.parse("tel:" + quickSelected.getPhones().get(0).getNumber()));
            startActivity(i);
            finish();
        }catch (Exception e) {
            logger.error("Error trying calling -> "+e);
        }
    }


    public static void launch(Context context) {
        Intent i = new Intent(context,EntryPoint.class);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(i);

    }


    @Override
    public void onActivityResult(int reqCode, int resultCode, Intent data){
        super.onActivityResult(reqCode, resultCode, data);

        switch(reqCode){
        case (PICK_CONTACT):
            if (resultCode == Activity.RESULT_OK){
                Uri contactData = data.getData();
                Cursor c = managedQuery(contactData, null, null, null, null);

                if (c.moveToFirst()){
                    // other data is available for the ContactBO.  I have decided
                    //    to only get the name of the ContactBO.
                    String name = c.getString(c.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));
                    Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
                }
            }
        }
    }

    public void openListContactsActivityAndPickContact(){
        Intent intent = new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI);
        startActivityForResult(intent, PICK_CONTACT);
    }

    public static void setSignalImage(int valor){
        //logger.debug("Signal to be drawn: "+valor);
        if (signalImage != null){
            try {

                if (valor == 99 || valor < 0){		
                    signalImage.setImageResource(R.drawable.signal0_big);	
                    return;

                }
                if (valor >= 0  && valor < 10){
                    signalImage.setImageResource(R.drawable.signal1_big);	
                    return;
                }

                if (valor >=10  && valor < 15){		
                    signalImage.setImageResource(R.drawable.signal2_big);	
                    return;

                }
                if (valor >=15  && valor < 20){		
                    signalImage.setImageResource(R.drawable.signal3_big);	
                    return;

                }
                if (valor >=20  ){		
                    signalImage.setImageResource(R.drawable.signal4_big);	
                    return;

                }
            }catch (Exception e) {
                logger.error("Setting singal image: "+e);
            }
        }

    }

}